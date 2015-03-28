#ifndef INCLUDED_openfl_display_StageDisplayState
#define INCLUDED_openfl_display_StageDisplayState

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display,StageDisplayState)
namespace openfl{
namespace display{


class StageDisplayState_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef StageDisplayState_obj OBJ_;

	public:
		StageDisplayState_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display.StageDisplayState"); }
		::String __ToString() const { return HX_CSTRING("StageDisplayState.") + tag; }

		static ::openfl::display::StageDisplayState FULL_SCREEN;
		static inline ::openfl::display::StageDisplayState FULL_SCREEN_dyn() { return FULL_SCREEN; }
		static ::openfl::display::StageDisplayState FULL_SCREEN_INTERACTIVE;
		static inline ::openfl::display::StageDisplayState FULL_SCREEN_INTERACTIVE_dyn() { return FULL_SCREEN_INTERACTIVE; }
		static ::openfl::display::StageDisplayState NORMAL;
		static inline ::openfl::display::StageDisplayState NORMAL_dyn() { return NORMAL; }
};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_StageDisplayState */ 
