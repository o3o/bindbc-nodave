//          Copyright 2021 - 2024 Orfeo Da Vià
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.nodave.binddynamic;

version (BindBC_Static) {
} else version (BindNodave_Static) {
} else {
   version = BindNodave_Dynamic;
}

version (BindNodave_Dynamic)  :

import bindbc.loader;
import bindbc.nodave.types;

extern (C) @nogc nothrow {
   alias pdaveGetS8from = int function(ubyte* b);
   alias pdaveGetU8from = int function(ubyte* b);
   alias pdaveGetS16from = int function(ubyte* b);
   alias pdaveGetU16from = int function(ubyte* b);
   alias pdaveGetS32from = int function(ubyte* b);
   alias pdaveGetU32from = uint function(ubyte* b);
   alias pdaveGetFloatfrom = float function(ubyte* b);
   alias pdavePut8 = ubyte* function(ubyte* b, int v);
   alias pdavePut16 = ubyte* function(ubyte* b, int v);
   alias pdavePut32 = ubyte* function(ubyte* b, int v);
   alias pdavePutFloat = ubyte* function(ubyte* b, float v);
   alias pdavePut8At = void function(ubyte* b, int pos, int v);
   alias pdavePut16At = void function(ubyte* b, int pos, int v);
   alias pdavePut32At = void function(ubyte* b, int pos, int v);
   alias pdavePutFloatAt = void function(ubyte* b, int pos, float v);

   alias pdaveToBCD = ubyte function(ubyte i);
   alias pdaveFromBCD = ubyte function(ubyte i);

   // plc
   // ---------
   alias pdaveGetS8 = int function(daveConnection* dc);
   alias pdaveGetU8 = int function(daveConnection* dc);
   alias pdaveGetS16 = int function(daveConnection* dc);
   alias pdaveGetU16 = int function(daveConnection* dc);
   alias pdaveGetS32 = int function(daveConnection* dc);
   alias pdaveGetU32 = uint function(daveConnection* dc);
   alias pdaveGetFloat = float function(daveConnection* dc);

   alias pdaveGetS8At = int function(daveConnection* dc, int pos);
   alias pdaveGetU8At = int function(daveConnection* dc, int pos);
   alias pdaveGetS16At = int function(daveConnection* dc, int pos);
   alias pdaveGetU16At = int function(daveConnection* dc, int pos);
   alias pdaveGetS32At = int function(daveConnection* dc, int pos);
   alias pdaveGetU32At = uint function(daveConnection* dc, int pos);
   alias pdaveGetFloatAt = float function(daveConnection* dc, int pos);

   alias pdaveSetBit = int function(daveConnection* dc, int area, int DB, int byteAdr, int bitAdr);
   alias pdaveClrBit = int function(daveConnection* dc, int area, int DB, int byteAdr, int bitAdr);

   /**
    * Read len bytes from the PLC.
    *
    * Params:
    *  dc = A daveConnection
    *  area = Denotes whether the data comes from FLAGS, DATA BLOCKS,
    *  DB = The number of the data block to be used. Set it to zero
    *  start = First byte.
    *  len = Number of bytes to read
    *  buffer = Pointer to a memory block provided by the calling program.
    *           If the pointer is not NULL, the result data will be copied thereto.
    *           Hence it must be big enough to take up the result.
    *
    */
   alias pdaveReadBytes = int function(daveConnection* dc, int area, int DB, int start, int len, void* buffer);

   /**
    * Write len bytes from `buffer` to the PLC.
    *
    * Params:
    *  dc = A daveConnection
    *  area = Denotes whether the data comes from FLAGS, DATA BLOCKS,  INPUTS or OUTPUTS. The writing of other data like timers and counters is not supported.
    *  start = determines the first byte
    *  DB = The number of the data block to be used. Set it to zero   for other area types.
    *  len = Number of bytes to write
    *  buffer = Pointer to a memory block.
    */
   alias pdaveWriteBytes = int function(daveConnection* dc, int area, int DB, int start, int len, void* buffer);

   alias pdaveReadPLCTime = int function(daveConnection* dc);

   /**
    * Get time in seconds from current read position
    */
   alias pdaveGetSeconds = float function(daveConnection* dc);

   /**
    * Get time in seconds from random position
    *
    * Params:
    *  dc = a daveConnection
    *  pos = Position in bytes
    *
    * Examples:
    * --------------------
    * // read 4 timers: each timer has 2 bytes
    * const(int) res = daveReadBytes(dc, daveTimer, 0, 0, 4, null);
    * // read second of timer 2
    * float d = daveGetSecondsAt(dc, 4);
    * // 4 because:
    * // | pos | timer   |
    * // | 0   | timer 0 |
    * // | 1   | timer 0 |
    * // | 2   | timer 1 |
    * // | 3   | timer 1 |
    * // | 4   | timer 2 | <----
    * // | 5   | timer 2 |
    * --------------------
    */
   alias pdaveGetSecondsAt = float function(daveConnection* dc, int pos);
   alias pdaveGetCounterValue = int function(daveConnection* dc);
   alias pdaveGetCounterValueAt = int function(daveConnection* dc, int pos);
   alias pdaveConstructUpload = void function(PDU* p, char blockType, int blockNr);
   alias pdaveConstructDoUpload = void function(PDU* p, int uploadID);
   alias pdaveConstructEndUpload = void function(PDU* p, int uploadID);

   alias pdaveGetOrderCode = int function(daveConnection* dc, char* buf);
   alias pdaveReadManyBytes = int function(daveConnection* dc, int area, int DBnum, int start, int len, void* buffer);
   alias pdaveWriteManyBytes = int function(daveConnection* dc, int area, int DB, int start, int len, void* buffer);
   alias pdaveReadBits = int function(daveConnection* dc, int area, int DB, int start, int len, void* buffer);
   alias pdaveWriteBits = int function(daveConnection* dc, int area, int DB, int start, int len, void* buffer);

   alias pdaveReadSZL = int function(daveConnection* dc, int ID, int index, void* buf, int buflen);
   alias pdaveListBlocksOfType = int function(daveConnection* dc, ubyte type, daveBlockEntry* buf);
   alias pdaveListBlocks = int function(daveConnection* dc, daveBlockTypeEntry* buf);
   alias pinitUpload = int function(daveConnection* dc, char blockType, int blockNr, int* uploadID);
   alias pdoUpload = int function(daveConnection* dc, int* more, ubyte** buffer, int* len, int uploadID);
   alias pendUpload = int function(daveConnection* dc, int uploadID);
   alias pdaveGetProgramBlock = int function(daveConnection* dc, int blockType, int number, char* buffer, int* length);
   alias pdaveStop = int function(daveConnection* dc);
   alias pdaveStart = int function(daveConnection* dc);
   alias pdaveCopyRAMtoROM = int function(daveConnection* dc);
   alias pdaveForce200 = int function(daveConnection* dc, int area, int start, int val);
   alias pdavePrepareReadRequest = void function(daveConnection* dc, PDU* p);
   alias pdaveAddVarToReadRequest = void function(PDU* p, int area, int DBnum, int start, int bytes);
   alias pdaveExecReadRequest = int function(daveConnection* dc, PDU* p, daveResultSet* rl);
   alias pdaveUseResult = int function(daveConnection* dc, daveResultSet* rl, int n);
   alias pdaveFreeResults = void function(daveResultSet* rl);
   alias pdaveAddBitVarToReadRequest = void function(PDU* p, int area, int DBnum, int start, int byteCount);
   alias pdavePrepareWriteRequest = void function(daveConnection* dc, PDU* p);
   alias pdaveAddVarToWriteRequest = void function(PDU* p, int area, int DBnum, int start, int bytes, void* buffer);
   alias pdaveAddBitVarToWriteRequest = void function(PDU* p, int area, int DBnum, int start, int byteCount, void* buffer);
   alias pdaveExecWriteRequest = int function(daveConnection* dc, PDU* p, daveResultSet* rl);
   alias pdaveInitAdapter = int function(daveInterface* di);
   alias pdaveConnectPLC = int function(daveConnection* dc);
   alias pdaveDisconnectPLC = int function(daveConnection* dc);
   alias pdaveDisconnectAdapter = int function(daveInterface* di);
   alias pdaveListReachablePartners = int function(daveInterface* di, char* buf);
   alias pdaveSetTimeout = void function(daveInterface* di, int tmo);
   alias pdaveGetTimeout = int function(daveInterface* di);
   alias pdaveGetName = char* function(daveInterface* di);
   alias pdaveGetMPIAdr = int function(daveConnection* dc);
   alias pdaveGetAnswLen = int function(daveConnection* dc);
   alias pdaveGetMaxPDULen = int function(daveConnection* dc);

   alias pdaveFree = void function(void* dc);

   alias pdaveGetErrorOfResult = int function(daveResultSet*, int number);
   alias pdaveForceDisconnectIBH = int function(daveInterface* di, int src, int dest, int mpi);
   alias pdaveResetIBH = int function(daveInterface* di);

   alias pdaveSetPLCTime = int function(daveConnection* dc, ubyte* ts);
   alias pdaveSetPLCTimeToSystime = int function(daveConnection* dc);

   alias pdaveStrerror = char* function(int code);
   alias pdaveStringCopy = void function(char* intString, char* extString);
   alias pdaveSetDebug = void function(int nDebug);
   alias pdaveGetDebug = int function();

   /**
    * Create a daveInterface structure.
    *
    * Params:
    *  nfd = A _daveOSserialType
    *  nname = Interface name
    *  localMPI = The address used by your computer/adapter (only meaningful for MPI and PPI)
    *  protocol = A constant specifying the protocol to be used on this interface
    *  speed = A constant specifying the speed to be used on this interface. (only meaningful for MPI and Profibus)
    */
   alias pdaveNewInterface = daveInterface* function(daveOSserialType nfd, const(char)* nname, int localMPI, int protocol, int speed);

   /**
    * Setup a new connection structure using an initialized
    * daveInterface and PLC's MPI address.
    *
    * Params:
    *  di = A daveInterface
    *  MPI = The address of the PLC (only meaningful for MPI and PPI).
    *  rack = The rack the CPU is mounted in (normally 0, only meaningful for ISO over TCP).
    *  slot = The slot number the CPU is mounted in (normally 2, only meaningful for ISO over TCP)
    */
   alias pdaveNewConnection = daveConnection* function(daveInterface* di, int MPI, int rack, int slot);
   alias pdaveGetResponse = int function(daveConnection* dc);
   alias pdaveSendMessage = int function(daveConnection* dc, PDU* p);
   alias pdaveDumpPDU = void function(PDU* p);
   alias pdaveDump = void function(char* name, ubyte* b, int len);
   alias pdaveBlockName = char* function(ubyte bn);
   alias pdaveAreaName = char* function(ubyte n);

   alias pdaveSwapIed_16 = short function(short ff);
   alias pdaveSwapIed_32 = int function(int ff);
   alias ptoPLCfloat = float function(float ff);
   alias pdaveToPLCfloat = int function(float ff);
}

