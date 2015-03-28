#ifndef INCLUDED_nape_geom_MarchingSquares
#define INCLUDED_nape_geom_MarchingSquares

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,GeomPolyList)
HX_DECLARE_CLASS2(nape,geom,MarchingSquares)
HX_DECLARE_CLASS2(nape,geom,Vec2)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  MarchingSquares_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef MarchingSquares_obj OBJ_;
		MarchingSquares_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< MarchingSquares_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~MarchingSquares_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("MarchingSquares"); }

		static ::nape::geom::GeomPolyList run( Dynamic iso,::nape::geom::AABB bounds,::nape::geom::Vec2 cellsize,hx::Null< int >  quality,::nape::geom::Vec2 subgrid,hx::Null< bool >  combine,::nape::geom::GeomPolyList output);
		static Dynamic run_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_MarchingSquares */ 
