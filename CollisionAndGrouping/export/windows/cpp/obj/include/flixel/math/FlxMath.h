#ifndef INCLUDED_flixel_math_FlxMath
#define INCLUDED_flixel_math_FlxMath

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS2(flixel,math,FlxMath)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace flixel{
namespace math{


class HXCPP_CLASS_ATTRIBUTES  FlxMath_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxMath_obj OBJ_;
		FlxMath_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxMath_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxMath_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxMath"); }

		static Float MIN_VALUE_FLOAT;
		static Float MAX_VALUE_FLOAT;
		static int MIN_VALUE_INT;
		static int MAX_VALUE_INT;
		static Float SQUARE_ROOT_OF_TWO;
		static Float EPSILON;
		static Float roundDecimal( Float Value,int Precision);
		static Dynamic roundDecimal_dyn();

		static Float bound( Float Value,Dynamic Min,Dynamic Max);
		static Dynamic bound_dyn();

		static Float lerp( Float Min,Float Max,Float Ratio);
		static Dynamic lerp_dyn();

		static bool inBounds( Float Value,Dynamic Min,Dynamic Max);
		static Dynamic inBounds_dyn();

		static bool isOdd( Float n);
		static Dynamic isOdd_dyn();

		static bool isEven( Float n);
		static Dynamic isEven_dyn();

		static int numericComparison( Float num1,Float num2);
		static Dynamic numericComparison_dyn();

		static bool pointInCoordinates( Float pointX,Float pointY,Float rectX,Float rectY,Float rectWidth,Float rectHeight);
		static Dynamic pointInCoordinates_dyn();

		static bool pointInFlxRect( Float pointX,Float pointY,::flixel::math::FlxRect rect);
		static Dynamic pointInFlxRect_dyn();

		static bool mouseInFlxRect( bool useWorldCoords,::flixel::math::FlxRect rect);
		static Dynamic mouseInFlxRect_dyn();

		static bool pointInRectangle( Float pointX,Float pointY,::openfl::_v2::geom::Rectangle rect);
		static Dynamic pointInRectangle_dyn();

		static int maxAdd( int value,int amount,int max,hx::Null< int >  min);
		static Dynamic maxAdd_dyn();

		static int wrapValue( int value,int amount,int max);
		static Dynamic wrapValue_dyn();

		static Float dotProduct( Float ax,Float ay,Float bx,Float by);
		static Dynamic dotProduct_dyn();

		static Float vectorLength( Float dx,Float dy);
		static Dynamic vectorLength_dyn();

		static Float getDistance( ::flixel::math::FlxPoint Point1,::flixel::math::FlxPoint Point2);
		static Dynamic getDistance_dyn();

		static int distanceBetween( ::flixel::FlxSprite SpriteA,::flixel::FlxSprite SpriteB);
		static Dynamic distanceBetween_dyn();

		static bool isDistanceWithin( ::flixel::FlxSprite SpriteA,::flixel::FlxSprite SpriteB,Float Distance,hx::Null< bool >  IncludeEqual);
		static Dynamic isDistanceWithin_dyn();

		static int distanceToPoint( ::flixel::FlxSprite Sprite,::flixel::math::FlxPoint Target);
		static Dynamic distanceToPoint_dyn();

		static bool isDistanceToPointWithin( ::flixel::FlxSprite Sprite,::flixel::math::FlxPoint Target,Float Distance,hx::Null< bool >  IncludeEqual);
		static Dynamic isDistanceToPointWithin_dyn();

		static int distanceToMouse( ::flixel::FlxSprite Sprite);
		static Dynamic distanceToMouse_dyn();

		static bool isDistanceToMouseWithin( ::flixel::FlxSprite Sprite,Float Distance,hx::Null< bool >  IncludeEqual);
		static Dynamic isDistanceToMouseWithin_dyn();

		static int getDecimals( Float Number);
		static Dynamic getDecimals_dyn();

		static bool equal( Float aValueA,Float aValueB,hx::Null< Float >  aDiff);
		static Dynamic equal_dyn();

		static int signOf( Float f);
		static Dynamic signOf_dyn();

		static bool sameSign( Float f1,Float f2);
		static Dynamic sameSign_dyn();

		static Float sinh( Float f);
		static Dynamic sinh_dyn();

		static int maxInt( int a,int b);
		static Dynamic maxInt_dyn();

		static int minInt( int a,int b);
		static Dynamic minInt_dyn();

		static int absInt( int a);
		static Dynamic absInt_dyn();

};

} // end namespace flixel
} // end namespace math

#endif /* INCLUDED_flixel_math_FlxMath */ 
