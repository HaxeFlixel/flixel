#ifndef INCLUDED_flixel_tweens_FlxEase
#define INCLUDED_flixel_tweens_FlxEase

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,tweens,FlxEase)
namespace flixel{
namespace tweens{


class HXCPP_CLASS_ATTRIBUTES  FlxEase_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxEase_obj OBJ_;
		FlxEase_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxEase_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxEase_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxEase"); }

		static Float PI2;
		static Float EL;
		static Float B1;
		static Float B2;
		static Float B3;
		static Float B4;
		static Float B5;
		static Float B6;
		static Float ELASTIC_AMPLITUDE;
		static Float ELASTIC_PERIOD;
		static Float quadIn( Float t);
		static Dynamic quadIn_dyn();

		static Float quadOut( Float t);
		static Dynamic quadOut_dyn();

		static Float quadInOut( Float t);
		static Dynamic quadInOut_dyn();

		static Float cubeIn( Float t);
		static Dynamic cubeIn_dyn();

		static Float cubeOut( Float t);
		static Dynamic cubeOut_dyn();

		static Float cubeInOut( Float t);
		static Dynamic cubeInOut_dyn();

		static Float quartIn( Float t);
		static Dynamic quartIn_dyn();

		static Float quartOut( Float t);
		static Dynamic quartOut_dyn();

		static Float quartInOut( Float t);
		static Dynamic quartInOut_dyn();

		static Float quintIn( Float t);
		static Dynamic quintIn_dyn();

		static Float quintOut( Float t);
		static Dynamic quintOut_dyn();

		static Float quintInOut( Float t);
		static Dynamic quintInOut_dyn();

		static Float sineIn( Float t);
		static Dynamic sineIn_dyn();

		static Float sineOut( Float t);
		static Dynamic sineOut_dyn();

		static Float sineInOut( Float t);
		static Dynamic sineInOut_dyn();

		static Float bounceIn( Float t);
		static Dynamic bounceIn_dyn();

		static Float bounceOut( Float t);
		static Dynamic bounceOut_dyn();

		static Float bounceInOut( Float t);
		static Dynamic bounceInOut_dyn();

		static Float circIn( Float t);
		static Dynamic circIn_dyn();

		static Float circOut( Float t);
		static Dynamic circOut_dyn();

		static Float circInOut( Float t);
		static Dynamic circInOut_dyn();

		static Float expoIn( Float t);
		static Dynamic expoIn_dyn();

		static Float expoOut( Float t);
		static Dynamic expoOut_dyn();

		static Float expoInOut( Float t);
		static Dynamic expoInOut_dyn();

		static Float backIn( Float t);
		static Dynamic backIn_dyn();

		static Float backOut( Float t);
		static Dynamic backOut_dyn();

		static Float backInOut( Float t);
		static Dynamic backInOut_dyn();

		static Float elasticIn( Float t);
		static Dynamic elasticIn_dyn();

		static Float elasticOut( Float t);
		static Dynamic elasticOut_dyn();

		static Float elasticInOut( Float t);
		static Dynamic elasticInOut_dyn();

};

} // end namespace flixel
} // end namespace tweens

#endif /* INCLUDED_flixel_tweens_FlxEase */ 
