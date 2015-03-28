#ifndef INCLUDED_flixel_input_gamepad_FlxGamepadButton
#define INCLUDED_flixel_input_gamepad_FlxGamepadButton

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/input/FlxInput.h>
HX_DECLARE_CLASS2(flixel,input,FlxInput)
HX_DECLARE_CLASS2(flixel,input,IFlxInput)
HX_DECLARE_CLASS3(flixel,input,gamepad,FlxGamepadButton)
namespace flixel{
namespace input{
namespace gamepad{


class HXCPP_CLASS_ATTRIBUTES  FlxGamepadButton_obj : public ::flixel::input::FlxInput_obj{
	public:
		typedef ::flixel::input::FlxInput_obj super;
		typedef FlxGamepadButton_obj OBJ_;
		FlxGamepadButton_obj();
		Void __construct(int ID);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxGamepadButton_obj > __new(int ID);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxGamepadButton_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxGamepadButton"); }

};

} // end namespace flixel
} // end namespace input
} // end namespace gamepad

#endif /* INCLUDED_flixel_input_gamepad_FlxGamepadButton */ 
