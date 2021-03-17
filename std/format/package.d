// Written in the D programming language.

/**
   This module implements the formatting functionality for strings and
   I/O. It's comparable to C99's `vsprintf()` and uses a similar
   _format encoding scheme.

   For an introductory look at $(B std._format)'s capabilities and how to use
   this module see the dedicated
   $(LINK2 http://wiki.dlang.org/Defining_custom_print_format_specifiers, DWiki article).

   This module centers around two functions:

$(BOOKTABLE ,
$(TR $(TH Function Name) $(TH Description)
)
    $(TR $(TD $(REF_ALTTEXT $(D formattedRead), formattedRead, std, format, read))
        $(TD Reads values according to the format string from an InputRange.
    ))
    $(TR $(TD $(REF_ALTTEXT $(D formattedWrite), formattedWrite, std, format, write))
        $(TD Formats its arguments according to the format string and puts them
        to an OutputRange.
    ))
)

   Please see the documentation of function
   $(REF_ALTTEXT $(D formattedWrite), formattedWrite, std, format, write) for a
   description of the format string.

   Two functions have been added for convenience:

$(BOOKTABLE ,
$(TR $(TH Function Name) $(TH Description)
)
    $(TR $(TD $(LREF format))
        $(TD Returns a GC-allocated string with the formatting result.
    ))
    $(TR $(TD $(LREF sformat))
        $(TD Puts the formatting result into a preallocated array.
    ))
)

   These two functions are publicly imported by $(MREF std, string)
   to be easily available.

   The functions $(REF_ALTTEXT $(D formatValue), formatValue, std, format, write) and
   $(REF_ALTTEXT $(D unformatValue), unformatValue, std, format, read) are
   used for the plumbing.
   Copyright: Copyright The D Language Foundation 2000-2013.

   Macros:
   SUBREF = $(REF_ALTTEXT $2, $2, std, format, $1)$(NBSP)

   License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

   Authors: $(HTTP walterbright.com, Walter Bright), $(HTTP erdani.com,
   Andrei Alexandrescu), and Kenji Hara

   Source: $(PHOBOSSRC std/format.d)
 */
module std.format;

public import std.format.read;
public import std.format.spec;
public import std.format.write;

import std.exception : enforce;
import std.range.primitives : isInputRange;
import std.traits : CharTypeOf, isSomeChar, isSomeString, StringTypeOf;
import std.format.internal.write : hasToString;

/**
Signals a mismatch between a format and its corresponding argument.
 */
class FormatException : Exception
{
    @safe @nogc pure nothrow
    this()
    {
        super("format error");
    }

    @safe @nogc pure nothrow
    this(string msg, string fn = __FILE__, size_t ln = __LINE__, Throwable next = null)
    {
        super(msg, fn, ln, next);
    }
}

///
@safe unittest
{
    import std.exception : assertThrown;

    assertThrown!FormatException(format("%d", "foo"));
}

package alias enforceFmt = enforce!FormatException;

// undocumented because of deprecation
// string elements are formatted like UTF-8 string literals.
void formatElement(Writer, T, Char)(auto ref Writer w, T val, scope const ref FormatSpec!Char f)
if (is(StringTypeOf!T) && !hasToString!(T, Char) && !is(T == enum))
{
    import std.array : appender;
    import std.format.internal.write : formatChar;
    import std.range.primitives : put;
    import std.utf : decode, UTFException;

    StringTypeOf!T str = val;   // https://issues.dlang.org/show_bug.cgi?id=8015

    if (f.spec == 's')
    {
        try
        {
            // ignore other specifications and quote
            for (size_t i = 0; i < str.length; )
            {
                auto c = decode(str, i);
                // \uFFFE and \uFFFF are considered valid by isValidDchar,
                // so need checking for interchange.
                if (c == 0xFFFE || c == 0xFFFF)
                    goto LinvalidSeq;
            }
            put(w, '\"');
            for (size_t i = 0; i < str.length; )
            {
                auto c = decode(str, i);
                formatChar(w, c, '"');
            }
            put(w, '\"');
            return;
        }
        catch (UTFException)
        {
        }

        // If val contains invalid UTF sequence, formatted like HexString literal
    LinvalidSeq:
        static if (is(typeof(str[0]) : const(char)))
        {
            enum postfix = 'c';
            alias IntArr = const(ubyte)[];
        }
        else static if (is(typeof(str[0]) : const(wchar)))
        {
            enum postfix = 'w';
            alias IntArr = const(ushort)[];
        }
        else static if (is(typeof(str[0]) : const(dchar)))
        {
            enum postfix = 'd';
            alias IntArr = const(uint)[];
        }
        formattedWrite(w, "x\"%(%02X %)\"%s", cast(IntArr) str, postfix);
    }
    else
        formatValue(w, str, f);
}

@safe pure unittest
{
    import std.array : appender;

    auto w = appender!string();
    auto spec = singleSpec("%s");
    formatElement(w, "Hello World", spec);

    assert(w.data == "\"Hello World\"");
}

// https://issues.dlang.org/show_bug.cgi?id=8015
@safe unittest
{
    import std.typecons : Tuple;

    struct MyStruct
    {
        string str;
        @property string toStr()
        {
            return str;
        }
        alias toStr this;
    }

    Tuple!(MyStruct) t;
}

// undocumented because of deprecation
// Character elements are formatted like UTF-8 character literals.
void formatElement(Writer, T, Char)(auto ref Writer w, T val, scope const ref FormatSpec!Char f)
if (is(CharTypeOf!T) && !is(T == enum))
{
    import std.range.primitives : put;
    import std.format.internal.write : formatChar;

    if (f.spec == 's')
    {
        put(w, '\'');
        formatChar(w, val, '\'');
        put(w, '\'');
    }
    else
        formatValue(w, val, f);
}

///
@safe unittest
{
    import std.array : appender;

    auto w = appender!string();
    auto spec = singleSpec("%s");
    formatElement(w, "H", spec);

    assert(w.data == "\"H\"", w.data);
}

// undocumented
// Maybe T is noncopyable struct, so receive it by 'auto ref'.
void formatElement(Writer, T, Char)(auto ref Writer w, auto ref T val, scope const ref FormatSpec!Char f)
if ((!is(StringTypeOf!T) || hasToString!(T, Char)) && !is(CharTypeOf!T) || is(T == enum))
{
    formatValue(w, val, f);
}

// Like NullSink, but toString() isn't even called at all. Used to test the format string.
package struct NoOpSink
{
    void put(E)(scope const E) pure @safe @nogc nothrow {}
}

/* ======================== Unit Tests ====================================== */

version (StdUnittest)
package void formatTest(T)(T val, string expected, size_t ln = __LINE__, string fn = __FILE__)
{
    import core.exception : AssertError;
    import std.array : appender;
    import std.conv : text;

    FormatSpec!char f;
    auto w = appender!string();
    formatValue(w, val, f);
    enforce!AssertError(w.data == expected,
        text("expected = `", expected, "`, result = `", w.data, "`"), fn, ln);
}

version (StdUnittest)
package void formatTest(T)(string fmt, T val, string expected, size_t ln = __LINE__, string fn = __FILE__) @safe
{
    import core.exception : AssertError;
    import std.array : appender;
    import std.conv : text;

    auto w = appender!string();
    formattedWrite(w, fmt, val);
    enforce!AssertError(w.data == expected,
        text("expected = `", expected, "`, result = `", w.data, "`"), fn, ln);
}

