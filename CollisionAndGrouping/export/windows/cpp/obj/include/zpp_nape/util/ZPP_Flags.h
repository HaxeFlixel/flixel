#ifndef INCLUDED_zpp_nape_util_ZPP_Flags
#define INCLUDED_zpp_nape_util_ZPP_Flags

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,CbEvent)
HX_DECLARE_CLASS2(nape,callbacks,InteractionType)
HX_DECLARE_CLASS2(nape,callbacks,ListenerType)
HX_DECLARE_CLASS2(nape,callbacks,PreFlag)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterType)
HX_DECLARE_CLASS2(nape,geom,Winding)
HX_DECLARE_CLASS2(nape,phys,BodyType)
HX_DECLARE_CLASS2(nape,phys,GravMassMode)
HX_DECLARE_CLASS2(nape,phys,InertiaMode)
HX_DECLARE_CLASS2(nape,phys,MassMode)
HX_DECLARE_CLASS2(nape,shape,ShapeType)
HX_DECLARE_CLASS2(nape,shape,ValidationResult)
HX_DECLARE_CLASS2(nape,space,Broadphase)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Flags)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Flags_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Flags_obj OBJ_;
		ZPP_Flags_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Flags_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Flags_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_Flags"); }

		static bool internal;
		static int id_ImmState_ACCEPT;
		static int id_ImmState_IGNORE;
		static int id_ImmState_ALWAYS;
		static int id_GravMassMode_DEFAULT;
		static int id_GravMassMode_FIXED;
		static int id_GravMassMode_SCALED;
		static int id_InertiaMode_DEFAULT;
		static int id_InertiaMode_FIXED;
		static int id_MassMode_DEFAULT;
		static int id_MassMode_FIXED;
		static int id_BodyType_STATIC;
		static int id_BodyType_DYNAMIC;
		static int id_BodyType_KINEMATIC;
		static int id_ListenerType_BODY;
		static int id_PreFlag_ACCEPT;
		static int id_ListenerType_CONSTRAINT;
		static int id_PreFlag_IGNORE;
		static int id_ListenerType_INTERACTION;
		static int id_PreFlag_ACCEPT_ONCE;
		static int id_ListenerType_PRE;
		static int id_PreFlag_IGNORE_ONCE;
		static int id_CbEvent_BEGIN;
		static int id_InteractionType_COLLISION;
		static int id_CbEvent_ONGOING;
		static int id_InteractionType_SENSOR;
		static int id_CbEvent_END;
		static int id_InteractionType_FLUID;
		static int id_CbEvent_WAKE;
		static int id_InteractionType_ANY;
		static int id_CbEvent_SLEEP;
		static int id_CbEvent_BREAK;
		static int id_CbEvent_PRE;
		static int id_Winding_UNDEFINED;
		static int id_Winding_CLOCKWISE;
		static int id_Winding_ANTICLOCKWISE;
		static int id_ValidationResult_VALID;
		static int id_ValidationResult_DEGENERATE;
		static int id_ValidationResult_CONCAVE;
		static int id_ValidationResult_SELF_INTERSECTING;
		static int id_ShapeType_CIRCLE;
		static int id_ShapeType_POLYGON;
		static int id_Broadphase_DYNAMIC_AABB_TREE;
		static int id_Broadphase_SWEEP_AND_PRUNE;
		static int id_ArbiterType_COLLISION;
		static int id_ArbiterType_SENSOR;
		static int id_ArbiterType_FLUID;
		static ::nape::phys::GravMassMode GravMassMode_DEFAULT;
		static ::nape::phys::GravMassMode GravMassMode_FIXED;
		static ::nape::phys::GravMassMode GravMassMode_SCALED;
		static ::nape::phys::InertiaMode InertiaMode_DEFAULT;
		static ::nape::phys::InertiaMode InertiaMode_FIXED;
		static ::nape::phys::MassMode MassMode_DEFAULT;
		static ::nape::phys::MassMode MassMode_FIXED;
		static ::nape::phys::BodyType BodyType_STATIC;
		static ::nape::phys::BodyType BodyType_DYNAMIC;
		static ::nape::phys::BodyType BodyType_KINEMATIC;
		static ::nape::callbacks::ListenerType ListenerType_BODY;
		static ::nape::callbacks::PreFlag PreFlag_ACCEPT;
		static ::nape::callbacks::ListenerType ListenerType_CONSTRAINT;
		static ::nape::callbacks::PreFlag PreFlag_IGNORE;
		static ::nape::callbacks::ListenerType ListenerType_INTERACTION;
		static ::nape::callbacks::PreFlag PreFlag_ACCEPT_ONCE;
		static ::nape::callbacks::ListenerType ListenerType_PRE;
		static ::nape::callbacks::PreFlag PreFlag_IGNORE_ONCE;
		static ::nape::callbacks::CbEvent CbEvent_BEGIN;
		static ::nape::callbacks::InteractionType InteractionType_COLLISION;
		static ::nape::callbacks::CbEvent CbEvent_ONGOING;
		static ::nape::callbacks::InteractionType InteractionType_SENSOR;
		static ::nape::callbacks::CbEvent CbEvent_END;
		static ::nape::callbacks::InteractionType InteractionType_FLUID;
		static ::nape::callbacks::CbEvent CbEvent_WAKE;
		static ::nape::callbacks::InteractionType InteractionType_ANY;
		static ::nape::callbacks::CbEvent CbEvent_SLEEP;
		static ::nape::callbacks::CbEvent CbEvent_BREAK;
		static ::nape::callbacks::CbEvent CbEvent_PRE;
		static ::nape::geom::Winding Winding_UNDEFINED;
		static ::nape::geom::Winding Winding_CLOCKWISE;
		static ::nape::geom::Winding Winding_ANTICLOCKWISE;
		static ::nape::shape::ValidationResult ValidationResult_VALID;
		static ::nape::shape::ValidationResult ValidationResult_DEGENERATE;
		static ::nape::shape::ValidationResult ValidationResult_CONCAVE;
		static ::nape::shape::ValidationResult ValidationResult_SELF_INTERSECTING;
		static ::nape::shape::ShapeType ShapeType_CIRCLE;
		static ::nape::shape::ShapeType ShapeType_POLYGON;
		static ::nape::space::Broadphase Broadphase_DYNAMIC_AABB_TREE;
		static ::nape::space::Broadphase Broadphase_SWEEP_AND_PRUNE;
		static ::nape::dynamics::ArbiterType ArbiterType_COLLISION;
		static ::nape::dynamics::ArbiterType ArbiterType_SENSOR;
		static ::nape::dynamics::ArbiterType ArbiterType_FLUID;
};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZPP_Flags */ 
