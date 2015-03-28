#ifndef INCLUDED_zpp_nape_dynamics_ZPP_InteractionFilter
#define INCLUDED_zpp_nape_dynamics_ZPP_InteractionFilter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,InteractionFilter)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_InteractionFilter)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Shape)
namespace zpp_nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ZPP_InteractionFilter_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_InteractionFilter_obj OBJ_;
		ZPP_InteractionFilter_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_InteractionFilter_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_InteractionFilter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_InteractionFilter"); }

		::zpp_nape::dynamics::ZPP_InteractionFilter next;
		Dynamic userData;
		::nape::dynamics::InteractionFilter outer;
		virtual ::nape::dynamics::InteractionFilter wrapper( );
		Dynamic wrapper_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		::zpp_nape::util::ZNPList_ZPP_Shape shapes;
		::nape::shape::ShapeList wrap_shapes;
		virtual Void feature_cons( );
		Dynamic feature_cons_dyn();

		virtual Void addShape( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic addShape_dyn();

		virtual Void remShape( ::zpp_nape::shape::ZPP_Shape shape);
		Dynamic remShape_dyn();

		virtual ::zpp_nape::dynamics::ZPP_InteractionFilter copy( );
		Dynamic copy_dyn();

		int collisionGroup;
		int collisionMask;
		virtual bool shouldCollide( ::zpp_nape::dynamics::ZPP_InteractionFilter x);
		Dynamic shouldCollide_dyn();

		int sensorGroup;
		int sensorMask;
		virtual bool shouldSense( ::zpp_nape::dynamics::ZPP_InteractionFilter x);
		Dynamic shouldSense_dyn();

		int fluidGroup;
		int fluidMask;
		virtual bool shouldFlow( ::zpp_nape::dynamics::ZPP_InteractionFilter x);
		Dynamic shouldFlow_dyn();

		virtual Void invalidate( );
		Dynamic invalidate_dyn();

		static ::zpp_nape::dynamics::ZPP_InteractionFilter zpp_pool;
};

} // end namespace zpp_nape
} // end namespace dynamics

#endif /* INCLUDED_zpp_nape_dynamics_ZPP_InteractionFilter */ 
