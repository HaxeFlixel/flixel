#ifndef INCLUDED_zpp_nape_geom_ZPP_Monotone
#define INCLUDED_zpp_nape_geom_ZPP_Monotone

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Monotone)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionedPoly)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_PartitionVertex)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Monotone_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Monotone_obj OBJ_;
		ZPP_Monotone_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Monotone_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Monotone_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_Monotone"); }

		static ::zpp_nape::geom::ZPP_Vec2 bisector( ::zpp_nape::geom::ZPP_PartitionVertex b);
		static Dynamic bisector_dyn();

		static bool below( ::zpp_nape::geom::ZPP_PartitionVertex p,::zpp_nape::geom::ZPP_PartitionVertex q);
		static Dynamic below_dyn();

		static bool above( ::zpp_nape::geom::ZPP_PartitionVertex p,::zpp_nape::geom::ZPP_PartitionVertex q);
		static Dynamic above_dyn();

		static bool left_vertex( ::zpp_nape::geom::ZPP_PartitionVertex p);
		static Dynamic left_vertex_dyn();

		static bool isMonotone( ::zpp_nape::geom::ZPP_GeomVert P);
		static Dynamic isMonotone_dyn();

		static ::zpp_nape::geom::ZPP_PartitionedPoly sharedPPoly;
		static ::zpp_nape::geom::ZPP_PartitionedPoly getShared( );
		static Dynamic getShared_dyn();

		static ::zpp_nape::util::ZNPList_ZPP_PartitionVertex queue;
		static ::zpp_nape::util::ZPP_Set_ZPP_PartitionVertex edges;
		static ::zpp_nape::geom::ZPP_PartitionedPoly decompose( ::zpp_nape::geom::ZPP_GeomVert P,::zpp_nape::geom::ZPP_PartitionedPoly poly);
		static Dynamic decompose_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_Monotone */ 
