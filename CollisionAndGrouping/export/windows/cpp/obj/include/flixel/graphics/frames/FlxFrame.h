#ifndef INCLUDED_flixel_graphics_frames_FlxFrame
#define INCLUDED_flixel_graphics_frames_FlxFrame

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS2(flixel,math,FlxMatrix)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxFrame_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxFrame_obj OBJ_;
		FlxFrame_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxFrame_obj > __new(::flixel::graphics::FlxGraphic parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxFrame_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxFrame_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxFrame"); }

		::String name;
		::flixel::math::FlxRect frame;
		::flixel::graphics::FlxGraphic parent;
		int tileID;
		int angle;
		::flixel::math::FlxPoint sourceSize;
		::flixel::math::FlxPoint offset;
		::flixel::math::FlxPoint center;
		int type;
		::openfl::_v2::display::BitmapData _bitmapData;
		::openfl::_v2::display::BitmapData _hReversedBitmapData;
		::openfl::_v2::display::BitmapData _vReversedBitmapData;
		::openfl::_v2::display::BitmapData _hvReversedBitmapData;
		virtual ::flixel::math::FlxMatrix prepareFrameMatrix( ::flixel::math::FlxMatrix mat);
		Dynamic prepareFrameMatrix_dyn();

		virtual ::openfl::_v2::display::BitmapData paintOnBitmap( ::openfl::_v2::display::BitmapData bmd);
		Dynamic paintOnBitmap_dyn();

		virtual ::openfl::_v2::display::BitmapData getBitmap( );
		Dynamic getBitmap_dyn();

		virtual ::openfl::_v2::display::BitmapData getHReversedBitmap( );
		Dynamic getHReversedBitmap_dyn();

		virtual ::openfl::_v2::display::BitmapData getVReversedBitmap( );
		Dynamic getVReversedBitmap_dyn();

		virtual ::openfl::_v2::display::BitmapData getHVReversedBitmap( );
		Dynamic getHVReversedBitmap_dyn();

		virtual Void destroyBitmaps( );
		Dynamic destroyBitmaps_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		static int sortByName( ::flixel::graphics::frames::FlxFrame frame1,::flixel::graphics::frames::FlxFrame frame2,int prefixLength,int postfixLength);
		static Dynamic sortByName_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxFrame */ 
