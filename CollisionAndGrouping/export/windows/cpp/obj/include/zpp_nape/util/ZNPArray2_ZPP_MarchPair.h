#ifndef INCLUDED_zpp_nape_util_ZNPArray2_ZPP_MarchPair
#define INCLUDED_zpp_nape_util_ZNPArray2_ZPP_MarchPair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_MarchPair)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPArray2_ZPP_MarchPair)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZNPArray2_ZPP_MarchPair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZNPArray2_ZPP_MarchPair_obj OBJ_;
		ZNPArray2_ZPP_MarchPair_obj();
		Void __construct(int width,int height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZNPArray2_ZPP_MarchPair_obj > __new(int width,int height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZNPArray2_ZPP_MarchPair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZNPArray2_ZPP_MarchPair"); }

		Array< ::Dynamic > list;
		int width;
		virtual Void resize( int width,int height,::zpp_nape::geom::ZPP_MarchPair def);
		Dynamic resize_dyn();

		virtual ::zpp_nape::geom::ZPP_MarchPair get( int x,int y);
		Dynamic get_dyn();

		virtual ::zpp_nape::geom::ZPP_MarchPair set( int x,int y,::zpp_nape::geom::ZPP_MarchPair obj);
		Dynamic set_dyn();

};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZNPArray2_ZPP_MarchPair */ 
