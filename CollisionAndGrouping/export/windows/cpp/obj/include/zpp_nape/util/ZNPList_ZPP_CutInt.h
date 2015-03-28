#ifndef INCLUDED_zpp_nape_util_ZNPList_ZPP_CutInt
#define INCLUDED_zpp_nape_util_ZNPList_ZPP_CutInt

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_CutInt)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CutInt)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPNode_ZPP_CutInt)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZNPList_ZPP_CutInt_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZNPList_ZPP_CutInt_obj OBJ_;
		ZNPList_ZPP_CutInt_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZNPList_ZPP_CutInt_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZNPList_ZPP_CutInt_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZNPList_ZPP_CutInt"); }

		::zpp_nape::util::ZNPNode_ZPP_CutInt head;
		virtual ::zpp_nape::util::ZNPNode_ZPP_CutInt begin( );
		Dynamic begin_dyn();

		bool modified;
		bool pushmod;
		int length;
		virtual Void setbegin( ::zpp_nape::util::ZNPNode_ZPP_CutInt i);
		Dynamic setbegin_dyn();

		virtual ::zpp_nape::geom::ZPP_CutInt add( ::zpp_nape::geom::ZPP_CutInt o);
		Dynamic add_dyn();

		virtual ::zpp_nape::geom::ZPP_CutInt inlined_add( ::zpp_nape::geom::ZPP_CutInt o);
		Dynamic inlined_add_dyn();

		virtual Void addAll( ::zpp_nape::util::ZNPList_ZPP_CutInt x);
		Dynamic addAll_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_CutInt insert( ::zpp_nape::util::ZNPNode_ZPP_CutInt cur,::zpp_nape::geom::ZPP_CutInt o);
		Dynamic insert_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_CutInt inlined_insert( ::zpp_nape::util::ZNPNode_ZPP_CutInt cur,::zpp_nape::geom::ZPP_CutInt o);
		Dynamic inlined_insert_dyn();

		virtual Void pop( );
		Dynamic pop_dyn();

		virtual Void inlined_pop( );
		Dynamic inlined_pop_dyn();

		virtual ::zpp_nape::geom::ZPP_CutInt pop_unsafe( );
		Dynamic pop_unsafe_dyn();

		virtual ::zpp_nape::geom::ZPP_CutInt inlined_pop_unsafe( );
		Dynamic inlined_pop_unsafe_dyn();

		virtual Void remove( ::zpp_nape::geom::ZPP_CutInt obj);
		Dynamic remove_dyn();

		virtual bool try_remove( ::zpp_nape::geom::ZPP_CutInt obj);
		Dynamic try_remove_dyn();

		virtual Void inlined_remove( ::zpp_nape::geom::ZPP_CutInt obj);
		Dynamic inlined_remove_dyn();

		virtual bool inlined_try_remove( ::zpp_nape::geom::ZPP_CutInt obj);
		Dynamic inlined_try_remove_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_CutInt erase( ::zpp_nape::util::ZNPNode_ZPP_CutInt pre);
		Dynamic erase_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_CutInt inlined_erase( ::zpp_nape::util::ZNPNode_ZPP_CutInt pre);
		Dynamic inlined_erase_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_CutInt splice( ::zpp_nape::util::ZNPNode_ZPP_CutInt pre,int n);
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

		virtual bool has( ::zpp_nape::geom::ZPP_CutInt obj);
		Dynamic has_dyn();

		virtual bool inlined_has( ::zpp_nape::geom::ZPP_CutInt obj);
		Dynamic inlined_has_dyn();

		virtual ::zpp_nape::geom::ZPP_CutInt front( );
		Dynamic front_dyn();

		virtual ::zpp_nape::geom::ZPP_CutInt back( );
		Dynamic back_dyn();

		virtual ::zpp_nape::util::ZNPNode_ZPP_CutInt iterator_at( int ind);
		Dynamic iterator_at_dyn();

		virtual ::zpp_nape::geom::ZPP_CutInt at( int ind);
		Dynamic at_dyn();

};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZNPList_ZPP_CutInt */ 
