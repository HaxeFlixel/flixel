#ifndef INCLUDED_openfl__v2_display_TriangleCulling
#define INCLUDED_openfl__v2_display_TriangleCulling

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,TriangleCulling)
namespace openfl{
namespace _v2{
namespace display{


class TriangleCulling_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef TriangleCulling_obj OBJ_;

	public:
		TriangleCulling_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.display.TriangleCulling"); }
		::String __ToString() const { return HX_CSTRING("TriangleCulling.") + tag; }

		static ::openfl::_v2::display::TriangleCulling NEGATIVE;
		static inline ::openfl::_v2::display::TriangleCulling NEGATIVE_dyn() { return NEGATIVE; }
		static ::openfl::_v2::display::TriangleCulling NONE;
		static inline ::openfl::_v2::display::TriangleCulling NONE_dyn() { return NONE; }
		static ::openfl::_v2::display::TriangleCulling POSITIVE;
		static inline ::openfl::_v2::display::TriangleCulling POSITIVE_dyn() { return POSITIVE; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_TriangleCulling */ 
