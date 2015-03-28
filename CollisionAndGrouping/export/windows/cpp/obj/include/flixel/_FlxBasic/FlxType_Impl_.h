#ifndef INCLUDED_flixel__FlxBasic_FlxType_Impl_
#define INCLUDED_flixel__FlxBasic_FlxType_Impl_

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,_FlxBasic,FlxType_Impl_)
namespace flixel{
namespace _FlxBasic{


class HXCPP_CLASS_ATTRIBUTES  FlxType_Impl__obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxType_Impl__obj OBJ_;
		FlxType_Impl__obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxType_Impl__obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxType_Impl__obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxType_Impl_"); }

		static int NONE;
		static int OBJECT;
		static int GROUP;
		static int TILEMAP;
		static int SPRITEGROUP;
};

} // end namespace flixel
} // end namespace _FlxBasic

#endif /* INCLUDED_flixel__FlxBasic_FlxType_Impl_ */ 
