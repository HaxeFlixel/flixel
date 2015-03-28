#ifndef INCLUDED_openfl__v2_display_OpenGLView
#define INCLUDED_openfl__v2_display_OpenGLView

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/DirectRenderer.h>
HX_DECLARE_CLASS3(openfl,_v2,display,DirectRenderer)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,OpenGLView)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  OpenGLView_obj : public ::openfl::_v2::display::DirectRenderer_obj{
	public:
		typedef ::openfl::_v2::display::DirectRenderer_obj super;
		typedef OpenGLView_obj OBJ_;
		OpenGLView_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< OpenGLView_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~OpenGLView_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("OpenGLView"); }

		static ::String CONTEXT_LOST;
		static ::String CONTEXT_RESTORED;
		static bool isSupported;
		static bool get_isSupported( );
		static Dynamic get_isSupported_dyn();

};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_OpenGLView */ 
