#ifndef INCLUDED_flixel_graphics_frames_FlxEmptyFrame
#define INCLUDED_flixel_graphics_frames_FlxEmptyFrame

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/frames/FlxFrame.h>
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxEmptyFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxEmptyFrame_obj : public ::flixel::graphics::frames::FlxFrame_obj{
	public:
		typedef ::flixel::graphics::frames::FlxFrame_obj super;
		typedef FlxEmptyFrame_obj OBJ_;
		FlxEmptyFrame_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxEmptyFrame_obj > __new(::flixel::graphics::FlxGraphic parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxEmptyFrame_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxEmptyFrame"); }

		virtual ::openfl::_v2::display::BitmapData paintOnBitmap( ::openfl::_v2::display::BitmapData bmd);

		virtual ::openfl::_v2::display::BitmapData getHReversedBitmap( );

		virtual ::openfl::_v2::display::BitmapData getVReversedBitmap( );

		virtual ::openfl::_v2::display::BitmapData getHVReversedBitmap( );

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxEmptyFrame */ 
