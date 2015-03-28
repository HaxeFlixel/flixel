#ifndef INCLUDED_zpp_nape_util_ZPP_Debug
#define INCLUDED_zpp_nape_util_ZPP_Debug

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Mat23)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Debug)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ShapeDebug)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Debug_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Debug_obj OBJ_;
		ZPP_Debug_obj();
		Void __construct(int width,int height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Debug_obj > __new(int width,int height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Debug_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Debug"); }

		::nape::util::Debug outer;
		bool isbmp;
		::zpp_nape::util::ZPP_ShapeDebug d_shape;
		Float bg_r;
		Float bg_g;
		Float bg_b;
		int bg_col;
		::zpp_nape::geom::ZPP_Mat23 xform;
		bool xnull;
		Float xdet;
		int width;
		int height;
		::zpp_nape::geom::ZPP_AABB viewport;
		::zpp_nape::geom::ZPP_AABB iport;
		virtual Void xform_invalidate( );
		Dynamic xform_invalidate_dyn();

		virtual Void setform( );
		Dynamic setform_dyn();

		::zpp_nape::geom::ZPP_AABB tmpab;
		virtual bool cull( ::zpp_nape::geom::ZPP_AABB aabb);
		Dynamic cull_dyn();

		virtual Void sup_setbg( int bgcol);
		Dynamic sup_setbg_dyn();

		static bool internal;
};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZPP_Debug */ 
