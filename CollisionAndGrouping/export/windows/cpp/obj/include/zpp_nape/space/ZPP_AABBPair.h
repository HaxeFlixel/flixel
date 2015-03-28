#ifndef INCLUDED_zpp_nape_space_ZPP_AABBPair
#define INCLUDED_zpp_nape_space_ZPP_AABBPair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBNode)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBPair)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_AABBPair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_AABBPair_obj OBJ_;
		ZPP_AABBPair_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_AABBPair_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_AABBPair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_AABBPair"); }

		::zpp_nape::space::ZPP_AABBNode n1;
		::zpp_nape::space::ZPP_AABBNode n2;
		bool first;
		bool sleeping;
		int id;
		int di;
		::zpp_nape::dynamics::ZPP_Arbiter arb;
		::zpp_nape::space::ZPP_AABBPair next;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		static ::zpp_nape::space::ZPP_AABBPair zpp_pool;
};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_AABBPair */ 
