#ifndef INCLUDED_flixel_util_FlxDestroyUtil
#define INCLUDED_flixel_util_FlxDestroyUtil

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,util,FlxDestroyUtil)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  FlxDestroyUtil_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxDestroyUtil_obj OBJ_;
		FlxDestroyUtil_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxDestroyUtil_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxDestroyUtil_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxDestroyUtil"); }

		static Dynamic destroy( ::flixel::util::IFlxDestroyable object);
		static Dynamic destroy_dyn();

		static Dynamic destroyArray( Dynamic array);
		static Dynamic destroyArray_dyn();

		static Dynamic put( ::flixel::util::IFlxPooled object);
		static Dynamic put_dyn();

		static Dynamic putArray( Dynamic array);
		static Dynamic putArray_dyn();

		static ::openfl::_v2::display::BitmapData dispose( ::openfl::_v2::display::BitmapData bitmapData);
		static Dynamic dispose_dyn();

		static Dynamic removeChild( ::openfl::_v2::display::DisplayObjectContainer parent,Dynamic child);
		static Dynamic removeChild_dyn();

};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_FlxDestroyUtil */ 
