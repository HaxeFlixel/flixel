#ifndef INCLUDED_flixel_system_ui_FlxSystemButton
#define INCLUDED_flixel_system_ui_FlxSystemButton

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/Sprite.h>
#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS3(flixel,system,ui,FlxSystemButton)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,Bitmap)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,MouseEvent)
namespace flixel{
namespace system{
namespace ui{


class HXCPP_CLASS_ATTRIBUTES  FlxSystemButton_obj : public ::openfl::_v2::display::Sprite_obj{
	public:
		typedef ::openfl::_v2::display::Sprite_obj super;
		typedef FlxSystemButton_obj OBJ_;
		FlxSystemButton_obj();
		Void __construct(::openfl::_v2::display::BitmapData Icon,Dynamic UpHandler,hx::Null< bool >  __o_ToggleMode);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxSystemButton_obj > __new(::openfl::_v2::display::BitmapData Icon,Dynamic UpHandler,hx::Null< bool >  __o_ToggleMode);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxSystemButton_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxSystemButton_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxSystemButton"); }

		Dynamic upHandler;
		Dynamic &upHandler_dyn() { return upHandler;}
		bool enabled;
		bool toggleMode;
		bool toggled;
		::openfl::_v2::display::Bitmap _icon;
		bool _mouseDown;
		virtual Void changeIcon( ::openfl::_v2::display::BitmapData Icon);
		Dynamic changeIcon_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void onMouseUp( ::openfl::_v2::events::MouseEvent E);
		Dynamic onMouseUp_dyn();

		virtual Void onMouseDown( ::openfl::_v2::events::MouseEvent E);
		Dynamic onMouseDown_dyn();

		virtual Void onMouseOver( ::openfl::_v2::events::MouseEvent E);
		Dynamic onMouseOver_dyn();

		virtual Void onMouseOut( ::openfl::_v2::events::MouseEvent E);
		Dynamic onMouseOut_dyn();

		virtual bool set_toggled( bool Value);
		Dynamic set_toggled_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace ui

#endif /* INCLUDED_flixel_system_ui_FlxSystemButton */ 
