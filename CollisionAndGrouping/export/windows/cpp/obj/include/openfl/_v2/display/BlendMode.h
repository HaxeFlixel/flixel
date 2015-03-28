#ifndef INCLUDED_openfl__v2_display_BlendMode
#define INCLUDED_openfl__v2_display_BlendMode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,BlendMode)
namespace openfl{
namespace _v2{
namespace display{


class BlendMode_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef BlendMode_obj OBJ_;

	public:
		BlendMode_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.display.BlendMode"); }
		::String __ToString() const { return HX_CSTRING("BlendMode.") + tag; }

		static ::openfl::_v2::display::BlendMode ADD;
		static inline ::openfl::_v2::display::BlendMode ADD_dyn() { return ADD; }
		static ::openfl::_v2::display::BlendMode ALPHA;
		static inline ::openfl::_v2::display::BlendMode ALPHA_dyn() { return ALPHA; }
		static ::openfl::_v2::display::BlendMode DARKEN;
		static inline ::openfl::_v2::display::BlendMode DARKEN_dyn() { return DARKEN; }
		static ::openfl::_v2::display::BlendMode DIFFERENCE;
		static inline ::openfl::_v2::display::BlendMode DIFFERENCE_dyn() { return DIFFERENCE; }
		static ::openfl::_v2::display::BlendMode ERASE;
		static inline ::openfl::_v2::display::BlendMode ERASE_dyn() { return ERASE; }
		static ::openfl::_v2::display::BlendMode HARDLIGHT;
		static inline ::openfl::_v2::display::BlendMode HARDLIGHT_dyn() { return HARDLIGHT; }
		static ::openfl::_v2::display::BlendMode INVERT;
		static inline ::openfl::_v2::display::BlendMode INVERT_dyn() { return INVERT; }
		static ::openfl::_v2::display::BlendMode LAYER;
		static inline ::openfl::_v2::display::BlendMode LAYER_dyn() { return LAYER; }
		static ::openfl::_v2::display::BlendMode LIGHTEN;
		static inline ::openfl::_v2::display::BlendMode LIGHTEN_dyn() { return LIGHTEN; }
		static ::openfl::_v2::display::BlendMode MULTIPLY;
		static inline ::openfl::_v2::display::BlendMode MULTIPLY_dyn() { return MULTIPLY; }
		static ::openfl::_v2::display::BlendMode NORMAL;
		static inline ::openfl::_v2::display::BlendMode NORMAL_dyn() { return NORMAL; }
		static ::openfl::_v2::display::BlendMode OVERLAY;
		static inline ::openfl::_v2::display::BlendMode OVERLAY_dyn() { return OVERLAY; }
		static ::openfl::_v2::display::BlendMode SCREEN;
		static inline ::openfl::_v2::display::BlendMode SCREEN_dyn() { return SCREEN; }
		static ::openfl::_v2::display::BlendMode SUBTRACT;
		static inline ::openfl::_v2::display::BlendMode SUBTRACT_dyn() { return SUBTRACT; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_BlendMode */ 
