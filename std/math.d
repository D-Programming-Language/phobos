// Written in the D programming language.

/**
 * Contains the elementary mathematical functions (powers, roots,
 * and trigonometric functions), and low-level floating-point operations.
 * Mathematical special functions are available in `std.mathspecial`.
 *
$(SCRIPT inhibitQuickIndex = 1;)

$(DIVC quickindex,
$(BOOKTABLE ,
$(TR $(TH Category) $(TH Members) )
$(TR $(TDNW Constants) $(TD
    $(MYREF E) $(MYREF PI) $(MYREF PI_2) $(MYREF PI_4) $(MYREF M_1_PI)
    $(MYREF M_2_PI) $(MYREF M_2_SQRTPI) $(MYREF LN10) $(MYREF LN2)
    $(MYREF LOG2) $(MYREF LOG2E) $(MYREF LOG2T) $(MYREF LOG10E)
    $(MYREF SQRT2) $(MYREF SQRT1_2)
))
$(TR $(TDNW Classics) $(TD
    $(MYREF abs) $(MYREF fabs) $(MYREF sqrt) $(MYREF cbrt) $(MYREF hypot)
    $(MYREF poly) $(MYREF nextPow2) $(MYREF truncPow2)
))
$(TR $(TDNW Trigonometry) $(TD
    $(MYREF sin) $(MYREF cos) $(MYREF tan) $(MYREF asin) $(MYREF acos)
    $(MYREF atan) $(MYREF atan2) $(MYREF sinh) $(MYREF cosh) $(MYREF tanh)
    $(MYREF asinh) $(MYREF acosh) $(MYREF atanh)
))
$(TR $(TDNW Rounding) $(TD
    $(MYREF ceil) $(MYREF floor) $(MYREF round) $(MYREF lround)
    $(MYREF trunc) $(MYREF rint) $(MYREF lrint) $(MYREF nearbyint)
    $(MYREF rndtol) $(MYREF quantize)
))
$(TR $(TDNW Exponentiation & Logarithms) $(TD
    $(MYREF pow) $(MYREF exp) $(MYREF exp2) $(MYREF expm1) $(MYREF ldexp)
    $(MYREF frexp) $(MYREF log) $(MYREF log2) $(MYREF log10) $(MYREF logb)
    $(MYREF ilogb) $(MYREF log1p) $(MYREF scalbn)
))
$(TR $(TDNW Modulus) $(TD
    $(MYREF fmod) $(MYREF modf) $(MYREF remainder)
))
$(TR $(TDNW Floating-point operations) $(TD
    $(MYREF approxEqual) $(MYREF feqrel) $(MYREF fdim) $(MYREF fmax)
    $(MYREF fmin) $(MYREF fma) $(MYREF isClose) $(MYREF nextDown) $(MYREF nextUp)
    $(MYREF nextafter) $(MYREF NaN) $(MYREF getNaNPayload)
    $(MYREF cmp)
))
$(TR $(TDNW Introspection) $(TD
    $(MYREF isFinite) $(MYREF isIdentical) $(MYREF isInfinity) $(MYREF isNaN)
    $(MYREF isNormal) $(MYREF isSubnormal) $(MYREF signbit) $(MYREF sgn)
    $(MYREF copysign) $(MYREF isPowerOf2)
))
$(TR $(TDNW Hardware Control) $(TD
    $(MYREF IeeeFlags) $(MYREF FloatingPointControl)
))
)
)

 * The functionality closely follows the IEEE754-2008 standard for
 * floating-point arithmetic, including the use of camelCase names rather
 * than C99-style lower case names. All of these functions behave correctly
 * when presented with an infinity or NaN.
 *
 * The following IEEE 'real' formats are currently supported:
 * $(UL
 * $(LI 64 bit Big-endian  'double' (eg PowerPC))
 * $(LI 128 bit Big-endian 'quadruple' (eg SPARC))
 * $(LI 64 bit Little-endian 'double' (eg x86-SSE2))
 * $(LI 80 bit Little-endian, with implied bit 'real80' (eg x87, Itanium))
 * $(LI 128 bit Little-endian 'quadruple' (not implemented on any known processor!))
 * $(LI Non-IEEE 128 bit Big-endian 'doubledouble' (eg PowerPC) has partial support)
 * )
 * Unlike C, there is no global 'errno' variable. Consequently, almost all of
 * these functions are pure nothrow.
 *
 * Macros:
 *      TABLE_SV = <table border="1" cellpadding="4" cellspacing="0">
 *              <caption>Special Values</caption>
 *              $0</table>
 *      SVH = $(TR $(TH $1) $(TH $2))
 *      SV  = $(TR $(TD $1) $(TD $2))
 *      TH3 = $(TR $(TH $1) $(TH $2) $(TH $3))
 *      TD3 = $(TR $(TD $1) $(TD $2) $(TD $3))
 *      TABLE_DOMRG = <table border="1" cellpadding="4" cellspacing="0">
 *              $(SVH Domain X, Range Y)
                $(SV $1, $2)
 *              </table>
 *      DOMAIN=$1
 *      RANGE=$1

 *      NAN = $(RED NAN)
 *      SUP = <span style="vertical-align:super;font-size:smaller">$0</span>
 *      GAMMA = &#915;
 *      THETA = &theta;
 *      INTEGRAL = &#8747;
 *      INTEGRATE = $(BIG &#8747;<sub>$(SMALL $1)</sub><sup>$2</sup>)
 *      POWER = $1<sup>$2</sup>
 *      SUB = $1<sub>$2</sub>
 *      BIGSUM = $(BIG &Sigma; <sup>$2</sup><sub>$(SMALL $1)</sub>)
 *      CHOOSE = $(BIG &#40;) <sup>$(SMALL $1)</sup><sub>$(SMALL $2)</sub> $(BIG &#41;)
 *      PLUSMN = &plusmn;
 *      INFIN = &infin;
 *      PLUSMNINF = &plusmn;&infin;
 *      PI = &pi;
 *      LT = &lt;
 *      GT = &gt;
 *      SQRT = &radic;
 *      HALF = &frac12;
 *
 * Copyright: Copyright The D Language Foundation 2000 - 2011.
 *            D implementations of tan, atan, atan2, exp, expm1, exp2, log, log10, log1p,
 *            log2, floor, ceil and lrint functions are based on the CEPHES math library,
 *            which is Copyright (C) 2001 Stephen L. Moshier $(LT)steve@moshier.net$(GT)
 *            and are incorporated herein by permission of the author.  The author
 *            reserves the right to distribute this material elsewhere under different
 *            copying permissions.  These modifications are distributed here under
 *            the following terms:
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   $(HTTP digitalmars.com, Walter Bright), Don Clugston,
 *            Conversion of CEPHES math library to D by Iain Buclaw and David Nadlinger
 * Source: $(PHOBOSSRC std/math.d)
 */
module std.math;

static import core.math;
static import core.stdc.math;
static import core.stdc.fenv;
import std.traits :  CommonType, isFloatingPoint, isIntegral, isNumeric,
    isSigned, isUnsigned, Largest, Unqual;

// @@@DEPRECATED_2.102@@@
// Note: Exposed accidentally, should be deprecated / removed
deprecated("std.meta.AliasSeq was unintentionally available from std.math "
           ~ "and will be removed after 2.102. Please import std.meta instead")
public import std.meta : AliasSeq;

version (DigitalMars)
{
    version = INLINE_YL2X;        // x87 has opcodes for these
}

version (X86)       version = X86_Any;
version (X86_64)    version = X86_Any;
version (PPC)       version = PPC_Any;
version (PPC64)     version = PPC_Any;
version (MIPS32)    version = MIPS_Any;
version (MIPS64)    version = MIPS_Any;
version (AArch64)   version = ARM_Any;
version (ARM)       version = ARM_Any;
version (S390)      version = IBMZ_Any;
version (SPARC)     version = SPARC_Any;
version (SPARC64)   version = SPARC_Any;
version (SystemZ)   version = IBMZ_Any;
version (RISCV32)   version = RISCV_Any;
version (RISCV64)   version = RISCV_Any;

version (D_InlineAsm_X86)    version = InlineAsm_X86_Any;
version (D_InlineAsm_X86_64) version = InlineAsm_X86_Any;

version (InlineAsm_X86_Any) version = InlineAsm_X87;
version (InlineAsm_X87)
{
    static assert(real.mant_dig == 64);
    version (CRuntime_Microsoft) version = InlineAsm_X87_MSVC;
}

version (X86_64) version = StaticallyHaveSSE;
version (X86) version (OSX) version = StaticallyHaveSSE;

version (StaticallyHaveSSE)
{
    private enum bool haveSSE = true;
}
else version (X86)
{
    static import core.cpuid;
    private alias haveSSE = core.cpuid.sse;
}

version (D_SoftFloat)
{
    // Some soft float implementations may support IEEE floating flags.
    // The implementation here supports hardware flags only and is so currently
    // only available for supported targets.
}
else version (X86_Any)   version = IeeeFlagsSupport;
else version (PPC_Any)   version = IeeeFlagsSupport;
else version (RISCV_Any) version = IeeeFlagsSupport;
else version (MIPS_Any)  version = IeeeFlagsSupport;
else version (ARM_Any)   version = IeeeFlagsSupport;

// Struct FloatingPointControl is only available if hardware FP units are available.
version (D_HardFloat)
{
    // FloatingPointControl.clearExceptions() depends on version IeeeFlagsSupport
    version (IeeeFlagsSupport) version = FloatingPointControlSupport;
}

version (StdUnittest) private
{
    static if (real.sizeof > double.sizeof)
        enum uint useDigits = 16;
    else
        enum uint useDigits = 15;

    /******************************************
     * Compare floating point numbers to n decimal digits of precision.
     * Returns:
     *  1       match
     *  0       nomatch
     */

    private bool equalsDigit(real x, real y, uint ndigits) @safe nothrow @nogc
    {
        import core.stdc.stdio : sprintf;

        if (signbit(x) != signbit(y))
            return 0;

        if (isInfinity(x) && isInfinity(y))
            return 1;
        if (isInfinity(x) || isInfinity(y))
            return 0;

        if (isNaN(x) && isNaN(y))
            return 1;
        if (isNaN(x) || isNaN(y))
            return 0;

        char[30] bufx;
        char[30] bufy;
        assert(ndigits < bufx.length);

        int ix;
        int iy;
        version (CRuntime_Microsoft)
            alias real_t = double;
        else
            alias real_t = real;

        () @trusted {
            ix = sprintf(bufx.ptr, is(real_t == real) ? "%.*Lg" : "%.*g", ndigits, cast(real_t) x);
            iy = sprintf(bufy.ptr, is(real_t == real) ? "%.*Lg" : "%.*g", ndigits, cast(real_t) y);
        } ();

        assert(ix < bufx.length && ix > 0);
        assert(ix < bufy.length && ix > 0);

        return bufx[0 .. ix] == bufy[0 .. iy];
    }
}


// Values obtained from Wolfram Alpha. 116 bits ought to be enough for anybody.
// Wolfram Alpha LLC. 2011. Wolfram|Alpha. http://www.wolframalpha.com/input/?i=e+in+base+16 (access July 6, 2011).
enum real E =          0x1.5bf0a8b1457695355fb8ac404e7a8p+1L; /** e = 2.718281... */
enum real LOG2T =      0x1.a934f0979a3715fc9257edfe9b5fbp+1L; /** $(SUB log, 2)10 = 3.321928... */
enum real LOG2E =      0x1.71547652b82fe1777d0ffda0d23a8p+0L; /** $(SUB log, 2)e = 1.442695... */
enum real LOG2 =       0x1.34413509f79fef311f12b35816f92p-2L; /** $(SUB log, 10)2 = 0.301029... */
enum real LOG10E =     0x1.bcb7b1526e50e32a6ab7555f5a67cp-2L; /** $(SUB log, 10)e = 0.434294... */
enum real LN2 =        0x1.62e42fefa39ef35793c7673007e5fp-1L; /** ln 2  = 0.693147... */
enum real LN10 =       0x1.26bb1bbb5551582dd4adac5705a61p+1L; /** ln 10 = 2.302585... */
enum real PI =         0x1.921fb54442d18469898cc51701b84p+1L; /** &pi; = 3.141592... */
enum real PI_2 =       PI/2;                                  /** $(PI) / 2 = 1.570796... */
enum real PI_4 =       PI/4;                                  /** $(PI) / 4 = 0.785398... */
enum real M_1_PI =     0x1.45f306dc9c882a53f84eafa3ea69cp-2L; /** 1 / $(PI) = 0.318309... */
enum real M_2_PI =     2*M_1_PI;                              /** 2 / $(PI) = 0.636619... */
enum real M_2_SQRTPI = 0x1.20dd750429b6d11ae3a914fed7fd8p+0L; /** 2 / $(SQRT)$(PI) = 1.128379... */
enum real SQRT2 =      0x1.6a09e667f3bcc908b2fb1366ea958p+0L; /** $(SQRT)2 = 1.414213... */
enum real SQRT1_2 =    SQRT2/2;                               /** $(SQRT)$(HALF) = 0.707106... */
// Note: Make sure the magic numbers in compiler backend for x87 match these.

/***********************************
 * Calculates the absolute value of a number.
 *
 * Params:
 *     Num = (template parameter) type of number
 *       x = real number value
 *
 * Returns:
 *     The absolute value of the number. If floating-point or integral,
 *     the return type will be the same as the input.
 *
 * Limitations:
 *     Does not work correctly for signed intergal types and value `Num`.min.
 */
auto abs(Num)(Num x) @nogc pure nothrow
if ((is(immutable Num == immutable short) || is(immutable Num == immutable byte)) ||
    (is(typeof(Num.init >= 0)) && is(typeof(-Num.init))))
{
    static if (isFloatingPoint!(Num))
        return fabs(x);
    else
    {
        static if (is(immutable Num == immutable short) || is(immutable Num == immutable byte))
            return x >= 0 ? x : cast(Num) -int(x);
        else
            return x >= 0 ? x : -x;
    }
}

/// ditto
@safe pure nothrow @nogc unittest
{
    assert(isIdentical(abs(-0.0L), 0.0L));
    assert(isNaN(abs(real.nan)));
    assert(abs(-real.infinity) == real.infinity);
    assert(abs(-56) == 56);
    assert(abs(2321312L)  == 2321312L);
}

@safe pure nothrow @nogc unittest
{
    short s = -8;
    byte b = -8;
    assert(abs(s) == 8);
    assert(abs(b) == 8);
    immutable(byte) c = -8;
    assert(abs(c) == 8);
}

@safe pure nothrow @nogc unittest
{
    import std.meta : AliasSeq;
    static foreach (T; AliasSeq!(float, double, real))
    {{
        T f = 3;
        assert(abs(f) == f);
        assert(abs(-f) == f);
    }}
}

// see https://issues.dlang.org/show_bug.cgi?id=20205
// to avoid falling into the trap again
@safe pure nothrow @nogc unittest
{
    assert(50 - abs(-100) == -50);
}

// https://issues.dlang.org/show_bug.cgi?id=19162
@safe unittest
{
    struct Vector(T, int size)
    {
        T x, y, z;
    }

    static auto abs(T, int size)(auto ref const Vector!(T, size) v)
    {
        return v;
    }
    Vector!(int, 3) v;
    assert(abs(v) == v);
}

/***********************************
 * Returns cosine of x. x is in radians.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH cos(x)) $(TH invalid?))
 *      $(TR $(TD $(NAN))            $(TD $(NAN)) $(TD yes)     )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(NAN)) $(TD yes)     )
 *      )
 * Bugs:
 *      Results are undefined if |x| >= $(POWER 2,64).
 */
pragma(inline, true)
real cos(real x) @safe pure nothrow @nogc { return core.math.cos(x); }
///ditto
pragma(inline, true)
double cos(double x) @safe pure nothrow @nogc { return core.math.cos(x); }
///ditto
pragma(inline, true)
float cos(float x) @safe pure nothrow @nogc { return core.math.cos(x); }

///
@safe unittest
{
    assert(cos(0.0) == 1.0);
    assert(cos(1.0).isClose(0.5403023059));
    assert(cos(3.0).isClose(-0.9899924966));
}

@safe unittest
{
    real function(real) pcos = &cos;
    assert(pcos != null);
}

/***********************************
 * Returns $(HTTP en.wikipedia.org/wiki/Sine, sine) of x. x is in $(HTTP en.wikipedia.org/wiki/Radian, radians).
 *
 *      $(TABLE_SV
 *      $(TH3 x           ,  sin(x)      ,  invalid?)
 *      $(TD3 $(NAN)      ,  $(NAN)      ,  yes     )
 *      $(TD3 $(PLUSMN)0.0,  $(PLUSMN)0.0,  no      )
 *      $(TD3 $(PLUSMNINF),  $(NAN)      ,  yes     )
 *      )
 *
 * Params:
 *      x = angle in radians (not degrees)
 * Returns:
 *      sine of x
 * See_Also:
 *      $(MYREF cos), $(MYREF tan), $(MYREF asin)
 * Bugs:
 *      Results are undefined if |x| >= $(POWER 2,64).
 */
pragma(inline, true)
real sin(real x) @safe pure nothrow @nogc { return core.math.sin(x); }
///ditto
pragma(inline, true)
double sin(double x) @safe pure nothrow @nogc { return core.math.sin(x); }
///ditto
pragma(inline, true)
float sin(float x) @safe pure nothrow @nogc { return core.math.sin(x); }

///
@safe unittest
{
    import std.math : sin, PI;
    import std.stdio : writefln;

    void someFunc()
    {
      real x = 30.0;
      auto result = sin(x * (PI / 180)); // convert degrees to radians
      writefln("The sine of %s degrees is %s", x, result);
    }
}

@safe unittest
{
    real function(real) psin = &sin;
    assert(psin != null);
}

/****************************************************************************
 * Returns tangent of x. x is in radians.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)             $(TH tan(x))       $(TH invalid?))
 *      $(TR $(TD $(NAN))        $(TD $(NAN))       $(TD yes))
 *      $(TR $(TD $(PLUSMN)0.0)  $(TD $(PLUSMN)0.0) $(TD no))
 *      $(TR $(TD $(PLUSMNINF))  $(TD $(NAN))       $(TD yes))
 *      )
 */
pragma(inline, true)
real tan(real x) @safe pure nothrow @nogc
{
    version (InlineAsm_X87)
    {
        if (!__ctfe)
            return tanAsm(x);
    }
    return tanImpl(x);
}

/// ditto
pragma(inline, true)
double tan(double x) @safe pure nothrow @nogc { return __ctfe ? cast(double) tan(cast(real) x) : tanImpl(x); }

/// ditto
pragma(inline, true)
float tan(float x) @safe pure nothrow @nogc { return __ctfe ? cast(float) tan(cast(real) x) : tanImpl(x); }

///
@safe unittest
{
    assert(isIdentical(tan(0.0), 0.0));
    assert(tan(PI).isClose(0, 0.0, 1e-10));
    assert(tan(PI / 3).isClose(sqrt(3.0)));
}

version (InlineAsm_X87)
private real tanAsm(real x) @trusted pure nothrow @nogc
{
    version (X86)
    {
    asm pure nothrow @nogc
    {
        fld     x[EBP]                  ; // load theta
        fxam                            ; // test for oddball values
        fstsw   AX                      ;
        sahf                            ;
        jc      trigerr                 ; // x is NAN, infinity, or empty
                                          // 387's can handle subnormals
SC18:   fptan                           ;
        fstsw   AX                      ;
        sahf                            ;
        jnp     Clear1                  ; // C2 = 1 (x is out of range)

        // Do argument reduction to bring x into range
        fldpi                           ;
        fxch                            ;
SC17:   fprem1                          ;
        fstsw   AX                      ;
        sahf                            ;
        jp      SC17                    ;
        fstp    ST(1)                   ; // remove pi from stack
        jmp     SC18                    ;

trigerr:
        jnp     Lret                    ; // if theta is NAN, return theta
        fstp    ST(0)                   ; // dump theta
    }
    return real.nan;

Clear1: asm pure nothrow @nogc{
        fstp    ST(0)                   ; // dump X, which is always 1
    }

Lret: {}
    }
    else version (X86_64)
    {
        version (Win64)
        {
            asm pure nothrow @nogc
            {
                fld     real ptr [RCX]  ; // load theta
            }
        }
        else
        {
            asm pure nothrow @nogc
            {
                fld     x[RBP]          ; // load theta
            }
        }
    asm pure nothrow @nogc
    {
        fxam                            ; // test for oddball values
        fstsw   AX                      ;
        test    AH,1                    ;
        jnz     trigerr                 ; // x is NAN, infinity, or empty
                                          // 387's can handle subnormals
SC18:   fptan                           ;
        fstsw   AX                      ;
        test    AH,4                    ;
        jz      Clear1                  ; // C2 = 1 (x is out of range)

        // Do argument reduction to bring x into range
        fldpi                           ;
        fxch                            ;
SC17:   fprem1                          ;
        fstsw   AX                      ;
        test    AH,4                    ;
        jnz     SC17                    ;
        fstp    ST(1)                   ; // remove pi from stack
        jmp     SC18                    ;

trigerr:
        test    AH,4                    ;
        jz      Lret                    ; // if theta is NAN, return theta
        fstp    ST(0)                   ; // dump theta
    }
    return real.nan;

Clear1: asm pure nothrow @nogc{
        fstp    ST(0)                   ; // dump X, which is always 1
    }

Lret: {}
    }
    else
        static assert(0);
}

private T tanImpl(T)(T x) @safe pure nothrow @nogc
{
    // Coefficients for tan(x) and PI/4 split into three parts.
    enum realFormat = floatTraits!T.realFormat;
    static if (realFormat == RealFormat.ieeeQuadruple)
    {
        static immutable T[6] P = [
            2.883414728874239697964612246732416606301E10L,
            -2.307030822693734879744223131873392503321E9L,
            5.160188250214037865511600561074819366815E7L,
            -4.249691853501233575668486667664718192660E5L,
            1.272297782199996882828849455156962260810E3L,
            -9.889929415807650724957118893791829849557E-1L
        ];
        static immutable T[7] Q = [
            8.650244186622719093893836740197250197602E10L,
            -4.152206921457208101480801635640958361612E10L,
            2.758476078803232151774723646710890525496E9L,
            -5.733709132766856723608447733926138506824E7L,
            4.529422062441341616231663543669583527923E5L,
            -1.317243702830553658702531997959756728291E3L,
            1.0
        ];

        enum T P1 =
            7.853981633974483067550664827649598009884357452392578125E-1L;
        enum T P2 =
            2.8605943630549158983813312792950660807511260829685741796657E-18L;
        enum T P3 =
            2.1679525325309452561992610065108379921905808E-35L;
    }
    else static if (realFormat == RealFormat.ieeeExtended ||
                    realFormat == RealFormat.ieeeDouble)
    {
        static immutable T[3] P = [
           -1.7956525197648487798769E7L,
            1.1535166483858741613983E6L,
           -1.3093693918138377764608E4L,
        ];
        static immutable T[5] Q = [
           -5.3869575592945462988123E7L,
            2.5008380182335791583922E7L,
           -1.3208923444021096744731E6L,
            1.3681296347069295467845E4L,
            1.0000000000000000000000E0L,
        ];

        enum T P1 = 7.853981554508209228515625E-1L;
        enum T P2 = 7.946627356147928367136046290398E-9L;
        enum T P3 = 3.061616997868382943065164830688E-17L;
    }
    else static if (realFormat == RealFormat.ieeeSingle)
    {
        static immutable T[6] P = [
            3.33331568548E-1,
            1.33387994085E-1,
            5.34112807005E-2,
            2.44301354525E-2,
            3.11992232697E-3,
            9.38540185543E-3,
        ];

        enum T P1 = 0.78515625;
        enum T P2 = 2.4187564849853515625E-4;
        enum T P3 = 3.77489497744594108E-8;
    }
    else
        static assert(0, "no coefficients for tan()");

    // Special cases.
    if (x == cast(T) 0.0 || isNaN(x))
        return x;
    if (isInfinity(x))
        return T.nan;

    // Make argument positive but save the sign.
    bool sign = false;
    if (signbit(x))
    {
        sign = true;
        x = -x;
    }

    // Compute x mod PI/4.
    static if (realFormat == RealFormat.ieeeSingle)
    {
        enum T FOPI = 4 / PI;
        int j = cast(int) (FOPI * x);
        T y = j;
        T z;
    }
    else
    {
        T y = floor(x / cast(T) PI_4);
        // Strip high bits of integer part.
        enum T highBitsFactor = (realFormat == RealFormat.ieeeDouble ? 0x1p3 : 0x1p4);
        enum T highBitsInv = 1.0 / highBitsFactor;
        T z = y * highBitsInv;
        // Compute y - 2^numHighBits * (y / 2^numHighBits).
        z = y - highBitsFactor * floor(z);

        // Integer and fraction part modulo one octant.
        int j = cast(int)(z);
    }

    // Map zeros and singularities to origin.
    if (j & 1)
    {
        j += 1;
        y += cast(T) 1.0;
    }

    z = ((x - y * P1) - y * P2) - y * P3;
    const T zz = z * z;

    enum T zzThreshold = (realFormat == RealFormat.ieeeSingle ? 1.0e-4L :
                          realFormat == RealFormat.ieeeDouble ? 1.0e-14L : 1.0e-20L);
    if (zz > zzThreshold)
    {
        static if (realFormat == RealFormat.ieeeSingle)
            y = z + z * (zz * poly(zz, P));
        else
            y = z + z * (zz * poly(zz, P) / poly(zz, Q));
    }
    else
        y = z;

    if (j & 2)
        y = (cast(T) -1.0) / y;

    return (sign) ? -y : y;
}

@safe @nogc nothrow unittest
{
    static void testTan(T)()
    {
        // ±0
        const T zero = 0.0;
        assert(isIdentical(tan(zero), zero));
        assert(isIdentical(tan(-zero), -zero));
        // ±∞
        const T inf = T.infinity;
        assert(isNaN(tan(inf)));
        assert(isNaN(tan(-inf)));
        // NaN
        const T specialNaN = NaN(0x0123L);
        assert(isIdentical(tan(specialNaN), specialNaN));

        static immutable T[2][] vals =
        [
            // angle, tan
            [   .5,  .54630248984],
            [   1,   1.5574077247],
            [   1.5, 14.101419947],
            [   2,  -2.1850398633],
            [   2.5,-.74702229724],
            [   3,  -.14254654307],
            [   3.5, .37458564016],
            [   4,   1.1578212823],
            [   4.5, 4.6373320546],
            [   5,  -3.3805150062],
            [   5.5,-.99558405221],
            [   6,  -.29100619138],
            [   6.5, .22027720035],
            [   10,  .64836082746],

            // special angles
            [   PI_4,   1],
            //[   PI_2,   T.infinity], // PI_2 is not _exactly_ pi/2.
            [   3*PI_4, -1],
            [   PI,     0],
            [   5*PI_4, 1],
            //[   3*PI_2, -T.infinity],
            [   7*PI_4, -1],
            [   2*PI,   0],
         ];

        foreach (ref val; vals)
        {
            T x = val[0];
            T r = val[1];
            T t = tan(x);

            //printf("tan(%Lg) = %Lg, should be %Lg\n", cast(real) x, cast(real) t, cast(real) r);
            assert(isClose(r, t, CommonDefaultFor!(T,T), CommonDefaultFor!(T,T)));

            x = -x;
            r = -r;
            t = tan(x);
            //printf("tan(%Lg) = %Lg, should be %Lg\n", cast(real) x, cast(real) t, cast(real) r);
            assert(isClose(r, t, CommonDefaultFor!(T,T), CommonDefaultFor!(T,T)));
        }
    }

    import std.meta : AliasSeq;
    foreach (T; AliasSeq!(real, double, float))
        testTan!T();

    assert(equalsDigit(tan(PI / 3), std.math.sqrt(3.0L), useDigits));
}

/***************
 * Calculates the arc cosine of x,
 * returning a value ranging from 0 to $(PI).
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)         $(TH acos(x)) $(TH invalid?))
 *      $(TR $(TD $(GT)1.0)  $(TD $(NAN))  $(TD yes))
 *      $(TR $(TD $(LT)-1.0) $(TD $(NAN))  $(TD yes))
 *      $(TR $(TD $(NAN))    $(TD $(NAN))  $(TD yes))
 *  )
 */
real acos(real x) @safe pure nothrow @nogc
{
    return atan2(sqrt(1-x*x), x);
}

/// ditto
double acos(double x) @safe pure nothrow @nogc { return acos(cast(real) x); }

/// ditto
float acos(float x) @safe pure nothrow @nogc  { return acos(cast(real) x); }

///
@safe unittest
{
    assert(acos(0.0).isClose(1.570796327));
    assert(acos(0.5).isClose(std.math.PI / 3));
    assert(acos(PI).isNaN);
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(acos(0.5), std.math.PI / 3, useDigits));
}

/***************
 * Calculates the arc sine of x,
 * returning a value ranging from -$(PI)/2 to $(PI)/2.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)            $(TH asin(x))      $(TH invalid?))
 *      $(TR $(TD $(PLUSMN)0.0) $(TD $(PLUSMN)0.0) $(TD no))
 *      $(TR $(TD $(GT)1.0)     $(TD $(NAN))       $(TD yes))
 *      $(TR $(TD $(LT)-1.0)    $(TD $(NAN))       $(TD yes))
 *  )
 */
real asin(real x) @safe pure nothrow @nogc
{
    return atan2(x, sqrt(1-x*x));
}

/// ditto
double asin(double x) @safe pure nothrow @nogc { return asin(cast(real) x); }

/// ditto
float asin(float x) @safe pure nothrow @nogc  { return asin(cast(real) x); }

///
@safe unittest
{
    assert(isIdentical(asin(0.0), 0.0));
    assert(asin(0.5).isClose(PI / 6));
    assert(asin(PI).isNaN);
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(asin(0.5), PI / 6, useDigits));
}

/***************
 * Calculates the arc tangent of x,
 * returning a value ranging from -$(PI)/2 to $(PI)/2.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH atan(x))      $(TH invalid?))
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD $(PLUSMN)0.0) $(TD no))
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(NAN))       $(TD yes))
 *  )
 */
pragma(inline, true)
real atan(real x) @safe pure nothrow @nogc
{
    version (InlineAsm_X87)
    {
        if (!__ctfe)
            return atan2Asm(x, 1.0L);
    }
    return atanImpl(x);
}

/// ditto
pragma(inline, true)
double atan(double x) @safe pure nothrow @nogc { return __ctfe ? cast(double) atan(cast(real) x) : atanImpl(x); }

/// ditto
pragma(inline, true)
float atan(float x) @safe pure nothrow @nogc { return __ctfe ? cast(float) atan(cast(real) x) : atanImpl(x); }

///
@safe unittest
{
    assert(isIdentical(atan(0.0), 0.0));
    assert(atan(sqrt(3.0)).isClose(PI / 3));
}

private T atanImpl(T)(T x) @safe pure nothrow @nogc
{
    // Coefficients for atan(x)
    enum realFormat = floatTraits!T.realFormat;
    static if (realFormat == RealFormat.ieeeQuadruple)
    {
        static immutable T[9] P = [
            -6.880597774405940432145577545328795037141E2L,
            -2.514829758941713674909996882101723647996E3L,
            -3.696264445691821235400930243493001671932E3L,
            -2.792272753241044941703278827346430350236E3L,
            -1.148164399808514330375280133523543970854E3L,
            -2.497759878476618348858065206895055957104E2L,
            -2.548067867495502632615671450650071218995E1L,
            -8.768423468036849091777415076702113400070E-1L,
            -6.635810778635296712545011270011752799963E-4L
        ];
        static immutable T[9] Q = [
            2.064179332321782129643673263598686441900E3L,
            8.782996876218210302516194604424986107121E3L,
            1.547394317752562611786521896296215170819E4L,
            1.458510242529987155225086911411015961174E4L,
            7.928572347062145288093560392463784743935E3L,
            2.494680540950601626662048893678584497900E3L,
            4.308348370818927353321556740027020068897E2L,
            3.566239794444800849656497338030115886153E1L,
            1.0
        ];
    }
    else static if (realFormat == RealFormat.ieeeExtended)
    {
        static immutable T[5] P = [
           -5.0894116899623603312185E1L,
           -9.9988763777265819915721E1L,
           -6.3976888655834347413154E1L,
           -1.4683508633175792446076E1L,
           -8.6863818178092187535440E-1L,
        ];
        static immutable T[6] Q = [
            1.5268235069887081006606E2L,
            3.9157570175111990631099E2L,
            3.6144079386152023162701E2L,
            1.4399096122250781605352E2L,
            2.2981886733594175366172E1L,
            1.0000000000000000000000E0L,
        ];
    }
    else static if (realFormat == RealFormat.ieeeDouble)
    {
        static immutable T[5] P = [
           -6.485021904942025371773E1L,
           -1.228866684490136173410E2L,
           -7.500855792314704667340E1L,
           -1.615753718733365076637E1L,
           -8.750608600031904122785E-1L,
        ];
        static immutable T[6] Q = [
            1.945506571482613964425E2L,
            4.853903996359136964868E2L,
            4.328810604912902668951E2L,
            1.650270098316988542046E2L,
            2.485846490142306297962E1L,
            1.000000000000000000000E0L,
        ];

        enum T MOREBITS = 6.123233995736765886130E-17L;
    }
    else static if (realFormat == RealFormat.ieeeSingle)
    {
        static immutable T[4] P = [
           -3.33329491539E-1,
            1.99777106478E-1,
           -1.38776856032E-1,
            8.05374449538E-2,
        ];
    }
    else
        static assert(0, "no coefficients for atan()");

    // tan(PI/8)
    enum T TAN_PI_8 = 0.414213562373095048801688724209698078569672L;
    // tan(3 * PI/8)
    enum T TAN3_PI_8 = 2.414213562373095048801688724209698078569672L;

    // Special cases.
    if (x == cast(T) 0.0)
        return x;
    if (isInfinity(x))
        return copysign(cast(T) PI_2, x);

    // Make argument positive but save the sign.
    bool sign = false;
    if (signbit(x))
    {
        sign = true;
        x = -x;
    }

    static if (realFormat == RealFormat.ieeeDouble) // special case for double precision
    {
        short flag = 0;
        T y;
        if (x > TAN3_PI_8)
        {
            y = PI_2;
            flag = 1;
            x = -(1.0 / x);
        }
        else if (x <= 0.66)
        {
            y = 0.0;
        }
        else
        {
            y = PI_4;
            flag = 2;
            x = (x - 1.0)/(x + 1.0);
        }

        T z = x * x;
        z = z * poly(z, P) / poly(z, Q);
        z = x * z + x;
        if (flag == 2)
            z += 0.5 * MOREBITS;
        else if (flag == 1)
            z += MOREBITS;
        y = y + z;
    }
    else
    {
        // Range reduction.
        T y;
        if (x > TAN3_PI_8)
        {
            y = PI_2;
            x = -((cast(T) 1.0) / x);
        }
        else if (x > TAN_PI_8)
        {
            y = PI_4;
            x = (x - cast(T) 1.0)/(x + cast(T) 1.0);
        }
        else
            y = 0.0;

        // Rational form in x^^2.
        const T z = x * x;
        static if (realFormat == RealFormat.ieeeSingle)
            y += poly(z, P) * z * x + x;
        else
            y = y + (poly(z, P) / poly(z, Q)) * z * x + x;
    }

    return (sign) ? -y : y;
}

@safe @nogc nothrow unittest
{
    static void testAtan(T)()
    {
        // ±0
        const T zero = 0.0;
        assert(isIdentical(atan(zero), zero));
        assert(isIdentical(atan(-zero), -zero));
        // ±∞
        const T inf = T.infinity;
        assert(isClose(atan(inf), cast(T) PI_2));
        assert(isClose(atan(-inf), cast(T) -PI_2));
        // NaN
        const T specialNaN = NaN(0x0123L);
        assert(isIdentical(atan(specialNaN), specialNaN));

        static immutable T[2][] vals =
        [
            // x, atan(x)
            [ 0.25, 0.24497866313 ],
            [ 0.5,  0.46364760900 ],
            [ 1,    PI_4          ],
            [ 1.5,  0.98279372325 ],
            [ 10,   1.47112767430 ],
        ];

        foreach (ref val; vals)
        {
            T x = val[0];
            T r = val[1];
            T a = atan(x);

            //printf("atan(%Lg) = %Lg, should be %Lg\n", cast(real) x, cast(real) a, cast(real) r);
            assert(isClose(r, a, CommonDefaultFor!(T,T), CommonDefaultFor!(T,T)));

            x = -x;
            r = -r;
            a = atan(x);
            //printf("atan(%Lg) = %Lg, should be %Lg\n", cast(real) x, cast(real) a, cast(real) r);
            assert(isClose(r, a, CommonDefaultFor!(T,T), CommonDefaultFor!(T,T)));
        }
    }

    import std.meta : AliasSeq;
    foreach (T; AliasSeq!(real, double, float))
        testAtan!T();

    assert(equalsDigit(atan(std.math.sqrt(3.0L)), PI / 3, useDigits));
}

/***************
 * Calculates the arc tangent of y / x,
 * returning a value ranging from -$(PI) to $(PI).
 *
 *      $(TABLE_SV
 *      $(TR $(TH y)                 $(TH x)            $(TH atan(y, x)))
 *      $(TR $(TD $(NAN))            $(TD anything)     $(TD $(NAN)) )
 *      $(TR $(TD anything)          $(TD $(NAN))       $(TD $(NAN)) )
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD $(GT)0.0)     $(TD $(PLUSMN)0.0) )
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD +0.0)         $(TD $(PLUSMN)0.0) )
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD $(LT)0.0)     $(TD $(PLUSMN)$(PI)))
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD -0.0)         $(TD $(PLUSMN)$(PI)))
 *      $(TR $(TD $(GT)0.0)          $(TD $(PLUSMN)0.0) $(TD $(PI)/2) )
 *      $(TR $(TD $(LT)0.0)          $(TD $(PLUSMN)0.0) $(TD -$(PI)/2) )
 *      $(TR $(TD $(GT)0.0)          $(TD $(INFIN))     $(TD $(PLUSMN)0.0) )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD anything)     $(TD $(PLUSMN)$(PI)/2))
 *      $(TR $(TD $(GT)0.0)          $(TD -$(INFIN))    $(TD $(PLUSMN)$(PI)) )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(INFIN))     $(TD $(PLUSMN)$(PI)/4))
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD -$(INFIN))    $(TD $(PLUSMN)3$(PI)/4))
 *      )
 */
pragma(inline, true)
real atan2(real y, real x) @trusted pure nothrow @nogc // TODO: @safe
{
    version (InlineAsm_X87)
    {
        if (!__ctfe)
            return atan2Asm(y, x);
    }
    return atan2Impl(y, x);
}

/// ditto
pragma(inline, true)
double atan2(double y, double x) @safe pure nothrow @nogc
{
    return __ctfe ? cast(double) atan2(cast(real) y, cast(real) x) : atan2Impl(y, x);
}

/// ditto
pragma(inline, true)
float atan2(float y, float x) @safe pure nothrow @nogc
{
    return __ctfe ? cast(float) atan2(cast(real) y, cast(real) x) : atan2Impl(y, x);
}

///
@safe unittest
{
    assert(atan2(1.0, sqrt(3.0)).isClose(PI / 6));
}

version (InlineAsm_X87)
private real atan2Asm(real y, real x) @trusted pure nothrow @nogc
{
    version (Win64)
    {
        asm pure nothrow @nogc {
            naked;
            fld real ptr [RDX]; // y
            fld real ptr [RCX]; // x
            fpatan;
            ret;
        }
    }
    else
    {
        asm pure nothrow @nogc {
            fld y;
            fld x;
            fpatan;
        }
    }
}

private T atan2Impl(T)(T y, T x) @safe pure nothrow @nogc
{
    // Special cases.
    if (isNaN(x) || isNaN(y))
        return T.nan;
    if (y == cast(T) 0.0)
    {
        if (x >= 0 && !signbit(x))
            return copysign(0, y);
        else
            return copysign(cast(T) PI, y);
    }
    if (x == cast(T) 0.0)
        return copysign(cast(T) PI_2, y);
    if (isInfinity(x))
    {
        if (signbit(x))
        {
            if (isInfinity(y))
                return copysign(3 * cast(T) PI_4, y);
            else
                return copysign(cast(T) PI, y);
        }
        else
        {
            if (isInfinity(y))
                return copysign(cast(T) PI_4, y);
            else
                return copysign(cast(T) 0.0, y);
        }
    }
    if (isInfinity(y))
        return copysign(cast(T) PI_2, y);

    // Call atan and determine the quadrant.
    T z = atan(y / x);

    if (signbit(x))
    {
        if (signbit(y))
            z = z - cast(T) PI;
        else
            z = z + cast(T) PI;
    }

    if (z == cast(T) 0.0)
        return copysign(z, y);

    return z;
}

@safe @nogc nothrow unittest
{
    static void testAtan2(T)()
    {
        // NaN
        const T nan = T.nan;
        assert(isNaN(atan2(nan, cast(T) 1)));
        assert(isNaN(atan2(cast(T) 1, nan)));

        const T inf = T.infinity;
        static immutable T[3][] vals =
        [
            // y, x, atan2(y, x)

            // ±0
            [  0.0,  1.0,  0.0 ],
            [ -0.0,  1.0, -0.0 ],
            [  0.0,  0.0,  0.0 ],
            [ -0.0,  0.0, -0.0 ],
            [  0.0, -1.0,  PI ],
            [ -0.0, -1.0, -PI ],
            [  0.0, -0.0,  PI ],
            [ -0.0, -0.0, -PI ],
            [  1.0,  0.0,  PI_2 ],
            [  1.0, -0.0,  PI_2 ],
            [ -1.0,  0.0, -PI_2 ],
            [ -1.0, -0.0, -PI_2 ],

            // ±∞
            [  1.0,  inf,  0.0 ],
            [ -1.0,  inf, -0.0 ],
            [  1.0, -inf,  PI ],
            [ -1.0, -inf, -PI ],
            [  inf,  1.0,  PI_2 ],
            [  inf, -1.0,  PI_2 ],
            [ -inf,  1.0, -PI_2 ],
            [ -inf, -1.0, -PI_2 ],
            [  inf,  inf,  PI_4 ],
            [ -inf,  inf, -PI_4 ],
            [  inf, -inf,  3 * PI_4 ],
            [ -inf, -inf, -3 * PI_4 ],

            [  1.0,  1.0,  PI_4 ],
            [ -2.0,  2.0, -PI_4 ],
            [  3.0, -3.0,  3 * PI_4 ],
            [ -4.0, -4.0, -3 * PI_4 ],

            [  0.75,  0.25,   1.249045772398 ],
            [ -0.5,   0.375, -0.927295218002 ],
            [  0.5,  -0.125,  1.815774989922 ],
            [ -0.75, -0.5,   -2.158798930342 ],
        ];

        foreach (ref val; vals)
        {
            const T y = val[0];
            const T x = val[1];
            const T r = val[2];
            const T a = atan2(y, x);

            //printf("atan2(%Lg, %Lg) = %Lg, should be %Lg\n", cast(real) y, cast(real) x, cast(real) a, cast(real) r);
            if (r == 0)
                assert(isIdentical(r, a)); // check sign
            else
                assert(isClose(r, a));
        }
    }

    import std.meta : AliasSeq;
    foreach (T; AliasSeq!(real, double, float))
        testAtan2!T();

    assert(equalsDigit(atan2(1.0L, std.math.sqrt(3.0L)), PI / 6, useDigits));
}

/***********************************
 * Calculates the hyperbolic cosine of x.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH cosh(x))      $(TH invalid?))
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(PLUSMN)0.0) $(TD no) )
 *      )
 */
real cosh(real x) @safe pure nothrow @nogc
{
    //  cosh = (exp(x)+exp(-x))/2.
    // The naive implementation works correctly.
    const real y = exp(x);
    return (y + 1.0/y) * 0.5;
}

/// ditto
double cosh(double x) @safe pure nothrow @nogc { return cosh(cast(real) x); }

/// ditto
float cosh(float x) @safe pure nothrow @nogc  { return cosh(cast(real) x); }

///
@safe unittest
{
    assert(cosh(0.0) == 1.0);
    assert(cosh(1.0).isClose((E + 1.0 / E) / 2));
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(cosh(1.0), (E + 1.0 / E) / 2, useDigits));
}

/***********************************
 * Calculates the hyperbolic sine of x.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH sinh(x))           $(TH invalid?))
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD $(PLUSMN)0.0)      $(TD no))
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(PLUSMN)$(INFIN)) $(TD no))
 *      )
 */
real sinh(real x) @safe pure nothrow @nogc { return _sinh(x); }

/// ditto
double sinh(double x) @safe pure nothrow @nogc { return _sinh(x); }

/// ditto
float sinh(float x) @safe pure nothrow @nogc { return _sinh(x); }

///
@safe unittest
{
    enum sinh1 = (E - 1.0 / E) / 2;
    import std.meta : AliasSeq;
    static foreach (F; AliasSeq!(float, double, real))
    {
        assert(isIdentical(sinh(F(0.0)), F(0.0)));
        assert(sinh(F(1.0)).isClose(F(sinh1)));
    }
}

private F _sinh(F)(F x)
{
    //  sinh(x) =  (exp(x)-exp(-x))/2;
    // Very large arguments could cause an overflow, but
    // the maximum value of x for which exp(x) + exp(-x)) != exp(x)
    // is x = 0.5 * (real.mant_dig) * LN2. // = 22.1807 for real80.
    if (fabs(x) > F.mant_dig * F(LN2))
    {
        return copysign(F(0.5) * exp(fabs(x)), x);
    }

    const y = expm1(x);
    return F(0.5) * y / (y+1) * (y+2);
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(sinh(1.0L), real((E - 1.0 / E) / 2), useDigits));
}
/***********************************
 * Calculates the hyperbolic tangent of x.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH tanh(x))      $(TH invalid?))
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD $(PLUSMN)0.0) $(TD no) )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(PLUSMN)1.0) $(TD no))
 *      )
 */
real tanh(real x) @safe pure nothrow @nogc { return _tanh(x); }

/// ditto
double tanh(double x) @safe pure nothrow @nogc { return _tanh(x); }

/// ditto
float tanh(float x) @safe pure nothrow @nogc { return _tanh(x); }

///
@safe unittest
{
    assert(isIdentical(tanh(0.0), 0.0));
    assert(tanh(1.0).isClose(sinh(1.0) / cosh(1.0)));
}

private F _tanh(F)(F x)
{
    //  tanh(x) = (exp(x) - exp(-x))/(exp(x)+exp(-x))
    if (fabs(x) > F.mant_dig * F(LN2))
    {
        return copysign(1, x);
    }

    const y = expm1(2*x);
    return y / (y + 2);
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(tanh(1.0L), sinh(1.0L) / cosh(1.0L), 15));
}

/***********************************
 * Calculates the inverse hyperbolic cosine of x.
 *
 *  Mathematically, acosh(x) = log(x + sqrt( x*x - 1))
 *
 * $(TABLE_DOMRG
 *    $(DOMAIN 1..$(INFIN)),
 *    $(RANGE  0..$(INFIN))
 * )
 *
 *  $(TABLE_SV
 *    $(SVH  x,     acosh(x) )
 *    $(SV  $(NAN), $(NAN) )
 *    $(SV  $(LT)1,     $(NAN) )
 *    $(SV  1,      0       )
 *    $(SV  +$(INFIN),+$(INFIN))
 *  )
 */
real acosh(real x) @safe pure nothrow @nogc { return _acosh(x); }

/// ditto
double acosh(double x) @safe pure nothrow @nogc { return _acosh(x); }

/// ditto
float acosh(float x) @safe pure nothrow @nogc { return _acosh(x); }

///
@safe @nogc nothrow unittest
{
    assert(isNaN(acosh(0.9)));
    assert(isNaN(acosh(real.nan)));
    assert(isIdentical(acosh(1.0), 0.0));
    assert(acosh(real.infinity) == real.infinity);
    assert(isNaN(acosh(0.5)));
}

private F _acosh(F)(F x) @safe pure nothrow @nogc
{
    if (x > 1/F.epsilon)
        return F(LN2) + log(x);
    else
        return log(x + sqrt(x*x - 1));
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(acosh(cosh(3.0L)), 3.0L, useDigits));
}

/***********************************
 * Calculates the inverse hyperbolic sine of x.
 *
 *  Mathematically,
 *  ---------------
 *  asinh(x) =  log( x + sqrt( x*x + 1 )) // if x >= +0
 *  asinh(x) = -log(-x + sqrt( x*x + 1 )) // if x <= -0
 *  -------------
 *
 *    $(TABLE_SV
 *    $(SVH x,                asinh(x)       )
 *    $(SV  $(NAN),           $(NAN)         )
 *    $(SV  $(PLUSMN)0,       $(PLUSMN)0      )
 *    $(SV  $(PLUSMN)$(INFIN),$(PLUSMN)$(INFIN))
 *    )
 */
real asinh(real x) @safe pure nothrow @nogc { return _asinh(x); }

/// ditto
double asinh(double x) @safe pure nothrow @nogc { return _asinh(x); }

/// ditto
float asinh(float x) @safe pure nothrow @nogc { return _asinh(x); }

///
@safe @nogc nothrow unittest
{
    assert(isIdentical(asinh(0.0), 0.0));
    assert(isIdentical(asinh(-0.0), -0.0));
    assert(asinh(real.infinity) == real.infinity);
    assert(asinh(-real.infinity) == -real.infinity);
    assert(isNaN(asinh(real.nan)));
}

private F _asinh(F)(F x)
{
    return (fabs(x) > 1 / F.epsilon)
        // beyond this point, x*x + 1 == x*x
        ? copysign(F(LN2) + log(fabs(x)), x)
        // sqrt(x*x + 1) ==  1 + x * x / ( 1 + sqrt(x*x + 1) )
        : copysign(log1p(fabs(x) + x*x / (1 + sqrt(x*x + 1)) ), x);
}

@safe unittest
{
    assert(equalsDigit(asinh(sinh(3.0L)), 3.0L, useDigits));
}

/***********************************
 * Calculates the inverse hyperbolic tangent of x,
 * returning a value from ranging from -1 to 1.
 *
 * Mathematically, atanh(x) = log( (1+x)/(1-x) ) / 2
 *
 * $(TABLE_DOMRG
 *    $(DOMAIN -$(INFIN)..$(INFIN)),
 *    $(RANGE  -1 .. 1)
 * )
 * $(BR)
 * $(TABLE_SV
 *    $(SVH  x,     acosh(x) )
 *    $(SV  $(NAN), $(NAN) )
 *    $(SV  $(PLUSMN)0, $(PLUSMN)0)
 *    $(SV  -$(INFIN), -0)
 * )
 */
real atanh(real x) @safe pure nothrow @nogc
{
    // log( (1+x)/(1-x) ) == log ( 1 + (2*x)/(1-x) )
    return  0.5 * log1p( 2 * x / (1 - x) );
}

/// ditto
double atanh(double x) @safe pure nothrow @nogc { return atanh(cast(real) x); }

/// ditto
float atanh(float x) @safe pure nothrow @nogc { return atanh(cast(real) x); }

///
@safe @nogc nothrow unittest
{
    assert(isIdentical(atanh(0.0), 0.0));
    assert(isIdentical(atanh(-0.0),-0.0));
    assert(isNaN(atanh(real.nan)));
    assert(isNaN(atanh(-real.infinity)));
    assert(atanh(0.0) == 0);
}

@safe unittest
{
    assert(equalsDigit(atanh(tanh(0.5L)), 0.5, useDigits));
}

/*****************************************
 * Returns x rounded to a long value using the current rounding mode.
 * If the integer value of x is
 * greater than long.max, the result is
 * indeterminate.
 */
pragma(inline, true)
long rndtol(real x) @nogc @safe pure nothrow { return core.math.rndtol(x); }
//FIXME
///ditto
pragma(inline, true)
long rndtol(double x) @safe pure nothrow @nogc { return rndtol(cast(real) x); }
//FIXME
///ditto
pragma(inline, true)
long rndtol(float x) @safe pure nothrow @nogc { return rndtol(cast(real) x); }

///
@safe unittest
{
    assert(rndtol(1.0) == 1L);
    assert(rndtol(1.2) == 1L);
    assert(rndtol(1.7) == 2L);
    assert(rndtol(1.0001) == 1L);
}

@safe unittest
{
    long function(real) prndtol = &rndtol;
    assert(prndtol != null);
}

/***************************************
 * Compute square root of x.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)         $(TH sqrt(x))   $(TH invalid?))
 *      $(TR $(TD -0.0)      $(TD -0.0)      $(TD no))
 *      $(TR $(TD $(LT)0.0)  $(TD $(NAN))    $(TD yes))
 *      $(TR $(TD +$(INFIN)) $(TD +$(INFIN)) $(TD no))
 *      )
 */
pragma(inline, true)
float sqrt(float x) @nogc @safe pure nothrow { return core.math.sqrt(x); }

/// ditto
pragma(inline, true)
double sqrt(double x) @nogc @safe pure nothrow { return core.math.sqrt(x); }

/// ditto
pragma(inline, true)
real sqrt(real x) @nogc @safe pure nothrow { return core.math.sqrt(x); }

///
@safe pure nothrow @nogc unittest
{
    assert(sqrt(2.0).feqrel(1.4142) > 16);
    assert(sqrt(9.0).feqrel(3.0) > 16);

    assert(isNaN(sqrt(-1.0f)));
    assert(isNaN(sqrt(-1.0)));
    assert(isNaN(sqrt(-1.0L)));
}

@safe unittest
{
    float function(float) psqrtf = &sqrt;
    assert(psqrtf != null);
    double function(double) psqrtd = &sqrt;
    assert(psqrtd != null);
    real function(real) psqrtr = &sqrt;
    assert(psqrtr != null);

    //ctfe
    enum ZX80 = sqrt(7.0f);
    enum ZX81 = sqrt(7.0);
    enum ZX82 = sqrt(7.0L);
}

/**
 * Calculates e$(SUPERSCRIPT x).
 *
 *  $(TABLE_SV
 *    $(TR $(TH x)             $(TH e$(SUPERSCRIPT x)) )
 *    $(TR $(TD +$(INFIN))     $(TD +$(INFIN)) )
 *    $(TR $(TD -$(INFIN))     $(TD +0.0)      )
 *    $(TR $(TD $(NAN))        $(TD $(NAN))    )
 *  )
 */
pragma(inline, true)
real exp(real x) @trusted pure nothrow @nogc // TODO: @safe
{
    version (InlineAsm_X87)
    {
        //  e^^x = 2^^(LOG2E*x)
        // (This is valid because the overflow & underflow limits for exp
        // and exp2 are so similar).
        if (!__ctfe)
            return exp2Asm(LOG2E*x);
    }
    return expImpl(x);
}

/// ditto
pragma(inline, true)
double exp(double x) @safe pure nothrow @nogc { return __ctfe ? cast(double) exp(cast(real) x) : expImpl(x); }

/// ditto
pragma(inline, true)
float exp(float x) @safe pure nothrow @nogc { return __ctfe ? cast(float) exp(cast(real) x) : expImpl(x); }

///
@safe unittest
{
    assert(exp(0.0) == 1.0);
    assert(exp(3.0).feqrel(E * E * E) > 16);
}

private T expImpl(T)(T x) @safe pure nothrow @nogc
{
    alias F = floatTraits!T;
    static if (F.realFormat == RealFormat.ieeeSingle)
    {
        static immutable T[6] P = [
            5.0000001201E-1,
            1.6666665459E-1,
            4.1665795894E-2,
            8.3334519073E-3,
            1.3981999507E-3,
            1.9875691500E-4,
        ];

        enum T C1 = 0.693359375;
        enum T C2 = -2.12194440e-4;

        // Overflow and Underflow limits.
        enum T OF = 88.72283905206835;
        enum T UF = -103.278929903431851103; // ln(2^-149)
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        // Coefficients for exp(x)
        static immutable T[3] P = [
            9.99999999999999999910E-1L,
            3.02994407707441961300E-2L,
            1.26177193074810590878E-4L,
        ];
        static immutable T[4] Q = [
            2.00000000000000000009E0L,
            2.27265548208155028766E-1L,
            2.52448340349684104192E-3L,
            3.00198505138664455042E-6L,
        ];

        // C1 + C2 = LN2.
        enum T C1 = 6.93145751953125E-1;
        enum T C2 = 1.42860682030941723212E-6;

        // Overflow and Underflow limits.
        enum T OF =  7.09782712893383996732E2;  // ln((1-2^-53) * 2^1024)
        enum T UF = -7.451332191019412076235E2; // ln(2^-1075)
    }
    else static if (F.realFormat == RealFormat.ieeeExtended ||
                    F.realFormat == RealFormat.ieeeExtended53)
    {
        // Coefficients for exp(x)
        static immutable T[3] P = [
            9.9999999999999999991025E-1L,
            3.0299440770744196129956E-2L,
            1.2617719307481059087798E-4L,
        ];
        static immutable T[4] Q = [
            2.0000000000000000000897E0L,
            2.2726554820815502876593E-1L,
            2.5244834034968410419224E-3L,
            3.0019850513866445504159E-6L,
        ];

        // C1 + C2 = LN2.
        enum T C1 = 6.9314575195312500000000E-1L;
        enum T C2 = 1.4286068203094172321215E-6L;

        // Overflow and Underflow limits.
        enum T OF =  1.1356523406294143949492E4L;  // ln((1-2^-64) * 2^16384)
        enum T UF = -1.13994985314888605586758E4L; // ln(2^-16446)
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        // Coefficients for exp(x) - 1
        static immutable T[5] P = [
            9.999999999999999999999999999999999998502E-1L,
            3.508710990737834361215404761139478627390E-2L,
            2.708775201978218837374512615596512792224E-4L,
            6.141506007208645008909088812338454698548E-7L,
            3.279723985560247033712687707263393506266E-10L
        ];
        static immutable T[6] Q = [
            2.000000000000000000000000000000000000150E0,
            2.368408864814233538909747618894558968880E-1L,
            3.611828913847589925056132680618007270344E-3L,
            1.504792651814944826817779302637284053660E-5L,
            1.771372078166251484503904874657985291164E-8L,
            2.980756652081995192255342779918052538681E-12L
        ];

        // C1 + C2 = LN2.
        enum T C1 = 6.93145751953125E-1L;
        enum T C2 = 1.428606820309417232121458176568075500134E-6L;

        // Overflow and Underflow limits.
        enum T OF =  1.135583025911358400418251384584930671458833e4L;
        enum T UF = -1.143276959615573793352782661133116431383730e4L;
    }
    else
        static assert(0, "Not implemented for this architecture");

    // Special cases.
    if (isNaN(x))
        return x;
    if (x > OF)
        return real.infinity;
    if (x < UF)
        return 0.0;

    // Express: e^^x = e^^g * 2^^n
    //   = e^^g * e^^(n * LOG2E)
    //   = e^^(g + n * LOG2E)
    T xx = floor((cast(T) LOG2E) * x + cast(T) 0.5);
    const int n = cast(int) xx;
    x -= xx * C1;
    x -= xx * C2;

    static if (F.realFormat == RealFormat.ieeeSingle)
    {
        xx = x * x;
        x = poly(x, P) * xx + x + 1.0f;
    }
    else
    {
        // Rational approximation for exponential of the fractional part:
        //  e^^x = 1 + 2x P(x^^2) / (Q(x^^2) - P(x^^2))
        xx = x * x;
        const T px = x * poly(xx, P);
        x = px / (poly(xx, Q) - px);
        x = (cast(T) 1.0) + (cast(T) 2.0) * x;
    }

    // Scale by power of 2.
    x = ldexp(x, n);

    return x;
}

@safe @nogc nothrow unittest
{
    version (FloatingPointControlSupport)
    {
        FloatingPointControl ctrl;
        if (FloatingPointControl.hasExceptionTraps)
            ctrl.disableExceptions(FloatingPointControl.allExceptions);
        ctrl.rounding = FloatingPointControl.roundToNearest;
    }

    static void testExp(T)()
    {
        enum realFormat = floatTraits!T.realFormat;
        static if (realFormat == RealFormat.ieeeQuadruple)
        {
            static immutable T[2][] exptestpoints =
            [ //  x               exp(x)
                [ 1.0L,           E                                        ],
                [ 0.5L,           0x1.a61298e1e069bc972dfefab6df34p+0L     ],
                [ 3.0L,           E*E*E                                    ],
                [ 0x1.6p+13L,     0x1.6e509d45728655cdb4840542acb5p+16250L ], // near overflow
                [ 0x1.7p+13L,     T.infinity                               ], // close overflow
                [ 0x1p+80L,       T.infinity                               ], // far overflow
                [ T.infinity,     T.infinity                               ],
                [-0x1.18p+13L,    0x1.5e4bf54b4807034ea97fef0059a6p-12927L ], // near underflow
                [-0x1.625p+13L,   0x1.a6bd68a39d11fec3a250cd97f524p-16358L ], // ditto
                [-0x1.62dafp+13L, 0x0.cb629e9813b80ed4d639e875be6cp-16382L ], // near underflow - subnormal
                [-0x1.6549p+13L,  0x0.0000000000000000000000000001p-16382L ], // ditto
                [-0x1.655p+13L,   0                                        ], // close underflow
                [-0x1p+30L,       0                                        ], // far underflow
            ];
        }
        else static if (realFormat == RealFormat.ieeeExtended ||
                        realFormat == RealFormat.ieeeExtended53)
        {
            static immutable T[2][] exptestpoints =
            [ //  x               exp(x)
                [ 1.0L,           E                            ],
                [ 0.5L,           0x1.a61298e1e069bc97p+0L     ],
                [ 3.0L,           E*E*E                        ],
                [ 0x1.1p+13L,     0x1.29aeffefc8ec645p+12557L  ], // near overflow
                [ 0x1.7p+13L,     T.infinity                   ], // close overflow
                [ 0x1p+80L,       T.infinity                   ], // far overflow
                [ T.infinity,     T.infinity                   ],
                [-0x1.18p+13L,    0x1.5e4bf54b4806db9p-12927L  ], // near underflow
                [-0x1.625p+13L,   0x1.a6bd68a39d11f35cp-16358L ], // ditto
                [-0x1.62dafp+13L, 0x1.96c53d30277021dp-16383L  ], // near underflow - subnormal
                [-0x1.643p+13L,   0x1p-16444L                  ], // ditto
                [-0x1.645p+13L,   0                            ], // close underflow
                [-0x1p+30L,       0                            ], // far underflow
            ];
        }
        else static if (realFormat == RealFormat.ieeeDouble)
        {
            static immutable T[2][] exptestpoints =
            [ //  x,             exp(x)
                [ 1.0L,          E                        ],
                [ 0.5L,          0x1.a61298e1e069cp+0L    ],
                [ 3.0L,          E*E*E                    ],
                [ 0x1.6p+9L,     0x1.93bf4ec282efbp+1015L ], // near overflow
                [ 0x1.7p+9L,     T.infinity               ], // close overflow
                [ 0x1p+80L,      T.infinity               ], // far overflow
                [ T.infinity,    T.infinity               ],
                [-0x1.6p+9L,     0x1.44a3824e5285fp-1016L ], // near underflow
                [-0x1.64p+9L,    0x0.06f84920bb2d4p-1022L ], // near underflow - subnormal
                [-0x1.743p+9L,   0x0.0000000000001p-1022L ], // ditto
                [-0x1.8p+9L,     0                        ], // close underflow
                [-0x1p+30L,      0                        ], // far underflow
            ];
        }
        else static if (realFormat == RealFormat.ieeeSingle)
        {
            static immutable T[2][] exptestpoints =
            [ //  x,             exp(x)
                [ 1.0L,          E                ],
                [ 0.5L,          0x1.a61299p+0L   ],
                [ 3.0L,          E*E*E            ],
                [ 0x1.62p+6L,    0x1.99b988p+127L ], // near overflow
                [ 0x1.7p+6L,     T.infinity       ], // close overflow
                [ 0x1p+80L,      T.infinity       ], // far overflow
                [ T.infinity,    T.infinity       ],
                [-0x1.5cp+6L,    0x1.666d0ep-126L ], // near underflow
                [-0x1.7p+6L,     0x0.026a42p-126L ], // near underflow - subnormal
                [-0x1.9cp+6L,    0x0.000002p-126L ], // ditto
                [-0x1.ap+6L,     0                ], // close underflow
                [-0x1p+30L,      0                ], // far underflow
            ];
        }
        else
            static assert(0, "No exp() tests for real type!");

        const minEqualMantissaBits = T.mant_dig - 2;
        T x;
        version (IeeeFlagsSupport) IeeeFlags f;
        foreach (ref pair; exptestpoints)
        {
            version (IeeeFlagsSupport) resetIeeeFlags();
            x = exp(pair[0]);
            //printf("exp(%La) = %La, should be %La\n", cast(real) pair[0], cast(real) x, cast(real) pair[1]);
            assert(feqrel(x, pair[1]) >= minEqualMantissaBits);
        }

        // Ideally, exp(0) would not set the inexact flag.
        // Unfortunately, fldl2e sets it!
        // So it's not realistic to avoid setting it.
        assert(exp(cast(T) 0.0) == 1.0);

        // NaN propagation. Doesn't set flags, bcos was already NaN.
        version (IeeeFlagsSupport)
        {
            resetIeeeFlags();
            x = exp(T.nan);
            f = ieeeFlags;
            assert(isIdentical(abs(x), T.nan));
            assert(f.flags == 0);

            resetIeeeFlags();
            x = exp(-T.nan);
            f = ieeeFlags;
            assert(isIdentical(abs(x), T.nan));
            assert(f.flags == 0);
        }
        else
        {
            x = exp(T.nan);
            assert(isIdentical(abs(x), T.nan));

            x = exp(-T.nan);
            assert(isIdentical(abs(x), T.nan));
        }

        x = exp(NaN(0x123));
        assert(isIdentical(x, NaN(0x123)));
    }

    import std.meta : AliasSeq;
    foreach (T; AliasSeq!(real, double, float))
        testExp!T();

    // High resolution test (verified against GNU MPFR/Mathematica).
    assert(exp(0.5L) == 0x1.A612_98E1_E069_BC97_2DFE_FAB6_DF34p+0L);

    assert(equalsDigit(exp(3.0L), E * E * E, useDigits));
}

/**
 * Calculates the value of the natural logarithm base (e)
 * raised to the power of x, minus 1.
 *
 * For very small x, expm1(x) is more accurate
 * than exp(x)-1.
 *
 *  $(TABLE_SV
 *    $(TR $(TH x)             $(TH e$(SUPERSCRIPT x)-1)  )
 *    $(TR $(TD $(PLUSMN)0.0)  $(TD $(PLUSMN)0.0) )
 *    $(TR $(TD +$(INFIN))     $(TD +$(INFIN))    )
 *    $(TR $(TD -$(INFIN))     $(TD -1.0)         )
 *    $(TR $(TD $(NAN))        $(TD $(NAN))       )
 *  )
 */
pragma(inline, true)
real expm1(real x) @trusted pure nothrow @nogc // TODO: @safe
{
    version (InlineAsm_X87)
    {
        if (!__ctfe)
            return expm1Asm(x);
    }
    return expm1Impl(x);
}

/// ditto
pragma(inline, true)
double expm1(double x) @safe pure nothrow @nogc
{
    return __ctfe ? cast(double) expm1(cast(real) x) : expm1Impl(x);
}

/// ditto
pragma(inline, true)
float expm1(float x) @safe pure nothrow @nogc
{
    // no single-precision version in Cephes => use double precision
    return __ctfe ? cast(float) expm1(cast(real) x) : cast(float) expm1Impl(cast(double) x);
}

///
@safe unittest
{
    assert(isIdentical(expm1(0.0), 0.0));
    assert(expm1(1.0).feqrel(1.71828) > 16);
    assert(expm1(2.0).feqrel(6.3890) > 16);
}

version (InlineAsm_X87)
private real expm1Asm(real x) @trusted pure nothrow @nogc
{
    version (X86)
    {
        enum PARAMSIZE = (real.sizeof+3)&(0xFFFF_FFFC); // always a multiple of 4
        asm pure nothrow @nogc
        {
            /*  expm1() for x87 80-bit reals, IEEE754-2008 conformant.
             * Author: Don Clugston.
             *
             *    expm1(x) = 2^^(rndint(y))* 2^^(y-rndint(y)) - 1 where y = LN2*x.
             *    = 2rndy * 2ym1 + 2rndy - 1, where 2rndy = 2^^(rndint(y))
             *     and 2ym1 = (2^^(y-rndint(y))-1).
             *    If 2rndy  < 0.5*real.epsilon, result is -1.
             *    Implementation is otherwise the same as for exp2()
             */
            naked;
            fld real ptr [ESP+4] ; // x
            mov AX, [ESP+4+8]; // AX = exponent and sign
            sub ESP, 12+8; // Create scratch space on the stack
            // [ESP,ESP+2] = scratchint
            // [ESP+4..+6, +8..+10, +10] = scratchreal
            // set scratchreal mantissa = 1.0
            mov dword ptr [ESP+8], 0;
            mov dword ptr [ESP+8+4], 0x80000000;
            and AX, 0x7FFF; // drop sign bit
            cmp AX, 0x401D; // avoid InvalidException in fist
            jae L_extreme;
            fldl2e;
            fmulp ST(1), ST; // y = x*log2(e)
            fist dword ptr [ESP]; // scratchint = rndint(y)
            fisub dword ptr [ESP]; // y - rndint(y)
            // and now set scratchreal exponent
            mov EAX, [ESP];
            add EAX, 0x3fff;
            jle short L_largenegative;
            cmp EAX,0x8000;
            jge short L_largepositive;
            mov [ESP+8+8],AX;
            f2xm1; // 2ym1 = 2^^(y-rndint(y)) -1
            fld real ptr [ESP+8] ; // 2rndy = 2^^rndint(y)
            fmul ST(1), ST;  // ST=2rndy, ST(1)=2rndy*2ym1
            fld1;
            fsubp ST(1), ST; // ST = 2rndy-1, ST(1) = 2rndy * 2ym1 - 1
            faddp ST(1), ST; // ST = 2rndy * 2ym1 + 2rndy - 1
            add ESP,12+8;
            ret PARAMSIZE;

L_extreme:  // Extreme exponent. X is very large positive, very
            // large negative, infinity, or NaN.
            fxam;
            fstsw AX;
            test AX, 0x0400; // NaN_or_zero, but we already know x != 0
            jz L_was_nan;  // if x is NaN, returns x
            test AX, 0x0200;
            jnz L_largenegative;
L_largepositive:
            // Set scratchreal = real.max.
            // squaring it will create infinity, and set overflow flag.
            mov word  ptr [ESP+8+8], 0x7FFE;
            fstp ST(0);
            fld real ptr [ESP+8];  // load scratchreal
            fmul ST(0), ST;        // square it, to create havoc!
L_was_nan:
            add ESP,12+8;
            ret PARAMSIZE;
L_largenegative:
            fstp ST(0);
            fld1;
            fchs; // return -1. Underflow flag is not set.
            add ESP,12+8;
            ret PARAMSIZE;
        }
    }
    else version (X86_64)
    {
        asm pure nothrow @nogc
        {
            naked;
        }
        version (Win64)
        {
            asm pure nothrow @nogc
            {
                fld   real ptr [RCX];  // x
                mov   AX,[RCX+8];      // AX = exponent and sign
            }
        }
        else
        {
            asm pure nothrow @nogc
            {
                fld   real ptr [RSP+8];  // x
                mov   AX,[RSP+8+8];      // AX = exponent and sign
            }
        }
        asm pure nothrow @nogc
        {
            /*  expm1() for x87 80-bit reals, IEEE754-2008 conformant.
             * Author: Don Clugston.
             *
             *    expm1(x) = 2^(rndint(y))* 2^(y-rndint(y)) - 1 where y = LN2*x.
             *    = 2rndy * 2ym1 + 2rndy - 1, where 2rndy = 2^(rndint(y))
             *     and 2ym1 = (2^(y-rndint(y))-1).
             *    If 2rndy  < 0.5*real.epsilon, result is -1.
             *    Implementation is otherwise the same as for exp2()
             */
            sub RSP, 24;       // Create scratch space on the stack
            // [RSP,RSP+2] = scratchint
            // [RSP+4..+6, +8..+10, +10] = scratchreal
            // set scratchreal mantissa = 1.0
            mov dword ptr [RSP+8], 0;
            mov dword ptr [RSP+8+4], 0x80000000;
            and AX, 0x7FFF; // drop sign bit
            cmp AX, 0x401D; // avoid InvalidException in fist
            jae L_extreme;
            fldl2e;
            fmul ; // y = x*log2(e)
            fist dword ptr [RSP]; // scratchint = rndint(y)
            fisub dword ptr [RSP]; // y - rndint(y)
            // and now set scratchreal exponent
            mov EAX, [RSP];
            add EAX, 0x3fff;
            jle short L_largenegative;
            cmp EAX,0x8000;
            jge short L_largepositive;
            mov [RSP+8+8],AX;
            f2xm1; // 2^(y-rndint(y)) -1
            fld real ptr [RSP+8] ; // 2^rndint(y)
            fmul ST(1), ST;
            fld1;
            fsubp ST(1), ST;
            fadd;
            add RSP,24;
            ret;

L_extreme:  // Extreme exponent. X is very large positive, very
            // large negative, infinity, or NaN.
            fxam;
            fstsw AX;
            test AX, 0x0400; // NaN_or_zero, but we already know x != 0
            jz L_was_nan;  // if x is NaN, returns x
            test AX, 0x0200;
            jnz L_largenegative;
L_largepositive:
            // Set scratchreal = real.max.
            // squaring it will create infinity, and set overflow flag.
            mov word  ptr [RSP+8+8], 0x7FFE;
            fstp ST(0);
            fld real ptr [RSP+8];  // load scratchreal
            fmul ST(0), ST;        // square it, to create havoc!
L_was_nan:
            add RSP,24;
            ret;

L_largenegative:
            fstp ST(0);
            fld1;
            fchs; // return -1. Underflow flag is not set.
            add RSP,24;
            ret;
        }
    }
    else
        static assert(0);
}

private T expm1Impl(T)(T x) @safe pure nothrow @nogc
{
    // Coefficients for exp(x) - 1 and overflow/underflow limits.
    enum realFormat = floatTraits!T.realFormat;
    static if (realFormat == RealFormat.ieeeQuadruple)
    {
        static immutable T[8] P = [
            2.943520915569954073888921213330863757240E8L,
            -5.722847283900608941516165725053359168840E7L,
            8.944630806357575461578107295909719817253E6L,
            -7.212432713558031519943281748462837065308E5L,
            4.578962475841642634225390068461943438441E4L,
            -1.716772506388927649032068540558788106762E3L,
            4.401308817383362136048032038528753151144E1L,
            -4.888737542888633647784737721812546636240E-1L
        ];

        static immutable T[9] Q = [
            1.766112549341972444333352727998584753865E9L,
            -7.848989743695296475743081255027098295771E8L,
            1.615869009634292424463780387327037251069E8L,
            -2.019684072836541751428967854947019415698E7L,
            1.682912729190313538934190635536631941751E6L,
            -9.615511549171441430850103489315371768998E4L,
            3.697714952261803935521187272204485251835E3L,
            -8.802340681794263968892934703309274564037E1L,
            1.0
        ];

        enum T OF = 1.1356523406294143949491931077970764891253E4L;
        enum T UF = -1.143276959615573793352782661133116431383730e4L;
    }
    else static if (realFormat == RealFormat.ieeeExtended)
    {
        static immutable T[5] P = [
           -1.586135578666346600772998894928250240826E4L,
            2.642771505685952966904660652518429479531E3L,
           -3.423199068835684263987132888286791620673E2L,
            1.800826371455042224581246202420972737840E1L,
           -5.238523121205561042771939008061958820811E-1L,
        ];
        static immutable T[6] Q = [
           -9.516813471998079611319047060563358064497E4L,
            3.964866271411091674556850458227710004570E4L,
           -7.207678383830091850230366618190187434796E3L,
            7.206038318724600171970199625081491823079E2L,
           -4.002027679107076077238836622982900945173E1L,
            1.0
        ];

        enum T OF =  1.1356523406294143949492E4L;
        enum T UF = -4.5054566736396445112120088E1L;
    }
    else static if (realFormat == RealFormat.ieeeDouble)
    {
        static immutable T[3] P = [
            9.9999999999999999991025E-1,
            3.0299440770744196129956E-2,
            1.2617719307481059087798E-4,
        ];
        static immutable T[4] Q = [
            2.0000000000000000000897E0,
            2.2726554820815502876593E-1,
            2.5244834034968410419224E-3,
            3.0019850513866445504159E-6,
        ];
    }
    else
        static assert(0, "no coefficients for expm1()");

    static if (realFormat == RealFormat.ieeeDouble) // special case for double precision
    {
        if (x < -0.5 || x > 0.5)
            return exp(x) - 1.0;
        if (x == 0.0)
            return x;

        const T xx = x * x;
        x = x * poly(xx, P);
        x = x / (poly(xx, Q) - x);
        return x + x;
    }
    else
    {
        // C1 + C2 = LN2.
        enum T C1 = 6.9314575195312500000000E-1L;
        enum T C2 = 1.428606820309417232121458176568075500134E-6L;

        // Special cases.
        if (x > OF)
            return real.infinity;
        if (x == cast(T) 0.0)
            return x;
        if (x < UF)
            return -1.0;

        // Express x = LN2 (n + remainder), remainder not exceeding 1/2.
        int n = cast(int) floor((cast(T) 0.5) + x / cast(T) LN2);
        x -= n * C1;
        x -= n * C2;

        // Rational approximation:
        //  exp(x) - 1 = x + 0.5 x^^2 + x^^3 P(x) / Q(x)
        T px = x * poly(x, P);
        T qx = poly(x, Q);
        const T xx = x * x;
        qx = x + ((cast(T) 0.5) * xx + xx * px / qx);

        // We have qx = exp(remainder LN2) - 1, so:
        //  exp(x) - 1 = 2^^n (qx + 1) - 1 = 2^^n qx + 2^^n - 1.
        px = ldexp(cast(T) 1.0, n);
        x = px * qx + (px - cast(T) 1.0);

        return x;
    }
}

@safe @nogc nothrow unittest
{
    static void testExpm1(T)()
    {
        // NaN
        assert(isNaN(expm1(cast(T) T.nan)));

        static immutable T[] xs = [ -2, -0.75, -0.3, 0.0, 0.1, 0.2, 0.5, 1.0 ];
        foreach (x; xs)
        {
            const T e = expm1(x);
            const T r = exp(x) - 1;

            //printf("expm1(%Lg) = %Lg, should approximately be %Lg\n", cast(real) x, cast(real) e, cast(real) r);
            assert(isClose(r, e, CommonDefaultFor!(T,T), CommonDefaultFor!(T,T)));
        }
    }

    import std.meta : AliasSeq;
    foreach (T; AliasSeq!(real, double))
        testExpm1!T();
}

/**
 * Calculates 2$(SUPERSCRIPT x).
 *
 *  $(TABLE_SV
 *    $(TR $(TH x)             $(TH exp2(x))   )
 *    $(TR $(TD +$(INFIN))     $(TD +$(INFIN)) )
 *    $(TR $(TD -$(INFIN))     $(TD +0.0)      )
 *    $(TR $(TD $(NAN))        $(TD $(NAN))    )
 *  )
 */
pragma(inline, true)
real exp2(real x) @nogc @trusted pure nothrow // TODO: @safe
{
    version (InlineAsm_X87)
    {
        if (!__ctfe)
            return exp2Asm(x);
    }
    return exp2Impl(x);
}

/// ditto
pragma(inline, true)
double exp2(double x) @nogc @safe pure nothrow { return __ctfe ? cast(double) exp2(cast(real) x) : exp2Impl(x); }

/// ditto
pragma(inline, true)
float exp2(float x) @nogc @safe pure nothrow { return __ctfe ? cast(float) exp2(cast(real) x) : exp2Impl(x); }

///
@safe unittest
{
    assert(isIdentical(exp2(0.0), 1.0));
    assert(exp2(2.0).feqrel(4.0) > 16);
    assert(exp2(8.0).feqrel(256.0) > 16);
}

@safe unittest
{
    version (CRuntime_Microsoft) {} else // aexp2/exp2f/exp2l not implemented
    {
        assert( core.stdc.math.exp2f(0.0f) == 1 );
        assert( core.stdc.math.exp2 (0.0)  == 1 );
        assert( core.stdc.math.exp2l(0.0L) == 1 );
    }
}

version (InlineAsm_X87)
private real exp2Asm(real x) @nogc @trusted pure nothrow
{
    version (X86)
    {
        enum PARAMSIZE = (real.sizeof+3)&(0xFFFF_FFFC); // always a multiple of 4

        asm pure nothrow @nogc
        {
            /*  exp2() for x87 80-bit reals, IEEE754-2008 conformant.
             * Author: Don Clugston.
             *
             * exp2(x) = 2^^(rndint(x))* 2^^(y-rndint(x))
             * The trick for high performance is to avoid the fscale(28cycles on core2),
             * frndint(19 cycles), leaving f2xm1(19 cycles) as the only slow instruction.
             *
             * We can do frndint by using fist. BUT we can't use it for huge numbers,
             * because it will set the Invalid Operation flag if overflow or NaN occurs.
             * Fortunately, whenever this happens the result would be zero or infinity.
             *
             * We can perform fscale by directly poking into the exponent. BUT this doesn't
             * work for the (very rare) cases where the result is subnormal. So we fall back
             * to the slow method in that case.
             */
            naked;
            fld real ptr [ESP+4] ; // x
            mov AX, [ESP+4+8]; // AX = exponent and sign
            sub ESP, 12+8; // Create scratch space on the stack
            // [ESP,ESP+2] = scratchint
            // [ESP+4..+6, +8..+10, +10] = scratchreal
            // set scratchreal mantissa = 1.0
            mov dword ptr [ESP+8], 0;
            mov dword ptr [ESP+8+4], 0x80000000;
            and AX, 0x7FFF; // drop sign bit
            cmp AX, 0x401D; // avoid InvalidException in fist
            jae L_extreme;
            fist dword ptr [ESP]; // scratchint = rndint(x)
            fisub dword ptr [ESP]; // x - rndint(x)
            // and now set scratchreal exponent
            mov EAX, [ESP];
            add EAX, 0x3fff;
            jle short L_subnormal;
            cmp EAX,0x8000;
            jge short L_overflow;
            mov [ESP+8+8],AX;
L_normal:
            f2xm1;
            fld1;
            faddp ST(1), ST; // 2^^(x-rndint(x))
            fld real ptr [ESP+8] ; // 2^^rndint(x)
            add ESP,12+8;
            fmulp ST(1), ST;
            ret PARAMSIZE;

L_subnormal:
            // Result will be subnormal.
            // In this rare case, the simple poking method doesn't work.
            // The speed doesn't matter, so use the slow fscale method.
            fild dword ptr [ESP];  // scratchint
            fld1;
            fscale;
            fstp real ptr [ESP+8]; // scratchreal = 2^^scratchint
            fstp ST(0);         // drop scratchint
            jmp L_normal;

L_extreme:  // Extreme exponent. X is very large positive, very
            // large negative, infinity, or NaN.
            fxam;
            fstsw AX;
            test AX, 0x0400; // NaN_or_zero, but we already know x != 0
            jz L_was_nan;  // if x is NaN, returns x
            // set scratchreal = real.min_normal
            // squaring it will return 0, setting underflow flag
            mov word  ptr [ESP+8+8], 1;
            test AX, 0x0200;
            jnz L_waslargenegative;
L_overflow:
            // Set scratchreal = real.max.
            // squaring it will create infinity, and set overflow flag.
            mov word  ptr [ESP+8+8], 0x7FFE;
L_waslargenegative:
            fstp ST(0);
            fld real ptr [ESP+8];  // load scratchreal
            fmul ST(0), ST;        // square it, to create havoc!
L_was_nan:
            add ESP,12+8;
            ret PARAMSIZE;
        }
    }
    else version (X86_64)
    {
        asm pure nothrow @nogc
        {
            naked;
        }
        version (Win64)
        {
            asm pure nothrow @nogc
            {
                fld   real ptr [RCX];  // x
                mov   AX,[RCX+8];      // AX = exponent and sign
            }
        }
        else
        {
            asm pure nothrow @nogc
            {
                fld   real ptr [RSP+8];  // x
                mov   AX,[RSP+8+8];      // AX = exponent and sign
            }
        }
        asm pure nothrow @nogc
        {
            /*  exp2() for x87 80-bit reals, IEEE754-2008 conformant.
             * Author: Don Clugston.
             *
             * exp2(x) = 2^(rndint(x))* 2^(y-rndint(x))
             * The trick for high performance is to avoid the fscale(28cycles on core2),
             * frndint(19 cycles), leaving f2xm1(19 cycles) as the only slow instruction.
             *
             * We can do frndint by using fist. BUT we can't use it for huge numbers,
             * because it will set the Invalid Operation flag is overflow or NaN occurs.
             * Fortunately, whenever this happens the result would be zero or infinity.
             *
             * We can perform fscale by directly poking into the exponent. BUT this doesn't
             * work for the (very rare) cases where the result is subnormal. So we fall back
             * to the slow method in that case.
             */
            sub RSP, 24; // Create scratch space on the stack
            // [RSP,RSP+2] = scratchint
            // [RSP+4..+6, +8..+10, +10] = scratchreal
            // set scratchreal mantissa = 1.0
            mov dword ptr [RSP+8], 0;
            mov dword ptr [RSP+8+4], 0x80000000;
            and AX, 0x7FFF; // drop sign bit
            cmp AX, 0x401D; // avoid InvalidException in fist
            jae L_extreme;
            fist dword ptr [RSP]; // scratchint = rndint(x)
            fisub dword ptr [RSP]; // x - rndint(x)
            // and now set scratchreal exponent
            mov EAX, [RSP];
            add EAX, 0x3fff;
            jle short L_subnormal;
            cmp EAX,0x8000;
            jge short L_overflow;
            mov [RSP+8+8],AX;
L_normal:
            f2xm1;
            fld1;
            fadd; // 2^(x-rndint(x))
            fld real ptr [RSP+8] ; // 2^rndint(x)
            add RSP,24;
            fmulp ST(1), ST;
            ret;

L_subnormal:
            // Result will be subnormal.
            // In this rare case, the simple poking method doesn't work.
            // The speed doesn't matter, so use the slow fscale method.
            fild dword ptr [RSP];  // scratchint
            fld1;
            fscale;
            fstp real ptr [RSP+8]; // scratchreal = 2^scratchint
            fstp ST(0);         // drop scratchint
            jmp L_normal;

L_extreme:  // Extreme exponent. X is very large positive, very
            // large negative, infinity, or NaN.
            fxam;
            fstsw AX;
            test AX, 0x0400; // NaN_or_zero, but we already know x != 0
            jz L_was_nan;  // if x is NaN, returns x
            // set scratchreal = real.min
            // squaring it will return 0, setting underflow flag
            mov word  ptr [RSP+8+8], 1;
            test AX, 0x0200;
            jnz L_waslargenegative;
L_overflow:
            // Set scratchreal = real.max.
            // squaring it will create infinity, and set overflow flag.
            mov word  ptr [RSP+8+8], 0x7FFE;
L_waslargenegative:
            fstp ST(0);
            fld real ptr [RSP+8];  // load scratchreal
            fmul ST(0), ST;        // square it, to create havoc!
L_was_nan:
            add RSP,24;
            ret;
        }
    }
    else
        static assert(0);
}

private T exp2Impl(T)(T x) @nogc @safe pure nothrow
{
    // Coefficients for exp2(x)
    enum realFormat = floatTraits!T.realFormat;
    static if (realFormat == RealFormat.ieeeQuadruple)
    {
        static immutable T[5] P = [
            9.079594442980146270952372234833529694788E12L,
            1.530625323728429161131811299626419117557E11L,
            5.677513871931844661829755443994214173883E8L,
            6.185032670011643762127954396427045467506E5L,
            1.587171580015525194694938306936721666031E2L
        ];

        static immutable T[6] Q = [
            2.619817175234089411411070339065679229869E13L,
            1.490560994263653042761789432690793026977E12L,
            1.092141473886177435056423606755843616331E10L,
            2.186249607051644894762167991800811827835E7L,
            1.236602014442099053716561665053645270207E4L,
            1.0
        ];
    }
    else static if (realFormat == RealFormat.ieeeExtended)
    {
        static immutable T[3] P = [
            2.0803843631901852422887E6L,
            3.0286971917562792508623E4L,
            6.0614853552242266094567E1L,
        ];
        static immutable T[4] Q = [
            6.0027204078348487957118E6L,
            3.2772515434906797273099E5L,
            1.7492876999891839021063E3L,
            1.0000000000000000000000E0L,
        ];
    }
    else static if (realFormat == RealFormat.ieeeDouble)
    {
        static immutable T[3] P = [
            1.51390680115615096133E3L,
            2.02020656693165307700E1L,
            2.30933477057345225087E-2L,
        ];
        static immutable T[3] Q = [
            4.36821166879210612817E3L,
            2.33184211722314911771E2L,
            1.00000000000000000000E0L,
        ];
    }
    else static if (realFormat == RealFormat.ieeeSingle)
    {
        static immutable T[6] P = [
            6.931472028550421E-001L,
            2.402264791363012E-001L,
            5.550332471162809E-002L,
            9.618437357674640E-003L,
            1.339887440266574E-003L,
            1.535336188319500E-004L,
        ];
    }
    else
        static assert(0, "no coefficients for exp2()");

    // Overflow and Underflow limits.
    enum T OF = T.max_exp;
    enum T UF = T.min_exp - 1;

    // Special cases.
    if (isNaN(x))
        return x;
    if (x > OF)
        return real.infinity;
    if (x < UF)
        return 0.0;

    static if (realFormat == RealFormat.ieeeSingle) // special case for single precision
    {
        // The following is necessary because range reduction blows up.
        if (x == 0.0f)
            return 1.0f;

        // Separate into integer and fractional parts.
        const T i = floor(x);
        int n = cast(int) i;
        x -= i;
        if (x > 0.5f)
        {
            n += 1;
            x -= 1.0f;
        }

        // Rational approximation:
        //  exp2(x) = 1.0 + x P(x)
        x = 1.0f + x * poly(x, P);
    }
    else
    {
        // Separate into integer and fractional parts.
        const T i = floor(x + cast(T) 0.5);
        int n = cast(int) i;
        x -= i;

        // Rational approximation:
        //  exp2(x) = 1.0 + 2x P(x^^2) / (Q(x^^2) - P(x^^2))
        const T xx = x * x;
        const T px = x * poly(xx, P);
        x = px / (poly(xx, Q) - px);
        x = (cast(T) 1.0) + (cast(T) 2.0) * x;
    }

    // Scale by power of 2.
    x = ldexp(x, n);

    return x;
}

@safe @nogc nothrow unittest
{
    assert(feqrel(exp2(0.5L), SQRT2) >= real.mant_dig -1);
    assert(exp2(8.0L) == 256.0);
    assert(exp2(-9.0L)== 1.0L/512.0);

    static void testExp2(T)()
    {
        // NaN
        const T specialNaN = NaN(0x0123L);
        assert(isIdentical(exp2(specialNaN), specialNaN));

        // over-/underflow
        enum T OF = T.max_exp;
        enum T UF = T.min_exp - T.mant_dig;
        assert(isIdentical(exp2(OF + 1), cast(T) T.infinity));
        assert(isIdentical(exp2(UF - 1), cast(T) 0.0));

        static immutable T[2][] vals =
        [
            // x, exp2(x)
            [  0.0, 1.0 ],
            [ -0.0, 1.0 ],
            [  0.5, SQRT2 ],
            [  8.0, 256.0 ],
            [ -9.0, 1.0 / 512 ],
        ];

        foreach (ref val; vals)
        {
            const T x = val[0];
            const T r = val[1];
            const T e = exp2(x);

            //printf("exp2(%Lg) = %Lg, should be %Lg\n", cast(real) x, cast(real) e, cast(real) r);
            assert(isClose(r, e));
        }
    }

    import std.meta : AliasSeq;
    foreach (T; AliasSeq!(real, double, float))
        testExp2!T();
}

/*********************************************************************
 * Separate floating point value into significand and exponent.
 *
 * Returns:
 *      Calculate and return $(I x) and $(I exp) such that
 *      value =$(I x)*2$(SUPERSCRIPT exp) and
 *      .5 $(LT)= |$(I x)| $(LT) 1.0
 *
 *      $(I x) has same sign as value.
 *
 *      $(TABLE_SV
 *      $(TR $(TH value)           $(TH returns)         $(TH exp))
 *      $(TR $(TD $(PLUSMN)0.0)    $(TD $(PLUSMN)0.0)    $(TD 0))
 *      $(TR $(TD +$(INFIN))       $(TD +$(INFIN))       $(TD int.max))
 *      $(TR $(TD -$(INFIN))       $(TD -$(INFIN))       $(TD int.min))
 *      $(TR $(TD $(PLUSMN)$(NAN)) $(TD $(PLUSMN)$(NAN)) $(TD int.min))
 *      )
 */
T frexp(T)(const T value, out int exp) @trusted pure nothrow @nogc
if (isFloatingPoint!T)
{
    if (__ctfe)
    {
        // Handle special cases.
        if (value == 0) { exp = 0; return value; }
        if (value == T.infinity) { exp = int.max; return value; }
        if (value == -T.infinity || value != value) { exp = int.min; return value; }
        // Handle ordinary cases.
        // In CTFE there is no performance advantage for having separate
        // paths for different floating point types.
        T absValue = value < 0 ? -value : value;
        int expCount;
        static if (T.mant_dig > double.mant_dig)
        {
            for (; absValue >= 0x1.0p+1024L; absValue *= 0x1.0p-1024L)
                expCount += 1024;
            for (; absValue < 0x1.0p-1021L; absValue *= 0x1.0p+1021L)
                expCount -= 1021;
        }
        const double dval = cast(double) absValue;
        int dexp = cast(int) (((*cast(const long*) &dval) >>> 52) & 0x7FF) + double.min_exp - 2;
        dexp++;
        expCount += dexp;
        absValue *= 2.0 ^^ -dexp;
        // If the original value was subnormal or if it was a real
        // then absValue can still be outside the [0.5, 1.0) range.
        if (absValue < 0.5)
        {
            assert(T.mant_dig > double.mant_dig || isSubnormal(value));
            do
            {
                absValue += absValue;
                expCount--;
            } while (absValue < 0.5);
        }
        else
        {
            assert(absValue < 1 || T.mant_dig > double.mant_dig);
            for (; absValue >= 1; absValue *= T(0.5))
                expCount++;
        }
        exp = expCount;
        return value < 0 ? -absValue : absValue;
    }

    Unqual!T vf = value;
    ushort* vu = cast(ushort*)&vf;
    static if (is(immutable T == immutable float))
        int* vi = cast(int*)&vf;
    else
        long* vl = cast(long*)&vf;
    int ex;
    alias F = floatTraits!T;

    ex = vu[F.EXPPOS_SHORT] & F.EXPMASK;
    static if (F.realFormat == RealFormat.ieeeExtended ||
               F.realFormat == RealFormat.ieeeExtended53)
    {
        if (ex)
        {   // If exponent is non-zero
            if (ex == F.EXPMASK) // infinity or NaN
            {
                if (*vl &  0x7FFF_FFFF_FFFF_FFFF)  // NaN
                {
                    *vl |= 0xC000_0000_0000_0000;  // convert NaNS to NaNQ
                    exp = int.min;
                }
                else if (vu[F.EXPPOS_SHORT] & 0x8000)   // negative infinity
                    exp = int.min;
                else   // positive infinity
                    exp = int.max;

            }
            else
            {
                exp = ex - F.EXPBIAS;
                vu[F.EXPPOS_SHORT] = (0x8000 & vu[F.EXPPOS_SHORT]) | 0x3FFE;
            }
        }
        else if (!*vl)
        {
            // vf is +-0.0
            exp = 0;
        }
        else
        {
            // subnormal

            vf *= F.RECIP_EPSILON;
            ex = vu[F.EXPPOS_SHORT] & F.EXPMASK;
            exp = ex - F.EXPBIAS - T.mant_dig + 1;
            vu[F.EXPPOS_SHORT] = ((-1 - F.EXPMASK) & vu[F.EXPPOS_SHORT]) | 0x3FFE;
        }
        return vf;
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        if (ex)     // If exponent is non-zero
        {
            if (ex == F.EXPMASK)
            {
                // infinity or NaN
                if (vl[MANTISSA_LSB] |
                    (vl[MANTISSA_MSB] & 0x0000_FFFF_FFFF_FFFF))  // NaN
                {
                    // convert NaNS to NaNQ
                    vl[MANTISSA_MSB] |= 0x0000_8000_0000_0000;
                    exp = int.min;
                }
                else if (vu[F.EXPPOS_SHORT] & 0x8000)   // negative infinity
                    exp = int.min;
                else   // positive infinity
                    exp = int.max;
            }
            else
            {
                exp = ex - F.EXPBIAS;
                vu[F.EXPPOS_SHORT] = F.EXPBIAS | (0x8000 & vu[F.EXPPOS_SHORT]);
            }
        }
        else if ((vl[MANTISSA_LSB] |
            (vl[MANTISSA_MSB] & 0x0000_FFFF_FFFF_FFFF)) == 0)
        {
            // vf is +-0.0
            exp = 0;
        }
        else
        {
            // subnormal
            vf *= F.RECIP_EPSILON;
            ex = vu[F.EXPPOS_SHORT] & F.EXPMASK;
            exp = ex - F.EXPBIAS - T.mant_dig + 1;
            vu[F.EXPPOS_SHORT] = F.EXPBIAS | (0x8000 & vu[F.EXPPOS_SHORT]);
        }
        return vf;
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        if (ex) // If exponent is non-zero
        {
            if (ex == F.EXPMASK)   // infinity or NaN
            {
                if (*vl == 0x7FF0_0000_0000_0000)  // positive infinity
                {
                    exp = int.max;
                }
                else if (*vl == 0xFFF0_0000_0000_0000) // negative infinity
                    exp = int.min;
                else
                { // NaN
                    *vl |= 0x0008_0000_0000_0000;  // convert NaNS to NaNQ
                    exp = int.min;
                }
            }
            else
            {
                exp = (ex - F.EXPBIAS) >> 4;
                vu[F.EXPPOS_SHORT] = cast(ushort)((0x800F & vu[F.EXPPOS_SHORT]) | 0x3FE0);
            }
        }
        else if (!(*vl & 0x7FFF_FFFF_FFFF_FFFF))
        {
            // vf is +-0.0
            exp = 0;
        }
        else
        {
            // subnormal
            vf *= F.RECIP_EPSILON;
            ex = vu[F.EXPPOS_SHORT] & F.EXPMASK;
            exp = ((ex - F.EXPBIAS) >> 4) - T.mant_dig + 1;
            vu[F.EXPPOS_SHORT] =
                cast(ushort)(((-1 - F.EXPMASK) & vu[F.EXPPOS_SHORT]) | 0x3FE0);
        }
        return vf;
    }
    else static if (F.realFormat == RealFormat.ieeeSingle)
    {
        if (ex) // If exponent is non-zero
        {
            if (ex == F.EXPMASK)   // infinity or NaN
            {
                if (*vi == 0x7F80_0000)  // positive infinity
                {
                    exp = int.max;
                }
                else if (*vi == 0xFF80_0000) // negative infinity
                    exp = int.min;
                else
                { // NaN
                    *vi |= 0x0040_0000;  // convert NaNS to NaNQ
                    exp = int.min;
                }
            }
            else
            {
                exp = (ex - F.EXPBIAS) >> 7;
                vu[F.EXPPOS_SHORT] = cast(ushort)((0x807F & vu[F.EXPPOS_SHORT]) | 0x3F00);
            }
        }
        else if (!(*vi & 0x7FFF_FFFF))
        {
            // vf is +-0.0
            exp = 0;
        }
        else
        {
            // subnormal
            vf *= F.RECIP_EPSILON;
            ex = vu[F.EXPPOS_SHORT] & F.EXPMASK;
            exp = ((ex - F.EXPBIAS) >> 7) - T.mant_dig + 1;
            vu[F.EXPPOS_SHORT] =
                cast(ushort)(((-1 - F.EXPMASK) & vu[F.EXPPOS_SHORT]) | 0x3F00);
        }
        return vf;
    }
    else // static if (F.realFormat == RealFormat.ibmExtended)
    {
        assert(0, "frexp not implemented");
    }
}

///
@safe unittest
{
    int exp;
    real mantissa = frexp(123.456L, exp);

    assert(isClose(mantissa * pow(2.0L, cast(real) exp), 123.456L));

    assert(frexp(-real.nan, exp) && exp == int.min);
    assert(frexp(real.nan, exp) && exp == int.min);
    assert(frexp(-real.infinity, exp) == -real.infinity && exp == int.min);
    assert(frexp(real.infinity, exp) == real.infinity && exp == int.max);
    assert(frexp(-0.0, exp) == -0.0 && exp == 0);
    assert(frexp(0.0, exp) == 0.0 && exp == 0);
}

@safe @nogc nothrow unittest
{
    int exp;
    real mantissa = frexp(123.456L, exp);

    // check if values are equal to 19 decimal digits of precision
    assert(equalsDigit(mantissa * pow(2.0L, cast(real) exp), 123.456L, 19));
}

@safe unittest
{
    import std.meta : AliasSeq;
    import std.typecons : tuple, Tuple;

    static foreach (T; AliasSeq!(real, double, float))
    {{
        Tuple!(T, T, int)[] vals =     // x,frexp,exp
            [
             tuple(T(0.0),  T( 0.0 ), 0),
             tuple(T(-0.0), T( -0.0), 0),
             tuple(T(1.0),  T( .5  ), 1),
             tuple(T(-1.0), T( -.5 ), 1),
             tuple(T(2.0),  T( .5  ), 2),
             tuple(T(float.min_normal/2.0f), T(.5), -126),
             tuple(T.infinity, T.infinity, int.max),
             tuple(-T.infinity, -T.infinity, int.min),
             tuple(T.nan, T.nan, int.min),
             tuple(-T.nan, -T.nan, int.min),

             // https://issues.dlang.org/show_bug.cgi?id=16026:
             tuple(3 * (T.min_normal * T.epsilon), T( .75), (T.min_exp - T.mant_dig) + 2)
             ];

        foreach (elem; vals)
        {
            T x = elem[0];
            T e = elem[1];
            int exp = elem[2];
            int eptr;
            T v = frexp(x, eptr);
            assert(isIdentical(e, v));
            assert(exp == eptr);

        }

        static if (floatTraits!(T).realFormat == RealFormat.ieeeExtended)
        {
            static T[3][] extendedvals = [ // x,frexp,exp
                [0x1.a5f1c2eb3fe4efp+73L,    0x1.A5F1C2EB3FE4EFp-1L,     74],    // normal
                [0x1.fa01712e8f0471ap-1064L, 0x1.fa01712e8f0471ap-1L, -1063],
                [T.min_normal,      .5, -16381],
                [T.min_normal/2.0L, .5, -16382]    // subnormal
            ];
            foreach (elem; extendedvals)
            {
                T x = elem[0];
                T e = elem[1];
                int exp = cast(int) elem[2];
                int eptr;
                T v = frexp(x, eptr);
                assert(isIdentical(e, v));
                assert(exp == eptr);

            }
        }
    }}

    // CTFE
    alias CtfeFrexpResult= Tuple!(real, int);
    static CtfeFrexpResult ctfeFrexp(T)(const T value)
    {
        int exp;
        auto significand = frexp(value, exp);
        return CtfeFrexpResult(significand, exp);
    }
    static foreach (T; AliasSeq!(real, double, float))
    {{
        enum Tuple!(T, T, int)[] vals =     // x,frexp,exp
            [
             tuple(T(0.0),  T( 0.0 ), 0),
             tuple(T(-0.0), T( -0.0), 0),
             tuple(T(1.0),  T( .5  ), 1),
             tuple(T(-1.0), T( -.5 ), 1),
             tuple(T(2.0),  T( .5  ), 2),
             tuple(T(float.min_normal/2.0f), T(.5), -126),
             tuple(T.infinity, T.infinity, int.max),
             tuple(-T.infinity, -T.infinity, int.min),
             tuple(T.nan, T.nan, int.min),
             tuple(-T.nan, -T.nan, int.min),

             // https://issues.dlang.org/show_bug.cgi?id=16026:
             tuple(3 * (T.min_normal * T.epsilon), T( .75), (T.min_exp - T.mant_dig) + 2)
             ];

        static foreach (elem; vals)
        {
            static assert(ctfeFrexp(elem[0]) is CtfeFrexpResult(elem[1], elem[2]));
        }

        static if (floatTraits!(T).realFormat == RealFormat.ieeeExtended)
        {
            enum T[3][] extendedvals = [ // x,frexp,exp
                [0x1.a5f1c2eb3fe4efp+73L,    0x1.A5F1C2EB3FE4EFp-1L,     74],    // normal
                [0x1.fa01712e8f0471ap-1064L, 0x1.fa01712e8f0471ap-1L, -1063],
                [T.min_normal,      .5, -16381],
                [T.min_normal/2.0L, .5, -16382]    // subnormal
            ];
            static foreach (elem; extendedvals)
            {
                static assert(ctfeFrexp(elem[0]) is CtfeFrexpResult(elem[1], cast(int) elem[2]));
            }
        }
    }}
}

@safe unittest
{
    import std.meta : AliasSeq;
    void foo() {
        static foreach (T; AliasSeq!(real, double, float))
        {{
            int exp;
            const T a = 1;
            immutable T b = 2;
            auto c = frexp(a, exp);
            auto d = frexp(b, exp);
        }}
    }
}

/******************************************
 * Extracts the exponent of x as a signed integral value.
 *
 * If x is not a special value, the result is the same as
 * $(D cast(int) logb(x)).
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                $(TH ilogb(x))     $(TH Range error?))
 *      $(TR $(TD 0)                 $(TD FP_ILOGB0)   $(TD yes))
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD int.max)     $(TD no))
 *      $(TR $(TD $(NAN))            $(TD FP_ILOGBNAN) $(TD no))
 *      )
 */
int ilogb(T)(const T x) @trusted pure nothrow @nogc
if (isFloatingPoint!T)
{
    import core.bitop : bsr;
    alias F = floatTraits!T;

    union floatBits
    {
        T rv;
        ushort[T.sizeof/2] vu;
        uint[T.sizeof/4] vui;
        static if (T.sizeof >= 8)
            ulong[T.sizeof/8] vul;
    }
    floatBits y = void;
    y.rv = x;

    int ex = y.vu[F.EXPPOS_SHORT] & F.EXPMASK;
    static if (F.realFormat == RealFormat.ieeeExtended ||
               F.realFormat == RealFormat.ieeeExtended53)
    {
        if (ex)
        {
            // If exponent is non-zero
            if (ex == F.EXPMASK) // infinity or NaN
            {
                if (y.vul[0] &  0x7FFF_FFFF_FFFF_FFFF)  // NaN
                    return FP_ILOGBNAN;
                else // +-infinity
                    return int.max;
            }
            else
            {
                return ex - F.EXPBIAS - 1;
            }
        }
        else if (!y.vul[0])
        {
            // vf is +-0.0
            return FP_ILOGB0;
        }
        else
        {
            // subnormal
            return ex - F.EXPBIAS - T.mant_dig + 1 + bsr(y.vul[0]);
        }
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        if (ex)    // If exponent is non-zero
        {
            if (ex == F.EXPMASK)
            {
                // infinity or NaN
                if (y.vul[MANTISSA_LSB] | ( y.vul[MANTISSA_MSB] & 0x0000_FFFF_FFFF_FFFF))  // NaN
                    return FP_ILOGBNAN;
                else // +- infinity
                    return int.max;
            }
            else
            {
                return ex - F.EXPBIAS - 1;
            }
        }
        else if ((y.vul[MANTISSA_LSB] | (y.vul[MANTISSA_MSB] & 0x0000_FFFF_FFFF_FFFF)) == 0)
        {
            // vf is +-0.0
            return FP_ILOGB0;
        }
        else
        {
            // subnormal
            const ulong msb = y.vul[MANTISSA_MSB] & 0x0000_FFFF_FFFF_FFFF;
            const ulong lsb = y.vul[MANTISSA_LSB];
            if (msb)
                return ex - F.EXPBIAS - T.mant_dig + 1 + bsr(msb) + 64;
            else
                return ex - F.EXPBIAS - T.mant_dig + 1 + bsr(lsb);
        }
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        if (ex) // If exponent is non-zero
        {
            if (ex == F.EXPMASK)   // infinity or NaN
            {
                if ((y.vul[0] & 0x7FFF_FFFF_FFFF_FFFF) == 0x7FF0_0000_0000_0000)  // +- infinity
                    return int.max;
                else // NaN
                    return FP_ILOGBNAN;
            }
            else
            {
                return ((ex - F.EXPBIAS) >> 4) - 1;
            }
        }
        else if (!(y.vul[0] & 0x7FFF_FFFF_FFFF_FFFF))
        {
            // vf is +-0.0
            return FP_ILOGB0;
        }
        else
        {
            // subnormal
            enum MANTISSAMASK_64 = ((cast(ulong) F.MANTISSAMASK_INT) << 32) | 0xFFFF_FFFF;
            return ((ex - F.EXPBIAS) >> 4) - T.mant_dig + 1 + bsr(y.vul[0] & MANTISSAMASK_64);
        }
    }
    else static if (F.realFormat == RealFormat.ieeeSingle)
    {
        if (ex) // If exponent is non-zero
        {
            if (ex == F.EXPMASK)   // infinity or NaN
            {
                if ((y.vui[0] & 0x7FFF_FFFF) == 0x7F80_0000)  // +- infinity
                    return int.max;
                else // NaN
                    return FP_ILOGBNAN;
            }
            else
            {
                return ((ex - F.EXPBIAS) >> 7) - 1;
            }
        }
        else if (!(y.vui[0] & 0x7FFF_FFFF))
        {
            // vf is +-0.0
            return FP_ILOGB0;
        }
        else
        {
            // subnormal
            const uint mantissa = y.vui[0] & F.MANTISSAMASK_INT;
            return ((ex - F.EXPBIAS) >> 7) - T.mant_dig + 1 + bsr(mantissa);
        }
    }
    else // static if (F.realFormat == RealFormat.ibmExtended)
    {
        assert(0, "ilogb not implemented");
    }
}
/// ditto
int ilogb(T)(const T x) @safe pure nothrow @nogc
if (isIntegral!T && isUnsigned!T)
{
    import core.bitop : bsr;
    if (x == 0)
        return FP_ILOGB0;
    else
    {
        static assert(T.sizeof <= ulong.sizeof, "integer size too large for the current ilogb implementation");
        return bsr(x);
    }
}
/// ditto
int ilogb(T)(const T x) @safe pure nothrow @nogc
if (isIntegral!T && isSigned!T)
{
    import std.traits : Unsigned;
    // Note: abs(x) can not be used because the return type is not Unsigned and
    //       the return value would be wrong for x == int.min
    Unsigned!T absx =  x >= 0 ? x : -x;
    return ilogb(absx);
}

///
@safe pure unittest
{
    assert(ilogb(1) == 0);
    assert(ilogb(3) == 1);
    assert(ilogb(3.0) == 1);
    assert(ilogb(100_000_000) == 26);

    assert(ilogb(0) == FP_ILOGB0);
    assert(ilogb(0.0) == FP_ILOGB0);
    assert(ilogb(double.nan) == FP_ILOGBNAN);
    assert(ilogb(double.infinity) == int.max);
}

/**
Special return values of $(LREF ilogb).
 */
alias FP_ILOGB0   = core.stdc.math.FP_ILOGB0;
/// ditto
alias FP_ILOGBNAN = core.stdc.math.FP_ILOGBNAN;

///
@safe pure unittest
{
    assert(ilogb(0) == FP_ILOGB0);
    assert(ilogb(0.0) == FP_ILOGB0);
    assert(ilogb(double.nan) == FP_ILOGBNAN);
}

@safe nothrow @nogc unittest
{
    import std.meta : AliasSeq;
    import std.typecons : Tuple;
    static foreach (F; AliasSeq!(float, double, real))
    {{
        alias T = Tuple!(F, int);
        T[13] vals =   // x, ilogb(x)
        [
            T(  F.nan     , FP_ILOGBNAN ),
            T( -F.nan     , FP_ILOGBNAN ),
            T(  F.infinity, int.max     ),
            T( -F.infinity, int.max     ),
            T(  0.0       , FP_ILOGB0   ),
            T( -0.0       , FP_ILOGB0   ),
            T(  2.0       , 1           ),
            T(  2.0001    , 1           ),
            T(  1.9999    , 0           ),
            T(  0.5       , -1          ),
            T(  123.123   , 6           ),
            T( -123.123   , 6           ),
            T(  0.123     , -4          ),
        ];

        foreach (elem; vals)
        {
            assert(ilogb(elem[0]) == elem[1]);
        }
    }}

    // min_normal and subnormals
    assert(ilogb(-float.min_normal) == -126);
    assert(ilogb(nextUp(-float.min_normal)) == -127);
    assert(ilogb(nextUp(-float(0.0))) == -149);
    assert(ilogb(-double.min_normal) == -1022);
    assert(ilogb(nextUp(-double.min_normal)) == -1023);
    assert(ilogb(nextUp(-double(0.0))) == -1074);
    static if (floatTraits!(real).realFormat == RealFormat.ieeeExtended)
    {
        assert(ilogb(-real.min_normal) == -16382);
        assert(ilogb(nextUp(-real.min_normal)) == -16383);
        assert(ilogb(nextUp(-real(0.0))) == -16445);
    }
    else static if (floatTraits!(real).realFormat == RealFormat.ieeeDouble)
    {
        assert(ilogb(-real.min_normal) == -1022);
        assert(ilogb(nextUp(-real.min_normal)) == -1023);
        assert(ilogb(nextUp(-real(0.0))) == -1074);
    }

    // test integer types
    assert(ilogb(0) == FP_ILOGB0);
    assert(ilogb(int.max) == 30);
    assert(ilogb(int.min) == 31);
    assert(ilogb(uint.max) == 31);
    assert(ilogb(long.max) == 62);
    assert(ilogb(long.min) == 63);
    assert(ilogb(ulong.max) == 63);
}

/*******************************************
 * Compute n * 2$(SUPERSCRIPT exp)
 * References: frexp
 */

pragma(inline, true)
real ldexp(real n, int exp)     @safe pure nothrow @nogc { return core.math.ldexp(n, exp); }
///ditto
pragma(inline, true)
double ldexp(double n, int exp) @safe pure nothrow @nogc { return core.math.ldexp(n, exp); }
///ditto
pragma(inline, true)
float ldexp(float n, int exp)   @safe pure nothrow @nogc { return core.math.ldexp(n, exp); }

///
@nogc @safe pure nothrow unittest
{
    import std.meta : AliasSeq;
    static foreach (T; AliasSeq!(float, double, real))
    {{
        T r;

        r = ldexp(3.0L, 3);
        assert(r == 24);

        r = ldexp(cast(T) 3.0, cast(int) 3);
        assert(r == 24);

        T n = 3.0;
        int exp = 3;
        r = ldexp(n, exp);
        assert(r == 24);
    }}
}

@safe pure nothrow @nogc unittest
{
    static if (floatTraits!(real).realFormat == RealFormat.ieeeExtended ||
               floatTraits!(real).realFormat == RealFormat.ieeeExtended53 ||
               floatTraits!(real).realFormat == RealFormat.ieeeQuadruple)
    {
        assert(ldexp(1.0L, -16384) == 0x1p-16384L);
        assert(ldexp(1.0L, -16382) == 0x1p-16382L);
        int x;
        real n = frexp(0x1p-16384L, x);
        assert(n == 0.5L);
        assert(x==-16383);
        assert(ldexp(n, x)==0x1p-16384L);
    }
    else static if (floatTraits!(real).realFormat == RealFormat.ieeeDouble)
    {
        assert(ldexp(1.0L, -1024) == 0x1p-1024L);
        assert(ldexp(1.0L, -1022) == 0x1p-1022L);
        int x;
        real n = frexp(0x1p-1024L, x);
        assert(n == 0.5L);
        assert(x==-1023);
        assert(ldexp(n, x)==0x1p-1024L);
    }
    else static assert(false, "Floating point type real not supported");
}

/* workaround https://issues.dlang.org/show_bug.cgi?id=14718
   float parsing depends on platform strtold
@safe pure nothrow @nogc unittest
{
    assert(ldexp(1.0, -1024) == 0x1p-1024);
    assert(ldexp(1.0, -1022) == 0x1p-1022);
    int x;
    double n = frexp(0x1p-1024, x);
    assert(n == 0.5);
    assert(x==-1023);
    assert(ldexp(n, x)==0x1p-1024);
}

@safe pure nothrow @nogc unittest
{
    assert(ldexp(1.0f, -128) == 0x1p-128f);
    assert(ldexp(1.0f, -126) == 0x1p-126f);
    int x;
    float n = frexp(0x1p-128f, x);
    assert(n == 0.5f);
    assert(x==-127);
    assert(ldexp(n, x)==0x1p-128f);
}
*/

@safe @nogc nothrow unittest
{
    static real[3][] vals =    // value,exp,ldexp
    [
    [    0,    0,    0],
    [    1,    0,    1],
    [    -1,    0,    -1],
    [    1,    1,    2],
    [    123,    10,    125952],
    [    real.max,    int.max,    real.infinity],
    [    real.max,    -int.max,    0],
    [    real.min_normal,    -int.max,    0],
    ];
    int i;

    for (i = 0; i < vals.length; i++)
    {
        real x = vals[i][0];
        int exp = cast(int) vals[i][1];
        real z = vals[i][2];
        real l = ldexp(x, exp);

        assert(equalsDigit(z, l, 7));
    }

    real function(real, int) pldexp = &ldexp;
    assert(pldexp != null);
}

private
{
    version (INLINE_YL2X) {} else
    {
        static if (floatTraits!real.realFormat == RealFormat.ieeeQuadruple)
        {
            // Coefficients for log(1 + x) = x - x**2/2 + x**3 P(x)/Q(x)
            static immutable real[13] logCoeffsP = [
                1.313572404063446165910279910527789794488E4L,
                7.771154681358524243729929227226708890930E4L,
                2.014652742082537582487669938141683759923E5L,
                3.007007295140399532324943111654767187848E5L,
                2.854829159639697837788887080758954924001E5L,
                1.797628303815655343403735250238293741397E5L,
                7.594356839258970405033155585486712125861E4L,
                2.128857716871515081352991964243375186031E4L,
                3.824952356185897735160588078446136783779E3L,
                4.114517881637811823002128927449878962058E2L,
                2.321125933898420063925789532045674660756E1L,
                4.998469661968096229986658302195402690910E-1L,
                1.538612243596254322971797716843006400388E-6L
            ];
            static immutable real[13] logCoeffsQ = [
                3.940717212190338497730839731583397586124E4L,
                2.626900195321832660448791748036714883242E5L,
                7.777690340007566932935753241556479363645E5L,
                1.347518538384329112529391120390701166528E6L,
                1.514882452993549494932585972882995548426E6L,
                1.158019977462989115839826904108208787040E6L,
                6.132189329546557743179177159925690841200E5L,
                2.248234257620569139969141618556349415120E5L,
                5.605842085972455027590989944010492125825E4L,
                9.147150349299596453976674231612674085381E3L,
                9.104928120962988414618126155557301584078E2L,
                4.839208193348159620282142911143429644326E1L,
                1.0
            ];

            // Coefficients for log(x) = z + z^3 P(z^2)/Q(z^2)
            // where z = 2(x-1)/(x+1)
            static immutable real[6] logCoeffsR = [
                1.418134209872192732479751274970992665513E5L,
                -8.977257995689735303686582344659576526998E4L,
                2.048819892795278657810231591630928516206E4L,
                -2.024301798136027039250415126250455056397E3L,
                8.057002716646055371965756206836056074715E1L,
                -8.828896441624934385266096344596648080902E-1L
            ];
            static immutable real[7] logCoeffsS = [
                1.701761051846631278975701529965589676574E6L,
                -1.332535117259762928288745111081235577029E6L,
                4.001557694070773974936904547424676279307E5L,
                -5.748542087379434595104154610899551484314E4L,
                3.998526750980007367835804959888064681098E3L,
                -1.186359407982897997337150403816839480438E2L,
                1.0
            ];
        }
        else
        {
            // Coefficients for log(1 + x) = x - x**2/2 + x**3 P(x)/Q(x)
            static immutable real[7] logCoeffsP = [
                2.0039553499201281259648E1L,
                5.7112963590585538103336E1L,
                6.0949667980987787057556E1L,
                2.9911919328553073277375E1L,
                6.5787325942061044846969E0L,
                4.9854102823193375972212E-1L,
                4.5270000862445199635215E-5L,
            ];
            static immutable real[7] logCoeffsQ = [
                6.0118660497603843919306E1L,
                2.1642788614495947685003E2L,
                3.0909872225312059774938E2L,
                2.2176239823732856465394E2L,
                8.3047565967967209469434E1L,
                1.5062909083469192043167E1L,
                1.0000000000000000000000E0L,
            ];

            // Coefficients for log(x) = z + z^3 P(z^2)/Q(z^2)
            // where z = 2(x-1)/(x+1)
            static immutable real[4] logCoeffsR = [
               -3.5717684488096787370998E1L,
                1.0777257190312272158094E1L,
               -7.1990767473014147232598E-1L,
                1.9757429581415468984296E-3L,
            ];
            static immutable real[4] logCoeffsS = [
               -4.2861221385716144629696E2L,
                1.9361891836232102174846E2L,
               -2.6201045551331104417768E1L,
                1.0000000000000000000000E0L,
            ];
        }
    }
}

/**************************************
 * Calculate the natural logarithm of x.
 *
 *    $(TABLE_SV
 *    $(TR $(TH x)            $(TH log(x))    $(TH divide by 0?) $(TH invalid?))
 *    $(TR $(TD $(PLUSMN)0.0) $(TD -$(INFIN)) $(TD yes)          $(TD no))
 *    $(TR $(TD $(LT)0.0)     $(TD $(NAN))    $(TD no)           $(TD yes))
 *    $(TR $(TD +$(INFIN))    $(TD +$(INFIN)) $(TD no)           $(TD no))
 *    )
 */
real log(real x) @safe pure nothrow @nogc
{
    version (INLINE_YL2X)
        return core.math.yl2x(x, LN2);
    else
    {
        // C1 + C2 = LN2.
        enum real C1 = 6.93145751953125E-1L;
        enum real C2 = 1.428606820309417232121458176568075500134E-6L;

        // Special cases.
        if (isNaN(x))
            return x;
        if (isInfinity(x) && !signbit(x))
            return x;
        if (x == 0.0)
            return -real.infinity;
        if (x < 0.0)
            return real.nan;

        // Separate mantissa from exponent.
        // Note, frexp is used so that denormal numbers will be handled properly.
        real y, z;
        int exp;

        x = frexp(x, exp);

        // Logarithm using log(x) = z + z^^3 R(z) / S(z),
        // where z = 2(x - 1)/(x + 1)
        if ((exp > 2) || (exp < -2))
        {
            if (x < SQRT1_2)
            {   // 2(2x - 1)/(2x + 1)
                exp -= 1;
                z = x - 0.5;
                y = 0.5 * z + 0.5;
            }
            else
            {   // 2(x - 1)/(x + 1)
                z = x - 0.5;
                z -= 0.5;
                y = 0.5 * x  + 0.5;
            }
            x = z / y;
            z = x * x;
            z = x * (z * poly(z, logCoeffsR) / poly(z, logCoeffsS));
            z += exp * C2;
            z += x;
            z += exp * C1;

            return z;
        }

        // Logarithm using log(1 + x) = x - .5x^^2 + x^^3 P(x) / Q(x)
        if (x < SQRT1_2)
        {
            exp -= 1;
            x = 2.0 * x - 1.0;
        }
        else
        {
            x = x - 1.0;
        }
        z = x * x;
        y = x * (z * poly(x, logCoeffsP) / poly(x, logCoeffsQ));
        y += exp * C2;
        z = y - 0.5 * z;

        // Note, the sum of above terms does not exceed x/4,
        // so it contributes at most about 1/4 lsb to the error.
        z += x;
        z += exp * C1;

        return z;
    }
}

///
@safe pure nothrow @nogc unittest
{
    assert(feqrel(log(E), 1) >= real.mant_dig - 1);
}

/**************************************
 * Calculate the base-10 logarithm of x.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)            $(TH log10(x))  $(TH divide by 0?) $(TH invalid?))
 *      $(TR $(TD $(PLUSMN)0.0) $(TD -$(INFIN)) $(TD yes)          $(TD no))
 *      $(TR $(TD $(LT)0.0)     $(TD $(NAN))    $(TD no)           $(TD yes))
 *      $(TR $(TD +$(INFIN))    $(TD +$(INFIN)) $(TD no)           $(TD no))
 *      )
 */
real log10(real x) @safe pure nothrow @nogc
{
    version (INLINE_YL2X)
        return core.math.yl2x(x, LOG2);
    else
    {
        // log10(2) split into two parts.
        enum real L102A =  0.3125L;
        enum real L102B = -1.14700043360188047862611052755069732318101185E-2L;

        // log10(e) split into two parts.
        enum real L10EA =  0.5L;
        enum real L10EB = -6.570551809674817234887108108339491770560299E-2L;

        // Special cases are the same as for log.
        if (isNaN(x))
            return x;
        if (isInfinity(x) && !signbit(x))
            return x;
        if (x == 0.0)
            return -real.infinity;
        if (x < 0.0)
            return real.nan;

        // Separate mantissa from exponent.
        // Note, frexp is used so that denormal numbers will be handled properly.
        real y, z;
        int exp;

        x = frexp(x, exp);

        // Logarithm using log(x) = z + z^^3 R(z) / S(z),
        // where z = 2(x - 1)/(x + 1)
        if ((exp > 2) || (exp < -2))
        {
            if (x < SQRT1_2)
            {   // 2(2x - 1)/(2x + 1)
                exp -= 1;
                z = x - 0.5;
                y = 0.5 * z + 0.5;
            }
            else
            {   // 2(x - 1)/(x + 1)
                z = x - 0.5;
                z -= 0.5;
                y = 0.5 * x  + 0.5;
            }
            x = z / y;
            z = x * x;
            y = x * (z * poly(z, logCoeffsR) / poly(z, logCoeffsS));
            goto Ldone;
        }

        // Logarithm using log(1 + x) = x - .5x^^2 + x^^3 P(x) / Q(x)
        if (x < SQRT1_2)
        {
            exp -= 1;
            x = 2.0 * x - 1.0;
        }
        else
            x = x - 1.0;

        z = x * x;
        y = x * (z * poly(x, logCoeffsP) / poly(x, logCoeffsQ));
        y = y - 0.5 * z;

        // Multiply log of fraction by log10(e) and base 2 exponent by log10(2).
        // This sequence of operations is critical and it may be horribly
        // defeated by some compiler optimizers.
    Ldone:
        z = y * L10EB;
        z += x * L10EB;
        z += exp * L102B;
        z += y * L10EA;
        z += x * L10EA;
        z += exp * L102A;

        return z;
    }
}

///
@safe pure nothrow @nogc unittest
{
    assert(fabs(log10(1000) - 3) < .000001);
}

/**
 * Calculates the natural logarithm of 1 + x.
 *
 * For very small x, log1p(x) will be more accurate than
 * log(1 + x).
 *
 *  $(TABLE_SV
 *  $(TR $(TH x)            $(TH log1p(x))     $(TH divide by 0?) $(TH invalid?))
 *  $(TR $(TD $(PLUSMN)0.0) $(TD $(PLUSMN)0.0) $(TD no)           $(TD no))
 *  $(TR $(TD -1.0)         $(TD -$(INFIN))    $(TD yes)          $(TD no))
 *  $(TR $(TD $(LT)-1.0)    $(TD -$(NAN))      $(TD no)           $(TD yes))
 *  $(TR $(TD +$(INFIN))    $(TD +$(INFIN))    $(TD no)           $(TD no))
 *  )
 */
real log1p(real x) @safe pure nothrow @nogc
{
    version (INLINE_YL2X)
    {
        // On x87, yl2xp1 is valid if and only if -0.5 <= lg(x) <= 0.5,
        //    ie if -0.29 <= x <= 0.414
        return (fabs(x) <= 0.25)  ? core.math.yl2xp1(x, LN2) : core.math.yl2x(x+1, LN2);
    }
    else
    {
        // Special cases.
        if (isNaN(x) || x == 0.0)
            return x;
        if (isInfinity(x) && !signbit(x))
            return x;
        if (x == -1.0)
            return -real.infinity;
        if (x < -1.0)
            return real.nan;

        return log(x + 1.0);
    }
}

///
@safe pure unittest
{
    assert(isIdentical(log1p(0.0), 0.0));
    assert(log1p(1.0).feqrel(0.69314) > 16);

    assert(log1p(-1.0) == -real.infinity);
    assert(isNaN(log1p(-2.0)));
    assert(log1p(real.nan) is real.nan);
    assert(log1p(-real.nan) is -real.nan);
    assert(log1p(real.infinity) == real.infinity);
}

/***************************************
 * Calculates the base-2 logarithm of x:
 * $(SUB log, 2)x
 *
 *  $(TABLE_SV
 *  $(TR $(TH x)            $(TH log2(x))   $(TH divide by 0?) $(TH invalid?))
 *  $(TR $(TD $(PLUSMN)0.0) $(TD -$(INFIN)) $(TD yes)          $(TD no) )
 *  $(TR $(TD $(LT)0.0)     $(TD $(NAN))    $(TD no)           $(TD yes) )
 *  $(TR $(TD +$(INFIN))    $(TD +$(INFIN)) $(TD no)           $(TD no) )
 *  )
 */
real log2(real x) @safe pure nothrow @nogc
{
    version (INLINE_YL2X)
        return core.math.yl2x(x, 1.0L);
    else
    {
        // Special cases are the same as for log.
        if (isNaN(x))
            return x;
        if (isInfinity(x) && !signbit(x))
            return x;
        if (x == 0.0)
            return -real.infinity;
        if (x < 0.0)
            return real.nan;

        // Separate mantissa from exponent.
        // Note, frexp is used so that denormal numbers will be handled properly.
        real y, z;
        int exp;

        x = frexp(x, exp);

        // Logarithm using log(x) = z + z^^3 R(z) / S(z),
        // where z = 2(x - 1)/(x + 1)
        if ((exp > 2) || (exp < -2))
        {
            if (x < SQRT1_2)
            {   // 2(2x - 1)/(2x + 1)
                exp -= 1;
                z = x - 0.5;
                y = 0.5 * z + 0.5;
            }
            else
            {   // 2(x - 1)/(x + 1)
                z = x - 0.5;
                z -= 0.5;
                y = 0.5 * x  + 0.5;
            }
            x = z / y;
            z = x * x;
            y = x * (z * poly(z, logCoeffsR) / poly(z, logCoeffsS));
            goto Ldone;
        }

        // Logarithm using log(1 + x) = x - .5x^^2 + x^^3 P(x) / Q(x)
        if (x < SQRT1_2)
        {
            exp -= 1;
            x = 2.0 * x - 1.0;
        }
        else
            x = x - 1.0;

        z = x * x;
        y = x * (z * poly(x, logCoeffsP) / poly(x, logCoeffsQ));
        y = y - 0.5 * z;

        // Multiply log of fraction by log10(e) and base 2 exponent by log10(2).
        // This sequence of operations is critical and it may be horribly
        // defeated by some compiler optimizers.
    Ldone:
        z = y * (LOG2E - 1.0);
        z += x * (LOG2E - 1.0);
        z += y;
        z += x;
        z += exp;

        return z;
    }
}

///
@safe unittest
{
    assert(isClose(log2(1024.0L), 10));
}

@safe @nogc nothrow unittest
{
    // check if values are equal to 19 decimal digits of precision
    assert(equalsDigit(log2(1024.0L), 10, 19));
}

/*****************************************
 * Extracts the exponent of x as a signed integral value.
 *
 * If x is subnormal, it is treated as if it were normalized.
 * For a positive, finite x:
 *
 * 1 $(LT)= $(I x) * FLT_RADIX$(SUPERSCRIPT -logb(x)) $(LT) FLT_RADIX
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH logb(x))   $(TH divide by 0?) )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD +$(INFIN)) $(TD no))
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD -$(INFIN)) $(TD yes) )
 *      )
 */
real logb(real x) @trusted nothrow @nogc
{
    version (InlineAsm_X87_MSVC)
    {
        version (X86_64)
        {
            asm pure nothrow @nogc
            {
                naked                       ;
                fld     real ptr [RCX]      ;
                fxtract                     ;
                fstp    ST(0)               ;
                ret                         ;
            }
        }
        else
        {
            asm pure nothrow @nogc
            {
                fld     x                   ;
                fxtract                     ;
                fstp    ST(0)               ;
            }
        }
    }
    else
        return core.stdc.math.logbl(x);
}

///
@safe @nogc nothrow unittest
{
    assert(logb(1.0) == 0);
    assert(logb(100.0) == 6);

    assert(logb(0.0) == -real.infinity);
    assert(logb(real.infinity) == real.infinity);
    assert(logb(-real.infinity) == real.infinity);
}

/************************************
 * Calculates the remainder from the calculation x/y.
 * Returns:
 * The value of x - i * y, where i is the number of times that y can
 * be completely subtracted from x. The result has the same sign as x.
 *
 * $(TABLE_SV
 *  $(TR $(TH x)              $(TH y)             $(TH fmod(x, y))   $(TH invalid?))
 *  $(TR $(TD $(PLUSMN)0.0)   $(TD not 0.0)       $(TD $(PLUSMN)0.0) $(TD no))
 *  $(TR $(TD $(PLUSMNINF))   $(TD anything)      $(TD $(NAN))       $(TD yes))
 *  $(TR $(TD anything)       $(TD $(PLUSMN)0.0)  $(TD $(NAN))       $(TD yes))
 *  $(TR $(TD !=$(PLUSMNINF)) $(TD $(PLUSMNINF))  $(TD x)            $(TD no))
 * )
 */
real fmod(real x, real y) @trusted nothrow @nogc
{
    version (CRuntime_Microsoft)
    {
        return x % y;
    }
    else
        return core.stdc.math.fmodl(x, y);
}

///
@safe unittest
{
    assert(isIdentical(fmod(0.0, 1.0), 0.0));
    assert(fmod(5.0, 3.0).feqrel(2.0) > 16);
    assert(isNaN(fmod(5.0, 0.0)));
}

/************************************
 * Breaks x into an integral part and a fractional part, each of which has
 * the same sign as x. The integral part is stored in i.
 * Returns:
 * The fractional part of x.
 *
 * $(TABLE_SV
 *  $(TR $(TH x)              $(TH i (on input))  $(TH modf(x, i))   $(TH i (on return)))
 *  $(TR $(TD $(PLUSMNINF))   $(TD anything)      $(TD $(PLUSMN)0.0) $(TD $(PLUSMNINF)))
 * )
 */
real modf(real x, ref real i) @trusted nothrow @nogc
{
    version (CRuntime_Microsoft)
    {
        i = trunc(x);
        return copysign(isInfinity(x) ? 0.0 : x - i, x);
    }
    else
        return core.stdc.math.modfl(x,&i);
}

///
@safe unittest
{
    real frac;
    real intpart;

    frac = modf(3.14159, intpart);
    assert(intpart.feqrel(3.0) > 16);
    assert(frac.feqrel(0.14159) > 16);
}

/*************************************
 * Efficiently calculates x * 2$(SUPERSCRIPT n).
 *
 * scalbn handles underflow and overflow in
 * the same fashion as the basic arithmetic operators.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH scalb(x)))
 *      $(TR $(TD $(PLUSMNINF))      $(TD $(PLUSMNINF)) )
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD $(PLUSMN)0.0) )
 *      )
 */
pragma(inline, true)
real scalbn(real x, int n) @safe pure nothrow @nogc { return _scalbn(x,n); }

/// ditto
pragma(inline, true)
double scalbn(double x, int n) @safe pure nothrow @nogc { return _scalbn(x,n); }

/// ditto
pragma(inline, true)
float scalbn(float x, int n) @safe pure nothrow @nogc { return _scalbn(x,n); }

///
@safe pure nothrow @nogc unittest
{
    assert(scalbn(0x1.2345678abcdefp0L, 999) == 0x1.2345678abcdefp999L);
    assert(scalbn(-real.infinity, 5) == -real.infinity);
    assert(scalbn(2.0,10) == 2048.0);
    assert(scalbn(2048.0f,-10) == 2.0f);
}

pragma(inline, true)
private F _scalbn(F)(F x, int n)
{
    if (__ctfe)
    {
        // Handle special cases.
        if (x == F(0.0) || isInfinity(x))
            return x;
    }
    return core.math.ldexp(x, n);
}

@safe pure nothrow @nogc unittest
{
    // CTFE-able test
    static assert(scalbn(0x1.2345678abcdefp0L, 999) == 0x1.2345678abcdefp999L);
    static assert(scalbn(-real.infinity, 5) == -real.infinity);
    // Test with large exponent delta n where the result is in bounds but 2.0L ^^ n is not.
    enum initialExponent = real.min_exp + 2, resultExponent = real.max_exp - 2;
    enum int n = resultExponent - initialExponent;
    enum real x = 0x1.2345678abcdefp0L * (2.0L ^^ initialExponent);
    enum staticResult = scalbn(x, n);
    static assert(staticResult == 0x1.2345678abcdefp0L * (2.0L ^^ resultExponent));
    assert(scalbn(x, n) == staticResult);
}

/***************
 * Calculates the cube root of x.
 *
 *      $(TABLE_SV
 *      $(TR $(TH $(I x))            $(TH cbrt(x))           $(TH invalid?))
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD $(PLUSMN)0.0)      $(TD no) )
 *      $(TR $(TD $(NAN))            $(TD $(NAN))            $(TD yes) )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(PLUSMN)$(INFIN)) $(TD no) )
 *      )
 */
real cbrt(real x) @trusted nothrow @nogc
{
    version (CRuntime_Microsoft)
    {
        version (INLINE_YL2X)
            return copysign(exp2(core.math.yl2x(fabs(x), 1.0L/3.0L)), x);
        else
            return core.stdc.math.cbrtl(x);
    }
    else
        return core.stdc.math.cbrtl(x);
}

///
@safe unittest
{
    assert(cbrt(1.0).feqrel(1.0) > 16);
    assert(cbrt(27.0).feqrel(3.0) > 16);
    assert(cbrt(15.625).feqrel(2.5) > 16);
}

/*******************************
 * Returns |x|
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH fabs(x)))
 *      $(TR $(TD $(PLUSMN)0.0)      $(TD +0.0) )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD +$(INFIN)) )
 *      )
 */
pragma(inline, true)
real fabs(real x) @safe pure nothrow @nogc { return core.math.fabs(x); }

///ditto
pragma(inline, true)
double fabs(double d) @trusted pure nothrow @nogc
{
    ulong tmp = *cast(ulong*)&d & 0x7FFF_FFFF_FFFF_FFFF;
    return *cast(double*)&tmp;
}

///ditto
pragma(inline, true)
float fabs(float f) @trusted pure nothrow @nogc
{
    uint tmp = *cast(uint*)&f & 0x7FFF_FFFF;
    return *cast(float*)&tmp;
}

///
@safe unittest
{

    assert(isIdentical(fabs(0.0f), 0.0f));
    assert(isIdentical(fabs(-0.0f), 0.0f));
    assert(fabs(-10.0f) == 10.0f);

    assert(isIdentical(fabs(0.0), 0.0));
    assert(isIdentical(fabs(-0.0), 0.0));
    assert(fabs(-10.0) == 10.0);

    assert(isIdentical(fabs(0.0L), 0.0L));
    assert(isIdentical(fabs(-0.0L), 0.0L));
    assert(fabs(-10.0L) == 10.0L);
}

@safe unittest
{
    real function(real) pfabs = &fabs;
    assert(pfabs != null);
}

/***********************************************************************
 * Calculates the length of the
 * hypotenuse of a right-angled triangle with sides of length x and y.
 * The hypotenuse is the value of the square root of
 * the sums of the squares of x and y:
 *
 *      sqrt($(POWER x, 2) + $(POWER y, 2))
 *
 * Note that hypot(x, y), hypot(y, x) and
 * hypot(x, -y) are equivalent.
 *
 *  $(TABLE_SV
 *  $(TR $(TH x)            $(TH y)            $(TH hypot(x, y)) $(TH invalid?))
 *  $(TR $(TD x)            $(TD $(PLUSMN)0.0) $(TD |x|)         $(TD no))
 *  $(TR $(TD $(PLUSMNINF)) $(TD y)            $(TD +$(INFIN))   $(TD no))
 *  $(TR $(TD $(PLUSMNINF)) $(TD $(NAN))       $(TD +$(INFIN))   $(TD no))
 *  )
 */

real hypot(real x, real y) @safe pure nothrow @nogc
{
    // Scale x and y to avoid underflow and overflow.
    // If one is huge and the other tiny, return the larger.
    // If both are huge, avoid overflow by scaling by 1/sqrt(real.max/2).
    // If both are tiny, avoid underflow by scaling by sqrt(real.min_normal*real.epsilon).

    enum real SQRTMIN = 0.5 * sqrt(real.min_normal); // This is a power of 2.
    enum real SQRTMAX = 1.0L / SQRTMIN; // 2^^((max_exp)/2) = nextUp(sqrt(real.max))

    static assert(2*(SQRTMAX/2)*(SQRTMAX/2) <= real.max);

    // Proves that sqrt(real.max) ~~  0.5/sqrt(real.min_normal)
    static assert(real.min_normal*real.max > 2 && real.min_normal*real.max <= 4);

    real u = fabs(x);
    real v = fabs(y);
    if (!(u >= v))  // check for NaN as well.
    {
        v = u;
        u = fabs(y);
        if (u == real.infinity) return u; // hypot(inf, nan) == inf
        if (v == real.infinity) return v; // hypot(nan, inf) == inf
    }

    // Now u >= v, or else one is NaN.
    if (v >= SQRTMAX*0.5)
    {
            // hypot(huge, huge) -- avoid overflow
        u *= SQRTMIN*0.5;
        v *= SQRTMIN*0.5;
        return sqrt(u*u + v*v) * SQRTMAX * 2.0;
    }

    if (u <= SQRTMIN)
    {
        // hypot (tiny, tiny) -- avoid underflow
        // This is only necessary to avoid setting the underflow
        // flag.
        u *= SQRTMAX / real.epsilon;
        v *= SQRTMAX / real.epsilon;
        return sqrt(u*u + v*v) * SQRTMIN * real.epsilon;
    }

    if (u * real.epsilon > v)
    {
        // hypot (huge, tiny) = huge
        return u;
    }

    // both are in the normal range
    return sqrt(u*u + v*v);
}

///
@safe unittest
{
    assert(hypot(1.0, 1.0).feqrel(1.4142) > 16);
    assert(hypot(3.0, 4.0).feqrel(5.0) > 16);
    assert(hypot(real.infinity, 1.0) == real.infinity);
    assert(hypot(real.infinity, real.nan) == real.infinity);
}

@safe unittest
{
    static real[3][] vals =     // x,y,hypot
        [
            [ 0.0,     0.0,   0.0],
            [ 0.0,    -0.0,   0.0],
            [ -0.0,   -0.0,   0.0],
            [ 3.0,     4.0,   5.0],
            [ -300,   -400,   500],
            [0.0,      7.0,   7.0],
            [9.0,   9*real.epsilon,   9.0],
            [88/(64*sqrt(real.min_normal)), 105/(64*sqrt(real.min_normal)), 137/(64*sqrt(real.min_normal))],
            [88/(128*sqrt(real.min_normal)), 105/(128*sqrt(real.min_normal)), 137/(128*sqrt(real.min_normal))],
            [3*real.min_normal*real.epsilon, 4*real.min_normal*real.epsilon, 5*real.min_normal*real.epsilon],
            [ real.min_normal, real.min_normal, sqrt(2.0L)*real.min_normal],
            [ real.max/sqrt(2.0L), real.max/sqrt(2.0L), real.max],
            [ real.infinity, real.nan, real.infinity],
            [ real.nan, real.infinity, real.infinity],
            [ real.nan, real.nan, real.nan],
            [ real.nan, real.max, real.nan],
            [ real.max, real.nan, real.nan],
        ];
        for (int i = 0; i < vals.length; i++)
        {
            real x = vals[i][0];
            real y = vals[i][1];
            real z = vals[i][2];
            real h = hypot(x, y);
            assert(isIdentical(z,h) || feqrel(z, h) >= real.mant_dig - 1);
        }
}

/**************************************
 * Returns the value of x rounded upward to the next integer
 * (toward positive infinity).
 */
real ceil(real x) @trusted pure nothrow @nogc
{
    version (InlineAsm_X87_MSVC)
    {
        version (X86_64)
        {
            asm pure nothrow @nogc
            {
                naked                       ;
                fld     real ptr [RCX]      ;
                fstcw   8[RSP]              ;
                mov     AL,9[RSP]           ;
                mov     DL,AL               ;
                and     AL,0xC3             ;
                or      AL,0x08             ; // round to +infinity
                mov     9[RSP],AL           ;
                fldcw   8[RSP]              ;
                frndint                     ;
                mov     9[RSP],DL           ;
                fldcw   8[RSP]              ;
                ret                         ;
            }
        }
        else
        {
            short cw;
            asm pure nothrow @nogc
            {
                fld     x                   ;
                fstcw   cw                  ;
                mov     AL,byte ptr cw+1    ;
                mov     DL,AL               ;
                and     AL,0xC3             ;
                or      AL,0x08             ; // round to +infinity
                mov     byte ptr cw+1,AL    ;
                fldcw   cw                  ;
                frndint                     ;
                mov     byte ptr cw+1,DL    ;
                fldcw   cw                  ;
            }
        }
    }
    else
    {
        // Special cases.
        if (isNaN(x) || isInfinity(x))
            return x;

        real y = floorImpl(x);
        if (y < x)
            y += 1.0;

        return y;
    }
}

///
@safe pure nothrow @nogc unittest
{
    assert(ceil(+123.456L) == +124);
    assert(ceil(-123.456L) == -123);
    assert(ceil(-1.234L) == -1);
    assert(ceil(-0.123L) == 0);
    assert(ceil(0.0L) == 0);
    assert(ceil(+0.123L) == 1);
    assert(ceil(+1.234L) == 2);
    assert(ceil(real.infinity) == real.infinity);
    assert(isNaN(ceil(real.nan)));
    assert(isNaN(ceil(real.init)));
}

/// ditto
double ceil(double x) @trusted pure nothrow @nogc
{
    // Special cases.
    if (isNaN(x) || isInfinity(x))
        return x;

    double y = floorImpl(x);
    if (y < x)
        y += 1.0;

    return y;
}

@safe pure nothrow @nogc unittest
{
    assert(ceil(+123.456) == +124);
    assert(ceil(-123.456) == -123);
    assert(ceil(-1.234) == -1);
    assert(ceil(-0.123) == 0);
    assert(ceil(0.0) == 0);
    assert(ceil(+0.123) == 1);
    assert(ceil(+1.234) == 2);
    assert(ceil(double.infinity) == double.infinity);
    assert(isNaN(ceil(double.nan)));
    assert(isNaN(ceil(double.init)));
}

/// ditto
float ceil(float x) @trusted pure nothrow @nogc
{
    // Special cases.
    if (isNaN(x) || isInfinity(x))
        return x;

    float y = floorImpl(x);
    if (y < x)
        y += 1.0;

    return y;
}

@safe pure nothrow @nogc unittest
{
    assert(ceil(+123.456f) == +124);
    assert(ceil(-123.456f) == -123);
    assert(ceil(-1.234f) == -1);
    assert(ceil(-0.123f) == 0);
    assert(ceil(0.0f) == 0);
    assert(ceil(+0.123f) == 1);
    assert(ceil(+1.234f) == 2);
    assert(ceil(float.infinity) == float.infinity);
    assert(isNaN(ceil(float.nan)));
    assert(isNaN(ceil(float.init)));
}

/**************************************
 * Returns the value of x rounded downward to the next integer
 * (toward negative infinity).
 */
real floor(real x) @trusted pure nothrow @nogc
{
    version (InlineAsm_X87_MSVC)
    {
        version (X86_64)
        {
            asm pure nothrow @nogc
            {
                naked                       ;
                fld     real ptr [RCX]      ;
                fstcw   8[RSP]              ;
                mov     AL,9[RSP]           ;
                mov     DL,AL               ;
                and     AL,0xC3             ;
                or      AL,0x04             ; // round to -infinity
                mov     9[RSP],AL           ;
                fldcw   8[RSP]              ;
                frndint                     ;
                mov     9[RSP],DL           ;
                fldcw   8[RSP]              ;
                ret                         ;
            }
        }
        else
        {
            short cw;
            asm pure nothrow @nogc
            {
                fld     x                   ;
                fstcw   cw                  ;
                mov     AL,byte ptr cw+1    ;
                mov     DL,AL               ;
                and     AL,0xC3             ;
                or      AL,0x04             ; // round to -infinity
                mov     byte ptr cw+1,AL    ;
                fldcw   cw                  ;
                frndint                     ;
                mov     byte ptr cw+1,DL    ;
                fldcw   cw                  ;
            }
        }
    }
    else
    {
        // Special cases.
        if (isNaN(x) || isInfinity(x) || x == 0.0)
            return x;

        return floorImpl(x);
    }
}

///
@safe pure nothrow @nogc unittest
{
    assert(floor(+123.456L) == +123);
    assert(floor(-123.456L) == -124);
    assert(floor(+123.0L) == +123);
    assert(floor(-124.0L) == -124);
    assert(floor(-1.234L) == -2);
    assert(floor(-0.123L) == -1);
    assert(floor(0.0L) == 0);
    assert(floor(+0.123L) == 0);
    assert(floor(+1.234L) == 1);
    assert(floor(real.infinity) == real.infinity);
    assert(isNaN(floor(real.nan)));
    assert(isNaN(floor(real.init)));
}

/// ditto
double floor(double x) @trusted pure nothrow @nogc
{
    // Special cases.
    if (isNaN(x) || isInfinity(x) || x == 0.0)
        return x;

    return floorImpl(x);
}

@safe pure nothrow @nogc unittest
{
    assert(floor(+123.456) == +123);
    assert(floor(-123.456) == -124);
    assert(floor(+123.0) == +123);
    assert(floor(-124.0) == -124);
    assert(floor(-1.234) == -2);
    assert(floor(-0.123) == -1);
    assert(floor(0.0) == 0);
    assert(floor(+0.123) == 0);
    assert(floor(+1.234) == 1);
    assert(floor(double.infinity) == double.infinity);
    assert(isNaN(floor(double.nan)));
    assert(isNaN(floor(double.init)));
}

/// ditto
float floor(float x) @trusted pure nothrow @nogc
{
    // Special cases.
    if (isNaN(x) || isInfinity(x) || x == 0.0)
        return x;

    return floorImpl(x);
}

@safe pure nothrow @nogc unittest
{
    assert(floor(+123.456f) == +123);
    assert(floor(-123.456f) == -124);
    assert(floor(+123.0f) == +123);
    assert(floor(-124.0f) == -124);
    assert(floor(-1.234f) == -2);
    assert(floor(-0.123f) == -1);
    assert(floor(0.0f) == 0);
    assert(floor(+0.123f) == 0);
    assert(floor(+1.234f) == 1);
    assert(floor(float.infinity) == float.infinity);
    assert(isNaN(floor(float.nan)));
    assert(isNaN(floor(float.init)));
}

/**
 * Round `val` to a multiple of `unit`. `rfunc` specifies the rounding
 * function to use; by default this is `rint`, which uses the current
 * rounding mode.
 */
Unqual!F quantize(alias rfunc = rint, F)(const F val, const F unit)
if (is(typeof(rfunc(F.init)) : F) && isFloatingPoint!F)
{
    typeof(return) ret = val;
    if (unit != 0)
    {
        const scaled = val / unit;
        if (!scaled.isInfinity)
            ret = rfunc(scaled) * unit;
    }
    return ret;
}

///
@safe pure nothrow @nogc unittest
{
    assert(isClose(12345.6789L.quantize(0.01L), 12345.68L));
    assert(isClose(12345.6789L.quantize!floor(0.01L), 12345.67L));
    assert(isClose(12345.6789L.quantize(22.0L), 12342.0L));
}

///
@safe pure nothrow @nogc unittest
{
    assert(isClose(12345.6789L.quantize(0), 12345.6789L));
    assert(12345.6789L.quantize(real.infinity).isNaN);
    assert(12345.6789L.quantize(real.nan).isNaN);
    assert(real.infinity.quantize(0.01L) == real.infinity);
    assert(real.infinity.quantize(real.nan).isNaN);
    assert(real.nan.quantize(0.01L).isNaN);
    assert(real.nan.quantize(real.infinity).isNaN);
    assert(real.nan.quantize(real.nan).isNaN);
}

/**
 * Round `val` to a multiple of `pow(base, exp)`. `rfunc` specifies the
 * rounding function to use; by default this is `rint`, which uses the
 * current rounding mode.
 */
Unqual!F quantize(real base, alias rfunc = rint, F, E)(const F val, const E exp)
if (is(typeof(rfunc(F.init)) : F) && isFloatingPoint!F && isIntegral!E)
{
    // TODO: Compile-time optimization for power-of-two bases?
    return quantize!rfunc(val, pow(cast(F) base, exp));
}

/// ditto
Unqual!F quantize(real base, long exp = 1, alias rfunc = rint, F)(const F val)
if (is(typeof(rfunc(F.init)) : F) && isFloatingPoint!F)
{
    enum unit = cast(F) pow(base, exp);
    return quantize!rfunc(val, unit);
}

///
@safe pure nothrow @nogc unittest
{
    assert(isClose(12345.6789L.quantize!10(-2), 12345.68L));
    assert(isClose(12345.6789L.quantize!(10, -2), 12345.68L));
    assert(isClose(12345.6789L.quantize!(10, floor)(-2), 12345.67L));
    assert(isClose(12345.6789L.quantize!(10, -2, floor), 12345.67L));

    assert(isClose(12345.6789L.quantize!22(1), 12342.0L));
    assert(isClose(12345.6789L.quantize!22, 12342.0L));
}

@safe pure nothrow @nogc unittest
{
    import std.meta : AliasSeq;

    static foreach (F; AliasSeq!(real, double, float))
    {{
        const maxL10 = cast(int) F.max.log10.floor;
        const maxR10 = pow(cast(F) 10, maxL10);
        assert(isClose((cast(F) 0.9L * maxR10).quantize!10(maxL10), maxR10));
        assert(isClose((cast(F)-0.9L * maxR10).quantize!10(maxL10), -maxR10));

        assert(F.max.quantize(F.min_normal) == F.max);
        assert((-F.max).quantize(F.min_normal) == -F.max);
        assert(F.min_normal.quantize(F.max) == 0);
        assert((-F.min_normal).quantize(F.max) == 0);
        assert(F.min_normal.quantize(F.min_normal) == F.min_normal);
        assert((-F.min_normal).quantize(F.min_normal) == -F.min_normal);
    }}
}

/******************************************
 * Rounds x to the nearest integer value, using the current rounding
 * mode.
 *
 * Unlike the rint functions, nearbyint does not raise the
 * FE_INEXACT exception.
 */
pragma(inline, true)
real nearbyint(real x) @safe pure nothrow @nogc
{
    return core.stdc.math.nearbyintl(x);
}

///
@safe pure unittest
{
    assert(nearbyint(0.4) == 0);
    assert(nearbyint(0.5) == 0);
    assert(nearbyint(0.6) == 1);
    assert(nearbyint(100.0) == 100);

    assert(isNaN(nearbyint(real.nan)));
    assert(nearbyint(real.infinity) == real.infinity);
    assert(nearbyint(-real.infinity) == -real.infinity);
}

/**********************************
 * Rounds x to the nearest integer value, using the current rounding
 * mode.
 *
 * If the return value is not equal to x, the FE_INEXACT
 * exception is raised.
 *
 * $(LREF nearbyint) performs the same operation, but does
 * not set the FE_INEXACT exception.
 */
pragma(inline, true)
real rint(real x) @safe pure nothrow @nogc
{
    return core.math.rint(x);
}
///ditto
pragma(inline, true)
double rint(double x) @safe pure nothrow @nogc
{
    return core.math.rint(x);
}
///ditto
pragma(inline, true)
float rint(float x) @safe pure nothrow @nogc
{
    return core.math.rint(x);
}

///
@safe unittest
{
    version (IeeeFlagsSupport) resetIeeeFlags();
    assert(rint(0.4) == 0);
    version (IeeeFlagsSupport) assert(ieeeFlags.inexact);

    assert(rint(0.5) == 0);
    assert(rint(0.6) == 1);
    assert(rint(100.0) == 100);

    assert(isNaN(rint(real.nan)));
    assert(rint(real.infinity) == real.infinity);
    assert(rint(-real.infinity) == -real.infinity);
}

@safe unittest
{
    real function(real) print = &rint;
    assert(print != null);
}

/***************************************
 * Rounds x to the nearest integer value, using the current rounding
 * mode.
 *
 * This is generally the fastest method to convert a floating-point number
 * to an integer. Note that the results from this function
 * depend on the rounding mode, if the fractional part of x is exactly 0.5.
 * If using the default rounding mode (ties round to even integers)
 * lrint(4.5) == 4, lrint(5.5)==6.
 */
long lrint(real x) @trusted pure nothrow @nogc
{
    version (InlineAsm_X87)
    {
        version (Win64)
        {
            asm pure nothrow @nogc
            {
                naked;
                fld     real ptr [RCX];
                fistp   qword ptr 8[RSP];
                mov     RAX,8[RSP];
                ret;
            }
        }
        else
        {
            long n;
            asm pure nothrow @nogc
            {
                fld x;
                fistp n;
            }
            return n;
        }
    }
    else
    {
        alias F = floatTraits!(real);
        static if (F.realFormat == RealFormat.ieeeDouble)
        {
            long result;

            // Rounding limit when casting from real(double) to ulong.
            enum real OF = 4.50359962737049600000E15L;

            uint* vi = cast(uint*)(&x);

            // Find the exponent and sign
            uint msb = vi[MANTISSA_MSB];
            uint lsb = vi[MANTISSA_LSB];
            int exp = ((msb >> 20) & 0x7ff) - 0x3ff;
            const int sign = msb >> 31;
            msb &= 0xfffff;
            msb |= 0x100000;

            if (exp < 63)
            {
                if (exp >= 52)
                    result = (cast(long) msb << (exp - 20)) | (lsb << (exp - 52));
                else
                {
                    // Adjust x and check result.
                    const real j = sign ? -OF : OF;
                    x = (j + x) - j;
                    msb = vi[MANTISSA_MSB];
                    lsb = vi[MANTISSA_LSB];
                    exp = ((msb >> 20) & 0x7ff) - 0x3ff;
                    msb &= 0xfffff;
                    msb |= 0x100000;

                    if (exp < 0)
                        result = 0;
                    else if (exp < 20)
                        result = cast(long) msb >> (20 - exp);
                    else if (exp == 20)
                        result = cast(long) msb;
                    else
                        result = (cast(long) msb << (exp - 20)) | (lsb >> (52 - exp));
                }
            }
            else
            {
                // It is left implementation defined when the number is too large.
                return cast(long) x;
            }

            return sign ? -result : result;
        }
        else static if (F.realFormat == RealFormat.ieeeExtended ||
                        F.realFormat == RealFormat.ieeeExtended53)
        {
            long result;

            // Rounding limit when casting from real(80-bit) to ulong.
            static if (F.realFormat == RealFormat.ieeeExtended)
                enum real OF = 9.22337203685477580800E18L;
            else
                enum real OF = 4.50359962737049600000E15L;

            ushort* vu = cast(ushort*)(&x);
            uint* vi = cast(uint*)(&x);

            // Find the exponent and sign
            int exp = (vu[F.EXPPOS_SHORT] & 0x7fff) - 0x3fff;
            const int sign = (vu[F.EXPPOS_SHORT] >> 15) & 1;

            if (exp < 63)
            {
                // Adjust x and check result.
                const real j = sign ? -OF : OF;
                x = (j + x) - j;
                exp = (vu[F.EXPPOS_SHORT] & 0x7fff) - 0x3fff;

                version (LittleEndian)
                {
                    if (exp < 0)
                        result = 0;
                    else if (exp <= 31)
                        result = vi[1] >> (31 - exp);
                    else
                        result = (cast(long) vi[1] << (exp - 31)) | (vi[0] >> (63 - exp));
                }
                else
                {
                    if (exp < 0)
                        result = 0;
                    else if (exp <= 31)
                        result = vi[1] >> (31 - exp);
                    else
                        result = (cast(long) vi[1] << (exp - 31)) | (vi[2] >> (63 - exp));
                }
            }
            else
            {
                // It is left implementation defined when the number is too large
                // to fit in a 64bit long.
                return cast(long) x;
            }

            return sign ? -result : result;
        }
        else static if (F.realFormat == RealFormat.ieeeQuadruple)
        {
            const vu = cast(ushort*)(&x);

            // Find the exponent and sign
            const sign = (vu[F.EXPPOS_SHORT] >> 15) & 1;
            if ((vu[F.EXPPOS_SHORT] & F.EXPMASK) - (F.EXPBIAS + 1) > 63)
            {
                // The result is left implementation defined when the number is
                // too large to fit in a 64 bit long.
                return cast(long) x;
            }

            // Force rounding of lower bits according to current rounding
            // mode by adding ±2^-112 and subtracting it again.
            enum OF = 5.19229685853482762853049632922009600E33L;
            const j = sign ? -OF : OF;
            x = (j + x) - j;

            const exp = (vu[F.EXPPOS_SHORT] & F.EXPMASK) - (F.EXPBIAS + 1);
            const implicitOne = 1UL << 48;
            auto vl = cast(ulong*)(&x);
            vl[MANTISSA_MSB] &= implicitOne - 1;
            vl[MANTISSA_MSB] |= implicitOne;

            long result;

            if (exp < 0)
                result = 0;
            else if (exp <= 48)
                result = vl[MANTISSA_MSB] >> (48 - exp);
            else
                result = (vl[MANTISSA_MSB] << (exp - 48)) | (vl[MANTISSA_LSB] >> (112 - exp));

            return sign ? -result : result;
        }
        else
        {
            static assert(false, "real type not supported by lrint()");
        }
    }
}

///
@safe pure nothrow @nogc unittest
{
    assert(lrint(4.5) == 4);
    assert(lrint(5.5) == 6);
    assert(lrint(-4.5) == -4);
    assert(lrint(-5.5) == -6);

    assert(lrint(int.max - 0.5) == 2147483646L);
    assert(lrint(int.max + 0.5) == 2147483648L);
    assert(lrint(int.min - 0.5) == -2147483648L);
    assert(lrint(int.min + 0.5) == -2147483648L);
}

static if (real.mant_dig >= long.sizeof * 8)
{
    @safe pure nothrow @nogc unittest
    {
        assert(lrint(long.max - 1.5L) == long.max - 1);
        assert(lrint(long.max - 0.5L) == long.max - 1);
        assert(lrint(long.min + 0.5L) == long.min);
        assert(lrint(long.min + 1.5L) == long.min + 2);
    }
}

/*******************************************
 * Return the value of x rounded to the nearest integer.
 * If the fractional part of x is exactly 0.5, the return value is
 * rounded away from zero.
 *
 * Returns:
 *     A `real`.
 */
auto round(real x) @trusted nothrow @nogc
{
    version (CRuntime_Microsoft)
    {
        auto old = FloatingPointControl.getControlState();
        FloatingPointControl.setControlState(
            (old & (-1 - FloatingPointControl.roundingMask)) | FloatingPointControl.roundToZero
        );
        x = rint((x >= 0) ? x + 0.5 : x - 0.5);
        FloatingPointControl.setControlState(old);
        return x;
    }
    else
        return core.stdc.math.roundl(x);
}

///
@safe nothrow @nogc unittest
{
    assert(round(4.5) == 5);
    assert(round(5.4) == 5);
    assert(round(-4.5) == -5);
    assert(round(-5.1) == -5);
}

// assure purity on Posix
version (Posix)
{
    @safe pure nothrow @nogc unittest
    {
        assert(round(4.5) == 5);
    }
}

/**********************************************
 * Return the value of x rounded to the nearest integer.
 *
 * If the fractional part of x is exactly 0.5, the return value is rounded
 * away from zero.
 *
 * $(BLUE This function is not implemented for Digital Mars C runtime.)
 */
long lround(real x) @trusted nothrow @nogc
{
    version (CRuntime_DigitalMars)
        assert(0, "lround not implemented");
    else
        return core.stdc.math.llroundl(x);
}

///
@safe nothrow @nogc unittest
{
    version (CRuntime_DigitalMars) {}
    else
    {
        assert(lround(0.49) == 0);
        assert(lround(0.5) == 1);
        assert(lround(1.5) == 2);
    }
}

/**
 Returns the integer portion of x, dropping the fractional portion.
 This is also known as "chop" rounding.
 `pure` on all platforms.
 */
real trunc(real x) @trusted nothrow @nogc pure
{
    version (InlineAsm_X87_MSVC)
    {
        version (X86_64)
        {
            asm pure nothrow @nogc
            {
                naked                       ;
                fld     real ptr [RCX]      ;
                fstcw   8[RSP]              ;
                mov     AL,9[RSP]           ;
                mov     DL,AL               ;
                and     AL,0xC3             ;
                or      AL,0x0C             ; // round to 0
                mov     9[RSP],AL           ;
                fldcw   8[RSP]              ;
                frndint                     ;
                mov     9[RSP],DL           ;
                fldcw   8[RSP]              ;
                ret                         ;
            }
        }
        else
        {
            short cw;
            asm pure nothrow @nogc
            {
                fld     x                   ;
                fstcw   cw                  ;
                mov     AL,byte ptr cw+1    ;
                mov     DL,AL               ;
                and     AL,0xC3             ;
                or      AL,0x0C             ; // round to 0
                mov     byte ptr cw+1,AL    ;
                fldcw   cw                  ;
                frndint                     ;
                mov     byte ptr cw+1,DL    ;
                fldcw   cw                  ;
            }
        }
    }
    else
        return core.stdc.math.truncl(x);
}

///
@safe pure unittest
{
    assert(trunc(0.01) == 0);
    assert(trunc(0.49) == 0);
    assert(trunc(0.5) == 0);
    assert(trunc(1.5) == 1);
}

/****************************************************
 * Calculate the remainder x REM y, following IEC 60559.
 *
 * REM is the value of x - y * n, where n is the integer nearest the exact
 * value of x / y.
 * If |n - x / y| == 0.5, n is even.
 * If the result is zero, it has the same sign as x.
 * Otherwise, the sign of the result is the sign of x / y.
 * Precision mode has no effect on the remainder functions.
 *
 * remquo returns `n` in the parameter `n`.
 *
 * $(TABLE_SV
 *  $(TR $(TH x)               $(TH y)            $(TH remainder(x, y)) $(TH n)   $(TH invalid?))
 *  $(TR $(TD $(PLUSMN)0.0)    $(TD not 0.0)      $(TD $(PLUSMN)0.0)    $(TD 0.0) $(TD no))
 *  $(TR $(TD $(PLUSMNINF))    $(TD anything)     $(TD -$(NAN))         $(TD ?)   $(TD yes))
 *  $(TR $(TD anything)        $(TD $(PLUSMN)0.0) $(TD $(PLUSMN)$(NAN)) $(TD ?)   $(TD yes))
 *  $(TR $(TD != $(PLUSMNINF)) $(TD $(PLUSMNINF)) $(TD x)               $(TD ?)   $(TD no))
 * )
 */
real remainder(real x, real y) @trusted nothrow @nogc
{
    return core.stdc.math.remainderl(x, y);
}

/// ditto
real remquo(real x, real y, out int n) @trusted nothrow @nogc  /// ditto
{
    return core.stdc.math.remquol(x, y, &n);
}

///
@safe @nogc nothrow unittest
{
    assert(remainder(5.1, 3.0).feqrel(-0.9) > 16);
    assert(remainder(-5.1, 3.0).feqrel(0.9) > 16);
    assert(remainder(0.0, 3.0) == 0.0);

    assert(isNaN(remainder(1.0, 0.0)));
    assert(isNaN(remainder(-1.0, 0.0)));
}

///
@safe @nogc nothrow unittest
{
    int n;

    assert(remquo(5.1, 3.0, n).feqrel(-0.9) > 16 && n == 2);
    assert(remquo(-5.1, 3.0, n).feqrel(0.9) > 16 && n == -2);
    assert(remquo(0.0, 3.0, n) == 0.0 && n == 0);
}


version (IeeeFlagsSupport)
{

/** IEEE exception status flags ('sticky bits')

 These flags indicate that an exceptional floating-point condition has occurred.
 They indicate that a NaN or an infinity has been generated, that a result
 is inexact, or that a signalling NaN has been encountered. If floating-point
 exceptions are enabled (unmasked), a hardware exception will be generated
 instead of setting these flags.
 */
struct IeeeFlags
{
nothrow @nogc:

private:
    // The x87 FPU status register is 16 bits.
    // The Pentium SSE2 status register is 32 bits.
    // The ARM and PowerPC FPSCR is a 32-bit register.
    // The SPARC FSR is a 32bit register (64 bits for SPARC 7 & 8, but high bits are uninteresting).
    // The RISC-V (32 & 64 bit) fcsr is 32-bit register.
    uint flags;

    version (CRuntime_Microsoft)
    {
        // Microsoft uses hardware-incompatible custom constants in fenv.h (core.stdc.fenv).
        // Applies to both x87 status word (16 bits) and SSE2 status word(32 bits).
        enum : int
        {
            INEXACT_MASK   = 0x20,
            UNDERFLOW_MASK = 0x10,
            OVERFLOW_MASK  = 0x08,
            DIVBYZERO_MASK = 0x04,
            INVALID_MASK   = 0x01,

            EXCEPTIONS_MASK = 0b11_1111
        }
        // Don't bother about subnormals, they are not supported on most CPUs.
        //  SUBNORMAL_MASK = 0x02;
    }
    else
    {
        enum : int
        {
            INEXACT_MASK    = core.stdc.fenv.FE_INEXACT,
            UNDERFLOW_MASK  = core.stdc.fenv.FE_UNDERFLOW,
            OVERFLOW_MASK   = core.stdc.fenv.FE_OVERFLOW,
            DIVBYZERO_MASK  = core.stdc.fenv.FE_DIVBYZERO,
            INVALID_MASK    = core.stdc.fenv.FE_INVALID,
            EXCEPTIONS_MASK = core.stdc.fenv.FE_ALL_EXCEPT,
        }
    }

    static uint getIeeeFlags() @trusted pure
    {
        version (InlineAsm_X86_Any)
        {
            ushort sw;
            asm pure nothrow @nogc { fstsw sw; }

            // OR the result with the SSE2 status register (MXCSR).
            if (haveSSE)
            {
                uint mxcsr;
                asm pure nothrow @nogc { stmxcsr mxcsr; }
                return (sw | mxcsr) & EXCEPTIONS_MASK;
            }
            else return sw & EXCEPTIONS_MASK;
        }
        else version (SPARC)
        {
           /*
               int retval;
               asm pure nothrow @nogc { st %fsr, retval; }
               return retval;
            */
           assert(0, "Not yet supported");
        }
        else version (ARM)
        {
            assert(false, "Not yet supported.");
        }
        else version (RISCV_Any)
        {
            mixin(`
            uint result = void;
            asm pure nothrow @nogc
            {
                "frflags %0" : "=r" (result);
            }
            return result;
            `);
        }
        else
            assert(0, "Not yet supported");
    }

    static void resetIeeeFlags() @trusted
    {
        version (InlineAsm_X86_Any)
        {
            asm nothrow @nogc
            {
                fnclex;
            }

            // Also clear exception flags in MXCSR, SSE's control register.
            if (haveSSE)
            {
                uint mxcsr;
                asm nothrow @nogc { stmxcsr mxcsr; }
                mxcsr &= ~EXCEPTIONS_MASK;
                asm nothrow @nogc { ldmxcsr mxcsr; }
            }
        }
        else version (RISCV_Any)
        {
            mixin(`
            uint newValues = 0x0;
            asm pure nothrow @nogc
            {
                "fsflags %0" : : "r" (newValues);
            }
            `);
        }
        else
        {
            /* SPARC:
              int tmpval;
              asm pure nothrow @nogc { st %fsr, tmpval; }
              tmpval &=0xFFFF_FC00;
              asm pure nothrow @nogc { ld tmpval, %fsr; }
            */
           assert(0, "Not yet supported");
        }
    }

public:
    /**
     * The result cannot be represented exactly, so rounding occurred.
     * Example: `x = sin(0.1);`
     */
    @property bool inexact() @safe const { return (flags & INEXACT_MASK) != 0; }

    /**
     * A zero was generated by underflow
     * Example: `x = real.min*real.epsilon/2;`
     */
    @property bool underflow() @safe const { return (flags & UNDERFLOW_MASK) != 0; }

    /**
     * An infinity was generated by overflow
     * Example: `x = real.max*2;`
     */
    @property bool overflow() @safe const { return (flags & OVERFLOW_MASK) != 0; }

    /**
     * An infinity was generated by division by zero
     * Example: `x = 3/0.0;`
     */
    @property bool divByZero() @safe const { return (flags & DIVBYZERO_MASK) != 0; }

    /**
     * A machine NaN was generated.
     * Example: `x = real.infinity * 0.0;`
     */
    @property bool invalid() @safe const { return (flags & INVALID_MASK) != 0; }
}

///
@safe unittest
{
    static void func() {
        int a = 10 * 10;
    }
    pragma(inline, false) static void blockopt(ref real x) {}
    real a = 3.5;
    // Set all the flags to zero
    resetIeeeFlags();
    assert(!ieeeFlags.divByZero);
    blockopt(a); // avoid constant propagation by the optimizer
    // Perform a division by zero.
    a /= 0.0L;
    assert(a == real.infinity);
    assert(ieeeFlags.divByZero);
    blockopt(a); // avoid constant propagation by the optimizer
    // Create a NaN
    a *= 0.0L;
    assert(ieeeFlags.invalid);
    assert(isNaN(a));

    // Check that calling func() has no effect on the
    // status flags.
    IeeeFlags f = ieeeFlags;
    func();
    assert(ieeeFlags == f);
}

@safe unittest
{
    import std.meta : AliasSeq;

    static struct Test
    {
        void delegate() @trusted action;
        bool function() @trusted ieeeCheck;
    }

    static foreach (T; AliasSeq!(float, double, real))
    {{
        T x; /* Needs to be here to trick -O. It would optimize away the
            calculations if x were local to the function literals. */
        auto tests = [
            Test(
                () { x = 1; x += 0.1L; },
                () => ieeeFlags.inexact
            ),
            Test(
                () { x = T.min_normal; x /= T.max; },
                () => ieeeFlags.underflow
            ),
            Test(
                () { x = T.max; x += T.max; },
                () => ieeeFlags.overflow
            ),
            Test(
                () { x = 1; x /= 0; },
                () => ieeeFlags.divByZero
            ),
            Test(
                () { x = 0; x /= 0; },
                () => ieeeFlags.invalid
            )
        ];
        foreach (test; tests)
        {
            resetIeeeFlags();
            assert(!test.ieeeCheck());
            test.action();
            assert(test.ieeeCheck());
        }
    }}
}

/// Set all of the floating-point status flags to false.
void resetIeeeFlags() @trusted nothrow @nogc
{
    IeeeFlags.resetIeeeFlags();
}

///
@safe unittest
{
    pragma(inline, false) static void blockopt(ref real x) {}
    resetIeeeFlags();
    real a = 3.5;
    blockopt(a); // avoid constant propagation by the optimizer
    a /= 0.0L;
    blockopt(a); // avoid constant propagation by the optimizer
    assert(a == real.infinity);
    assert(ieeeFlags.divByZero);

    resetIeeeFlags();
    assert(!ieeeFlags.divByZero);
}

/// Returns: snapshot of the current state of the floating-point status flags
@property IeeeFlags ieeeFlags() @trusted pure nothrow @nogc
{
   return IeeeFlags(IeeeFlags.getIeeeFlags());
}

///
@safe nothrow unittest
{
    pragma(inline, false) static void blockopt(ref real x) {}
    resetIeeeFlags();
    real a = 3.5;
    blockopt(a); // avoid constant propagation by the optimizer

    a /= 0.0L;
    assert(a == real.infinity);
    assert(ieeeFlags.divByZero);
    blockopt(a); // avoid constant propagation by the optimizer

    a *= 0.0L;
    assert(isNaN(a));
    assert(ieeeFlags.invalid);
}

} // IeeeFlagsSupport


version (FloatingPointControlSupport)
{

/** Control the Floating point hardware

  Change the IEEE754 floating-point rounding mode and the floating-point
  hardware exceptions.

  By default, the rounding mode is roundToNearest and all hardware exceptions
  are disabled. For most applications, debugging is easier if the $(I division
  by zero), $(I overflow), and $(I invalid operation) exceptions are enabled.
  These three are combined into a $(I severeExceptions) value for convenience.
  Note in particular that if $(I invalidException) is enabled, a hardware trap
  will be generated whenever an uninitialized floating-point variable is used.

  All changes are temporary. The previous state is restored at the
  end of the scope.


Example:
----
{
    FloatingPointControl fpctrl;

    // Enable hardware exceptions for division by zero, overflow to infinity,
    // invalid operations, and uninitialized floating-point variables.
    fpctrl.enableExceptions(FloatingPointControl.severeExceptions);

    // This will generate a hardware exception, if x is a
    // default-initialized floating point variable:
    real x; // Add `= 0` or even `= real.nan` to not throw the exception.
    real y = x * 3.0;

    // The exception is only thrown for default-uninitialized NaN-s.
    // NaN-s with other payload are valid:
    real z = y * real.nan; // ok

    // The set hardware exceptions and rounding modes will be disabled when
    // leaving this scope.
}
----

 */
struct FloatingPointControl
{
nothrow @nogc:

    alias RoundingMode = uint; ///

    version (StdDdoc)
    {
        enum : RoundingMode
        {
            /** IEEE rounding modes.
             * The default mode is roundToNearest.
             *
             *  roundingMask = A mask of all rounding modes.
             */
            roundToNearest,
            roundDown, /// ditto
            roundUp, /// ditto
            roundToZero, /// ditto
            roundingMask, /// ditto
        }
    }
    else version (CRuntime_Microsoft)
    {
        // Microsoft uses hardware-incompatible custom constants in fenv.h (core.stdc.fenv).
        enum : RoundingMode
        {
            roundToNearest = 0x0000,
            roundDown      = 0x0400,
            roundUp        = 0x0800,
            roundToZero    = 0x0C00,
            roundingMask   = roundToNearest | roundDown
                             | roundUp | roundToZero,
        }
    }
    else
    {
        enum : RoundingMode
        {
            roundToNearest = core.stdc.fenv.FE_TONEAREST,
            roundDown      = core.stdc.fenv.FE_DOWNWARD,
            roundUp        = core.stdc.fenv.FE_UPWARD,
            roundToZero    = core.stdc.fenv.FE_TOWARDZERO,
            roundingMask   = roundToNearest | roundDown
                             | roundUp | roundToZero,
        }
    }

    /***
     * Change the floating-point hardware rounding mode
     *
     * Changing the rounding mode in the middle of a function can interfere
     * with optimizations of floating point expressions, as the optimizer assumes
     * that the rounding mode does not change.
     * It is best to change the rounding mode only at the
     * beginning of the function, and keep it until the function returns.
     * It is also best to add the line:
     * ---
     * pragma(inline, false);
     * ---
     * as the first line of the function so it will not get inlined.
     * Params:
     *    newMode = the new rounding mode
     */
    @property void rounding(RoundingMode newMode) @trusted
    {
        initialize();
        setControlState((getControlState() & (-1 - roundingMask)) | (newMode & roundingMask));
    }

    /// Returns: the currently active rounding mode
    @property static RoundingMode rounding() @trusted pure
    {
        return cast(RoundingMode)(getControlState() & roundingMask);
    }

    alias ExceptionMask = uint; ///

    version (StdDdoc)
    {
        enum : ExceptionMask
        {
            /** IEEE hardware exceptions.
             *  By default, all exceptions are masked (disabled).
             *
             *  severeExceptions = The overflow, division by zero, and invalid
             *  exceptions.
             */
            subnormalException,
            inexactException, /// ditto
            underflowException, /// ditto
            overflowException, /// ditto
            divByZeroException, /// ditto
            invalidException, /// ditto
            severeExceptions, /// ditto
            allExceptions, /// ditto
        }
    }
    else version (ARM_Any)
    {
        enum : ExceptionMask
        {
            subnormalException    = 0x8000,
            inexactException      = 0x1000,
            underflowException    = 0x0800,
            overflowException     = 0x0400,
            divByZeroException    = 0x0200,
            invalidException      = 0x0100,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException | subnormalException,
        }
    }
    else version (PPC_Any)
    {
        enum : ExceptionMask
        {
            inexactException      = 0x0008,
            divByZeroException    = 0x0010,
            underflowException    = 0x0020,
            overflowException     = 0x0040,
            invalidException      = 0x0080,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException,
        }
    }
    else version (RISCV_Any)
    {
        enum : ExceptionMask
        {
            inexactException      = 0x01,
            divByZeroException    = 0x02,
            underflowException    = 0x04,
            overflowException     = 0x08,
            invalidException      = 0x10,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException,
        }
    }
    else version (HPPA)
    {
        enum : ExceptionMask
        {
            inexactException      = 0x01,
            underflowException    = 0x02,
            overflowException     = 0x04,
            divByZeroException    = 0x08,
            invalidException      = 0x10,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException,
        }
    }
    else version (MIPS_Any)
    {
        enum : ExceptionMask
        {
            inexactException      = 0x0080,
            divByZeroException    = 0x0400,
            overflowException     = 0x0200,
            underflowException    = 0x0100,
            invalidException      = 0x0800,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException,
        }
    }
    else version (SPARC_Any)
    {
        enum : ExceptionMask
        {
            inexactException      = 0x0800000,
            divByZeroException    = 0x1000000,
            overflowException     = 0x4000000,
            underflowException    = 0x2000000,
            invalidException      = 0x8000000,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException,
        }
    }
    else version (IBMZ_Any)
    {
        enum : ExceptionMask
        {
            inexactException      = 0x08000000,
            divByZeroException    = 0x40000000,
            overflowException     = 0x20000000,
            underflowException    = 0x10000000,
            invalidException      = 0x80000000,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException,
        }
    }
    else version (X86_Any)
    {
        enum : ExceptionMask
        {
            inexactException      = 0x20,
            underflowException    = 0x10,
            overflowException     = 0x08,
            divByZeroException    = 0x04,
            subnormalException    = 0x02,
            invalidException      = 0x01,
            severeExceptions   = overflowException | divByZeroException
                                 | invalidException,
            allExceptions      = severeExceptions | underflowException
                                 | inexactException | subnormalException,
        }
    }
    else
        static assert(false, "Not implemented for this architecture");

    version (ARM_Any)
    {
        static bool hasExceptionTraps_impl() @safe
        {
            auto oldState = getControlState();
            // If exceptions are not supported, we set the bit but read it back as zero
            // https://sourceware.org/ml/libc-ports/2012-06/msg00091.html
            setControlState(oldState | divByZeroException);
            immutable result = (getControlState() & allExceptions) != 0;
            setControlState(oldState);
            return result;
        }
    }

    /// Returns: true if the current FPU supports exception trapping
    @property static bool hasExceptionTraps() @safe pure
    {
        version (X86_Any)
            return true;
        else version (PPC_Any)
            return true;
        else version (MIPS_Any)
            return true;
        else version (ARM_Any)
        {
            // The hasExceptionTraps_impl function is basically pure,
            // as it restores all global state
            auto fptr = ( () @trusted => cast(bool function() @safe
                pure nothrow @nogc)&hasExceptionTraps_impl)();
            return fptr();
        }
        else
            assert(0, "Not yet supported");
    }

    /// Enable (unmask) specific hardware exceptions. Multiple exceptions may be ORed together.
    void enableExceptions(ExceptionMask exceptions) @trusted
    {
        assert(hasExceptionTraps);
        initialize();
        version (X86_Any)
            setControlState(getControlState() & ~(exceptions & allExceptions));
        else
            setControlState(getControlState() | (exceptions & allExceptions));
    }

    /// Disable (mask) specific hardware exceptions. Multiple exceptions may be ORed together.
    void disableExceptions(ExceptionMask exceptions) @trusted
    {
        assert(hasExceptionTraps);
        initialize();
        version (X86_Any)
            setControlState(getControlState() | (exceptions & allExceptions));
        else
            setControlState(getControlState() & ~(exceptions & allExceptions));
    }

    /// Returns: the exceptions which are currently enabled (unmasked)
    @property static ExceptionMask enabledExceptions() @trusted pure
    {
        assert(hasExceptionTraps);
        version (X86_Any)
            return (getControlState() & allExceptions) ^ allExceptions;
        else
            return (getControlState() & allExceptions);
    }

    ///  Clear all pending exceptions, then restore the original exception state and rounding mode.
    ~this() @trusted
    {
        clearExceptions();
        if (initialized)
            setControlState(savedState);
    }

private:
    ControlState savedState;

    bool initialized = false;

    version (ARM_Any)
    {
        alias ControlState = uint;
    }
    else version (HPPA)
    {
        alias ControlState = uint;
    }
    else version (PPC_Any)
    {
        alias ControlState = uint;
    }
    else version (RISCV_Any)
    {
        alias ControlState = uint;
    }
    else version (MIPS_Any)
    {
        alias ControlState = uint;
    }
    else version (SPARC_Any)
    {
        alias ControlState = ulong;
    }
    else version (IBMZ_Any)
    {
        alias ControlState = uint;
    }
    else version (X86_Any)
    {
        alias ControlState = ushort;
    }
    else
        static assert(false, "Not implemented for this architecture");

    void initialize() @safe
    {
        // BUG: This works around the absence of this() constructors.
        if (initialized) return;
        clearExceptions();
        savedState = getControlState();
        initialized = true;
    }

    // Clear all pending exceptions
    static void clearExceptions() @safe
    {
        version (IeeeFlagsSupport)
            resetIeeeFlags();
        else
            static assert(false, "Not implemented for this architecture");
    }

    // Read from the control register
    static ControlState getControlState() @trusted pure
    {
        version (D_InlineAsm_X86)
        {
            short cont;
            asm pure nothrow @nogc
            {
                xor EAX, EAX;
                fstcw cont;
            }
            return cont;
        }
        else version (D_InlineAsm_X86_64)
        {
            short cont;
            asm pure nothrow @nogc
            {
                xor RAX, RAX;
                fstcw cont;
            }
            return cont;
        }
        else version (RISCV_Any)
        {
            mixin(`
            ControlState cont;
            asm pure nothrow @nogc
            {
                "frcsr %0" : "=r" (cont);
            }
            return cont;
            `);
        }
        else
            assert(0, "Not yet supported");
    }

    // Set the control register
    static void setControlState(ControlState newState) @trusted
    {
        version (InlineAsm_X86_Any)
        {
            asm nothrow @nogc
            {
                fclex;
                fldcw newState;
            }

            // Also update MXCSR, SSE's control register.
            if (haveSSE)
            {
                uint mxcsr;
                asm nothrow @nogc { stmxcsr mxcsr; }

                /* In the FPU control register, rounding mode is in bits 10 and
                11. In MXCSR it's in bits 13 and 14. */
                mxcsr &= ~(roundingMask << 3);             // delete old rounding mode
                mxcsr |= (newState & roundingMask) << 3;   // write new rounding mode

                /* In the FPU control register, masks are bits 0 through 5.
                In MXCSR they're 7 through 12. */
                mxcsr &= ~(allExceptions << 7);            // delete old masks
                mxcsr |= (newState & allExceptions) << 7;  // write new exception masks

                asm nothrow @nogc { ldmxcsr mxcsr; }
            }
        }
        else version (RISCV_Any)
        {
            mixin(`
            asm pure nothrow @nogc
            {
                "fscsr %0" : : "r" (newState);
            }
            `);
        }
        else
            assert(0, "Not yet supported");
    }
}

///
@safe unittest
{
    FloatingPointControl fpctrl;

    fpctrl.rounding = FloatingPointControl.roundDown;
    assert(lrint(1.5) == 1.0);

    fpctrl.rounding = FloatingPointControl.roundUp;
    assert(lrint(1.4) == 2.0);

    fpctrl.rounding = FloatingPointControl.roundToNearest;
    assert(lrint(1.5) == 2.0);
}

@safe unittest
{
    void ensureDefaults()
    {
        assert(FloatingPointControl.rounding
               == FloatingPointControl.roundToNearest);
        if (FloatingPointControl.hasExceptionTraps)
            assert(FloatingPointControl.enabledExceptions == 0);
    }

    {
        FloatingPointControl ctrl;
    }
    ensureDefaults();

    {
        FloatingPointControl ctrl;
        ctrl.rounding = FloatingPointControl.roundDown;
        assert(FloatingPointControl.rounding == FloatingPointControl.roundDown);
    }
    ensureDefaults();

    if (FloatingPointControl.hasExceptionTraps)
    {
        FloatingPointControl ctrl;
        ctrl.enableExceptions(FloatingPointControl.divByZeroException
                              | FloatingPointControl.overflowException);
        assert(ctrl.enabledExceptions ==
               (FloatingPointControl.divByZeroException
                | FloatingPointControl.overflowException));

        ctrl.rounding = FloatingPointControl.roundUp;
        assert(FloatingPointControl.rounding == FloatingPointControl.roundUp);
    }
    ensureDefaults();
}

@safe unittest // rounding
{
    import std.meta : AliasSeq;

    static foreach (T; AliasSeq!(float, double, real))
    {{
        /* Be careful with changing the rounding mode, it interferes
         * with common subexpressions. Changing rounding modes should
         * be done with separate functions that are not inlined.
         */

        {
            static T addRound(T)(uint rm)
            {
                pragma(inline, false) static void blockopt(ref T x) {}
                pragma(inline, false);
                FloatingPointControl fpctrl;
                fpctrl.rounding = rm;
                T x = 1;
                blockopt(x); // avoid constant propagation by the optimizer
                x += 0.1L;
                return x;
            }

            T u = addRound!(T)(FloatingPointControl.roundUp);
            T d = addRound!(T)(FloatingPointControl.roundDown);
            T z = addRound!(T)(FloatingPointControl.roundToZero);

            assert(u > d);
            assert(z == d);
        }

        {
            static T subRound(T)(uint rm)
            {
                pragma(inline, false) static void blockopt(ref T x) {}
                pragma(inline, false);
                FloatingPointControl fpctrl;
                fpctrl.rounding = rm;
                T x = -1;
                blockopt(x); // avoid constant propagation by the optimizer
                x -= 0.1L;
                return x;
            }

            T u = subRound!(T)(FloatingPointControl.roundUp);
            T d = subRound!(T)(FloatingPointControl.roundDown);
            T z = subRound!(T)(FloatingPointControl.roundToZero);

            assert(u > d);
            assert(z == u);
        }
    }}
}

} // FloatingPointControlSupport


/*********************************
 * Determines if $(D_PARAM x) is NaN.
 * Params:
 *  x = a floating point number.
 * Returns:
 *  `true` if $(D_PARAM x) is Nan.
 */
bool isNaN(X)(X x) @nogc @trusted pure nothrow
if (isFloatingPoint!(X))
{
    version (all)
    {
        return x != x;
    }
    else
    {
        /*
        Code kept for historical context. At least on Intel, the simple test
        x != x uses one dedicated instruction (ucomiss/ucomisd) that runs in one
        cycle. Code for 80- and 128-bits is larger but still smaller than the
        integrals-based solutions below. Future revisions may enable the code
        below conditionally depending on hardware.
        */
        alias F = floatTraits!(X);
        static if (F.realFormat == RealFormat.ieeeSingle)
        {
            const uint p = *cast(uint *)&x;
            // Sign bit (MSB) is irrelevant so mask it out.
            // Next 8 bits should be all set.
            // At least one bit among the least significant 23 bits should be set.
            return (p & 0x7FFF_FFFF) > 0x7F80_0000;
        }
        else static if (F.realFormat == RealFormat.ieeeDouble)
        {
            const ulong  p = *cast(ulong *)&x;
            // Sign bit (MSB) is irrelevant so mask it out.
            // Next 11 bits should be all set.
            // At least one bit among the least significant 52 bits should be set.
            return (p & 0x7FFF_FFFF_FFFF_FFFF) > 0x7FF0_0000_0000_0000;
        }
        else static if (F.realFormat == RealFormat.ieeeExtended ||
                        F.realFormat == RealFormat.ieeeExtended53)
        {
            const ushort e = F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT];
            const ulong ps = *cast(ulong *)&x;
            return e == F.EXPMASK &&
                ps & 0x7FFF_FFFF_FFFF_FFFF; // not infinity
        }
        else static if (F.realFormat == RealFormat.ieeeQuadruple)
        {
            const ushort e = F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT];
            const ulong psLsb = (cast(ulong *)&x)[MANTISSA_LSB];
            const ulong psMsb = (cast(ulong *)&x)[MANTISSA_MSB];
            return e == F.EXPMASK &&
                (psLsb | (psMsb& 0x0000_FFFF_FFFF_FFFF)) != 0;
        }
        else
        {
            return x != x;
        }
    }
}

///
@safe pure nothrow @nogc unittest
{
    assert( isNaN(float.init));
    assert( isNaN(-double.init));
    assert( isNaN(real.nan));
    assert( isNaN(-real.nan));
    assert(!isNaN(cast(float) 53.6));
    assert(!isNaN(cast(real)-53.6));
}

@safe pure nothrow @nogc unittest
{
    import std.meta : AliasSeq;

    static foreach (T; AliasSeq!(float, double, real))
    {{
        // CTFE-able tests
        assert(isNaN(T.init));
        assert(isNaN(-T.init));
        assert(isNaN(T.nan));
        assert(isNaN(-T.nan));
        assert(!isNaN(T.infinity));
        assert(!isNaN(-T.infinity));
        assert(!isNaN(cast(T) 53.6));
        assert(!isNaN(cast(T)-53.6));

        // Runtime tests
        shared T f;
        f = T.init;
        assert(isNaN(f));
        assert(isNaN(-f));
        f = T.nan;
        assert(isNaN(f));
        assert(isNaN(-f));
        f = T.infinity;
        assert(!isNaN(f));
        assert(!isNaN(-f));
        f = cast(T) 53.6;
        assert(!isNaN(f));
        assert(!isNaN(-f));
    }}
}

/*********************************
 * Determines if $(D_PARAM x) is finite.
 * Params:
 *  x = a floating point number.
 * Returns:
 *  `true` if $(D_PARAM x) is finite.
 */
bool isFinite(X)(X x) @trusted pure nothrow @nogc
{
    static if (__traits(isFloating, X))
        if (__ctfe)
            return x == x && x != X.infinity && x != -X.infinity;
    alias F = floatTraits!(X);
    ushort* pe = cast(ushort *)&x;
    return (pe[F.EXPPOS_SHORT] & F.EXPMASK) != F.EXPMASK;
}

///
@safe pure nothrow @nogc unittest
{
    assert( isFinite(1.23f));
    assert( isFinite(float.max));
    assert( isFinite(float.min_normal));
    assert(!isFinite(float.nan));
    assert(!isFinite(float.infinity));
}

@safe pure nothrow @nogc unittest
{
    assert(isFinite(1.23));
    assert(isFinite(double.max));
    assert(isFinite(double.min_normal));
    assert(!isFinite(double.nan));
    assert(!isFinite(double.infinity));

    assert(isFinite(1.23L));
    assert(isFinite(real.max));
    assert(isFinite(real.min_normal));
    assert(!isFinite(real.nan));
    assert(!isFinite(real.infinity));

    //CTFE
    static assert(isFinite(1.23));
    static assert(isFinite(double.max));
    static assert(isFinite(double.min_normal));
    static assert(!isFinite(double.nan));
    static assert(!isFinite(double.infinity));

    static assert(isFinite(1.23L));
    static assert(isFinite(real.max));
    static assert(isFinite(real.min_normal));
    static assert(!isFinite(real.nan));
    static assert(!isFinite(real.infinity));
}


/*********************************
 * Determines if $(D_PARAM x) is normalized.
 *
 * A normalized number must not be zero, subnormal, infinite nor $(NAN).
 *
 * Params:
 *  x = a floating point number.
 * Returns:
 *  `true` if $(D_PARAM x) is normalized.
 */

/* Need one for each format because subnormal floats might
 * be converted to normal reals.
 */
bool isNormal(X)(X x) @trusted pure nothrow @nogc
{
    static if (__traits(isFloating, X))
        if (__ctfe)
            return (x <= -X.min_normal && x != -X.infinity) || (x >= X.min_normal && x != X.infinity);
    alias F = floatTraits!(X);
    ushort e = F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT];
    return (e != F.EXPMASK && e != 0);
}

///
@safe pure nothrow @nogc unittest
{
    float f = 3;
    double d = 500;
    real e = 10e+48;

    assert(isNormal(f));
    assert(isNormal(d));
    assert(isNormal(e));
    f = d = e = 0;
    assert(!isNormal(f));
    assert(!isNormal(d));
    assert(!isNormal(e));
    assert(!isNormal(real.infinity));
    assert(isNormal(-real.max));
    assert(!isNormal(real.min_normal/4));

}

@safe pure nothrow @nogc unittest
{
    // CTFE
    enum float f = 3;
    enum double d = 500;
    enum real e = 10e+48;

    static assert(isNormal(f));
    static assert(isNormal(d));
    static assert(isNormal(e));

    static assert(!isNormal(0.0f));
    static assert(!isNormal(0.0));
    static assert(!isNormal(0.0L));
    static assert(!isNormal(real.infinity));
    static assert(isNormal(-real.max));
    static assert(!isNormal(real.min_normal/4));
}

/*********************************
 * Determines if $(D_PARAM x) is subnormal.
 *
 * Subnormals (also known as "denormal number"), have a 0 exponent
 * and a 0 most significant mantissa bit.
 *
 * Params:
 *  x = a floating point number.
 * Returns:
 *  `true` if $(D_PARAM x) is a denormal number.
 */
bool isSubnormal(X)(X x) @trusted pure nothrow @nogc
{
    static if (__traits(isFloating, X))
        if (__ctfe)
            return -X.min_normal < x && x < X.min_normal;
    /*
        Need one for each format because subnormal floats might
        be converted to normal reals.
    */
    alias F = floatTraits!(X);
    static if (F.realFormat == RealFormat.ieeeSingle)
    {
        uint *p = cast(uint *)&x;
        return (*p & F.EXPMASK_INT) == 0 && *p & F.MANTISSAMASK_INT;
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        uint *p = cast(uint *)&x;
        return (p[MANTISSA_MSB] & F.EXPMASK_INT) == 0
            && (p[MANTISSA_LSB] || p[MANTISSA_MSB] & F.MANTISSAMASK_INT);
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        ushort e = F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT];
        long*   ps = cast(long *)&x;
        return (e == 0 &&
          ((ps[MANTISSA_LSB]|(ps[MANTISSA_MSB]& 0x0000_FFFF_FFFF_FFFF)) != 0));
    }
    else static if (F.realFormat == RealFormat.ieeeExtended ||
                    F.realFormat == RealFormat.ieeeExtended53)
    {
        ushort* pe = cast(ushort *)&x;
        long*   ps = cast(long *)&x;

        return (pe[F.EXPPOS_SHORT] & F.EXPMASK) == 0 && *ps > 0;
    }
    else
    {
        static assert(false, "Not implemented for this architecture");
    }
}

///
@safe pure nothrow @nogc unittest
{
    import std.meta : AliasSeq;

    static foreach (T; AliasSeq!(float, double, real))
    {{
        T f;
        for (f = 1.0; !isSubnormal(f); f /= 2)
            assert(f != 0);
    }}
}

@safe pure nothrow @nogc unittest
{
    static bool subnormalTest(T)()
    {
        T f;
        for (f = 1.0; !isSubnormal(f); f /= 2)
            if (f == 0)
                return false;
        return true;
    }
    static assert(subnormalTest!float());
    static assert(subnormalTest!double());
    static assert(subnormalTest!real());
}

/*********************************
 * Determines if $(D_PARAM x) is $(PLUSMN)$(INFIN).
 * Params:
 *  x = a floating point number.
 * Returns:
 *  `true` if $(D_PARAM x) is $(PLUSMN)$(INFIN).
 */
bool isInfinity(X)(X x) @nogc @trusted pure nothrow
if (isFloatingPoint!(X))
{
    alias F = floatTraits!(X);
    static if (F.realFormat == RealFormat.ieeeSingle)
    {
        return ((*cast(uint *)&x) & 0x7FFF_FFFF) == 0x7F80_0000;
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        return ((*cast(ulong *)&x) & 0x7FFF_FFFF_FFFF_FFFF)
            == 0x7FF0_0000_0000_0000;
    }
    else static if (F.realFormat == RealFormat.ieeeExtended ||
                    F.realFormat == RealFormat.ieeeExtended53)
    {
        const ushort e = cast(ushort)(F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT]);
        const ulong ps = *cast(ulong *)&x;

        // On Motorola 68K, infinity can have hidden bit = 1 or 0. On x86, it is always 1.
        return e == F.EXPMASK && (ps & 0x7FFF_FFFF_FFFF_FFFF) == 0;
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        const long psLsb = (cast(long *)&x)[MANTISSA_LSB];
        const long psMsb = (cast(long *)&x)[MANTISSA_MSB];
        return (psLsb == 0)
            && (psMsb & 0x7FFF_FFFF_FFFF_FFFF) == 0x7FFF_0000_0000_0000;
    }
    else
    {
        return (x < -X.max) || (X.max < x);
    }
}

///
@nogc @safe pure nothrow unittest
{
    assert(!isInfinity(float.init));
    assert(!isInfinity(-float.init));
    assert(!isInfinity(float.nan));
    assert(!isInfinity(-float.nan));
    assert(isInfinity(float.infinity));
    assert(isInfinity(-float.infinity));
    assert(isInfinity(-1.0f / 0.0f));
}

@safe pure nothrow @nogc unittest
{
    // CTFE-able tests
    assert(!isInfinity(double.init));
    assert(!isInfinity(-double.init));
    assert(!isInfinity(double.nan));
    assert(!isInfinity(-double.nan));
    assert(isInfinity(double.infinity));
    assert(isInfinity(-double.infinity));
    assert(isInfinity(-1.0 / 0.0));

    assert(!isInfinity(real.init));
    assert(!isInfinity(-real.init));
    assert(!isInfinity(real.nan));
    assert(!isInfinity(-real.nan));
    assert(isInfinity(real.infinity));
    assert(isInfinity(-real.infinity));
    assert(isInfinity(-1.0L / 0.0L));

    // Runtime tests
    shared float f;
    f = float.init;
    assert(!isInfinity(f));
    assert(!isInfinity(-f));
    f = float.nan;
    assert(!isInfinity(f));
    assert(!isInfinity(-f));
    f = float.infinity;
    assert(isInfinity(f));
    assert(isInfinity(-f));
    f = (-1.0f / 0.0f);
    assert(isInfinity(f));

    shared double d;
    d = double.init;
    assert(!isInfinity(d));
    assert(!isInfinity(-d));
    d = double.nan;
    assert(!isInfinity(d));
    assert(!isInfinity(-d));
    d = double.infinity;
    assert(isInfinity(d));
    assert(isInfinity(-d));
    d = (-1.0 / 0.0);
    assert(isInfinity(d));

    shared real e;
    e = real.init;
    assert(!isInfinity(e));
    assert(!isInfinity(-e));
    e = real.nan;
    assert(!isInfinity(e));
    assert(!isInfinity(-e));
    e = real.infinity;
    assert(isInfinity(e));
    assert(isInfinity(-e));
    e = (-1.0L / 0.0L);
    assert(isInfinity(e));
}

@nogc @safe pure nothrow unittest
{
    import std.meta : AliasSeq;
    static bool foo(T)(inout T x) { return isInfinity(x); }
    foreach (T; AliasSeq!(float, double, real))
    {
        assert(!foo(T(3.14f)));
        assert(foo(T.infinity));
    }
}

/*********************************
 * Is the binary representation of x identical to y?
 */
bool isIdentical(real x, real y) @trusted pure nothrow @nogc
{
    if (__ctfe)
    {
        if (x !is y) return false;
        if (x == x) return true; // If not NaN `is` implies identical representation.
        static if (double.mant_dig != real.mant_dig)
        {
            // Works because we are in CTFE and there is no way in CTFE to set more
            // bits of NaN payload than can fit in a double, and since 2.087
            // changed real.init to be non-signaling I *think* there is no way in
            // CTFE for a real to be a signaling NaN unless real and double have
            // the same representation so real's bits can be manipulated directly.
            double d1 = x, d2 = y;
        }
        else
        {
            // Alias to avoid converting signaling to quiet.
            alias d1 = x;
            alias d2 = y;
        }
        return *cast(long*) &d1 == *cast(long*) &d2;
    }
    // We're doing a bitwise comparison so the endianness is irrelevant.
    long*   pxs = cast(long *)&x;
    long*   pys = cast(long *)&y;
    alias F = floatTraits!(real);
    static if (F.realFormat == RealFormat.ieeeDouble)
    {
        return pxs[0] == pys[0];
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        return pxs[0] == pys[0] && pxs[1] == pys[1];
    }
    else static if (F.realFormat == RealFormat.ieeeExtended)
    {
        ushort* pxe = cast(ushort *)&x;
        ushort* pye = cast(ushort *)&y;
        return pxe[4] == pye[4] && pxs[0] == pys[0];
    }
    else
    {
        assert(0, "isIdentical not implemented");
    }
}

///
@safe @nogc pure nothrow unittest
{
    assert( isIdentical(0.0, 0.0));
    assert( isIdentical(1.0, 1.0));
    assert( isIdentical(real.infinity, real.infinity));
    assert( isIdentical(-real.infinity, -real.infinity));

    assert(!isIdentical(0.0, -0.0));
    assert(!isIdentical(real.nan, -real.nan));
    assert(!isIdentical(real.infinity, -real.infinity));
}

@safe @nogc pure nothrow unittest
{
    static assert( isIdentical(0.0, 0.0));
    static assert( isIdentical(1.0, 1.0));
    static assert( isIdentical(real.infinity, real.infinity));
    static assert( isIdentical(-real.infinity, -real.infinity));
    static assert( isIdentical(real.nan, real.nan));

    static assert(!isIdentical(0.0, -0.0));
    static assert(!isIdentical(real.nan, -real.nan));
    static assert(!isIdentical(real.infinity, -real.infinity));
}
/*********************************
 * Return 1 if sign bit of e is set, 0 if not.
 */
int signbit(X)(X x) @nogc @trusted pure nothrow
{
    if (__ctfe)
    {
        double dval = cast(double) x; // Precision can increase or decrease but sign won't change (even NaN).
        return 0 > *cast(long*) &dval;
    }

    alias F = floatTraits!(X);
    return ((cast(ubyte *)&x)[F.SIGNPOS_BYTE] & 0x80) != 0;
}

///
@nogc @safe pure nothrow unittest
{
    assert(!signbit(float.nan));
    assert(signbit(-float.nan));
    assert(!signbit(168.1234f));
    assert(signbit(-168.1234f));
    assert(!signbit(0.0f));
    assert(signbit(-0.0f));
    assert(signbit(-float.max));
    assert(!signbit(float.max));

    assert(!signbit(double.nan));
    assert(signbit(-double.nan));
    assert(!signbit(168.1234));
    assert(signbit(-168.1234));
    assert(!signbit(0.0));
    assert(signbit(-0.0));
    assert(signbit(-double.max));
    assert(!signbit(double.max));

    assert(!signbit(real.nan));
    assert(signbit(-real.nan));
    assert(!signbit(168.1234L));
    assert(signbit(-168.1234L));
    assert(!signbit(0.0L));
    assert(signbit(-0.0L));
    assert(signbit(-real.max));
    assert(!signbit(real.max));
}

@nogc @safe pure nothrow unittest
{
    // CTFE
    static assert(!signbit(float.nan));
    static assert(signbit(-float.nan));
    static assert(!signbit(168.1234f));
    static assert(signbit(-168.1234f));
    static assert(!signbit(0.0f));
    static assert(signbit(-0.0f));
    static assert(signbit(-float.max));
    static assert(!signbit(float.max));

    static assert(!signbit(double.nan));
    static assert(signbit(-double.nan));
    static assert(!signbit(168.1234));
    static assert(signbit(-168.1234));
    static assert(!signbit(0.0));
    static assert(signbit(-0.0));
    static assert(signbit(-double.max));
    static assert(!signbit(double.max));

    static assert(!signbit(real.nan));
    static assert(signbit(-real.nan));
    static assert(!signbit(168.1234L));
    static assert(signbit(-168.1234L));
    static assert(!signbit(0.0L));
    static assert(signbit(-0.0L));
    static assert(signbit(-real.max));
    static assert(!signbit(real.max));
}

/**
Params:
    to = the numeric value to use
    from = the sign value to use
Returns:
    a value composed of to with from's sign bit.
 */
R copysign(R, X)(R to, X from) @trusted pure nothrow @nogc
if (isFloatingPoint!(R) && isFloatingPoint!(X))
{
    if (__ctfe)
    {
        return signbit(to) == signbit(from) ? to : -to;
    }
    ubyte* pto   = cast(ubyte *)&to;
    const ubyte* pfrom = cast(ubyte *)&from;

    alias T = floatTraits!(R);
    alias F = floatTraits!(X);
    pto[T.SIGNPOS_BYTE] &= 0x7F;
    pto[T.SIGNPOS_BYTE] |= pfrom[F.SIGNPOS_BYTE] & 0x80;
    return to;
}

/// ditto
R copysign(R, X)(X to, R from) @trusted pure nothrow @nogc
if (isIntegral!(X) && isFloatingPoint!(R))
{
    return copysign(cast(R) to, from);
}

///
@safe pure nothrow @nogc unittest
{
    assert(copysign(1.0, 1.0) == 1.0);
    assert(copysign(1.0, -0.0) == -1.0);
    assert(copysign(1UL, -1.0) == -1.0);
    assert(copysign(-1.0, -1.0) == -1.0);

    assert(copysign(real.infinity, -1.0) == -real.infinity);
    assert(copysign(real.nan, 1.0) is real.nan);
    assert(copysign(-real.nan, 1.0) is real.nan);
    assert(copysign(real.nan, -1.0) is -real.nan);
}

@safe pure nothrow @nogc unittest
{
    import std.meta : AliasSeq;

    static foreach (X; AliasSeq!(float, double, real, int, long))
    {
        static foreach (Y; AliasSeq!(float, double, real))
        {{
            X x = 21;
            Y y = 23.8;
            Y e = void;

            e = copysign(x, y);
            assert(e == 21.0);

            e = copysign(-x, y);
            assert(e == 21.0);

            e = copysign(x, -y);
            assert(e == -21.0);

            e = copysign(-x, -y);
            assert(e == -21.0);

            static if (isFloatingPoint!X)
            {
                e = copysign(X.nan, y);
                assert(isNaN(e) && !signbit(e));

                e = copysign(X.nan, -y);
                assert(isNaN(e) && signbit(e));
            }
        }}
    }
    // CTFE
    static foreach (X; AliasSeq!(float, double, real, int, long))
    {
        static foreach (Y; AliasSeq!(float, double, real))
        {{
            enum X x = 21;
            enum Y y = 23.8;

            assert(21.0 == copysign(x, y));
            assert(21.0 == copysign(-x, y));
            assert(-21.0 == copysign(x, -y));
            assert(-21.0 == copysign(-x, -y));

            static if (isFloatingPoint!X)
            {
                static assert(isNaN(copysign(X.nan, y)) && !signbit(copysign(X.nan, y)));
                assert(isNaN(copysign(X.nan, -y)) && signbit(copysign(X.nan, -y)));
            }
        }}
    }
}

/*********************************
Returns `-1` if $(D x < 0), `x` if $(D x == 0), `1` if
$(D x > 0), and $(NAN) if x==$(NAN).
 */
F sgn(F)(F x) @safe pure nothrow @nogc
if (isFloatingPoint!F || isIntegral!F)
{
    // @@@TODO@@@: make this faster
    return x > 0 ? 1 : x < 0 ? -1 : x;
}

///
@safe pure nothrow @nogc unittest
{
    assert(sgn(168.1234) == 1);
    assert(sgn(-168.1234) == -1);
    assert(sgn(0.0) == 0);
    assert(sgn(-0.0) == 0);
}

// Functions for NaN payloads
/*
 * A 'payload' can be stored in the significand of a $(NAN). One bit is required
 * to distinguish between a quiet and a signalling $(NAN). This leaves 22 bits
 * of payload for a float; 51 bits for a double; 62 bits for an 80-bit real;
 * and 111 bits for a 128-bit quad.
*/
/**
 * Create a quiet $(NAN), storing an integer inside the payload.
 *
 * For floats, the largest possible payload is 0x3F_FFFF.
 * For doubles, it is 0x3_FFFF_FFFF_FFFF.
 * For 80-bit or 128-bit reals, it is 0x3FFF_FFFF_FFFF_FFFF.
 */
real NaN(ulong payload) @trusted pure nothrow @nogc
{
    alias F = floatTraits!(real);
    static if (F.realFormat == RealFormat.ieeeExtended ||
               F.realFormat == RealFormat.ieeeExtended53)
    {
        // real80 (in x86 real format, the implied bit is actually
        // not implied but a real bit which is stored in the real)
        ulong v = 3; // implied bit = 1, quiet bit = 1
    }
    else
    {
        ulong v = 1; // no implied bit. quiet bit = 1
    }
    if (__ctfe)
    {
        v = 1; // We use a double in CTFE.
        assert(payload >>> 51 == 0,
            "Cannot set more than 51 bits of NaN payload in CTFE.");
    }


    ulong a = payload;

    // 22 Float bits
    ulong w = a & 0x3F_FFFF;
    a -= w;

    v <<=22;
    v |= w;
    a >>=22;

    // 29 Double bits
    v <<=29;
    w = a & 0xFFF_FFFF;
    v |= w;
    a -= w;
    a >>=29;

    if (__ctfe)
    {
        v |= 0x7FF0_0000_0000_0000;
        return *cast(double*) &v;
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        v |= 0x7FF0_0000_0000_0000;
        real x;
        * cast(ulong *)(&x) = v;
        return x;
    }
    else
    {
        v <<=11;
        a &= 0x7FF;
        v |= a;
        real x = real.nan;

        // Extended real bits
        static if (F.realFormat == RealFormat.ieeeQuadruple)
        {
            v <<= 1; // there's no implicit bit

            version (LittleEndian)
            {
                *cast(ulong*)(6+cast(ubyte*)(&x)) = v;
            }
            else
            {
                *cast(ulong*)(2+cast(ubyte*)(&x)) = v;
            }
        }
        else
        {
            *cast(ulong *)(&x) = v;
        }
        return x;
    }
}

///
@safe @nogc pure nothrow unittest
{
    real a = NaN(1_000_000);
    assert(isNaN(a));
    assert(getNaNPayload(a) == 1_000_000);
}

@system pure nothrow @nogc unittest // not @safe because taking address of local.
{
    static if (floatTraits!(real).realFormat == RealFormat.ieeeDouble)
    {
        auto x = NaN(1);
        auto xl = *cast(ulong*)&x;
        assert(xl & 0x8_0000_0000_0000UL); //non-signaling bit, bit 52
        assert((xl & 0x7FF0_0000_0000_0000UL) == 0x7FF0_0000_0000_0000UL); //all exp bits set
    }
}

/**
 * Extract an integral payload from a $(NAN).
 *
 * Returns:
 * the integer payload as a ulong.
 *
 * For floats, the largest possible payload is 0x3F_FFFF.
 * For doubles, it is 0x3_FFFF_FFFF_FFFF.
 * For 80-bit or 128-bit reals, it is 0x3FFF_FFFF_FFFF_FFFF.
 */
ulong getNaNPayload(real x) @trusted pure nothrow @nogc
{
    //  assert(isNaN(x));
    alias F = floatTraits!(real);
    ulong m = void;
    if (__ctfe)
    {
        double y = x;
        m = *cast(ulong*) &y;
        // Make it look like an 80-bit significand.
        // Skip exponent, and quiet bit
        m &= 0x0007_FFFF_FFFF_FFFF;
        m <<= 11;
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        m = *cast(ulong*)(&x);
        // Make it look like an 80-bit significand.
        // Skip exponent, and quiet bit
        m &= 0x0007_FFFF_FFFF_FFFF;
        m <<= 11;
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        version (LittleEndian)
        {
            m = *cast(ulong*)(6+cast(ubyte*)(&x));
        }
        else
        {
            m = *cast(ulong*)(2+cast(ubyte*)(&x));
        }

        m >>= 1; // there's no implicit bit
    }
    else
    {
        m = *cast(ulong*)(&x);
    }

    // ignore implicit bit and quiet bit

    const ulong f = m & 0x3FFF_FF00_0000_0000L;

    ulong w = f >>> 40;
            w |= (m & 0x00FF_FFFF_F800L) << (22 - 11);
            w |= (m & 0x7FF) << 51;
            return w;
}

///
@safe @nogc pure nothrow unittest
{
    real a = NaN(1_000_000);
    assert(isNaN(a));
    assert(getNaNPayload(a) == 1_000_000);
}

@safe @nogc pure nothrow unittest
{
    enum real a = NaN(1_000_000);
    static assert(isNaN(a));
    static assert(getNaNPayload(a) == 1_000_000);
    real b = NaN(1_000_000);
    assert(isIdentical(b, a));
    // The CTFE version of getNaNPayload relies on it being impossible
    // for a CTFE-constructed NaN to have more than 51 bits of payload.
    enum nanNaN = NaN(getNaNPayload(real.nan));
    assert(isIdentical(real.nan, nanNaN));
    static if (real.init != real.init)
    {
        enum initNaN = NaN(getNaNPayload(real.init));
        assert(isIdentical(real.init, initNaN));
    }
}

debug(UnitTest)
{
    @safe pure nothrow @nogc unittest
    {
        real nan4 = NaN(0x789_ABCD_EF12_3456);
        static if (floatTraits!(real).realFormat == RealFormat.ieeeExtended
                || floatTraits!(real).realFormat == RealFormat.ieeeQuadruple)
        {
            assert(getNaNPayload(nan4) == 0x789_ABCD_EF12_3456);
        }
        else
        {
            assert(getNaNPayload(nan4) == 0x1_ABCD_EF12_3456);
        }
        double nan5 = nan4;
        assert(getNaNPayload(nan5) == 0x1_ABCD_EF12_3456);
        float nan6 = nan4;
        assert(getNaNPayload(nan6) == 0x12_3456);
        nan4 = NaN(0xFABCD);
        assert(getNaNPayload(nan4) == 0xFABCD);
        nan6 = nan4;
        assert(getNaNPayload(nan6) == 0xFABCD);
        nan5 = NaN(0x100_0000_0000_3456);
        assert(getNaNPayload(nan5) == 0x0000_0000_3456);
    }
}

/**
 * Calculate the next largest floating point value after x.
 *
 * Return the least number greater than x that is representable as a real;
 * thus, it gives the next point on the IEEE number line.
 *
 *  $(TABLE_SV
 *    $(SVH x,            nextUp(x)   )
 *    $(SV  -$(INFIN),    -real.max   )
 *    $(SV  $(PLUSMN)0.0, real.min_normal*real.epsilon )
 *    $(SV  real.max,     $(INFIN) )
 *    $(SV  $(INFIN),     $(INFIN) )
 *    $(SV  $(NAN),       $(NAN)   )
 * )
 */
real nextUp(real x) @trusted pure nothrow @nogc
{
    alias F = floatTraits!(real);
    static if (F.realFormat != RealFormat.ieeeDouble)
    {
        if (__ctfe)
        {
            if (x == -real.infinity)
                return -real.max;
            if (!(x < real.infinity)) // Infinity or NaN.
                return x;
            real delta;
            // Start with a decent estimate of delta.
            if (x <= 0x1.ffffffffffffep+1023 && x >= -double.max)
            {
                const double d = cast(double) x;
                delta = (cast(real) nextUp(d) - cast(real) d) * 0x1p-11L;
                while (x + (delta * 0x1p-100L) > x)
                    delta *= 0x1p-100L;
            }
            else
            {
                delta = 0x1p960L;
                while (!(x + delta > x) && delta < real.max * 0x1p-100L)
                    delta *= 0x1p100L;
            }
            if (x + delta > x)
            {
                while (x + (delta / 2) > x)
                    delta /= 2;
            }
            else
            {
                do { delta += delta; } while (!(x + delta > x));
            }
            if (x < 0 && x + delta == 0)
                return -0.0L;
            return x + delta;
        }
    }
    static if (F.realFormat == RealFormat.ieeeDouble)
    {
        return nextUp(cast(double) x);
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        ushort e = F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT];
        if (e == F.EXPMASK)
        {
            // NaN or Infinity
            if (x == -real.infinity) return -real.max;
            return x; // +Inf and NaN are unchanged.
        }

        auto ps = cast(ulong *)&x;
        if (ps[MANTISSA_MSB] & 0x8000_0000_0000_0000)
        {
            // Negative number
            if (ps[MANTISSA_LSB] == 0 && ps[MANTISSA_MSB] == 0x8000_0000_0000_0000)
            {
                // it was negative zero, change to smallest subnormal
                ps[MANTISSA_LSB] = 1;
                ps[MANTISSA_MSB] = 0;
                return x;
            }
            if (ps[MANTISSA_LSB] == 0) --ps[MANTISSA_MSB];
            --ps[MANTISSA_LSB];
        }
        else
        {
            // Positive number
            ++ps[MANTISSA_LSB];
            if (ps[MANTISSA_LSB] == 0) ++ps[MANTISSA_MSB];
        }
        return x;
    }
    else static if (F.realFormat == RealFormat.ieeeExtended ||
                    F.realFormat == RealFormat.ieeeExtended53)
    {
        // For 80-bit reals, the "implied bit" is a nuisance...
        ushort *pe = cast(ushort *)&x;
        ulong  *ps = cast(ulong  *)&x;
        // EPSILON is 1 for 64-bit, and 2048 for 53-bit precision reals.
        enum ulong EPSILON = 2UL ^^ (64 - real.mant_dig);

        if ((pe[F.EXPPOS_SHORT] & F.EXPMASK) == F.EXPMASK)
        {
            // First, deal with NANs and infinity
            if (x == -real.infinity) return -real.max;
            return x; // +Inf and NaN are unchanged.
        }
        if (pe[F.EXPPOS_SHORT] & 0x8000)
        {
            // Negative number -- need to decrease the significand
            *ps -= EPSILON;
            // Need to mask with 0x7FFF... so subnormals are treated correctly.
            if ((*ps & 0x7FFF_FFFF_FFFF_FFFF) == 0x7FFF_FFFF_FFFF_FFFF)
            {
                if (pe[F.EXPPOS_SHORT] == 0x8000)   // it was negative zero
                {
                    *ps = 1;
                    pe[F.EXPPOS_SHORT] = 0; // smallest subnormal.
                    return x;
                }

                --pe[F.EXPPOS_SHORT];

                if (pe[F.EXPPOS_SHORT] == 0x8000)
                    return x; // it's become a subnormal, implied bit stays low.

                *ps = 0xFFFF_FFFF_FFFF_FFFF; // set the implied bit
                return x;
            }
            return x;
        }
        else
        {
            // Positive number -- need to increase the significand.
            // Works automatically for positive zero.
            *ps += EPSILON;
            if ((*ps & 0x7FFF_FFFF_FFFF_FFFF) == 0)
            {
                // change in exponent
                ++pe[F.EXPPOS_SHORT];
                *ps = 0x8000_0000_0000_0000; // set the high bit
            }
        }
        return x;
    }
    else // static if (F.realFormat == RealFormat.ibmExtended)
    {
        assert(0, "nextUp not implemented");
    }
}

/** ditto */
double nextUp(double x) @trusted pure nothrow @nogc
{
    ulong s = *cast(ulong *)&x;

    if ((s & 0x7FF0_0000_0000_0000) == 0x7FF0_0000_0000_0000)
    {
        // First, deal with NANs and infinity
        if (x == -x.infinity) return -x.max;
        return x; // +INF and NAN are unchanged.
    }
    if (s & 0x8000_0000_0000_0000)    // Negative number
    {
        if (s == 0x8000_0000_0000_0000) // it was negative zero
        {
            s = 0x0000_0000_0000_0001; // change to smallest subnormal
            return *cast(double*) &s;
        }
        --s;
    }
    else
    {   // Positive number
        ++s;
    }
    return *cast(double*) &s;
}

/** ditto */
float nextUp(float x) @trusted pure nothrow @nogc
{
    uint s = *cast(uint *)&x;

    if ((s & 0x7F80_0000) == 0x7F80_0000)
    {
        // First, deal with NANs and infinity
        if (x == -x.infinity) return -x.max;

        return x; // +INF and NAN are unchanged.
    }
    if (s & 0x8000_0000)   // Negative number
    {
        if (s == 0x8000_0000) // it was negative zero
        {
            s = 0x0000_0001; // change to smallest subnormal
            return *cast(float*) &s;
        }

        --s;
    }
    else
    {
        // Positive number
        ++s;
    }
    return *cast(float*) &s;
}

///
@safe @nogc pure nothrow unittest
{
    assert(nextUp(1.0 - 1.0e-6).feqrel(0.999999) > 16);
    assert(nextUp(1.0 - real.epsilon).feqrel(1.0) > 16);
}

/**
 * Calculate the next smallest floating point value before x.
 *
 * Return the greatest number less than x that is representable as a real;
 * thus, it gives the previous point on the IEEE number line.
 *
 *  $(TABLE_SV
 *    $(SVH x,            nextDown(x)   )
 *    $(SV  $(INFIN),     real.max  )
 *    $(SV  $(PLUSMN)0.0, -real.min_normal*real.epsilon )
 *    $(SV  -real.max,    -$(INFIN) )
 *    $(SV  -$(INFIN),    -$(INFIN) )
 *    $(SV  $(NAN),       $(NAN)    )
 * )
 */
real nextDown(real x) @safe pure nothrow @nogc
{
    return -nextUp(-x);
}

/** ditto */
double nextDown(double x) @safe pure nothrow @nogc
{
    return -nextUp(-x);
}

/** ditto */
float nextDown(float x) @safe pure nothrow @nogc
{
    return -nextUp(-x);
}

///
@safe pure nothrow @nogc unittest
{
    assert( nextDown(1.0 + real.epsilon) == 1.0);
}

@safe pure nothrow @nogc unittest
{
    static if (floatTraits!(real).realFormat == RealFormat.ieeeExtended ||
               floatTraits!(real).realFormat == RealFormat.ieeeDouble ||
               floatTraits!(real).realFormat == RealFormat.ieeeExtended53 ||
               floatTraits!(real).realFormat == RealFormat.ieeeQuadruple)
    {
        // Tests for reals
        assert(isIdentical(nextUp(NaN(0xABC)), NaN(0xABC)));
        //static assert(isIdentical(nextUp(NaN(0xABC)), NaN(0xABC)));
        // negative numbers
        assert( nextUp(-real.infinity) == -real.max );
        assert( nextUp(-1.0L-real.epsilon) == -1.0 );
        assert( nextUp(-2.0L) == -2.0 + real.epsilon);
        static assert( nextUp(-real.infinity) == -real.max );
        static assert( nextUp(-1.0L-real.epsilon) == -1.0 );
        static assert( nextUp(-2.0L) == -2.0 + real.epsilon);
        // subnormals and zero
        assert( nextUp(-real.min_normal) == -real.min_normal*(1-real.epsilon) );
        assert( nextUp(-real.min_normal*(1-real.epsilon)) == -real.min_normal*(1-2*real.epsilon) );
        assert( isIdentical(-0.0L, nextUp(-real.min_normal*real.epsilon)) );
        assert( nextUp(-0.0L) == real.min_normal*real.epsilon );
        assert( nextUp(0.0L) == real.min_normal*real.epsilon );
        assert( nextUp(real.min_normal*(1-real.epsilon)) == real.min_normal );
        assert( nextUp(real.min_normal) == real.min_normal*(1+real.epsilon) );
        static assert( nextUp(-real.min_normal) == -real.min_normal*(1-real.epsilon) );
        static assert( nextUp(-real.min_normal*(1-real.epsilon)) == -real.min_normal*(1-2*real.epsilon) );
        static assert( -0.0L is nextUp(-real.min_normal*real.epsilon) );
        static assert( nextUp(-0.0L) == real.min_normal*real.epsilon );
        static assert( nextUp(0.0L) == real.min_normal*real.epsilon );
        static assert( nextUp(real.min_normal*(1-real.epsilon)) == real.min_normal );
        static assert( nextUp(real.min_normal) == real.min_normal*(1+real.epsilon) );
        // positive numbers
        assert( nextUp(1.0L) == 1.0 + real.epsilon );
        assert( nextUp(2.0L-real.epsilon) == 2.0 );
        assert( nextUp(real.max) == real.infinity );
        assert( nextUp(real.infinity)==real.infinity );
        static assert( nextUp(1.0L) == 1.0 + real.epsilon );
        static assert( nextUp(2.0L-real.epsilon) == 2.0 );
        static assert( nextUp(real.max) == real.infinity );
        static assert( nextUp(real.infinity)==real.infinity );
        // ctfe near double.max boundary
        static assert(nextUp(nextDown(cast(real) double.max)) == cast(real) double.max);
    }

    double n = NaN(0xABC);
    assert(isIdentical(nextUp(n), n));
    // negative numbers
    assert( nextUp(-double.infinity) == -double.max );
    assert( nextUp(-1-double.epsilon) == -1.0 );
    assert( nextUp(-2.0) == -2.0 + double.epsilon);
    // subnormals and zero

    assert( nextUp(-double.min_normal) == -double.min_normal*(1-double.epsilon) );
    assert( nextUp(-double.min_normal*(1-double.epsilon)) == -double.min_normal*(1-2*double.epsilon) );
    assert( isIdentical(-0.0, nextUp(-double.min_normal*double.epsilon)) );
    assert( nextUp(0.0) == double.min_normal*double.epsilon );
    assert( nextUp(-0.0) == double.min_normal*double.epsilon );
    assert( nextUp(double.min_normal*(1-double.epsilon)) == double.min_normal );
    assert( nextUp(double.min_normal) == double.min_normal*(1+double.epsilon) );
    // positive numbers
    assert( nextUp(1.0) == 1.0 + double.epsilon );
    assert( nextUp(2.0-double.epsilon) == 2.0 );
    assert( nextUp(double.max) == double.infinity );

    float fn = NaN(0xABC);
    assert(isIdentical(nextUp(fn), fn));
    float f = -float.min_normal*(1-float.epsilon);
    float f1 = -float.min_normal;
    assert( nextUp(f1) ==  f);
    f = 1.0f+float.epsilon;
    f1 = 1.0f;
    assert( nextUp(f1) == f );
    f1 = -0.0f;
    assert( nextUp(f1) == float.min_normal*float.epsilon);
    assert( nextUp(float.infinity)==float.infinity );

    assert(nextDown(1.0L+real.epsilon)==1.0);
    assert(nextDown(1.0+double.epsilon)==1.0);
    f = 1.0f+float.epsilon;
    assert(nextDown(f)==1.0);
    assert(nextafter(1.0+real.epsilon, -real.infinity)==1.0);

    // CTFE

    enum double ctfe_n = NaN(0xABC);
    //static assert(isIdentical(nextUp(ctfe_n), ctfe_n)); // FIXME: https://issues.dlang.org/show_bug.cgi?id=20197
    static assert(nextUp(double.nan) is double.nan);
    // negative numbers
    static assert( nextUp(-double.infinity) == -double.max );
    static assert( nextUp(-1-double.epsilon) == -1.0 );
    static assert( nextUp(-2.0) == -2.0 + double.epsilon);
    // subnormals and zero

    static assert( nextUp(-double.min_normal) == -double.min_normal*(1-double.epsilon) );
    static assert( nextUp(-double.min_normal*(1-double.epsilon)) == -double.min_normal*(1-2*double.epsilon) );
    static assert( -0.0 is nextUp(-double.min_normal*double.epsilon) );
    static assert( nextUp(0.0) == double.min_normal*double.epsilon );
    static assert( nextUp(-0.0) == double.min_normal*double.epsilon );
    static assert( nextUp(double.min_normal*(1-double.epsilon)) == double.min_normal );
    static assert( nextUp(double.min_normal) == double.min_normal*(1+double.epsilon) );
    // positive numbers
    static assert( nextUp(1.0) == 1.0 + double.epsilon );
    static assert( nextUp(2.0-double.epsilon) == 2.0 );
    static assert( nextUp(double.max) == double.infinity );

    enum float ctfe_fn = NaN(0xABC);
    //static assert(isIdentical(nextUp(ctfe_fn), ctfe_fn)); // FIXME: https://issues.dlang.org/show_bug.cgi?id=20197
    static assert(nextUp(float.nan) is float.nan);
    static assert(nextUp(-float.min_normal) == -float.min_normal*(1-float.epsilon));
    static assert(nextUp(1.0f) == 1.0f+float.epsilon);
    static assert(nextUp(-0.0f) == float.min_normal*float.epsilon);
    static assert(nextUp(float.infinity)==float.infinity);
    static assert(nextDown(1.0L+real.epsilon)==1.0);
    static assert(nextDown(1.0+double.epsilon)==1.0);
    static assert(nextDown(1.0f+float.epsilon)==1.0);
    static assert(nextafter(1.0+real.epsilon, -real.infinity)==1.0);
}



/******************************************
 * Calculates the next representable value after x in the direction of y.
 *
 * If y > x, the result will be the next largest floating-point value;
 * if y < x, the result will be the next smallest value.
 * If x == y, the result is y.
 * If x or y is a NaN, the result is a NaN.
 *
 * Remarks:
 * This function is not generally very useful; it's almost always better to use
 * the faster functions nextUp() or nextDown() instead.
 *
 * The FE_INEXACT and FE_OVERFLOW exceptions will be raised if x is finite and
 * the function result is infinite. The FE_INEXACT and FE_UNDERFLOW
 * exceptions will be raised if the function value is subnormal, and x is
 * not equal to y.
 */
T nextafter(T)(const T x, const T y) @safe pure nothrow @nogc
{
    if (x == y || isNaN(y))
    {
        return y;
    }

    if (isNaN(x))
    {
        return x;
    }

    return ((y>x) ? nextUp(x) :  nextDown(x));
}

///
@safe pure nothrow @nogc unittest
{
    float a = 1;
    assert(is(typeof(nextafter(a, a)) == float));
    assert(nextafter(a, a.infinity) > a);
    assert(isNaN(nextafter(a, a.nan)));
    assert(isNaN(nextafter(a.nan, a)));

    double b = 2;
    assert(is(typeof(nextafter(b, b)) == double));
    assert(nextafter(b, b.infinity) > b);
    assert(isNaN(nextafter(b, b.nan)));
    assert(isNaN(nextafter(b.nan, b)));

    real c = 3;
    assert(is(typeof(nextafter(c, c)) == real));
    assert(nextafter(c, c.infinity) > c);
    assert(isNaN(nextafter(c, c.nan)));
    assert(isNaN(nextafter(c.nan, c)));
}

@safe pure nothrow @nogc unittest
{
    // CTFE
    enum float a = 1;
    static assert(is(typeof(nextafter(a, a)) == float));
    static assert(nextafter(a, a.infinity) > a);
    static assert(isNaN(nextafter(a, a.nan)));
    static assert(isNaN(nextafter(a.nan, a)));

    enum double b = 2;
    static assert(is(typeof(nextafter(b, b)) == double));
    static assert(nextafter(b, b.infinity) > b);
    static assert(isNaN(nextafter(b, b.nan)));
    static assert(isNaN(nextafter(b.nan, b)));

    enum real c = 3;
    static assert(is(typeof(nextafter(c, c)) == real));
    static assert(nextafter(c, c.infinity) > c);
    static assert(isNaN(nextafter(c, c.nan)));
    static assert(isNaN(nextafter(c.nan, c)));

    enum real negZero = nextafter(+0.0L, -0.0L);
    static assert(negZero == -0.0L);
    static assert(signbit(negZero));

    static assert(nextafter(c, c) == c);
}

//real nexttoward(real x, real y) { return core.stdc.math.nexttowardl(x, y); }

/**
 * Returns the positive difference between x and y.
 *
 * Equivalent to `fmax(x-y, 0)`.
 *
 * Returns:
 *      $(TABLE_SV
 *      $(TR $(TH x, y)       $(TH fdim(x, y)))
 *      $(TR $(TD x $(GT) y)  $(TD x - y))
 *      $(TR $(TD x $(LT)= y) $(TD +0.0))
 *      )
 */
real fdim(real x, real y) @safe pure nothrow @nogc
{
    return (x < y) ? +0.0 : x - y;
}

///
@safe pure nothrow @nogc unittest
{
    assert(fdim(2.0, 0.0) == 2.0);
    assert(fdim(-2.0, 0.0) == 0.0);
    assert(fdim(real.infinity, 2.0) == real.infinity);
    assert(isNaN(fdim(real.nan, 2.0)));
    assert(isNaN(fdim(2.0, real.nan)));
    assert(isNaN(fdim(real.nan, real.nan)));
}

/**
 * Returns the larger of `x` and `y`.
 *
 * If one of the arguments is a `NaN`, the other is returned.
 *
 * See_Also: $(REF max, std,algorithm,comparison) is faster because it does not perform the `isNaN` test.
 */
F fmax(F)(const F x, const F y) @safe pure nothrow @nogc
if (__traits(isFloating, F))
{
    // Do the more predictable test first. Generates 0 branches with ldc and 1 branch with gdc.
    // See https://godbolt.org/z/erxrW9
    if (isNaN(x)) return y;
    return y > x ? y : x;
}

///
@safe pure nothrow @nogc unittest
{
    import std.meta : AliasSeq;
    static foreach (F; AliasSeq!(float, double, real))
    {
        assert(fmax(F(0.0), F(2.0)) == 2.0);
        assert(fmax(F(-2.0), 0.0) == F(0.0));
        assert(fmax(F.infinity, F(2.0)) == F.infinity);
        assert(fmax(F.nan, F(2.0)) == F(2.0));
        assert(fmax(F(2.0), F.nan) == F(2.0));
    }
}

/**
 * Returns the smaller of `x` and `y`.
 *
 * If one of the arguments is a `NaN`, the other is returned.
 *
 * See_Also: $(REF min, std,algorithm,comparison) is faster because it does not perform the `isNaN` test.
 */
F fmin(F)(const F x, const F y) @safe pure nothrow @nogc
if (__traits(isFloating, F))
{
    // Do the more predictable test first. Generates 0 branches with ldc and 1 branch with gdc.
    // See https://godbolt.org/z/erxrW9
    if (isNaN(x)) return y;
    return y < x ? y : x;
}

///
@safe pure nothrow @nogc unittest
{
    import std.meta : AliasSeq;
    static foreach (F; AliasSeq!(float, double, real))
    {
        assert(fmin(F(0.0), F(2.0)) == 0.0);
        assert(fmin(F(-2.0), F(0.0)) == -2.0);
        assert(fmin(F.infinity, F(2.0)) == 2.0);
        assert(fmin(F.nan, F(2.0)) == 2.0);
        assert(fmin(F(2.0), F.nan) == 2.0);
    }
}

/**************************************
 * Returns (x * y) + z, rounding only once according to the
 * current rounding mode.
 *
 * BUGS: Not currently implemented - rounds twice.
 */
pragma(inline, true)
real fma(real x, real y, real z) @safe pure nothrow @nogc { return (x * y) + z; }

///
@safe pure nothrow @nogc unittest
{
    assert(fma(0.0, 2.0, 2.0) == 2.0);
    assert(fma(2.0, 2.0, 2.0) == 6.0);
    assert(fma(real.infinity, 2.0, 2.0) == real.infinity);
    assert(fma(real.nan, 2.0, 2.0) is real.nan);
    assert(fma(2.0, 2.0, real.nan) is real.nan);
}

/**
 * Compute the value of x $(SUPERSCRIPT n), where n is an integer
 */
Unqual!F pow(F, G)(F x, G n) @nogc @trusted pure nothrow
if (isFloatingPoint!(F) && isIntegral!(G))
{
    // NaN ^^ 0 is an exception defined by IEEE (yields 1 instead of NaN)
    if (isNaN(x)) return n ? x : 1.0;

    import std.traits : Unsigned;
    real p = 1.0, v = void;
    Unsigned!(Unqual!G) m = n;

    if (n < 0)
    {
        if (n == -1) return 1 / x;

        m = cast(typeof(m))(0 - n);
        v = p / x;
    }
    else
    {
        switch (n)
        {
        case 0:
            return 1.0;
        case 1:
            return x;
        default:
        }

        v = x;
    }

    // Bail out early, if we can estimate that the result is infinity or 0.0:
    //
    // We use the following two conclusions:
    //
    //    m * floor(log2(abs(v))) >= F.max_exp
    // =>             abs(v) ^^ m >  F.max == nextDown(F.infinity)
    //
    //    m * (bias - ex - 1) >= bias + F.mant_dig - 1
    // =>         abs(v) ^^ m <  2 ^^ (-bias - F.mant_dig + 2) == nextUp(0.0)
    //
    // floor(log2(abs(v))) == ex - bias can be directly taken from the
    // exponent of the floating point represantation, to avoid long
    // calculations here.

    enum uint bias = F.max_exp - 1;

    static if (is(F == float))
    {
        float f = cast(float) v;
        uint ival = () @trusted { return *cast(uint*) &f; }();
        ulong ex = (ival >> 23) & 255;
    }
    else static if (is(F == double) || (is(T == real) && T.mant_dig == double.mant_dig))
    {
        double d = cast(double) v;
        ulong ival = () @trusted { return *cast(ulong*) &d; }();
        ulong ex = (ival >> 52) & 2047;
    }
    else static if (is (F == real) && real.mant_dig == 64)
    {
        ulong ex = void;
        if (__ctfe)
        {
            // in CTFE we cannot access the bit patterns and have therefore to
            // fall back to the (slower) general case
            // skipping subnormals by setting ex = bias
            ex = abs(v) == F.infinity ? 2 * bias + 1 :
                (abs(v) < F.min_normal ? bias : cast(ulong) (floor(log2(abs(v))) + bias));
        }
        else
        {
            ulong[2] ival = () @trusted { return *cast(ulong[2]*) &v; }();
            ex = ival[1] & 32767;
        }
    }
    else
    {
        // ToDo: Add special treatment for other reals too.

        // In the general case we have to fall back to log2, which is slower, but still
        // a certain speed gain compared to not bailing out early.
            // skipping subnormals by setting ex = bias
        ulong ex = abs(v) == F.infinity ? 2 * bias + 1 :
            (abs(v) < F.min_normal ? bias : cast(ulong) (floor(log2(abs(v))) + bias));
    }

    // m * (...) can exceed ulong.max, we therefore first check m >= (...).
    // This is sufficient to know that the result will be infinity or 0.0
    // and at the same time it guards against an overflow.
    if (ex > bias && (m >= F.max_exp || m * (ex - bias) >= F.max_exp))
        return (m % 2 == 0 || v > 0) ? F.infinity : -F.infinity;
    else if (ex < bias - 1
             && (m >= bias + F.mant_dig - 1 || m * (bias - ex - 1) >= bias + F.mant_dig - 1))
        return 0.0;

    while (1)
    {
        if (m & 1)
            p *= v;
        m >>= 1;
        if (!m)
            break;
        v *= v;
    }
    return p;
}

///
@safe pure nothrow @nogc unittest
{
    assert(pow(2.0, 5) == 32.0);
    assert(pow(1.5, 9).feqrel(38.4433) > 16);
    assert(pow(real.nan, 2) is real.nan);
    assert(pow(real.infinity, 2) == real.infinity);
}

@safe pure nothrow @nogc unittest
{
    // Make sure it instantiates and works properly on immutable values and
    // with various integer and float types.
    immutable real x = 46;
    immutable float xf = x;
    immutable double xd = x;
    immutable uint one = 1;
    immutable ushort two = 2;
    immutable ubyte three = 3;
    immutable ulong eight = 8;

    immutable int neg1 = -1;
    immutable short neg2 = -2;
    immutable byte neg3 = -3;
    immutable long neg8 = -8;


    assert(pow(x,0) == 1.0);
    assert(pow(xd,one) == x);
    assert(pow(xf,two) == x * x);
    assert(pow(x,three) == x * x * x);
    assert(pow(x,eight) == (x * x) * (x * x) * (x * x) * (x * x));

    assert(pow(x, neg1) == 1 / x);

    assert(isClose(pow(xd, neg2), cast(double) (1 / (x * x)), 1e-25));
    assert(isClose(pow(xf, neg8), cast(float) (1 / ((x * x) * (x * x) * (x * x) * (x * x))), 1e-15));

    assert(feqrel(pow(x, neg3),  1 / (x * x * x)) >= real.mant_dig - 1);
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(pow(2.0L, 10L), 1024, 19));
}

// https://issues.dlang.org/show_bug.cgi?id=21601
@safe @nogc nothrow pure unittest
{
    // When reals are large enough the results of pow(b, e) can be
    // calculated correctly, if b is of type float or double and e is
    // not too large.
    static if (real.mant_dig >= 64)
    {
        // expected result: 3.790e-42
        assert(pow(-513645318757045764096.0f, -2) > 0.0);

        // expected result: 3.763915357831797e-309
        assert(pow(-1.6299717435255677e+154, -2) > 0.0);
    }
}

/**
 * Compute the power of two integral numbers.
 *
 * Params:
 *     x = base
 *     n = exponent
 *
 * Returns:
 *     x raised to the power of n. If n is negative the result is 1 / pow(x, -n),
 *     which is calculated as integer division with remainder. This may result in
 *     a division by zero error.
 *
 *     If both x and n are 0, the result is 1.
 *
 * Throws:
 *     If x is 0 and n is negative, the result is the same as the result of a
 *     division by zero.
 */
typeof(Unqual!(F).init * Unqual!(G).init) pow(F, G)(F x, G n) @nogc @trusted pure nothrow
if (isIntegral!(F) && isIntegral!(G))
{
    typeof(return) p, v = void;
    Unqual!G m = n;

    static if (isSigned!(F))
    {
        if (x == -1) return cast(typeof(return)) (m & 1 ? -1 : 1);
    }
    static if (isSigned!(G))
    {
        if (x == 0 && m <= -1) return x / 0;
    }
    if (x == 1) return 1;
    static if (isSigned!(G))
    {
        if (m < 0) return 0;
    }

    switch (m)
    {
    case 0:
        p = 1;
        break;

    case 1:
        p = x;
        break;

    case 2:
        p = x * x;
        break;

    default:
        v = x;
        p = 1;
        while (1)
        {
            if (m & 1)
                p *= v;
            m >>= 1;
            if (!m)
                break;
            v *= v;
        }
        break;
    }
    return p;
}

///
@safe pure nothrow @nogc unittest
{
    assert(pow(2, 3) == 8);
    assert(pow(3, 2) == 9);

    assert(pow(2, 10) == 1_024);
    assert(pow(2, 20) == 1_048_576);
    assert(pow(2, 30) == 1_073_741_824);

    assert(pow(0, 0) == 1);

    assert(pow(1, -5) == 1);
    assert(pow(1, -6) == 1);
    assert(pow(-1, -5) == -1);
    assert(pow(-1, -6) == 1);

    assert(pow(-2, 5) == -32);
    assert(pow(-2, -5) == 0);
    assert(pow(cast(double) -2, -5) == -0.03125);
}

@safe pure nothrow @nogc unittest
{
    immutable int one = 1;
    immutable byte two = 2;
    immutable ubyte three = 3;
    immutable short four = 4;
    immutable long ten = 10;

    assert(pow(two, three) == 8);
    assert(pow(two, ten) == 1024);
    assert(pow(one, ten) == 1);
    assert(pow(ten, four) == 10_000);
    assert(pow(four, 10) == 1_048_576);
    assert(pow(three, four) == 81);
}

// https://issues.dlang.org/show_bug.cgi?id=7006
@safe pure nothrow @nogc unittest
{
    assert(pow(5, -1) == 0);
    assert(pow(-5, -1) == 0);
    assert(pow(5, -2) == 0);
    assert(pow(-5, -2) == 0);
    assert(pow(-1, int.min) == 1);
    assert(pow(-2, int.min) == 0);

    assert(pow(4294967290UL,2) == 18446744022169944100UL);
    assert(pow(0,uint.max) == 0);
}

/**Computes integer to floating point powers.*/
real pow(I, F)(I x, F y) @nogc @trusted pure nothrow
if (isIntegral!I && isFloatingPoint!F)
{
    return pow(cast(real) x, cast(Unqual!F) y);
}

///
@safe pure nothrow @nogc unittest
{
    assert(pow(2, 5.0) == 32.0);
    assert(pow(7, 3.0) == 343.0);
    assert(pow(2, real.nan) is real.nan);
    assert(pow(2, real.infinity) == real.infinity);
}

/**
 * Calculates x$(SUPERSCRIPT y).
 *
 * $(TABLE_SV
 * $(TR $(TH x) $(TH y) $(TH pow(x, y))
 *      $(TH div 0) $(TH invalid?))
 * $(TR $(TD anything)      $(TD $(PLUSMN)0.0)                $(TD 1.0)
 *      $(TD no)        $(TD no) )
 * $(TR $(TD |x| $(GT) 1)    $(TD +$(INFIN))                  $(TD +$(INFIN))
 *      $(TD no)        $(TD no) )
 * $(TR $(TD |x| $(LT) 1)    $(TD +$(INFIN))                  $(TD +0.0)
 *      $(TD no)        $(TD no) )
 * $(TR $(TD |x| $(GT) 1)    $(TD -$(INFIN))                  $(TD +0.0)
 *      $(TD no)        $(TD no) )
 * $(TR $(TD |x| $(LT) 1)    $(TD -$(INFIN))                  $(TD +$(INFIN))
 *      $(TD no)        $(TD no) )
 * $(TR $(TD +$(INFIN))      $(TD $(GT) 0.0)                  $(TD +$(INFIN))
 *      $(TD no)        $(TD no) )
 * $(TR $(TD +$(INFIN))      $(TD $(LT) 0.0)                  $(TD +0.0)
 *      $(TD no)        $(TD no) )
 * $(TR $(TD -$(INFIN))      $(TD odd integer $(GT) 0.0)      $(TD -$(INFIN))
 *      $(TD no)        $(TD no) )
 * $(TR $(TD -$(INFIN))      $(TD $(GT) 0.0, not odd integer) $(TD +$(INFIN))
 *      $(TD no)        $(TD no))
 * $(TR $(TD -$(INFIN))      $(TD odd integer $(LT) 0.0)      $(TD -0.0)
 *      $(TD no)        $(TD no) )
 * $(TR $(TD -$(INFIN))      $(TD $(LT) 0.0, not odd integer) $(TD +0.0)
 *      $(TD no)        $(TD no) )
 * $(TR $(TD $(PLUSMN)1.0)   $(TD $(PLUSMN)$(INFIN))          $(TD -$(NAN))
 *      $(TD no)        $(TD yes) )
 * $(TR $(TD $(LT) 0.0)      $(TD finite, nonintegral)        $(TD $(NAN))
 *      $(TD no)        $(TD yes))
 * $(TR $(TD $(PLUSMN)0.0)   $(TD odd integer $(LT) 0.0)      $(TD $(PLUSMNINF))
 *      $(TD yes)       $(TD no) )
 * $(TR $(TD $(PLUSMN)0.0)   $(TD $(LT) 0.0, not odd integer) $(TD +$(INFIN))
 *      $(TD yes)       $(TD no))
 * $(TR $(TD $(PLUSMN)0.0)   $(TD odd integer $(GT) 0.0)      $(TD $(PLUSMN)0.0)
 *      $(TD no)        $(TD no) )
 * $(TR $(TD $(PLUSMN)0.0)   $(TD $(GT) 0.0, not odd integer) $(TD +0.0)
 *      $(TD no)        $(TD no) )
 * )
 */
Unqual!(Largest!(F, G)) pow(F, G)(F x, G y) @nogc @trusted pure nothrow
if (isFloatingPoint!(F) && isFloatingPoint!(G))
{
    alias Float = typeof(return);

    static real impl(real x, real y) @nogc pure nothrow
    {
        // Special cases.
        if (isNaN(y))
            return y;
        if (isNaN(x) && y != 0.0)
            return x;

        // Even if x is NaN.
        if (y == 0.0)
            return 1.0;
        if (y == 1.0)
            return x;

        if (isInfinity(y))
        {
            if (isInfinity(x))
            {
                if (!signbit(y) && !signbit(x))
                    return F.infinity;
                else
                    return F.nan;
            }
            else if (fabs(x) > 1)
            {
                if (signbit(y))
                    return +0.0;
                else
                    return F.infinity;
            }
            else if (fabs(x) == 1)
            {
                return F.nan;
            }
            else // < 1
            {
                if (signbit(y))
                    return F.infinity;
                else
                    return +0.0;
            }
        }
        if (isInfinity(x))
        {
            if (signbit(x))
            {
                long i = cast(long) y;
                if (y > 0.0)
                {
                    if (i == y && i & 1)
                        return -F.infinity;
                    else if (i == y)
                        return F.infinity;
                    else
                        return -F.nan;
                }
                else if (y < 0.0)
                {
                    if (i == y && i & 1)
                        return -0.0;
                    else if (i == y)
                        return +0.0;
                    else
                        return F.nan;
                }
            }
            else
            {
                if (y > 0.0)
                    return F.infinity;
                else if (y < 0.0)
                    return +0.0;
            }
        }

        if (x == 0.0)
        {
            if (signbit(x))
            {
                long i = cast(long) y;
                if (y > 0.0)
                {
                    if (i == y && i & 1)
                        return -0.0;
                    else
                        return +0.0;
                }
                else if (y < 0.0)
                {
                    if (i == y && i & 1)
                        return -F.infinity;
                    else
                        return F.infinity;
                }
            }
            else
            {
                if (y > 0.0)
                    return +0.0;
                else if (y < 0.0)
                    return F.infinity;
            }
        }
        if (x == 1.0)
            return 1.0;

        if (y >= F.max)
        {
            if ((x > 0.0 && x < 1.0) || (x > -1.0 && x < 0.0))
                return 0.0;
            if (x > 1.0 || x < -1.0)
                return F.infinity;
        }
        if (y <= -F.max)
        {
            if ((x > 0.0 && x < 1.0) || (x > -1.0 && x < 0.0))
                return F.infinity;
            if (x > 1.0 || x < -1.0)
                return 0.0;
        }

        if (x >= F.max)
        {
            if (y > 0.0)
                return F.infinity;
            else
                return 0.0;
        }
        if (x <= -F.max)
        {
            long i = cast(long) y;
            if (y > 0.0)
            {
                if (i == y && i & 1)
                    return -F.infinity;
                else
                    return F.infinity;
            }
            else if (y < 0.0)
            {
                if (i == y && i & 1)
                    return -0.0;
                else
                    return +0.0;
            }
        }

        // Integer power of x.
        long iy = cast(long) y;
        if (iy == y && fabs(y) < 32_768.0)
            return pow(x, iy);

        real sign = 1.0;
        if (x < 0)
        {
            // Result is real only if y is an integer
            // Check for a non-zero fractional part
            enum maxOdd = pow(2.0L, real.mant_dig) - 1.0L;
            static if (maxOdd > ulong.max)
            {
                // Generic method, for any FP type
                if (floor(y) != y)
                    return sqrt(x); // Complex result -- create a NaN

                const hy = 0.5 * y;
                if (floor(hy) != hy)
                    sign = -1.0;
            }
            else
            {
                // Much faster, if ulong has enough precision
                const absY = fabs(y);
                if (absY <= maxOdd)
                {
                    const uy = cast(ulong) absY;
                    if (uy != absY)
                        return sqrt(x); // Complex result -- create a NaN

                    if (uy & 1)
                        sign = -1.0;
                }
            }
            x = -x;
        }
        version (INLINE_YL2X)
        {
            // If x > 0, x ^^ y == 2 ^^ ( y * log2(x) )
            // TODO: This is not accurate in practice. A fast and accurate
            // (though complicated) method is described in:
            // "An efficient rounding boundary test for pow(x, y)
            // in double precision", C.Q. Lauter and V. Lefèvre, INRIA (2007).
            return sign * exp2( core.math.yl2x(x, y) );
        }
        else
        {
            // If x > 0, x ^^ y == 2 ^^ ( y * log2(x) )
            // TODO: This is not accurate in practice. A fast and accurate
            // (though complicated) method is described in:
            // "An efficient rounding boundary test for pow(x, y)
            // in double precision", C.Q. Lauter and V. Lefèvre, INRIA (2007).
            Float w = exp2(y * log2(x));
            return sign * w;
        }
    }
    return impl(x, y);
}

///
@safe pure nothrow @nogc unittest
{
    assert(isClose(pow(2.0, 3.0), 8.0));
    assert(isClose(pow(1.5, 10.0), 57.6650390625));

    // square root of 9
    assert(isClose(pow(9.0, 0.5), 3.0));
    // 10th root of 1024
    assert(isClose(pow(1024.0, 0.1), 2.0));

    assert(isClose(pow(-4.0, 3.0), -64.0));

    // reciprocal of 4 ^^ 2
    assert(isClose(pow(4.0, -2.0), 0.0625));
    // reciprocal of (-2) ^^ 3
    assert(isClose(pow(-2.0, -3.0), -0.125));

    assert(isClose(pow(-2.5, 3.0), -15.625));
    // reciprocal of 2.5 ^^ 3
    assert(isClose(pow(2.5, -3.0), 0.064));
    // reciprocal of (-2.5) ^^ 3
    assert(isClose(pow(-2.5, -3.0), -0.064));

    // reciprocal of square root of 4
    assert(isClose(pow(4.0, -0.5), 0.5));

    // per definition
    assert(isClose(pow(0.0, 0.0), 1.0));
}

///
@safe pure nothrow @nogc unittest
{
    // the result is a complex number
    // which cannot be represented as floating point number
    import std.math : isNaN;
    assert(isNaN(pow(-2.5, -1.5)));

    // use the ^^-operator of std.complex instead
    import std.complex : complex;
    auto c1 = complex(-2.5, 0.0);
    auto c2 = complex(-1.5, 0.0);
    auto result = c1 ^^ c2;
    // exact result apparently depends on `real` precision => increased tolerance
    assert(isClose(result.re, -4.64705438e-17, 2e-4));
    assert(isClose(result.im, 2.52982e-1, 2e-4));
}

@safe pure nothrow @nogc unittest
{
    assert(pow(1.5, real.infinity) == real.infinity);
    assert(pow(0.5, real.infinity) == 0.0);
    assert(pow(1.5, -real.infinity) == 0.0);
    assert(pow(0.5, -real.infinity) == real.infinity);
    assert(pow(real.infinity, 1.0) == real.infinity);
    assert(pow(real.infinity, -1.0) == 0.0);
    assert(pow(real.infinity, real.infinity) == real.infinity);
    assert(pow(-real.infinity, 1.0) == -real.infinity);
    assert(pow(-real.infinity, 2.0) == real.infinity);
    assert(pow(-real.infinity, -1.0) == -0.0);
    assert(pow(-real.infinity, -2.0) == 0.0);
    assert(isNaN(pow(1.0, real.infinity)));
    assert(pow(0.0, -1.0) == real.infinity);
    assert(pow(real.nan, 0.0) == 1.0);
    assert(isNaN(pow(real.nan, 3.0)));
    assert(isNaN(pow(3.0, real.nan)));
}

@safe @nogc nothrow unittest
{
    assert(equalsDigit(pow(2.0L, 10.0L), 1024, 19));
}

@safe pure nothrow @nogc unittest
{
    // Test all the special values.  These unittests can be run on Windows
    // by temporarily changing the version (linux) to version (all).
    immutable float zero = 0;
    immutable real one = 1;
    immutable double two = 2;
    immutable float three = 3;
    immutable float fnan = float.nan;
    immutable double dnan = double.nan;
    immutable real rnan = real.nan;
    immutable dinf = double.infinity;
    immutable rninf = -real.infinity;

    assert(pow(fnan, zero) == 1);
    assert(pow(dnan, zero) == 1);
    assert(pow(rnan, zero) == 1);

    assert(pow(two, dinf) == double.infinity);
    assert(isIdentical(pow(0.2f, dinf), +0.0));
    assert(pow(0.99999999L, rninf) == real.infinity);
    assert(isIdentical(pow(1.000000001, rninf), +0.0));
    assert(pow(dinf, 0.001) == dinf);
    assert(isIdentical(pow(dinf, -0.001), +0.0));
    assert(pow(rninf, 3.0L) == rninf);
    assert(pow(rninf, 2.0L) == real.infinity);
    assert(isIdentical(pow(rninf, -3.0), -0.0));
    assert(isIdentical(pow(rninf, -2.0), +0.0));

    // @@@BUG@@@ somewhere
    version (OSX) {} else assert(isNaN(pow(one, dinf)));
    version (OSX) {} else assert(isNaN(pow(-one, dinf)));
    assert(isNaN(pow(-0.2, PI)));
    // boundary cases. Note that epsilon == 2^^-n for some n,
    // so 1/epsilon == 2^^n is always even.
    assert(pow(-1.0L, 1/real.epsilon - 1.0L) == -1.0L);
    assert(pow(-1.0L, 1/real.epsilon) == 1.0L);
    assert(isNaN(pow(-1.0L, 1/real.epsilon-0.5L)));
    assert(isNaN(pow(-1.0L, -1/real.epsilon+0.5L)));

    assert(pow(0.0, -3.0) == double.infinity);
    assert(pow(-0.0, -3.0) == -double.infinity);
    assert(pow(0.0, -PI) == double.infinity);
    assert(pow(-0.0, -PI) == double.infinity);
    assert(isIdentical(pow(0.0, 5.0), 0.0));
    assert(isIdentical(pow(-0.0, 5.0), -0.0));
    assert(isIdentical(pow(0.0, 6.0), 0.0));
    assert(isIdentical(pow(-0.0, 6.0), 0.0));

    // https://issues.dlang.org/show_bug.cgi?id=14786 fixed
    immutable real maxOdd = pow(2.0L, real.mant_dig) - 1.0L;
    assert(pow(-1.0L,  maxOdd) == -1.0L);
    assert(pow(-1.0L, -maxOdd) == -1.0L);
    assert(pow(-1.0L, maxOdd + 1.0L) == 1.0L);
    assert(pow(-1.0L, -maxOdd + 1.0L) == 1.0L);
    assert(pow(-1.0L, maxOdd - 1.0L) == 1.0L);
    assert(pow(-1.0L, -maxOdd - 1.0L) == 1.0L);

    // Now, actual numbers.
    assert(isClose(pow(two, three), 8.0));
    assert(isClose(pow(two, -2.5), 0.1767766953));

    // Test integer to float power.
    immutable uint twoI = 2;
    assert(isClose(pow(twoI, three), 8.0));
}

// https://issues.dlang.org/show_bug.cgi?id=20508
@safe pure nothrow @nogc unittest
{
    assert(isNaN(pow(-double.infinity, 0.5)));

    assert(isNaN(pow(-real.infinity, real.infinity)));
    assert(isNaN(pow(-real.infinity, -real.infinity)));
    assert(isNaN(pow(-real.infinity, 1.234)));
    assert(isNaN(pow(-real.infinity, -0.751)));
    assert(pow(-real.infinity, 0.0) == 1.0);
}

/** Computes the value of a positive integer `x`, raised to the power `n`, modulo `m`.
 *
 *  Params:
 *      x = base
 *      n = exponent
 *      m = modulus
 *
 *  Returns:
 *      `x` to the power `n`, modulo `m`.
 *      The return type is the largest of `x`'s and `m`'s type.
 *
 * The function requires that all values have unsigned types.
 */
Unqual!(Largest!(F, H)) powmod(F, G, H)(F x, G n, H m)
if (isUnsigned!F && isUnsigned!G && isUnsigned!H)
{
    import std.meta : AliasSeq;

    alias T = Unqual!(Largest!(F, H));
    static if (T.sizeof <= 4)
    {
        alias DoubleT = AliasSeq!(void, ushort, uint, void, ulong)[T.sizeof];
    }

    static T mulmod(T a, T b, T c)
    {
        static if (T.sizeof == 8)
        {
            static T addmod(T a, T b, T c)
            {
                b = c - b;
                if (a >= b)
                    return a - b;
                else
                    return c - b + a;
            }

            T result = 0, tmp;

            b %= c;
            while (a > 0)
            {
                if (a & 1)
                    result = addmod(result, b, c);

                a >>= 1;
                b = addmod(b, b, c);
            }

            return result;
        }
        else
        {
            DoubleT result = cast(DoubleT) (cast(DoubleT) a * cast(DoubleT) b);
            return result % c;
        }
    }

    T base = x, result = 1, modulus = m;
    Unqual!G exponent = n;

    while (exponent > 0)
    {
        if (exponent & 1)
            result = mulmod(result, base, modulus);

        base = mulmod(base, base, modulus);
        exponent >>= 1;
    }

    return result;
}

///
@safe pure nothrow @nogc unittest
{
    assert(powmod(1U, 10U, 3U) == 1);
    assert(powmod(3U, 2U, 6U) == 3);
    assert(powmod(5U, 5U, 15U) == 5);
    assert(powmod(2U, 3U, 5U) == 3);
    assert(powmod(2U, 4U, 5U) == 1);
    assert(powmod(2U, 5U, 5U) == 2);
}

@safe pure nothrow @nogc unittest
{
    ulong a = 18446744073709551615u, b = 20u, c = 18446744073709551610u;
    assert(powmod(a, b, c) == 95367431640625u);
    a = 100; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 18223853583554725198u);
    a = 117; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 11493139548346411394u);
    a = 134; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 10979163786734356774u);
    a = 151; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 7023018419737782840u);
    a = 168; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 58082701842386811u);
    a = 185; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 17423478386299876798u);
    a = 202; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 5522733478579799075u);
    a = 219; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 15230218982491623487u);
    a = 236; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 5198328724976436000u);

    a = 0; b = 7919; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 0);
    a = 123; b = 0; c = 18446744073709551557u;
    assert(powmod(a, b, c) == 1);

    immutable ulong a1 = 253, b1 = 7919, c1 = 18446744073709551557u;
    assert(powmod(a1, b1, c1) == 3883707345459248860u);

    uint x = 100 ,y = 7919, z = 1844674407u;
    assert(powmod(x, y, z) == 1613100340u);
    x = 134; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 734956622u);
    x = 151; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 1738696945u);
    x = 168; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 1247580927u);
    x = 185; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 1293855176u);
    x = 202; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 1566963682u);
    x = 219; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 181227807u);
    x = 236; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 217988321u);
    x = 253; y = 7919; z = 1844674407u;
    assert(powmod(x, y, z) == 1588843243u);

    x = 0; y = 7919; z = 184467u;
    assert(powmod(x, y, z) == 0);
    x = 123; y = 0; z = 1844674u;
    assert(powmod(x, y, z) == 1);

    immutable ubyte x1 = 117;
    immutable uint y1 = 7919;
    immutable uint z1 = 1844674407u;
    auto res = powmod(x1, y1, z1);
    assert(is(typeof(res) == uint));
    assert(res == 9479781u);

    immutable ushort x2 = 123;
    immutable uint y2 = 203;
    immutable ubyte z2 = 113;
    auto res2 = powmod(x2, y2, z2);
    assert(is(typeof(res2) == ushort));
    assert(res2 == 42u);
}

/**************************************
 * To what precision is x equal to y?
 *
 * Returns: the number of mantissa bits which are equal in x and y.
 * eg, 0x1.F8p+60 and 0x1.F1p+60 are equal to 5 bits of precision.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)      $(TH y)          $(TH feqrel(x, y)))
 *      $(TR $(TD x)      $(TD x)          $(TD real.mant_dig))
 *      $(TR $(TD x)      $(TD $(GT)= 2*x) $(TD 0))
 *      $(TR $(TD x)      $(TD $(LT)= x/2) $(TD 0))
 *      $(TR $(TD $(NAN)) $(TD any)        $(TD 0))
 *      $(TR $(TD any)    $(TD $(NAN))     $(TD 0))
 *      )
 */
int feqrel(X)(const X x, const X y) @trusted pure nothrow @nogc
if (isFloatingPoint!(X))
{
    /* Public Domain. Author: Don Clugston, 18 Aug 2005.
     */
    alias F = floatTraits!(X);
    static if (F.realFormat == RealFormat.ieeeSingle
            || F.realFormat == RealFormat.ieeeDouble
            || F.realFormat == RealFormat.ieeeExtended
            || F.realFormat == RealFormat.ieeeExtended53
            || F.realFormat == RealFormat.ieeeQuadruple)
    {
        if (x == y)
            return X.mant_dig; // ensure diff != 0, cope with INF.

        Unqual!X diff = fabs(x - y);

        ushort *pa = cast(ushort *)(&x);
        ushort *pb = cast(ushort *)(&y);
        ushort *pd = cast(ushort *)(&diff);


        // The difference in abs(exponent) between x or y and abs(x-y)
        // is equal to the number of significand bits of x which are
        // equal to y. If negative, x and y have different exponents.
        // If positive, x and y are equal to 'bitsdiff' bits.
        // AND with 0x7FFF to form the absolute value.
        // To avoid out-by-1 errors, we subtract 1 so it rounds down
        // if the exponents were different. This means 'bitsdiff' is
        // always 1 lower than we want, except that if bitsdiff == 0,
        // they could have 0 or 1 bits in common.

        int bitsdiff = (((  (pa[F.EXPPOS_SHORT] & F.EXPMASK)
                          + (pb[F.EXPPOS_SHORT] & F.EXPMASK)
                          - (1 << F.EXPSHIFT)) >> 1)
                        - (pd[F.EXPPOS_SHORT] & F.EXPMASK)) >> F.EXPSHIFT;
        if ( (pd[F.EXPPOS_SHORT] & F.EXPMASK) == 0)
        {   // Difference is subnormal
            // For subnormals, we need to add the number of zeros that
            // lie at the start of diff's significand.
            // We do this by multiplying by 2^^real.mant_dig
            diff *= F.RECIP_EPSILON;
            return bitsdiff + X.mant_dig - ((pd[F.EXPPOS_SHORT] & F.EXPMASK) >> F.EXPSHIFT);
        }

        if (bitsdiff > 0)
            return bitsdiff + 1; // add the 1 we subtracted before

        // Avoid out-by-1 errors when factor is almost 2.
        if (bitsdiff == 0
            && ((pa[F.EXPPOS_SHORT] ^ pb[F.EXPPOS_SHORT]) & F.EXPMASK) == 0)
        {
            return 1;
        } else return 0;
    }
    else
    {
        static assert(false, "Not implemented for this architecture");
    }
}

///
@safe pure unittest
{
    assert(feqrel(2.0, 2.0) == 53);
    assert(feqrel(2.0f, 2.0f) == 24);
    assert(feqrel(2.0, double.nan) == 0);

    // Test that numbers are within n digits of each
    // other by testing if feqrel > n * log2(10)

    // five digits
    assert(feqrel(2.0, 2.00001) > 16);
    // ten digits
    assert(feqrel(2.0, 2.00000000001) > 33);
}

@safe pure nothrow @nogc unittest
{
    void testFeqrel(F)()
    {
       // Exact equality
       assert(feqrel(F.max, F.max) == F.mant_dig);
       assert(feqrel!(F)(0.0, 0.0) == F.mant_dig);
       assert(feqrel(F.infinity, F.infinity) == F.mant_dig);

       // a few bits away from exact equality
       F w=1;
       for (int i = 1; i < F.mant_dig - 1; ++i)
       {
          assert(feqrel!(F)(1.0 + w * F.epsilon, 1.0) == F.mant_dig-i);
          assert(feqrel!(F)(1.0 - w * F.epsilon, 1.0) == F.mant_dig-i);
          assert(feqrel!(F)(1.0, 1 + (w-1) * F.epsilon) == F.mant_dig - i + 1);
          w*=2;
       }

       assert(feqrel!(F)(1.5+F.epsilon, 1.5) == F.mant_dig-1);
       assert(feqrel!(F)(1.5-F.epsilon, 1.5) == F.mant_dig-1);
       assert(feqrel!(F)(1.5-F.epsilon, 1.5+F.epsilon) == F.mant_dig-2);


       // Numbers that are close
       assert(feqrel!(F)(0x1.Bp+84, 0x1.B8p+84) == 5);
       assert(feqrel!(F)(0x1.8p+10, 0x1.Cp+10) == 2);
       assert(feqrel!(F)(1.5 * (1 - F.epsilon), 1.0L) == 2);
       assert(feqrel!(F)(1.5, 1.0) == 1);
       assert(feqrel!(F)(2 * (1 - F.epsilon), 1.0L) == 1);

       // Factors of 2
       assert(feqrel(F.max, F.infinity) == 0);
       assert(feqrel!(F)(2 * (1 - F.epsilon), 1.0L) == 1);
       assert(feqrel!(F)(1.0, 2.0) == 0);
       assert(feqrel!(F)(4.0, 1.0) == 0);

       // Extreme inequality
       assert(feqrel(F.nan, F.nan) == 0);
       assert(feqrel!(F)(0.0L, -F.nan) == 0);
       assert(feqrel(F.nan, F.infinity) == 0);
       assert(feqrel(F.infinity, -F.infinity) == 0);
       assert(feqrel(F.max, -F.max) == 0);

       assert(feqrel(F.min_normal / 8, F.min_normal / 17) == 3);

       const F Const = 2;
       immutable F Immutable = 2;
       auto Compiles = feqrel(Const, Immutable);
    }

    assert(feqrel(7.1824L, 7.1824L) == real.mant_dig);

    testFeqrel!(real)();
    testFeqrel!(double)();
    testFeqrel!(float)();
}


/***********************************
 * Evaluate polynomial A(x) = $(SUB a, 0) + $(SUB a, 1)x + $(SUB a, 2)$(POWER x,2) +
 *                          $(SUB a,3)$(POWER x,3); ...
 *
 * Uses Horner's rule A(x) = $(SUB a, 0) + x($(SUB a, 1) + x($(SUB a, 2) +
 *                         x($(SUB a, 3) + ...)))
 * Params:
 *      x =     the value to evaluate.
 *      A =     array of coefficients $(SUB a, 0), $(SUB a, 1), etc.
 */
Unqual!(CommonType!(T1, T2)) poly(T1, T2)(T1 x, in T2[] A) @trusted pure nothrow @nogc
if (isFloatingPoint!T1 && isFloatingPoint!T2)
in
{
    assert(A.length > 0);
}
do
{
    static if (is(immutable T2 == immutable real))
    {
        return polyImpl(x, A);
    }
    else
    {
        return polyImplBase(x, A);
    }
}

/// ditto
Unqual!(CommonType!(T1, T2)) poly(T1, T2, int N)(T1 x, ref const T2[N] A) @safe pure nothrow @nogc
if (isFloatingPoint!T1 && isFloatingPoint!T2 && N > 0 && N <= 10)
{
    // statically unrolled version for up to 10 coefficients
    typeof(return) r = A[N - 1];
    static foreach (i; 1 .. N)
    {
        r *= x;
        r += A[N - 1 - i];
    }
    return r;
}

///
@safe nothrow @nogc unittest
{
    real x = 3.1L;
    static real[] pp = [56.1L, 32.7L, 6];

    assert(poly(x, pp) == (56.1L + (32.7L + 6.0L * x) * x));
}

@safe nothrow @nogc unittest
{
    double x = 3.1;
    static double[] pp = [56.1, 32.7, 6];
    double y = x;
    y *= 6.0;
    y += 32.7;
    y *= x;
    y += 56.1;
    assert(poly(x, pp) == y);
}

@safe unittest
{
    static assert(poly(3.0, [1.0, 2.0, 3.0]) == 34);
}

private Unqual!(CommonType!(T1, T2)) polyImplBase(T1, T2)(T1 x, in T2[] A) @trusted pure nothrow @nogc
if (isFloatingPoint!T1 && isFloatingPoint!T2)
{
    ptrdiff_t i = A.length - 1;
    typeof(return) r = A[i];
    while (--i >= 0)
    {
        r *= x;
        r += A[i];
    }
    return r;
}

private real polyImpl(real x, in real[] A) @trusted pure nothrow @nogc
{
    version (D_InlineAsm_X86)
    {
        if (__ctfe)
        {
            return polyImplBase(x, A);
        }
        version (Windows)
        {
        // BUG: This code assumes a frame pointer in EBP.
            asm pure nothrow @nogc // assembler by W. Bright
            {
                // EDX = (A.length - 1) * real.sizeof
                mov     ECX,A[EBP]              ; // ECX = A.length
                dec     ECX                     ;
                lea     EDX,[ECX][ECX*8]        ;
                add     EDX,ECX                 ;
                add     EDX,A+4[EBP]            ;
                fld     real ptr [EDX]          ; // ST0 = coeff[ECX]
                jecxz   return_ST               ;
                fld     x[EBP]                  ; // ST0 = x
                fxch    ST(1)                   ; // ST1 = x, ST0 = r
                align   4                       ;
        L2:     fmul    ST,ST(1)                ; // r *= x
                fld     real ptr -10[EDX]       ;
                sub     EDX,10                  ; // deg--
                faddp   ST(1),ST                ;
                dec     ECX                     ;
                jne     L2                      ;
                fxch    ST(1)                   ; // ST1 = r, ST0 = x
                fstp    ST(0)                   ; // dump x
                align   4                       ;
        return_ST:                              ;
            }
        }
        else version (linux)
        {
            asm pure nothrow @nogc // assembler by W. Bright
            {
                // EDX = (A.length - 1) * real.sizeof
                mov     ECX,A[EBP]              ; // ECX = A.length
                dec     ECX                     ;
                lea     EDX,[ECX*8]             ;
                lea     EDX,[EDX][ECX*4]        ;
                add     EDX,A+4[EBP]            ;
                fld     real ptr [EDX]          ; // ST0 = coeff[ECX]
                jecxz   return_ST               ;
                fld     x[EBP]                  ; // ST0 = x
                fxch    ST(1)                   ; // ST1 = x, ST0 = r
                align   4                       ;
        L2:     fmul    ST,ST(1)                ; // r *= x
                fld     real ptr -12[EDX]       ;
                sub     EDX,12                  ; // deg--
                faddp   ST(1),ST                ;
                dec     ECX                     ;
                jne     L2                      ;
                fxch    ST(1)                   ; // ST1 = r, ST0 = x
                fstp    ST(0)                   ; // dump x
                align   4                       ;
        return_ST:                              ;
            }
        }
        else version (OSX)
        {
            asm pure nothrow @nogc // assembler by W. Bright
            {
                // EDX = (A.length - 1) * real.sizeof
                mov     ECX,A[EBP]              ; // ECX = A.length
                dec     ECX                     ;
                lea     EDX,[ECX*8]             ;
                add     EDX,EDX                 ;
                add     EDX,A+4[EBP]            ;
                fld     real ptr [EDX]          ; // ST0 = coeff[ECX]
                jecxz   return_ST               ;
                fld     x[EBP]                  ; // ST0 = x
                fxch    ST(1)                   ; // ST1 = x, ST0 = r
                align   4                       ;
        L2:     fmul    ST,ST(1)                ; // r *= x
                fld     real ptr -16[EDX]       ;
                sub     EDX,16                  ; // deg--
                faddp   ST(1),ST                ;
                dec     ECX                     ;
                jne     L2                      ;
                fxch    ST(1)                   ; // ST1 = r, ST0 = x
                fstp    ST(0)                   ; // dump x
                align   4                       ;
        return_ST:                              ;
            }
        }
        else version (FreeBSD)
        {
            asm pure nothrow @nogc // assembler by W. Bright
            {
                // EDX = (A.length - 1) * real.sizeof
                mov     ECX,A[EBP]              ; // ECX = A.length
                dec     ECX                     ;
                lea     EDX,[ECX*8]             ;
                lea     EDX,[EDX][ECX*4]        ;
                add     EDX,A+4[EBP]            ;
                fld     real ptr [EDX]          ; // ST0 = coeff[ECX]
                jecxz   return_ST               ;
                fld     x[EBP]                  ; // ST0 = x
                fxch    ST(1)                   ; // ST1 = x, ST0 = r
                align   4                       ;
        L2:     fmul    ST,ST(1)                ; // r *= x
                fld     real ptr -12[EDX]       ;
                sub     EDX,12                  ; // deg--
                faddp   ST(1),ST                ;
                dec     ECX                     ;
                jne     L2                      ;
                fxch    ST(1)                   ; // ST1 = r, ST0 = x
                fstp    ST(0)                   ; // dump x
                align   4                       ;
        return_ST:                              ;
            }
        }
        else version (Solaris)
        {
            asm pure nothrow @nogc // assembler by W. Bright
            {
                // EDX = (A.length - 1) * real.sizeof
                mov     ECX,A[EBP]              ; // ECX = A.length
                dec     ECX                     ;
                lea     EDX,[ECX*8]             ;
                lea     EDX,[EDX][ECX*4]        ;
                add     EDX,A+4[EBP]            ;
                fld     real ptr [EDX]          ; // ST0 = coeff[ECX]
                jecxz   return_ST               ;
                fld     x[EBP]                  ; // ST0 = x
                fxch    ST(1)                   ; // ST1 = x, ST0 = r
                align   4                       ;
        L2:     fmul    ST,ST(1)                ; // r *= x
                fld     real ptr -12[EDX]       ;
                sub     EDX,12                  ; // deg--
                faddp   ST(1),ST                ;
                dec     ECX                     ;
                jne     L2                      ;
                fxch    ST(1)                   ; // ST1 = r, ST0 = x
                fstp    ST(0)                   ; // dump x
                align   4                       ;
        return_ST:                              ;
            }
        }
        else version (DragonFlyBSD)
        {
            asm pure nothrow @nogc // assembler by W. Bright
            {
                // EDX = (A.length - 1) * real.sizeof
                mov     ECX,A[EBP]              ; // ECX = A.length
                dec     ECX                     ;
                lea     EDX,[ECX*8]             ;
                lea     EDX,[EDX][ECX*4]        ;
                add     EDX,A+4[EBP]            ;
                fld     real ptr [EDX]          ; // ST0 = coeff[ECX]
                jecxz   return_ST               ;
                fld     x[EBP]                  ; // ST0 = x
                fxch    ST(1)                   ; // ST1 = x, ST0 = r
                align   4                       ;
        L2:     fmul    ST,ST(1)                ; // r *= x
                fld     real ptr -12[EDX]       ;
                sub     EDX,12                  ; // deg--
                faddp   ST(1),ST                ;
                dec     ECX                     ;
                jne     L2                      ;
                fxch    ST(1)                   ; // ST1 = r, ST0 = x
                fstp    ST(0)                   ; // dump x
                align   4                       ;
        return_ST:                              ;
            }
        }
        else
        {
            static assert(0);
        }
    }
    else
    {
        return polyImplBase(x, A);
    }
}


/**
   Computes whether a values is approximately equal to a reference value,
   admitting a maximum relative difference, and a maximum absolute difference.

   Warning:
        This template is considered out-dated. It will be removed from
        Phobos in 2.106.0. Please use $(LREF isClose) instead.

   Params:
        value = Value to compare.
        reference = Reference value.
        maxRelDiff = Maximum allowable difference relative to `reference`.
        Setting to 0.0 disables this check. Defaults to `1e-2`.
        maxAbsDiff = Maximum absolute difference. This is mainly usefull
        for comparing values to zero. Setting to 0.0 disables this check.
        Defaults to `1e-5`.

   Returns:
       `true` if `value` is approximately equal to `reference` under
       either criterium. It is sufficient, when `value ` satisfies
       one of the two criteria.

       If one item is a range, and the other is a single value, then
       the result is the logical and-ing of calling `approxEqual` on
       each element of the ranged item against the single item. If
       both items are ranges, then `approxEqual` returns `true` if
       and only if the ranges have the same number of elements and if
       `approxEqual` evaluates to `true` for each pair of elements.

    See_Also:
        Use $(LREF feqrel) to get the number of equal bits in the mantissa.
 */
deprecated("approxEqual will be removed in 2.106.0. Please use isClose instead.")
bool approxEqual(T, U, V)(T value, U reference, V maxRelDiff = 1e-2, V maxAbsDiff = 1e-5)
{
    import std.range.primitives : empty, front, isInputRange, popFront;
    static if (isInputRange!T)
    {
        static if (isInputRange!U)
        {
            // Two ranges
            for (;; value.popFront(), reference.popFront())
            {
                if (value.empty) return reference.empty;
                if (reference.empty) return value.empty;
                if (!approxEqual(value.front, reference.front, maxRelDiff, maxAbsDiff))
                    return false;
            }
        }
        else static if (isIntegral!U)
        {
            // convert reference to real
            return approxEqual(value, real(reference), maxRelDiff, maxAbsDiff);
        }
        else
        {
            // value is range, reference is number
            for (; !value.empty; value.popFront())
            {
                if (!approxEqual(value.front, reference, maxRelDiff, maxAbsDiff))
                    return false;
            }
            return true;
        }
    }
    else
    {
        static if (isInputRange!U)
        {
            // value is number, reference is range
            for (; !reference.empty; reference.popFront())
            {
                if (!approxEqual(value, reference.front, maxRelDiff, maxAbsDiff))
                    return false;
            }
            return true;
        }
        else static if (isIntegral!T || isIntegral!U)
        {
            // convert both value and reference to real
            return approxEqual(real(value), real(reference), maxRelDiff, maxAbsDiff);
        }
        else
        {
            // two numbers
            //static assert(is(T : real) && is(U : real));
            if (reference == 0)
            {
                return fabs(value) <= maxAbsDiff;
            }
            static if (is(typeof(value.infinity)) && is(typeof(reference.infinity)))
            {
                if (value == value.infinity && reference == reference.infinity ||
                    value == -value.infinity && reference == -reference.infinity) return true;
            }
            return fabs((value - reference) / reference) <= maxRelDiff
                || maxAbsDiff != 0 && fabs(value - reference) <= maxAbsDiff;
        }
    }
}

deprecated @safe pure nothrow unittest
{
    assert(approxEqual(1.0, 1.0099));
    assert(!approxEqual(1.0, 1.011));
    assert(approxEqual(0.00001, 0.0));
    assert(!approxEqual(0.00002, 0.0));

    assert(approxEqual(3.0, [3, 3.01, 2.99])); // several reference values is strange
    assert(approxEqual([3, 3.01, 2.99], 3.0)); // better

    float[] arr1 = [ 1.0, 2.0, 3.0 ];
    double[] arr2 = [ 1.001, 1.999, 3 ];
    assert(approxEqual(arr1, arr2));
}

deprecated @safe pure nothrow unittest
{
    // relative comparison depends on reference, make sure proper
    // side is used when comparing range to single value. Based on
    // https://issues.dlang.org/show_bug.cgi?id=15763
    auto a = [2e-3 - 1e-5];
    auto b = 2e-3 + 1e-5;
    assert(a[0].approxEqual(b));
    assert(!b.approxEqual(a[0]));
    assert(a.approxEqual(b));
    assert(!b.approxEqual(a));
}

deprecated @safe pure nothrow @nogc unittest
{
    assert(!approxEqual(0.0,1e-15,1e-9,0.0));
    assert(approxEqual(0.0,1e-15,1e-9,1e-9));
    assert(!approxEqual(1.0,3.0,0.0,1.0));

    assert(approxEqual(1.00000000099,1.0,1e-9,0.0));
    assert(!approxEqual(1.0000000011,1.0,1e-9,0.0));
}

deprecated @safe pure nothrow @nogc unittest
{
    // maybe unintuitive behavior
    assert(approxEqual(1000.0,1010.0));
    assert(approxEqual(9_090_000_000.0,9_000_000_000.0));
    assert(approxEqual(0.0,1e30,1.0));
    assert(approxEqual(0.00001,1e-30));
    assert(!approxEqual(-1e-30,1e-30,1e-2,0.0));
}

deprecated @safe pure nothrow @nogc unittest
{
    int a = 10;
    assert(approxEqual(10, a));

    assert(!approxEqual(3, 0));
    assert(approxEqual(3, 3));
    assert(approxEqual(3.0, 3));
    assert(approxEqual(3, 3.0));

    assert(approxEqual(0.0,0.0));
    assert(approxEqual(-0.0,0.0));
    assert(approxEqual(0.0f,0.0));
}

deprecated @safe pure nothrow @nogc unittest
{
    real num = real.infinity;
    assert(num == real.infinity);
    assert(approxEqual(num, real.infinity));
    num = -real.infinity;
    assert(num == -real.infinity);
    assert(approxEqual(num, -real.infinity));

    assert(!approxEqual(1,real.nan));
    assert(!approxEqual(real.nan,real.max));
    assert(!approxEqual(real.nan,real.nan));
}

deprecated @safe pure nothrow unittest
{
    assert(!approxEqual([1.0,2.0,3.0],[1.0,2.0]));
    assert(!approxEqual([1.0,2.0],[1.0,2.0,3.0]));

    assert(approxEqual!(real[],real[])([],[]));
    assert(approxEqual(cast(real[])[],cast(real[])[]));
}


/**
   Computes whether two values are approximately equal, admitting a maximum
   relative difference, and a maximum absolute difference.

   Params:
        lhs = First item to compare.
        rhs = Second item to compare.
        maxRelDiff = Maximum allowable relative difference.
        Setting to 0.0 disables this check. Default depends on the type of
        `lhs` and `rhs`: It is approximately half the number of decimal digits of
        precision of the smaller type.
        maxAbsDiff = Maximum absolute difference. This is mainly usefull
        for comparing values to zero. Setting to 0.0 disables this check.
        Defaults to `0.0`.

   Returns:
       `true` if the two items are approximately equal under either criterium.
       It is sufficient, when `value ` satisfies one of the two criteria.

       If one item is a range, and the other is a single value, then
       the result is the logical and-ing of calling `isClose` on
       each element of the ranged item against the single item. If
       both items are ranges, then `isClose` returns `true` if
       and only if the ranges have the same number of elements and if
       `isClose` evaluates to `true` for each pair of elements.

    See_Also:
        Use $(LREF feqrel) to get the number of equal bits in the mantissa.
 */
bool isClose(T, U, V = CommonType!(FloatingPointBaseType!T,FloatingPointBaseType!U))
    (T lhs, U rhs, V maxRelDiff = CommonDefaultFor!(T,U), V maxAbsDiff = 0.0)
{
    import std.range.primitives : empty, front, isInputRange, popFront;
    import std.complex : Complex;
    static if (isInputRange!T)
    {
        static if (isInputRange!U)
        {
            // Two ranges
            for (;; lhs.popFront(), rhs.popFront())
            {
                if (lhs.empty) return rhs.empty;
                if (rhs.empty) return lhs.empty;
                if (!isClose(lhs.front, rhs.front, maxRelDiff, maxAbsDiff))
                    return false;
            }
        }
        else
        {
            // lhs is range, rhs is number
            for (; !lhs.empty; lhs.popFront())
            {
                if (!isClose(lhs.front, rhs, maxRelDiff, maxAbsDiff))
                    return false;
            }
            return true;
        }
    }
    else static if (isInputRange!U)
    {
        // lhs is number, rhs is range
        for (; !rhs.empty; rhs.popFront())
        {
            if (!isClose(lhs, rhs.front, maxRelDiff, maxAbsDiff))
                return false;
        }
        return true;
    }
    else static if (is(T TE == Complex!TE))
    {
        static if (is(U UE == Complex!UE))
        {
            // Two complex numbers
            return isClose(lhs.re, rhs.re, maxRelDiff, maxAbsDiff)
                && isClose(lhs.im, rhs.im, maxRelDiff, maxAbsDiff);
        }
        else
        {
            // lhs is complex, rhs is number
            return isClose(lhs.re, rhs, maxRelDiff, maxAbsDiff)
                && isClose(lhs.im, 0.0, maxRelDiff, maxAbsDiff);
        }
    }
    else static if (is(U UE == Complex!UE))
    {
        // lhs is number, rhs is complex
        return isClose(lhs, rhs.re, maxRelDiff, maxAbsDiff)
            && isClose(0.0, rhs.im, maxRelDiff, maxAbsDiff);
    }
    else
    {
        // two numbers
        if (lhs == rhs) return true;

        static if (is(typeof(lhs.infinity)) && is(typeof(rhs.infinity)))
        {
            if (lhs == lhs.infinity || rhs == rhs.infinity ||
                lhs == -lhs.infinity || rhs == -rhs.infinity) return false;
        }

        auto diff = abs(lhs - rhs);

        return diff <= maxRelDiff*abs(lhs)
            || diff <= maxRelDiff*abs(rhs)
            || diff <= maxAbsDiff;
    }
}

///
@safe pure nothrow @nogc unittest
{
    assert(isClose(1.0,0.999_999_999));
    assert(isClose(0.001, 0.000_999_999_999));
    assert(isClose(1_000_000_000.0,999_999_999.0));

    assert(isClose(17.123_456_789, 17.123_456_78));
    assert(!isClose(17.123_456_789, 17.123_45));

    // use explicit 3rd parameter for less (or more) accuracy
    assert(isClose(17.123_456_789, 17.123_45, 1e-6));
    assert(!isClose(17.123_456_789, 17.123_45, 1e-7));

    // use 4th parameter when comparing close to zero
    assert(!isClose(1e-100, 0.0));
    assert(isClose(1e-100, 0.0, 0.0, 1e-90));
    assert(!isClose(1e-10, -1e-10));
    assert(isClose(1e-10, -1e-10, 0.0, 1e-9));
    assert(!isClose(1e-300, 1e-298));
    assert(isClose(1e-300, 1e-298, 0.0, 1e-200));

    // different default limits for different floating point types
    assert(isClose(1.0f, 0.999_99f));
    assert(!isClose(1.0, 0.999_99));
    static if (real.sizeof > double.sizeof)
        assert(!isClose(1.0L, 0.999_999_999L));
}

///
@safe pure nothrow unittest
{
    assert(isClose([1.0, 2.0, 3.0], [0.999_999_999, 2.000_000_001, 3.0]));
    assert(!isClose([1.0, 2.0], [0.999_999_999, 2.000_000_001, 3.0]));
    assert(!isClose([1.0, 2.0, 3.0], [0.999_999_999, 2.000_000_001]));

    assert(isClose([2.0, 1.999_999_999, 2.000_000_001], 2.0));
    assert(isClose(2.0, [2.0, 1.999_999_999, 2.000_000_001]));
}

@safe pure nothrow unittest
{
    assert(!isClose([1.0, 2.0, 3.0], [0.999_999_999, 3.0, 3.0]));
    assert(!isClose([2.0, 1.999_999, 2.000_000_001], 2.0));
    assert(!isClose(2.0, [2.0, 1.999_999_999, 2.000_000_999]));
}

@safe pure nothrow @nogc unittest
{
    immutable a = 1.00001f;
    const b = 1.000019;
    assert(isClose(a,b));

    assert(isClose(1.00001f,1.000019f));
    assert(isClose(1.00001f,1.000019));
    assert(isClose(1.00001,1.000019f));
    assert(!isClose(1.00001,1.000019));

    real a1 = 1e-300L;
    real a2 = a1.nextUp;
    assert(isClose(a1,a2));
}

@safe pure nothrow unittest
{
    float[] arr1 = [ 1.0, 2.0, 3.0 ];
    double[] arr2 = [ 1.00001, 1.99999, 3 ];
    assert(isClose(arr1, arr2));
}

@safe pure nothrow @nogc unittest
{
    assert(!isClose(1000.0,1010.0));
    assert(!isClose(9_090_000_000.0,9_000_000_000.0));
    assert(isClose(0.0,1e30,1.0));
    assert(!isClose(0.00001,1e-30));
    assert(!isClose(-1e-30,1e-30,1e-2,0.0));
}

@safe pure nothrow @nogc unittest
{
    assert(!isClose(3, 0));
    assert(isClose(3, 3));
    assert(isClose(3.0, 3));
    assert(isClose(3, 3.0));

    assert(isClose(0.0,0.0));
    assert(isClose(-0.0,0.0));
    assert(isClose(0.0f,0.0));
}

@safe pure nothrow @nogc unittest
{
    real num = real.infinity;
    assert(num == real.infinity);
    assert(isClose(num, real.infinity));
    num = -real.infinity;
    assert(num == -real.infinity);
    assert(isClose(num, -real.infinity));

    assert(!isClose(1,real.nan));
    assert(!isClose(real.nan,real.max));
    assert(!isClose(real.nan,real.nan));
}

@safe pure nothrow @nogc unittest
{
    assert(isClose!(real[],real[],real)([],[]));
    assert(isClose(cast(real[])[],cast(real[])[]));
}

@safe pure nothrow @nogc unittest
{
    import std.conv : to;

    float f = 31.79f;
    double d = 31.79;
    double f2d = f.to!double;

    assert(isClose(f,f2d));
    assert(!isClose(d,f2d));
}

@safe pure nothrow @nogc unittest
{
    import std.conv : to;

    double d = 31.79;
    float f = d.to!float;
    double f2d = f.to!double;

    assert(isClose(f,f2d));
    assert(!isClose(d,f2d));
    assert(isClose(d,f2d,1e-4));
}

private template CommonDefaultFor(T,U)
{
    import std.algorithm.comparison : min;

    alias baseT = FloatingPointBaseType!T;
    alias baseU = FloatingPointBaseType!U;

    enum CommonType!(baseT, baseU) CommonDefaultFor = 10.0L ^^ -((min(baseT.dig, baseU.dig) + 1) / 2 + 1);
}

private template FloatingPointBaseType(T)
{
    import std.range.primitives : ElementType;
    static if (isFloatingPoint!T)
    {
        alias FloatingPointBaseType = Unqual!T;
    }
    else static if (isFloatingPoint!(ElementType!(Unqual!T)))
    {
        alias FloatingPointBaseType = Unqual!(ElementType!(Unqual!T));
    }
    else
    {
        alias FloatingPointBaseType = real;
    }
}


@safe pure nothrow @nogc unittest
{
    float f = sqrt(2.0f);
    assert(fabs(f * f - 2.0f) < .00001);

    double d = sqrt(2.0);
    assert(fabs(d * d - 2.0) < .00001);

    real r = sqrt(2.0L);
    assert(fabs(r * r - 2.0) < .00001);
}

@safe pure nothrow @nogc unittest
{
    float f = fabs(-2.0f);
    assert(f == 2);

    double d = fabs(-2.0);
    assert(d == 2);

    real r = fabs(-2.0L);
    assert(r == 2);
}

@safe pure nothrow @nogc unittest
{
    float f = sin(-2.0f);
    assert(fabs(f - -0.909297f) < .00001);

    double d = sin(-2.0);
    assert(fabs(d - -0.909297f) < .00001);

    real r = sin(-2.0L);
    assert(fabs(r - -0.909297f) < .00001);
}

@safe pure nothrow @nogc unittest
{
    float f = cos(-2.0f);
    assert(fabs(f - -0.416147f) < .00001);

    double d = cos(-2.0);
    assert(fabs(d - -0.416147f) < .00001);

    real r = cos(-2.0L);
    assert(fabs(r - -0.416147f) < .00001);
}

@safe pure nothrow @nogc unittest
{
    float f = tan(-2.0f);
    assert(fabs(f - 2.18504f) < .00001);

    double d = tan(-2.0);
    assert(fabs(d - 2.18504f) < .00001);

    real r = tan(-2.0L);
    assert(fabs(r - 2.18504f) < .00001);

    // Verify correct behavior for large inputs
    assert(!isNaN(tan(0x1p63)));
    assert(!isNaN(tan(-0x1p63)));
    static if (real.mant_dig >= 64)
    {
        assert(!isNaN(tan(0x1p300L)));
        assert(!isNaN(tan(-0x1p300L)));
    }
}

// https://issues.dlang.org/show_bug.cgi?id=6381
// floor/ceil should be usable in pure function.
@safe pure nothrow unittest
{
    auto x = floor(1.2);
    auto y = ceil(1.2);
}

/***********************************
 * Defines a total order on all floating-point numbers.
 *
 * The order is defined as follows:
 * $(UL
 *      $(LI All numbers in [-$(INFIN), +$(INFIN)] are ordered
 *          the same way as by built-in comparison, with the exception of
 *          -0.0, which is less than +0.0;)
 *      $(LI If the sign bit is set (that is, it's 'negative'), $(NAN) is less
 *          than any number; if the sign bit is not set (it is 'positive'),
 *          $(NAN) is greater than any number;)
 *      $(LI $(NAN)s of the same sign are ordered by the payload ('negative'
 *          ones - in reverse order).)
 * )
 *
 * Returns:
 *      negative value if `x` precedes `y` in the order specified above;
 *      0 if `x` and `y` are identical, and positive value otherwise.
 *
 * See_Also:
 *      $(MYREF isIdentical)
 * Standards: Conforms to IEEE 754-2008
 */
int cmp(T)(const(T) x, const(T) y) @nogc @trusted pure nothrow
if (isFloatingPoint!T)
{
    alias F = floatTraits!T;

    static if (F.realFormat == RealFormat.ieeeSingle
               || F.realFormat == RealFormat.ieeeDouble)
    {
        static if (T.sizeof == 4)
            alias UInt = uint;
        else
            alias UInt = ulong;

        union Repainter
        {
            T number;
            UInt bits;
        }

        enum msb = ~(UInt.max >>> 1);

        import std.typecons : Tuple;
        Tuple!(Repainter, Repainter) vars = void;
        vars[0].number = x;
        vars[1].number = y;

        foreach (ref var; vars)
            if (var.bits & msb)
                var.bits = ~var.bits;
            else
                var.bits |= msb;

        if (vars[0].bits < vars[1].bits)
            return -1;
        else if (vars[0].bits > vars[1].bits)
            return 1;
        else
            return 0;
    }
    else static if (F.realFormat == RealFormat.ieeeExtended53
                    || F.realFormat == RealFormat.ieeeExtended
                    || F.realFormat == RealFormat.ieeeQuadruple)
    {
        static if (F.realFormat == RealFormat.ieeeQuadruple)
            alias RemT = ulong;
        else
            alias RemT = ushort;

        struct Bits
        {
            ulong bulk;
            RemT rem;
        }

        union Repainter
        {
            T number;
            Bits bits;
            ubyte[T.sizeof] bytes;
        }

        import std.typecons : Tuple;
        Tuple!(Repainter, Repainter) vars = void;
        vars[0].number = x;
        vars[1].number = y;

        foreach (ref var; vars)
            if (var.bytes[F.SIGNPOS_BYTE] & 0x80)
            {
                var.bits.bulk = ~var.bits.bulk;
                var.bits.rem = cast(typeof(var.bits.rem))(-1 - var.bits.rem); // ~var.bits.rem
            }
            else
            {
                var.bytes[F.SIGNPOS_BYTE] |= 0x80;
            }

        version (LittleEndian)
        {
            if (vars[0].bits.rem < vars[1].bits.rem)
                return -1;
            else if (vars[0].bits.rem > vars[1].bits.rem)
                return 1;
            else if (vars[0].bits.bulk < vars[1].bits.bulk)
                return -1;
            else if (vars[0].bits.bulk > vars[1].bits.bulk)
                return 1;
            else
                return 0;
        }
        else
        {
            if (vars[0].bits.bulk < vars[1].bits.bulk)
                return -1;
            else if (vars[0].bits.bulk > vars[1].bits.bulk)
                return 1;
            else if (vars[0].bits.rem < vars[1].bits.rem)
                return -1;
            else if (vars[0].bits.rem > vars[1].bits.rem)
                return 1;
            else
                return 0;
        }
    }
    else
    {
        // IBM Extended doubledouble does not follow the general
        // sign-exponent-significand layout, so has to be handled generically

        const int xSign = signbit(x),
            ySign = signbit(y);

        if (xSign == 1 && ySign == 1)
            return cmp(-y, -x);
        else if (xSign == 1)
            return -1;
        else if (ySign == 1)
            return 1;
        else if (x < y)
            return -1;
        else if (x == y)
            return 0;
        else if (x > y)
            return 1;
        else if (isNaN(x) && !isNaN(y))
            return 1;
        else if (isNaN(y) && !isNaN(x))
            return -1;
        else if (getNaNPayload(x) < getNaNPayload(y))
            return -1;
        else if (getNaNPayload(x) > getNaNPayload(y))
            return 1;
        else
            return 0;
    }
}

/// Most numbers are ordered naturally.
@safe unittest
{
    assert(cmp(-double.infinity, -double.max) < 0);
    assert(cmp(-double.max, -100.0) < 0);
    assert(cmp(-100.0, -0.5) < 0);
    assert(cmp(-0.5, 0.0) < 0);
    assert(cmp(0.0, 0.5) < 0);
    assert(cmp(0.5, 100.0) < 0);
    assert(cmp(100.0, double.max) < 0);
    assert(cmp(double.max, double.infinity) < 0);

    assert(cmp(1.0, 1.0) == 0);
}

/// Positive and negative zeroes are distinct.
@safe unittest
{
    assert(cmp(-0.0, +0.0) < 0);
    assert(cmp(+0.0, -0.0) > 0);
}

/// Depending on the sign, $(NAN)s go to either end of the spectrum.
@safe unittest
{
    assert(cmp(-double.nan, -double.infinity) < 0);
    assert(cmp(double.infinity, double.nan) < 0);
    assert(cmp(-double.nan, double.nan) < 0);
}

/// $(NAN)s of the same sign are ordered by the payload.
@safe unittest
{
    assert(cmp(NaN(10), NaN(20)) < 0);
    assert(cmp(-NaN(20), -NaN(10)) < 0);
}

@safe unittest
{
    import std.meta : AliasSeq;
    static foreach (T; AliasSeq!(float, double, real))
    {{
        T[] values = [-cast(T) NaN(20), -cast(T) NaN(10), -T.nan, -T.infinity,
                      -T.max, -T.max / 2, T(-16.0), T(-1.0).nextDown,
                      T(-1.0), T(-1.0).nextUp,
                      T(-0.5), -T.min_normal, (-T.min_normal).nextUp,
                      -2 * T.min_normal * T.epsilon,
                      -T.min_normal * T.epsilon,
                      T(-0.0), T(0.0),
                      T.min_normal * T.epsilon,
                      2 * T.min_normal * T.epsilon,
                      T.min_normal.nextDown, T.min_normal, T(0.5),
                      T(1.0).nextDown, T(1.0),
                      T(1.0).nextUp, T(16.0), T.max / 2, T.max,
                      T.infinity, T.nan, cast(T) NaN(10), cast(T) NaN(20)];

        foreach (i, x; values)
        {
            foreach (y; values[i + 1 .. $])
            {
                assert(cmp(x, y) < 0);
                assert(cmp(y, x) > 0);
            }
            assert(cmp(x, x) == 0);
        }
    }}
}

private enum PowType
{
    floor,
    ceil
}

pragma(inline, true)
private T powIntegralImpl(PowType type, T)(T val)
{
    import core.bitop : bsr;

    if (val == 0 || (type == PowType.ceil && (val > T.max / 2 || val == T.min)))
        return 0;
    else
    {
        static if (isSigned!T)
            return cast(Unqual!T) (val < 0 ? -(T(1) << bsr(0 - val) + type) : T(1) << bsr(val) + type);
        else
            return cast(Unqual!T) (T(1) << bsr(val) + type);
    }
}

private T powFloatingPointImpl(PowType type, T)(T x)
{
    if (!x.isFinite)
        return x;

    if (!x)
        return x;

    int exp;
    auto y = frexp(x, exp);

    static if (type == PowType.ceil)
        y = ldexp(cast(T) 0.5, exp + 1);
    else
        y = ldexp(cast(T) 0.5, exp);

    if (!y.isFinite)
        return cast(T) 0.0;

    y = copysign(y, x);

    return y;
}

/**
 * Gives the next power of two after `val`. `T` can be any built-in
 * numerical type.
 *
 * If the operation would lead to an over/underflow, this function will
 * return `0`.
 *
 * Params:
 *     val = any number
 *
 * Returns:
 *     the next power of two after `val`
 */
T nextPow2(T)(const T val)
if (isIntegral!T)
{
    return powIntegralImpl!(PowType.ceil)(val);
}

/// ditto
T nextPow2(T)(const T val)
if (isFloatingPoint!T)
{
    return powFloatingPointImpl!(PowType.ceil)(val);
}

///
@safe @nogc pure nothrow unittest
{
    assert(nextPow2(2) == 4);
    assert(nextPow2(10) == 16);
    assert(nextPow2(4000) == 4096);

    assert(nextPow2(-2) == -4);
    assert(nextPow2(-10) == -16);

    assert(nextPow2(uint.max) == 0);
    assert(nextPow2(uint.min) == 0);
    assert(nextPow2(size_t.max) == 0);
    assert(nextPow2(size_t.min) == 0);

    assert(nextPow2(int.max) == 0);
    assert(nextPow2(int.min) == 0);
    assert(nextPow2(long.max) == 0);
    assert(nextPow2(long.min) == 0);
}

///
@safe @nogc pure nothrow unittest
{
    assert(nextPow2(2.1) == 4.0);
    assert(nextPow2(-2.0) == -4.0);
    assert(nextPow2(0.25) == 0.5);
    assert(nextPow2(-4.0) == -8.0);

    assert(nextPow2(double.max) == 0.0);
    assert(nextPow2(double.infinity) == double.infinity);
}

@safe @nogc pure nothrow unittest
{
    assert(nextPow2(ubyte(2)) == 4);
    assert(nextPow2(ubyte(10)) == 16);

    assert(nextPow2(byte(2)) == 4);
    assert(nextPow2(byte(10)) == 16);

    assert(nextPow2(short(2)) == 4);
    assert(nextPow2(short(10)) == 16);
    assert(nextPow2(short(4000)) == 4096);

    assert(nextPow2(ushort(2)) == 4);
    assert(nextPow2(ushort(10)) == 16);
    assert(nextPow2(ushort(4000)) == 4096);
}

@safe @nogc pure nothrow unittest
{
    foreach (ulong i; 1 .. 62)
    {
        assert(nextPow2(1UL << i) == 2UL << i);
        assert(nextPow2((1UL << i) - 1) == 1UL << i);
        assert(nextPow2((1UL << i) + 1) == 2UL << i);
        assert(nextPow2((1UL << i) + (1UL<<(i-1))) == 2UL << i);
    }
}

@safe @nogc pure nothrow unittest
{
    import std.meta : AliasSeq;

    static foreach (T; AliasSeq!(float, double, real))
    {{
        enum T subNormal = T.min_normal / 2;

        static if (subNormal) assert(nextPow2(subNormal) == T.min_normal);

        assert(nextPow2(T(0.0)) == 0.0);

        assert(nextPow2(T(2.0)) == 4.0);
        assert(nextPow2(T(2.1)) == 4.0);
        assert(nextPow2(T(3.1)) == 4.0);
        assert(nextPow2(T(4.0)) == 8.0);
        assert(nextPow2(T(0.25)) == 0.5);

        assert(nextPow2(T(-2.0)) == -4.0);
        assert(nextPow2(T(-2.1)) == -4.0);
        assert(nextPow2(T(-3.1)) == -4.0);
        assert(nextPow2(T(-4.0)) == -8.0);
        assert(nextPow2(T(-0.25)) == -0.5);

        assert(nextPow2(T.max) == 0);
        assert(nextPow2(-T.max) == 0);

        assert(nextPow2(T.infinity) == T.infinity);
        assert(nextPow2(T.init).isNaN);
    }}
}

// https://issues.dlang.org/show_bug.cgi?id=15973
@safe @nogc pure nothrow unittest
{
    assert(nextPow2(uint.max / 2) == uint.max / 2 + 1);
    assert(nextPow2(uint.max / 2 + 2) == 0);
    assert(nextPow2(int.max / 2) == int.max / 2 + 1);
    assert(nextPow2(int.max / 2 + 2) == 0);
    assert(nextPow2(int.min + 1) == int.min);
}

/**
 * Gives the last power of two before `val`. $(T) can be any built-in
 * numerical type.
 *
 * Params:
 *     val = any number
 *
 * Returns:
 *     the last power of two before `val`
 */
T truncPow2(T)(const T val)
if (isIntegral!T)
{
    return powIntegralImpl!(PowType.floor)(val);
}

/// ditto
T truncPow2(T)(const T val)
if (isFloatingPoint!T)
{
    return powFloatingPointImpl!(PowType.floor)(val);
}

///
@safe @nogc pure nothrow unittest
{
    assert(truncPow2(3) == 2);
    assert(truncPow2(4) == 4);
    assert(truncPow2(10) == 8);
    assert(truncPow2(4000) == 2048);

    assert(truncPow2(-5) == -4);
    assert(truncPow2(-20) == -16);

    assert(truncPow2(uint.max) == int.max + 1);
    assert(truncPow2(uint.min) == 0);
    assert(truncPow2(ulong.max) == long.max + 1);
    assert(truncPow2(ulong.min) == 0);

    assert(truncPow2(int.max) == (int.max / 2) + 1);
    assert(truncPow2(int.min) == int.min);
    assert(truncPow2(long.max) == (long.max / 2) + 1);
    assert(truncPow2(long.min) == long.min);
}

///
@safe @nogc pure nothrow unittest
{
    assert(truncPow2(2.1) == 2.0);
    assert(truncPow2(7.0) == 4.0);
    assert(truncPow2(-1.9) == -1.0);
    assert(truncPow2(0.24) == 0.125);
    assert(truncPow2(-7.0) == -4.0);

    assert(truncPow2(double.infinity) == double.infinity);
}

@safe @nogc pure nothrow unittest
{
    assert(truncPow2(ubyte(3)) == 2);
    assert(truncPow2(ubyte(4)) == 4);
    assert(truncPow2(ubyte(10)) == 8);

    assert(truncPow2(byte(3)) == 2);
    assert(truncPow2(byte(4)) == 4);
    assert(truncPow2(byte(10)) == 8);

    assert(truncPow2(ushort(3)) == 2);
    assert(truncPow2(ushort(4)) == 4);
    assert(truncPow2(ushort(10)) == 8);
    assert(truncPow2(ushort(4000)) == 2048);

    assert(truncPow2(short(3)) == 2);
    assert(truncPow2(short(4)) == 4);
    assert(truncPow2(short(10)) == 8);
    assert(truncPow2(short(4000)) == 2048);
}

@safe @nogc pure nothrow unittest
{
    foreach (ulong i; 1 .. 62)
    {
        assert(truncPow2(2UL << i) == 2UL << i);
        assert(truncPow2((2UL << i) + 1) == 2UL << i);
        assert(truncPow2((2UL << i) - 1) == 1UL << i);
        assert(truncPow2((2UL << i) - (2UL<<(i-1))) == 1UL << i);
    }
}

@safe @nogc pure nothrow unittest
{
    import std.meta : AliasSeq;

    static foreach (T; AliasSeq!(float, double, real))
    {
        assert(truncPow2(T(0.0)) == 0.0);

        assert(truncPow2(T(4.0)) == 4.0);
        assert(truncPow2(T(2.1)) == 2.0);
        assert(truncPow2(T(3.5)) == 2.0);
        assert(truncPow2(T(7.0)) == 4.0);
        assert(truncPow2(T(0.24)) == 0.125);

        assert(truncPow2(T(-2.0)) == -2.0);
        assert(truncPow2(T(-2.1)) == -2.0);
        assert(truncPow2(T(-3.1)) == -2.0);
        assert(truncPow2(T(-7.0)) == -4.0);
        assert(truncPow2(T(-0.24)) == -0.125);

        assert(truncPow2(T.infinity) == T.infinity);
        assert(truncPow2(T.init).isNaN);
    }
}

/**
Check whether a number is an integer power of two.

Note that only positive numbers can be integer powers of two. This
function always return `false` if `x` is negative or zero.

Params:
    x = the number to test

Returns:
    `true` if `x` is an integer power of two.
*/
bool isPowerOf2(X)(const X x) pure @safe nothrow @nogc
if (isNumeric!X)
{
    static if (isFloatingPoint!X)
    {
        int exp;
        const X sig = frexp(x, exp);

        return (exp != int.min) && (sig is cast(X) 0.5L);
    }
    else
    {
        static if (isSigned!X)
        {
            auto y = cast(typeof(x + 0))x;
            return y > 0 && !(y & (y - 1));
        }
        else
        {
            auto y = cast(typeof(x + 0u))x;
            return (y & -y) > (y - 1);
        }
    }
}
///
@safe unittest
{
    assert( isPowerOf2(1.0L));
    assert( isPowerOf2(2.0L));
    assert( isPowerOf2(0.5L));
    assert( isPowerOf2(pow(2.0L, 96)));
    assert( isPowerOf2(pow(2.0L, -77)));

    assert(!isPowerOf2(-2.0L));
    assert(!isPowerOf2(-0.5L));
    assert(!isPowerOf2(0.0L));
    assert(!isPowerOf2(4.315));
    assert(!isPowerOf2(1.0L / 3.0L));

    assert(!isPowerOf2(real.nan));
    assert(!isPowerOf2(real.infinity));
}
///
@safe unittest
{
    assert( isPowerOf2(1));
    assert( isPowerOf2(2));
    assert( isPowerOf2(1uL << 63));

    assert(!isPowerOf2(-4));
    assert(!isPowerOf2(0));
    assert(!isPowerOf2(1337u));
}

@safe unittest
{
    import std.meta : AliasSeq;

    enum smallP2 = pow(2.0L, -62);
    enum bigP2 = pow(2.0L, 50);
    enum smallP7 = pow(7.0L, -35);
    enum bigP7 = pow(7.0L, 30);

    static foreach (X; AliasSeq!(float, double, real))
    {{
        immutable min_sub = X.min_normal * X.epsilon;

        foreach (x; [smallP2, min_sub, X.min_normal, .25L, 0.5L, 1.0L,
                              2.0L, 8.0L, pow(2.0L, X.max_exp - 1), bigP2])
        {
            assert( isPowerOf2(cast(X) x));
            assert(!isPowerOf2(cast(X)-x));
        }

        foreach (x; [0.0L, 3 * min_sub, smallP7, 0.1L, 1337.0L, bigP7, X.max, real.nan, real.infinity])
        {
            assert(!isPowerOf2(cast(X) x));
            assert(!isPowerOf2(cast(X)-x));
        }
    }}

    static foreach (X; AliasSeq!(byte, ubyte, short, ushort, int, uint, long, ulong))
    {{
        foreach (x; [1, 2, 4, 8, (X.max >>> 1) + 1])
        {
            assert( isPowerOf2(cast(X) x));
            static if (isSigned!X)
                assert(!isPowerOf2(cast(X)-x));
        }

        foreach (x; [0, 3, 5, 13, 77, X.min, X.max])
            assert(!isPowerOf2(cast(X) x));
    }}

    // CTFE
    static foreach (X; AliasSeq!(float, double, real))
    {{
        enum min_sub = X.min_normal * X.epsilon;

        static foreach (x; [smallP2, min_sub, X.min_normal, .25L, 0.5L, 1.0L,
                              2.0L, 8.0L, pow(2.0L, X.max_exp - 1), bigP2])
        {
            static assert( isPowerOf2(cast(X) x));
            static assert(!isPowerOf2(cast(X)-x));
        }

        static foreach (x; [0.0L, 3 * min_sub, smallP7, 0.1L, 1337.0L, bigP7, X.max, real.nan, real.infinity])
        {
            static assert(!isPowerOf2(cast(X) x));
            static assert(!isPowerOf2(cast(X)-x));
        }
    }}

    static foreach (X; AliasSeq!(byte, ubyte, short, ushort, int, uint, long, ulong))
    {{
        static foreach (x; [1, 2, 4, 8, (X.max >>> 1) + 1])
        {
            static assert( isPowerOf2(cast(X) x));
            static if (isSigned!X)
                static assert(!isPowerOf2(cast(X)-x));
        }

        static foreach (x; [0, 3, 5, 13, 77, X.min, X.max])
            static assert(!isPowerOf2(cast(X) x));
    }}
}

package: // Not public yet
/* Return the value that lies halfway between x and y on the IEEE number line.
 *
 * Formally, the result is the arithmetic mean of the binary significands of x
 * and y, multiplied by the geometric mean of the binary exponents of x and y.
 * x and y must have the same sign, and must not be NaN.
 * Note: this function is useful for ensuring O(log n) behaviour in algorithms
 * involving a 'binary chop'.
 *
 * Special cases:
 * If x and y are within a factor of 2, (ie, feqrel(x, y) > 0), the return value
 * is the arithmetic mean (x + y) / 2.
 * If x and y are even powers of 2, the return value is the geometric mean,
 *   ieeeMean(x, y) = sqrt(x * y).
 *
 */
T ieeeMean(T)(const T x, const T y)  @trusted pure nothrow @nogc
in
{
    // both x and y must have the same sign, and must not be NaN.
    assert(signbit(x) == signbit(y));
    assert(x == x && y == y);
}
do
{
    // Runtime behaviour for contract violation:
    // If signs are opposite, or one is a NaN, return 0.
    if (!((x >= 0 && y >= 0) || (x <= 0 && y <= 0))) return 0.0;

    // The implementation is simple: cast x and y to integers,
    // average them (avoiding overflow), and cast the result back to a floating-point number.

    alias F = floatTraits!(T);
    T u;
    static if (F.realFormat == RealFormat.ieeeExtended ||
               F.realFormat == RealFormat.ieeeExtended53)
    {
        // There's slight additional complexity because they are actually
        // 79-bit reals...
        ushort *ue = cast(ushort *)&u;
        ulong *ul = cast(ulong *)&u;
        ushort *xe = cast(ushort *)&x;
        ulong *xl = cast(ulong *)&x;
        ushort *ye = cast(ushort *)&y;
        ulong *yl = cast(ulong *)&y;

        // Ignore the useless implicit bit. (Bonus: this prevents overflows)
        ulong m = ((*xl) & 0x7FFF_FFFF_FFFF_FFFFL) + ((*yl) & 0x7FFF_FFFF_FFFF_FFFFL);

        // @@@ BUG? @@@
        // Cast shouldn't be here
        ushort e = cast(ushort) ((xe[F.EXPPOS_SHORT] & F.EXPMASK)
                                 + (ye[F.EXPPOS_SHORT] & F.EXPMASK));
        if (m & 0x8000_0000_0000_0000L)
        {
            ++e;
            m &= 0x7FFF_FFFF_FFFF_FFFFL;
        }
        // Now do a multi-byte right shift
        const uint c = e & 1; // carry
        e >>= 1;
        m >>>= 1;
        if (c)
            m |= 0x4000_0000_0000_0000L; // shift carry into significand
        if (e)
            *ul = m | 0x8000_0000_0000_0000L; // set implicit bit...
        else
            *ul = m; // ... unless exponent is 0 (subnormal or zero).

        ue[4]= e | (xe[F.EXPPOS_SHORT]& 0x8000); // restore sign bit
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        // This would be trivial if 'ucent' were implemented...
        ulong *ul = cast(ulong *)&u;
        ulong *xl = cast(ulong *)&x;
        ulong *yl = cast(ulong *)&y;

        // Multi-byte add, then multi-byte right shift.
        import core.checkedint : addu;
        bool carry;
        ulong ml = addu(xl[MANTISSA_LSB], yl[MANTISSA_LSB], carry);

        ulong mh = carry + (xl[MANTISSA_MSB] & 0x7FFF_FFFF_FFFF_FFFFL) +
            (yl[MANTISSA_MSB] & 0x7FFF_FFFF_FFFF_FFFFL);

        ul[MANTISSA_MSB] = (mh >>> 1) | (xl[MANTISSA_MSB] & 0x8000_0000_0000_0000);
        ul[MANTISSA_LSB] = (ml >>> 1) | (mh & 1) << 63;
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        ulong *ul = cast(ulong *)&u;
        ulong *xl = cast(ulong *)&x;
        ulong *yl = cast(ulong *)&y;
        ulong m = (((*xl) & 0x7FFF_FFFF_FFFF_FFFFL)
                   + ((*yl) & 0x7FFF_FFFF_FFFF_FFFFL)) >>> 1;
        m |= ((*xl) & 0x8000_0000_0000_0000L);
        *ul = m;
    }
    else static if (F.realFormat == RealFormat.ieeeSingle)
    {
        uint *ul = cast(uint *)&u;
        uint *xl = cast(uint *)&x;
        uint *yl = cast(uint *)&y;
        uint m = (((*xl) & 0x7FFF_FFFF) + ((*yl) & 0x7FFF_FFFF)) >>> 1;
        m |= ((*xl) & 0x8000_0000);
        *ul = m;
    }
    else
    {
        assert(0, "Not implemented");
    }
    return u;
}

@safe pure nothrow @nogc unittest
{
    assert(ieeeMean(-0.0,-1e-20)<0);
    assert(ieeeMean(0.0,1e-20)>0);

    assert(ieeeMean(1.0L,4.0L)==2L);
    assert(ieeeMean(2.0*1.013,8.0*1.013)==4*1.013);
    assert(ieeeMean(-1.0L,-4.0L)==-2L);
    assert(ieeeMean(-1.0,-4.0)==-2);
    assert(ieeeMean(-1.0f,-4.0f)==-2f);
    assert(ieeeMean(-1.0,-2.0)==-1.5);
    assert(ieeeMean(-1*(1+8*real.epsilon),-2*(1+8*real.epsilon))
                 ==-1.5*(1+5*real.epsilon));
    assert(ieeeMean(0x1p60,0x1p-10)==0x1p25);

    static if (floatTraits!(real).realFormat == RealFormat.ieeeExtended)
    {
      assert(ieeeMean(1.0L,real.infinity)==0x1p8192L);
      assert(ieeeMean(0.0L,real.infinity)==1.5);
    }
    assert(ieeeMean(0.5*real.min_normal*(1-4*real.epsilon),0.5*real.min_normal)
           == 0.5*real.min_normal*(1-2*real.epsilon));
}


// The following IEEE 'real' formats are currently supported.
version (LittleEndian)
{
    static assert(real.mant_dig == 53 || real.mant_dig == 64
               || real.mant_dig == 113,
      "Only 64-bit, 80-bit, and 128-bit reals"~
      " are supported for LittleEndian CPUs");
}
else
{
    static assert(real.mant_dig == 53 || real.mant_dig == 113,
    "Only 64-bit and 128-bit reals are supported for BigEndian CPUs.");
}

// Underlying format exposed through floatTraits
enum RealFormat
{
    ieeeHalf,
    ieeeSingle,
    ieeeDouble,
    ieeeExtended,   // x87 80-bit real
    ieeeExtended53, // x87 real rounded to precision of double.
    ibmExtended,    // IBM 128-bit extended
    ieeeQuadruple,
}

// Constants used for extracting the components of the representation.
// They supplement the built-in floating point properties.
template floatTraits(T)
{
    // EXPMASK is a ushort mask to select the exponent portion (without sign)
    // EXPSHIFT is the number of bits the exponent is left-shifted by in its ushort
    // EXPBIAS is the exponent bias - 1 (exp == EXPBIAS yields ×2^-1).
    // EXPPOS_SHORT is the index of the exponent when represented as a ushort array.
    // SIGNPOS_BYTE is the index of the sign when represented as a ubyte array.
    // RECIP_EPSILON is the value such that (smallest_subnormal) * RECIP_EPSILON == T.min_normal
    enum Unqual!T RECIP_EPSILON = (1/T.epsilon);
    static if (T.mant_dig == 24)
    {
        // Single precision float
        enum ushort EXPMASK = 0x7F80;
        enum ushort EXPSHIFT = 7;
        enum ushort EXPBIAS = 0x3F00;
        enum uint EXPMASK_INT = 0x7F80_0000;
        enum uint MANTISSAMASK_INT = 0x007F_FFFF;
        enum realFormat = RealFormat.ieeeSingle;
        version (LittleEndian)
        {
            enum EXPPOS_SHORT = 1;
            enum SIGNPOS_BYTE = 3;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
            enum SIGNPOS_BYTE = 0;
        }
    }
    else static if (T.mant_dig == 53)
    {
        static if (T.sizeof == 8)
        {
            // Double precision float, or real == double
            enum ushort EXPMASK = 0x7FF0;
            enum ushort EXPSHIFT = 4;
            enum ushort EXPBIAS = 0x3FE0;
            enum uint EXPMASK_INT = 0x7FF0_0000;
            enum uint MANTISSAMASK_INT = 0x000F_FFFF; // for the MSB only
            enum realFormat = RealFormat.ieeeDouble;
            version (LittleEndian)
            {
                enum EXPPOS_SHORT = 3;
                enum SIGNPOS_BYTE = 7;
            }
            else
            {
                enum EXPPOS_SHORT = 0;
                enum SIGNPOS_BYTE = 0;
            }
        }
        else static if (T.sizeof == 12)
        {
            // Intel extended real80 rounded to double
            enum ushort EXPMASK = 0x7FFF;
            enum ushort EXPSHIFT = 0;
            enum ushort EXPBIAS = 0x3FFE;
            enum realFormat = RealFormat.ieeeExtended53;
            version (LittleEndian)
            {
                enum EXPPOS_SHORT = 4;
                enum SIGNPOS_BYTE = 9;
            }
            else
            {
                enum EXPPOS_SHORT = 0;
                enum SIGNPOS_BYTE = 0;
            }
        }
        else
            static assert(false, "No traits support for " ~ T.stringof);
    }
    else static if (T.mant_dig == 64)
    {
        // Intel extended real80
        enum ushort EXPMASK = 0x7FFF;
        enum ushort EXPSHIFT = 0;
        enum ushort EXPBIAS = 0x3FFE;
        enum realFormat = RealFormat.ieeeExtended;
        version (LittleEndian)
        {
            enum EXPPOS_SHORT = 4;
            enum SIGNPOS_BYTE = 9;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
            enum SIGNPOS_BYTE = 0;
        }
    }
    else static if (T.mant_dig == 113)
    {
        // Quadruple precision float
        enum ushort EXPMASK = 0x7FFF;
        enum ushort EXPSHIFT = 0;
        enum ushort EXPBIAS = 0x3FFE;
        enum realFormat = RealFormat.ieeeQuadruple;
        version (LittleEndian)
        {
            enum EXPPOS_SHORT = 7;
            enum SIGNPOS_BYTE = 15;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
            enum SIGNPOS_BYTE = 0;
        }
    }
    else static if (T.mant_dig == 106)
    {
        // IBM Extended doubledouble
        enum ushort EXPMASK = 0x7FF0;
        enum ushort EXPSHIFT = 4;
        enum realFormat = RealFormat.ibmExtended;

        // For IBM doubledouble the larger magnitude double comes first.
        // It's really a double[2] and arrays don't index differently
        // between little and big-endian targets.
        enum DOUBLEPAIR_MSB = 0;
        enum DOUBLEPAIR_LSB = 1;

        // The exponent/sign byte is for most significant part.
        version (LittleEndian)
        {
            enum EXPPOS_SHORT = 3;
            enum SIGNPOS_BYTE = 7;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
            enum SIGNPOS_BYTE = 0;
        }
    }
    else
        static assert(false, "No traits support for " ~ T.stringof);
}

// These apply to all floating-point types
version (LittleEndian)
{
    enum MANTISSA_LSB = 0;
    enum MANTISSA_MSB = 1;
}
else
{
    enum MANTISSA_LSB = 1;
    enum MANTISSA_MSB = 0;
}

// Common code for math implementations.

// Helper for floor/ceil
T floorImpl(T)(const T x) @trusted pure nothrow @nogc
{
    alias F = floatTraits!(T);
    // Take care not to trigger library calls from the compiler,
    // while ensuring that we don't get defeated by some optimizers.
    union floatBits
    {
        T rv;
        ushort[T.sizeof/2] vu;

        // Other kinds of extractors for real formats.
        static if (F.realFormat == RealFormat.ieeeSingle)
            int vi;
    }
    floatBits y = void;
    y.rv = x;

    // Find the exponent (power of 2)
    // Do this by shifting the raw value so that the exponent lies in the low bits,
    // then mask out the sign bit, and subtract the bias.
    static if (F.realFormat == RealFormat.ieeeSingle)
    {
        int exp = ((y.vi >> (T.mant_dig - 1)) & 0xff) - 0x7f;
    }
    else static if (F.realFormat == RealFormat.ieeeDouble)
    {
        int exp = ((y.vu[F.EXPPOS_SHORT] >> 4) & 0x7ff) - 0x3ff;

        version (LittleEndian)
            int pos = 0;
        else
            int pos = 3;
    }
    else static if (F.realFormat == RealFormat.ieeeExtended ||
                    F.realFormat == RealFormat.ieeeExtended53)
    {
        int exp = (y.vu[F.EXPPOS_SHORT] & 0x7fff) - 0x3fff;

        version (LittleEndian)
            int pos = 0;
        else
            int pos = 4;
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        int exp = (y.vu[F.EXPPOS_SHORT] & 0x7fff) - 0x3fff;

        version (LittleEndian)
            int pos = 0;
        else
            int pos = 7;
    }
    else
        static assert(false, "Not implemented for this architecture");

    if (exp < 0)
    {
        if (x < 0.0)
            return -1.0;
        else
            return 0.0;
    }

    static if (F.realFormat == RealFormat.ieeeSingle)
    {
        if (exp < (T.mant_dig - 1))
        {
            // Clear all bits representing the fraction part.
            const uint fraction_mask = F.MANTISSAMASK_INT >> exp;

            if ((y.vi & fraction_mask) != 0)
            {
                // If 'x' is negative, then first substract 1.0 from the value.
                if (y.vi < 0)
                    y.vi += 0x00800000 >> exp;
                y.vi &= ~fraction_mask;
            }
        }
    }
    else
    {
        static if (F.realFormat == RealFormat.ieeeExtended53)
            exp = (T.mant_dig + 11 - 1) - exp; // mant_dig is really 64
        else
            exp = (T.mant_dig - 1) - exp;

        // Zero 16 bits at a time.
        while (exp >= 16)
        {
            version (LittleEndian)
                y.vu[pos++] = 0;
            else
                y.vu[pos--] = 0;
            exp -= 16;
        }

        // Clear the remaining bits.
        if (exp > 0)
            y.vu[pos] &= 0xffff ^ ((1 << exp) - 1);

        if ((x < 0.0) && (x != y.rv))
            y.rv -= 1.0;
    }

    return y.rv;
}
