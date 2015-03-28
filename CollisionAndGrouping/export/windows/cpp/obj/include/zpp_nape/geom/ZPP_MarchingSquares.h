#ifndef INCLUDED_zpp_nape_geom_ZPP_MarchingSquares
#define INCLUDED_zpp_nape_geom_ZPP_MarchingSquares

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,GeomPolyList)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_MarchPair)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_MarchingSquares)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPArray2_Float)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPArray2_ZPP_GeomVert)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPArray2_ZPP_MarchPair)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_MarchingSquares_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_MarchingSquares_obj OBJ_;
		ZPP_MarchingSquares_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_MarchingSquares_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_MarchingSquares_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_MarchingSquares"); }

		virtual Void output( ::nape::geom::GeomPolyList ret,::zpp_nape::geom::ZPP_GeomVert poly);
		Dynamic output_dyn();

		virtual ::zpp_nape::geom::ZPP_GeomVert linkright( ::zpp_nape::geom::ZPP_GeomVert poly,int key);
		Dynamic linkright_dyn();

		virtual ::zpp_nape::geom::ZPP_GeomVert linkleft( ::zpp_nape::geom::ZPP_GeomVert poly,int key);
		Dynamic linkleft_dyn();

		virtual ::zpp_nape::geom::ZPP_GeomVert linkdown( ::zpp_nape::geom::ZPP_GeomVert poly,int key);
		Dynamic linkdown_dyn();

		virtual ::zpp_nape::geom::ZPP_GeomVert linkup( ::zpp_nape::geom::ZPP_GeomVert poly,int key);
		Dynamic linkup_dyn();

		virtual Void combLR( ::zpp_nape::geom::ZPP_MarchPair a,::zpp_nape::geom::ZPP_MarchPair b);
		Dynamic combLR_dyn();

		virtual Void combUD( ::zpp_nape::geom::ZPP_MarchPair a,::zpp_nape::geom::ZPP_MarchPair b);
		Dynamic combUD_dyn();

		virtual Void combUD_virtual( ::zpp_nape::geom::ZPP_MarchPair a,::zpp_nape::geom::ZPP_MarchPair b);
		Dynamic combUD_virtual_dyn();

		virtual bool combLeft( int key);
		Dynamic combLeft_dyn();

		virtual bool combRight( int key);
		Dynamic combRight_dyn();

		virtual bool combUp( int key);
		Dynamic combUp_dyn();

		virtual bool combDown( int key);
		Dynamic combDown_dyn();

		virtual bool comb( int flag);
		Dynamic comb_dyn();

		virtual ::zpp_nape::geom::ZPP_MarchPair marchSquare( Dynamic iso,::zpp_nape::util::ZNPArray2_Float isos,::zpp_nape::util::ZNPArray2_ZPP_GeomVert ints,Float x0,Float y0,Float x1,Float y1,int xn,int yn,bool fstx,bool fsty,bool sndx,bool sndy,int quality);
		Dynamic marchSquare_dyn();

		virtual Float lerp( Float x0,Float x1,Float v0,Float v1);
		Dynamic lerp_dyn();

		virtual Float xlerp( Float x0,Float x1,Float y,Float v0,Float v1,Dynamic iso,int quality);
		Dynamic xlerp_dyn();

		virtual Float ylerp( Float y0,Float y1,Float x,Float v0,Float v1,Dynamic iso,int quality);
		Dynamic ylerp_dyn();

		static ::zpp_nape::geom::ZPP_MarchingSquares me;
		static ::zpp_nape::util::ZNPArray2_Float isos;
		static ::zpp_nape::util::ZNPArray2_ZPP_GeomVert ints;
		static ::zpp_nape::util::ZNPArray2_ZPP_MarchPair map;
		static Void run( Dynamic iso,Float bx0,Float by0,Float bx1,Float by1,::nape::geom::Vec2 cell,int quality,bool combine,::nape::geom::GeomPolyList ret);
		static Dynamic run_dyn();

		static Array< int > look_march;
		static Float ISO( Dynamic iso,Float x,Float y);
		static Dynamic ISO_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_MarchingSquares */ 
