#ifndef INCLUDED_flixel_graphics_frames_FlxBarFrames
#define INCLUDED_flixel_graphics_frames_FlxBarFrames

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/frames/FlxFramesCollection.h>
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxBarFrames)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,ui,FlxBarFillDirection)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxBarFrames_obj : public ::flixel::graphics::frames::FlxFramesCollection_obj{
	public:
		typedef ::flixel::graphics::frames::FlxFramesCollection_obj super;
		typedef FlxBarFrames_obj OBJ_;
		FlxBarFrames_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent,::flixel::ui::FlxBarFillDirection barType);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxBarFrames_obj > __new(::flixel::graphics::FlxGraphic parent,::flixel::ui::FlxBarFillDirection barType);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxBarFrames_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxBarFrames"); }

		::flixel::graphics::frames::FlxFrame atlasFrame;
		::flixel::math::FlxRect region;
		::flixel::ui::FlxBarFillDirection barType;
		virtual ::flixel::graphics::frames::FlxBarFrames changeType( ::flixel::ui::FlxBarFillDirection barType);
		Dynamic changeType_dyn();

		virtual ::openfl::_v2::display::BitmapData getFilledBitmap( );
		Dynamic getFilledBitmap_dyn();

		virtual bool equals( ::flixel::ui::FlxBarFillDirection barType,int numFrames,::flixel::math::FlxRect region,::flixel::graphics::frames::FlxFrame atlasFrame);
		Dynamic equals_dyn();

		virtual Void destroy( );

		static ::flixel::graphics::frames::FlxBarFrames fromFrame( ::flixel::graphics::frames::FlxFrame frame,::flixel::ui::FlxBarFillDirection barType,hx::Null< int >  numFrames);
		static Dynamic fromFrame_dyn();

		static ::flixel::graphics::frames::FlxBarFrames fromGraphic( ::flixel::graphics::FlxGraphic graphic,::flixel::ui::FlxBarFillDirection barType,hx::Null< int >  numFrames,::flixel::math::FlxRect region);
		static Dynamic fromGraphic_dyn();

		static ::flixel::graphics::frames::FlxBarFrames fromRectangle( Dynamic source,::flixel::ui::FlxBarFillDirection barType,hx::Null< int >  numFrames,::flixel::math::FlxRect region);
		static Dynamic fromRectangle_dyn();

		static ::flixel::graphics::frames::FlxBarFrames findFrame( ::flixel::graphics::FlxGraphic graphic,::flixel::ui::FlxBarFillDirection barType,hx::Null< int >  numFrames,::flixel::math::FlxRect region,::flixel::graphics::frames::FlxFrame atlasFrame);
		static Dynamic findFrame_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxBarFrames */ 
