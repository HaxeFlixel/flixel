#ifndef INCLUDED_nape_shape_Shape
#define INCLUDED_nape_shape_Shape

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/phys/Interactor.h>
HX_DECLARE_CLASS2(nape,dynamics,InteractionFilter)
HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,Mat23)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,FluidProperties)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,phys,Material)
HX_DECLARE_CLASS2(nape,shape,Circle)
HX_DECLARE_CLASS2(nape,shape,Polygon)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(nape,shape,ShapeType)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
namespace nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  Shape_obj : public ::nape::phys::Interactor_obj{
	public:
		typedef ::nape::phys::Interactor_obj super;
		typedef Shape_obj OBJ_;
		Shape_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Shape_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Shape_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Shape"); }

		::zpp_nape::shape::ZPP_Shape zpp_inner;
		virtual ::nape::shape::ShapeType get_type( );
		Dynamic get_type_dyn();

		virtual bool isCircle( );
		Dynamic isCircle_dyn();

		virtual bool isPolygon( );
		Dynamic isPolygon_dyn();

		virtual ::nape::phys::Body get_body( );
		Dynamic get_body_dyn();

		virtual ::nape::phys::Body set_body( ::nape::phys::Body body);
		Dynamic set_body_dyn();

		virtual ::nape::shape::Circle get_castCircle( );
		Dynamic get_castCircle_dyn();

		virtual ::nape::shape::Polygon get_castPolygon( );
		Dynamic get_castPolygon_dyn();

		virtual ::nape::geom::Vec2 get_worldCOM( );
		Dynamic get_worldCOM_dyn();

		virtual ::nape::geom::Vec2 get_localCOM( );
		Dynamic get_localCOM_dyn();

		virtual ::nape::geom::Vec2 set_localCOM( ::nape::geom::Vec2 localCOM);
		Dynamic set_localCOM_dyn();

		virtual Float get_area( );
		Dynamic get_area_dyn();

		virtual Float get_inertia( );
		Dynamic get_inertia_dyn();

		virtual Float get_angDrag( );
		Dynamic get_angDrag_dyn();

		virtual ::nape::phys::Material get_material( );
		Dynamic get_material_dyn();

		virtual ::nape::phys::Material set_material( ::nape::phys::Material material);
		Dynamic set_material_dyn();

		virtual ::nape::dynamics::InteractionFilter get_filter( );
		Dynamic get_filter_dyn();

		virtual ::nape::dynamics::InteractionFilter set_filter( ::nape::dynamics::InteractionFilter filter);
		Dynamic set_filter_dyn();

		virtual ::nape::phys::FluidProperties get_fluidProperties( );
		Dynamic get_fluidProperties_dyn();

		virtual ::nape::phys::FluidProperties set_fluidProperties( ::nape::phys::FluidProperties fluidProperties);
		Dynamic set_fluidProperties_dyn();

		virtual bool get_fluidEnabled( );
		Dynamic get_fluidEnabled_dyn();

		virtual bool set_fluidEnabled( bool fluidEnabled);
		Dynamic set_fluidEnabled_dyn();

		virtual bool get_sensorEnabled( );
		Dynamic get_sensorEnabled_dyn();

		virtual bool set_sensorEnabled( bool sensorEnabled);
		Dynamic set_sensorEnabled_dyn();

		virtual ::nape::geom::AABB get_bounds( );
		Dynamic get_bounds_dyn();

		virtual ::nape::shape::Shape translate( ::nape::geom::Vec2 translation);
		Dynamic translate_dyn();

		virtual ::nape::shape::Shape scale( Float scalex,Float scaley);
		Dynamic scale_dyn();

		virtual ::nape::shape::Shape rotate( Float angle);
		Dynamic rotate_dyn();

		virtual ::nape::shape::Shape transform( ::nape::geom::Mat23 matrix);
		Dynamic transform_dyn();

		virtual bool contains( ::nape::geom::Vec2 point);
		Dynamic contains_dyn();

		virtual ::nape::shape::Shape copy( );
		Dynamic copy_dyn();

		virtual ::String toString( );

};

} // end namespace nape
} // end namespace shape

#endif /* INCLUDED_nape_shape_Shape */ 
