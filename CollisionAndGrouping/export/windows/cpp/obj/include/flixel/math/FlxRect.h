#ifndef INCLUDED_flixel_math_FlxRect
#define INCLUDED_flixel_math_FlxRect

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxPooled.h>
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,FlxPool_flixel_math_FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace flixel{
namespace math{


class HXCPP_CLASS_ATTRIBUTES  FlxRect_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxRect_obj OBJ_;
		FlxRect_obj();
		Void __construct(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,hx::Null< Float >  __o_Width,hx::Null< Float >  __o_Height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxRect_obj > __new(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,hx::Null< Float >  __o_Width,hx::Null< Float >  __o_Height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxRect_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		inline operator ::flixel::util::IFlxPooled_obj *()
			{ return new ::flixel::util::IFlxPooled_delegate_< FlxRect_obj >(this); }
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxRect_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxRect"); }

		Float x;
		Float y;
		Float width;
		Float height;
		bool _weak;
		bool _inPool;
		virtual Void put( );
		Dynamic put_dyn();

		virtual Void putWeak( );
		Dynamic putWeak_dyn();

		virtual ::flixel::math::FlxRect setSize( Float Width,Float Height);
		Dynamic setSize_dyn();

		virtual ::flixel::math::FlxRect setPosition( Float x,Float y);
		Dynamic setPosition_dyn();

		virtual ::flixel::math::FlxRect set( hx::Null< Float >  X,hx::Null< Float >  Y,hx::Null< Float >  Width,hx::Null< Float >  Height);
		Dynamic set_dyn();

		virtual ::flixel::math::FlxRect copyFrom( ::flixel::math::FlxRect Rect);
		Dynamic copyFrom_dyn();

		virtual ::flixel::math::FlxRect copyTo( ::flixel::math::FlxRect Rect);
		Dynamic copyTo_dyn();

		virtual ::flixel::math::FlxRect copyFromFlash( ::openfl::_v2::geom::Rectangle FlashRect);
		Dynamic copyFromFlash_dyn();

		virtual ::openfl::_v2::geom::Rectangle copyToFlash( ::openfl::_v2::geom::Rectangle FlashRect);
		Dynamic copyToFlash_dyn();

		virtual bool overlaps( ::flixel::math::FlxRect Rect);
		Dynamic overlaps_dyn();

		virtual bool containsFlxPoint( ::flixel::math::FlxPoint Point);
		Dynamic containsFlxPoint_dyn();

		virtual ::flixel::math::FlxRect _union( ::flixel::math::FlxRect Rect);
		Dynamic _union_dyn();

		virtual ::flixel::math::FlxRect floor( );
		Dynamic floor_dyn();

		virtual ::flixel::math::FlxRect ceil( );
		Dynamic ceil_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual bool equals( ::flixel::math::FlxRect rect);
		Dynamic equals_dyn();

		virtual ::flixel::math::FlxRect intersection( ::flixel::math::FlxRect rect);
		Dynamic intersection_dyn();

		virtual Float get_left( );
		Dynamic get_left_dyn();

		virtual Float set_left( Float Value);
		Dynamic set_left_dyn();

		virtual Float get_right( );
		Dynamic get_right_dyn();

		virtual Float set_right( Float Value);
		Dynamic set_right_dyn();

		virtual Float get_top( );
		Dynamic get_top_dyn();

		virtual Float set_top( Float Value);
		Dynamic set_top_dyn();

		virtual Float get_bottom( );
		Dynamic get_bottom_dyn();

		virtual Float set_bottom( Float Value);
		Dynamic set_bottom_dyn();

		static ::flixel::math::FlxRect flxRect;
		static ::openfl::_v2::geom::Rectangle rect;
		static ::flixel::util::FlxPool_flixel_math_FlxRect _pool;
		static ::flixel::math::FlxRect get( hx::Null< Float >  X,hx::Null< Float >  Y,hx::Null< Float >  Width,hx::Null< Float >  Height);
		static Dynamic get_dyn();

		static ::flixel::math::FlxRect weak( hx::Null< Float >  X,hx::Null< Float >  Y,hx::Null< Float >  Width,hx::Null< Float >  Height);
		static Dynamic weak_dyn();

};

} // end namespace flixel
} // end namespace math

#endif /* INCLUDED_flixel_math_FlxRect */ 
