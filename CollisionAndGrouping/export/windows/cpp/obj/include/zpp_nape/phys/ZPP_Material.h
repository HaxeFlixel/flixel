#ifndef INCLUDED_zpp_nape_phys_ZPP_Material
#define INCLUDED_zpp_nape_phys_ZPP_Material

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Material)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Material)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Shape)
namespace zpp_nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Material_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Material_obj OBJ_;
		ZPP_Material_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Material_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Material_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Material"); }

		::zpp_nape::phys::ZPP_Material next;
		Dynamic userData;
		::nape::phys::Material outer;
		virtual ::nape::phys::Material wrapper( );
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

		Float dynamicFriction;
		Float staticFriction;
		Float density;
		Float elasticity;
		Float rollingFriction;
		virtual ::zpp_nape::phys::ZPP_Material copy( );
		Dynamic copy_dyn();

		virtual Void set( ::zpp_nape::phys::ZPP_Material x);
		Dynamic set_dyn();

		virtual Void invalidate( int x);
		Dynamic invalidate_dyn();

		static ::zpp_nape::phys::ZPP_Material zpp_pool;
		static int WAKE;
		static int PROPS;
		static int ANGDRAG;
		static int ARBITERS;
};

} // end namespace zpp_nape
} // end namespace phys

#endif /* INCLUDED_zpp_nape_phys_ZPP_Material */ 
