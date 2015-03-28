#ifndef INCLUDED_nape_space_Space
#define INCLUDED_nape_space_Space

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,InteractionType)
HX_DECLARE_CLASS2(nape,callbacks,ListenerList)
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,ConstraintList)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterList)
HX_DECLARE_CLASS2(nape,dynamics,InteractionFilter)
HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,ConvexResult)
HX_DECLARE_CLASS2(nape,geom,ConvexResultList)
HX_DECLARE_CLASS2(nape,geom,Ray)
HX_DECLARE_CLASS2(nape,geom,RayResult)
HX_DECLARE_CLASS2(nape,geom,RayResultList)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,BodyList)
HX_DECLARE_CLASS2(nape,phys,Compound)
HX_DECLARE_CLASS2(nape,phys,CompoundList)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(nape,space,Broadphase)
HX_DECLARE_CLASS2(nape,space,Space)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
namespace nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  Space_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Space_obj OBJ_;
		Space_obj();
		Void __construct(::nape::geom::Vec2 gravity,::nape::space::Broadphase broadphase);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Space_obj > __new(::nape::geom::Vec2 gravity,::nape::space::Broadphase broadphase);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Space_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Space"); }

		::zpp_nape::space::ZPP_Space zpp_inner;
		virtual Dynamic get_userData( );
		Dynamic get_userData_dyn();

		virtual ::nape::geom::Vec2 get_gravity( );
		Dynamic get_gravity_dyn();

		virtual ::nape::geom::Vec2 set_gravity( ::nape::geom::Vec2 gravity);
		Dynamic set_gravity_dyn();

		virtual ::nape::space::Broadphase get_broadphase( );
		Dynamic get_broadphase_dyn();

		virtual bool get_sortContacts( );
		Dynamic get_sortContacts_dyn();

		virtual bool set_sortContacts( bool sortContacts);
		Dynamic set_sortContacts_dyn();

		virtual Float get_worldAngularDrag( );
		Dynamic get_worldAngularDrag_dyn();

		virtual Float set_worldAngularDrag( Float worldAngularDrag);
		Dynamic set_worldAngularDrag_dyn();

		virtual Float get_worldLinearDrag( );
		Dynamic get_worldLinearDrag_dyn();

		virtual Float set_worldLinearDrag( Float worldLinearDrag);
		Dynamic set_worldLinearDrag_dyn();

		virtual ::nape::phys::CompoundList get_compounds( );
		Dynamic get_compounds_dyn();

		virtual ::nape::phys::BodyList get_bodies( );
		Dynamic get_bodies_dyn();

		virtual ::nape::phys::BodyList get_liveBodies( );
		Dynamic get_liveBodies_dyn();

		virtual ::nape::constraint::ConstraintList get_constraints( );
		Dynamic get_constraints_dyn();

		virtual ::nape::constraint::ConstraintList get_liveConstraints( );
		Dynamic get_liveConstraints_dyn();

		virtual Void visitBodies( Dynamic lambda);
		Dynamic visitBodies_dyn();

		virtual Void visitConstraints( Dynamic lambda);
		Dynamic visitConstraints_dyn();

		virtual Void visitCompounds( Dynamic lambda);
		Dynamic visitCompounds_dyn();

		virtual ::nape::phys::Body get_world( );
		Dynamic get_world_dyn();

		virtual ::nape::dynamics::ArbiterList get_arbiters( );
		Dynamic get_arbiters_dyn();

		virtual ::nape::callbacks::ListenerList get_listeners( );
		Dynamic get_listeners_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void step( Float deltaTime,hx::Null< int >  velocityIterations,hx::Null< int >  positionIterations);
		Dynamic step_dyn();

		virtual int get_timeStamp( );
		Dynamic get_timeStamp_dyn();

		virtual Float get_elapsedTime( );
		Dynamic get_elapsedTime_dyn();

		virtual ::nape::callbacks::InteractionType interactionType( ::nape::shape::Shape shape1,::nape::shape::Shape shape2);
		Dynamic interactionType_dyn();

		virtual ::nape::shape::ShapeList shapesUnderPoint( ::nape::geom::Vec2 point,::nape::dynamics::InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesUnderPoint_dyn();

		virtual ::nape::phys::BodyList bodiesUnderPoint( ::nape::geom::Vec2 point,::nape::dynamics::InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesUnderPoint_dyn();

		virtual ::nape::shape::ShapeList shapesInAABB( ::nape::geom::AABB aabb,hx::Null< bool >  containment,hx::Null< bool >  strict,::nape::dynamics::InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesInAABB_dyn();

		virtual ::nape::phys::BodyList bodiesInAABB( ::nape::geom::AABB aabb,hx::Null< bool >  containment,hx::Null< bool >  strict,::nape::dynamics::InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesInAABB_dyn();

		virtual ::nape::shape::ShapeList shapesInCircle( ::nape::geom::Vec2 position,Float radius,hx::Null< bool >  containment,::nape::dynamics::InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesInCircle_dyn();

		virtual ::nape::phys::BodyList bodiesInCircle( ::nape::geom::Vec2 position,Float radius,hx::Null< bool >  containment,::nape::dynamics::InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesInCircle_dyn();

		virtual ::nape::shape::ShapeList shapesInShape( ::nape::shape::Shape shape,hx::Null< bool >  containment,::nape::dynamics::InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesInShape_dyn();

		virtual ::nape::phys::BodyList bodiesInShape( ::nape::shape::Shape shape,hx::Null< bool >  containment,::nape::dynamics::InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesInShape_dyn();

		virtual ::nape::shape::ShapeList shapesInBody( ::nape::phys::Body body,::nape::dynamics::InteractionFilter filter,::nape::shape::ShapeList output);
		Dynamic shapesInBody_dyn();

		virtual ::nape::phys::BodyList bodiesInBody( ::nape::phys::Body body,::nape::dynamics::InteractionFilter filter,::nape::phys::BodyList output);
		Dynamic bodiesInBody_dyn();

		virtual ::nape::geom::ConvexResult convexCast( ::nape::shape::Shape shape,Float deltaTime,hx::Null< bool >  liveSweep,::nape::dynamics::InteractionFilter filter);
		Dynamic convexCast_dyn();

		virtual ::nape::geom::ConvexResultList convexMultiCast( ::nape::shape::Shape shape,Float deltaTime,hx::Null< bool >  liveSweep,::nape::dynamics::InteractionFilter filter,::nape::geom::ConvexResultList output);
		Dynamic convexMultiCast_dyn();

		virtual ::nape::geom::RayResult rayCast( ::nape::geom::Ray ray,hx::Null< bool >  inner,::nape::dynamics::InteractionFilter filter);
		Dynamic rayCast_dyn();

		virtual ::nape::geom::RayResultList rayMultiCast( ::nape::geom::Ray ray,hx::Null< bool >  inner,::nape::dynamics::InteractionFilter filter,::nape::geom::RayResultList output);
		Dynamic rayMultiCast_dyn();

};

} // end namespace nape
} // end namespace space

#endif /* INCLUDED_nape_space_Space */ 
