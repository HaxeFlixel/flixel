#ifndef INCLUDED_flixel_tweens_motion_QuadPath
#define INCLUDED_flixel_tweens_motion_QuadPath

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/tweens/motion/Motion.h>
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,tweens,FlxTween)
HX_DECLARE_CLASS3(flixel,tweens,motion,Motion)
HX_DECLARE_CLASS3(flixel,tweens,motion,QuadPath)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace tweens{
namespace motion{


class HXCPP_CLASS_ATTRIBUTES  QuadPath_obj : public ::flixel::tweens::motion::Motion_obj{
	public:
		typedef ::flixel::tweens::motion::Motion_obj super;
		typedef QuadPath_obj OBJ_;
		QuadPath_obj();
		Void __construct(Dynamic Options);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< QuadPath_obj > __new(Dynamic Options);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~QuadPath_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("QuadPath"); }

		Array< ::Dynamic > _points;
		Float _distance;
		Float _speed;
		int _index;
		int _numSegs;
		bool _updateCurve;
		Array< Float > _curveT;
		Array< Float > _curveD;
		::flixel::math::FlxPoint _a;
		::flixel::math::FlxPoint _b;
		::flixel::math::FlxPoint _c;
		virtual Void destroy( );

		virtual ::flixel::tweens::motion::QuadPath setMotion( Float DurationOrSpeed,hx::Null< bool >  UseDuration);
		Dynamic setMotion_dyn();

		virtual ::flixel::tweens::motion::QuadPath addPoint( hx::Null< Float >  x,hx::Null< Float >  y);
		Dynamic addPoint_dyn();

		virtual ::flixel::math::FlxPoint getPoint( hx::Null< int >  index);
		Dynamic getPoint_dyn();

		virtual ::flixel::tweens::FlxTween start( );

		virtual Void update( Float elapsed);

		virtual Void updatePath( );
		Dynamic updatePath_dyn();

		virtual Float getCurveLength( ::flixel::math::FlxPoint start,::flixel::math::FlxPoint control,::flixel::math::FlxPoint finish);
		Dynamic getCurveLength_dyn();

};

} // end namespace flixel
} // end namespace tweens
} // end namespace motion

#endif /* INCLUDED_flixel_tweens_motion_QuadPath */ 
