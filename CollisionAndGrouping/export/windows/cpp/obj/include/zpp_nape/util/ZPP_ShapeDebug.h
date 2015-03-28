#ifndef INCLUDED_zpp_nape_util_ZPP_ShapeDebug
#define INCLUDED_zpp_nape_util_ZPP_ShapeDebug

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/util/ZPP_Debug.h>
HX_DECLARE_CLASS2(nape,phys,BodyList)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(nape,util,ShapeDebug)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Graphics)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,Shape)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Mat23)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Compound)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Compound)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Debug)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ShapeDebug)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZPP_ShapeDebug_obj : public ::zpp_nape::util::ZPP_Debug_obj{
	public:
		typedef ::zpp_nape::util::ZPP_Debug_obj super;
		typedef ZPP_ShapeDebug_obj OBJ_;
		ZPP_ShapeDebug_obj();
		Void __construct(int width,int height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_ShapeDebug_obj > __new(int width,int height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_ShapeDebug_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_ShapeDebug"); }

		::nape::util::ShapeDebug outer_zn;
		::openfl::_v2::display::Shape shape;
		::openfl::_v2::display::Graphics graphics;
		virtual Void setbg( int bgColor);
		Dynamic setbg_dyn();

		::zpp_nape::util::ZNPList_ZPP_Compound compoundstack;
		virtual Void draw_compound( ::zpp_nape::phys::ZPP_Compound compound,::zpp_nape::geom::ZPP_Mat23 xform,Float xdet,bool xnull);
		Dynamic draw_compound_dyn();

		::nape::shape::ShapeList shapeList;
		::nape::phys::BodyList bodyList;
		virtual Void draw_space( ::zpp_nape::space::ZPP_Space space,::zpp_nape::geom::ZPP_Mat23 xform,Float xdet,bool xnull);
		Dynamic draw_space_dyn();

		virtual Void draw_body( ::zpp_nape::phys::ZPP_Body body,::zpp_nape::geom::ZPP_Mat23 xform,Float xdet,bool xnull);
		Dynamic draw_body_dyn();

		virtual Void draw_shape( ::zpp_nape::shape::ZPP_Shape shape,::zpp_nape::geom::ZPP_Mat23 xform,Float xdet,bool xnull);
		Dynamic draw_shape_dyn();

		virtual Void draw_arbiter( ::zpp_nape::dynamics::ZPP_Arbiter arb,::zpp_nape::geom::ZPP_Mat23 xform,Float xdet,bool xnull);
		Dynamic draw_arbiter_dyn();

};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZPP_ShapeDebug */ 
