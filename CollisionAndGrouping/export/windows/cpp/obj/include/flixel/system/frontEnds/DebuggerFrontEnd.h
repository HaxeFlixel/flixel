#ifndef INCLUDED_flixel_system_frontEnds_DebuggerFrontEnd
#define INCLUDED_flixel_system_frontEnds_DebuggerFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,debug,FlxButtonAlignment)
HX_DECLARE_CLASS3(flixel,system,debug,FlxDebuggerLayout)
HX_DECLARE_CLASS3(flixel,system,debug,TrackerProfile)
HX_DECLARE_CLASS3(flixel,system,debug,Window)
HX_DECLARE_CLASS3(flixel,system,frontEnds,DebuggerFrontEnd)
HX_DECLARE_CLASS3(flixel,system,ui,FlxSystemButton)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxSignal)
HX_DECLARE_CLASS3(flixel,util,_FlxSignal,FlxBaseSignal)
HX_DECLARE_CLASS3(flixel,util,_FlxSignal,FlxSignal0)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  DebuggerFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef DebuggerFrontEnd_obj OBJ_;
		DebuggerFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< DebuggerFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~DebuggerFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("DebuggerFrontEnd"); }

		int precision;
		Array< int > toggleKeys;
		bool drawDebug;
		::flixel::util::_FlxSignal::FlxSignal0 drawDebugChanged;
		bool visible;
		virtual Void setLayout( ::flixel::system::debug::FlxDebuggerLayout Layout);
		Dynamic setLayout_dyn();

		virtual Void resetLayout( );
		Dynamic resetLayout_dyn();

		virtual ::flixel::system::ui::FlxSystemButton addButton( ::flixel::system::debug::FlxButtonAlignment Alignment,::openfl::_v2::display::BitmapData Icon,Dynamic UpHandler,hx::Null< bool >  ToggleMode,hx::Null< bool >  UpdateLayout);
		Dynamic addButton_dyn();

		virtual ::flixel::system::debug::Window track( Dynamic Object,::String WindowTitle);
		Dynamic track_dyn();

		virtual Void addTrackerProfile( ::flixel::system::debug::TrackerProfile Profile);
		Dynamic addTrackerProfile_dyn();

		virtual Void removeButton( ::flixel::system::ui::FlxSystemButton Button,hx::Null< bool >  UpdateLayout);
		Dynamic removeButton_dyn();

		virtual bool set_drawDebug( bool Value);
		Dynamic set_drawDebug_dyn();

		virtual bool set_visible( bool Value);
		Dynamic set_visible_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_DebuggerFrontEnd */ 
