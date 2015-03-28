#ifndef INCLUDED_zpp_nape_space_ZPP_Island
#define INCLUDED_zpp_nape_space_ZPP_Island

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Island)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Component)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Island_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Island_obj OBJ_;
		ZPP_Island_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Island_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Island_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Island"); }

		::zpp_nape::space::ZPP_Island next;
		virtual ::zpp_nape::space::ZPP_Island elem( );
		Dynamic elem_dyn();

		virtual ::zpp_nape::space::ZPP_Island begin( );
		Dynamic begin_dyn();

		bool _inuse;
		bool modified;
		bool pushmod;
		int length;
		virtual Void setbegin( ::zpp_nape::space::ZPP_Island i);
		Dynamic setbegin_dyn();

		virtual ::zpp_nape::space::ZPP_Island add( ::zpp_nape::space::ZPP_Island o);
		Dynamic add_dyn();

		virtual ::zpp_nape::space::ZPP_Island inlined_add( ::zpp_nape::space::ZPP_Island o);
		Dynamic inlined_add_dyn();

		virtual Void addAll( ::zpp_nape::space::ZPP_Island x);
		Dynamic addAll_dyn();

		virtual ::zpp_nape::space::ZPP_Island insert( ::zpp_nape::space::ZPP_Island cur,::zpp_nape::space::ZPP_Island o);
		Dynamic insert_dyn();

		virtual ::zpp_nape::space::ZPP_Island inlined_insert( ::zpp_nape::space::ZPP_Island cur,::zpp_nape::space::ZPP_Island o);
		Dynamic inlined_insert_dyn();

		virtual Void pop( );
		Dynamic pop_dyn();

		virtual Void inlined_pop( );
		Dynamic inlined_pop_dyn();

		virtual ::zpp_nape::space::ZPP_Island pop_unsafe( );
		Dynamic pop_unsafe_dyn();

		virtual ::zpp_nape::space::ZPP_Island inlined_pop_unsafe( );
		Dynamic inlined_pop_unsafe_dyn();

		virtual Void remove( ::zpp_nape::space::ZPP_Island obj);
		Dynamic remove_dyn();

		virtual bool try_remove( ::zpp_nape::space::ZPP_Island obj);
		Dynamic try_remove_dyn();

		virtual Void inlined_remove( ::zpp_nape::space::ZPP_Island obj);
		Dynamic inlined_remove_dyn();

		virtual bool inlined_try_remove( ::zpp_nape::space::ZPP_Island obj);
		Dynamic inlined_try_remove_dyn();

		virtual ::zpp_nape::space::ZPP_Island erase( ::zpp_nape::space::ZPP_Island pre);
		Dynamic erase_dyn();

		virtual ::zpp_nape::space::ZPP_Island inlined_erase( ::zpp_nape::space::ZPP_Island pre);
		Dynamic inlined_erase_dyn();

		virtual ::zpp_nape::space::ZPP_Island splice( ::zpp_nape::space::ZPP_Island pre,int n);
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

		virtual bool has( ::zpp_nape::space::ZPP_Island obj);
		Dynamic has_dyn();

		virtual bool inlined_has( ::zpp_nape::space::ZPP_Island obj);
		Dynamic inlined_has_dyn();

		virtual ::zpp_nape::space::ZPP_Island front( );
		Dynamic front_dyn();

		virtual ::zpp_nape::space::ZPP_Island back( );
		Dynamic back_dyn();

		virtual ::zpp_nape::space::ZPP_Island iterator_at( int ind);
		Dynamic iterator_at_dyn();

		virtual ::zpp_nape::space::ZPP_Island at( int ind);
		Dynamic at_dyn();

		::zpp_nape::util::ZNPList_ZPP_Component comps;
		bool sleep;
		int waket;
		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		static ::zpp_nape::space::ZPP_Island zpp_pool;
};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_Island */ 
