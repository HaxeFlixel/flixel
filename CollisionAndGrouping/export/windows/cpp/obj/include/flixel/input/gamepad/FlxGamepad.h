#ifndef INCLUDED_flixel_input_gamepad_FlxGamepad
#define INCLUDED_flixel_input_gamepad_FlxGamepad

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS2(flixel,input,FlxInput)
HX_DECLARE_CLASS2(flixel,input,IFlxInput)
HX_DECLARE_CLASS3(flixel,input,gamepad,FlxAxes)
HX_DECLARE_CLASS3(flixel,input,gamepad,FlxGamepad)
HX_DECLARE_CLASS3(flixel,input,gamepad,FlxGamepadButton)
HX_DECLARE_CLASS3(flixel,input,gamepad,FlxGamepadDeadZoneMode)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS2(haxe,ds,BalancedTree)
HX_DECLARE_CLASS2(haxe,ds,EnumValueMap)
namespace flixel{
namespace input{
namespace gamepad{


class HXCPP_CLASS_ATTRIBUTES  FlxGamepad_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxGamepad_obj OBJ_;
		FlxGamepad_obj();
		Void __construct(int ID,hx::Null< Float >  __o_GlobalDeadZone);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxGamepad_obj > __new(int ID,hx::Null< Float >  __o_GlobalDeadZone);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxGamepad_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxGamepad_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxGamepad"); }

		int id;
		Array< ::Dynamic > buttons;
		bool connected;
		Float deadZone;
		::flixel::input::gamepad::FlxGamepadDeadZoneMode deadZoneMode;
		::flixel::math::FlxPoint hat;
		::flixel::math::FlxPoint ball;
		bool dpadUp;
		bool dpadDown;
		bool dpadLeft;
		bool dpadRight;
		Array< Float > axis;
		virtual ::flixel::input::gamepad::FlxGamepadButton getButton( int ButtonID);
		Dynamic getButton_dyn();

		virtual Void update( );
		Dynamic update_dyn();

		virtual Void reset( );
		Dynamic reset_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual bool checkStatus( int ButtonID,int Status);
		Dynamic checkStatus_dyn();

		virtual bool anyPressed( Array< int > ButtonIDArray);
		Dynamic anyPressed_dyn();

		virtual bool anyJustPressed( Array< int > ButtonIDArray);
		Dynamic anyJustPressed_dyn();

		virtual bool anyJustReleased( Array< int > ButtonIDArray);
		Dynamic anyJustReleased_dyn();

		virtual bool pressed( int ButtonID);
		Dynamic pressed_dyn();

		virtual bool justPressed( int ButtonID);
		Dynamic justPressed_dyn();

		virtual bool justReleased( int ButtonID);
		Dynamic justReleased_dyn();

		virtual int firstPressedButtonID( );
		Dynamic firstPressedButtonID_dyn();

		virtual int firstJustPressedButtonID( );
		Dynamic firstJustPressedButtonID_dyn();

		virtual int firstJustReleasedButtonID( );
		Dynamic firstJustReleasedButtonID_dyn();

		virtual Float getAxis( int AxisID);
		Dynamic getAxis_dyn();

		virtual Float getXAxis( ::haxe::ds::EnumValueMap Axes);
		Dynamic getXAxis_dyn();

		virtual Float getYAxis( ::haxe::ds::EnumValueMap Axes);
		Dynamic getYAxis_dyn();

		virtual bool anyButton( hx::Null< int >  state);
		Dynamic anyButton_dyn();

		virtual bool anyInput( );
		Dynamic anyInput_dyn();

		virtual Float getAxisValue( int AxisID);
		Dynamic getAxisValue_dyn();

		virtual Float getAnalogueAxisValue( ::flixel::input::gamepad::FlxAxes Axis,::haxe::ds::EnumValueMap Axes);
		Dynamic getAnalogueAxisValue_dyn();

		virtual bool get_dpadUp( );
		Dynamic get_dpadUp_dyn();

		virtual bool get_dpadDown( );
		Dynamic get_dpadDown_dyn();

		virtual bool get_dpadLeft( );
		Dynamic get_dpadLeft_dyn();

		virtual bool get_dpadRight( );
		Dynamic get_dpadRight_dyn();

};

} // end namespace flixel
} // end namespace input
} // end namespace gamepad

#endif /* INCLUDED_flixel_input_gamepad_FlxGamepad */ 
