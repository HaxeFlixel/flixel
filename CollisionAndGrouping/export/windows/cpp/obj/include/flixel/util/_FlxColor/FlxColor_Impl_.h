#ifndef INCLUDED_flixel_util__FlxColor_FlxColor_Impl_
#define INCLUDED_flixel_util__FlxColor_FlxColor_Impl_

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(EReg)
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS3(flixel,util,_FlxColor,FlxColor_Impl_)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
namespace flixel{
namespace util{
namespace _FlxColor{


class HXCPP_CLASS_ATTRIBUTES  FlxColor_Impl__obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxColor_Impl__obj OBJ_;
		FlxColor_Impl__obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxColor_Impl__obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxColor_Impl__obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxColor_Impl_"); }

		static int TRANSPARENT;
		static int WHITE;
		static int GRAY;
		static int BLACK;
		static int GREEN;
		static int LIME;
		static int YELLOW;
		static int ORANGE;
		static int RED;
		static int PURPLE;
		static int BLUE;
		static int BROWN;
		static int PINK;
		static int MAGENTA;
		static int CYAN;
		static ::haxe::ds::StringMap colorLookup;
		static ::EReg COLOR_REGEX;
		static int fromInt( int Value);
		static Dynamic fromInt_dyn();

		static int fromRGB( int Red,int Green,int Blue,hx::Null< int >  Alpha);
		static Dynamic fromRGB_dyn();

		static int fromRGBFloat( Float Red,Float Green,Float Blue,hx::Null< Float >  Alpha);
		static Dynamic fromRGBFloat_dyn();

		static int fromCMYK( Float Cyan,Float Magenta,Float Yellow,Float Black,hx::Null< Float >  Alpha);
		static Dynamic fromCMYK_dyn();

		static int fromHSB( Float Hue,Float Saturation,Float Brightness,hx::Null< Float >  Alpha);
		static Dynamic fromHSB_dyn();

		static int fromHSL( Float Hue,Float Saturation,Float Lightness,hx::Null< Float >  Alpha);
		static Dynamic fromHSL_dyn();

		static Dynamic fromString( ::String str);
		static Dynamic fromString_dyn();

		static Array< int > getHSBColorWheel( hx::Null< int >  Alpha);
		static Dynamic getHSBColorWheel_dyn();

		static int interpolate( int Color1,int Color2,hx::Null< Float >  Factor);
		static Dynamic interpolate_dyn();

		static Array< int > gradient( int Color1,int Color2,int Steps,Dynamic Ease);
		static Dynamic gradient_dyn();

		static int multiply( int lhs,int rhs);
		static Dynamic multiply_dyn();

		static int add( int lhs,int rhs);
		static Dynamic add_dyn();

		static int subtract( int lhs,int rhs);
		static Dynamic subtract_dyn();

		static int getComplementHarmony( int this1);
		static Dynamic getComplementHarmony_dyn();

		static Dynamic getAnalogousHarmony( int this1,hx::Null< int >  Threshold);
		static Dynamic getAnalogousHarmony_dyn();

		static Dynamic getSplitComplementHarmony( int this1,hx::Null< int >  Threshold);
		static Dynamic getSplitComplementHarmony_dyn();

		static Dynamic getTriadicHarmony( int this1);
		static Dynamic getTriadicHarmony_dyn();

		static int to24Bit( int this1);
		static Dynamic to24Bit_dyn();

		static ::String toHexString( int this1,hx::Null< bool >  Alpha,hx::Null< bool >  Prefix);
		static Dynamic toHexString_dyn();

		static ::String toWebString( int this1);
		static Dynamic toWebString_dyn();

		static ::String getColorInfo( int this1);
		static Dynamic getColorInfo_dyn();

		static int getDarkened( int this1,hx::Null< Float >  Factor);
		static Dynamic getDarkened_dyn();

		static int getLightened( int this1,hx::Null< Float >  Factor);
		static Dynamic getLightened_dyn();

		static int getInverted( int this1);
		static Dynamic getInverted_dyn();

		static int setRGB( int this1,int Red,int Green,int Blue,hx::Null< int >  Alpha);
		static Dynamic setRGB_dyn();

		static int setRGBFloat( int this1,Float Red,Float Green,Float Blue,hx::Null< Float >  Alpha);
		static Dynamic setRGBFloat_dyn();

