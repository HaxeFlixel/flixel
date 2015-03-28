#ifndef INCLUDED_zpp_nape_geom_ZPP_SimpleSweep
#define INCLUDED_zpp_nape_geom_ZPP_SimpleSweep

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SimpleEvent)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SimpleSeg)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SimpleSweep)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_SimpleSeg)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_SimpleSweep_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_SimpleSweep_obj OBJ_;
		ZPP_SimpleSweep_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_SimpleSweep_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_SimpleSweep_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_SimpleSweep"); }

		Float sweepx;
		::zpp_nape::util::ZPP_Set_ZPP_SimpleSeg tree;
		virtual Void swap_nodes( ::zpp_nape::geom::ZPP_SimpleSeg p,::zpp_nape::geom::ZPP_SimpleSeg q);
		Dynamic swap_nodes_dyn();

		virtual bool edge_lt( ::zpp_nape::geom::ZPP_SimpleSeg p,::zpp_nape::geom::ZPP_SimpleSeg q);
		Dynamic edge_lt_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual ::zpp_nape::geom::ZPP_SimpleSeg add( ::zpp_nape::geom::ZPP_SimpleSeg e);
		Dynamic add_dyn();

		virtual Void remove( ::zpp_nape::geom::ZPP_SimpleSeg e);
		Dynamic remove_dyn();

		virtual bool intersect( ::zpp_nape::geom::ZPP_SimpleSeg p,::zpp_nape::geom::ZPP_SimpleSeg q);
		Dynamic intersect_dyn();

		virtual ::zpp_nape::geom::ZPP_SimpleEvent intersection( ::zpp_nape::geom::ZPP_SimpleSeg p,::zpp_nape::geom::ZPP_SimpleSeg q);
		Dynamic intersection_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_SimpleSweep */ 
