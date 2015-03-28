#ifndef INCLUDED_flixel_text_FlxTextFormatMarkerPair
#define INCLUDED_flixel_text_FlxTextFormatMarkerPair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,text,FlxTextFormat)
HX_DECLARE_CLASS2(flixel,text,FlxTextFormatMarkerPair)
namespace flixel{
namespace text{


class HXCPP_CLASS_ATTRIBUTES  FlxTextFormatMarkerPair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxTextFormatMarkerPair_obj OBJ_;
		FlxTextFormatMarkerPair_obj();
		Void __construct(::flixel::text::FlxTextFormat format,::String marker);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTextFormatMarkerPair_obj > __new(::flixel::text::FlxTextFormat format,::String marker);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTextFormatMarkerPair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTextFormatMarkerPair"); }

		::flixel::text::FlxTextFormat format;
		::String marker;
};

} // end namespace flixel
} // end namespace text

#endif /* INCLUDED_flixel_text_FlxTextFormatMarkerPair */ 