__gshared {
   pdaveGetS8from daveGetS8from;
   pdaveGetU8from daveGetU8from;
   pdaveGetS16from daveGetS16from;
   pdaveGetU16from daveGetU16from;
   pdaveGetS32from daveGetS32from;
   pdaveGetU32from daveGetU32from;
   pdaveGetFloatfrom daveGetFloatfrom;
   pdavePut8 davePut8;
   pdavePut16 davePut16;
   pdavePut32 davePut32;
   pdavePutFloat davePutFloat;
   pdavePut8At davePut8At;
   pdavePut16At davePut16At;
   pdavePut32At davePut32At;
   pdavePutFloatAt davePutFloatAt;
   pdaveToBCD daveToBCD;
   pdaveFromBCD daveFromBCD;
   //                plc
   //                ---------
   pdaveGetS8 daveGetS8;
   pdaveGetU8 daveGetU8;
   pdaveGetS16 daveGetS16;
   pdaveGetU16 daveGetU16;
   pdaveGetS32 daveGetS32;
   pdaveGetU32 daveGetU32;
   pdaveGetFloat daveGetFloat;
   pdaveGetS8At daveGetS8At;
   pdaveGetU8At daveGetU8At;
   pdaveGetS16At daveGetS16At;
   pdaveGetU16At daveGetU16At;
   pdaveGetS32At daveGetS32At;
   pdaveGetU32At daveGetU32At;
   pdaveGetFloatAt daveGetFloatAt;
   pdaveSetBit daveSetBit;
   pdaveClrBit daveClrBit;
/**
    * Read len bytes from the PLC.
    *
    * Params:
    *  dc = A daveConnection
    *  area = Denotes whether the data comes from FLAGS, DATA BLOCKS,
    *  DB = The number of the data block to be used. Set it to zero
    *  start = First byte.
    *  len = Number of bytes to read
    *  buffer = Pointer to a memory block provided by the calling program.
    *           If the pointer is not NULL, the result data will be copied thereto.
    *           Hence it must be big enough to take up the result.
    *
    */

   pdaveReadBytes daveReadBytes;
   pdaveWriteBytes daveWriteBytes;
   pdaveReadPLCTime daveReadPLCTime;
   pdaveGetSeconds daveGetSeconds;
   pdaveGetSecondsAt daveGetSecondsAt;
   pdaveGetCounterValue daveGetCounterValue;
   pdaveGetCounterValueAt daveGetCounterValueAt;
   pdaveConstructUpload daveConstructUpload;
   pdaveConstructDoUpload daveConstructDoUpload;
   pdaveConstructEndUpload daveConstructEndUpload;
   pdaveGetOrderCode daveGetOrderCode;
   pdaveReadManyBytes daveReadManyBytes;
   pdaveWriteManyBytes daveWriteManyBytes;
   pdaveReadBits daveReadBits;
   pdaveWriteBits daveWriteBits;
   pdaveReadSZL daveReadSZL;
   pdaveListBlocksOfType daveListBlocksOfType;
   pdaveListBlocks daveListBlocks;
   pinitUpload initUpload;
   pdoUpload doUpload;
   pendUpload endUpload;
   pdaveGetProgramBlock daveGetProgramBlock;
   pdaveStop daveStop;
   pdaveStart daveStart;
   pdaveCopyRAMtoROM daveCopyRAMtoROM;
   pdaveForce200 daveForce200;
   pdavePrepareReadRequest davePrepareReadRequest;
   pdaveAddVarToReadRequest daveAddVarToReadRequest;
   pdaveExecReadRequest daveExecReadRequest;
   pdaveUseResult daveUseResult;
   pdaveFreeResults daveFreeResults;
   pdaveAddBitVarToReadRequest daveAddBitVarToReadRequest;
   pdavePrepareWriteRequest davePrepareWriteRequest;
   pdaveAddVarToWriteRequest daveAddVarToWriteRequest;
   pdaveAddBitVarToWriteRequest daveAddBitVarToWriteRequest;
   pdaveExecWriteRequest daveExecWriteRequest;
   pdaveInitAdapter daveInitAdapter;
   pdaveConnectPLC daveConnectPLC;
   pdaveDisconnectPLC daveDisconnectPLC;
   pdaveDisconnectAdapter daveDisconnectAdapter;
   pdaveListReachablePartners daveListReachablePartners;
   pdaveSetTimeout daveSetTimeout;
   pdaveGetTimeout daveGetTimeout;
   pdaveGetName daveGetName;
   pdaveGetMPIAdr daveGetMPIAdr;
   pdaveGetAnswLen daveGetAnswLen;
   pdaveGetMaxPDULen daveGetMaxPDULen;
   pdaveFree daveFree;
   pdaveGetErrorOfResult daveGetErrorOfResult;
   pdaveForceDisconnectIBH daveForceDisconnectIBH;
   pdaveResetIBH daveResetIBH;
   pdaveSetPLCTime daveSetPLCTime;
   pdaveSetPLCTimeToSystime daveSetPLCTimeToSystime;
   pdaveStrerror daveStrerror;
   pdaveStringCopy daveStringCopy;
   pdaveSetDebug daveSetDebug;
   pdaveGetDebug daveGetDebug;
   pdaveNewInterface daveNewInterface;
   pdaveNewConnection daveNewConnection;
   pdaveGetResponse daveGetResponse;
   pdaveSendMessage daveSendMessage;
   pdaveDumpPDU daveDumpPDU;
   pdaveDump daveDump;
   pdaveBlockName daveBlockName;
   pdaveAreaName daveAreaName;
   pdaveSwapIed_16 daveSwapIed_16;
   pdaveSwapIed_32 daveSwapIed_32;
   ptoPLCfloat toPLCfloat;
   pdaveToPLCfloat daveToPLCfloat;
}

