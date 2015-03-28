#ifndef INCLUDED_zpp_nape_space_ZPP_AABBTree
#define INCLUDED_zpp_nape_space_ZPP_AABBTree

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBNode)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBTree)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_AABBTree_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_AABBTree_obj OBJ_;
		ZPP_AABBTree_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_AABBTree_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_AABBTree_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_AABBTree"); }

		::zpp_nape::space::ZPP_AABBNode root;
		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void insertLeaf( ::zpp_nape::space::ZPP_AABBNode leaf);
		Dynamic insertLeaf_dyn();

		virtual Void inlined_insertLeaf( ::zpp_nape::space::ZPP_AABBNode leaf);
		Dynamic inlined_insertLeaf_dyn();

		virtual Void removeLeaf( ::zpp_nape::space::ZPP_AABBNode leaf);
		Dynamic removeLeaf_dyn();

		virtual Void inlined_removeLeaf( ::zpp_nape::space::ZPP_AABBNode leaf);
		Dynamic inlined_removeLeaf_dyn();

		virtual ::zpp_nape::space::ZPP_AABBNode balance( ::zpp_nape::space::ZPP_AABBNode a);
		Dynamic balance_dyn();

		static ::zpp_nape::geom::ZPP_AABB tmpaabb;
};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_AABBTree */ 
