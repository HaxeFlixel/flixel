#ifndef INCLUDED_openfl_display_InterpolationMethod
#define INCLUDED_openfl_display_InterpolationMethod

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display,InterpolationMethod)
namespace openfl{
namespace display{


class InterpolationMethod_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef InterpolationMethod_obj OBJ_;

	public:
		InterpolationMethod_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display.InterpolationMethod"); }
		::String __ToString() const { return HX_CSTRING("InterpolationMethod.") + tag; }

		static ::openfl::display::InterpolationMethod LINEAR_RGB;
		static inline ::openfl::display::InterpolationMethod LINEAR_RGB_dyn() { return LINEAR_RGB; }
		static ::openfl::display::InterpolationMethod RGB;
		static inline ::openfl::display::InterpolationMethod RGB_dyn() { return RGB; }
};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_InterpolationMethod */ 
