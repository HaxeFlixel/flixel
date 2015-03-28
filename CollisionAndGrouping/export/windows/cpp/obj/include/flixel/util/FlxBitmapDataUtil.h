#ifndef INCLUDED_flixel_util_FlxBitmapDataUtil
#define INCLUDED_flixel_util_FlxBitmapDataUtil

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,FlxBitmapDataUtil)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  FlxBitmapDataUtil_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxBitmapDataUtil_obj OBJ_;
		FlxBitmapDataUtil_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxBitmapDataUtil_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxBitmapDataUtil_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxBitmapDataUtil"); }

		static Void merge( ::openfl::_v2::display::BitmapData sourceBitmapData,::openfl::_v2::geom::Rectangle sourceRect,::openfl::_v2::display::BitmapData destBitmapData,::openfl::_v2::geom::Point destPoint,int redMultiplier,int greenMultiplier,int blueMultiplier,int alphaMultiplier);
		static Dynamic merge_dyn();

		static int mergeColorComponent( int source,int dest,int multiplier);
		static Dynamic mergeColorComponent_dyn();

		static Dynamic compare( ::openfl::_v2::display::BitmapData Bitmap1,::openfl::_v2::display::BitmapData Bitmap2);
		static Dynamic compare_dyn();

		static Float getMemorySize( ::openfl::_v2::display::BitmapData bitmapData);
		static Dynamic getMemorySize_dyn();

		static Array< ::Dynamic > replaceColor( ::openfl::_v2::display::BitmapData bitmapData,int color,int newColor,hx::Null< bool >  fetchPositions,::flixel::math::FlxRect rect);
		static Dynamic replaceColor_dyn();

		static ::openfl::_v2::display::BitmapData addSpacing( ::openfl::_v2::display::BitmapData bitmapData,::flixel::math::FlxPoint frameSize,::flixel::math::FlxPoint spacing,::flixel::math::FlxRect region);
		static Dynamic addSpacing_dyn();

		static ::openfl::_v2::display::BitmapData generateRotations( ::openfl::_v2::display::BitmapData brush,hx::Null< int >  rotations,hx::Null< bool >  antiAliasing,hx::Null< bool >  autoBuffer);
		static Dynamic generateRotations_dyn();

};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_FlxBitmapDataUtil */ 
