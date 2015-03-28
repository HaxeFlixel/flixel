#ifndef INCLUDED_flixel_system_debug_ConsoleCommands
#define INCLUDED_flixel_system_debug_ConsoleCommands

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,debug,Console)
HX_DECLARE_CLASS3(flixel,system,debug,ConsoleCommands)
HX_DECLARE_CLASS3(flixel,system,debug,Window)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
namespace flixel{
namespace system{
namespace debug{


class HXCPP_CLASS_ATTRIBUTES  ConsoleCommands_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ConsoleCommands_obj OBJ_;
		ConsoleCommands_obj();
		Void __construct(::flixel::system::debug::Console console);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ConsoleCommands_obj > __new(::flixel::system::debug::Console console);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ConsoleCommands_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ConsoleCommands"); }

		::flixel::system::debug::Console _console;
		bool _watchingMouse;
		virtual Void help( ::String Alias);
		Dynamic help_dyn();

		virtual Void close( );
		Dynamic close_dyn();

		virtual Void clearHistory( );
		Dynamic clearHistory_dyn();

		virtual Void resetState( );
		Dynamic resetState_dyn();

		virtual Void switchState( ::String ClassName);
		Dynamic switchState_dyn();

		virtual Void resetGame( );
		Dynamic resetGame_dyn();

		virtual Void create( ::String ClassName,::String MousePos,Array< ::String > Params);
		Dynamic create_dyn();

		virtual Void set( ::String ObjectAndVariable,Dynamic NewVariableValue,::String WatchName);
		Dynamic set_dyn();

		virtual Void fields( ::String ObjectAndVariable,hx::Null< int >  NumSuperClassesToInclude);
		Dynamic fields_dyn();

		virtual Void call( ::String FunctionAlias,Array< ::String > Params);
		Dynamic call_dyn();

		virtual Void listObjects( );
		Dynamic listObjects_dyn();

		virtual Void listFunctions( );
		Dynamic listFunctions_dyn();

		virtual Void watchMouse( );
		Dynamic watchMouse_dyn();

		virtual Void track( ::String ObjectAndVariable);
		Dynamic track_dyn();

		virtual Void pause( );
		Dynamic pause_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_ConsoleCommands */ 
