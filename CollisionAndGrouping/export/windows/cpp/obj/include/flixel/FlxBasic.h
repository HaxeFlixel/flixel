#ifndef INCLUDED_flixel_FlxBasic
#define INCLUDED_flixel_FlxBasic

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{


class HXCPP_CLASS_ATTRIBUTES  FlxBasic_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxBasic_obj OBJ_;
		FlxBasic_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxBasic_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxBasic_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxBasic_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxBasic"); }

		int ID;
		bool active;
		bool visible;
		bool alive;
		bool exists;
		int flixelType;
		Array< ::Dynamic > _cameras;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void kill( );
		Dynamic kill_dyn();

		virtual Void revive( );
		Dynamic revive_dyn();

		virtual Void update( Float elapsed);
		Dynamic update_dyn();

		virtual Void draw( );
		Dynamic draw_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual bool set_visible( bool Value);
		Dynamic set_visible_dyn();

		virtual bool set_active( bool Value);
		Dynamic set_active_dyn();

		virtual bool set_exists( bool Value);
		Dynamic set_exists_dyn();

		virtual bool set_alive( bool Value);
		Dynamic set_alive_dyn();

		virtual ::flixel::FlxCamera get_camera( );
		Dynamic get_camera_dyn();

		virtual ::flixel::FlxCamera set_camera( ::flixel::FlxCamera Value);
		Dynamic set_camera_dyn();

		virtual Array< ::Dynamic > get_cameras( );
		Dynamic get_cameras_dyn();

		virtual Array< ::Dynamic > set_cameras( Array< ::Dynamic > Value);
		Dynamic set_cameras_dyn();

		static int activeCount;
		static int visibleCount;
};

} // end namespace flixel

#endif /* INCLUDED_flixel_FlxBasic */ 
