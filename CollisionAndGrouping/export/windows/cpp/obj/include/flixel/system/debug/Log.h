#ifndef INCLUDED_flixel_system_debug_Log
#define INCLUDED_flixel_system_debug_Log

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/system/debug/Window.h>
HX_DECLARE_CLASS3(flixel,system,debug,Log)
HX_DECLARE_CLASS3(flixel,system,debug,LogStyle)
HX_DECLARE_CLASS3(flixel,system,debug,Window)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,text,TextField)
namespace flixel{
namespace system{
namespace debug{


class HXCPP_CLASS_ATTRIBUTES  Log_obj : public ::flixel::system::debug::Window_obj{
	public:
		typedef ::flixel::system::debug::Window_obj super;
		typedef Log_obj OBJ_;
		Log_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Log_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Log_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Log"); }

		::openfl::_v2::text::TextField _text;
		Array< ::String > _lines;
		virtual Void destroy( );

		virtual bool add( Dynamic Data,::flixel::system::debug::LogStyle Style,hx::Null< bool >  FireOnce);
		Dynamic add_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void updateSize( );

		static int MAX_LOG_LINES;
		static ::String LINE_BREAK;
};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_Log */ 
