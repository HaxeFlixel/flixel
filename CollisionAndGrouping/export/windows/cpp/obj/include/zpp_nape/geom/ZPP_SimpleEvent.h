#ifndef INCLUDED_zpp_nape_geom_ZPP_SimpleEvent
#define INCLUDED_zpp_nape_geom_ZPP_SimpleEvent

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SimpleEvent)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SimpleSeg)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SimpleVert)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_SimpleEvent)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_SimpleEvent_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_SimpleEvent_obj OBJ_;
		ZPP_SimpleEvent_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_SimpleEvent_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_SimpleEvent_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_SimpleEvent"); }

		int type;
		::zpp_nape::geom::ZPP_SimpleVert vertex;
		::zpp_nape::geom::ZPP_SimpleSeg segment;
		::zpp_nape::geom::ZPP_SimpleSeg segment2;
		::zpp_nape::util::ZPP_Set_ZPP_SimpleEvent node;
		::zpp_nape::geom::ZPP_SimpleEvent next;
		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		static Void swap_nodes( ::zpp_nape::geom::ZPP_SimpleEvent a,::zpp_nape::geom::ZPP_SimpleEvent b);
		static Dynamic swap_nodes_dyn();

		static bool less_xy( ::zpp_nape::geom::ZPP_SimpleEvent a,::zpp_nape::geom::ZPP_SimpleEvent b);
		static Dynamic less_xy_dyn();

		static ::zpp_nape::geom::ZPP_SimpleEvent zpp_pool;
		static ::zpp_nape::geom::ZPP_SimpleEvent get( ::zpp_nape::geom::ZPP_SimpleVert v);
		static Dynamic get_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_SimpleEvent */ 
