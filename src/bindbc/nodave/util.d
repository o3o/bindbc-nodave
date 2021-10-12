module bindbc.nodave.util;
import std.socket : TcpSocket;

import bindbc.nodave;
/**
 * Creates a new daveConnection
 * Params:
 *  sock = Tcp socket
 *  rack = The rack the CPU is mounted in (normally 0, only meaningful for ISO over TCP).
 *  slot = The rack the CPU is mounted in (normally 0, only meaningful for ISO over TCP).
 *
 */
daveConnection* createConnection(TcpSocket sock, int rack = 0, int slot = 0) {
   enum int MPI = 0; //The address of the PLC (only meaningful for MPI and PPI).
   enum int RACK = 0; // The rack the CPU is mounted in (normally 0, only meaningful for ISO over TCP).
   enum int SLOT = 0;

   daveOSserialType fds;
   fds.rfd = sock.handle;
   fds.wfd = fds.rfd;

   if (fds.rfd > 0) {
      daveInterface* di = daveNewInterface(fds, "IF1", 0, daveProtoISOTCP, daveSpeed9k);
      daveSetTimeout(di, 5_000_000);
      daveConnection* dc = daveNewConnection(di, MPI, rack, slot);
      if (daveConnectPLC(dc) != 0) {
         throw new Exception("Couldn't connect to PLC ");
      }
      return dc;
   } else {
      throw new Exception("Invalid file descriptor");
   }
}

/**
 * Write a sequence of bytes from a buffer to PLC memory, db area.
 * Params:
 *  param = param description
 *  dc     = A pointer to a daveConnection structure representing an established connection.
 *  db     = The number of a data block. Only meaningful if area is daveDB. Use 0 oterwise.
 *  start  = The address of the first byte in the block.
 *  len    = The number of bytes to write.
 *  buffer = Buffer to write.
 *  buffer = An array
 */
int writeBytes(daveConnection* dc, int db, int start, int len, ubyte[] buffer) {
   return daveWriteBytes(dc, daveDB, db, start, len, buffer.ptr);
}
