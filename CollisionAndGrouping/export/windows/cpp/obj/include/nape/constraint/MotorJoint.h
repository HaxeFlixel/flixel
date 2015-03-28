#ifndef INCLUDED_nape_constraint_MotorJoint
#define INCLUDED_nape_constraint_MotorJoint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/constraint/Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,MotorJoint)
HX_DECLARE_CLASS2(nape,geom,MatMN)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_MotorJoint)
namespace nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  MotorJoint_obj : public ::nape::constraint::Constraint_obj{
	public:
		typedef ::nape::constraint::Constraint_obj super;
		typedef MotorJoint_obj OBJ_;
		MotorJoint_obj();
		Void __construct(::nape::phys::Body body1,::nape::phys::Body body2,hx::Null< Float >  __o_rate,hx::Null< Float >  __o_ratio);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< MotorJoint_obj > __new(::nape::phys::Body body1,::nape::phys::Body body2,hx::Null< Float >  __o_rate,hx::Null< Float >  __o_ratio);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~MotorJoint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("MotorJoint"); }

		::zpp_nape::constraint::ZPP_MotorJoint zpp_inner_zn;
		virtual ::nape::phys::Body get_body1( );
		Dynamic get_body1_dyn();

		virtual ::nape::phys::Body set_body1( ::nape::phys::Body body1);
		Dynamic set_body1_dyn();

		virtual ::nape::phys::Body get_body2( );
		Dynamic get_body2_dyn();

		virtual ::nape::phys::Body set_body2( ::nape::phys::Body body2);
		Dynamic set_body2_dyn();

		virtual Float get_ratio( );
		Dynamic get_ratio_dyn();

		virtual Float set_ratio( Float ratio);
		Dynamic set_ratio_dyn();

		virtual Float get_rate( );
		Dynamic get_rate_dyn();

		virtual Float set_rate( Float rate);
		Dynamic set_rate_dyn();

		virtual ::nape::geom::MatMN impulse( );

		virtual ::nape::geom::Vec3 bodyImpulse( ::nape::phys::Body body);

		virtual Void visitBodies( Dynamic lambda);

};

} // end namespace nape
} // end namespace constraint

#endif /* INCLUDED_nape_constraint_MotorJoint */ 
