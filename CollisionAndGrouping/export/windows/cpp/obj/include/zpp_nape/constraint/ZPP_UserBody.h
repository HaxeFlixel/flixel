#ifndef INCLUDED_zpp_nape_constraint_ZPP_UserBody
#define INCLUDED_zpp_nape_constraint_ZPP_UserBody

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_UserBody)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
namespace zpp_nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  ZPP_UserBody_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_UserBody_obj OBJ_;
		ZPP_UserBody_obj();
		Void __construct(int cnt,::zpp_nape::phys::ZPP_Body body);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_UserBody_obj > __new(int cnt,::zpp_nape::phys::ZPP_Body body);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_UserBody_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_UserBody"); }

		int cnt;
		::zpp_nape::phys::ZPP_Body body;
};

} // end namespace zpp_nape
} // end namespace constraint

#endif /* INCLUDED_zpp_nape_constraint_ZPP_UserBody */ 
