/**
 * Implements an output range that appends data to a buffer.
 */
module bindbc.nodave.bufferappender;

import std.array : Appender, appender;

/**
 * This is a convenience alias for Appender.
 */
alias DaveBuffer = Appender!(ubyte[]);

/**
 * Appends byte to the managed array.
 *
 * Params:
 *  app = Appender
 *  value = Byte to append
 */
DaveBuffer put8(DaveBuffer app, in ubyte value) {
   app.put(value);
   return app;
}

///
unittest {
   auto app = appender!(ubyte[]);
   app.put8(10);
   app.put8(11);
   app.put8(12);
   app.put8(13);
   assert(app.data.length == 4);
   assert(app.data == [10, 11, 12, 13]);
}
///
unittest {
   auto app = appender!(ubyte[]);
   // dfmt off
   app.put8(10)
      .put8(11)
      .put8(12)
      .put8(13);
   // dfmt on
   assert(app.data.length == 4);
   assert(app.data == [10, 11, 12, 13]);
}

/**
 * Inserts a signed short (16 bits) in to [DaveBuffer]
 */
alias put16 = putW!short;
/**
 * Inserts a unsigned short (16 bits) in to [DaveBuffer]
 */
alias putu16 = putW!ushort;
/**
 * Converts word (16bit) `value` into bytes and appends it to the managed array.
 */
DaveBuffer putW(T)(DaveBuffer app, in T value) if (is(T == short) || is(T == ushort)) {
   import std.bitmanip : nativeToBigEndian;

   ubyte[2] buffer = nativeToBigEndian!T(value);
   app.put(buffer.dup);
   return app;
}

///
unittest {
   auto app = appender!(ubyte[]);
   app.put16(0x2a);
   app.put16(0x7ac);
   app.put16(0x7e2);
   app.put16(0x7b3);
   assert(app.data.length == 8);
   assert(app.data == [0x00, 0x2a, 0x07, 0xac, 0x07, 0xe2, 0x07, 0xb3]);

   auto uapp = appender!(ubyte[]);
   uapp.putu16(0x2a);
   uapp.putu16(0x7ac);
   uapp.putu16(0x7e2);
   uapp.putu16(0x7b3);
   assert(uapp.data.length == 8);
   assert(uapp.data == [0x00, 0x2a, 0x07, 0xac, 0x07, 0xe2, 0x07, 0xb3]);

}
///
unittest {
   auto app = appender!(ubyte[]);
   app.put16(-0x7ac);
   app.putu16(0x7ac);
   assert(app.data.length == 4);
   assert(app.data == [0xf8, 0x54, 0x07, 0xac]);
}

unittest {
   import core.bitop: bts;
   auto app = appender!(ubyte[]);
   size_t r = 0;
   size_t c = 0;
   bts(&r, 0);
   bts(&r, 1);
   bts(&r, 2);
   bts(&c, 0);

   app.put8(cast(ubyte)r);
   app.put8(cast(ubyte)c);
   assert(app.data == [0x07, 0x01]);
}
unittest {
   import core.bitop: bts;
   auto app = appender!(ubyte[]);
   size_t r = 0;
   bts(&r, 8);
   bts(&r, 9);
   bts(&r, 10);
   bts(&r, 0);

   app.put16(cast(short)r);
   assert(app.data == [0x07, 0x01]);
}

/**
 * Inserts a unsigned int (32 bits) in to [DaveBuffer]
 */
alias put32 = putDW!int;
/**
 * Inserts a signed int (32 bits) in to [DaveBuffer]
 */
alias putu32 = putDW!uint;

/**
 * Converts double word (32 bits) `value` into bytes and appends it to the managed array.
 */
DaveBuffer putDW(T)(DaveBuffer app, in T value)  if (is(T == int) || is(T == uint)) {
   import std.bitmanip : nativeToBigEndian;

   ubyte[4] buffer = nativeToBigEndian!T(value);
   app.put(buffer.dup);
   return app;
}

///
unittest {
   auto app = appender!(ubyte[]);
   app.put32(19641971);
   app.put32(19712004);
   app.put32(20072004);
   app.put32(1);
   app.put32(-1964);
   assert(app.data.length == 20);

   // dfmt off
   assert(app.data == [
         0x01, 0x2b, 0xb6, 0x73,
         0x01, 0x2c, 0xc8, 0x04,
         0x01, 0x32, 0x46, 0x44,
         0x00, 0x0, 0x0, 0x1,
         0xff, 0xff, 0xf8, 0x54,
   ]);
   // dfmt on
}

/**
 * Converts float `value` into bytes and appends it to the managed array.
 */
DaveBuffer putFloat(DaveBuffer app, in float value) {
   import std.bitmanip : nativeToBigEndian;

   ubyte[4] buffer = nativeToBigEndian(value);
   app.put(buffer.dup);
   return app;
}

unittest {
   auto app = appender!(ubyte[]);
   app.putFloat(42.);
   app.putFloat(1964.);
   app.putFloat(19.64);
   app.putFloat(3.1415);

   assert(app.data.length == 16);
   // dfmt off
   assert(app.data == [
         0x42, 0x28, 0x0, 0x0, //42
         0x44, 0xf5, 0x80, 0x0, //1964
         0x41, 0x9d, 0x1e, 0xb8, //19.64
         0x40, 0x49, 0x0e, 0x56, //3.1415
         ]);
   // dfmt on
}
