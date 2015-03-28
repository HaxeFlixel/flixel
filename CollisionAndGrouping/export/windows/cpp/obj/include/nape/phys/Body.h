#ifndef INCLUDED_nape_phys_Body
#define INCLUDED_nape_phys_Body

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/phys/Interactor.h>
HX_DECLARE_CLASS2(nape,callbacks,InteractionType)
HX_DECLARE_CLASS2(nape,constraint,ConstraintList)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterList)
HX_DECLARE_CLASS2(nape,dynamics,InteractionFilter)
HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,Mat23)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,BodyList)
HX_DECLARE_CLASS2(nape,phys,BodyType)
HX_DECLARE_CLASS2(nape,phys,Compound)
HX_DECLARE_CLASS2(nape,phys,FluidProperties)
HX_DECLARE_CLASS2(nape,phys,GravMassMode)
HX_DECLARE_CLASS2(nape,phys,InertiaMode)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,phys,MassMode)
HX_DECLARE_CLASS2(nape,phys,Material)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(nape,space,Space)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  Body_obj : public ::nape::phys::Interactor_obj{
	public:
		typedef ::nape::phys::Interactor_obj super;
		typedef Body_obj OBJ_;
		Body_obj();
		Void __construct(::nape::phys::BodyType type,::nape::geom::Vec2 position);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Body_obj > __new(::nape::phys::BodyType type,::nape::geom::Vec2 position);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Body_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Body"); }

		::zpp_nape::phys::ZPP_Body zpp_inner;
		bool debugDraw;
		virtual ::nape::phys::BodyType get_type( );
		Dynamic get_type_dyn();

		virtual ::nape::phys::BodyType set_type( ::nape::phys::BodyType type);
		Dynamic set_type_dyn();

		virtual bool get_isBullet( );
		Dynamic get_isBullet_dyn();

		virtual bool set_isBullet( bool isBullet);
		Dynamic set_isBullet_dyn();

		virtual bool get_disableCCD( );
		Dynamic get_disableCCD_dyn();

		virtual bool set_disableCCD( bool disableCCD);
		Dynamic set_disableCCD_dyn();

		virtual ::nape::phys::Body integrate( Float deltaTime);
		Dynamic integrate_dyn();

		virtual bool isStatic( );
		Dynamic isStatic_dyn();

		virtual bool isDynamic( );
		Dynamic isDynamic_dyn();

		virtual bool isKinematic( );
		Dynamic isKinematic_dyn();

		virtual ::nape::shape::ShapeList get_shapes( );
		Dynamic get_shapes_dyn();

		virtual ::nape::phys::Compound get_compound( );
		Dynamic get_compound_dyn();

		virtual ::nape::phys::Compound set_compound( ::nape::phys::Compound compound);
		Dynamic set_compound_dyn();

		virtual ::nape::space::Space get_space( );
		Dynamic get_space_dyn();

		virtual ::nape::space::Space set_space( ::nape::space::Space space);
		Dynamic set_space_dyn();

		virtual ::nape::dynamics::ArbiterList get_arbiters( );
		Dynamic get_arbiters_dyn();

		virtual bool get_isSleeping( );
		Dynamic get_isSleeping_dyn();

		virtual ::nape::constraint::ConstraintList get_constraints( );
		Dynamic get_constraints_dyn();

		virtual ::nape::phys::Body copy( );
		Dynamic copy_dyn();

		virtual ::nape::geom::Vec2 get_position( );
		Dynamic get_position_dyn();

		virtual ::nape::geom::Vec2 set_position( ::nape::geom::Vec2 position);
		Dynamic set_position_dyn();

		virtual ::nape::geom::Vec2 get_velocity( );
		Dynamic get_velocity_dyn();

		virtual ::nape::geom::Vec2 set_velocity( ::nape::geom::Vec2 velocity);
		Dynamic set_velocity_dyn();

		virtual ::nape::phys::Body setVelocityFromTarget( ::nape::geom::Vec2 targetPosition,Float targetRotation,Float deltaTime);
		Dynamic setVelocityFromTarget_dyn();

		virtual ::nape::geom::Vec2 get_kinematicVel( );
		Dynamic get_kinematicVel_dyn();

		virtual ::nape::geom::Vec2 set_kinematicVel( ::nape::geom::Vec2 kinematicVel);
		Dynamic set_kinematicVel_dyn();

		virtual ::nape::geom::Vec2 get_surfaceVel( );
		Dynamic get_surfaceVel_dyn();

		virtual ::nape::geom::Vec2 set_surfaceVel( ::nape::geom::Vec2 surfaceVel);
		Dynamic set_surfaceVel_dyn();

		virtual ::nape::geom::Vec2 get_force( );
		Dynamic get_force_dyn();

		virtual ::nape::geom::Vec2 set_force( ::nape::geom::Vec2 force);
		Dynamic set_force_dyn();

		virtual ::nape::geom::Vec3 get_constraintVelocity( );
		Dynamic get_constraintVelocity_dyn();

		virtual Float get_rotation( );
		Dynamic get_rotation_dyn();

		virtual Float set_rotation( Float rotation);
		Dynamic set_rotation_dyn();

		virtual Float get_angularVel( );
		Dynamic get_angularVel_dyn();

		virtual Float set_angularVel( Float angularVel);
		Dynamic set_angularVel_dyn();

		virtual Float get_kinAngVel( );
		Dynamic get_kinAngVel_dyn();

		virtual Float set_kinAngVel( Float kinAngVel);
		Dynamic set_kinAngVel_dyn();

		virtual Float get_torque( );
		Dynamic get_torque_dyn();

		virtual Float set_torque( Float torque);
		Dynamic set_torque_dyn();

		virtual ::nape::geom::AABB get_bounds( );
		Dynamic get_bounds_dyn();

		virtual bool get_allowMovement( );
		Dynamic get_allowMovement_dyn();

		virtual bool set_allowMovement( bool allowMovement);
		Dynamic set_allowMovement_dyn();

		virtual bool get_allowRotation( );
		Dynamic get_allowRotation_dyn();

		virtual bool set_allowRotation( bool allowRotation);
		Dynamic set_allowRotation_dyn();

		virtual ::nape::phys::MassMode get_massMode( );
		Dynamic get_massMode_dyn();

		virtual ::nape::phys::MassMode set_massMode( ::nape::phys::MassMode massMode);
		Dynamic set_massMode_dyn();

		virtual Float get_constraintMass( );
		Dynamic get_constraintMass_dyn();

		virtual Float get_mass( );
		Dynamic get_mass_dyn();

		virtual Float set_mass( Float mass);
		Dynamic set_mass_dyn();

		virtual ::nape::phys::GravMassMode get_gravMassMode( );
		Dynamic get_gravMassMode_dyn();

		virtual ::nape::phys::GravMassMode set_gravMassMode( ::nape::phys::GravMassMode gravMassMode);
		Dynamic set_gravMassMode_dyn();

		virtual Float get_gravMass( );
		Dynamic get_gravMass_dyn();

		virtual Float set_gravMass( Float gravMass);
		Dynamic set_gravMass_dyn();

		virtual Float get_gravMassScale( );
		Dynamic get_gravMassScale_dyn();

		virtual Float set_gravMassScale( Float gravMassScale);
		Dynamic set_gravMassScale_dyn();

		virtual ::nape::phys::InertiaMode get_inertiaMode( );
		Dynamic get_inertiaMode_dyn();

		virtual ::nape::phys::InertiaMode set_inertiaMode( ::nape::phys::InertiaMode inertiaMode);
		Dynamic set_inertiaMode_dyn();

		virtual Float get_constraintInertia( );
		Dynamic get_constraintInertia_dyn();

		virtual Float get_inertia( );
		Dynamic get_inertia_dyn();

		virtual Float set_inertia( Float inertia);
		Dynamic set_inertia_dyn();

		virtual ::nape::phys::BodyList connectedBodies( hx::Null< int >  depth,::nape::phys::BodyList output);
		Dynamic connectedBodies_dyn();

		virtual ::nape::phys::BodyList interactingBodies( ::nape::callbacks::InteractionType type,hx::Null< int >  depth,::nape::phys::BodyList output);
		Dynamic interactingBodies_dyn();

		virtual Float crushFactor( );
		Dynamic crushFactor_dyn();

		virtual ::nape::geom::Vec2 localPointToWorld( ::nape::geom::Vec2 point,hx::Null< bool >  weak);
		Dynamic localPointToWorld_dyn();

		virtual ::nape::geom::Vec2 worldPointToLocal( ::nape::geom::Vec2 point,hx::Null< bool >  weak);
		Dynamic worldPointToLocal_dyn();

		virtual ::nape::geom::Vec2 localVectorToWorld( ::nape::geom::Vec2 vector,hx::Null< bool >  weak);
		Dynamic localVectorToWorld_dyn();

		virtual ::nape::geom::Vec2 worldVectorToLocal( ::nape::geom::Vec2 vector,hx::Null< bool >  weak);
		Dynamic worldVectorToLocal_dyn();

		virtual ::nape::phys::Body applyImpulse( ::nape::geom::Vec2 impulse,::nape::geom::Vec2 pos,hx::Null< bool >  sleepable);
		Dynamic applyImpulse_dyn();

		virtual ::nape::phys::Body applyAngularImpulse( Float impulse,hx::Null< bool >  sleepable);
		Dynamic applyAngularImpulse_dyn();

		virtual ::nape::phys::Body translateShapes( ::nape::geom::Vec2 translation);
		Dynamic translateShapes_dyn();

		virtual ::nape::phys::Body rotateShapes( Float angle);
		Dynamic rotateShapes_dyn();

		virtual ::nape::phys::Body scaleShapes( Float scaleX,Float scaleY);
		Dynamic scaleShapes_dyn();

		virtual ::nape::phys::Body transformShapes( ::nape::geom::Mat23 matrix);
		Dynamic transformShapes_dyn();

		virtual ::nape::phys::Body align( );
		Dynamic align_dyn();

		virtual ::nape::phys::Body rotate( ::nape::geom::Vec2 centre,Float angle);
		Dynamic rotate_dyn();

		virtual ::nape::phys::Body setShapeMaterials( ::nape::phys::Material material);
		Dynamic setShapeMaterials_dyn();

		virtual ::nape::phys::Body setShapeFilters( ::nape::dynamics::InteractionFilter filter);
		Dynamic setShapeFilters_dyn();

		virtual ::nape::phys::Body setShapeFluidProperties( ::nape::phys::FluidProperties fluidProperties);
		Dynamic setShapeFluidProperties_dyn();

		virtual ::nape::geom::Vec2 get_localCOM( );
		Dynamic get_localCOM_dyn();

		virtual ::nape::geom::Vec2 get_worldCOM( );
		Dynamic get_worldCOM_dyn();

		virtual ::nape::geom::Vec3 normalImpulse( ::nape::phys::Body body,hx::Null< bool >  freshOnly);
		Dynamic normalImpulse_dyn();

		virtual ::nape::geom::Vec3 tangentImpulse( ::nape::phys::Body body,hx::Null< bool >  freshOnly);
		Dynamic tangentImpulse_dyn();

		virtual ::nape::geom::Vec3 totalContactsImpulse( ::nape::phys::Body body,hx::Null< bool >  freshOnly);
		Dynamic totalContactsImpulse_dyn();

		virtual Float rollingImpulse( ::nape::phys::Body body,hx::Null< bool >  freshOnly);
		Dynamic rollingImpulse_dyn();

		virtual ::nape::geom::Vec3 buoyancyImpulse( ::nape::phys::Body body);
		Dynamic buoyancyImpulse_dyn();

		virtual ::nape::geom::Vec3 dragImpulse( ::nape::phys::Body body);
		Dynamic dragImpulse_dyn();

		virtual ::nape::geom::Vec3 totalFluidImpulse( ::nape::phys::Body body);
		Dynamic totalFluidImpulse_dyn();

		virtual ::nape::geom::Vec3 constraintsImpulse( );
		Dynamic constraintsImpulse_dyn();

		virtual ::nape::geom::Vec3 totalImpulse( ::nape::phys::Body body,hx::Null< bool >  freshOnly);
		Dynamic totalImpulse_dyn();

		virtual bool contains( ::nape::geom::Vec2 point);
		Dynamic contains_dyn();

		virtual ::String toString( );

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_Body */ 
