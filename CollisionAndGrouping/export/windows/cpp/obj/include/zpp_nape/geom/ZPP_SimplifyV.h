#ifndef INCLUDED_zpp_nape_geom_ZPP_SimplifyV
#define INCLUDED_zpp_nape_geom_ZPP_SimplifyV

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SimplifyV)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_SimplifyV_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_SimplifyV_obj OBJ_;
		ZPP_SimplifyV_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_SimplifyV_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_SimplifyV_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_SimplifyV"); }

		Float x;
		Float y;
		::zpp_nape::geom::ZPP_SimplifyV next;
		::zpp_nape::geom::ZPP_SimplifyV prev;
		bool flag;
		bool forced;
		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		static ::zpp_nape::geom::ZPP_SimplifyV zpp_pool;
		static ::zpp_nape::geom::ZPP_SimplifyV get( ::zpp_nape::geom::ZPP_GeomVert v);
		static Dynamic get_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_SimplifyV */ 
