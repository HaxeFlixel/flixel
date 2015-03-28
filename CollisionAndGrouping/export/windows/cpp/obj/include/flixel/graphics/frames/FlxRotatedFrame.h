#ifndef INCLUDED_flixel_graphics_frames_FlxRotatedFrame
#define INCLUDED_flixel_graphics_frames_FlxRotatedFrame

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/frames/FlxFrame.h>
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxRotatedFrame)
HX_DECLARE_CLASS2(flixel,math,FlxMatrix)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxRotatedFrame_obj : public ::flixel::graphics::frames::FlxFrame_obj{
	public:
		typedef ::flixel::graphics::frames::FlxFrame_obj super;
		typedef FlxRotatedFrame_obj OBJ_;
		FlxRotatedFrame_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent,int angle);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxRotatedFrame_obj > __new(::flixel::graphics::FlxGraphic parent,int angle);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxRotatedFrame_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxRotatedFrame"); }

		virtual ::flixel::math::FlxMatrix prepareFrameMatrix( ::flixel::math::FlxMatrix mat);

		virtual ::openfl::_v2::display::BitmapData paintOnBitmap( ::openfl::_v2::display::BitmapData bmd);

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxRotatedFrame */ 
