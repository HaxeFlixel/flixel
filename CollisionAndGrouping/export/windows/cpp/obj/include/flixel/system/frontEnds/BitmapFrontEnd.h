#ifndef INCLUDED_flixel_system_frontEnds_BitmapFrontEnd
#define INCLUDED_flixel_system_frontEnds_BitmapFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS3(flixel,system,frontEnds,BitmapFrontEnd)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  BitmapFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BitmapFrontEnd_obj OBJ_;
		BitmapFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BitmapFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BitmapFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("BitmapFrontEnd"); }

		::haxe::ds::StringMap _cache;
		virtual Void onAssetsReload( ::openfl::_v2::events::Event e);
		Dynamic onAssetsReload_dyn();

		::flixel::graphics::frames::FlxFrame whitePixel;
		::flixel::graphics::frames::FlxFrame _whitePixel;
		virtual ::flixel::graphics::frames::FlxFrame get_whitePixel( );
		Dynamic get_whitePixel_dyn();

		virtual Void onContext( );
		Dynamic onContext_dyn();

		virtual Void dumpCache( );
		Dynamic dumpCache_dyn();

		virtual Void undumpCache( );
		Dynamic undumpCache_dyn();

		virtual bool checkCache( ::String Key);
		Dynamic checkCache_dyn();

		virtual ::flixel::graphics::FlxGraphic create( int Width,int Height,int Color,hx::Null< bool >  Unique,::String Key);
		Dynamic create_dyn();

		virtual ::flixel::graphics::FlxGraphic add( Dynamic Graphic,hx::Null< bool >  Unique,::String Key);
		Dynamic add_dyn();

		virtual ::flixel::graphics::FlxGraphic addGraphic( ::flixel::graphics::FlxGraphic graphic);
		Dynamic addGraphic_dyn();

		virtual ::flixel::graphics::FlxGraphic get( ::String key);
		Dynamic get_dyn();

		virtual ::String findKeyForBitmap( ::openfl::_v2::display::BitmapData bmd);
		Dynamic findKeyForBitmap_dyn();

		virtual ::String getKeyForClass( ::Class source);
		Dynamic getKeyForClass_dyn();

		virtual ::String generateKey( ::String systemKey,::String userKey,hx::Null< bool >  unique);
		Dynamic generateKey_dyn();

		virtual ::String getUniqueKey( ::String baseKey);
		Dynamic getUniqueKey_dyn();

		virtual ::String getKeyWithSpacings( ::String baseKey,::flixel::math::FlxPoint frameSize,::flixel::math::FlxPoint frameSpacing,::flixel::math::FlxRect region);
		Dynamic getKeyWithSpacings_dyn();

		virtual Void remove( ::flixel::graphics::FlxGraphic graphic);
		Dynamic remove_dyn();

		virtual Void removeByKey( ::String key);
		Dynamic removeByKey_dyn();

		virtual Void removeFromOpenFLCache( ::String key);
		Dynamic removeFromOpenFLCache_dyn();

		virtual Void removeIfNoUse( ::flixel::graphics::FlxGraphic graphic);
		Dynamic removeIfNoUse_dyn();

		virtual Void clearCache( );
		Dynamic clearCache_dyn();

		virtual Void clearUnused( );
		Dynamic clearUnused_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_BitmapFrontEnd */ 
