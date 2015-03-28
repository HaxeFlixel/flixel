#ifndef INCLUDED_openfl__v2_display_LineScaleMode
#define INCLUDED_openfl__v2_display_LineScaleMode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,LineScaleMode)
namespace openfl{
namespace _v2{
namespace display{


class LineScaleMode_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef LineScaleMode_obj OBJ_;

	public:
		LineScaleMode_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.display.LineScaleMode"); }
		::String __ToString() const { return HX_CSTRING("LineScaleMode.") + tag; }

		static ::openfl::_v2::display::LineScaleMode HORIZONTAL;
		static inline ::openfl::_v2::display::LineScaleMode HORIZONTAL_dyn() { return HORIZONTAL; }
		static ::openfl::_v2::display::LineScaleMode NONE;
		static inline ::openfl::_v2::display::LineScaleMode NONE_dyn() { return NONE; }
		static ::openfl::_v2::display::LineScaleMode NORMAL;
		static inline ::openfl::_v2::display::LineScaleMode NORMAL_dyn() { return NORMAL; }
		static ::openfl::_v2::display::LineScaleMode OPENGL;
		static inline ::openfl::_v2::display::LineScaleMode OPENGL_dyn() { return OPENGL; }
		static ::openfl::_v2::display::LineScaleMode VERTICAL;
		static inline ::openfl::_v2::display::LineScaleMode VERTICAL_dyn() { return VERTICAL; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_LineScaleMode */ 