version (StdUnittest)
package void formatTest(T)(T val, string[] expected, size_t ln = __LINE__, string fn = __FILE__)
{
    import core.exception : AssertError;
    import std.array : appender;
    import std.conv : text;

    FormatSpec!char f;
    auto w = appender!string();
    formatValue(w, val, f);
    foreach (cur; expected)
    {
        if (w.data == cur) return;
    }
    enforce!AssertError(false,
        text("expected one of `", expected, "`, result = `", w.data, "`"), fn, ln);
}

version (StdUnittest)
package void formatTest(T)(string fmt, T val, string[] expected, size_t ln = __LINE__, string fn = __FILE__) @safe
{
    import core.exception : AssertError;
    import std.array : appender;
    import std.conv : text;

    auto w = appender!string();
    formattedWrite(w, fmt, val);
    foreach (cur; expected)
    {
        if (w.data == cur) return;
    }
    enforce!AssertError(false,
        text("expected one of `", expected, "`, result = `", w.data, "`"), fn, ln);
}

@safe pure unittest
{
    import std.array : appender;

    auto stream = appender!string();
    formattedWrite(stream, "%s", 1.1);
    assert(stream.data == "1.1", stream.data);
}

@safe pure unittest
{
    import std.algorithm.iteration : map;
    import std.array : appender;

    auto stream = appender!string();
    formattedWrite(stream, "%s", map!"a*a"([2, 3, 5]));
    assert(stream.data == "[4, 9, 25]", stream.data);

    // Test shared data.
    stream = appender!string();
    shared int s = 6;
    formattedWrite(stream, "%s", s);
    assert(stream.data == "6");
}

@safe pure unittest
{
    import std.array : appender;

    auto stream = appender!string();
    formattedWrite(stream, "%u", 42);
    assert(stream.data == "42", stream.data);
}

@safe pure unittest
{
    // testing raw writes
    import std.array : appender;

    auto w = appender!(char[])();
    uint a = 0x02030405;
    formattedWrite(w, "%+r", a);
    assert(w.data.length == 4 && w.data[0] == 2 && w.data[1] == 3
        && w.data[2] == 4 && w.data[3] == 5);

    w.clear();
    formattedWrite(w, "%-r", a);
    assert(w.data.length == 4 && w.data[0] == 5 && w.data[1] == 4
        && w.data[2] == 3 && w.data[3] == 2);
}

@safe pure unittest
{
    // testing positional parameters
    import std.array : appender;
    import std.exception : collectExceptionMsg;

    auto w = appender!(char[])();
    formattedWrite(w,
            "Numbers %2$s and %1$s are reversed and %1$s%2$s repeated",
            42, 0);
    assert(w.data == "Numbers 0 and 42 are reversed and 420 repeated",
            w.data);
    assert(collectExceptionMsg!FormatException(formattedWrite(w, "%1$s, %3$s", 1, 2))
        == "Positional specifier %3$s index exceeds 2");

    w.clear();
    formattedWrite(w, "asd%s", 23);
    assert(w.data == "asd23", w.data);
    w.clear();
    formattedWrite(w, "%s%s", 23, 45);
    assert(w.data == "2345", w.data);
}

