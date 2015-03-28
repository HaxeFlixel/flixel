#ifndef INCLUDED_openfl__v2_display_StageQuality
#define INCLUDED_openfl__v2_display_StageQuality

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,StageQuality)
namespace openfl{
namespace _v2{
namespace display{


class StageQuality_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef StageQuality_obj OBJ_;

	public:
		StageQuality_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.display.StageQuality"); }
		::String __ToString() const { return HX_CSTRING("StageQuality.") + tag; }

		static ::openfl::_v2::display::StageQuality BEST;
		static inline ::openfl::_v2::display::StageQuality BEST_dyn() { return BEST; }
		static ::openfl::_v2::display::StageQuality HIGH;
		static inline ::openfl::_v2::display::StageQuality HIGH_dyn() { return HIGH; }
		static ::openfl::_v2::display::StageQuality LOW;
		static inline ::openfl::_v2::display::StageQuality LOW_dyn() { return LOW; }
		static ::openfl::_v2::display::StageQuality MEDIUM;
		static inline ::openfl::_v2::display::StageQuality MEDIUM_dyn() { return MEDIUM; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_StageQuality */ 
