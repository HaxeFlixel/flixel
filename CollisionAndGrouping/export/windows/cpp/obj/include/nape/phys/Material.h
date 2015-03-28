#ifndef INCLUDED_nape_phys_Material
#define INCLUDED_nape_phys_Material

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Material)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Material)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  Material_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Material_obj OBJ_;
		Material_obj();
		Void __construct(hx::Null< Float >  __o_elasticity,hx::Null< Float >  __o_dynamicFriction,hx::Null< Float >  __o_staticFriction,hx::Null< Float >  __o_density,hx::Null< Float >  __o_rollingFriction);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Material_obj > __new(hx::Null< Float >  __o_elasticity,hx::Null< Float >  __o_dynamicFriction,hx::Null< Float >  __o_staticFriction,hx::Null< Float >  __o_density,hx::Null< Float >  __o_rollingFriction);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Material_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Material"); }

		::zpp_nape::phys::ZPP_Material zpp_inner;
		virtual Dynamic get_userData( );
		Dynamic get_userData_dyn();

		virtual ::nape::shape::ShapeList get_shapes( );
		Dynamic get_shapes_dyn();

		virtual ::nape::phys::Material copy( );
		Dynamic copy_dyn();

		virtual Float get_elasticity( );
		Dynamic get_elasticity_dyn();

		virtual Float set_elasticity( Float elasticity);
		Dynamic set_elasticity_dyn();

		virtual Float get_dynamicFriction( );
		Dynamic get_dynamicFriction_dyn();

		virtual Float set_dynamicFriction( Float dynamicFriction);
		Dynamic set_dynamicFriction_dyn();

		virtual Float get_staticFriction( );
		Dynamic get_staticFriction_dyn();

		virtual Float set_staticFriction( Float staticFriction);
		Dynamic set_staticFriction_dyn();

		virtual Float get_density( );
		Dynamic get_density_dyn();

		virtual Float set_density( Float density);
		Dynamic set_density_dyn();

		virtual Float get_rollingFriction( );
		Dynamic get_rollingFriction_dyn();

		virtual Float set_rollingFriction( Float rollingFriction);
		Dynamic set_rollingFriction_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::phys::Material wood( );
		static Dynamic wood_dyn();

		static ::nape::phys::Material steel( );
		static Dynamic steel_dyn();

		static ::nape::phys::Material ice( );
		static Dynamic ice_dyn();

		static ::nape::phys::Material rubber( );
		static Dynamic rubber_dyn();

		static ::nape::phys::Material glass( );
		static Dynamic glass_dyn();

		static ::nape::phys::Material sand( );
		static Dynamic sand_dyn();

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_Material */ 
