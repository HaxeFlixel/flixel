#ifndef INCLUDED_flixel_input_gamepad_FlxAxes
#define INCLUDED_flixel_input_gamepad_FlxAxes

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,input,gamepad,FlxAxes)
namespace flixel{
namespace input{
namespace gamepad{


class FlxAxes_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxAxes_obj OBJ_;

	public:
		FlxAxes_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.input.gamepad.FlxAxes"); }
		::String __ToString() const { return HX_CSTRING("FlxAxes.") + tag; }

		static ::flixel::input::gamepad::FlxAxes X;
		static inline ::flixel::input::gamepad::FlxAxes X_dyn() { return X; }
		static ::flixel::input::gamepad::FlxAxes Y;
		static inline ::flixel::input::gamepad::FlxAxes Y_dyn() { return Y; }
};

} // end namespace flixel
} // end namespace input
} // end namespace gamepad

#endif /* INCLUDED_flixel_input_gamepad_FlxAxes */ 
