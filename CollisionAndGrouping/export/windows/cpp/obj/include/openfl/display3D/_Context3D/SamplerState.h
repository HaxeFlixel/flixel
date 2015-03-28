#ifndef INCLUDED_openfl_display3D__Context3D_SamplerState
#define INCLUDED_openfl_display3D__Context3D_SamplerState

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display3D,Context3DMipFilter)
HX_DECLARE_CLASS2(openfl,display3D,Context3DTextureFilter)
HX_DECLARE_CLASS2(openfl,display3D,Context3DWrapMode)
HX_DECLARE_CLASS3(openfl,display3D,_Context3D,SamplerState)
namespace openfl{
namespace display3D{
namespace _Context3D{


class HXCPP_CLASS_ATTRIBUTES  SamplerState_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef SamplerState_obj OBJ_;
		SamplerState_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< SamplerState_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~SamplerState_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("SamplerState"); }

		::openfl::display3D::Context3DWrapMode wrap;
		::openfl::display3D::Context3DTextureFilter filter;
		::openfl::display3D::Context3DMipFilter mipfilter;
};

} // end namespace openfl
} // end namespace display3D
} // end namespace _Context3D

#endif /* INCLUDED_openfl_display3D__Context3D_SamplerState */ 
