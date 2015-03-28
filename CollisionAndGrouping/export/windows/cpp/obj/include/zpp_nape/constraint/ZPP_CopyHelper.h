#ifndef INCLUDED_zpp_nape_constraint_ZPP_CopyHelper
#define INCLUDED_zpp_nape_constraint_ZPP_CopyHelper

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_CopyHelper)
namespace zpp_nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  ZPP_CopyHelper_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_CopyHelper_obj OBJ_;
		ZPP_CopyHelper_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_CopyHelper_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_CopyHelper_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_CopyHelper"); }

		int id;
		::nape::phys::Body bc;
		Dynamic cb;
		Dynamic &cb_dyn() { return cb;}
		static ::zpp_nape::constraint::ZPP_CopyHelper dict( int id,::nape::phys::Body bc);
		static Dynamic dict_dyn();

		static ::zpp_nape::constraint::ZPP_CopyHelper todo( int id,Dynamic cb);
		static Dynamic todo_dyn();

};

} // end namespace zpp_nape
} // end namespace constraint

#endif /* INCLUDED_zpp_nape_constraint_ZPP_CopyHelper */ 
