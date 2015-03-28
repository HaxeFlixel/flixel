#ifndef INCLUDED_zpp_nape_geom_ZPP_PartitionVertex
#define INCLUDED_zpp_nape_geom_ZPP_PartitionVertex

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_PartitionVertex)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_PartitionVertex_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_PartitionVertex_obj OBJ_;
		ZPP_PartitionVertex_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_PartitionVertex_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_PartitionVertex_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_PartitionVertex"); }

		int id;
		Float mag;
		Float x;
		Float y;
		bool forced;
		::zpp_nape::util::ZNPList_ZPP_PartitionVertex diagonals;
		int type;
		::zpp_nape::geom::ZPP_PartitionVertex helper;
		bool rightchain;
		::zpp_nape::geom::ZPP_PartitionVertex next;
		::zpp_nape::geom::ZPP_PartitionVertex prev;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionVertex copy( );
		Dynamic copy_dyn();

		virtual Void sort( );
		Dynamic sort_dyn();

		::zpp_nape::util::ZPP_Set_ZPP_PartitionVertex node;
		static int nextId;
		static ::zpp_nape::geom::ZPP_PartitionVertex zpp_pool;
		static ::zpp_nape::geom::ZPP_PartitionVertex get( ::zpp_nape::geom::ZPP_GeomVert x);
		static Dynamic get_dyn();

		static Float rightdistance( ::zpp_nape::geom::ZPP_PartitionVertex edge,::zpp_nape::geom::ZPP_PartitionVertex vert);
		static Dynamic rightdistance_dyn();

		static bool vert_lt( ::zpp_nape::geom::ZPP_PartitionVertex edge,::zpp_nape::geom::ZPP_PartitionVertex vert);
		static Dynamic vert_lt_dyn();

		static Void edge_swap( ::zpp_nape::geom::ZPP_PartitionVertex p,::zpp_nape::geom::ZPP_PartitionVertex q);
		static Dynamic edge_swap_dyn();

		static bool edge_lt( ::zpp_nape::geom::ZPP_PartitionVertex p,::zpp_nape::geom::ZPP_PartitionVertex q);
		static Dynamic edge_lt_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_PartitionVertex */ 
