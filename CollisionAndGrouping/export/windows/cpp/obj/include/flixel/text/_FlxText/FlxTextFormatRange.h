#ifndef INCLUDED_flixel_text__FlxText_FlxTextFormatRange
#define INCLUDED_flixel_text__FlxText_FlxTextFormatRange

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,text,FlxTextFormat)
HX_DECLARE_CLASS3(flixel,text,_FlxText,FlxTextFormatRange)
HX_DECLARE_CLASS3(flixel,util,helpers,FlxRange)
namespace flixel{
namespace text{
namespace _FlxText{


class HXCPP_CLASS_ATTRIBUTES  FlxTextFormatRange_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxTextFormatRange_obj OBJ_;
		FlxTextFormatRange_obj();
		Void __construct(::flixel::text::FlxTextFormat format,int start,int end);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTextFormatRange_obj > __new(::flixel::text::FlxTextFormat format,int start,int end);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTextFormatRange_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTextFormatRange"); }

		::flixel::util::helpers::FlxRange range;
		::flixel::text::FlxTextFormat format;
};

} // end namespace flixel
} // end namespace text
} // end namespace _FlxText

#endif /* INCLUDED_flixel_text__FlxText_FlxTextFormatRange */ 
