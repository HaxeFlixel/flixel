#ifndef INCLUDED_flixel_math_FlxVector
#define INCLUDED_flixel_math_FlxVector

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/math/FlxPoint.h>
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxVector)
HX_DECLARE_CLASS2(flixel,util,FlxPool_flixel_math_FlxVector)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace math{


class HXCPP_CLASS_ATTRIBUTES  FlxVector_obj : public ::flixel::math::FlxPoint_obj{
	public:
		typedef ::flixel::math::FlxPoint_obj super;
		typedef FlxVector_obj OBJ_;
		FlxVector_obj();
		Void __construct(Dynamic X,Dynamic Y);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxVector_obj > __new(Dynamic X,Dynamic Y);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxVector_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxVector"); }

		virtual Void put( );

		virtual ::flixel::math::FlxPoint set( hx::Null< Float >  X,hx::Null< Float >  Y);

		virtual ::flixel::math::FlxVector scale( Float k);
		Dynamic scale_dyn();

		virtual ::flixel::math::FlxVector scaleNew( Float k);
		Dynamic scaleNew_dyn();

		virtual ::flixel::math::FlxVector addNew( ::flixel::math::FlxVector v);
		Dynamic addNew_dyn();

		virtual ::flixel::math::FlxVector subtractNew( ::flixel::math::FlxVector v);
		Dynamic subtractNew_dyn();

		virtual Float dotProduct( ::flixel::math::FlxVector v);
		Dynamic dotProduct_dyn();

		virtual Float dotProdWithNormalizing( ::flixel::math::FlxVector v);
		Dynamic dotProdWithNormalizing_dyn();

		virtual bool isPerpendicular( ::flixel::math::FlxVector v);
		Dynamic isPerpendicular_dyn();

		virtual Float crossProductLength( ::flixel::math::FlxVector v);
		Dynamic crossProductLength_dyn();

		virtual bool isParallel( ::flixel::math::FlxVector v);
		Dynamic isParallel_dyn();

		virtual bool isZero( );
		Dynamic isZero_dyn();

		virtual ::flixel::math::FlxVector zero( );
		Dynamic zero_dyn();

		virtual ::flixel::math::FlxVector normalize( );
		Dynamic normalize_dyn();

		virtual bool isNormalized( );
		Dynamic isNormalized_dyn();

		virtual ::flixel::math::FlxVector rotateByRadians( Float rads);
		Dynamic rotateByRadians_dyn();

		virtual ::flixel::math::FlxVector rotateByDegrees( Float degs);
		Dynamic rotateByDegrees_dyn();

		virtual ::flixel::math::FlxVector rotateWithTrig( Float sin,Float cos);
		Dynamic rotateWithTrig_dyn();

		virtual ::flixel::math::FlxVector rightNormal( ::flixel::math::FlxVector vec);
		Dynamic rightNormal_dyn();

		virtual ::flixel::math::FlxVector leftNormal( ::flixel::math::FlxVector vec);
		Dynamic leftNormal_dyn();

		virtual ::flixel::math::FlxVector negate( );
		Dynamic negate_dyn();

		virtual ::flixel::math::FlxVector negateNew( );
		Dynamic negateNew_dyn();

		virtual ::flixel::math::FlxVector projectTo( ::flixel::math::FlxVector v,::flixel::math::FlxVector proj);
		Dynamic projectTo_dyn();

		virtual ::flixel::math::FlxVector projectToNormalized( ::flixel::math::FlxVector v,::flixel::math::FlxVector proj);
		Dynamic projectToNormalized_dyn();

		virtual Float perpProduct( ::flixel::math::FlxVector v);
		Dynamic perpProduct_dyn();

		virtual Float ratio( ::flixel::math::FlxVector a,::flixel::math::FlxVector b,::flixel::math::FlxVector v);
		Dynamic ratio_dyn();

		virtual ::flixel::math::FlxVector findIntersection( ::flixel::math::FlxVector a,::flixel::math::FlxVector b,::flixel::math::FlxVector v,::flixel::math::FlxVector intersection);
		Dynamic findIntersection_dyn();

		virtual ::flixel::math::FlxVector findIntersectionInBounds( ::flixel::math::FlxVector a,::flixel::math::FlxVector b,::flixel::math::FlxVector v,::flixel::math::FlxVector intersection);
		Dynamic findIntersectionInBounds_dyn();

		virtual ::flixel::math::FlxVector truncate( Float max);
		Dynamic truncate_dyn();

		virtual Float radiansBetween( ::flixel::math::FlxVector v);
		Dynamic radiansBetween_dyn();

		virtual Float degreesBetween( ::flixel::math::FlxVector v);
		Dynamic degreesBetween_dyn();

		virtual int sign( ::flixel::math::FlxVector a,::flixel::math::FlxVector b);
		Dynamic sign_dyn();

		virtual Float dist( ::flixel::math::FlxVector v);
		Dynamic dist_dyn();

		virtual Float distSquared( ::flixel::math::FlxVector v);
		Dynamic distSquared_dyn();

		virtual ::flixel::math::FlxVector bounce( ::flixel::math::FlxVector normal,hx::Null< Float >  bounceCoeff);
		Dynamic bounce_dyn();

		virtual ::flixel::math::FlxVector bounceWithFriction( ::flixel::math::FlxVector normal,hx::Null< Float >  bounceCoeff,hx::Null< Float >  friction);
		Dynamic bounceWithFriction_dyn();

		virtual bool isValid( );
		Dynamic isValid_dyn();

		virtual ::flixel::math::FlxVector clone( ::flixel::math::FlxVector vec);
		Dynamic clone_dyn();

		virtual ::flixel::math::FlxVector addVector( ::flixel::math::FlxVector vec);
		Dynamic addVector_dyn();

		virtual Float get_dx( );
		Dynamic get_dx_dyn();

		virtual Float get_dy( );
		Dynamic get_dy_dyn();

		virtual Float get_length( );
		Dynamic get_length_dyn();

		virtual Float set_length( Float l);
		Dynamic set_length_dyn();

		virtual Float get_lengthSquared( );
		Dynamic get_lengthSquared_dyn();

		virtual Float get_degrees( );
		Dynamic get_degrees_dyn();

		virtual Float set_degrees( Float degs);
		Dynamic set_degrees_dyn();

		virtual Float get_radians( );
		Dynamic get_radians_dyn();

		virtual Float set_radians( Float rads);
		Dynamic set_radians_dyn();

		virtual Float get_rx( );
		Dynamic get_rx_dyn();

		virtual Float get_ry( );
		Dynamic get_ry_dyn();

		virtual Float get_lx( );
		Dynamic get_lx_dyn();

		virtual Float get_ly( );
		Dynamic get_ly_dyn();

		static Float EPSILON;
		static Float EPSILON_SQUARED;
		static ::flixel::util::FlxPool_flixel_math_FlxVector _pool;
		static ::flixel::math::FlxVector _vector1;
		static ::flixel::math::FlxVector _vector2;
		static ::flixel::math::FlxVector _vector3;
		static ::flixel::math::FlxVector get( hx::Null< Float >  X,hx::Null< Float >  Y);
		static Dynamic get_dyn();

};

} // end namespace flixel
} // end namespace math

#endif /* INCLUDED_flixel_math_FlxVector */ 
