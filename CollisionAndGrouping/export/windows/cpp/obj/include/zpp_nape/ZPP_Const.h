#ifndef INCLUDED_zpp_nape_ZPP_Const
#define INCLUDED_zpp_nape_ZPP_Const

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(zpp_nape,ZPP_Const)
namespace zpp_nape{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Const_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Const_obj OBJ_;
		ZPP_Const_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Const_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Const_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_Const"); }

		static Float POSINF( );
		static Dynamic POSINF_dyn();

		static Float NEGINF( );
		static Dynamic NEGINF_dyn();

		static Float FMAX;
};

} // end namespace zpp_nape

#endif /* INCLUDED_zpp_nape_ZPP_Const */ 
