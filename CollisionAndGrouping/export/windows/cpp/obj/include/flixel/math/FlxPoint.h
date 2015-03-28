#ifndef INCLUDED_flixel_math_FlxPoint
#define INCLUDED_flixel_math_FlxPoint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxPooled.h>
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,FlxPool_flixel_math_FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
namespace flixel{
namespace math{


class HXCPP_CLASS_ATTRIBUTES  FlxPoint_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxPoint_obj OBJ_;
		FlxPoint_obj();
		Void __construct(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxPoint_obj > __new(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxPoint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		inline operator ::flixel::util::IFlxPooled_obj *()
			{ return new ::flixel::util::IFlxPooled_delegate_< FlxPoint_obj >(this); }
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxPoint_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxPoint"); }

		Float x;
		Float y;
		bool _weak;
		bool _inPool;
		virtual Void put( );
		Dynamic put_dyn();

		virtual Void putWeak( );
		Dynamic putWeak_dyn();

		virtual ::flixel::math::FlxPoint set( hx::Null< Float >  X,hx::Null< Float >  Y);
		Dynamic set_dyn();

		virtual ::flixel::math::FlxPoint add( hx::Null< Float >  X,hx::Null< Float >  Y);
		Dynamic add_dyn();

		virtual ::flixel::math::FlxPoint addPoint( ::flixel::math::FlxPoint point);
		Dynamic addPoint_dyn();

		virtual ::flixel::math::FlxPoint subtract( hx::Null< Float >  X,hx::Null< Float >  Y);
		Dynamic subtract_dyn();

		virtual ::flixel::math::FlxPoint subtractPoint( ::flixel::math::FlxPoint point);
		Dynamic subtractPoint_dyn();

		virtual ::flixel::math::FlxPoint copyFrom( ::flixel::math::FlxPoint point);
		Dynamic copyFrom_dyn();

		virtual ::flixel::math::FlxPoint copyTo( ::flixel::math::FlxPoint point);
		Dynamic copyTo_dyn();

		virtual ::flixel::math::FlxPoint copyFromFlash( ::openfl::_v2::geom::Point FlashPoint);
		Dynamic copyFromFlash_dyn();

		virtual ::openfl::_v2::geom::Point copyToFlash( ::openfl::_v2::geom::Point FlashPoint);
		Dynamic copyToFlash_dyn();

		virtual bool inCoords( Float RectX,Float RectY,Float RectWidth,Float RectHeight);
		Dynamic inCoords_dyn();

		virtual bool inFlxRect( ::flixel::math::FlxRect Rect);
		Dynamic inFlxRect_dyn();

		virtual Float distanceTo( ::flixel::math::FlxPoint AnotherPoint);
		Dynamic distanceTo_dyn();

		virtual ::flixel::math::FlxPoint floor( );
		Dynamic floor_dyn();

		virtual ::flixel::math::FlxPoint ceil( );
		Dynamic ceil_dyn();

		virtual ::flixel::math::FlxPoint rotate( ::flixel::math::FlxPoint Pivot,Float Angle);
		Dynamic rotate_dyn();

		virtual Float angleBetween( ::flixel::math::FlxPoint point);
		Dynamic angleBetween_dyn();

		virtual bool equals( ::flixel::math::FlxPoint point);
		Dynamic equals_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::flixel::math::FlxPoint transform( ::openfl::_v2::geom::Matrix matrix);
		Dynamic transform_dyn();

		virtual Float set_x( Float Value);
		Dynamic set_x_dyn();

		virtual Float set_y( Float Value);
		Dynamic set_y_dyn();

		static ::flixel::math::FlxPoint flxPoint;
		static ::openfl::_v2::geom::Point point;
		static ::flixel::util::FlxPool_flixel_math_FlxPoint _pool;
		static ::flixel::math::FlxPoint get( hx::Null< Float >  X,hx::Null< Float >  Y);
		static Dynamic get_dyn();

		static ::flixel::math::FlxPoint weak( hx::Null< Float >  X,hx::Null< Float >  Y);
		static Dynamic weak_dyn();

};

} // end namespace flixel
} // end namespace math

#endif /* INCLUDED_flixel_math_FlxPoint */ 
