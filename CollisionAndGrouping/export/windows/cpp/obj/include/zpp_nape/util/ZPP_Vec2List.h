#ifndef INCLUDED_zpp_nape_util_ZPP_Vec2List
#define INCLUDED_zpp_nape_util_ZPP_Vec2List

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec2List)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPNode_ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Vec2List)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Vec2List_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Vec2List_obj OBJ_;
		ZPP_Vec2List_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Vec2List_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Vec2List_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Vec2List"); }

		::nape::geom::Vec2List outer;
		::zpp_nape::util::ZNPList_ZPP_Vec2 inner;
		bool immutable;
		bool _invalidated;
		Dynamic _invalidate;
		Dynamic &_invalidate_dyn() { return _invalidate;}
		Dynamic _validate;
		Dynamic &_validate_dyn() { return _validate;}
		Dynamic _modifiable;
		Dynamic &_modifiable_dyn() { return _modifiable;}
		Dynamic adder;
		Dynamic &adder_dyn() { return adder;}
		Dynamic post_adder;
		Dynamic &post_adder_dyn() { return post_adder;}
		Dynamic subber;
		Dynamic &subber_dyn() { return subber;}
		bool dontremove;
		bool reverse_flag;
		virtual Void valmod( );
		Dynamic valmod_dyn();

		virtual Void modified( );
		Dynamic modified_dyn();

		virtual Void modify_test( );
		Dynamic modify_test_dyn();

		virtual Void validate( );
		Dynamic validate_dyn();

		virtual Void invalidate( );
		Dynamic invalidate_dyn();

		int at_index;
		::zpp_nape::util::ZNPNode_ZPP_Vec2 at_ite;
		::zpp_nape::util::ZNPNode_ZPP_Vec2 push_ite;
		bool zip_length;
		int user_length;
		static bool internal;
		static ::nape::geom::Vec2List get( ::zpp_nape::util::ZNPList_ZPP_Vec2 list,hx::Null< bool >  imm);
		static Dynamic get_dyn();

};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZPP_Vec2List */ 
