#ifndef INCLUDED_openfl__v2_display_Bitmap
#define INCLUDED_openfl__v2_display_Bitmap

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/DisplayObject.h>
HX_DECLARE_CLASS3(openfl,_v2,display,Bitmap)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS2(openfl,display,PixelSnapping)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  Bitmap_obj : public ::openfl::_v2::display::DisplayObject_obj{
	public:
		typedef ::openfl::_v2::display::DisplayObject_obj super;
		typedef Bitmap_obj OBJ_;
		Bitmap_obj();
		Void __construct(::openfl::_v2::display::BitmapData bitmapData,::openfl::display::PixelSnapping pixelSnapping,hx::Null< bool >  __o_smoothing);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Bitmap_obj > __new(::openfl::_v2::display::BitmapData bitmapData,::openfl::display::PixelSnapping pixelSnapping,hx::Null< bool >  __o_smoothing);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Bitmap_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Bitmap"); }

		::openfl::_v2::display::BitmapData bitmapData;
		bool smoothing;
		virtual Void __rebuild( );
		Dynamic __rebuild_dyn();

		virtual ::openfl::_v2::display::BitmapData set_bitmapData( ::openfl::_v2::display::BitmapData value);
		Dynamic set_bitmapData_dyn();

		virtual ::openfl::display::PixelSnapping get_pixelSnapping( );
		Dynamic get_pixelSnapping_dyn();

		virtual ::openfl::display::PixelSnapping set_pixelSnapping( ::openfl::display::PixelSnapping value);
		Dynamic set_pixelSnapping_dyn();

		virtual bool set_smoothing( bool value);
		Dynamic set_smoothing_dyn();

		static Dynamic lime_display_object_get_pixel_snapping;
		static Dynamic &lime_display_object_get_pixel_snapping_dyn() { return lime_display_object_get_pixel_snapping;}
		static Dynamic lime_display_object_set_pixel_snapping;
		static Dynamic &lime_display_object_set_pixel_snapping_dyn() { return lime_display_object_set_pixel_snapping;}
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_Bitmap */ 
