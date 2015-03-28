#ifndef INCLUDED_openfl_display3D_Context3DClearMask
#define INCLUDED_openfl_display3D_Context3DClearMask

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display3D,Context3DClearMask)
namespace openfl{
namespace display3D{


class HXCPP_CLASS_ATTRIBUTES  Context3DClearMask_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Context3DClearMask_obj OBJ_;
		Context3DClearMask_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Context3DClearMask_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Context3DClearMask_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("Context3DClearMask"); }

		static int ALL;
		static int COLOR;
		static int DEPTH;
		static int STENCIL;
};

} // end namespace openfl
} // end namespace display3D

#endif /* INCLUDED_openfl_display3D_Context3DClearMask */ 
