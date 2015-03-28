#ifndef INCLUDED_zpp_nape_geom_ZPP_PartitionedPoly
#define INCLUDED_zpp_nape_geom_ZPP_PartitionedPoly

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionedPoly)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_PartitionedPoly)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_PartitionedPoly_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_PartitionedPoly_obj OBJ_;
		ZPP_PartitionedPoly_obj();
		Void __construct(::zpp_nape::geom::ZPP_GeomVert P);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_PartitionedPoly_obj > __new(::zpp_nape::geom::ZPP_GeomVert P);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_PartitionedPoly_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_PartitionedPoly"); }

		::zpp_nape::geom::ZPP_PartitionVertex vertices;
		virtual bool eq( ::zpp_nape::geom::ZPP_PartitionVertex a,::zpp_nape::geom::ZPP_PartitionVertex b);
		Dynamic eq_dyn();

		::zpp_nape::geom::ZPP_PartitionedPoly next;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual Void init( ::zpp_nape::geom::ZPP_GeomVert P);
		Dynamic init_dyn();

		virtual bool remove_collinear_vertices( );
		Dynamic remove_collinear_vertices_dyn();

		virtual Void add_diagonal( ::zpp_nape::geom::ZPP_PartitionVertex p,::zpp_nape::geom::ZPP_PartitionVertex q);
		Dynamic add_diagonal_dyn();

		virtual ::zpp_nape::util::ZNPList_ZPP_PartitionedPoly extract_partitions( ::zpp_nape::util::ZNPList_ZPP_PartitionedPoly ret);
		Dynamic extract_partitions_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionVertex pull_partitions( ::zpp_nape::geom::ZPP_PartitionVertex start,::zpp_nape::util::ZNPList_ZPP_PartitionedPoly ret);
		Dynamic pull_partitions_dyn();

		virtual ::zpp_nape::util::ZNPList_ZPP_GeomVert extract( ::zpp_nape::util::ZNPList_ZPP_GeomVert ret);
		Dynamic extract_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionVertex pull( ::zpp_nape::geom::ZPP_PartitionVertex start,::zpp_nape::util::ZNPList_ZPP_GeomVert ret);
		Dynamic pull_dyn();

		static ::zpp_nape::geom::ZPP_PartitionedPoly zpp_pool;
		static ::zpp_nape::util::ZNPList_ZPP_PartitionedPoly sharedPPList;
		static ::zpp_nape::util::ZNPList_ZPP_PartitionedPoly getSharedPP( );
		static Dynamic getSharedPP_dyn();

		static ::zpp_nape::util::ZNPList_ZPP_GeomVert sharedGVList;
		static ::zpp_nape::util::ZNPList_ZPP_GeomVert getShared( );
		static Dynamic getShared_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_PartitionedPoly */ 
