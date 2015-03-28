#ifndef INCLUDED_openfl_display3D_Context3DWrapMode
#define INCLUDED_openfl_display3D_Context3DWrapMode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display3D,Context3DWrapMode)
namespace openfl{
namespace display3D{


class Context3DWrapMode_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef Context3DWrapMode_obj OBJ_;

	public:
		Context3DWrapMode_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display3D.Context3DWrapMode"); }
		::String __ToString() const { return HX_CSTRING("Context3DWrapMode.") + tag; }

		static ::openfl::display3D::Context3DWrapMode CLAMP;
		static inline ::openfl::display3D::Context3DWrapMode CLAMP_dyn() { return CLAMP; }
		static ::openfl::display3D::Context3DWrapMode REPEAT;
		static inline ::openfl::display3D::Context3DWrapMode REPEAT_dyn() { return REPEAT; }
};

} // end namespace openfl
} // end namespace display3D

#endif /* INCLUDED_openfl_display3D_Context3DWrapMode */ 
