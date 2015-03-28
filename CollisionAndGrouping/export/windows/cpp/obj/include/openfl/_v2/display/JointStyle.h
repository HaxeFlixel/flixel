#ifndef INCLUDED_openfl__v2_display_JointStyle
#define INCLUDED_openfl__v2_display_JointStyle

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,JointStyle)
namespace openfl{
namespace _v2{
namespace display{


class JointStyle_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef JointStyle_obj OBJ_;

	public:
		JointStyle_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.display.JointStyle"); }
		::String __ToString() const { return HX_CSTRING("JointStyle.") + tag; }

		static ::openfl::_v2::display::JointStyle BEVEL;
		static inline ::openfl::_v2::display::JointStyle BEVEL_dyn() { return BEVEL; }
		static ::openfl::_v2::display::JointStyle MITER;
		static inline ::openfl::_v2::display::JointStyle MITER_dyn() { return MITER; }
		static ::openfl::_v2::display::JointStyle ROUND;
		static inline ::openfl::_v2::display::JointStyle ROUND_dyn() { return ROUND; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_JointStyle */ 
