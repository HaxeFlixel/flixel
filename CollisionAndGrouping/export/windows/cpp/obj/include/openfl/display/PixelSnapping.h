#ifndef INCLUDED_openfl_display_PixelSnapping
#define INCLUDED_openfl_display_PixelSnapping

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display,PixelSnapping)
namespace openfl{
namespace display{


class PixelSnapping_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef PixelSnapping_obj OBJ_;

	public:
		PixelSnapping_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display.PixelSnapping"); }
		::String __ToString() const { return HX_CSTRING("PixelSnapping.") + tag; }

		static ::openfl::display::PixelSnapping ALWAYS;
		static inline ::openfl::display::PixelSnapping ALWAYS_dyn() { return ALWAYS; }
		static ::openfl::display::PixelSnapping AUTO;
		static inline ::openfl::display::PixelSnapping AUTO_dyn() { return AUTO; }
		static ::openfl::display::PixelSnapping NEVER;
		static inline ::openfl::display::PixelSnapping NEVER_dyn() { return NEVER; }
};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_PixelSnapping */ 
