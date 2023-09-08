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
import std.datetime.stopwatch : StopWatch;

void main(string[] args) {
   writeln("try load");
   enum BYTES_PER_INT = 2;
   enum BYTES_PER_DINT = 4;
   enum BYTES_PER_LONG = 8;
   enum BYTES_PER_FLOAT = 4;

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
      long duration = 5; // in secondi
      string cmd = "";
      string valueList = "";

      auto opt = getopt(args,
            "ip", "Ip (172.20.0.10)", &ip,
            "slot", "Slot (default 0)", &slot,
            "d", "DB num (default 610)", &db,
            "s", "Start address (default 2)", &start,
            "l", "Number of element (see cmd)", &len,
            "c", "Command", &cmd,
            "i", "Loop durarion (s)", &duration,
            "b", "Buffer", &valueList
            );
      if (opt.helpWanted) {
         defaultGetoptPrinter("Siemens S7 cli",
               opt.options);
         help();
      } else {
         try {
            writefln("ip:%s slot:%s DB:%s start:%s len:%s", ip, slot, db, start, len);
            writeln();
            auto sock = new TcpSocket(new InternetAddress(ip, to!(ushort)(port)));

            daveConnection* dc = createConnection(sock);
            scope(exit) {
               daveDisconnectPLC(dc);
               sock.close;
            }

            switch (cmd) {
               case "ru8":
                  // read bytes
                  const(int) err = daveReadBytes(dc, daveDB, db, start, len, null);
                  for (int i = 0; i < len; ++i) {
                     writefln("db%s.%s 0x%x", db, i + start, dc.daveGetU8);
                  }
                  break;
               case "ru16":
                  // read len short (2 bytes)
                  dc.readBytes(db, start, len * BYTES_PER_INT);
                  for (int i = 0; i < len; ++i) {
                     print(db, start + i * BYTES_PER_INT, dc.daveGetU16);
                  }
                  break;
               case "ru16n":
                  // legge un intero 16 nativavmente
                  ubyte[2] buf;
                  const(int) err = daveReadBytes(dc, daveDB, db, start, 2 , buf.ptr);
                  writefln("%(0x%x %)", buf);
                  ushort v = bigEndianToNative!ushort(buf);
                  writefln("0x%x", v);
                  break;
               case "ru32":
                  // read len integer (4 bytes)
                  const(int) err = daveReadBytes(dc, daveDB, db, start, len * BYTES_PER_DINT, null);
                  for (int i = 0; i < len; ++i) {
                     print(db, start + i * BYTES_PER_DINT, dc.daveGetU32);
                  }
                  break;
               case "ru64":
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
               case "rf":
                  // read float  (4 bytes)
                  const(int) err = daveReadBytes(dc, daveDB, db, start, len * BYTES_PER_FLOAT, null);
                  for (int i = 0; i < len; ++i) {
                     writefln("db%s.%s %f", db, start + i * BYTES_PER_FLOAT, dc.daveGetFloat);
                  }
                  break;

               case "rs":
                  // read string
                  ubyte[1024] buf;
                  const(int) err = daveReadBytes(dc, daveDB, db, start, len, buf.ptr);
                  writefln("err %s", err);
                  //writefln("%(0x%x %)", buf);

                  string s = buf.getNTString();
                  writeln(s);

                  break;
               case "rs1":
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
               case "ralarm":
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
               case "wu8":
                  ubyte[] buf = valueList.toBytes();
                  writefln("%(%s %)", buf);
                  daveWriteBytes(dc, daveDB, db, start, buf.length.to!int, buf.ptr);
                  break;
               case "w16":
                  // write short
                  auto buf = appender!(ubyte[]);
                  short[] data = valueList.toBuffer!(short);
                  foreach (s; data) {
                     buf.put16(s);
                  }
                  daveWriteBytes(dc, daveDB, db, start, buf.data.length.to!int, buf.data.ptr);
                  break;
               case "wu32":
                  // write int
                  auto buf = appender!(ubyte[]);
                  short[] data = valueList.toBuffer!(short);
                  foreach (s; data) {
                     buf.putu32(s);
                  }
                  dc.writeBytes(db, start, BYTES_PER_DINT, buf.data);
                  break;
               case "rloop":
                  StopWatch sw;
                  sw.start;
                  while (sw.peek.total!"seconds" < duration) {
                     dc.readBytes(db, start, BYTES_PER_DINT);
                     writefln("%s : db%s.%s 0x%x", sw.peek.total!"seconds" , db, start, dc.daveGetU32);
                  }
                  break;
               default:
                  writefln("%s invalid command", cmd);
            }
         } catch(Exception e) {
            writeln(e);
         }
      }
   }
}

alias toBytes = toBuffer!(ubyte);

T[] toBuffer(T)(string s) {
   import std.algorithm: map, splitter;
   import std.array: array;
   import std.conv: to;

   auto result = s.splitter().map!(to!T);
   return result.array;
}

unittest {
   import std.algorithm;
   assert("1 2 3".toBuffer.equal([1, 3, 2]));
}

void print(int db, int addr, uint i0) {
   writefln("db%s.%s 0x%x (%s)", db, addr, i0, i0);
}

void help() {
   writeln();
   writeln("CMD:");
   writeln("ru8:read `l` bytes as uint8");
   writeln("ru16:read `l` bytes as uint16");
   writeln("ru32:read `l` bytes as uint32");
   writeln("ru64:read `l` bytes as uint64");
   writeln("f:read `l` bytes as float");
   writeln("wu8: write bytes");
   writeln("\ts7cli --ip <ip> -d100 -s42 -cwb -b \"1 2 3\"");
   writeln("w16 write int as int16");
   writeln("wu32 write int as uint32");
}
