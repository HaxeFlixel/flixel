#ifndef INCLUDED_openfl_display3D_Context3DTextureFilter
#define INCLUDED_openfl_display3D_Context3DTextureFilter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display3D,Context3DTextureFilter)
namespace openfl{
namespace display3D{


class Context3DTextureFilter_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef Context3DTextureFilter_obj OBJ_;

	public:
		Context3DTextureFilter_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.display3D.Context3DTextureFilter"); }
		::String __ToString() const { return HX_CSTRING("Context3DTextureFilter.") + tag; }

		static ::openfl::display3D::Context3DTextureFilter ANISOTROPIC16X;
		static inline ::openfl::display3D::Context3DTextureFilter ANISOTROPIC16X_dyn() { return ANISOTROPIC16X; }
		static ::openfl::display3D::Context3DTextureFilter ANISOTROPIC2X;
		static inline ::openfl::display3D::Context3DTextureFilter ANISOTROPIC2X_dyn() { return ANISOTROPIC2X; }
		static ::openfl::display3D::Context3DTextureFilter ANISOTROPIC4X;
		static inline ::openfl::display3D::Context3DTextureFilter ANISOTROPIC4X_dyn() { return ANISOTROPIC4X; }
		static ::openfl::display3D::Context3DTextureFilter ANISOTROPIC8X;
		static inline ::openfl::display3D::Context3DTextureFilter ANISOTROPIC8X_dyn() { return ANISOTROPIC8X; }
		static ::openfl::display3D::Context3DTextureFilter LINEAR;
		static inline ::openfl::display3D::Context3DTextureFilter LINEAR_dyn() { return LINEAR; }
		static ::openfl::display3D::Context3DTextureFilter NEAREST;
		static inline ::openfl::display3D::Context3DTextureFilter NEAREST_dyn() { return NEAREST; }
};

} // end namespace openfl
} // end namespace display3D

#endif /* INCLUDED_openfl_display3D_Context3DTextureFilter */ 
