#ifndef INCLUDED_nape_dynamics_Contact
#define INCLUDED_nape_dynamics_Contact

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,Arbiter)
HX_DECLARE_CLASS2(nape,dynamics,CollisionArbiter)
HX_DECLARE_CLASS2(nape,dynamics,Contact)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Contact)
namespace nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  Contact_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Contact_obj OBJ_;
		Contact_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Contact_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Contact_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Contact"); }

		::zpp_nape::dynamics::ZPP_Contact zpp_inner;
		virtual ::nape::dynamics::CollisionArbiter get_arbiter( );
		Dynamic get_arbiter_dyn();

		virtual Float get_penetration( );
		Dynamic get_penetration_dyn();

		virtual ::nape::geom::Vec2 get_position( );
		Dynamic get_position_dyn();

		virtual bool get_fresh( );
		Dynamic get_fresh_dyn();

		virtual ::nape::geom::Vec3 normalImpulse( ::nape::phys::Body body);
		Dynamic normalImpulse_dyn();

		virtual ::nape::geom::Vec3 tangentImpulse( ::nape::phys::Body body);
		Dynamic tangentImpulse_dyn();

		virtual Float rollingImpulse( ::nape::phys::Body body);
		Dynamic rollingImpulse_dyn();

		virtual ::nape::geom::Vec3 totalImpulse( ::nape::phys::Body body);
		Dynamic totalImpulse_dyn();

		virtual Float get_friction( );
		Dynamic get_friction_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace nape
} // end namespace dynamics

#endif /* INCLUDED_nape_dynamics_Contact */ 
