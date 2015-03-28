#ifndef INCLUDED_nape_dynamics_ArbiterType
#define INCLUDED_nape_dynamics_ArbiterType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,ArbiterType)
namespace nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ArbiterType_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ArbiterType_obj OBJ_;
		ArbiterType_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ArbiterType_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ArbiterType_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ArbiterType"); }

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::dynamics::ArbiterType get_COLLISION( );
		static Dynamic get_COLLISION_dyn();

		static ::nape::dynamics::ArbiterType get_SENSOR( );
		static Dynamic get_SENSOR_dyn();

		static ::nape::dynamics::ArbiterType get_FLUID( );
		static Dynamic get_FLUID_dyn();

};

} // end namespace nape
} // end namespace dynamics

#endif /* INCLUDED_nape_dynamics_ArbiterType */ 
