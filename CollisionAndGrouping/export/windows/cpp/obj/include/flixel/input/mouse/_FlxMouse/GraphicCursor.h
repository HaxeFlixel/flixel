#ifndef INCLUDED_flixel_input_mouse__FlxMouse_GraphicCursor
#define INCLUDED_flixel_input_mouse__FlxMouse_GraphicCursor

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/BitmapData.h>
HX_DECLARE_CLASS4(flixel,input,mouse,_FlxMouse,GraphicCursor)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace input{
namespace mouse{
namespace _FlxMouse{


class HXCPP_CLASS_ATTRIBUTES  GraphicCursor_obj : public ::openfl::_v2::display::BitmapData_obj{
	public:
		typedef ::openfl::_v2::display::BitmapData_obj super;
		typedef GraphicCursor_obj OBJ_;
		GraphicCursor_obj();
		Void __construct(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GraphicCursor_obj > __new(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GraphicCursor_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("GraphicCursor"); }

		static ::String resourceName;
};

} // end namespace flixel
} // end namespace input
} // end namespace mouse
} // end namespace _FlxMouse

#endif /* INCLUDED_flixel_input_mouse__FlxMouse_GraphicCursor */ 
