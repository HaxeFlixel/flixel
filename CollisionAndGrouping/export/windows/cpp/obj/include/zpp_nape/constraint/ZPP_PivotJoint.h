#ifndef INCLUDED_zpp_nape_constraint_ZPP_PivotJoint
#define INCLUDED_zpp_nape_constraint_ZPP_PivotJoint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/constraint/ZPP_Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,PivotJoint)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_CopyHelper)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_PivotJoint)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
namespace zpp_nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  ZPP_PivotJoint_obj : public ::zpp_nape::constraint::ZPP_Constraint_obj{
	public:
		typedef ::zpp_nape::constraint::ZPP_Constraint_obj super;
		typedef ZPP_PivotJoint_obj OBJ_;
		ZPP_PivotJoint_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_PivotJoint_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_PivotJoint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_PivotJoint"); }

		::nape::constraint::PivotJoint outer_zn;
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
		Float kMassa;
		Float kMassb;
		Float kMassc;
		Float jAccx;
		Float jAccy;
		Float jMax;
		Float gamma;
		Float biasx;
		Float biasy;
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

};

} // end namespace zpp_nape
} // end namespace constraint

#endif /* INCLUDED_zpp_nape_constraint_ZPP_PivotJoint */ 
