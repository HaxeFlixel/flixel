#ifndef INCLUDED_zpp_nape_space_ZPP_SweepPhase
#define INCLUDED_zpp_nape_space_ZPP_SweepPhase

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/space/ZPP_Broadphase.h>
HX_DECLARE_CLASS2(nape,geom,RayResult)
HX_DECLARE_CLASS2(nape,geom,RayResultList)
HX_DECLARE_CLASS2(nape,phys,BodyList)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_InteractionFilter)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Ray)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Broadphase)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_SweepData)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_SweepPhase)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_SweepPhase_obj : public ::zpp_nape::space::ZPP_Broadphase_obj{
	public:
		typedef ::zpp_nape::space::ZPP_Broadphase_obj super;
		typedef ZPP_SweepPhase_obj OBJ_;
		ZPP_SweepPhase_obj();
		Void __construct(::zpp_nape::space::ZPP_Space space);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_SweepPhase_obj > __new(::zpp_nape::space::ZPP_Space space);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_SweepPhase_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_SweepPhase"); }

		::zpp_nape::space::ZPP_SweepData list;
		virtual Void __insert( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic __insert_dyn();

		virtual Void __remove( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic __remove_dyn();

		virtual Void __sync( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic __sync_dyn();

		virtual Void sync_broadphase( );
		Dynamic sync_broadphase_dyn();

		virtual Void sync_broadphase_fast( );
		Dynamic sync_broadphase_fast_dyn();

		virtual Void broadphase( ::zpp_nape::space::ZPP_Space space,bool discrete);

		virtual Void clear( );

		virtual ::nape::shape::ShapeList shapesUnderPoint( Float x,Float y,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);

		virtual ::nape::phys::BodyList bodiesUnderPoint( Float x,Float y,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);

		virtual ::nape::shape::ShapeList shapesInAABB( ::zpp_nape::geom::ZPP_AABB aabb,bool strict,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);

		::nape::phys::BodyList failed;
		virtual ::nape::phys::BodyList bodiesInAABB( ::zpp_nape::geom::ZPP_AABB aabb,bool strict,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);

		virtual ::nape::shape::ShapeList shapesInCircle( Float x,Float y,Float r,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);

		virtual ::nape::phys::BodyList bodiesInCircle( Float x,Float y,Float r,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);

		virtual ::nape::shape::ShapeList shapesInShape( ::zpp_nape::shape::ZPP_Shape shape,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::shape::ShapeList output);

		virtual ::nape::phys::BodyList bodiesInShape( ::zpp_nape::shape::ZPP_Shape shape,bool containment,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::phys::BodyList output);

		virtual ::nape::geom::RayResult rayCast( ::zpp_nape::geom::ZPP_Ray ray,bool inner,::zpp_nape::dynamics::ZPP_InteractionFilter filter);

		virtual ::nape::geom::RayResultList rayMultiCast( ::zpp_nape::geom::ZPP_Ray ray,bool inner,::zpp_nape::dynamics::ZPP_InteractionFilter filter,::nape::geom::RayResultList output);

};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_SweepPhase */ 
