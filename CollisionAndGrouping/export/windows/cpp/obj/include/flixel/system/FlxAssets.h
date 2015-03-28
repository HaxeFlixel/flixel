#ifndef INCLUDED_flixel_system_FlxAssets
#define INCLUDED_flixel_system_FlxAssets

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,graphics,frames,FlxAtlasFrames)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS2(flixel,system,FlxAssets)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,Graphics)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,media,Sound)
namespace flixel{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  FlxAssets_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxAssets_obj OBJ_;
		FlxAssets_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxAssets_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxAssets_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxAssets"); }

		static ::String FONT_DEFAULT;
		static ::String FONT_DEBUGGER;
		static Void init( );
		static Dynamic init_dyn();

		static Void drawLogo( ::openfl::_v2::display::Graphics graph);
		static Dynamic drawLogo_dyn();

		static ::openfl::_v2::display::BitmapData getBitmapData( ::String id);
		static Dynamic getBitmapData_dyn();

		static ::openfl::_v2::display::BitmapData getBitmapFromClass( ::Class source);
		static Dynamic getBitmapFromClass_dyn();

		static ::openfl::_v2::display::BitmapData resolveBitmapData( Dynamic Graphic);
		static Dynamic resolveBitmapData_dyn();

		static ::String resolveKey( Dynamic Graphic,::String Key);
		static Dynamic resolveKey_dyn();

		static ::openfl::_v2::media::Sound getSound( ::String id);
		static Dynamic getSound_dyn();

		static ::flixel::graphics::frames::FlxAtlasFrames getVirtualInputFrames( );
		static Dynamic getVirtualInputFrames_dyn();

};

} // end namespace flixel
} // end namespace system

#endif /* INCLUDED_flixel_system_FlxAssets */ 
