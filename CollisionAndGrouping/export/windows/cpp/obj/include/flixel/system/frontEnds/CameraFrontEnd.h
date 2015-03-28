#ifndef INCLUDED_flixel_system_frontEnds_CameraFrontEnd
#define INCLUDED_flixel_system_frontEnds_CameraFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS1(flixel,FlxCameraShakeDirection)
HX_DECLARE_CLASS3(flixel,system,frontEnds,CameraFrontEnd)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  CameraFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef CameraFrontEnd_obj OBJ_;
		CameraFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< CameraFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~CameraFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("CameraFrontEnd"); }

		virtual ::flixel::FlxCamera add_flixel_FlxCamera( ::flixel::FlxCamera NewCamera);
		Dynamic add_flixel_FlxCamera_dyn();

		Array< ::Dynamic > list;
		bool useBufferLocking;
		::openfl::_v2::geom::Rectangle _cameraRect;
		virtual Void remove( ::flixel::FlxCamera Camera,hx::Null< bool >  Destroy);
		Dynamic remove_dyn();

		virtual Void reset( ::flixel::FlxCamera NewCamera);
		Dynamic reset_dyn();

		virtual Void flash( hx::Null< int >  Color,hx::Null< Float >  Duration,Dynamic OnComplete,hx::Null< bool >  Force);
		Dynamic flash_dyn();

		virtual Void fade( hx::Null< int >  Color,hx::Null< Float >  Duration,hx::Null< bool >  FadeIn,Dynamic OnComplete,hx::Null< bool >  Force);
		Dynamic fade_dyn();

		virtual Void shake( hx::Null< Float >  Intensity,hx::Null< Float >  Duration,Dynamic OnComplete,hx::Null< bool >  Force,::flixel::FlxCameraShakeDirection Direction);
		Dynamic shake_dyn();

		virtual Void lock( );
		Dynamic lock_dyn();

		virtual Void render( );
		Dynamic render_dyn();

		virtual Void unlock( );
		Dynamic unlock_dyn();

		virtual Void update( Float elapsed);
		Dynamic update_dyn();

		virtual Void resize( );
		Dynamic resize_dyn();

		virtual int get_bgColor( );
		Dynamic get_bgColor_dyn();

		virtual int set_bgColor( int Color);
		Dynamic set_bgColor_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_CameraFrontEnd */ 
