#ifndef INCLUDED_nape_constraint_AngleJoint
#define INCLUDED_nape_constraint_AngleJoint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/constraint/Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,AngleJoint)
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,geom,MatMN)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_AngleJoint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
namespace nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  AngleJoint_obj : public ::nape::constraint::Constraint_obj{
	public:
		typedef ::nape::constraint::Constraint_obj super;
		typedef AngleJoint_obj OBJ_;
		AngleJoint_obj();
		Void __construct(::nape::phys::Body body1,::nape::phys::Body body2,Float jointMin,Float jointMax,hx::Null< Float >  __o_ratio);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< AngleJoint_obj > __new(::nape::phys::Body body1,::nape::phys::Body body2,Float jointMin,Float jointMax,hx::Null< Float >  __o_ratio);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~AngleJoint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("AngleJoint"); }

		::zpp_nape::constraint::ZPP_AngleJoint zpp_inner_zn;
		virtual ::nape::phys::Body get_body1( );
		Dynamic get_body1_dyn();

		virtual ::nape::phys::Body set_body1( ::nape::phys::Body body1);
		Dynamic set_body1_dyn();

		virtual ::nape::phys::Body get_body2( );
		Dynamic get_body2_dyn();

		virtual ::nape::phys::Body set_body2( ::nape::phys::Body body2);
		Dynamic set_body2_dyn();

		virtual Float get_jointMin( );
		Dynamic get_jointMin_dyn();

		virtual Float set_jointMin( Float jointMin);
		Dynamic set_jointMin_dyn();

		virtual Float get_jointMax( );
		Dynamic get_jointMax_dyn();

		virtual Float set_jointMax( Float jointMax);
		Dynamic set_jointMax_dyn();

		virtual Float get_ratio( );
		Dynamic get_ratio_dyn();

		virtual Float set_ratio( Float ratio);
		Dynamic set_ratio_dyn();

		virtual bool isSlack( );
		Dynamic isSlack_dyn();

		virtual ::nape::geom::MatMN impulse( );

		virtual ::nape::geom::Vec3 bodyImpulse( ::nape::phys::Body body);

		virtual Void visitBodies( Dynamic lambda);

};

} // end namespace nape
} // end namespace constraint

#endif /* INCLUDED_nape_constraint_AngleJoint */ 
