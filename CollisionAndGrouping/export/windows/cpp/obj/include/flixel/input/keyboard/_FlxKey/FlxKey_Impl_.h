#ifndef INCLUDED_flixel_input_keyboard__FlxKey_FlxKey_Impl_
#define INCLUDED_flixel_input_keyboard__FlxKey_FlxKey_Impl_

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS4(flixel,input,keyboard,_FlxKey,FlxKey_Impl_)
HX_DECLARE_CLASS2(haxe,ds,IntMap)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
namespace flixel{
namespace input{
namespace keyboard{
namespace _FlxKey{


class HXCPP_CLASS_ATTRIBUTES  FlxKey_Impl__obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxKey_Impl__obj OBJ_;
		FlxKey_Impl__obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxKey_Impl__obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxKey_Impl__obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxKey_Impl_"); }

		static ::haxe::ds::StringMap fromStringMap;
		static ::haxe::ds::IntMap toStringMap;
		static int ANY;
		static int NONE;
		static int A;
		static int B;
		static int C;
		static int D;
		static int E;
		static int F;
		static int G;
		static int H;
		static int I;
		static int J;
		static int K;
		static int L;
		static int M;
		static int N;
		static int O;
		static int P;
		static int Q;
		static int R;
		static int S;
		static int T;
		static int U;
		static int V;
		static int W;
		static int X;
		static int Y;
		static int Z;
		static int ZERO;
		static int ONE;
		static int TWO;
		static int THREE;
		static int FOUR;
		static int FIVE;
		static int SIX;
		static int SEVEN;
		static int EIGHT;
		static int NINE;
		static int PAGEUP;
		static int PAGEDOWN;
		static int HOME;
		static int END;
		static int INSERT;
		static int ESCAPE;
		static int MINUS;
		static int PLUS;
		static int DELETE;
		static int BACKSPACE;
		static int LBRACKET;
		static int RBRACKET;
		static int BACKSLASH;
		static int CAPSLOCK;
		static int SEMICOLON;
		static int QUOTE;
		static int ENTER;
		static int SHIFT;
		static int COMMA;
		static int PERIOD;
		static int SLASH;
		static int GRAVEACCENT;
		static int CONTROL;
		static int ALT;
		static int SPACE;
		static int UP;
		static int DOWN;
		static int LEFT;
		static int RIGHT;
		static int TAB;
		static int PRINTSCREEN;
		static int F1;
		static int F2;
		static int F3;
		static int F4;
		static int F5;
		static int F6;
		static int F7;
		static int F8;
		static int F9;
		static int F10;
		static int F11;
		static int F12;
		static int NUMPADZERO;
		static int NUMPADONE;
		static int NUMPADTWO;
		static int NUMPADTHREE;
		static int NUMPADFOUR;
		static int NUMPADFIVE;
		static int NUMPADSIX;
		static int NUMPADSEVEN;
		static int NUMPADEIGHT;
		static int NUMPADNINE;
		static int NUMPADMINUS;
		static int NUMPADPLUS;
		static int NUMPADPERIOD;
		static int NUMPADMULTIPLY;
		static int fromString( ::String s);
		static Dynamic fromString_dyn();

		static ::String toString( int this1);
		static Dynamic toString_dyn();

};

} // end namespace flixel
} // end namespace input
} // end namespace keyboard
} // end namespace _FlxKey

#endif /* INCLUDED_flixel_input_keyboard__FlxKey_FlxKey_Impl_ */ 
