module bindbc.nodave.types;

enum NodaveSupport {
   noLibrary,
   badLibrary,
   //version 0.8.5.1
   nodave851 = 851,
}

enum NODAVE_VERSION_MAJOR = 0;

version (NODAVE_851) {
   enum NODAVE_VERSION_MINOR = 8;
   enum NODAVE_VERSION_REVISION = 5;
   enum nodaveSupport = NodaveSupport.nodave851;
} else {
   enum NODAVE_VERSION_MINOR = 8;
   enum NODAVE_VERSION_REVISION = 5;
   enum nodaveSupport = NodaveSupport.nodave851;
}

enum daveProtoISOTCP = 122; /** ISO over TCP */

/** ProfiBus/MPI speed constants to be used with newInterface */
enum daveSpeed9k = 0;
enum daveSpeed19k = 1;
enum daveSpeed187k = 2;
enum daveSpeed500k = 3;
enum daveSpeed1500k = 4;
enum daveSpeed45k = 5;
enum daveSpeed93k = 6;

enum daveP = 0x80;
enum daveInputs = 0x81;
enum daveOutputs = 0x82;
enum daveFlags = 0x83;
enum daveDB = 0x84; /** Data blocks */
enum daveDI = 0x85; /** Instance data blocks */
enum daveLocal = 0x86; /* not tested */
enum daveV = 0x87; /* don't know what it is */
enum daveCounter = 28; /** S7 counters */
enum daveTimer = 29; /** S7 timers */
enum daveCounter200 = 30; /* IEC counters (200 family) */
enum daveTimer200 = 31; /* IEC timers (200 family) */

struct daveOSserialType {
   int rfd;
   int wfd;
}

struct PDU {
   ubyte* param;
   ubyte* data;
   ubyte* udata;
   int hlen;
   int plen;
   int dlen;
   int udlen;
}

/**
 * A structure representing the physical connection to a PLC or a network of PLCs (e.g. like MPI).
 * daveInterface stores all those properties that are common to a network of PLCs:
 * $(LIST
 *   * The local address used by your computer.
 *   * The speed used in this network.
 *   * The protocol type used in this network.
 *   * A name which is used when printing out debug messages.
 * )
 *
 * The structure daveInterface is created and initialized by daveNewInterface:
 *
 * --------------------
 * daveInterface* di;
 * di = daveNewInterface(fds, "IF1", localMPI, daveProtoXXX, daveSpeedYYY);
 * --------------------
 *
 * or in D
 * --------------------
 * auto sock = new TcpSocket(new InternetAddress(ip, to!(ushort)(port)));
 * fds.wfd = fds.rfd = sock.handle;
 * daveInterface* di = daveNewInterface(fds, "IF1", 0, daveProtoISOTCP, daveSpeed9k);
 * --------------------
 */
struct daveInterface {
   int _timeout;
}

/**
 * A structure representing the physical connection to a single PLC.
 * daveConnection stores all properties that are unique to a single PLC:
 *
 * $(LIST
 *   * The MPI address of this PLC.
 *   * The rack the PLC is in.
 *   * The slot the PLC is in.
 *   )
 */
struct daveConnection {
   int AnswLen;
   ubyte* resultPointer;
   int maxPDUlength;
}

struct daveBlockTypeEntry {
   ubyte[2] type;
   ushort count;
}

struct daveBlockEntry {
   ushort number;
   ubyte[2] type;
}

struct daveResult {
   int error;
   int length;
   ubyte* bytes;
}

struct daveResultSet {
   int numResults;
   daveResult* results;
}
