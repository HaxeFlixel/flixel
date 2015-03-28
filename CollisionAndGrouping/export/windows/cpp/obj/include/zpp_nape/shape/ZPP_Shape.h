#ifndef INCLUDED_zpp_nape_shape_ZPP_Shape
#define INCLUDED_zpp_nape_shape_ZPP_Shape

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/phys/ZPP_Interactor.h>
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(nape,shape,ShapeType)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_InteractionFilter)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_FluidProperties)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Material)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Circle)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Polygon)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBNode)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_SweepData)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_AABBPair)
namespace zpp_nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Shape_obj : public ::zpp_nape::phys::ZPP_Interactor_obj{
	public:
		typedef ::zpp_nape::phys::ZPP_Interactor_obj super;
		typedef ZPP_Shape_obj OBJ_;
		ZPP_Shape_obj();
		Void __construct(int type);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Shape_obj > __new(int type);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Shape_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Shape"); }

		::nape::shape::Shape outer;
		::zpp_nape::phys::ZPP_Body body;
		int type;
		virtual bool isCircle( );
		Dynamic isCircle_dyn();

		virtual bool isPolygon( );
		Dynamic isPolygon_dyn();

		Float area;
		bool zip_area_inertia;
		Float inertia;
		Float angDrag;
		bool zip_angDrag;
		Float localCOMx;
		Float localCOMy;
		bool zip_localCOM;
		Float worldCOMx;
		Float worldCOMy;
		bool zip_worldCOM;
		::nape::geom::Vec2 wrap_localCOM;
		::nape::geom::Vec2 wrap_worldCOM;
		Float sweepRadius;
		bool zip_sweepRadius;
		Float sweepCoef;
		virtual Void invalidate_sweepRadius( );
		Dynamic invalidate_sweepRadius_dyn();

		virtual Void validate_sweepRadius( );
		Dynamic validate_sweepRadius_dyn();

		::zpp_nape::shape::ZPP_Circle circle;
		::zpp_nape::shape::ZPP_Polygon polygon;
		::zpp_nape::phys::ZPP_Material refmaterial;
		::zpp_nape::phys::ZPP_Material material;
		::zpp_nape::dynamics::ZPP_InteractionFilter filter;
		::zpp_nape::phys::ZPP_FluidProperties fluidProperties;
		bool fluidEnabled;
		bool sensorEnabled;
		::zpp_nape::space::ZPP_SweepData sweep;
		::zpp_nape::space::ZPP_AABBNode node;
		::zpp_nape::util::ZNPList_ZPP_AABBPair pairs;
		virtual Void clear( );
		Dynamic clear_dyn();

		::zpp_nape::geom::ZPP_AABB aabb;
		bool zip_aabb;
		virtual Void validate_aabb( );
		Dynamic validate_aabb_dyn();

		virtual Void force_validate_aabb( );
		Dynamic force_validate_aabb_dyn();

		virtual Void invalidate_aabb( );
		Dynamic invalidate_aabb_dyn();

		virtual Void validate_area_inertia( );
		Dynamic validate_area_inertia_dyn();

		virtual Void validate_angDrag( );
		Dynamic validate_angDrag_dyn();

		virtual Void validate_localCOM( );
		Dynamic validate_localCOM_dyn();

		virtual Void validate_worldCOM( );
		Dynamic validate_worldCOM_dyn();

		virtual Void getworldCOM( );
		Dynamic getworldCOM_dyn();

		virtual Void invalidate_area_inertia( );
		Dynamic invalidate_area_inertia_dyn();

		virtual Void invalidate_angDrag( );
		Dynamic invalidate_angDrag_dyn();

		virtual Void invalidate_localCOM( );
		Dynamic invalidate_localCOM_dyn();

		virtual Void invalidate_worldCOM( );
		Dynamic invalidate_worldCOM_dyn();

		virtual Void invalidate_material( int flags);
		Dynamic invalidate_material_dyn();

		virtual Void invalidate_filter( );
		Dynamic invalidate_filter_dyn();

		virtual Void invalidate_fluidprops( );
		Dynamic invalidate_fluidprops_dyn();

		virtual Void aabb_validate( );
		Dynamic aabb_validate_dyn();

		virtual Void setMaterial( ::zpp_nape::phys::ZPP_Material material);
		Dynamic setMaterial_dyn();

		virtual Void setFilter( ::zpp_nape::dynamics::ZPP_InteractionFilter filter);
		Dynamic setFilter_dyn();

		virtual Void setFluid( ::zpp_nape::phys::ZPP_FluidProperties fluid);
		Dynamic setFluid_dyn();

		virtual Void __immutable_midstep( ::String name);
		Dynamic __immutable_midstep_dyn();

		virtual Void addedToBody( );
		Dynamic addedToBody_dyn();

		virtual Void removedFromBody( );
		Dynamic removedFromBody_dyn();

		virtual Void addedToSpace( );
		Dynamic addedToSpace_dyn();

		virtual Void removedFromSpace( );
		Dynamic removedFromSpace_dyn();

		virtual ::nape::shape::Shape copy( );
		Dynamic copy_dyn();

		static Array< ::Dynamic > types;
};

} // end namespace zpp_nape
} // end namespace shape

#endif /* INCLUDED_zpp_nape_shape_ZPP_Shape */ 
