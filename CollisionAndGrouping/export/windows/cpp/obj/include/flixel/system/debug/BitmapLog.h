#ifndef INCLUDED_flixel_system_debug_BitmapLog
#define INCLUDED_flixel_system_debug_BitmapLog

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/system/debug/Window.h>
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS3(flixel,system,debug,BitmapLog)
HX_DECLARE_CLASS3(flixel,system,debug,Window)
HX_DECLARE_CLASS3(flixel,system,ui,FlxSystemButton)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
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
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
HX_DECLARE_CLASS3(openfl,_v2,text,TextField)
namespace flixel{
namespace system{
namespace debug{


class HXCPP_CLASS_ATTRIBUTES  BitmapLog_obj : public ::flixel::system::debug::Window_obj{
	public:
		typedef ::flixel::system::debug::Window_obj super;
		typedef BitmapLog_obj OBJ_;
		BitmapLog_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BitmapLog_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BitmapLog_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("BitmapLog"); }

		Float zoom;
		::openfl::_v2::display::Bitmap _canvasBitmap;
		Dynamic _entries;
		int _curIndex;
		::flixel::math::FlxPoint _point;
		::flixel::math::FlxPoint _lastMousePos;
		::flixel::math::FlxPoint _curMouseOffset;
		::openfl::_v2::geom::Matrix _matrix;
		::flixel::system::ui::FlxSystemButton _buttonLeft;
		::flixel::system::ui::FlxSystemButton _buttonText;
		::flixel::system::ui::FlxSystemButton _buttonRight;
		::openfl::_v2::text::TextField _counterText;
		::openfl::_v2::text::TextField _dimensionsText;
		::openfl::_v2::display::Sprite _ui;
		bool _middleMouseDown;
		::openfl::_v2::display::Bitmap _footer;
		::openfl::_v2::text::TextField _footerText;
		virtual Void createHeaderUI( );
		Dynamic createHeaderUI_dyn();

		virtual Void createFooterUI( );
		Dynamic createFooterUI_dyn();

		virtual Void destroy( );

		virtual Void update( );

		virtual Void updateSize( );

		virtual Void resize( Float Width,Float Height);

		virtual Void resizeTexts( );
		Dynamic resizeTexts_dyn();

		virtual Void next( );
		Dynamic next_dyn();

		virtual Void previous( );
		Dynamic previous_dyn();

		virtual Void resetSettings( );
		Dynamic resetSettings_dyn();

		virtual bool add( ::openfl::_v2::display::BitmapData bmp,::String name);
		Dynamic add_dyn();

		virtual Void clearAt( hx::Null< int >  Index);
		Dynamic clearAt_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool refreshCanvas( Dynamic Index);
		Dynamic refreshCanvas_dyn();

		virtual Void refreshTexts( );
		Dynamic refreshTexts_dyn();

		virtual Void drawBoundingBox( ::openfl::_v2::display::BitmapData bitmap);
		Dynamic drawBoundingBox_dyn();

		virtual Void onMouseWheel( ::openfl::_v2::events::MouseEvent e);
		Dynamic onMouseWheel_dyn();

		virtual Void onMiddleDown( ::openfl::_v2::events::MouseEvent e);
		Dynamic onMiddleDown_dyn();

		virtual Void onMiddleUp( ::openfl::_v2::events::MouseEvent e);
		Dynamic onMiddleUp_dyn();

		virtual Float set_zoom( Float Value);
		Dynamic set_zoom_dyn();

		virtual ::openfl::_v2::display::BitmapData get__canvas( );
		Dynamic get__canvas_dyn();

		virtual Dynamic get__curEntry( );
		Dynamic get__curEntry_dyn();

		virtual ::openfl::_v2::display::BitmapData get__curBitmap( );
		Dynamic get__curBitmap_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_BitmapLog */ 
