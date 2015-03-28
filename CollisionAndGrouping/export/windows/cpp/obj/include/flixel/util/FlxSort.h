#ifndef INCLUDED_flixel_util_FlxSort
#define INCLUDED_flixel_util_FlxSort

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,util,FlxSort)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  FlxSort_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxSort_obj OBJ_;
		FlxSort_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxSort_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxSort_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxSort"); }

		static int ASCENDING;
		static int DESCENDING;
		static int byY( int Order,::flixel::FlxObject Obj1,::flixel::FlxObject Obj2);
		static Dynamic byY_dyn();

		static int byValues( int Order,Float Value1,Float Value2);
		static Dynamic byValues_dyn();

};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_FlxSort */ 
