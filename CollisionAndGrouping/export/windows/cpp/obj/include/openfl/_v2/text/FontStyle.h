#ifndef INCLUDED_openfl__v2_text_FontStyle
#define INCLUDED_openfl__v2_text_FontStyle

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,text,FontStyle)
namespace openfl{
namespace _v2{
namespace text{


class FontStyle_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FontStyle_obj OBJ_;

	public:
		FontStyle_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.text.FontStyle"); }
		::String __ToString() const { return HX_CSTRING("FontStyle.") + tag; }

		static ::openfl::_v2::text::FontStyle BOLD;
		static inline ::openfl::_v2::text::FontStyle BOLD_dyn() { return BOLD; }
		static ::openfl::_v2::text::FontStyle BOLD_ITALIC;
		static inline ::openfl::_v2::text::FontStyle BOLD_ITALIC_dyn() { return BOLD_ITALIC; }
		static ::openfl::_v2::text::FontStyle ITALIC;
		static inline ::openfl::_v2::text::FontStyle ITALIC_dyn() { return ITALIC; }
		static ::openfl::_v2::text::FontStyle REGULAR;
		static inline ::openfl::_v2::text::FontStyle REGULAR_dyn() { return REGULAR; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace text

#endif /* INCLUDED_openfl__v2_text_FontStyle */ 
