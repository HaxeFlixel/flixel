#ifndef INCLUDED_zpp_nape_space_ZPP_Broadphase
#define INCLUDED_zpp_nape_space_ZPP_Broadphase

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Mat23)
HX_DECLARE_CLASS2(nape,geom,RayResult)
HX_DECLARE_CLASS2(nape,geom,RayResultList)
HX_DECLARE_CLASS2(nape,phys,BodyList)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_InteractionFilter)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Ray)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Broadphase)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_DynAABBPhase)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_SweepPhase)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Broadphase_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Broadphase_obj OBJ_;
		ZPP_Broadphase_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Broadphase_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Broadphase_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Broadphase"); }

		::zpp_nape::space::ZPP_Space space;
		bool is_sweep;
		::zpp_nape::space::ZPP_SweepPhase sweep;
		::zpp_nape::space::ZPP_DynAABBPhase dynab;
		virtual Void insert( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic insert_dyn();

		virtual Void remove( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic remove_dyn();

		virtual Void sync( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic sync_dyn();

		virtual Void broadphase( ::zpp_nape::space::ZPP_Space space,bool discrete);
		Dynamic broadphase_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual ::nape::shape::ShapeList shapesUnderPoint( Float x,Float y,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesUnderPoint_dyn();

		virtual ::nape::phys::BodyList bodiesUnderPoint( Float x,Float y,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesUnderPoint_dyn();

		::nape::shape::Shape aabbShape;
		::nape::geom::Mat23 matrix;
		virtual Void updateAABBShape( ::zpp_nape::geom::ZPP_AABB aabb);
		Dynamic updateAABBShape_dyn();

		virtual ::nape::shape::ShapeList shapesInAABB( ::zpp_nape::geom::ZPP_AABB aabb,bool strict,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesInAABB_dyn();

		virtual ::nape::phys::BodyList bodiesInAABB( ::zpp_nape::geom::ZPP_AABB aabb,bool strict,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesInAABB_dyn();

		::nape::shape::Shape circShape;
		virtual Void updateCircShape( Float x,Float y,Float r);
		Dynamic updateCircShape_dyn();

		virtual ::nape::shape::ShapeList shapesInCircle( Float x,Float y,Float r,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesInCircle_dyn();

		virtual ::nape::phys::BodyList bodiesInCircle( Float x,Float y,Float r,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesInCircle_dyn();

		virtual Void validateShape( ::zpp_nape::shape::ZPP_Shape s);
		Dynamic validateShape_dyn();

		virtual ::nape::shape::ShapeList shapesInShape( ::zpp_nape::shape::ZPP_Shape shape,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesInShape_dyn();

		virtual ::nape::phys::BodyList bodiesInShape( ::zpp_nape::shape::ZPP_Shape shape,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesInShape_dyn();

		virtual ::nape::geom::RayResult rayCast( ::zpp_nape::geom::ZPP_Ray ray,bool inner,::zpp_nape::dynamics::ZPP_InteractionFilter filter);
		Dynamic rayCast_dyn();

		virtual ::nape::geom::RayResultList rayMultiCast( ::zpp_nape::geom::ZPP_Ray ray,bool inner,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::geom::RayResultList output);
		Dynamic rayMultiCast_dyn();

};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_Broadphase */ 
