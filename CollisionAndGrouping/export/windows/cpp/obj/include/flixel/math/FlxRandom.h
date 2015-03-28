#ifndef INCLUDED_flixel_math_FlxRandom
#define INCLUDED_flixel_math_FlxRandom

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,math,FlxRandom)
namespace flixel{
namespace math{


class HXCPP_CLASS_ATTRIBUTES  FlxRandom_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxRandom_obj OBJ_;
		FlxRandom_obj();
		Void __construct(Dynamic InitialSeed);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxRandom_obj > __new(Dynamic InitialSeed);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxRandom_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxRandom"); }

		virtual Dynamic getObject_flixel_group_FlxTypedGroup_T( Dynamic Objects,Array< Float > WeightsArray,hx::Null< int >  StartIndex,Dynamic EndIndex);
		Dynamic getObject_flixel_group_FlxTypedGroup_T_dyn();

		int initialSeed;
		virtual int resetInitialSeed( );
		Dynamic resetInitialSeed_dyn();

		virtual int _int( hx::Null< int >  Min,hx::Null< int >  Max,Array< int > Excludes);
		Dynamic _int_dyn();

		virtual Float _float( hx::Null< Float >  Min,hx::Null< Float >  Max,Array< Float > Excludes);
		Dynamic _float_dyn();

		bool _hasFloatNormalSpare;
		Float _floatNormalRand1;
		Float _floatNormalRand2;
		Float _twoPI;
		Float _floatNormalRho;
		virtual Float floatNormal( hx::Null< Float >  Mean,hx::Null< Float >  StdDev);
		Dynamic floatNormal_dyn();

		virtual bool _bool( hx::Null< Float >  Chance);
		Dynamic _bool_dyn();

		virtual int sign( hx::Null< Float >  Chance);
		Dynamic sign_dyn();

		virtual int weightedPick( Array< Float > WeightsArray);
		Dynamic weightedPick_dyn();

		virtual int color( Dynamic Min,Dynamic Max,Dynamic Alpha,hx::Null< bool >  GreyScale);
		Dynamic color_dyn();

		virtual Float generate( );
		Dynamic generate_dyn();

		Float internalSeed;
		virtual int set_initialSeed( int NewSeed);
		Dynamic set_initialSeed_dyn();

		virtual int get_currentSeed( );
		Dynamic get_currentSeed_dyn();

		virtual int set_currentSeed( int NewSeed);
		Dynamic set_currentSeed_dyn();

		static int rangeBound( int Value);
		static Dynamic rangeBound_dyn();

		static Array< Float > _arrayFloatHelper;
		static Float MULTIPLIER;
		static int MODULUS;
};

} // end namespace flixel
} // end namespace math

#endif /* INCLUDED_flixel_math_FlxRandom */ 
