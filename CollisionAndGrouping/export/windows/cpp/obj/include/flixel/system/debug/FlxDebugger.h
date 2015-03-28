#ifndef INCLUDED_flixel_system_debug_FlxDebugger
#define INCLUDED_flixel_system_debug_FlxDebugger

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/Sprite.h>
HX_DECLARE_CLASS3(flixel,system,debug,BitmapLog)
HX_DECLARE_CLASS3(flixel,system,debug,Console)
HX_DECLARE_CLASS3(flixel,system,debug,FlxButtonAlignment)
HX_DECLARE_CLASS3(flixel,system,debug,FlxDebugger)
HX_DECLARE_CLASS3(flixel,system,debug,FlxDebuggerLayout)
HX_DECLARE_CLASS3(flixel,system,debug,Log)
HX_DECLARE_CLASS3(flixel,system,debug,Stats)
HX_DECLARE_CLASS3(flixel,system,debug,VCR)
HX_DECLARE_CLASS3(flixel,system,debug,Watch)
HX_DECLARE_CLASS3(flixel,system,debug,Window)
HX_DECLARE_CLASS3(flixel,system,ui,FlxSystemButton)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace flixel{
namespace system{
namespace debug{


class HXCPP_CLASS_ATTRIBUTES  FlxDebugger_obj : public ::openfl::_v2::display::Sprite_obj{
	public:
		typedef ::openfl::_v2::display::Sprite_obj super;
		typedef FlxDebugger_obj OBJ_;
		FlxDebugger_obj();
		Void __construct(Float Width,Float Height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxDebugger_obj > __new(Float Width,Float Height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxDebugger_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxDebugger"); }

		::flixel::system::debug::Stats stats;
		::flixel::system::debug::Log log;
		::flixel::system::debug::Watch watch;
		::flixel::system::debug::BitmapLog bitmapLog;
		::flixel::system::debug::VCR vcr;
		::flixel::system::debug::Console console;
		bool hasMouse;
		::flixel::system::debug::FlxDebuggerLayout _layout;
		::openfl::_v2::geom::Point _screen;
		::openfl::_v2::geom::Rectangle _screenBounds;
		Array< ::Dynamic > _middleButtons;
		Array< ::Dynamic > _leftButtons;
		Array< ::Dynamic > _rightButtons;
		::openfl::_v2::display::Sprite _topBar;
		Array< ::Dynamic > _windows;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void update( );
		Dynamic update_dyn();

		virtual Void setLayout( ::flixel::system::debug::FlxDebuggerLayout Layout);
		Dynamic setLayout_dyn();

		virtual Void resetLayout( );
		Dynamic resetLayout_dyn();

		virtual Void onResize( Float Width,Float Height);
		Dynamic onResize_dyn();

		virtual Void updateBounds( );
		Dynamic updateBounds_dyn();

		virtual Float hAlignButtons( Array< ::Dynamic > Sprites,hx::Null< Float >  Padding,hx::Null< bool >  Set,hx::Null< Float >  LeftOffset);
		Dynamic hAlignButtons_dyn();

		virtual Void resetButtonLayout( );
		Dynamic resetButtonLayout_dyn();

		virtual ::flixel::system::ui::FlxSystemButton addButton( ::flixel::system::debug::FlxButtonAlignment Position,::openfl::_v2::display::BitmapData Icon,Dynamic UpHandler,hx::Null< bool >  ToggleMode,hx::Null< bool >  UpdateLayout);
		Dynamic addButton_dyn();

		virtual Void removeButton( ::flixel::system::ui::FlxSystemButton Button,hx::Null< bool >  UpdateLayout);
		Dynamic removeButton_dyn();

		virtual Void addWindowToggleButton( ::flixel::system::debug::Window window,::Class icon);
		Dynamic addWindowToggleButton_dyn();

		virtual ::flixel::system::debug::Window addWindow( ::flixel::system::debug::Window window);
		Dynamic addWindow_dyn();

		virtual Void removeWindow( ::flixel::system::debug::Window window);
		Dynamic removeWindow_dyn();

		virtual Void onMouseOver( Dynamic _);
		Dynamic onMouseOver_dyn();

		virtual Void onMouseOut( Dynamic _);
		Dynamic onMouseOut_dyn();

		virtual Void removeButtonFromArray( Array< ::Dynamic > Arr,::flixel::system::ui::FlxSystemButton Button);
		Dynamic removeButtonFromArray_dyn();

		virtual Void toggleDrawDebug( );
		Dynamic toggleDrawDebug_dyn();

		virtual Void openHomepage( );
		Dynamic openHomepage_dyn();

		virtual Void openGitHub( );
		Dynamic openGitHub_dyn();

		static int GUTTER;
		static int TOP_HEIGHT;
};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_FlxDebugger */ 
