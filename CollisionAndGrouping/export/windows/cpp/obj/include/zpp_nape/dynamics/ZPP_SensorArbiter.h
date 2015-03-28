#ifndef INCLUDED_zpp_nape_dynamics_ZPP_SensorArbiter
#define INCLUDED_zpp_nape_dynamics_ZPP_SensorArbiter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/dynamics/ZPP_Arbiter.h>
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_SensorArbiter)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
namespace zpp_nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ZPP_SensorArbiter_obj : public ::zpp_nape::dynamics::ZPP_Arbiter_obj{
	public:
		typedef ::zpp_nape::dynamics::ZPP_Arbiter_obj super;
		typedef ZPP_SensorArbiter_obj OBJ_;
		ZPP_SensorArbiter_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_SensorArbiter_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_SensorArbiter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_SensorArbiter"); }

		::zpp_nape::dynamics::ZPP_SensorArbiter next;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual Void assign( ::zpp_nape::shape::ZPP_Shape s1,::zpp_nape::shape::ZPP_Shape s2,int id,int di);
		Dynamic assign_dyn();

		virtual Void retire( );
		Dynamic retire_dyn();

		virtual Void makemutable( );
		Dynamic makemutable_dyn();

		virtual Void makeimmutable( );
		Dynamic makeimmutable_dyn();

		static ::zpp_nape::dynamics::ZPP_SensorArbiter zpp_pool;
};

} // end namespace zpp_nape
} // end namespace dynamics

#endif /* INCLUDED_zpp_nape_dynamics_ZPP_SensorArbiter */ 
