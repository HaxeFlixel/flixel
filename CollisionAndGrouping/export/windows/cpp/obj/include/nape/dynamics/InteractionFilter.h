#ifndef INCLUDED_nape_dynamics_InteractionFilter
#define INCLUDED_nape_dynamics_InteractionFilter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,InteractionFilter)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_InteractionFilter)
namespace nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  InteractionFilter_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef InteractionFilter_obj OBJ_;
		InteractionFilter_obj();
		Void __construct(hx::Null< int >  __o_collisionGroup,hx::Null< int >  __o_collisionMask,hx::Null< int >  __o_sensorGroup,hx::Null< int >  __o_sensorMask,hx::Null< int >  __o_fluidGroup,hx::Null< int >  __o_fluidMask);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< InteractionFilter_obj > __new(hx::Null< int >  __o_collisionGroup,hx::Null< int >  __o_collisionMask,hx::Null< int >  __o_sensorGroup,hx::Null< int >  __o_sensorMask,hx::Null< int >  __o_fluidGroup,hx::Null< int >  __o_fluidMask);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~InteractionFilter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("InteractionFilter"); }

		::zpp_nape::dynamics::ZPP_InteractionFilter zpp_inner;
		virtual Dynamic get_userData( );
		Dynamic get_userData_dyn();

		virtual ::nape::shape::ShapeList get_shapes( );
		Dynamic get_shapes_dyn();

		virtual int get_collisionGroup( );
		Dynamic get_collisionGroup_dyn();

		virtual int set_collisionGroup( int collisionGroup);
		Dynamic set_collisionGroup_dyn();

		virtual int get_collisionMask( );
		Dynamic get_collisionMask_dyn();

		virtual int set_collisionMask( int collisionMask);
		Dynamic set_collisionMask_dyn();

		virtual int get_sensorGroup( );
		Dynamic get_sensorGroup_dyn();

		virtual int set_sensorGroup( int sensorGroup);
		Dynamic set_sensorGroup_dyn();

		virtual int get_sensorMask( );
		Dynamic get_sensorMask_dyn();

		virtual int set_sensorMask( int sensorMask);
		Dynamic set_sensorMask_dyn();

		virtual int get_fluidGroup( );
		Dynamic get_fluidGroup_dyn();

		virtual int set_fluidGroup( int fluidGroup);
		Dynamic set_fluidGroup_dyn();

		virtual int get_fluidMask( );
		Dynamic get_fluidMask_dyn();

		virtual int set_fluidMask( int fluidMask);
		Dynamic set_fluidMask_dyn();

		virtual bool shouldCollide( ::nape::dynamics::InteractionFilter filter);
		Dynamic shouldCollide_dyn();

		virtual bool shouldSense( ::nape::dynamics::InteractionFilter filter);
		Dynamic shouldSense_dyn();

		virtual bool shouldFlow( ::nape::dynamics::InteractionFilter filter);
		Dynamic shouldFlow_dyn();

		virtual ::nape::dynamics::InteractionFilter copy( );
		Dynamic copy_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace nape
} // end namespace dynamics

#endif /* INCLUDED_nape_dynamics_InteractionFilter */ 