@safe unittest
{
    import std.array : appender;
    import std.conv : text, octal;

    auto stream = appender!(char[])();

    formattedWrite(stream, "hello world! %s %s ", true, 57, 1_000_000_000, 'x', " foo");
    assert(stream.data == "hello world! true 57 ", stream.data);
    stream.clear();

    formattedWrite(stream, "%g %A %s", 1.67, -1.28, float.nan);
    assert(stream.data == "1.67 -0X1.47AE147AE147BP+0 nan", stream.data);
    stream.clear();

    formattedWrite(stream, "%x %X", 0x1234AF, 0xAFAFAFAF);
    assert(stream.data == "1234af AFAFAFAF");
    stream.clear();

    formattedWrite(stream, "%b %o", 0x1234AF, 0xAFAFAFAF);
    assert(stream.data == "100100011010010101111 25753727657");
    stream.clear();

    formattedWrite(stream, "%d %s", 0x1234AF, 0xAFAFAFAF);
    assert(stream.data == "1193135 2947526575");
    stream.clear();

    formattedWrite(stream, "%a %A", 1.32, 6.78f);
    assert(stream.data == "0x1.51eb851eb851fp+0 0X1.B1EB86P+2");
    stream.clear();

    formattedWrite(stream, "%#06.*f", 2, 12.345);
    assert(stream.data == "012.35");
    stream.clear();

    formattedWrite(stream, "%#0*.*f", 6, 2, 12.345);
    assert(stream.data == "012.35");
    stream.clear();

    const real constreal = 1;
    formattedWrite(stream, "%g",constreal);
    assert(stream.data == "1");
    stream.clear();

    formattedWrite(stream, "%7.4g:", 12.678);
    assert(stream.data == "  12.68:");
    stream.clear();

    formattedWrite(stream, "%7.4g:", 12.678L);
    assert(stream.data == "  12.68:");
    stream.clear();

    formattedWrite(stream, "%04f|%05d|%#05x|%#5x", -4.0, -10, 1, 1);
    assert(stream.data == "-4.000000|-0010|0x001|  0x1", stream.data);
    stream.clear();

    int i;
    string s;

    i = -10;
    formattedWrite(stream, "%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(stream.data == "-10|-10|-10|-10|-10.0000");
    stream.clear();

    i = -5;
    formattedWrite(stream, "%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(stream.data == "-5| -5|-05|-5|-5.0000");
    stream.clear();

    i = 0;
    formattedWrite(stream, "%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(stream.data == "0|  0|000|0|0.0000");
    stream.clear();

    i = 5;
    formattedWrite(stream, "%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(stream.data == "5|  5|005|5|5.0000");
    stream.clear();

    i = 10;
    formattedWrite(stream, "%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(stream.data == "10| 10|010|10|10.0000");
    stream.clear();

    formattedWrite(stream, "%.0d", 0);
    assert(stream.data == "");
    stream.clear();

    formattedWrite(stream, "%.g", .34);
    assert(stream.data == "0.3");
    stream.clear();

    stream.clear();
    formattedWrite(stream, "%.0g", .34);
    assert(stream.data == "0.3");

    stream.clear();
    formattedWrite(stream, "%.2g", .34);
    assert(stream.data == "0.34");

    stream.clear();
    formattedWrite(stream, "%0.0008f", 1e-08);
    assert(stream.data == "0.00000001");

    stream.clear();
    formattedWrite(stream, "%0.0008f", 1e-05);
    assert(stream.data == "0.00001000");

    s = "helloworld";
    string r;
    stream.clear();
    formattedWrite(stream, "%.2s", s[0 .. 5]);
    assert(stream.data == "he");
    stream.clear();
    formattedWrite(stream, "%.20s", s[0 .. 5]);
    assert(stream.data == "hello");
    stream.clear();
    formattedWrite(stream, "%8s", s[0 .. 5]);
    assert(stream.data == "   hello");

    byte[] arrbyte = new byte[4];
    arrbyte[0] = 100;
    arrbyte[1] = -99;
    arrbyte[3] = 0;
    stream.clear();
    formattedWrite(stream, "%s", arrbyte);
    assert(stream.data == "[100, -99, 0, 0]", stream.data);

    ubyte[] arrubyte = new ubyte[4];
    arrubyte[0] = 100;
    arrubyte[1] = 200;
    arrubyte[3] = 0;
    stream.clear();
    formattedWrite(stream, "%s", arrubyte);
    assert(stream.data == "[100, 200, 0, 0]", stream.data);

    short[] arrshort = new short[4];
    arrshort[0] = 100;
    arrshort[1] = -999;
    arrshort[3] = 0;
    stream.clear();
    formattedWrite(stream, "%s", arrshort);
    assert(stream.data == "[100, -999, 0, 0]");
    stream.clear();
    formattedWrite(stream, "%s", arrshort);
    assert(stream.data == "[100, -999, 0, 0]");

    ushort[] arrushort = new ushort[4];
    arrushort[0] = 100;
    arrushort[1] = 20_000;
    arrushort[3] = 0;
    stream.clear();
    formattedWrite(stream, "%s", arrushort);
    assert(stream.data == "[100, 20000, 0, 0]");

    int[] arrint = new int[4];
    arrint[0] = 100;
    arrint[1] = -999;
    arrint[3] = 0;
    stream.clear();
    formattedWrite(stream, "%s", arrint);
    assert(stream.data == "[100, -999, 0, 0]");
    stream.clear();
    formattedWrite(stream, "%s", arrint);
    assert(stream.data == "[100, -999, 0, 0]");

    long[] arrlong = new long[4];
    arrlong[0] = 100;
    arrlong[1] = -999;
    arrlong[3] = 0;
    stream.clear();
    formattedWrite(stream, "%s", arrlong);
    assert(stream.data == "[100, -999, 0, 0]");
    stream.clear();
    formattedWrite(stream, "%s",arrlong);
    assert(stream.data == "[100, -999, 0, 0]");

    ulong[] arrulong = new ulong[4];
    arrulong[0] = 100;
    arrulong[1] = 999;
    arrulong[3] = 0;
    stream.clear();
    formattedWrite(stream, "%s", arrulong);
    assert(stream.data == "[100, 999, 0, 0]");

    string[] arr2 = new string[4];
    arr2[0] = "hello";
    arr2[1] = "world";
    arr2[3] = "foo";
    stream.clear();
    formattedWrite(stream, "%s", arr2);
    assert(stream.data == `["hello", "world", "", "foo"]`, stream.data);

    stream.clear();
    formattedWrite(stream, "%.8d", 7);
    assert(stream.data == "00000007");

    stream.clear();
    formattedWrite(stream, "%.8x", 10);
    assert(stream.data == "0000000a");

    stream.clear();
    formattedWrite(stream, "%-3d", 7);
    assert(stream.data == "7  ");

    stream.clear();
    formattedWrite(stream, "%*d", -3, 7);
    assert(stream.data == "7  ");

    stream.clear();
    formattedWrite(stream, "%.*d", -3, 7);
    assert(stream.data == "7");

    stream.clear();
    formattedWrite(stream, "%s", "abc"c);
    assert(stream.data == "abc");
    stream.clear();
    formattedWrite(stream, "%s", "def"w);
    assert(stream.data == "def", text(stream.data.length));
    stream.clear();
    formattedWrite(stream, "%s", "ghi"d);
    assert(stream.data == "ghi");

    @trusted void* deadBeef() { return cast(void*) 0xDEADBEEF; }
    stream.clear();
    formattedWrite(stream, "%s", deadBeef());
    assert(stream.data == "DEADBEEF", stream.data);

    stream.clear();
    formattedWrite(stream, "%#x", 0xabcd);
    assert(stream.data == "0xabcd");
    stream.clear();
    formattedWrite(stream, "%#X", 0xABCD);
    assert(stream.data == "0XABCD");

    stream.clear();
    formattedWrite(stream, "%#o", octal!12345);
    assert(stream.data == "012345");
    stream.clear();
    formattedWrite(stream, "%o", 9);
    assert(stream.data == "11");

    stream.clear();
    formattedWrite(stream, "%+d", 123);
    assert(stream.data == "+123");
    stream.clear();
    formattedWrite(stream, "%+d", -123);
    assert(stream.data == "-123");
    stream.clear();
    formattedWrite(stream, "% d", 123);
    assert(stream.data == " 123");
    stream.clear();
    formattedWrite(stream, "% d", -123);
    assert(stream.data == "-123");

    stream.clear();
    formattedWrite(stream, "%%");
    assert(stream.data == "%");

    stream.clear();
    formattedWrite(stream, "%d", true);
    assert(stream.data == "1");
    stream.clear();
    formattedWrite(stream, "%d", false);
    assert(stream.data == "0");

    stream.clear();
    formattedWrite(stream, "%d", 'a');
    assert(stream.data == "97", stream.data);
    wchar wc = 'a';
    stream.clear();
    formattedWrite(stream, "%d", wc);
    assert(stream.data == "97");
    dchar dc = 'a';
    stream.clear();
    formattedWrite(stream, "%d", dc);
    assert(stream.data == "97");

    byte b = byte.max;
    stream.clear();
    formattedWrite(stream, "%x", b);
    assert(stream.data == "7f");
    stream.clear();
    formattedWrite(stream, "%x", ++b);
    assert(stream.data == "80");
    stream.clear();
    formattedWrite(stream, "%x", ++b);
    assert(stream.data == "81");

    short sh = short.max;
    stream.clear();
    formattedWrite(stream, "%x", sh);
    assert(stream.data == "7fff");
    stream.clear();
    formattedWrite(stream, "%x", ++sh);
    assert(stream.data == "8000");
    stream.clear();
    formattedWrite(stream, "%x", ++sh);
    assert(stream.data == "8001");

    i = int.max;
    stream.clear();
    formattedWrite(stream, "%x", i);
    assert(stream.data == "7fffffff");
    stream.clear();
    formattedWrite(stream, "%x", ++i);
    assert(stream.data == "80000000");
    stream.clear();
    formattedWrite(stream, "%x", ++i);
    assert(stream.data == "80000001");

    stream.clear();
    formattedWrite(stream, "%x", 10);
    assert(stream.data == "a");
    stream.clear();
    formattedWrite(stream, "%X", 10);
    assert(stream.data == "A");
    stream.clear();
    formattedWrite(stream, "%x", 15);
    assert(stream.data == "f");
    stream.clear();
    formattedWrite(stream, "%X", 15);
    assert(stream.data == "F");

    @trusted void ObjectTest()
    {
        Object c = null;
        stream.clear();
        formattedWrite(stream, "%s", c);
        assert(stream.data == "null");
    }
    ObjectTest();

    enum TestEnum
    {
        Value1, Value2
    }
    stream.clear();
    formattedWrite(stream, "%s", TestEnum.Value2);
    assert(stream.data == "Value2", stream.data);
    stream.clear();
    formattedWrite(stream, "%s", cast(TestEnum) 5);
    assert(stream.data == "cast(TestEnum)5", stream.data);

    //immutable(char[5])[int] aa = ([3:"hello", 4:"betty"]);
    //stream.clear();
    //formattedWrite(stream, "%s", aa.values);
    //assert(stream.data == "[[h,e,l,l,o],[b,e,t,t,y]]");
    //stream.clear();
    //formattedWrite(stream, "%s", aa);
    //assert(stream.data == "[3:[h,e,l,l,o],4:[b,e,t,t,y]]");

    static const dchar[] ds = ['a','b'];
    for (int j = 0; j < ds.length; ++j)
    {
        stream.clear(); formattedWrite(stream, " %d", ds[j]);
        if (j == 0)
            assert(stream.data == " 97");
        else
            assert(stream.data == " 98");
    }

    stream.clear();
    formattedWrite(stream, "%.-3d", 7);
    assert(stream.data == "7", ">" ~ stream.data ~ "<");
}

@safe unittest
{
    import std.array : appender;
    import std.meta : AliasSeq;

    immutable(char[5])[int] aa = ([3:"hello", 4:"betty"]);
    assert(aa[3] == "hello");
    assert(aa[4] == "betty");

    auto stream = appender!(char[])();
    alias AllNumerics =
        AliasSeq!(byte, ubyte, short, ushort, int, uint, long, ulong,
                  float, double, real);
    foreach (T; AllNumerics)
    {
        T value = 1;
        stream.clear();
        formattedWrite(stream, "%s", value);
        assert(stream.data == "1");
    }

    stream.clear();
    formattedWrite(stream, "%s", aa);
}

@system unittest
{
    string s = "hello!124:34.5";
    string a;
    int b;
    double c;
    formattedRead(s, "%s!%s:%s", &a, &b, &c);
    assert(a == "hello" && b == 124 && c == 34.5);
}

version (StdUnittest)
private void formatReflectTest(T)(ref T val, string fmt, string formatted, string fn = __FILE__, size_t ln = __LINE__)
{
    import core.exception : AssertError;
    import std.array : appender;
    import std.traits : isAssociativeArray;

    auto w = appender!string();
    formattedWrite(w, fmt, val);

    auto input = w.data;
    enforce!AssertError(input == formatted, input, fn, ln);

    T val2;
    formattedRead(input, fmt, &val2);

    static if (isAssociativeArray!T)
        if (__ctfe)
        {
            alias aa1 = val;
            alias aa2 = val2;
            assert(aa1 == aa2);

            assert(aa1.length == aa2.length);

            assert(aa1.keys == aa2.keys);

            assert(aa1.values == aa2.values);
            assert(aa1.values.length == aa2.values.length);
            foreach (i; 0 .. aa1.values.length)
                assert(aa1.values[i] == aa2.values[i]);

            foreach (i, key; aa1.keys)
                assert(aa1.values[i] == aa1[key]);
            foreach (i, key; aa2.keys)
                assert(aa2.values[i] == aa2[key]);
            return;
        }

    enforce!AssertError(val == val2, input, fn, ln);
}

version (StdUnittest)
private void formatReflectTest(T)(ref T val, string fmt, string[] formatted, string fn = __FILE__, size_t ln = __LINE__)
{
    import core.exception : AssertError;
    import std.array : appender;
    import std.traits : isAssociativeArray;

    auto w = appender!string();
    formattedWrite(w, fmt, val);

    auto input = w.data;

    foreach (cur; formatted)
    {
        if (input == cur) return;
    }
    enforce!AssertError(false, input, fn, ln);

    T val2;
    formattedRead(input, fmt, &val2);

    static if (isAssociativeArray!T)
        if (__ctfe)
        {
            alias aa1 = val;
            alias aa2 = val2;
            assert(aa1 == aa2);

            assert(aa1.length == aa2.length);

            assert(aa1.keys == aa2.keys);

            assert(aa1.values == aa2.values);
            assert(aa1.values.length == aa2.values.length);
            foreach (i; 0 .. aa1.values.length)
                assert(aa1.values[i] == aa2.values[i]);

            foreach (i, key; aa1.keys)
                assert(aa1.values[i] == aa1[key]);
            foreach (i, key; aa2.keys)
                assert(aa2.values[i] == aa2[key]);
            return;
        }

    enforce!AssertError(val == val2, input, fn, ln);
}

@system unittest
{
    void booleanTest()
    {
        auto b = true;
        formatReflectTest(b, "%s", `true`);
        formatReflectTest(b, "%b", `1`);
        formatReflectTest(b, "%o", `1`);
        formatReflectTest(b, "%d", `1`);
        formatReflectTest(b, "%u", `1`);
        formatReflectTest(b, "%x", `1`);
    }

    void integerTest()
    {
        auto n = 127;
        formatReflectTest(n, "%s", `127`);
        formatReflectTest(n, "%b", `1111111`);
        formatReflectTest(n, "%o", `177`);
        formatReflectTest(n, "%d", `127`);
        formatReflectTest(n, "%u", `127`);
        formatReflectTest(n, "%x", `7f`);
    }

    void floatingTest()
    {
        auto f = 3.14;
        formatReflectTest(f, "%s", `3.14`);
        formatReflectTest(f, "%e", `3.140000e+00`);
        formatReflectTest(f, "%f", `3.140000`);
        formatReflectTest(f, "%g", `3.14`);
    }

    void charTest()
    {
        auto c = 'a';
        formatReflectTest(c, "%s", `a`);
        formatReflectTest(c, "%c", `a`);
        formatReflectTest(c, "%b", `1100001`);
        formatReflectTest(c, "%o", `141`);
        formatReflectTest(c, "%d", `97`);
        formatReflectTest(c, "%u", `97`);
        formatReflectTest(c, "%x", `61`);
    }

    void strTest()
    {
        auto s = "hello";
        formatReflectTest(s, "%s",              `hello`);
        formatReflectTest(s, "%(%c,%)",         `h,e,l,l,o`);
        formatReflectTest(s, "%(%s,%)",         `'h','e','l','l','o'`);
        formatReflectTest(s, "[%(<%c>%| $ %)]", `[<h> $ <e> $ <l> $ <l> $ <o>]`);
    }

    void daTest()
    {
        auto a = [1,2,3,4];
        formatReflectTest(a, "%s",              `[1, 2, 3, 4]`);
        formatReflectTest(a, "[%(%s; %)]",      `[1; 2; 3; 4]`);
        formatReflectTest(a, "[%(<%s>%| $ %)]", `[<1> $ <2> $ <3> $ <4>]`);
    }

    void saTest()
    {
        int[4] sa = [1,2,3,4];
        formatReflectTest(sa, "%s",              `[1, 2, 3, 4]`);
        formatReflectTest(sa, "[%(%s; %)]",      `[1; 2; 3; 4]`);
        formatReflectTest(sa, "[%(<%s>%| $ %)]", `[<1> $ <2> $ <3> $ <4>]`);
    }

    void aaTest()
    {
        auto aa = [1:"hello", 2:"world"];
        formatReflectTest(aa, "%s",                    [`[1:"hello", 2:"world"]`, `[2:"world", 1:"hello"]`]);
        formatReflectTest(aa, "[%(%s->%s, %)]",        [`[1->"hello", 2->"world"]`, `[2->"world", 1->"hello"]`]);
        formatReflectTest(aa, "{%([%s=%(%c%)]%|; %)}", [`{[1=hello]; [2=world]}`, `{[2=world]; [1=hello]}`]);
    }

    import std.exception : assertCTFEable;

    assertCTFEable!(
    {
        booleanTest();
        integerTest();
        if (!__ctfe) floatingTest();    // snprintf
        charTest();
        strTest();
        daTest();
        saTest();
        aaTest();
        return true;
    });
}

// Undocumented
T unformatElement(T, Range, Char)(ref Range input, scope const ref FormatSpec!Char spec)
if (isInputRange!Range)
{
    import std.conv : parseElement;

    static if (isSomeString!T)
    {
        if (spec.spec == 's')
        {
            return parseElement!T(input);
        }
    }
    else static if (isSomeChar!T)
    {
        if (spec.spec == 's')
        {
            return parseElement!T(input);
        }
    }

    return unformatValue!T(input, spec);
}

/* ======================== Unit Tests ====================================== */

@system unittest
{
    int i;
    string s;

    s = format("hello world! %s %s %s%s%s", true, 57, 1_000_000_000, 'x', " foo");
    assert(s == "hello world! true 57 1000000000x foo");

    s = format("%s %A %s", 1.67, -1.28, float.nan);
    assert(s == "1.67 -0X1.47AE147AE147BP+0 nan", s);

    s = format("%x %X", 0x1234AF, 0xAFAFAFAF);
    assert(s == "1234af AFAFAFAF");

    s = format("%b %o", 0x1234AF, 0xAFAFAFAF);
    assert(s == "100100011010010101111 25753727657");

    s = format("%d %s", 0x1234AF, 0xAFAFAFAF);
    assert(s == "1193135 2947526575");
}

@system unittest
{
    import std.conv : octal;

    string s;
    int i;

    s = format("%#06.*f", 2, 12.345);
    assert(s == "012.35");

    s = format("%#0*.*f", 6, 2, 12.345);
    assert(s == "012.35");

    s = format("%7.4g:", 12.678);
    assert(s == "  12.68:");

    s = format("%7.4g:", 12.678L);
    assert(s == "  12.68:");

    s = format("%04f|%05d|%#05x|%#5x", -4.0, -10, 1, 1);
    assert(s == "-4.000000|-0010|0x001|  0x1");

    i = -10;
    s = format("%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(s == "-10|-10|-10|-10|-10.0000");

    i = -5;
    s = format("%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(s == "-5| -5|-05|-5|-5.0000");

    i = 0;
    s = format("%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(s == "0|  0|000|0|0.0000");

    i = 5;
    s = format("%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(s == "5|  5|005|5|5.0000");

    i = 10;
    s = format("%d|%3d|%03d|%1d|%01.4f", i, i, i, i, cast(double) i);
    assert(s == "10| 10|010|10|10.0000");

    s = format("%.0d", 0);
    assert(s == "");

    s = format("%.g", .34);
    assert(s == "0.3");

    s = format("%.0g", .34);
    assert(s == "0.3");

    s = format("%.2g", .34);
    assert(s == "0.34");

    s = format("%0.0008f", 1e-08);
    assert(s == "0.00000001");

    s = format("%0.0008f", 1e-05);
    assert(s == "0.00001000");

    s = "helloworld";
    string r;
    r = format("%.2s", s[0 .. 5]);
    assert(r == "he");
    r = format("%.20s", s[0 .. 5]);
    assert(r == "hello");
    r = format("%8s", s[0 .. 5]);
    assert(r == "   hello");

    byte[] arrbyte = new byte[4];
    arrbyte[0] = 100;
    arrbyte[1] = -99;
    arrbyte[3] = 0;
    r = format("%s", arrbyte);
    assert(r == "[100, -99, 0, 0]");

    ubyte[] arrubyte = new ubyte[4];
    arrubyte[0] = 100;
    arrubyte[1] = 200;
    arrubyte[3] = 0;
    r = format("%s", arrubyte);
    assert(r == "[100, 200, 0, 0]");

    short[] arrshort = new short[4];
    arrshort[0] = 100;
    arrshort[1] = -999;
    arrshort[3] = 0;
    r = format("%s", arrshort);
    assert(r == "[100, -999, 0, 0]");

    ushort[] arrushort = new ushort[4];
    arrushort[0] = 100;
    arrushort[1] = 20_000;
    arrushort[3] = 0;
    r = format("%s", arrushort);
    assert(r == "[100, 20000, 0, 0]");

    int[] arrint = new int[4];
    arrint[0] = 100;
    arrint[1] = -999;
    arrint[3] = 0;
    r = format("%s", arrint);
    assert(r == "[100, -999, 0, 0]");

    long[] arrlong = new long[4];
    arrlong[0] = 100;
    arrlong[1] = -999;
    arrlong[3] = 0;
    r = format("%s", arrlong);
    assert(r == "[100, -999, 0, 0]");

    ulong[] arrulong = new ulong[4];
    arrulong[0] = 100;
    arrulong[1] = 999;
    arrulong[3] = 0;
    r = format("%s", arrulong);
    assert(r == "[100, 999, 0, 0]");

    string[] arr2 = new string[4];
    arr2[0] = "hello";
    arr2[1] = "world";
    arr2[3] = "foo";
    r = format("%s", arr2);
    assert(r == `["hello", "world", "", "foo"]`);

    r = format("%.8d", 7);
    assert(r == "00000007");
    r = format("%.8x", 10);
    assert(r == "0000000a");

    r = format("%-3d", 7);
    assert(r == "7  ");

    r = format("%-1*d", 4, 3);
    assert(r == "3   ");

    r = format("%*d", -3, 7);
    assert(r == "7  ");

    r = format("%.*d", -3, 7);
    assert(r == "7");

    r = format("%-1.*f", 2, 3.1415);
    assert(r == "3.14");

    r = format("abc"c);
    assert(r == "abc");

    //format() returns the same type as inputted.
    wstring wr;
    wr = format("def"w);
    assert(wr == "def"w);

    dstring dr;
    dr = format("ghi"d);
    assert(dr == "ghi"d);

    // Empty static character arrays work as well
    const char[0] cempty;
    assert(format("test%spath", cempty) == "testpath");
    const wchar[0] wempty;
    assert(format("test%spath", wempty) == "testpath");
    const dchar[0] dempty;
    assert(format("test%spath", dempty) == "testpath");

    void* p = cast(void*) 0xDEADBEEF;
    r = format("%s", p);
    assert(r == "DEADBEEF");

    r = format("%#x", 0xabcd);
    assert(r == "0xabcd");
    r = format("%#X", 0xABCD);
    assert(r == "0XABCD");

    r = format("%#o", octal!12345);
    assert(r == "012345");
    r = format("%o", 9);
    assert(r == "11");
    r = format("%#o", 0);   // https://issues.dlang.org/show_bug.cgi?id=15663
    assert(r == "0");

    r = format("%+d", 123);
    assert(r == "+123");
    r = format("%+d", -123);
    assert(r == "-123");
    r = format("% d", 123);
    assert(r == " 123");
    r = format("% d", -123);
    assert(r == "-123");

    r = format("%%");
    assert(r == "%");

    r = format("%d", true);
    assert(r == "1");
    r = format("%d", false);
    assert(r == "0");

    r = format("%d", 'a');
    assert(r == "97");
    wchar wc = 'a';
    r = format("%d", wc);
    assert(r == "97");
    dchar dc = 'a';
    r = format("%d", dc);
    assert(r == "97");

    byte b = byte.max;
    r = format("%x", b);
    assert(r == "7f");
    r = format("%x", ++b);
    assert(r == "80");
    r = format("%x", ++b);
    assert(r == "81");

    short sh = short.max;
    r = format("%x", sh);
    assert(r == "7fff");
    r = format("%x", ++sh);
    assert(r == "8000");
    r = format("%x", ++sh);
    assert(r == "8001");

    i = int.max;
    r = format("%x", i);
    assert(r == "7fffffff");
    r = format("%x", ++i);
    assert(r == "80000000");
    r = format("%x", ++i);
    assert(r == "80000001");

    r = format("%x", 10);
    assert(r == "a");
    r = format("%X", 10);
    assert(r == "A");
    r = format("%x", 15);
    assert(r == "f");
    r = format("%X", 15);
    assert(r == "F");

    Object c = null;
    r = format("%s", c);
    assert(r == "null");

    enum TestEnum
    {
        Value1, Value2
    }
    r = format("%s", TestEnum.Value2);
    assert(r == "Value2");

    immutable(char[5])[int] aa = ([3:"hello", 4:"betty"]);
    r = format("%s", aa.values);
    assert(r == `["hello", "betty"]` || r == `["betty", "hello"]`);
    r = format("%s", aa);
    assert(r == `[3:"hello", 4:"betty"]` || r == `[4:"betty", 3:"hello"]`);

    static const dchar[] ds = ['a','b'];
    for (int j = 0; j < ds.length; ++j)
    {
        r = format(" %d", ds[j]);
        if (j == 0)
            assert(r == " 97");
        else
            assert(r == " 98");
    }

    r = format(">%14d<, %s", 15, [1,2,3]);
    assert(r == ">            15<, [1, 2, 3]");

    assert(format("%8s", "bar") == "     bar");
    assert(format("%8s", "b\u00e9ll\u00f4") == "   b\u00e9ll\u00f4");
}

// https://issues.dlang.org/show_bug.cgi?id=18205
@safe pure unittest
{
    assert("|%8s|".format("abc")       == "|     abc|");
    assert("|%8s|".format("αβγ")       == "|     αβγ|");
    assert("|%8s|".format("   ")       == "|        |");
    assert("|%8s|".format("été"d)      == "|     été|");
    assert("|%8s|".format("été 2018"w) == "|été 2018|");

    assert("%2s".format("e\u0301"w) == " e\u0301");
    assert("%2s".format("a\u0310\u0337"d) == " a\u0310\u0337");
}

// https://issues.dlang.org/show_bug.cgi?id=3479
@safe unittest
{
    import std.array : appender;

    auto stream = appender!(char[])();
    formattedWrite(stream, "%2$.*1$d", 12, 10);
    assert(stream.data == "000000000010", stream.data);
}

// https://issues.dlang.org/show_bug.cgi?id=6893
@safe unittest
{
    import std.array : appender;

    enum E : ulong { A, B, C }
    auto stream = appender!(char[])();
    formattedWrite(stream, "%s", E.C);
    assert(stream.data == "C");
}

// Used to check format strings are compatible with argument types
package(std) static const checkFormatException(alias fmt, Args...) =
{
    import std.conv : text;
    import std.format.internal.floats : ctfpMessage;

    try
    {
        auto n = .formattedWrite(NoOpSink(), fmt, Args.init);

        enforceFmt(n == Args.length, text("Orphan format arguments: args[", n, "..", Args.length, "]"));
    }
    catch (Exception e)
        return (e.msg == ctfpMessage) ? null : e;
    return null;
}();

/**
 * Format arguments into a string.
 *
 * If the format string is fixed, passing it as a template parameter checks the
 * type correctness of the parameters at compile-time. This also can result in
 * better performance.
 *
 * Params: fmt  = Format string. For detailed specification, see
 *         $(REF_ALTTEXT $(D formattedWrite), formattedWrite, std, format, write).
 *         args = Variadic list of arguments to format into returned string.
 *
 * Throws:
 *     $(LREF, FormatException) if the number of arguments doesn't match the number
 *     of format parameters and vice-versa.
 */
typeof(fmt) format(alias fmt, Args...)(Args args)
if (isSomeString!(typeof(fmt)))
{
    import std.array : appender;
    import std.range.primitives : ElementEncodingType;
    import std.traits : Unqual;

    alias e = checkFormatException!(fmt, Args);
    alias Char = Unqual!(ElementEncodingType!(typeof(fmt)));

    static assert(!e, e.msg);
    auto w = appender!(immutable(Char)[]);

    // no need to traverse the string twice during compile time
    if (!__ctfe)
    {
        enum len = guessLength!Char(fmt);
        w.reserve(len);
    }
    else
    {
        w.reserve(fmt.length);
    }

    formattedWrite(w, fmt, args);
    return w.data;
}

/// Type checking can be done when fmt is known at compile-time:
@safe unittest
{
    auto s = format!"%s is %s"("Pi", 3.14);
    assert(s == "Pi is 3.14");

    static assert(!__traits(compiles, {s = format!"%l"();}));     // missing arg
    static assert(!__traits(compiles, {s = format!""(404);}));    // surplus arg
    static assert(!__traits(compiles, {s = format!"%d"(4.03);})); // incompatible arg
}

// called during compilation to guess the length of the
// result of format
private size_t guessLength(Char, S)(S fmtString)
{
    import std.array : appender;

    size_t len;
    auto output = appender!(immutable(Char)[])();
    auto spec = FormatSpec!Char(fmtString);
    while (spec.writeUpToNextSpec(output))
    {
        // take a guess
        if (spec.width == 0 && (spec.precision == spec.UNSPECIFIED || spec.precision == spec.DYNAMIC))
        {
            switch (spec.spec)
            {
                case 'c':
                    ++len;
                    break;
                case 'd':
                case 'x':
                case 'X':
                    len += 3;
                    break;
                case 'b':
                    len += 8;
                    break;
                case 'f':
                case 'F':
                    len += 10;
                    break;
                case 's':
                case 'e':
                case 'E':
                case 'g':
                case 'G':
                    len += 12;
                    break;
                default: break;
            }

            continue;
        }

        if ((spec.spec == 'e' || spec.spec == 'E' || spec.spec == 'g' ||
             spec.spec == 'G' || spec.spec == 'f' || spec.spec == 'F') &&
            spec.precision != spec.UNSPECIFIED && spec.precision != spec.DYNAMIC &&
            spec.width == 0
        )
        {
            len += spec.precision + 5;
            continue;
        }

        if (spec.width == spec.precision)
            len += spec.width;
        else if (spec.width > 0 && spec.width != spec.DYNAMIC &&
                 (spec.precision == spec.UNSPECIFIED || spec.width > spec.precision))
        {
            len += spec.width;
        }
        else if (spec.precision != spec.UNSPECIFIED && spec.precision > spec.width)
            len += spec.precision;
    }
    len += output.data.length;
    return len;
}

@safe pure
unittest
{
    assert(guessLength!char("%c") == 1);
    assert(guessLength!char("%d") == 3);
    assert(guessLength!char("%x") == 3);
    assert(guessLength!char("%b") == 8);
    assert(guessLength!char("%f") == 10);
    assert(guessLength!char("%s") == 12);
    assert(guessLength!char("%02d") == 2);
    assert(guessLength!char("%02d") == 2);
    assert(guessLength!char("%4.4d") == 4);
    assert(guessLength!char("%2.4f") == 4);
    assert(guessLength!char("%02d:%02d:%02d") == 8);
    assert(guessLength!char("%0.2f") == 7);
    assert(guessLength!char("%0*d") == 0);
}

/// ditto
immutable(Char)[] format(Char, Args...)(in Char[] fmt, Args args)
if (isSomeChar!Char)
{
    import std.array : appender;

    auto w = appender!(immutable(Char)[]);
    auto n = formattedWrite(w, fmt, args);
    version (all)
    {
        // In the future, this check will be removed to increase consistency
        // with formattedWrite
        import std.conv : text;
        enforceFmt(n == args.length, text("Orphan format arguments: args[", n, "..", args.length, "]"));
    }
    return w.data;
}

@safe pure unittest
{
    import std.exception : assertCTFEable, assertThrown;

    assertCTFEable!(
    {
        assert(format("foo") == "foo");
        assert(format("foo%%") == "foo%");
        assert(format("foo%s", 'C') == "fooC");
        assert(format("%s foo", "bar") == "bar foo");
        assert(format("%s foo %s", "bar", "abc") == "bar foo abc");
        assert(format("foo %d", -123) == "foo -123");
        assert(format("foo %d", 123) == "foo 123");

        assertThrown!FormatException(format("foo %s"));
        assertThrown!FormatException(format("foo %s", 123, 456));

        assert(format("hel%slo%s%s%s", "world", -138, 'c', true) == "helworldlo-138ctrue");
    });

    assert(is(typeof(format("happy")) == string));
    assert(is(typeof(format("happy"w)) == wstring));
    assert(is(typeof(format("happy"d)) == dstring));
}

// https://issues.dlang.org/show_bug.cgi?id=16661
@safe unittest
{
    assert(format("%.2f"d, 0.4) == "0.40");
    assert("%02d"d.format(1) == "01"d);
}

/*****************************************************
 * Format arguments into buffer $(I buf) which must be large
 * enough to hold the result.
 *
 * Returns:
 *     The slice of `buf` containing the formatted string.
 *
 * Throws:
 *     A `RangeError` if `buf` isn't large enough to hold the
 *     formatted string.
 *
 *     A $(LREF FormatException) if the length of `args` is different
 *     than the number of format specifiers in `fmt`.
 */
char[] sformat(alias fmt, Args...)(char[] buf, Args args)
if (isSomeString!(typeof(fmt)))
{
    alias e = checkFormatException!(fmt, Args);
    static assert(!e, e.msg);
    return .sformat(buf, fmt, args);
}

/// ditto
char[] sformat(Char, Args...)(return scope char[] buf, scope const(Char)[] fmt, Args args)
{
    import core.exception : RangeError;
    import std.range.primitives;
    import std.utf : encode;

    static struct Sink
    {
        char[] buf;
        size_t i;
        void put(dchar c)
        {
            char[4] enc;
            auto n = encode(enc, c);

            if (buf.length < i + n)
                throw new RangeError(__FILE__, __LINE__);

            buf[i .. i + n] = enc[0 .. n];
            i += n;
        }
        void put(scope const(char)[] s)
        {
            if (buf.length < i + s.length)
                throw new RangeError(__FILE__, __LINE__);

            buf[i .. i + s.length] = s[];
            i += s.length;
        }
        void put(scope const(wchar)[] s)
        {
            for (; !s.empty; s.popFront())
                put(s.front);
        }
        void put(scope const(dchar)[] s)
        {
            for (; !s.empty; s.popFront())
                put(s.front);
        }
    }
    auto sink = Sink(buf);
    auto n = formattedWrite(sink, fmt, args);
    version (all)
    {
        // In the future, this check will be removed to increase consistency
        // with formattedWrite
        import std.conv : text;
        enforceFmt(
            n == args.length,
            text("Orphan format arguments: args[", n, " .. ", args.length, "]")
        );
    }
    return buf[0 .. sink.i];
}

/// The format string can be checked at compile-time (see $(LREF format) for details):
@system unittest
{
    char[10] buf;

    assert(buf[].sformat!"foo%s"('C') == "fooC");
    assert(sformat(buf[], "%s foo", "bar") == "bar foo");
}

@system unittest
{
    import core.exception : RangeError;
    import std.exception : assertCTFEable, assertThrown;

    assertCTFEable!(
    {
        char[10] buf;

        assert(sformat(buf[], "foo") == "foo");
        assert(sformat(buf[], "foo%%") == "foo%");
        assert(sformat(buf[], "foo%s", 'C') == "fooC");
        assert(sformat(buf[], "%s foo", "bar") == "bar foo");
        assertThrown!RangeError(sformat(buf[], "%s foo %s", "bar", "abc"));
        assert(sformat(buf[], "foo %d", -123) == "foo -123");
        assert(sformat(buf[], "foo %d", 123) == "foo 123");

        assertThrown!FormatException(sformat(buf[], "foo %s"));
        assertThrown!FormatException(sformat(buf[], "foo %s", 123, 456));

        assert(sformat(buf[], "%s %s %s", "c"c, "w"w, "d"d) == "c w d");
    });
}

@system unittest // ensure that sformat avoids the GC
{
    import core.memory : GC;

    const a = ["foo", "bar"];
    const u = GC.stats().usedSize;
    char[20] buf;
    sformat(buf, "%d", 123);
    sformat(buf, "%s", a);
    sformat(buf, "%s", 'c');
    assert(u == GC.stats().usedSize);
}

/*****************************
 * The .ptr is unsafe because it could be dereferenced and the length of the array may be 0.
 * Returns:
 *      the difference between the starts of the arrays
 */
package ptrdiff_t arrayPtrDiff(T)(const T[] array1, const T[] array2) @trusted pure nothrow @nogc
{
    return array1.ptr - array2.ptr;
}

@safe unittest
{
    import std.exception : assertCTFEable;

    assertCTFEable!(
    {
        auto tmp = format("%,d", 1000);
        assert(tmp == "1,000", "'" ~ tmp ~ "'");

        tmp = format("%,?d", 'z', 1234567);
        assert(tmp == "1z234z567", "'" ~ tmp ~ "'");

        tmp = format("%10,?d", 'z', 1234567);
        assert(tmp == " 1z234z567", "'" ~ tmp ~ "'");

        tmp = format("%11,2?d", 'z', 1234567);
        assert(tmp == " 1z23z45z67", "'" ~ tmp ~ "'");

        tmp = format("%11,*?d", 2, 'z', 1234567);
        assert(tmp == " 1z23z45z67", "'" ~ tmp ~ "'");

        tmp = format("%11,*d", 2, 1234567);
        assert(tmp == " 1,23,45,67", "'" ~ tmp ~ "'");

        tmp = format("%11,2d", 1234567);
        assert(tmp == " 1,23,45,67", "'" ~ tmp ~ "'");
    });
}

@safe unittest
{
    auto tmp = format("%,f", 1000.0);
    assert(tmp == "1,000.000000", "'" ~ tmp ~ "'");

    tmp = format("%,f", 1234567.891011);
    assert(tmp == "1,234,567.891011", "'" ~ tmp ~ "'");

    tmp = format("%,f", -1234567.891011);
    assert(tmp == "-1,234,567.891011", "'" ~ tmp ~ "'");

    tmp = format("%,2f", 1234567.891011);
    assert(tmp == "1,23,45,67.891011", "'" ~ tmp ~ "'");

    tmp = format("%18,f", 1234567.891011);
    assert(tmp == "  1,234,567.891011", "'" ~ tmp ~ "'");

    tmp = format("%18,?f", '.', 1234567.891011);
    assert(tmp == "  1.234.567.891011", "'" ~ tmp ~ "'");

    tmp = format("%,?.3f", 'ä', 1234567.891011);
    assert(tmp == "1ä234ä567.891", "'" ~ tmp ~ "'");

    tmp = format("%,*?.3f", 1, 'ä', 1234567.891011);
    assert(tmp == "1ä2ä3ä4ä5ä6ä7.891", "'" ~ tmp ~ "'");

    tmp = format("%,4?.3f", '_', 1234567.891011);
    assert(tmp == "123_4567.891", "'" ~ tmp ~ "'");

    tmp = format("%12,3.3f", 1234.5678);
    assert(tmp == "   1,234.568", "'" ~ tmp ~ "'");

    tmp = format("%,e", 3.141592653589793238462);
    assert(tmp == "3.141593e+00", "'" ~ tmp ~ "'");

    tmp = format("%15,e", 3.141592653589793238462);
    assert(tmp == "   3.141593e+00", "'" ~ tmp ~ "'");

    tmp = format("%15,e", -3.141592653589793238462);
    assert(tmp == "  -3.141593e+00", "'" ~ tmp ~ "'");

    tmp = format("%.4,*e", 2, 3.141592653589793238462);
    assert(tmp == "3.1416e+00", "'" ~ tmp ~ "'");

    tmp = format("%13.4,*e", 2, 3.141592653589793238462);
    assert(tmp == "   3.1416e+00", "'" ~ tmp ~ "'");

    tmp = format("%,.0f", 3.14);
    assert(tmp == "3", "'" ~ tmp ~ "'");

    tmp = format("%3,g", 1_000_000.123456);
    assert(tmp == "1e+06", "'" ~ tmp ~ "'");

    tmp = format("%19,?f", '.', -1234567.891011);
    assert(tmp == "  -1.234.567.891011", "'" ~ tmp ~ "'");
}

// Test for multiple indexes
@safe unittest
{
    auto tmp = format("%2:5$s", 1, 2, 3, 4, 5);
    assert(tmp == "2345", tmp);
}

// https://issues.dlang.org/show_bug.cgi?id=18047
@safe unittest
{
    auto cmp = "     123,456";
    assert(cmp.length == 12, format("%d", cmp.length));
    auto tmp = format("%12,d", 123456);
    assert(tmp.length == 12, format("%d", tmp.length));

    assert(tmp == cmp, "'" ~ tmp ~ "'");
}

// https://issues.dlang.org/show_bug.cgi?id=17459
@safe unittest
{
    auto cmp = "100";
    auto tmp  = format("%0d", 100);
    assert(tmp == cmp, tmp);

    cmp = "0100";
    tmp  = format("%04d", 100);
    assert(tmp == cmp, tmp);

    cmp = "0,000,000,100";
    tmp  = format("%012,3d", 100);
    assert(tmp == cmp, tmp);

    cmp = "0,000,001,000";
    tmp = format("%012,3d", 1_000);
    assert(tmp == cmp, tmp);

    cmp = "0,000,100,000";
    tmp = format("%012,3d", 100_000);
    assert(tmp == cmp, tmp);

    cmp = "0,001,000,000";
    tmp = format("%012,3d", 1_000_000);
    assert(tmp == cmp, tmp);

    cmp = "0,100,000,000";
    tmp = format("%012,3d", 100_000_000);
    assert(tmp == cmp, tmp);
}

// https://issues.dlang.org/show_bug.cgi?id=17459
@safe unittest
{
    auto cmp = "100,000";
    auto tmp  = format("%06,d", 100_000);
    assert(tmp == cmp, tmp);

    cmp = "100,000";
    tmp  = format("%07,d", 100_000);
    assert(tmp == cmp, tmp);

    cmp = "0,100,000";
    tmp  = format("%08,d", 100_000);
    assert(tmp == cmp, tmp);
}

// https://issues.dlang.org/show_bug.cgi?id=20288
@safe unittest
{
    string s = format("%,.2f", double.nan);
    assert(s == "nan", s);

    s = format("%,.2F", double.nan);
    assert(s == "NAN", s);

    s = format("%,.2f", -double.nan);
    assert(s == "-nan", s);

    s = format("%,.2F", -double.nan);
    assert(s == "-NAN", s);

    string g = format("^%13s$", "nan");
    string h = "^          nan$";
    assert(g == h, "\ngot:" ~ g ~ "\nexp:" ~ h);
    string a = format("^%13,3.2f$", double.nan);
    string b = format("^%13,3.2F$", double.nan);
    string c = format("^%13,3.2f$", -double.nan);
    string d = format("^%13,3.2F$", -double.nan);
    assert(a == "^          nan$", "\ngot:'"~ a ~ "'\nexp:'^          nan$'");
    assert(b == "^          NAN$", "\ngot:'"~ b ~ "'\nexp:'^          NAN$'");
    assert(c == "^         -nan$", "\ngot:'"~ c ~ "'\nexp:'^         -nan$'");
    assert(d == "^         -NAN$", "\ngot:'"~ d ~ "'\nexp:'^         -NAN$'");

    a = format("^%-13,3.2f$", double.nan);
    b = format("^%-13,3.2F$", double.nan);
    c = format("^%-13,3.2f$", -double.nan);
    d = format("^%-13,3.2F$", -double.nan);
    assert(a == "^nan          $", "\ngot:'"~ a ~ "'\nexp:'^nan          $'");
    assert(b == "^NAN          $", "\ngot:'"~ b ~ "'\nexp:'^NAN          $'");
    assert(c == "^-nan         $", "\ngot:'"~ c ~ "'\nexp:'^-nan         $'");
    assert(d == "^-NAN         $", "\ngot:'"~ d ~ "'\nexp:'^-NAN         $'");

    a = format("^%+13,3.2f$", double.nan);
    b = format("^%+13,3.2F$", double.nan);
    c = format("^%+13,3.2f$", -double.nan);
    d = format("^%+13,3.2F$", -double.nan);
    assert(a == "^         +nan$", "\ngot:'"~ a ~ "'\nexp:'^         +nan$'");
    assert(b == "^         +NAN$", "\ngot:'"~ b ~ "'\nexp:'^         +NAN$'");
    assert(c == "^         -nan$", "\ngot:'"~ c ~ "'\nexp:'^         -nan$'");
    assert(d == "^         -NAN$", "\ngot:'"~ d ~ "'\nexp:'^         -NAN$'");

    a = format("^%-+13,3.2f$", double.nan);
    b = format("^%-+13,3.2F$", double.nan);
    c = format("^%-+13,3.2f$", -double.nan);
    d = format("^%-+13,3.2F$", -double.nan);
    assert(a == "^+nan         $", "\ngot:'"~ a ~ "'\nexp:'^+nan         $'");
    assert(b == "^+NAN         $", "\ngot:'"~ b ~ "'\nexp:'^+NAN         $'");
    assert(c == "^-nan         $", "\ngot:'"~ c ~ "'\nexp:'^-nan         $'");
    assert(d == "^-NAN         $", "\ngot:'"~ d ~ "'\nexp:'^-NAN         $'");

    a = format("^%- 13,3.2f$", double.nan);
    b = format("^%- 13,3.2F$", double.nan);
    c = format("^%- 13,3.2f$", -double.nan);
    d = format("^%- 13,3.2F$", -double.nan);
    assert(a == "^ nan         $", "\ngot:'"~ a ~ "'\nexp:'^ nan         $'");
    assert(b == "^ NAN         $", "\ngot:'"~ b ~ "'\nexp:'^ NAN         $'");
    assert(c == "^-nan         $", "\ngot:'"~ c ~ "'\nexp:'^-nan         $'");
    assert(d == "^-NAN         $", "\ngot:'"~ d ~ "'\nexp:'^-NAN         $'");
}
