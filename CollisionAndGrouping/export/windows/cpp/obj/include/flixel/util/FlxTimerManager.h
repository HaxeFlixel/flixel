#ifndef INCLUDED_flixel_util_FlxTimerManager
#define INCLUDED_flixel_util_FlxTimerManager

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxBasic.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS2(flixel,util,FlxTimer)
HX_DECLARE_CLASS2(flixel,util,FlxTimerManager)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  FlxTimerManager_obj : public ::flixel::FlxBasic_obj{
	public:
		typedef ::flixel::FlxBasic_obj super;
		typedef FlxTimerManager_obj OBJ_;
		FlxTimerManager_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTimerManager_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTimerManager_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTimerManager"); }

		Array< ::Dynamic > _timers;
		virtual Void destroy( );

		virtual Void update( Float elapsed);

		virtual Void add( ::flixel::util::FlxTimer Timer);
		Dynamic add_dyn();

		virtual Void remove( ::flixel::util::FlxTimer Timer);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_FlxTimerManager */ 
