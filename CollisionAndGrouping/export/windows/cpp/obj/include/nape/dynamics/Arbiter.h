#ifndef INCLUDED_nape_dynamics_Arbiter
#define INCLUDED_nape_dynamics_Arbiter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,PreFlag)
HX_DECLARE_CLASS2(nape,dynamics,Arbiter)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterType)
HX_DECLARE_CLASS2(nape,dynamics,CollisionArbiter)
HX_DECLARE_CLASS2(nape,dynamics,FluidArbiter)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
namespace nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  Arbiter_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Arbiter_obj OBJ_;
		Arbiter_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Arbiter_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Arbiter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Arbiter"); }

		::zpp_nape::dynamics::ZPP_Arbiter zpp_inner;
		virtual bool get_isSleeping( );
		Dynamic get_isSleeping_dyn();

		virtual ::nape::dynamics::ArbiterType get_type( );
		Dynamic get_type_dyn();

		virtual bool isCollisionArbiter( );
		Dynamic isCollisionArbiter_dyn();

		virtual bool isFluidArbiter( );
		Dynamic isFluidArbiter_dyn();

		virtual bool isSensorArbiter( );
		Dynamic isSensorArbiter_dyn();

		virtual ::nape::dynamics::CollisionArbiter get_collisionArbiter( );
		Dynamic get_collisionArbiter_dyn();

		virtual ::nape::dynamics::FluidArbiter get_fluidArbiter( );
		Dynamic get_fluidArbiter_dyn();

		virtual ::nape::shape::Shape get_shape1( );
		Dynamic get_shape1_dyn();

		virtual ::nape::shape::Shape get_shape2( );
		Dynamic get_shape2_dyn();

		virtual ::nape::phys::Body get_body1( );
		Dynamic get_body1_dyn();

		virtual ::nape::phys::Body get_body2( );
		Dynamic get_body2_dyn();

		virtual ::nape::callbacks::PreFlag get_state( );
		Dynamic get_state_dyn();

		virtual ::nape::geom::Vec3 totalImpulse( ::nape::phys::Body body,hx::Null< bool >  freshOnly);
		Dynamic totalImpulse_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace nape
} // end namespace dynamics

#endif /* INCLUDED_nape_dynamics_Arbiter */ 
