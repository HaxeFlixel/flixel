#ifndef INCLUDED_openfl__v2_display_SpreadMethod
#define INCLUDED_openfl__v2_display_SpreadMethod

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,SpreadMethod)
namespace openfl{
namespace _v2{
namespace display{


class SpreadMethod_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef SpreadMethod_obj OBJ_;

	public:
		SpreadMethod_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.display.SpreadMethod"); }
		::String __ToString() const { return HX_CSTRING("SpreadMethod.") + tag; }

		static ::openfl::_v2::display::SpreadMethod PAD;
		static inline ::openfl::_v2::display::SpreadMethod PAD_dyn() { return PAD; }
		static ::openfl::_v2::display::SpreadMethod REFLECT;
		static inline ::openfl::_v2::display::SpreadMethod REFLECT_dyn() { return REFLECT; }
		static ::openfl::_v2::display::SpreadMethod REPEAT;
		static inline ::openfl::_v2::display::SpreadMethod REPEAT_dyn() { return REPEAT; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_SpreadMethod */ 
