#ifndef INCLUDED_nape_constraint_Constraint
#define INCLUDED_nape_constraint_Constraint

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,CbTypeList)
HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,geom,MatMN)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Compound)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,space,Space)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
namespace nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  Constraint_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Constraint_obj OBJ_;
		Constraint_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Constraint_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Constraint_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Constraint"); }

		::zpp_nape::constraint::ZPP_Constraint zpp_inner;
		virtual Dynamic get_userData( );
		Dynamic get_userData_dyn();

		bool debugDraw;
		virtual ::nape::phys::Compound get_compound( );
		Dynamic get_compound_dyn();

		virtual ::nape::phys::Compound set_compound( ::nape::phys::Compound compound);
		Dynamic set_compound_dyn();

		virtual ::nape::space::Space get_space( );
		Dynamic get_space_dyn();

		virtual ::nape::space::Space set_space( ::nape::space::Space space);
		Dynamic set_space_dyn();

		virtual bool get_isSleeping( );
		Dynamic get_isSleeping_dyn();

		virtual bool get_active( );
		Dynamic get_active_dyn();

		virtual bool set_active( bool active);
		Dynamic set_active_dyn();

		virtual bool get_ignore( );
		Dynamic get_ignore_dyn();

		virtual bool set_ignore( bool ignore);
		Dynamic set_ignore_dyn();

		virtual bool get_stiff( );
		Dynamic get_stiff_dyn();

		virtual bool set_stiff( bool stiff);
		Dynamic set_stiff_dyn();

		virtual Float get_frequency( );
		Dynamic get_frequency_dyn();

		virtual Float set_frequency( Float frequency);
		Dynamic set_frequency_dyn();

		virtual Float get_damping( );
		Dynamic get_damping_dyn();

		virtual Float set_damping( Float damping);
		Dynamic set_damping_dyn();

		virtual Float get_maxForce( );
		Dynamic get_maxForce_dyn();

		virtual Float set_maxForce( Float maxForce);
		Dynamic set_maxForce_dyn();

		virtual Float get_maxError( );
		Dynamic get_maxError_dyn();

		virtual Float set_maxError( Float maxError);
		Dynamic set_maxError_dyn();

		virtual bool get_breakUnderForce( );
		Dynamic get_breakUnderForce_dyn();

		virtual bool set_breakUnderForce( bool breakUnderForce);
		Dynamic set_breakUnderForce_dyn();

		virtual bool get_breakUnderError( );
		Dynamic get_breakUnderError_dyn();

		virtual bool set_breakUnderError( bool breakUnderError);
		Dynamic set_breakUnderError_dyn();

		virtual bool get_removeOnBreak( );
		Dynamic get_removeOnBreak_dyn();

		virtual bool set_removeOnBreak( bool removeOnBreak);
		Dynamic set_removeOnBreak_dyn();

		virtual ::nape::geom::MatMN impulse( );
		Dynamic impulse_dyn();

		virtual ::nape::geom::Vec3 bodyImpulse( ::nape::phys::Body body);
		Dynamic bodyImpulse_dyn();

		virtual Void visitBodies( Dynamic lambda);
		Dynamic visitBodies_dyn();

		virtual ::nape::callbacks::CbTypeList get_cbTypes( );
		Dynamic get_cbTypes_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::constraint::Constraint copy( );
		Dynamic copy_dyn();

};

} // end namespace nape
} // end namespace constraint

#endif /* INCLUDED_nape_constraint_Constraint */ 
