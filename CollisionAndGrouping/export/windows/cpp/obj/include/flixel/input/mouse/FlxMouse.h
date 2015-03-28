#ifndef INCLUDED_flixel_input_mouse_FlxMouse
#define INCLUDED_flixel_input_mouse_FlxMouse

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/input/FlxPointer.h>
#include <flixel/input/IFlxInputManager.h>
HX_DECLARE_CLASS2(flixel,input,FlxInput)
HX_DECLARE_CLASS2(flixel,input,FlxPointer)
HX_DECLARE_CLASS2(flixel,input,IFlxInput)
HX_DECLARE_CLASS2(flixel,input,IFlxInputManager)
HX_DECLARE_CLASS3(flixel,input,mouse,FlxMouse)
HX_DECLARE_CLASS3(flixel,input,mouse,FlxMouseButton)
HX_DECLARE_CLASS3(flixel,system,replay,MouseRecord)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,Bitmap)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,display,Stage)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,MouseEvent)
namespace flixel{
namespace input{
namespace mouse{


class HXCPP_CLASS_ATTRIBUTES  FlxMouse_obj : public ::flixel::input::FlxPointer_obj{
	public:
		typedef ::flixel::input::FlxPointer_obj super;
		typedef FlxMouse_obj OBJ_;
		FlxMouse_obj();
		Void __construct(::openfl::_v2::display::Sprite CursorContainer);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxMouse_obj > __new(::openfl::_v2::display::Sprite CursorContainer);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxMouse_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxMouse_obj >(this); }
		inline operator ::flixel::input::IFlxInputManager_obj *()
			{ return new ::flixel::input::IFlxInputManager_delegate_< FlxMouse_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxMouse"); }

		int wheel;
		::openfl::_v2::display::Sprite cursorContainer;
		bool visible;
		bool useSystemCursor;
		::flixel::input::mouse::FlxMouseButton _leftButton;
		::flixel::input::mouse::FlxMouseButton _middleButton;
		::flixel::input::mouse::FlxMouseButton _rightButton;
		::openfl::_v2::display::Bitmap _cursor;
		::openfl::_v2::display::BitmapData _cursorBitmapData;
		bool _wheelUsed;
		bool _visibleWhenFocusLost;
		int _lastX;
		int _lastY;
		int _lastWheel;
		::openfl::_v2::display::Stage _stage;
		virtual Void load( Dynamic Graphic,hx::Null< Float >  Scale,hx::Null< int >  XOffset,hx::Null< int >  YOffset);
		Dynamic load_dyn();

		virtual Void unload( );
		Dynamic unload_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void reset( );
		Dynamic reset_dyn();

		virtual Void update( );
		Dynamic update_dyn();

		virtual Void onFocus( );
		Dynamic onFocus_dyn();

		virtual Void onFocusLost( );
		Dynamic onFocusLost_dyn();

		virtual Void onGameStart( );
		Dynamic onGameStart_dyn();

		virtual Void onMouseWheel( ::openfl::_v2::events::MouseEvent FlashEvent);
		Dynamic onMouseWheel_dyn();

		virtual Void onMouseLeave( Dynamic _);
		Dynamic onMouseLeave_dyn();

		virtual bool get_pressed( );
		Dynamic get_pressed_dyn();

		virtual bool get_justPressed( );
		Dynamic get_justPressed_dyn();

		virtual bool get_justReleased( );
		Dynamic get_justReleased_dyn();

		virtual bool get_pressedRight( );
		Dynamic get_pressedRight_dyn();

		virtual bool get_justPressedRight( );
		Dynamic get_justPressedRight_dyn();

		virtual bool get_justReleasedRight( );
		Dynamic get_justReleasedRight_dyn();

		virtual bool get_pressedMiddle( );
		Dynamic get_pressedMiddle_dyn();

		virtual bool get_justPressedMiddle( );
		Dynamic get_justPressedMiddle_dyn();

		virtual bool get_justReleasedMiddle( );
		Dynamic get_justReleasedMiddle_dyn();

		virtual Void showSystemCursor( );
		Dynamic showSystemCursor_dyn();

		virtual Void hideSystemCursor( );
		Dynamic hideSystemCursor_dyn();

		virtual bool set_useSystemCursor( bool Value);
		Dynamic set_useSystemCursor_dyn();

		virtual bool set_visible( bool Value);
		Dynamic set_visible_dyn();

		virtual ::flixel::system::replay::MouseRecord record( );
		Dynamic record_dyn();

		virtual Void playback( ::flixel::system::replay::MouseRecord Record);
		Dynamic playback_dyn();

};

} // end namespace flixel
} // end namespace input
} // end namespace mouse

#endif /* INCLUDED_flixel_input_mouse_FlxMouse */ 
