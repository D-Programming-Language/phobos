module std.perpetual;

private import std.mmfile;
private import std.exception;
private import std.conv : to;
private import std.file : exists;
private import std.traits : hasIndirections;



/**
 * Persistently maps value type object to file
 */
struct Perpetual(T)
{
	private MmFile _heap;
	private enum _tag="Perpetual!("~T.stringof~")";

	static if(is(T == Element[],Element))
	{
	// dynamic array 
		private Element[] _value;
		enum bool dynamic=true;
		static assert(!hasIndirections!Element
		    , Element.stringof~" is reference type");
		@property Element[] Ref() { return _value; }
		string toString() { return to!string(_value); }

	}
	else
	{
	// value type
		private T *_value;
		enum bool dynamic=false;
		static assert(!hasIndirections!T
		    , T.stringof~" is reference type");
		@property ref T Ref() {	return *_value; }
		string toString() { return to!string(*_value); }
	}

/**
 * Get reference to wrapped object.
 */
	alias Ref this;


/**
 * Open file and assosiate object with it.
 * The file is extended if smaller than requred. Initialized
 *   with T.init if created or extended.
 */
	this(string path)
	{
		static if(dynamic)
		{
			enforce(exists(path)
			    , _tag~": dynamic array of zero length");
			size_t size=0;
		}
		else
		{
			size_t size=T.sizeof;
		}
		_heap=new MmFile(path, MmFile.Mode.readWrite, size, null, 0);
		static if(dynamic) // at least one element
			size=Element.sizeof;
		enforce(_heap.length >= size, _tag~": file is too small");

		static if(dynamic)
			_value=cast(Element[]) _heap[0.._heap.length];
		else
			_value=cast(T*) _heap[].ptr;
 	}

	this(size_t len, string path) {
		static if(dynamic) {
			size_t size=len*Element.sizeof;
		} else {
			size_t size=len*T.sizeof;
		}
		_heap=new MmFile(path, MmFile.Mode.readWrite, size, null, 0);
		enforce(_heap.length >= size, _tag~": file is too small");

		static if(dynamic) {
			_value=cast(Element[]) _heap[0.._heap.length];
		} else {
			_value=cast(T*) _heap[].ptr;
		}
 	}
}


///
unittest {
import std.stdio;
import std.conv;
import std.string;
import std.file : remove;
import std.file : deleteme;

struct A { int x; };
class B {};
enum Color { black, red, green, blue, white };

	string[] file;
	foreach(i; 1..8) file~=deleteme~to!string(i);
	scope(exit) foreach(f; file[]) remove(f);

	// create mapped variables
	{
		auto p0=Perpetual!int(file[0]);
		assert(p0 == 0);
		p0=7;

		auto p1=Perpetual!double(file[1]);
		p1=3.14159;

		// struct
		auto p2=Perpetual!A(file[2]);
		assert(p2.x == int.init);
		p2=A(22);		
		
		// static array of integers
		auto p3=Perpetual!(int[5])(file[3]);
		assert(p3[0] == 0);
		p3=[1,3,5,7,9];

		// enum
		auto p4=Perpetual!Color(file[4]);
		assert(p4 == Color.black);
		p4=Color.red;
		

		// character string, reinitialize if new file created
		auto p5=Perpetual!(char[32])(file[5]);
		p5="hello world";

		// double static array with initailization
		auto p8=Perpetual!(char[3][5])(file[6]);
		foreach(ref x; p8) x="..."; p8[0]="one"; p8[2]="two";

		//auto pX=Perpetual!(char*)("?");     //ERROR: "char* is reference type"
		//auto pX=Perpetual!B("?");           //ERROR: "B is reference type"
		//auto pX=Perpetual!(char*[])("?");   //ERROR: "char* is reference type"
		//auto pX=Perpetual!(char*[12])("?");  //ERROR: "char*[12] is reference type"
		//auto pX=Perpetual!(char[string])("?"); //ERROR: "char[string] is reference type"
		//auto pX=Perpetual!(char[][])("?");    //ERROR: "char[] is reference type"
		//auto pX=Perpetual!(char[][3])("?");   //ERROR: "char[][3] is reference type"
	}
	// destroy everything and unmap files
	
	
	// map again and check the values are preserved
	{
		auto p0=Perpetual!int(file[0]);
		assert(p0 == 7);

		auto p1=Perpetual!double(file[1]);
		assert(p1 == 3.14159);

		// struct
		auto p2=Perpetual!A(file[2]);
		assert(p2 == A(22));
		
		// map int[] as view only of array shorts
		auto p3=Perpetual!(immutable(short[]))(file[3]);
		// Attention: LSB only!
		assert(p3[0] == 1 && p3[2] == 3 && p3[4] == 5);
		//p3[1]=111; //ERROR: cannot modify immutable expression p3.Ref()[1]

		// enum
		auto p4=Perpetual!Color(file[4]);
		assert(p4 == Color.red);

		// view only variant of char[4]
		auto p5=Perpetual!string(4, file[5]);
		assert(p5 == "hell");
		//p5[0]='A'; //ERROR: cannot modify immutable expression p5.Ref()[0]
		//p5[]="1234"; //ERROR: slice p5.Ref()[] is not mutable


		// map of double array as plain array
		auto p6=Perpetual!(const(char[]))(file[6]);
		assert(p6[0..3] == "one");
		// map again as dynamic array
		auto p7=Perpetual!(char[3][])(file[6]);
		assert(p7.length == 5);
		assert(p7[2] == "two");
		//p7[0]="null"; //ERROR: Array lengths don't match for copy: 4 != 3
		p7[0]="nil";
	}

}


