#ifndef INCLUDED_zpp_nape_geom_ZPP_MarchSpan
#define INCLUDED_zpp_nape_geom_ZPP_MarchSpan

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_MarchSpan)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_MarchSpan_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_MarchSpan_obj OBJ_;
		ZPP_MarchSpan_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_MarchSpan_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_MarchSpan_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_MarchSpan"); }

		::zpp_nape::geom::ZPP_MarchSpan parent;
		int rank;
		bool out;
		::zpp_nape::geom::ZPP_MarchSpan next;
		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		static ::zpp_nape::geom::ZPP_MarchSpan zpp_pool;
};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_MarchSpan */ 
