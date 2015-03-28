#ifndef INCLUDED_zpp_nape_constraint_ZPP_AngleDraw
#define INCLUDED_zpp_nape_constraint_ZPP_AngleDraw

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_AngleDraw)
namespace zpp_nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  ZPP_AngleDraw_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_AngleDraw_obj OBJ_;
		ZPP_AngleDraw_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_AngleDraw_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_AngleDraw_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_AngleDraw"); }

		static Void indicator( ::nape::util::Debug g,::nape::geom::Vec2 c,Float ang,Float rad,int col);
		static Dynamic indicator_dyn();

		static Float maxarc;
		static Void drawSpiralSpring( ::nape::util::Debug g,::nape::geom::Vec2 c,Float a0,Float a1,Float r0,Float r1,int col,hx::Null< int >  coils);
		static Dynamic drawSpiralSpring_dyn();

		static Void drawSpiral( ::nape::util::Debug g,::nape::geom::Vec2 c,Float a0,Float a1,Float r0,Float r1,int col);
		static Dynamic drawSpiral_dyn();

};

} // end namespace zpp_nape
} // end namespace constraint

#endif /* INCLUDED_zpp_nape_constraint_ZPP_AngleDraw */ 
