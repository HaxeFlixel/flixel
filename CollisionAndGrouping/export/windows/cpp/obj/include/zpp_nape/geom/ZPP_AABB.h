#ifndef INCLUDED_zpp_nape_geom_ZPP_AABB
#define INCLUDED_zpp_nape_geom_ZPP_AABB

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_AABB_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_AABB_obj OBJ_;
		ZPP_AABB_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_AABB_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_AABB_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_AABB"); }

		Dynamic _invalidate;
		Dynamic &_invalidate_dyn() { return _invalidate;}
		Dynamic _validate;
		Dynamic &_validate_dyn() { return _validate;}
		bool _immutable;
		virtual Void validate( );
		Dynamic validate_dyn();

		virtual Void invalidate( );
		Dynamic invalidate_dyn();

		::nape::geom::AABB outer;
		virtual ::nape::geom::AABB wrapper( );
		Dynamic wrapper_dyn();

		::zpp_nape::geom::ZPP_AABB next;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual ::zpp_nape::geom::ZPP_AABB copy( );
		Dynamic copy_dyn();

		virtual Float width( );
		Dynamic width_dyn();

		virtual Float height( );
		Dynamic height_dyn();

		virtual Float perimeter( );
		Dynamic perimeter_dyn();

		Float minx;
		Float miny;
		::nape::geom::Vec2 wrap_min;
		virtual ::nape::geom::Vec2 getmin( );
		Dynamic getmin_dyn();

		virtual Void dom_min( );
		Dynamic dom_min_dyn();

		virtual Void mod_min( ::zpp_nape::geom::ZPP_Vec2 min);
		Dynamic mod_min_dyn();

		Float maxx;
		Float maxy;
		::nape::geom::Vec2 wrap_max;
		virtual ::nape::geom::Vec2 getmax( );
		Dynamic getmax_dyn();

		virtual Void dom_max( );
		Dynamic dom_max_dyn();

		virtual Void mod_max( ::zpp_nape::geom::ZPP_Vec2 max);
		Dynamic mod_max_dyn();

		virtual bool intersectX( ::zpp_nape::geom::ZPP_AABB x);
		Dynamic intersectX_dyn();

		virtual bool intersectY( ::zpp_nape::geom::ZPP_AABB x);
		Dynamic intersectY_dyn();

		virtual bool intersect( ::zpp_nape::geom::ZPP_AABB x);
		Dynamic intersect_dyn();

		virtual Void combine( ::zpp_nape::geom::ZPP_AABB x);
		Dynamic combine_dyn();

		virtual bool contains( ::zpp_nape::geom::ZPP_AABB x);
		Dynamic contains_dyn();

		virtual bool containsPoint( ::zpp_nape::geom::ZPP_Vec2 v);
		Dynamic containsPoint_dyn();

		virtual Void setCombine( ::zpp_nape::geom::ZPP_AABB a,::zpp_nape::geom::ZPP_AABB b);
		Dynamic setCombine_dyn();

		virtual Void setExpand( ::zpp_nape::geom::ZPP_AABB a,Float fatten);
		Dynamic setExpand_dyn();

		virtual Void setExpandPoint( Float x,Float y);
		Dynamic setExpandPoint_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::zpp_nape::geom::ZPP_AABB zpp_pool;
		static ::zpp_nape::geom::ZPP_AABB get( Float minx,Float miny,Float maxx,Float maxy);
		static Dynamic get_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_AABB */ 
