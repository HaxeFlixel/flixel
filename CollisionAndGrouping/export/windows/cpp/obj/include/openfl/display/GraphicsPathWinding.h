#ifndef INCLUDED_openfl_display_GraphicsPathWinding
#define INCLUDED_openfl_display_GraphicsPathWinding

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display,GraphicsPathWinding)
namespace openfl{
namespace display{


class GraphicsPathWinding_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef GraphicsPathWinding_obj OBJ_;

	public:
		GraphicsPathWinding_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display.GraphicsPathWinding"); }
		::String __ToString() const { return HX_CSTRING("GraphicsPathWinding.") + tag; }

		static ::openfl::display::GraphicsPathWinding EVEN_ODD;
		static inline ::openfl::display::GraphicsPathWinding EVEN_ODD_dyn() { return EVEN_ODD; }
		static ::openfl::display::GraphicsPathWinding NON_ZERO;
		static inline ::openfl::display::GraphicsPathWinding NON_ZERO_dyn() { return NON_ZERO; }
};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_GraphicsPathWinding */ 
