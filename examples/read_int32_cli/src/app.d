import std.stdio;
import std.conv;
import std.bitmanip;
import std.getopt;
import loader = bindbc.loader.sharedlib;
import bindbc.nodave;
import std.experimental.logger;
import std.string : fromStringz;
import std.socket;

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

      auto opt = getopt(args,
            "ip", "Ip (172.20.0.10)", &ip,
            "slot", "Slot (default 0)", &slot,
            "d", "DB num (default 610)", &db,
            "s", "Start address (default 2)", &start,
            "l", "Length in int (default 2)", &len
            );
      if (opt.helpWanted) {
         defaultGetoptPrinter("Read int (4 bytes) from Siemens S7",
               opt.options);
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
               enum BYTES_PER_DINT = 4;

               const(int) err = daveReadBytes(dc, daveDB, db, start, len * BYTES_PER_DINT, null);
               //s7.readBytes(db, start, len * BYTES_PER_INT);
               for (int i = 0; i < len; ++i) {
                  print(db, start + i * BYTES_PER_DINT, dc.daveGetU32);
               }
            }
         } catch(Exception e) {
            writeln(e);
         }
      }
   }
}

void print(int db, int addr, uint i0) {
   writefln("db%s.%s %s", db, addr, i0);
}
