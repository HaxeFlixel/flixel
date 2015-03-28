#ifndef INCLUDED_flixel_system_debug_Tracker
#define INCLUDED_flixel_system_debug_Tracker

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/system/debug/Watch.h>
HX_DECLARE_CLASS3(flixel,system,debug,Tracker)
HX_DECLARE_CLASS3(flixel,system,debug,TrackerProfile)
HX_DECLARE_CLASS3(flixel,system,debug,Watch)
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


class HXCPP_CLASS_ATTRIBUTES  Tracker_obj : public ::flixel::system::debug::Watch_obj{
	public:
		typedef ::flixel::system::debug::Watch_obj super;
		typedef Tracker_obj OBJ_;
		Tracker_obj();
		Void __construct(::flixel::system::debug::TrackerProfile Profile,Dynamic Object,::String WindowTitle);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Tracker_obj > __new(::flixel::system::debug::TrackerProfile Profile,Dynamic Object,::String WindowTitle);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Tracker_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Tracker"); }

		Dynamic _object;
		virtual Void destroy( );

		virtual ::flixel::system::debug::TrackerProfile findProfileByClass( ::Class ObjectClass);
		Dynamic findProfileByClass_dyn();

		virtual Void initWatchEntries( ::flixel::system::debug::TrackerProfile Profile);
		Dynamic initWatchEntries_dyn();

		virtual Void addExtensions( ::flixel::system::debug::TrackerProfile Profile);
		Dynamic addExtensions_dyn();

		virtual Void addVariables( Array< ::String > Variables);
		Dynamic addVariables_dyn();

		static Array< ::Dynamic > profiles;
		static Dynamic objectsBeingTracked;
		static int _numTrackerWindows;
		static Void addProfile( ::flixel::system::debug::TrackerProfile Profile);
		static Dynamic addProfile_dyn();

		static ::flixel::system::debug::TrackerProfile findProfile( Dynamic Object);
		static Dynamic findProfile_dyn();

		static Void onStateSwitch( );
		static Dynamic onStateSwitch_dyn();

		static Void initProfiles( );
		static Dynamic initProfiles_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_Tracker */ 
