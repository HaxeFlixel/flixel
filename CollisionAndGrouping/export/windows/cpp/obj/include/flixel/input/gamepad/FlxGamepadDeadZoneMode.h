#ifndef INCLUDED_flixel_input_gamepad_FlxGamepadDeadZoneMode
#define INCLUDED_flixel_input_gamepad_FlxGamepadDeadZoneMode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,input,gamepad,FlxGamepadDeadZoneMode)
namespace flixel{
namespace input{
namespace gamepad{


class FlxGamepadDeadZoneMode_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxGamepadDeadZoneMode_obj OBJ_;

	public:
		FlxGamepadDeadZoneMode_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.input.gamepad.FlxGamepadDeadZoneMode"); }
		::String __ToString() const { return HX_CSTRING("FlxGamepadDeadZoneMode.") + tag; }

		static ::flixel::input::gamepad::FlxGamepadDeadZoneMode CIRCULAR;
		static inline ::flixel::input::gamepad::FlxGamepadDeadZoneMode CIRCULAR_dyn() { return CIRCULAR; }
		static ::flixel::input::gamepad::FlxGamepadDeadZoneMode INDEPENDANT_AXES;
		static inline ::flixel::input::gamepad::FlxGamepadDeadZoneMode INDEPENDANT_AXES_dyn() { return INDEPENDANT_AXES; }
};

} // end namespace flixel
} // end namespace input
} // end namespace gamepad

#endif /* INCLUDED_flixel_input_gamepad_FlxGamepadDeadZoneMode */ 
