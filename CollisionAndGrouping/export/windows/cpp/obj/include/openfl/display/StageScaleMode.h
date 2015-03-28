#ifndef INCLUDED_openfl_display_StageScaleMode
#define INCLUDED_openfl_display_StageScaleMode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display,StageScaleMode)
namespace openfl{
namespace display{


class StageScaleMode_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef StageScaleMode_obj OBJ_;

	public:
		StageScaleMode_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display.StageScaleMode"); }
		::String __ToString() const { return HX_CSTRING("StageScaleMode.") + tag; }

		static ::openfl::display::StageScaleMode EXACT_FIT;
		static inline ::openfl::display::StageScaleMode EXACT_FIT_dyn() { return EXACT_FIT; }
		static ::openfl::display::StageScaleMode NO_BORDER;
		static inline ::openfl::display::StageScaleMode NO_BORDER_dyn() { return NO_BORDER; }
		static ::openfl::display::StageScaleMode NO_SCALE;
		static inline ::openfl::display::StageScaleMode NO_SCALE_dyn() { return NO_SCALE; }
		static ::openfl::display::StageScaleMode SHOW_ALL;
		static inline ::openfl::display::StageScaleMode SHOW_ALL_dyn() { return SHOW_ALL; }
};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_StageScaleMode */ 
