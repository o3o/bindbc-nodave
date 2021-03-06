import std.stdio;
import std.conv;
import std.bitmanip;
import std.getopt;
import loader = bindbc.loader.sharedlib;
import bindbc.nodave;
import std.experimental.logger;
import std.string : fromStringz;
import std.socket;
import core.bitop : bt;
import std.array : appender;

void main(string[] args) {
   writeln("try load");

   NodaveSupport retVal = loadNodave();
   info(loadedNodaveVersion);

   if (retVal != nodaveSupport) {
      foreach (info; loader.errors) {
         error(fromStringz(info.error), ":", fromStringz(info.message));
      }
      writeln("ERROR: ", retVal);
   } else {
      writeln("VERSION: ", retVal);
      writeln("loaded : ", loadedNodaveVersion);


      string ip = "172.20.0.10";
      int db = 610;
      int start = 2;
      int len = 2;
      int slot = 0;
      int port = 102;
      int func = 0;
      double value = 0;

      auto opt = getopt(args,
            "ip", "Ip (172.20.0.10)", &ip,
            "slot", "Slot (default 0)", &slot,
            "d", "DB num (default 610)", &db,
            "s", "Start address (default 2)", &start,
            "l", "Number of element", &len,
            "f", "Function ", &func,
            "a", "Argument/Value", &value
            );
      if (opt.helpWanted) {
         defaultGetoptPrinter("Read bytes from Siemens S7",
               opt.options);
         funcHelp();
      } else {
         try {
            writefln("ip:%s slot:%s DB:%s start:%s len:%s", ip, slot, db, start, len);
            writeln();
            auto sock = new TcpSocket(new InternetAddress(ip, to!(ushort)(port)));

            daveOSserialType fds;
            fds.rfd = sock.handle;
            fds.wfd = fds.rfd;

            if (fds.rfd > 0) {
               daveInterface* di = daveNewInterface(fds, "IF1", 0, daveProtoISOTCP, daveSpeed9k);
               daveSetTimeout(di, 5_000_000);
               enum int MPI = 0; //The address of the PLC (only meaningful for MPI and PPI).
               enum int RACK = 0; // The rack the CPU is mounted in (normally 0, only meaningful for ISO over TCP).
               daveConnection* dc = daveNewConnection(di, MPI, RACK, slot);
               if (daveConnectPLC(dc) != 0) {
                  throw new Exception("Couldn't connect to PLC with ip " ~ ip);
               }

               scope(exit) {
                  daveDisconnectPLC(dc);
                  sock.close;
               }
               switch (func) {
                  case 0:
                     // read len short (2 bytes)
                     enum BYTES_PER_INT = 2;
                     const(int) err = daveReadBytes(dc, daveDB, db, start, len * BYTES_PER_INT, null);
                     for (int i = 0; i < len; ++i) {
                        print(db, start + i * BYTES_PER_INT, dc.daveGetU16);
                     }
                     break;
                  case 1:
                     // read 1 integer (2 bytes)
                     ubyte[2] buf;
                     const(int) err = daveReadBytes(dc, daveDB, db, start, 2 , buf.ptr);
                     writefln("%(0x%x %)", buf);
                     ushort v = bigEndianToNative!ushort(buf);
                     writefln("0x%x", v);
                     break;
                  case 2:
                     // read len integer (4 bytes)
                     enum BYTES_PER_DINT = 4;
                     const(int) err = daveReadBytes(dc, daveDB, db, start, len * BYTES_PER_DINT, null);
                     for (int i = 0; i < len; ++i) {
                        print(db, start + i * BYTES_PER_DINT, dc.daveGetU32);
                     }
                     break;
                  case 5:
                     // read float  (4 bytes)
                     enum BYTES_PER_FLOAT = 4;
                     const(int) err = daveReadBytes(dc, daveDB, db, start, len * BYTES_PER_FLOAT, null);
                     for (int i = 0; i < len; ++i) {
                        writefln("db%s.%s %f", db, start + i * BYTES_PER_FLOAT, dc.daveGetFloat);
                     }
                     break;

                 case 3:
                     enum BYTES_PER_LONG = 8;
                     // read a 64bit
                     ubyte[BYTES_PER_LONG] idBuffer;

                     const(int) err = daveReadBytes(dc, daveDB, db, start, BYTES_PER_LONG, null);
                     foreach (i; 0 .. BYTES_PER_LONG) {
                        idBuffer[i] = dc.daveGetU8.to!ubyte;
                        print(db, start + i , idBuffer[i]);
                     }
                     ulong id = bigEndianToNative!ulong(idBuffer);
                     writeln(id);
                     break;
                 case 30:
                     enum BYTES_PER_LONG = 8;
                     // read a 64bit
                     ubyte[BYTES_PER_LONG] idBuffer;

                     const(int) err = daveReadBytes(dc, daveDB, db, start, BYTES_PER_LONG, idBuffer.ptr);
                     writefln("%(0x%x %)", idBuffer);

                     ulong id = bigEndianToNative!ulong(idBuffer);
                     writeln(id);
                     break;
                 case 4:
                     // read string
                     ubyte[1024] buf;
                     const(int) err = daveReadBytes(dc, daveDB, db, start, len, buf.ptr);
                     writefln("err %s", err);
                     //writefln("%(0x%x %)", buf);

                     string s = buf.getNTString();
                     writeln(s);

                     break;
                 case 40:
                     // read string
                     ubyte[] buf; // NO, must be static array
                     const(int) err = daveReadBytes(dc, daveDB, db, start, len, buf.ptr);
                     assert(err == 0);
                     assert(buf.length == 0);
                     writefln("err %s buf.len %s", err, buf.length);

                     writefln("%(0x%x %)", buf);
                     string s = buf.getNTString();
                     writeln(s);
                     break;
                 case 50:
                     // write and read a uint
                     uint V = 0x80402010;
                     ubyte[4] buf = nativeToBigEndian(V);
                     daveWriteBytes(dc, daveDB, db, start, 4, buf.ptr);

                     ubyte[4] rep;
                     const(int) err = daveReadBytes(dc, daveDB, db, start, len, rep.ptr);
                     ubyte[] slice = rep.dup;
                     uint u = slice.read!(uint, Endian.bigEndian)();
                     writefln("0x%x", u);

                     daveReadBytes(dc, daveDB, db, start, len, null);
                     writefln("%s %s", dc.daveGetU32, dc.daveGetS32);
                     break;
                 case 60:
                     // write and read a float
                     enum float MIN = -42.0;
                     enum float MAX = 3.14;

                     auto buf = appender!(ubyte[]);
                     buf.putFloat(MIN);
                     buf.putFloat(MAX);
                     daveWriteBytes(dc, daveDB, db, start, 8, buf.data.ptr);

                     break;
                 case 7:
                     // read bytes
                     const(int) err = daveReadBytes(dc, daveDB, db, start, len, null);
                     for (int i = 0; i < len; ++i) {
                        writefln("db%s.%s 0x%x", db, i + start, dc.daveGetU8);
                     }
                     break;
                 case 8:
                     enum LEN = 16;
                     ubyte[LEN] buffer;
                     size_t[2] alert;
                     const(int) err = daveReadBytes(dc, daveDB, db, start, LEN, buffer.ptr);
                     ubyte[] buf = buffer.dup;
                     writefln("%( 0x%x %)", buf);

                     alert[0] = buf.read!(size_t, Endian.littleEndian);
                     alert[1] = buf.read!(size_t, Endian.littleEndian);
                     foreach (i; 0 .. LEN * 8) {
                        if (bt(alert.ptr, i)) {
                           writefln("alarm %s", i);
                        }
                     }
                     break;
                 case 9:
                     // write short
                     auto buf = appender!(ubyte[]);
                     buf.put16(value.to!short);
                     daveWriteBytes(dc, daveDB, db, start, 2, buf.data.ptr);
                     break;

                  default:
                     assert(false);
               }
            }
         } catch(Exception e) {
            writeln(e);
         }
      }
   }
}

void print(int db, int addr, uint i0) {
   writefln("db%s.%s 0x%x (%s)", db, addr, i0, i0);
}
void funcHelp() {
   writeln();
   writeln("Function code:");
   writeln("0: read `len` short (2 bytes)");
   writeln("1: read one short (2 bytes)");
   writeln("2: read `len` int (4 bytes)");
   writeln("3: read long (8 bytes)");
   writeln("30: read long (8 bytes)");
   writeln("4: read string (max 1024 bytes)");
   writeln("5: read `len` float (4 bytes)");
   writeln("50: write/read uint (4 bytes)");
   writeln("60: write 2 float (4 bytes)");
   writeln("7: read `len` bytes");
   writeln("8: read `len` bytes and print bits");
   writeln("9: write ushort");
   writeln("\t read_int32_cli --ip<IP> -d<DB> -s<ADDR> -f<FUNC> -a<value>");

}
