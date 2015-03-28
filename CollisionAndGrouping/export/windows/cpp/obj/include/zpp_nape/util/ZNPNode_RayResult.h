#ifndef INCLUDED_zpp_nape_util_ZNPNode_RayResult
#define INCLUDED_zpp_nape_util_ZNPNode_RayResult

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,RayResult)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPNode_RayResult)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZNPNode_RayResult_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZNPNode_RayResult_obj OBJ_;
		ZNPNode_RayResult_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZNPNode_RayResult_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZNPNode_RayResult_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZNPNode_RayResult"); }

		::zpp_nape::util::ZNPNode_RayResult next;
		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		::nape::geom::RayResult elt;
		virtual ::nape::geom::RayResult elem( );
		Dynamic elem_dyn();

		static ::zpp_nape::util::ZNPNode_RayResult zpp_pool;
};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZNPNode_RayResult */ 
