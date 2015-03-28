#ifndef INCLUDED_nape_constraint_UserConstraint
#define INCLUDED_nape_constraint_UserConstraint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/constraint/Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,UserConstraint)
HX_DECLARE_CLASS2(nape,geom,MatMN)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_UserConstraint)
namespace nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  UserConstraint_obj : public ::nape::constraint::Constraint_obj{
	public:
		typedef ::nape::constraint::Constraint_obj super;
		typedef UserConstraint_obj OBJ_;
		UserConstraint_obj();
		Void __construct(int dimensions,hx::Null< bool >  __o_velocityOnly);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< UserConstraint_obj > __new(int dimensions,hx::Null< bool >  __o_velocityOnly);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~UserConstraint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("UserConstraint"); }

		::zpp_nape::constraint::ZPP_UserConstraint zpp_inner_zn;
		virtual ::nape::geom::Vec2 __bindVec2( );
		Dynamic __bindVec2_dyn();

		virtual ::nape::constraint::UserConstraint __copy( );
		Dynamic __copy_dyn();

		virtual Void __broken( );
		Dynamic __broken_dyn();

		virtual Void __validate( );
		Dynamic __validate_dyn();

		virtual Void __draw( ::nape::util::Debug debug);
		Dynamic __draw_dyn();

		virtual Void __prepare( );
		Dynamic __prepare_dyn();

		virtual Void __position( Array< Float > err);
		Dynamic __position_dyn();

		virtual Void __velocity( Array< Float > err);
		Dynamic __velocity_dyn();

		virtual Void __eff_mass( Array< Float > eff);
		Dynamic __eff_mass_dyn();

		virtual Void __clamp( Array< Float > jAcc);
		Dynamic __clamp_dyn();

		virtual Void __impulse( Array< Float > imp,::nape::phys::Body body,::nape::geom::Vec3 out);
		Dynamic __impulse_dyn();

		virtual ::nape::geom::MatMN impulse( );

		virtual ::nape::geom::Vec3 bodyImpulse( ::nape::phys::Body body);

		virtual Void visitBodies( Dynamic lambda);

		virtual Void __invalidate( );
		Dynamic __invalidate_dyn();

		virtual ::nape::phys::Body __registerBody( ::nape::phys::Body oldBody,::nape::phys::Body newBody);
		Dynamic __registerBody_dyn();

};

} // end namespace nape
} // end namespace constraint

#endif /* INCLUDED_nape_constraint_UserConstraint */ 
