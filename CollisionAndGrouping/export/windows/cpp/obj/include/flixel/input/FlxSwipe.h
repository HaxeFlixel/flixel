#ifndef INCLUDED_flixel_input_FlxSwipe
#define INCLUDED_flixel_input_FlxSwipe

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,input,FlxSwipe)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace input{


class HXCPP_CLASS_ATTRIBUTES  FlxSwipe_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxSwipe_obj OBJ_;
		FlxSwipe_obj();
		Void __construct(int ID,::flixel::math::FlxPoint StartPosition,::flixel::math::FlxPoint EndPosition,Float StartTimeInTicks);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxSwipe_obj > __new(int ID,::flixel::math::FlxPoint StartPosition,::flixel::math::FlxPoint EndPosition,Float StartTimeInTicks);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxSwipe_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxSwipe"); }

		int ID;
		::flixel::math::FlxPoint startPosition;
		::flixel::math::FlxPoint endPosition;
		Float _startTimeInTicks;
		Float _endTimeInTicks;
		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual Float get_distance( );
		Dynamic get_distance_dyn();

		virtual Float get_angle( );
		Dynamic get_angle_dyn();

		virtual Float get_duration( );
		Dynamic get_duration_dyn();

};

} // end namespace flixel
} // end namespace input

#endif /* INCLUDED_flixel_input_FlxSwipe */ 
