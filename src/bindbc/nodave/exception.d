module bindbc.nodave.exception;

import bindbc.nodave;

/**
 * Generic NoDave exception
 */
class NodaveException : Exception {
   this(int errNo) {
      import std.conv : to;

      string message = daveStrerror(errNo).to!string;
      //string message = (errNo).to!string;
      _errNo = errNo;

      this(message);
   }

   this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
      super(message, file, line, next);
   }

   private int _errNo;
   int errNo() {
      return _errNo;
   }
}
/**
 * NoDave DB read exception
 */
class NodaveReadException : NodaveException {
   this(int errNo, in int datablock, in int start, in int length) {
      _db = datablock;
      _start = start;
      _len = length;
      super(errNo);
   }

   private int _db;
   int dataBlock() {
      return _db;
   }

   private int _start;
   int startAddr() {
      return _start;
   }

   private int _len;
   int length() {
      return _len;
   }
}
/+
unittest {
   auto ex = new NodaveException(6);
   assert(ex.errNo == 6);
   assert(ex.msg == "the CPU does not support reading a bit block of length<>1");
}
+/
