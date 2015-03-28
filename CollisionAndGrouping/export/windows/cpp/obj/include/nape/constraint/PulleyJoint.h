#ifndef INCLUDED_nape_constraint_PulleyJoint
#define INCLUDED_nape_constraint_PulleyJoint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/constraint/Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,PulleyJoint)
HX_DECLARE_CLASS2(nape,geom,MatMN)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_PulleyJoint)
namespace nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  PulleyJoint_obj : public ::nape::constraint::Constraint_obj{
	public:
		typedef ::nape::constraint::Constraint_obj super;
		typedef PulleyJoint_obj OBJ_;
		PulleyJoint_obj();
		Void __construct(::nape::phys::Body body1,::nape::phys::Body body2,::nape::phys::Body body3,::nape::phys::Body body4,::nape::geom::Vec2 anchor1,::nape::geom::Vec2 anchor2,::nape::geom::Vec2 anchor3,::nape::geom::Vec2 anchor4,Float jointMin,Float jointMax,hx::Null< Float >  __o_ratio);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< PulleyJoint_obj > __new(::nape::phys::Body body1,::nape::phys::Body body2,::nape::phys::Body body3,::nape::phys::Body body4,::nape::geom::Vec2 anchor1,::nape::geom::Vec2 anchor2,::nape::geom::Vec2 anchor3,::nape::geom::Vec2 anchor4,Float jointMin,Float jointMax,hx::Null< Float >  __o_ratio);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~PulleyJoint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("PulleyJoint"); }

		::zpp_nape::constraint::ZPP_PulleyJoint zpp_inner_zn;
		virtual ::nape::phys::Body get_body1( );
		Dynamic get_body1_dyn();

		virtual ::nape::phys::Body set_body1( ::nape::phys::Body body1);
		Dynamic set_body1_dyn();

		virtual ::nape::phys::Body get_body2( );
		Dynamic get_body2_dyn();

		virtual ::nape::phys::Body set_body2( ::nape::phys::Body body2);
		Dynamic set_body2_dyn();

		virtual ::nape::phys::Body get_body3( );
		Dynamic get_body3_dyn();

		virtual ::nape::phys::Body set_body3( ::nape::phys::Body body3);
		Dynamic set_body3_dyn();

		virtual ::nape::phys::Body get_body4( );
		Dynamic get_body4_dyn();

		virtual ::nape::phys::Body set_body4( ::nape::phys::Body body4);
		Dynamic set_body4_dyn();

		virtual ::nape::geom::Vec2 get_anchor1( );
		Dynamic get_anchor1_dyn();

		virtual ::nape::geom::Vec2 set_anchor1( ::nape::geom::Vec2 anchor1);
		Dynamic set_anchor1_dyn();

		virtual ::nape::geom::Vec2 get_anchor2( );
		Dynamic get_anchor2_dyn();

		virtual ::nape::geom::Vec2 set_anchor2( ::nape::geom::Vec2 anchor2);
		Dynamic set_anchor2_dyn();

		virtual ::nape::geom::Vec2 get_anchor3( );
		Dynamic get_anchor3_dyn();

		virtual ::nape::geom::Vec2 set_anchor3( ::nape::geom::Vec2 anchor3);
		Dynamic set_anchor3_dyn();

		virtual ::nape::geom::Vec2 get_anchor4( );
		Dynamic get_anchor4_dyn();

		virtual ::nape::geom::Vec2 set_anchor4( ::nape::geom::Vec2 anchor4);
		Dynamic set_anchor4_dyn();

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

#endif /* INCLUDED_nape_constraint_PulleyJoint */ 
