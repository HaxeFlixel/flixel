#ifndef INCLUDED_flixel_text_FlxTextFormat
#define INCLUDED_flixel_text_FlxTextFormat

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,text,FlxTextFormat)
HX_DECLARE_CLASS3(openfl,_v2,text,TextFormat)
namespace flixel{
namespace text{


class HXCPP_CLASS_ATTRIBUTES  FlxTextFormat_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxTextFormat_obj OBJ_;
		FlxTextFormat_obj();
		Void __construct(Dynamic FontColor,Dynamic Bold,Dynamic Italic,Dynamic BorderColor);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTextFormat_obj > __new(Dynamic FontColor,Dynamic Bold,Dynamic Italic,Dynamic BorderColor);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTextFormat_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTextFormat"); }

		int borderColor;
		::openfl::_v2::text::TextFormat format;
};

} // end namespace flixel
} // end namespace text

#endif /* INCLUDED_flixel_text_FlxTextFormat */ 
