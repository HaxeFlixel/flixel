#ifndef INCLUDED_openfl_display_StageAlign
#define INCLUDED_openfl_display_StageAlign

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display,StageAlign)
namespace openfl{
namespace display{


class StageAlign_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef StageAlign_obj OBJ_;

	public:
		StageAlign_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display.StageAlign"); }
		::String __ToString() const { return HX_CSTRING("StageAlign.") + tag; }

		static ::openfl::display::StageAlign BOTTOM;
		static inline ::openfl::display::StageAlign BOTTOM_dyn() { return BOTTOM; }
		static ::openfl::display::StageAlign BOTTOM_LEFT;
		static inline ::openfl::display::StageAlign BOTTOM_LEFT_dyn() { return BOTTOM_LEFT; }
		static ::openfl::display::StageAlign BOTTOM_RIGHT;
		static inline ::openfl::display::StageAlign BOTTOM_RIGHT_dyn() { return BOTTOM_RIGHT; }
		static ::openfl::display::StageAlign LEFT;
		static inline ::openfl::display::StageAlign LEFT_dyn() { return LEFT; }
		static ::openfl::display::StageAlign RIGHT;
		static inline ::openfl::display::StageAlign RIGHT_dyn() { return RIGHT; }
		static ::openfl::display::StageAlign TOP;
		static inline ::openfl::display::StageAlign TOP_dyn() { return TOP; }
		static ::openfl::display::StageAlign TOP_LEFT;
		static inline ::openfl::display::StageAlign TOP_LEFT_dyn() { return TOP_LEFT; }
		static ::openfl::display::StageAlign TOP_RIGHT;
		static inline ::openfl::display::StageAlign TOP_RIGHT_dyn() { return TOP_RIGHT; }
};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_StageAlign */ 
