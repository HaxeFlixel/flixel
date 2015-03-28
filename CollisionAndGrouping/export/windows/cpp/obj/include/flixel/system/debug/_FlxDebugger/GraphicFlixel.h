#ifndef INCLUDED_flixel_system_debug__FlxDebugger_GraphicFlixel
#define INCLUDED_flixel_system_debug__FlxDebugger_GraphicFlixel

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/BitmapData.h>
HX_DECLARE_CLASS4(flixel,system,debug,_FlxDebugger,GraphicFlixel)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace system{
namespace debug{
namespace _FlxDebugger{


class HXCPP_CLASS_ATTRIBUTES  GraphicFlixel_obj : public ::openfl::_v2::display::BitmapData_obj{
	public:
		typedef ::openfl::_v2::display::BitmapData_obj super;
		typedef GraphicFlixel_obj OBJ_;
		GraphicFlixel_obj();
		Void __construct(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GraphicFlixel_obj > __new(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GraphicFlixel_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("GraphicFlixel"); }

		static ::String resourceName;
};

} // end namespace flixel
} // end namespace system
} // end namespace debug
} // end namespace _FlxDebugger

#endif /* INCLUDED_flixel_system_debug__FlxDebugger_GraphicFlixel */ 
