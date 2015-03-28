#ifndef INCLUDED_zpp_nape_util_ZNPList_ZPP_FluidArbiter
#define INCLUDED_zpp_nape_util_ZNPList_ZPP_FluidArbiter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_FluidArbiter)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_FluidArbiter)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPNode_ZPP_FluidArbiter)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZNPList_ZPP_FluidArbiter_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZNPList_ZPP_FluidArbiter_obj OBJ_;
		ZNPList_ZPP_FluidArbiter_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZNPList_ZPP_FluidArbiter_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZNPList_ZPP_FluidArbiter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZNPList_ZPP_FluidArbiter"); }

		::zpp_nape::util::ZNPNode_ZPP_FluidArbiter head;
		virtual ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter begin( );
		Dynamic begin_dyn();

		bool modified;
		bool pushmod;
		int length;
		virtual Void setbegin( ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter i);
		Dynamic setbegin_dyn();

		virtual ::zpp_nape::dynamics::ZPP_FluidArbiter add( ::zpp_nape::dynamics::ZPP_FluidArbiter o);
		Dynamic add_dyn();

		virtual ::zpp_nape::dynamics::ZPP_FluidArbiter inlined_add( ::zpp_nape::dynamics::ZPP_FluidArbiter o);
		Dynamic inlined_add_dyn();

		virtual Void addAll( ::zpp_nape::util::ZNPList_ZPP_FluidArbiter x);
		Dynamic addAll_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter insert( ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter cur,::zpp_nape::dynamics::ZPP_FluidArbiter o);
		Dynamic insert_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter inlined_insert( ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter cur,::zpp_nape::dynamics::ZPP_FluidArbiter o);
		Dynamic inlined_insert_dyn();

		virtual Void pop( );
		Dynamic pop_dyn();

		virtual Void inlined_pop( );
		Dynamic inlined_pop_dyn();

		virtual ::zpp_nape::dynamics::ZPP_FluidArbiter pop_unsafe( );
		Dynamic pop_unsafe_dyn();

		virtual ::zpp_nape::dynamics::ZPP_FluidArbiter inlined_pop_unsafe( );
		Dynamic inlined_pop_unsafe_dyn();

		virtual Void remove( ::zpp_nape::dynamics::ZPP_FluidArbiter obj);
		Dynamic remove_dyn();

		virtual bool try_remove( ::zpp_nape::dynamics::ZPP_FluidArbiter obj);
		Dynamic try_remove_dyn();

		virtual Void inlined_remove( ::zpp_nape::dynamics::ZPP_FluidArbiter obj);
		Dynamic inlined_remove_dyn();

		virtual bool inlined_try_remove( ::zpp_nape::dynamics::ZPP_FluidArbiter obj);
		Dynamic inlined_try_remove_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter erase( ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter pre);
		Dynamic erase_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter inlined_erase( ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter pre);
		Dynamic inlined_erase_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter splice( ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter pre,int n);
		Dynamic splice_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void inlined_clear( );
		Dynamic inlined_clear_dyn();

		virtual Void reverse( );
		Dynamic reverse_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual int size( );
		Dynamic size_dyn();

		virtual bool has( ::zpp_nape::dynamics::ZPP_FluidArbiter obj);
		Dynamic has_dyn();

		virtual bool inlined_has( ::zpp_nape::dynamics::ZPP_FluidArbiter obj);
		Dynamic inlined_has_dyn();

		virtual ::zpp_nape::dynamics::ZPP_FluidArbiter front( );
		Dynamic front_dyn();

		virtual ::zpp_nape::dynamics::ZPP_FluidArbiter back( );
		Dynamic back_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_FluidArbiter iterator_at( int ind);
		Dynamic iterator_at_dyn();

		virtual ::zpp_nape::dynamics::ZPP_FluidArbiter at( int ind);
		Dynamic at_dyn();

};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZNPList_ZPP_FluidArbiter */ 
