#ifndef INCLUDED_flixel_system_scaleModes_BaseScaleMode
#define INCLUDED_flixel_system_scaleModes_BaseScaleMode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS3(flixel,system,scaleModes,BaseScaleMode)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace system{
namespace scaleModes{


class HXCPP_CLASS_ATTRIBUTES  BaseScaleMode_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BaseScaleMode_obj OBJ_;
		BaseScaleMode_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BaseScaleMode_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BaseScaleMode_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("BaseScaleMode"); }

		::flixel::math::FlxPoint deviceSize;
		::flixel::math::FlxPoint gameSize;
		::flixel::math::FlxPoint scale;
		::flixel::math::FlxPoint offset;
		virtual Void onMeasure( int Width,int Height);
		Dynamic onMeasure_dyn();

		virtual Void updateGameSize( int Width,int Height);
		Dynamic updateGameSize_dyn();

		virtual Void updateDeviceSize( int Width,int Height);
		Dynamic updateDeviceSize_dyn();

		virtual Void updateScaleOffset( );
		Dynamic updateScaleOffset_dyn();

		virtual Void updateGamePosition( );
		Dynamic updateGamePosition_dyn();

		static int gWidth;
		static int gHeight;
		static ::flixel::math::FlxPoint zoom;
};

} // end namespace flixel
} // end namespace system
} // end namespace scaleModes

#endif /* INCLUDED_flixel_system_scaleModes_BaseScaleMode */ 
