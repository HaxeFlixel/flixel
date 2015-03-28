#ifndef INCLUDED_flixel__FlxSprite_GraphicDefault
#define INCLUDED_flixel__FlxSprite_GraphicDefault

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/BitmapData.h>
HX_DECLARE_CLASS2(flixel,_FlxSprite,GraphicDefault)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace _FlxSprite{


class HXCPP_CLASS_ATTRIBUTES  GraphicDefault_obj : public ::openfl::_v2::display::BitmapData_obj{
	public:
		typedef ::openfl::_v2::display::BitmapData_obj super;
		typedef GraphicDefault_obj OBJ_;
		GraphicDefault_obj();
		Void __construct(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GraphicDefault_obj > __new(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GraphicDefault_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("GraphicDefault"); }

		static ::String resourceName;
};

} // end namespace flixel
} // end namespace _FlxSprite

#endif /* INCLUDED_flixel__FlxSprite_GraphicDefault */ 
