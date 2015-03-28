#ifndef INCLUDED_zpp_nape_constraint_ZPP_PulleyJoint
#define INCLUDED_zpp_nape_constraint_ZPP_PulleyJoint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/constraint/ZPP_Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,PulleyJoint)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_CopyHelper)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_PulleyJoint)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
namespace zpp_nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  ZPP_PulleyJoint_obj : public ::zpp_nape::constraint::ZPP_Constraint_obj{
	public:
		typedef ::zpp_nape::constraint::ZPP_Constraint_obj super;
		typedef ZPP_PulleyJoint_obj OBJ_;
		ZPP_PulleyJoint_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_PulleyJoint_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_PulleyJoint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_PulleyJoint"); }

		::nape::constraint::PulleyJoint outer_zn;
		Float ratio;
		Float jointMin;
		Float jointMax;
		bool slack;
		bool equal;
		virtual bool is_slack( );
		Dynamic is_slack_dyn();

		Float n12x;
		Float n12y;
		Float n34x;
		Float n34y;
		Float cx1;
		Float cx2;
		Float cx3;
		Float cx4;
		virtual ::nape::geom::Vec3 bodyImpulse( ::zpp_nape::phys::ZPP_Body b);
		Dynamic bodyImpulse_dyn();

		virtual Void activeBodies( );

		virtual Void inactiveBodies( );

		::zpp_nape::phys::ZPP_Body b1;
		Float a1localx;
		Float a1localy;
		Float a1relx;
		Float a1rely;
		virtual Void validate_a1( );
		Dynamic validate_a1_dyn();

		virtual Void invalidate_a1( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic invalidate_a1_dyn();

		virtual Void setup_a1( );
		Dynamic setup_a1_dyn();

		::nape::geom::Vec2 wrap_a1;
		::zpp_nape::phys::ZPP_Body b2;
		Float a2localx;
		Float a2localy;
		Float a2relx;
		Float a2rely;
		virtual Void validate_a2( );
		Dynamic validate_a2_dyn();

		virtual Void invalidate_a2( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic invalidate_a2_dyn();

		virtual Void setup_a2( );
		Dynamic setup_a2_dyn();

		::nape::geom::Vec2 wrap_a2;
		::zpp_nape::phys::ZPP_Body b3;
		Float a3localx;
		Float a3localy;
		Float a3relx;
		Float a3rely;
		virtual Void validate_a3( );
		Dynamic validate_a3_dyn();

		virtual Void invalidate_a3( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic invalidate_a3_dyn();

		virtual Void setup_a3( );
		Dynamic setup_a3_dyn();

		::nape::geom::Vec2 wrap_a3;
		::zpp_nape::phys::ZPP_Body b4;
		Float a4localx;
		Float a4localy;
		Float a4relx;
		Float a4rely;
		virtual Void validate_a4( );
		Dynamic validate_a4_dyn();

		virtual Void invalidate_a4( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic invalidate_a4_dyn();

		virtual Void setup_a4( );
		Dynamic setup_a4_dyn();

		::nape::geom::Vec2 wrap_a4;
		Float kMass;
		Float jAcc;
		Float jMax;
		Float gamma;
		Float bias;
		bool stepped;
		virtual ::nape::constraint::Constraint copy( Array< ::Dynamic > dict,Array< ::Dynamic > todo);

		virtual Void validate( );

		virtual Void wake_connected( );

		virtual Void forest( );

		virtual bool pair_exists( int id,int di);

		virtual Void clearcache( );

		virtual bool preStep( Float dt);

		virtual Void warmStart( );

		virtual bool applyImpulseVel( );

		virtual bool applyImpulsePos( );

		virtual Void draw( ::nape::util::Debug g);

		virtual Void drawLink( ::nape::util::Debug g,::nape::geom::Vec2 a1,::nape::geom::Vec2 a2,::nape::geom::Vec2 n,Float nl,Float bias,Float scale,int ca,int cb);
		Dynamic drawLink_dyn();

};

} // end namespace zpp_nape
} // end namespace constraint

#endif /* INCLUDED_zpp_nape_constraint_ZPP_PulleyJoint */ 
