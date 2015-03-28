#ifndef INCLUDED_zpp_nape_space_ZPP_AABBNode
#define INCLUDED_zpp_nape_space_ZPP_AABBNode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBNode)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_AABBNode_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_AABBNode_obj OBJ_;
		ZPP_AABBNode_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_AABBNode_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_AABBNode_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_AABBNode"); }

		::zpp_nape::geom::ZPP_AABB aabb;
		::zpp_nape::shape::ZPP_Shape shape;
		bool dyn;
		::zpp_nape::space::ZPP_AABBNode parent;
		::zpp_nape::space::ZPP_AABBNode child1;
		::zpp_nape::space::ZPP_AABBNode child2;
		int height;
		Float rayt;
		::zpp_nape::space::ZPP_AABBNode next;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		::zpp_nape::space::ZPP_AABBNode mnext;
		bool moved;
		::zpp_nape::space::ZPP_AABBNode snext;
		bool synced;
		bool first_sync;
		virtual bool isLeaf( );
		Dynamic isLeaf_dyn();

		static ::zpp_nape::space::ZPP_AABBNode zpp_pool;
};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_AABBNode */ 