		static int setCMYK( int this1,Float Cyan,Float Magenta,Float Yellow,Float Black,hx::Null< Float >  Alpha);
		static Dynamic setCMYK_dyn();

		static int setHSB( int this1,Float Hue,Float Saturation,Float Brightness,Float Alpha);
		static Dynamic setHSB_dyn();

		static int setHSL( int this1,Float Hue,Float Saturation,Float Lightness,Float Alpha);
		static Dynamic setHSL_dyn();

		static int setHSChromaMatch( int this1,Float Hue,Float Saturation,Float Chroma,Float Match,Float Alpha);
		static Dynamic setHSChromaMatch_dyn();

		static int _new( hx::Null< int >  Value);
		static Dynamic _new_dyn();

		static int get_red( int this1);
		static Dynamic get_red_dyn();

		static int get_green( int this1);
		static Dynamic get_green_dyn();

		static int get_blue( int this1);
		static Dynamic get_blue_dyn();

		static int get_alpha( int this1);
		static Dynamic get_alpha_dyn();

		static Float get_redFloat( int this1);
		static Dynamic get_redFloat_dyn();

		static Float get_greenFloat( int this1);
		static Dynamic get_greenFloat_dyn();

		static Float get_blueFloat( int this1);
		static Dynamic get_blueFloat_dyn();

		static Float get_alphaFloat( int this1);
		static Dynamic get_alphaFloat_dyn();

		static int set_red( int this1,int Value);
		static Dynamic set_red_dyn();

		static int set_green( int this1,int Value);
		static Dynamic set_green_dyn();

		static int set_blue( int this1,int Value);
		static Dynamic set_blue_dyn();

		static int set_alpha( int this1,int Value);
		static Dynamic set_alpha_dyn();

		static Float set_redFloat( int this1,Float Value);
		static Dynamic set_redFloat_dyn();

		static Float set_greenFloat( int this1,Float Value);
		static Dynamic set_greenFloat_dyn();

		static Float set_blueFloat( int this1,Float Value);
		static Dynamic set_blueFloat_dyn();

		static Float set_alphaFloat( int this1,Float Value);
		static Dynamic set_alphaFloat_dyn();

		static Float get_cyan( int this1);
		static Dynamic get_cyan_dyn();

		static Float get_magenta( int this1);
		static Dynamic get_magenta_dyn();

		static Float get_yellow( int this1);
		static Dynamic get_yellow_dyn();

		static Float get_black( int this1);
		static Dynamic get_black_dyn();

		static Float set_cyan( int this1,Float Value);
		static Dynamic set_cyan_dyn();

		static Float set_magenta( int this1,Float Value);
		static Dynamic set_magenta_dyn();

		static Float set_yellow( int this1,Float Value);
		static Dynamic set_yellow_dyn();

		static Float set_black( int this1,Float Value);
		static Dynamic set_black_dyn();

		static Float get_hue( int this1);
		static Dynamic get_hue_dyn();

		static Float get_brightness( int this1);
		static Dynamic get_brightness_dyn();

		static Float get_saturation( int this1);
		static Dynamic get_saturation_dyn();

		static Float get_lightness( int this1);
		static Dynamic get_lightness_dyn();

		static Float set_hue( int this1,Float Value);
		static Dynamic set_hue_dyn();

		static Float set_saturation( int this1,Float Value);
		static Dynamic set_saturation_dyn();

		static Float set_brightness( int this1,Float Value);
		static Dynamic set_brightness_dyn();

		static Float set_lightness( int this1,Float Value);
		static Dynamic set_lightness_dyn();

		static Float maxColor( int this1);
		static Dynamic maxColor_dyn();

		static Float minColor( int this1);
		static Dynamic minColor_dyn();

		static int boundChannel( int this1,int Value);
		static Dynamic boundChannel_dyn();

		static bool equal( Dynamic lhs,Dynamic rhs);
		static Dynamic equal_dyn();

		static bool notEqual( Dynamic lhs,Dynamic rhs);
		static Dynamic notEqual_dyn();

};

} // end namespace flixel
} // end namespace util
} // end namespace _FlxColor

#endif /* INCLUDED_flixel_util__FlxColor_FlxColor_Impl_ */ 
