#ifndef INCLUDED_flixel_system_debug__Stats_GraphicMinimizeButton
#define INCLUDED_flixel_system_debug__Stats_GraphicMinimizeButton

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/BitmapData.h>
HX_DECLARE_CLASS4(flixel,system,debug,_Stats,GraphicMinimizeButton)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace system{
namespace debug{
namespace _Stats{


class HXCPP_CLASS_ATTRIBUTES  GraphicMinimizeButton_obj : public ::openfl::_v2::display::BitmapData_obj{
	public:
		typedef ::openfl::_v2::display::BitmapData_obj super;
		typedef GraphicMinimizeButton_obj OBJ_;
		GraphicMinimizeButton_obj();
		Void __construct(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GraphicMinimizeButton_obj > __new(int width,int height,Dynamic __o_transparent,Dynamic __o_fillRGBA);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GraphicMinimizeButton_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("GraphicMinimizeButton"); }

		static ::String resourceName;
};

} // end namespace flixel
} // end namespace system
} // end namespace debug
} // end namespace _Stats

#endif /* INCLUDED_flixel_system_debug__Stats_GraphicMinimizeButton */ 
