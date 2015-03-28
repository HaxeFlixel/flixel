#ifndef INCLUDED_nape_phys_FluidProperties
#define INCLUDED_nape_phys_FluidProperties

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,phys,FluidProperties)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_FluidProperties)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  FluidProperties_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FluidProperties_obj OBJ_;
		FluidProperties_obj();
		Void __construct(hx::Null< Float >  __o_density,hx::Null< Float >  __o_viscosity);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FluidProperties_obj > __new(hx::Null< Float >  __o_density,hx::Null< Float >  __o_viscosity);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FluidProperties_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FluidProperties"); }

		::zpp_nape::phys::ZPP_FluidProperties zpp_inner;
		virtual Dynamic get_userData( );
		Dynamic get_userData_dyn();

		virtual ::nape::shape::ShapeList get_shapes( );
		Dynamic get_shapes_dyn();

		virtual ::nape::phys::FluidProperties copy( );
		Dynamic copy_dyn();

		virtual Float get_density( );
		Dynamic get_density_dyn();

		virtual Float set_density( Float density);
		Dynamic set_density_dyn();

		virtual Float get_viscosity( );
		Dynamic get_viscosity_dyn();

		virtual Float set_viscosity( Float viscosity);
		Dynamic set_viscosity_dyn();

		virtual ::nape::geom::Vec2 get_gravity( );
		Dynamic get_gravity_dyn();

		virtual ::nape::geom::Vec2 set_gravity( ::nape::geom::Vec2 gravity);
		Dynamic set_gravity_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_FluidProperties */ 
