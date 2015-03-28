#ifndef INCLUDED_zpp_nape_shape_ZPP_Circle
#define INCLUDED_zpp_nape_shape_ZPP_Circle

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/shape/ZPP_Shape.h>
HX_DECLARE_CLASS2(nape,geom,Mat23)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,Circle)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Circle)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
namespace zpp_nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Circle_obj : public ::zpp_nape::shape::ZPP_Shape_obj{
	public:
		typedef ::zpp_nape::shape::ZPP_Shape_obj super;
		typedef ZPP_Circle_obj OBJ_;
		ZPP_Circle_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Circle_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Circle_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Circle"); }

		::nape::shape::Circle outer_zn;
		Float radius;
		virtual Void __clear( );
		Dynamic __clear_dyn();

		virtual Void invalidate_radius( );
		Dynamic invalidate_radius_dyn();

		virtual Void localCOM_validate( );
		Dynamic localCOM_validate_dyn();

		virtual Void localCOM_invalidate( ::zpp_nape::geom::ZPP_Vec2 x);
		Dynamic localCOM_invalidate_dyn();

		virtual Void localCOM_immutable( );
		Dynamic localCOM_immutable_dyn();

		virtual Void setupLocalCOM( );
		Dynamic setupLocalCOM_dyn();

		virtual Void __validate_aabb( );
		Dynamic __validate_aabb_dyn();

		virtual Void _force_validate_aabb( );
		Dynamic _force_validate_aabb_dyn();

		virtual Void __validate_sweepRadius( );
		Dynamic __validate_sweepRadius_dyn();

		virtual Void __validate_area_inertia( );
		Dynamic __validate_area_inertia_dyn();

		virtual Void __validate_angDrag( );
		Dynamic __validate_angDrag_dyn();

		virtual Void __scale( Float sx,Float sy);
		Dynamic __scale_dyn();

		virtual Void __translate( Float x,Float y);
		Dynamic __translate_dyn();

		virtual Void __rotate( Float x,Float y);
		Dynamic __rotate_dyn();

		virtual Void __transform( ::nape::geom::Mat23 m);
		Dynamic __transform_dyn();

		virtual ::zpp_nape::shape::ZPP_Circle __copy( );
		Dynamic __copy_dyn();

};

} // end namespace zpp_nape
} // end namespace shape

#endif /* INCLUDED_zpp_nape_shape_ZPP_Circle */ 
