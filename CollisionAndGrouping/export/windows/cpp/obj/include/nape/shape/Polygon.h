#ifndef INCLUDED_nape_shape_Polygon
#define INCLUDED_nape_shape_Polygon

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/shape/Shape.h>
HX_DECLARE_CLASS2(nape,dynamics,InteractionFilter)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec2List)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,phys,Material)
HX_DECLARE_CLASS2(nape,shape,EdgeList)
HX_DECLARE_CLASS2(nape,shape,Polygon)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(nape,shape,ValidationResult)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Polygon)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
namespace nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  Polygon_obj : public ::nape::shape::Shape_obj{
	public:
		typedef ::nape::shape::Shape_obj super;
		typedef Polygon_obj OBJ_;
		Polygon_obj();
		Void __construct(Dynamic localVerts,::nape::phys::Material material,::nape::dynamics::InteractionFilter filter);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Polygon_obj > __new(Dynamic localVerts,::nape::phys::Material material,::nape::dynamics::InteractionFilter filter);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Polygon_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Polygon"); }

		::zpp_nape::shape::ZPP_Polygon zpp_inner_zn;
		virtual ::nape::geom::Vec2List get_localVerts( );
		Dynamic get_localVerts_dyn();

		virtual ::nape::geom::Vec2List get_worldVerts( );
		Dynamic get_worldVerts_dyn();

		virtual ::nape::shape::EdgeList get_edges( );
		Dynamic get_edges_dyn();

		virtual ::nape::shape::ValidationResult validity( );
		Dynamic validity_dyn();

		static Array< ::Dynamic > rect( Float x,Float y,Float width,Float height,hx::Null< bool >  weak);
		static Dynamic rect_dyn();

		static Array< ::Dynamic > box( Float width,Float height,hx::Null< bool >  weak);
		static Dynamic box_dyn();

		static Array< ::Dynamic > regular( Float xRadius,Float yRadius,int edgeCount,hx::Null< Float >  angleOffset,hx::Null< bool >  weak);
		static Dynamic regular_dyn();

};

} // end namespace nape
} // end namespace shape

#endif /* INCLUDED_nape_shape_Polygon */ 
