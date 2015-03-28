#ifndef INCLUDED_zpp_nape_dynamics_ZPP_Arbiter
#define INCLUDED_zpp_nape_dynamics_ZPP_Arbiter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,Arbiter)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterType)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_ColArbiter)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_FluidArbiter)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_SensorArbiter)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBPair)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
namespace zpp_nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Arbiter_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Arbiter_obj OBJ_;
		ZPP_Arbiter_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Arbiter_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Arbiter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Arbiter"); }

		::nape::dynamics::Arbiter outer;
		virtual ::nape::dynamics::Arbiter wrapper( );
		Dynamic wrapper_dyn();

		virtual bool inactiveme( );
		Dynamic inactiveme_dyn();

		::zpp_nape::dynamics::ZPP_Arbiter hnext;
		int id;
		int di;
		int stamp;
		int up_stamp;
		int sleep_stamp;
		int endGenerated;
		bool active;
		bool cleared;
		bool sleeping;
		int present;
		bool intchange;
		bool presentable;
		bool continuous;
		bool fresh;
		int immState;
		virtual bool acting( );
		Dynamic acting_dyn();

		bool invalidated;
		::zpp_nape::phys::ZPP_Body b1;
		::zpp_nape::phys::ZPP_Body b2;
		::zpp_nape::shape::ZPP_Shape ws1;
		::zpp_nape::shape::ZPP_Shape ws2;
		::zpp_nape::space::ZPP_AABBPair pair;
		virtual Void swap_features( );
		Dynamic swap_features_dyn();

		int type;
		::zpp_nape::dynamics::ZPP_ColArbiter colarb;
		::zpp_nape::dynamics::ZPP_FluidArbiter fluidarb;
		::zpp_nape::dynamics::ZPP_SensorArbiter sensorarb;
		virtual Void lazyRetire( ::zpp_nape::space::ZPP_Space s,::zpp_nape::phys::ZPP_Body b);
		Dynamic lazyRetire_dyn();

		virtual Void sup_assign( ::zpp_nape::shape::ZPP_Shape s1,::zpp_nape::shape::ZPP_Shape s2,int id,int di);
		Dynamic sup_assign_dyn();

		virtual Void sup_retire( );
		Dynamic sup_retire_dyn();

		static bool internal;
		static int COL;
		static int FLUID;
		static int SENSOR;
		static Array< ::Dynamic > types;
};

} // end namespace zpp_nape
} // end namespace dynamics

#endif /* INCLUDED_zpp_nape_dynamics_ZPP_Arbiter */ 
