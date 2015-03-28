#ifndef INCLUDED_flixel_text__FlxText_FlxTextAlign_Impl_
#define INCLUDED_flixel_text__FlxText_FlxTextAlign_Impl_

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,text,_FlxText,FlxTextAlign_Impl_)
namespace flixel{
namespace text{
namespace _FlxText{


class HXCPP_CLASS_ATTRIBUTES  FlxTextAlign_Impl__obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxTextAlign_Impl__obj OBJ_;
		FlxTextAlign_Impl__obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTextAlign_Impl__obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTextAlign_Impl__obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxTextAlign_Impl_"); }

		static ::String LEFT;
		static ::String CENTER;
		static ::String RIGHT;
		static ::String JUSTIFY;
};

} // end namespace flixel
} // end namespace text
} // end namespace _FlxText

#endif /* INCLUDED_flixel_text__FlxText_FlxTextAlign_Impl_ */ 