private {
   SharedLib lib;
   NodaveSupport loadedVersion;
}

@nogc nothrow:

void unloadNodave() {
   if (lib != invalidHandle) {
      lib.unload();
   }
}

NodaveSupport loadedNodaveVersion() @safe {
   return loadedVersion;
}

bool isNodaveLoaded() @safe {
   return lib != invalidHandle;
}

NodaveSupport loadNodave() {
   version (Windows) {
      const(char)[][1] libNames = ["nodave.dll"];
   } else version (OSX) {
      const(char)[][1] libNames = ["libnodave.dylib",];
   } else version (Posix) {
      pragma(msg, "lin");
      const(char)[][3] libNames = ["libnodave.so", "/usr/lib/libnodave.so", "/usr/local/lib/libnodave.so",];
   } else {
      static assert(0, "bindbc-nodave is not yet supported on this platform.");
   }

   NodaveSupport ret;
   foreach (name; libNames) {
      ret = loadNodave(name.ptr);
      if (ret != NodaveSupport.noLibrary) {
         break;
      }
   }
   return ret;
}

NodaveSupport loadNodave(const(char)* libName) {
   lib = load(libName);
   if (lib == invalidHandle) {
      return NodaveSupport.noLibrary;
   }

   auto errCount = errorCount();

   loadedVersion = NodaveSupport.badLibrary;

   lib.bindSymbol(cast(void**)&daveGetS8from, "daveGetS8from");
   lib.bindSymbol(cast(void**)&daveGetU8from, "daveGetU8from");
   lib.bindSymbol(cast(void**)&daveGetS16from, "daveGetS16from");
   lib.bindSymbol(cast(void**)&daveGetU16from, "daveGetU16from");
   lib.bindSymbol(cast(void**)&daveGetS32from, "daveGetS32from");
   lib.bindSymbol(cast(void**)&daveGetU32from, "daveGetU32from");
   lib.bindSymbol(cast(void**)&daveGetFloatfrom, "daveGetFloatfrom");
   lib.bindSymbol(cast(void**)&davePut8, "davePut8");
   lib.bindSymbol(cast(void**)&davePut16, "davePut16");
   lib.bindSymbol(cast(void**)&davePut32, "davePut32");
   lib.bindSymbol(cast(void**)&davePutFloat, "davePutFloat");
   lib.bindSymbol(cast(void**)&davePut8At, "davePut8At");
   lib.bindSymbol(cast(void**)&davePut16At, "davePut16At");
   lib.bindSymbol(cast(void**)&davePut32At, "davePut32At");
   lib.bindSymbol(cast(void**)&davePutFloatAt, "davePutFloatAt");
   lib.bindSymbol(cast(void**)&daveToBCD, "daveToBCD");
   lib.bindSymbol(cast(void**)&daveFromBCD, "daveFromBCD");
   lib.bindSymbol(cast(void**)&daveGetS8, "daveGetS8");
   lib.bindSymbol(cast(void**)&daveGetU8, "daveGetU8");
   lib.bindSymbol(cast(void**)&daveGetS16, "daveGetS16");
   lib.bindSymbol(cast(void**)&daveGetU16, "daveGetU16");
   lib.bindSymbol(cast(void**)&daveGetS32, "daveGetS32");
   lib.bindSymbol(cast(void**)&daveGetU32, "daveGetU32");
   lib.bindSymbol(cast(void**)&daveGetFloat, "daveGetFloat");
   lib.bindSymbol(cast(void**)&daveGetS8At, "daveGetS8At");
   lib.bindSymbol(cast(void**)&daveGetU8At, "daveGetU8At");
   lib.bindSymbol(cast(void**)&daveGetS16At, "daveGetS16At");
   lib.bindSymbol(cast(void**)&daveGetU16At, "daveGetU16At");
   lib.bindSymbol(cast(void**)&daveGetS32At, "daveGetS32At");
   lib.bindSymbol(cast(void**)&daveGetU32At, "daveGetU32At");
   lib.bindSymbol(cast(void**)&daveGetFloatAt, "daveGetFloatAt");
   lib.bindSymbol(cast(void**)&daveSetBit, "daveSetBit");
   lib.bindSymbol(cast(void**)&daveClrBit, "daveClrBit");
   lib.bindSymbol(cast(void**)&daveReadBytes, "daveReadBytes");
   lib.bindSymbol(cast(void**)&daveWriteBytes, "daveWriteBytes");
   lib.bindSymbol(cast(void**)&daveReadPLCTime, "daveReadPLCTime");
   lib.bindSymbol(cast(void**)&daveGetSeconds, "daveGetSeconds");
   lib.bindSymbol(cast(void**)&daveGetSecondsAt, "daveGetSecondsAt");
   lib.bindSymbol(cast(void**)&daveGetCounterValue, "daveGetCounterValue");
   lib.bindSymbol(cast(void**)&daveGetCounterValueAt, "daveGetCounterValueAt");
   lib.bindSymbol(cast(void**)&daveConstructUpload, "_daveConstructUpload");
   lib.bindSymbol(cast(void**)&daveConstructDoUpload, "_daveConstructDoUpload");
   lib.bindSymbol(cast(void**)&daveConstructEndUpload, "_daveConstructEndUpload");
   lib.bindSymbol(cast(void**)&daveGetOrderCode, "daveGetOrderCode");
   lib.bindSymbol(cast(void**)&daveReadManyBytes, "daveReadManyBytes");
   lib.bindSymbol(cast(void**)&daveWriteManyBytes, "daveWriteManyBytes");
   lib.bindSymbol(cast(void**)&daveReadBits, "daveReadBits");
   lib.bindSymbol(cast(void**)&daveWriteBits, "daveWriteBits");
   lib.bindSymbol(cast(void**)&daveReadSZL, "daveReadSZL");
   lib.bindSymbol(cast(void**)&daveListBlocksOfType, "daveListBlocksOfType");
   lib.bindSymbol(cast(void**)&daveListBlocks, "daveListBlocks");
   lib.bindSymbol(cast(void**)&initUpload, "initUpload");
   lib.bindSymbol(cast(void**)&doUpload, "doUpload");
   lib.bindSymbol(cast(void**)&endUpload, "endUpload");
   lib.bindSymbol(cast(void**)&daveGetProgramBlock, "daveGetProgramBlock");
   lib.bindSymbol(cast(void**)&daveStop, "daveStop");
   lib.bindSymbol(cast(void**)&daveStart, "daveStart");
   lib.bindSymbol(cast(void**)&daveCopyRAMtoROM, "daveCopyRAMtoROM");
   lib.bindSymbol(cast(void**)&daveForce200, "daveForce200");
   lib.bindSymbol(cast(void**)&davePrepareReadRequest, "davePrepareReadRequest");
   lib.bindSymbol(cast(void**)&daveAddVarToReadRequest, "daveAddVarToReadRequest");
   lib.bindSymbol(cast(void**)&daveExecReadRequest, "daveExecReadRequest");
   lib.bindSymbol(cast(void**)&daveUseResult, "daveUseResult");
   lib.bindSymbol(cast(void**)&daveFreeResults, "daveFreeResults");
   lib.bindSymbol(cast(void**)&daveAddBitVarToReadRequest, "daveAddBitVarToReadRequest");
   lib.bindSymbol(cast(void**)&davePrepareWriteRequest, "davePrepareWriteRequest");
   lib.bindSymbol(cast(void**)&daveAddVarToWriteRequest, "daveAddVarToWriteRequest");
   lib.bindSymbol(cast(void**)&daveAddBitVarToWriteRequest, "daveAddBitVarToWriteRequest");
   lib.bindSymbol(cast(void**)&daveExecWriteRequest, "daveExecWriteRequest");
   lib.bindSymbol(cast(void**)&daveInitAdapter, "daveInitAdapter");
   lib.bindSymbol(cast(void**)&daveConnectPLC, "daveConnectPLC");
   lib.bindSymbol(cast(void**)&daveDisconnectPLC, "daveDisconnectPLC");
   lib.bindSymbol(cast(void**)&daveDisconnectAdapter, "daveDisconnectAdapter");
   lib.bindSymbol(cast(void**)&daveListReachablePartners, "daveListReachablePartners");
   lib.bindSymbol(cast(void**)&daveSetTimeout, "daveSetTimeout");
   lib.bindSymbol(cast(void**)&daveGetTimeout, "daveGetTimeout");
   lib.bindSymbol(cast(void**)&daveGetName, "daveGetName");
   lib.bindSymbol(cast(void**)&daveGetMPIAdr, "daveGetMPIAdr");
   lib.bindSymbol(cast(void**)&daveGetAnswLen, "daveGetAnswLen");
   lib.bindSymbol(cast(void**)&daveGetMaxPDULen, "daveGetMaxPDULen");
   lib.bindSymbol(cast(void**)&daveFree, "daveFree");
   lib.bindSymbol(cast(void**)&daveGetErrorOfResult, "daveGetErrorOfResult");
   lib.bindSymbol(cast(void**)&daveForceDisconnectIBH, "daveForceDisconnectIBH");
   lib.bindSymbol(cast(void**)&daveResetIBH, "daveResetIBH");
   lib.bindSymbol(cast(void**)&daveSetPLCTime, "daveSetPLCTime");
   lib.bindSymbol(cast(void**)&daveSetPLCTimeToSystime, "daveSetPLCTimeToSystime");
   lib.bindSymbol(cast(void**)&daveStrerror, "daveStrerror");
   lib.bindSymbol(cast(void**)&daveStringCopy, "daveStringCopy");
   lib.bindSymbol(cast(void**)&daveSetDebug, "daveSetDebug");
   lib.bindSymbol(cast(void**)&daveGetDebug, "daveGetDebug");
   lib.bindSymbol(cast(void**)&daveNewInterface, "daveNewInterface");
   lib.bindSymbol(cast(void**)&daveNewConnection, "daveNewConnection");
   lib.bindSymbol(cast(void**)&daveGetResponse, "daveGetResponse");
   lib.bindSymbol(cast(void**)&daveSendMessage, "daveSendMessage");
   lib.bindSymbol(cast(void**)&daveDumpPDU, "_daveDumpPDU");
   lib.bindSymbol(cast(void**)&daveDump, "_daveDump");
   lib.bindSymbol(cast(void**)&daveBlockName, "daveBlockName");
   lib.bindSymbol(cast(void**)&daveAreaName, "daveAreaName");
   lib.bindSymbol(cast(void**)&daveSwapIed_16, "daveSwapIed_16");
   lib.bindSymbol(cast(void**)&daveSwapIed_32, "daveSwapIed_32");
   lib.bindSymbol(cast(void**)&toPLCfloat, "toPLCfloat");
   lib.bindSymbol(cast(void**)&daveToPLCfloat, "daveToPLCfloat");

   if (errorCount() != errCount) {
      return NodaveSupport.badLibrary;
   } else {
      loadedVersion = NodaveSupport.nodave851;
   }


   // here other versions

    return loadedVersion;
}
