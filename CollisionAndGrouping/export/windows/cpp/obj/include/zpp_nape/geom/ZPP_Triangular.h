#ifndef INCLUDED_zpp_nape_geom_ZPP_Triangular
#define INCLUDED_zpp_nape_geom_ZPP_Triangular

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionedPoly)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Triangular)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_PartitionPair)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Triangular_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Triangular_obj OBJ_;
		ZPP_Triangular_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Triangular_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Triangular_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_Triangular"); }

		static bool lt( ::zpp_nape::geom::ZPP_PartitionVertex p,::zpp_nape::geom::ZPP_PartitionVertex q);
		static Dynamic lt_dyn();

		static Float right_turn( ::zpp_nape::geom::ZPP_PartitionVertex a,::zpp_nape::geom::ZPP_PartitionVertex b,::zpp_nape::geom::ZPP_PartitionVertex c);
		static Dynamic right_turn_dyn();

		static ::zpp_nape::util::ZNPList_ZPP_PartitionVertex queue;
		static ::zpp_nape::util::ZNPList_ZPP_PartitionVertex stack;
		static bool delaunay( ::zpp_nape::geom::ZPP_PartitionVertex A,::zpp_nape::geom::ZPP_PartitionVertex B,::zpp_nape::geom::ZPP_PartitionVertex C,::zpp_nape::geom::ZPP_PartitionVertex D);
		static Dynamic delaunay_dyn();

		static ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair edgeSet;
		static Void optimise( ::zpp_nape::geom::ZPP_PartitionedPoly P);
		static Dynamic optimise_dyn();

		static ::zpp_nape::geom::ZPP_PartitionedPoly triangulate( ::zpp_nape::geom::ZPP_PartitionedPoly P);
		static Dynamic triangulate_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_Triangular */ 
