import loader = bindbc.loader.sharedlib;
import bindbc.nodave;
import std.experimental.logger;
import std.string : fromStringz;
import std.socket;
import std.stdio;
import std.array : appender;
import std.getopt;

void main(string[] args) {
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


      string ip = "192.168.113.50";
      int db = 601;
      int start = 46;
      int val = 0;
      enum ushort PORT = 102;

      auto opt = getopt(args,
            "ip", "Ip (192.168.113.50)", &ip,
            "d", "DB num (default 601)", &db,
            "s", "Start address (default 46)", &start,
            "v", "Value ", &val,
            );
      if (opt.helpWanted) {
         defaultGetoptPrinter("Write int (4 bytes) from Siemens S7",
               opt.options);
      } else {
         try {
            writefln("ip:%s db:%s start:%s val:%s", ip, db, start, val);

            auto sock = new TcpSocket(new InternetAddress(ip, PORT));
            daveConnection* dc = createConnection(sock);
            scope(exit) {
               daveDisconnectPLC(dc);
               sock.close;
            }

            enum BYTES_PER_DINT = 4;
            enum BYTES_PER_INT = 2;

            ubyte[BYTES_PER_DINT] buf;
            davePut32At(buf.ptr, BYTES_PER_DINT * 0, val);

            daveWriteBytes(dc, daveDB, db, start, BYTES_PER_DINT, buf.ptr);

            /+
               auto app = appender!(ubyte[]);
            app.put16(120);
            app.put16(122);
            app.put16(124);
            daveWriteBytes(dc, daveDB, DB, 20, 6, app.data.ptr);
            writeln("appender");
            writeln();
            daveReadBytes(dc, daveDB, DB, 20, 6, null);
            for (size_t i = 0; i < 3; ++i) {
               writefln(" addr %03d :%s", i * BYTES_PER_INT  + 20, dc.daveGetS16());
            }
            +/
         } catch(Exception e) {
            writeln(e);
         }
      }
   }
}
