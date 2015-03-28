#ifndef INCLUDED_zpp_nape_util_ZNPList_ZPP_AABBPair
#define INCLUDED_zpp_nape_util_ZNPList_ZPP_AABBPair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,space,ZPP_AABBPair)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_AABBPair)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPNode_ZPP_AABBPair)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZNPList_ZPP_AABBPair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZNPList_ZPP_AABBPair_obj OBJ_;
		ZNPList_ZPP_AABBPair_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZNPList_ZPP_AABBPair_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZNPList_ZPP_AABBPair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZNPList_ZPP_AABBPair"); }

		::zpp_nape::util::ZNPNode_ZPP_AABBPair head;
		virtual ::zpp_nape::util::ZNPNode_ZPP_AABBPair begin( );
		Dynamic begin_dyn();

		bool modified;
		bool pushmod;
		int length;
		virtual Void setbegin( ::zpp_nape::util::ZNPNode_ZPP_AABBPair i);
		Dynamic setbegin_dyn();

		virtual ::zpp_nape::space::ZPP_AABBPair add( ::zpp_nape::space::ZPP_AABBPair o);
		Dynamic add_dyn();

		virtual ::zpp_nape::space::ZPP_AABBPair inlined_add( ::zpp_nape::space::ZPP_AABBPair o);
		Dynamic inlined_add_dyn();

		virtual Void addAll( ::zpp_nape::util::ZNPList_ZPP_AABBPair x);
		Dynamic addAll_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_AABBPair insert( ::zpp_nape::util::ZNPNode_ZPP_AABBPair cur,::zpp_nape::space::ZPP_AABBPair o);
		Dynamic insert_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_AABBPair inlined_insert( ::zpp_nape::util::ZNPNode_ZPP_AABBPair cur,::zpp_nape::space::ZPP_AABBPair o);
		Dynamic inlined_insert_dyn();

		virtual Void pop( );
		Dynamic pop_dyn();

		virtual Void inlined_pop( );
		Dynamic inlined_pop_dyn();

		virtual ::zpp_nape::space::ZPP_AABBPair pop_unsafe( );
		Dynamic pop_unsafe_dyn();

		virtual ::zpp_nape::space::ZPP_AABBPair inlined_pop_unsafe( );
		Dynamic inlined_pop_unsafe_dyn();

		virtual Void remove( ::zpp_nape::space::ZPP_AABBPair obj);
		Dynamic remove_dyn();

		virtual bool try_remove( ::zpp_nape::space::ZPP_AABBPair obj);
		Dynamic try_remove_dyn();

		virtual Void inlined_remove( ::zpp_nape::space::ZPP_AABBPair obj);
		Dynamic inlined_remove_dyn();

		virtual bool inlined_try_remove( ::zpp_nape::space::ZPP_AABBPair obj);
		Dynamic inlined_try_remove_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_AABBPair erase( ::zpp_nape::util::ZNPNode_ZPP_AABBPair pre);
		Dynamic erase_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_AABBPair inlined_erase( ::zpp_nape::util::ZNPNode_ZPP_AABBPair pre);
		Dynamic inlined_erase_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_AABBPair splice( ::zpp_nape::util::ZNPNode_ZPP_AABBPair pre,int n);
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

		virtual bool has( ::zpp_nape::space::ZPP_AABBPair obj);
		Dynamic has_dyn();

		virtual bool inlined_has( ::zpp_nape::space::ZPP_AABBPair obj);
		Dynamic inlined_has_dyn();

		virtual ::zpp_nape::space::ZPP_AABBPair front( );
		Dynamic front_dyn();

		virtual ::zpp_nape::space::ZPP_AABBPair back( );
		Dynamic back_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_AABBPair iterator_at( int ind);
		Dynamic iterator_at_dyn();

		virtual ::zpp_nape::space::ZPP_AABBPair at( int ind);
		Dynamic at_dyn();

};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZNPList_ZPP_AABBPair */ 
