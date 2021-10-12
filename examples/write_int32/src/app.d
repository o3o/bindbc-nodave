import loader = bindbc.loader.sharedlib;
import bindbc.nodave;
import std.experimental.logger;
import std.string : fromStringz;
import std.socket;
import std.stdio;
import std.array : appender;

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


      enum string IP = "192.168.0.2";
      enum DB = 610;
      enum ADDR = 4;

      string ip = IP;
      if (args.length > 1) {
         ip = args[1];
      }

      try {
         writeln("use ip ", ip);

         enum ushort PORT = 102;
         auto sock = new TcpSocket(new InternetAddress(ip, PORT));

         daveConnection* dc = createConnection(sock);
         scope(exit) {
            daveDisconnectPLC(dc);
            sock.close;
         }

         enum BYTES_PER_DINT = 4;
         enum BYTES_PER_INT = 2;
         enum FIELDS = 3;

         ubyte[BYTES_PER_DINT * FIELDS] buf;
         davePut32At(buf.ptr, BYTES_PER_DINT * 0, 2200);
         davePut32At(buf.ptr, BYTES_PER_DINT * 1, 42);
         davePut32At(buf.ptr, BYTES_PER_DINT * 2, 640);
         daveWriteBytes(dc, daveDB, DB, ADDR, 12, buf.ptr);

         daveReadBytes(dc, daveDB, DB, ADDR, 12, null);
         for (size_t i = 0; i < 3; ++i) {
            writefln("addr %03d :%s", i * BYTES_PER_DINT  + 4, dc.daveGetS32());
         }

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



      } catch(Exception e) {
         writeln(e);
      }
   }
}
