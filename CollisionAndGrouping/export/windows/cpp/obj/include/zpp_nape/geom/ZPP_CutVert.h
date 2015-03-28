#ifndef INCLUDED_zpp_nape_geom_ZPP_CutVert
#define INCLUDED_zpp_nape_geom_ZPP_CutVert

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_CutVert)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVert)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_CutVert_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_CutVert_obj OBJ_;
		ZPP_CutVert_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_CutVert_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_CutVert_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_CutVert"); }

		::zpp_nape::geom::ZPP_CutVert prev;
		::zpp_nape::geom::ZPP_CutVert next;
		Float posx;
		Float posy;
		::zpp_nape::geom::ZPP_GeomVert vert;
		Float value;
		bool positive;
		::zpp_nape::geom::ZPP_CutVert parent;
		int rank;
		bool used;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		static ::zpp_nape::geom::ZPP_CutVert zpp_pool;
		static ::zpp_nape::geom::ZPP_CutVert path( ::zpp_nape::geom::ZPP_GeomVert poly);
		static Dynamic path_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_CutVert */ 
