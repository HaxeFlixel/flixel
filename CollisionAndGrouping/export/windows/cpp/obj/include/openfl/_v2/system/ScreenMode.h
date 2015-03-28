#ifndef INCLUDED_openfl__v2_system_ScreenMode
#define INCLUDED_openfl__v2_system_ScreenMode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,system,PixelFormat)
HX_DECLARE_CLASS3(openfl,_v2,system,ScreenMode)
namespace openfl{
namespace _v2{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  ScreenMode_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ScreenMode_obj OBJ_;
		ScreenMode_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ScreenMode_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ScreenMode_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ScreenMode"); }

		::openfl::_v2::system::PixelFormat format;
		int width;
		int height;
		int refreshRate;
};

} // end namespace openfl
} // end namespace _v2
} // end namespace system

#endif /* INCLUDED_openfl__v2_system_ScreenMode */ 
