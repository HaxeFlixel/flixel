#ifndef INCLUDED_flixel_input_gamepad_FlxGamepadManager
#define INCLUDED_flixel_input_gamepad_FlxGamepadManager

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/input/IFlxInputManager.h>
HX_DECLARE_CLASS2(flixel,input,IFlxInputManager)
HX_DECLARE_CLASS3(flixel,input,gamepad,FlxGamepad)
HX_DECLARE_CLASS3(flixel,input,gamepad,FlxGamepadManager)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS2(openfl,events,JoystickEvent)
namespace flixel{
namespace input{
namespace gamepad{


class HXCPP_CLASS_ATTRIBUTES  FlxGamepadManager_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxGamepadManager_obj OBJ_;
		FlxGamepadManager_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxGamepadManager_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxGamepadManager_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxGamepadManager_obj >(this); }
		inline operator ::flixel::input::IFlxInputManager_obj *()
			{ return new ::flixel::input::IFlxInputManager_delegate_< FlxGamepadManager_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxGamepadManager"); }

		::flixel::input::gamepad::FlxGamepad firstActive;
		::flixel::input::gamepad::FlxGamepad lastActive;
		int numActiveGamepads;
		Float globalDeadZone;
		Array< ::Dynamic > _gamepads;
		Array< ::Dynamic > _activeGamepads;
		virtual ::flixel::input::gamepad::FlxGamepad getByID( int GamepadID);
		Dynamic getByID_dyn();

		virtual Void removeByID( int GamepadID);
		Dynamic removeByID_dyn();

		virtual ::flixel::input::gamepad::FlxGamepad createByID( int GamepadID);
		Dynamic createByID_dyn();

		virtual Array< int > getActiveGamepadIDs( Array< int > IDsArray);
		Dynamic getActiveGamepadIDs_dyn();

		virtual Array< ::Dynamic > getActiveGamepads( Array< ::Dynamic > GamepadArray);
		Dynamic getActiveGamepads_dyn();

		virtual int getFirstActiveGamepadID( );
		Dynamic getFirstActiveGamepadID_dyn();

		virtual ::flixel::input::gamepad::FlxGamepad getFirstActiveGamepad( );
		Dynamic getFirstActiveGamepad_dyn();

		virtual bool anyButton( hx::Null< int >  state);
		Dynamic anyButton_dyn();

		virtual bool anyInput( );
		Dynamic anyInput_dyn();

		virtual bool anyPressed( int ButtonID);
		Dynamic anyPressed_dyn();

		virtual bool anyJustPressed( int ButtonID);
		Dynamic anyJustPressed_dyn();

		virtual bool anyJustReleased( int ButtonID);
		Dynamic anyJustReleased_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void reset( );
		Dynamic reset_dyn();

		virtual Void handleButtonDown( ::openfl::events::JoystickEvent FlashEvent);
		Dynamic handleButtonDown_dyn();

		virtual Void handleButtonUp( ::openfl::events::JoystickEvent FlashEvent);
		Dynamic handleButtonUp_dyn();

		virtual Void handleAxisMove( ::openfl::events::JoystickEvent FlashEvent);
		Dynamic handleAxisMove_dyn();

		virtual Void handleBallMove( ::openfl::events::JoystickEvent FlashEvent);
		Dynamic handleBallMove_dyn();

		virtual Void handleHatMove( ::openfl::events::JoystickEvent FlashEvent);
		Dynamic handleHatMove_dyn();

		virtual Void handleDeviceAdded( ::openfl::events::JoystickEvent event);
		Dynamic handleDeviceAdded_dyn();

		virtual Void handleDeviceRemoved( ::openfl::events::JoystickEvent event);
		Dynamic handleDeviceRemoved_dyn();

		virtual Void update( );
		Dynamic update_dyn();

		virtual Void onFocus( );
		Dynamic onFocus_dyn();

		virtual Void onFocusLost( );
		Dynamic onFocusLost_dyn();

		virtual int get_numActiveGamepads( );
		Dynamic get_numActiveGamepads_dyn();

		virtual Float set_globalDeadZone( Float DeadZone);
		Dynamic set_globalDeadZone_dyn();

};

} // end namespace flixel
} // end namespace input
} // end namespace gamepad

#endif /* INCLUDED_flixel_input_gamepad_FlxGamepadManager */ 
