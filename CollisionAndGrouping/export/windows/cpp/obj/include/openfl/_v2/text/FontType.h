#ifndef INCLUDED_openfl__v2_text_FontType
#define INCLUDED_openfl__v2_text_FontType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,text,FontType)
namespace openfl{
namespace _v2{
namespace text{


class FontType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FontType_obj OBJ_;

	public:
		FontType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.text.FontType"); }
		::String __ToString() const { return HX_CSTRING("FontType.") + tag; }

		static ::openfl::_v2::text::FontType DEVICE;
		static inline ::openfl::_v2::text::FontType DEVICE_dyn() { return DEVICE; }
		static ::openfl::_v2::text::FontType EMBEDDED;
		static inline ::openfl::_v2::text::FontType EMBEDDED_dyn() { return EMBEDDED; }
		static ::openfl::_v2::text::FontType EMBEDDED_CFF;
		static inline ::openfl::_v2::text::FontType EMBEDDED_CFF_dyn() { return EMBEDDED_CFF; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace text

#endif /* INCLUDED_openfl__v2_text_FontType */ 
