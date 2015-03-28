#ifndef INCLUDED_zpp_nape_geom_ZPP_Cutter
#define INCLUDED_zpp_nape_geom_ZPP_Cutter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,GeomPolyList)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Cutter)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CutInt)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CutVert)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Cutter_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Cutter_obj OBJ_;
		ZPP_Cutter_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Cutter_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Cutter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_Cutter"); }

		static ::zpp_nape::util::ZNPList_ZPP_CutInt ints;
		static ::zpp_nape::util::ZNPList_ZPP_CutVert paths;
		static ::nape::geom::GeomPolyList run( ::zpp_nape::geom::ZPP_GeomVert P,::nape::geom::Vec2 _start,::nape::geom::Vec2 _end,bool bstart,bool bend,::nape::geom::GeomPolyList output);
		static Dynamic run_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_Cutter */ 
