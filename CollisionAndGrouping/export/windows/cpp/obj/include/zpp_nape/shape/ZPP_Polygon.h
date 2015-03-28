#ifndef INCLUDED_zpp_nape_shape_ZPP_Polygon
#define INCLUDED_zpp_nape_shape_ZPP_Polygon

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/shape/ZPP_Shape.h>
HX_DECLARE_CLASS2(nape,geom,Mat23)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec2List)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,EdgeList)
HX_DECLARE_CLASS2(nape,shape,Polygon)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(nape,shape,ValidationResult)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Polygon)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Edge)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Vec2List)
namespace zpp_nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Polygon_obj : public ::zpp_nape::shape::ZPP_Shape_obj{
	public:
		typedef ::zpp_nape::shape::ZPP_Shape_obj super;
		typedef ZPP_Polygon_obj OBJ_;
		ZPP_Polygon_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Polygon_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Polygon_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Polygon"); }

		::nape::shape::Polygon outer_zn;
		::zpp_nape::geom::ZPP_Vec2 lverts;
		::nape::geom::Vec2List wrap_lverts;
		::zpp_nape::geom::ZPP_Vec2 gverts;
		::nape::geom::Vec2List wrap_gverts;
		::zpp_nape::util::ZNPList_ZPP_Edge edges;
		::nape::shape::EdgeList wrap_edges;
		int edgeCnt;
		bool reverse_flag;
		virtual Void __clear( );
		Dynamic __clear_dyn();

		virtual Void lverts_pa_invalidate( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic lverts_pa_invalidate_dyn();

		virtual Void lverts_pa_immutable( );
		Dynamic lverts_pa_immutable_dyn();

		virtual Void gverts_pa_validate( );
		Dynamic gverts_pa_validate_dyn();

		virtual Void lverts_post_adder( ::nape::geom::Vec2 x);
		Dynamic lverts_post_adder_dyn();

		virtual Void lverts_subber( ::nape::geom::Vec2 x);
		Dynamic lverts_subber_dyn();

		virtual Void lverts_invalidate( ::zpp_nape::util::ZPP_Vec2List _);
		Dynamic lverts_invalidate_dyn();

		virtual Void lverts_validate( );
		Dynamic lverts_validate_dyn();

		virtual Void lverts_modifiable( );
		Dynamic lverts_modifiable_dyn();

		virtual Void gverts_validate( );
		Dynamic gverts_validate_dyn();

		virtual Void edges_validate( );
		Dynamic edges_validate_dyn();

		virtual Void getlverts( );
		Dynamic getlverts_dyn();

		virtual Void getgverts( );
		Dynamic getgverts_dyn();

		virtual Void getedges( );
		Dynamic getedges_dyn();

		bool zip_lverts;
		virtual Void invalidate_lverts( );
		Dynamic invalidate_lverts_dyn();

		bool zip_laxi;
		virtual Void invalidate_laxi( );
		Dynamic invalidate_laxi_dyn();

		bool zip_gverts;
		virtual Void invalidate_gverts( );
		Dynamic invalidate_gverts_dyn();

		bool zip_gaxi;
		virtual Void invalidate_gaxi( );
		Dynamic invalidate_gaxi_dyn();

		bool zip_valid;
		::nape::shape::ValidationResult validation;
		virtual ::nape::shape::ValidationResult valid( );
		Dynamic valid_dyn();

		virtual Void validate_lverts( );
		Dynamic validate_lverts_dyn();

		virtual Void cleanup_lvert( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic cleanup_lvert_dyn();

		bool zip_sanitation;
		virtual Void splice_collinear( );
		Dynamic splice_collinear_dyn();

		virtual Void splice_collinear_real( );
		Dynamic splice_collinear_real_dyn();

		virtual Void reverse_vertices( );
		Dynamic reverse_vertices_dyn();

		virtual Void validate_laxi( );
		Dynamic validate_laxi_dyn();

		virtual Void validate_gverts( );
		Dynamic validate_gverts_dyn();

		virtual Void validate_gaxi( );
		Dynamic validate_gaxi_dyn();

		virtual Void __validate_aabb( );
		Dynamic __validate_aabb_dyn();

		virtual Void _force_validate_aabb( );
		Dynamic _force_validate_aabb_dyn();

		virtual Void __validate_sweepRadius( );
		Dynamic __validate_sweepRadius_dyn();

		virtual Void __validate_area_inertia( );
		Dynamic __validate_area_inertia_dyn();

		virtual Void __validate_angDrag( );
		Dynamic __validate_angDrag_dyn();

		virtual Void __validate_localCOM( );
		Dynamic __validate_localCOM_dyn();

		virtual Void localCOM_validate( );
		Dynamic localCOM_validate_dyn();

		virtual Void localCOM_invalidate( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic localCOM_invalidate_dyn();

		virtual Void setupLocalCOM( );
		Dynamic setupLocalCOM_dyn();

		virtual Void __translate( Float dx,Float dy);
		Dynamic __translate_dyn();

		virtual Void __scale( Float sx,Float sy);
		Dynamic __scale_dyn();

		virtual Void __rotate( Float ax,Float ay);
		Dynamic __rotate_dyn();

		virtual Void __transform( ::nape::geom::Mat23 mat);
		Dynamic __transform_dyn();

		virtual ::zpp_nape::shape::ZPP_Polygon __copy( );
		Dynamic __copy_dyn();

};

} // end namespace zpp_nape
} // end namespace shape

#endif /* INCLUDED_zpp_nape_shape_ZPP_Polygon */ 
