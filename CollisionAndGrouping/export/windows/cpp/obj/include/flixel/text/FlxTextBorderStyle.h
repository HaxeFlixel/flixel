#ifndef INCLUDED_flixel_text_FlxTextBorderStyle
#define INCLUDED_flixel_text_FlxTextBorderStyle

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,text,FlxTextBorderStyle)
namespace flixel{
namespace text{


class FlxTextBorderStyle_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxTextBorderStyle_obj OBJ_;

	public:
		FlxTextBorderStyle_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.text.FlxTextBorderStyle"); }
		::String __ToString() const { return HX_CSTRING("FlxTextBorderStyle.") + tag; }

		static ::flixel::text::FlxTextBorderStyle NONE;
		static inline ::flixel::text::FlxTextBorderStyle NONE_dyn() { return NONE; }
		static ::flixel::text::FlxTextBorderStyle OUTLINE;
		static inline ::flixel::text::FlxTextBorderStyle OUTLINE_dyn() { return OUTLINE; }
		static ::flixel::text::FlxTextBorderStyle OUTLINE_FAST;
		static inline ::flixel::text::FlxTextBorderStyle OUTLINE_FAST_dyn() { return OUTLINE_FAST; }
		static ::flixel::text::FlxTextBorderStyle SHADOW;
		static inline ::flixel::text::FlxTextBorderStyle SHADOW_dyn() { return SHADOW; }
};

} // end namespace flixel
} // end namespace text

#endif /* INCLUDED_flixel_text_FlxTextBorderStyle */ 
