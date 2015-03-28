#ifndef INCLUDED_flixel_FlxCameraShakeDirection
#define INCLUDED_flixel_FlxCameraShakeDirection

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxCameraShakeDirection)
namespace flixel{


class FlxCameraShakeDirection_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxCameraShakeDirection_obj OBJ_;

	public:
		FlxCameraShakeDirection_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.FlxCameraShakeDirection"); }
		::String __ToString() const { return HX_CSTRING("FlxCameraShakeDirection.") + tag; }

		static ::flixel::FlxCameraShakeDirection BOTH_AXES;
		static inline ::flixel::FlxCameraShakeDirection BOTH_AXES_dyn() { return BOTH_AXES; }
		static ::flixel::FlxCameraShakeDirection X_AXIS;
		static inline ::flixel::FlxCameraShakeDirection X_AXIS_dyn() { return X_AXIS; }
		static ::flixel::FlxCameraShakeDirection Y_AXIS;
		static inline ::flixel::FlxCameraShakeDirection Y_AXIS_dyn() { return Y_AXIS; }
};

} // end namespace flixel

#endif /* INCLUDED_flixel_FlxCameraShakeDirection */ 
