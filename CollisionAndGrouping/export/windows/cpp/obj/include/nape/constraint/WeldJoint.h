#ifndef INCLUDED_nape_constraint_WeldJoint
#define INCLUDED_nape_constraint_WeldJoint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/constraint/Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,WeldJoint)
HX_DECLARE_CLASS2(nape,geom,MatMN)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_WeldJoint)
namespace nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  WeldJoint_obj : public ::nape::constraint::Constraint_obj{
	public:
		typedef ::nape::constraint::Constraint_obj super;
		typedef WeldJoint_obj OBJ_;
		WeldJoint_obj();
		Void __construct(::nape::phys::Body body1,::nape::phys::Body body2,::nape::geom::Vec2 anchor1,::nape::geom::Vec2 anchor2,hx::Null< Float >  __o_phase);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< WeldJoint_obj > __new(::nape::phys::Body body1,::nape::phys::Body body2,::nape::geom::Vec2 anchor1,::nape::geom::Vec2 anchor2,hx::Null< Float >  __o_phase);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~WeldJoint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("WeldJoint"); }

		::zpp_nape::constraint::ZPP_WeldJoint zpp_inner_zn;
		virtual ::nape::phys::Body get_body1( );
		Dynamic get_body1_dyn();

		virtual ::nape::phys::Body set_body1( ::nape::phys::Body body1);
		Dynamic set_body1_dyn();

		virtual ::nape::phys::Body get_body2( );
		Dynamic get_body2_dyn();

		virtual ::nape::phys::Body set_body2( ::nape::phys::Body body2);
		Dynamic set_body2_dyn();

		virtual ::nape::geom::Vec2 get_anchor1( );
		Dynamic get_anchor1_dyn();

		virtual ::nape::geom::Vec2 set_anchor1( ::nape::geom::Vec2 anchor1);
		Dynamic set_anchor1_dyn();

		virtual ::nape::geom::Vec2 get_anchor2( );
		Dynamic get_anchor2_dyn();

		virtual ::nape::geom::Vec2 set_anchor2( ::nape::geom::Vec2 anchor2);
		Dynamic set_anchor2_dyn();

		virtual Float get_phase( );
		Dynamic get_phase_dyn();

		virtual Float set_phase( Float phase);
		Dynamic set_phase_dyn();

		virtual ::nape::geom::MatMN impulse( );

		virtual ::nape::geom::Vec3 bodyImpulse( ::nape::phys::Body body);

		virtual Void visitBodies( Dynamic lambda);

};

} // end namespace nape
} // end namespace constraint

#endif /* INCLUDED_nape_constraint_WeldJoint */ 
