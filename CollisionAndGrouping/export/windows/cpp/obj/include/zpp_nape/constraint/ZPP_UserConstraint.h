#ifndef INCLUDED_zpp_nape_constraint_ZPP_UserConstraint
#define INCLUDED_zpp_nape_constraint_ZPP_UserConstraint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/constraint/ZPP_Constraint.h>
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,UserConstraint)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_CopyHelper)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_UserBody)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_UserConstraint)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
namespace zpp_nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  ZPP_UserConstraint_obj : public ::zpp_nape::constraint::ZPP_Constraint_obj{
	public:
		typedef ::zpp_nape::constraint::ZPP_Constraint_obj super;
		typedef ZPP_UserConstraint_obj OBJ_;
		ZPP_UserConstraint_obj();
		Void __construct(int dim,bool velonly);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_UserConstraint_obj > __new(int dim,bool velonly);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_UserConstraint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_UserConstraint"); }

		::nape::constraint::UserConstraint outer_zn;
		virtual Void bindVec2_invalidate( ::zpp_nape::geom::ZPP_Vec2 _);
		Dynamic bindVec2_invalidate_dyn();

		Array< ::Dynamic > bodies;
		int dim;
		Array< Float > jAcc;
		Array< Float > bias;
		virtual Void addBody( ::zpp_nape::phys::ZPP_Body b);
		Dynamic addBody_dyn();

		virtual bool remBody( ::zpp_nape::phys::ZPP_Body b);
		Dynamic remBody_dyn();

		virtual ::nape::geom::Vec3 bodyImpulse( ::zpp_nape::phys::ZPP_Body b);
		Dynamic bodyImpulse_dyn();

		virtual Void activeBodies( );

		virtual Void inactiveBodies( );

		bool stepped;
		virtual ::nape::constraint::Constraint copy( Array< ::Dynamic > dict,Array< ::Dynamic > todo);

		virtual Void validate( );

		virtual Void wake_connected( );

		virtual Void forest( );

		virtual bool pair_exists( int id,int di);

		virtual Void broken( );

		virtual Void clearcache( );

		virtual Float lsq( Array< Float > v);
		Dynamic lsq_dyn();

		virtual Void _clamp( Array< Float > v,Float max);
		Dynamic _clamp_dyn();

		Array< Float > L;
		virtual Array< Float > solve( Array< Float > m);
		Dynamic solve_dyn();

		Array< Float > y;
		virtual Void transform( Array< Float > L,Array< Float > x);
		Dynamic transform_dyn();

		Float soft;
		Float gamma;
		bool velonly;
		Float jMax;
		Array< Float > Keff;
		virtual bool preStep( Float dt);

		::nape::geom::Vec3 vec3;
		virtual Void warmStart( );

		Array< Float > J;
		Array< Float > jOld;
		virtual bool applyImpulseVel( );

		virtual bool applyImpulsePos( );

		virtual Void draw( ::nape::util::Debug g);

};

} // end namespace zpp_nape
} // end namespace constraint

#endif /* INCLUDED_zpp_nape_constraint_ZPP_UserConstraint */ 
