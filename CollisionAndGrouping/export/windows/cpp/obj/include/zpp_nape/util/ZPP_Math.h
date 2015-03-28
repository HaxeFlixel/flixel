#ifndef INCLUDED_zpp_nape_util_ZPP_Math
#define INCLUDED_zpp_nape_util_ZPP_Math

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Math)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Math_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Math_obj OBJ_;
		ZPP_Math_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Math_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Math_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_Math"); }

		static Float sqrt( Float x);
		static Dynamic sqrt_dyn();

		static Float invsqrt( Float x);
		static Dynamic invsqrt_dyn();

		static Float sqr( Float x);
		static Dynamic sqr_dyn();

		static Float clamp2( Float x,Float a);
		static Dynamic clamp2_dyn();

		static Float clamp( Float x,Float a,Float b);
		static Dynamic clamp_dyn();

};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZPP_Math */ 
