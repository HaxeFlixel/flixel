#ifndef INCLUDED_flixel_graphics_frames_FlxImageFrame
#define INCLUDED_flixel_graphics_frames_FlxImageFrame

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/frames/FlxFramesCollection.h>
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxImageFrame)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxImageFrame_obj : public ::flixel::graphics::frames::FlxFramesCollection_obj{
	public:
		typedef ::flixel::graphics::frames::FlxFramesCollection_obj super;
		typedef FlxImageFrame_obj OBJ_;
		FlxImageFrame_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxImageFrame_obj > __new(::flixel::graphics::FlxGraphic parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxImageFrame_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxImageFrame"); }

		::flixel::graphics::frames::FlxFrame frame;
		virtual bool equals( ::flixel::math::FlxRect rect);
		Dynamic equals_dyn();

		virtual Void destroy( );

		static ::flixel::graphics::frames::FlxImageFrame fromEmptyFrame( ::flixel::graphics::FlxGraphic graphic,::flixel::math::FlxRect frameRect);
		static Dynamic fromEmptyFrame_dyn();

		static ::flixel::graphics::frames::FlxImageFrame fromFrame( ::flixel::graphics::frames::FlxFrame source);
		static Dynamic fromFrame_dyn();

		static ::flixel::graphics::frames::FlxImageFrame fromImage( Dynamic source);
		static Dynamic fromImage_dyn();

		static ::flixel::graphics::frames::FlxImageFrame fromGraphic( ::flixel::graphics::FlxGraphic graphic,::flixel::math::FlxRect region);
		static Dynamic fromGraphic_dyn();

		static ::flixel::graphics::frames::FlxImageFrame fromRectangle( Dynamic source,::flixel::math::FlxRect region);
		static Dynamic fromRectangle_dyn();

		static ::flixel::graphics::frames::FlxImageFrame findFrame( ::flixel::graphics::FlxGraphic graphic,::flixel::math::FlxRect frameRect);
		static Dynamic findFrame_dyn();

		static ::flixel::graphics::frames::FlxImageFrame findEmptyFrame( ::flixel::graphics::FlxGraphic graphic,::flixel::math::FlxRect frameRect);
		static Dynamic findEmptyFrame_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxImageFrame */ 
