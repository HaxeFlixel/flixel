#ifndef INCLUDED_flixel_input_keyboard_FlxKeyboard
#define INCLUDED_flixel_input_keyboard_FlxKeyboard

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/input/FlxKeyManager.h>
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS2(flixel,input,FlxKeyManager)
HX_DECLARE_CLASS2(flixel,input,IFlxInputManager)
HX_DECLARE_CLASS3(flixel,input,keyboard,FlxKeyboard)
HX_DECLARE_CLASS3(flixel,system,replay,CodeValuePair)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,KeyboardEvent)
namespace flixel{
namespace input{
namespace keyboard{


class HXCPP_CLASS_ATTRIBUTES  FlxKeyboard_obj : public ::flixel::input::FlxKeyManager_obj{
	public:
		typedef ::flixel::input::FlxKeyManager_obj super;
		typedef FlxKeyboard_obj OBJ_;
		FlxKeyboard_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxKeyboard_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxKeyboard_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxKeyboard"); }

		::haxe::ds::StringMap _nativeCorrection;
		virtual Void onKeyUp( ::openfl::_v2::events::KeyboardEvent event);

		virtual Void onKeyDown( ::openfl::_v2::events::KeyboardEvent event);

		virtual int resolveKeyCode( ::openfl::_v2::events::KeyboardEvent e);

		virtual Array< ::Dynamic > record( );
		Dynamic record_dyn();

		virtual Void playback( Array< ::Dynamic > Record);
		Dynamic playback_dyn();

};

} // end namespace flixel
} // end namespace input
} // end namespace keyboard

#endif /* INCLUDED_flixel_input_keyboard_FlxKeyboard */ 
