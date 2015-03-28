#ifndef INCLUDED_zpp_nape_space_ZPP_SweepData
#define INCLUDED_zpp_nape_space_ZPP_SweepData

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_SweepData)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_SweepData_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_SweepData_obj OBJ_;
		ZPP_SweepData_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_SweepData_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_SweepData_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_SweepData"); }

		::zpp_nape::space::ZPP_SweepData next;
		::zpp_nape::space::ZPP_SweepData prev;
		::zpp_nape::shape::ZPP_Shape shape;
		::zpp_nape::geom::ZPP_AABB aabb;
		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		virtual bool gt( ::zpp_nape::space::ZPP_SweepData x);
		Dynamic gt_dyn();

		static ::zpp_nape::space::ZPP_SweepData zpp_pool;
};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_SweepData */ 
