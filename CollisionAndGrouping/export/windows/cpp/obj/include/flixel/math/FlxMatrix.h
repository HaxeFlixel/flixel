#ifndef INCLUDED_flixel_math_FlxMatrix
#define INCLUDED_flixel_math_FlxMatrix

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/geom/Matrix.h>
HX_DECLARE_CLASS2(flixel,math,FlxMatrix)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
namespace flixel{
namespace math{


class HXCPP_CLASS_ATTRIBUTES  FlxMatrix_obj : public ::openfl::_v2::geom::Matrix_obj{
	public:
		typedef ::openfl::_v2::geom::Matrix_obj super;
		typedef FlxMatrix_obj OBJ_;
		FlxMatrix_obj();
		Void __construct(hx::Null< Float >  __o_a,hx::Null< Float >  __o_b,hx::Null< Float >  __o_c,hx::Null< Float >  __o_d,hx::Null< Float >  __o_tx,hx::Null< Float >  __o_ty);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxMatrix_obj > __new(hx::Null< Float >  __o_a,hx::Null< Float >  __o_b,hx::Null< Float >  __o_c,hx::Null< Float >  __o_d,hx::Null< Float >  __o_tx,hx::Null< Float >  __o_ty);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxMatrix_obj();

		HX_DO_RTTI;
		double __INumField(int inFieldID);
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxMatrix"); }

		virtual ::flixel::math::FlxMatrix rotateWithTrig( Float cos,Float sin);
		Dynamic rotateWithTrig_dyn();

		virtual ::flixel::math::FlxMatrix rotateByPositive90( );
		Dynamic rotateByPositive90_dyn();

		virtual ::flixel::math::FlxMatrix rotateByNegative90( );
		Dynamic rotateByNegative90_dyn();

		static ::flixel::math::FlxMatrix matrix;
};

} // end namespace flixel
} // end namespace math

#endif /* INCLUDED_flixel_math_FlxMatrix */ 
