#ifndef INCLUDED_openfl__v2_display_CapsStyle
#define INCLUDED_openfl__v2_display_CapsStyle

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,CapsStyle)
namespace openfl{
namespace _v2{
namespace display{


class CapsStyle_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef CapsStyle_obj OBJ_;

	public:
		CapsStyle_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.display.CapsStyle"); }
		::String __ToString() const { return HX_CSTRING("CapsStyle.") + tag; }

		static ::openfl::_v2::display::CapsStyle NONE;
		static inline ::openfl::_v2::display::CapsStyle NONE_dyn() { return NONE; }
		static ::openfl::_v2::display::CapsStyle ROUND;
		static inline ::openfl::_v2::display::CapsStyle ROUND_dyn() { return ROUND; }
		static ::openfl::_v2::display::CapsStyle SQUARE;
		static inline ::openfl::_v2::display::CapsStyle SQUARE_dyn() { return SQUARE; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_CapsStyle */ 
