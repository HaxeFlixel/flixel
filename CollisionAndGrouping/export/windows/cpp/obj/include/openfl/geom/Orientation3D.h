#ifndef INCLUDED_openfl_geom_Orientation3D
#define INCLUDED_openfl_geom_Orientation3D

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,geom,Orientation3D)
namespace openfl{
namespace geom{


class Orientation3D_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef Orientation3D_obj OBJ_;

	public:
		Orientation3D_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.geom.Orientation3D"); }
		::String __ToString() const { return HX_CSTRING("Orientation3D.") + tag; }

		static ::openfl::geom::Orientation3D AXIS_ANGLE;
		static inline ::openfl::geom::Orientation3D AXIS_ANGLE_dyn() { return AXIS_ANGLE; }
		static ::openfl::geom::Orientation3D EULER_ANGLES;
		static inline ::openfl::geom::Orientation3D EULER_ANGLES_dyn() { return EULER_ANGLES; }
		static ::openfl::geom::Orientation3D QUATERNION;
		static inline ::openfl::geom::Orientation3D QUATERNION_dyn() { return QUATERNION; }
};

} // end namespace openfl
} // end namespace geom

#endif /* INCLUDED_openfl_geom_Orientation3D */ 
