#ifndef INCLUDED_zpp_nape_geom_ZPP_PartitionPair
#define INCLUDED_zpp_nape_geom_ZPP_PartitionPair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionPair)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionVertex)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_PartitionPair)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_PartitionPair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_PartitionPair_obj OBJ_;
		ZPP_PartitionPair_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_PartitionPair_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_PartitionPair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_PartitionPair"); }

		::zpp_nape::geom::ZPP_PartitionPair next;
		virtual ::zpp_nape::geom::ZPP_PartitionPair elem( );
		Dynamic elem_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair begin( );
		Dynamic begin_dyn();

		bool _inuse;
		bool modified;
		bool pushmod;
		int length;
		virtual Void setbegin( ::zpp_nape::geom::ZPP_PartitionPair i);
		Dynamic setbegin_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair add( ::zpp_nape::geom::ZPP_PartitionPair o);
		Dynamic add_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair inlined_add( ::zpp_nape::geom::ZPP_PartitionPair o);
		Dynamic inlined_add_dyn();

		virtual Void addAll( ::zpp_nape::geom::ZPP_PartitionPair x);
		Dynamic addAll_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair insert( ::zpp_nape::geom::ZPP_PartitionPair cur,::zpp_nape::geom::ZPP_PartitionPair o);
		Dynamic insert_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair inlined_insert( ::zpp_nape::geom::ZPP_PartitionPair cur,::zpp_nape::geom::ZPP_PartitionPair o);
		Dynamic inlined_insert_dyn();

		virtual Void pop( );
		Dynamic pop_dyn();

		virtual Void inlined_pop( );
		Dynamic inlined_pop_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair pop_unsafe( );
		Dynamic pop_unsafe_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair inlined_pop_unsafe( );
		Dynamic inlined_pop_unsafe_dyn();

		virtual Void remove( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic remove_dyn();

		virtual bool try_remove( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic try_remove_dyn();

		virtual Void inlined_remove( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic inlined_remove_dyn();

		virtual bool inlined_try_remove( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic inlined_try_remove_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair erase( ::zpp_nape::geom::ZPP_PartitionPair pre);
		Dynamic erase_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair inlined_erase( ::zpp_nape::geom::ZPP_PartitionPair pre);
		Dynamic inlined_erase_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair splice( ::zpp_nape::geom::ZPP_PartitionPair pre,int n);
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

		virtual bool has( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic has_dyn();

		virtual bool inlined_has( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic inlined_has_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair front( );
		Dynamic front_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair back( );
		Dynamic back_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair iterator_at( int ind);
		Dynamic iterator_at_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair at( int ind);
		Dynamic at_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		::zpp_nape::geom::ZPP_PartitionVertex a;
		::zpp_nape::geom::ZPP_PartitionVertex b;
		int id;
		int di;
		::zpp_nape::util::ZPP_Set_ZPP_PartitionPair node;
		static ::zpp_nape::geom::ZPP_PartitionPair zpp_pool;
		static ::zpp_nape::geom::ZPP_PartitionPair get( ::zpp_nape::geom::ZPP_PartitionVertex a,::zpp_nape::geom::ZPP_PartitionVertex b);
		static Dynamic get_dyn();

		static Void edge_swap( ::zpp_nape::geom::ZPP_PartitionPair a,::zpp_nape::geom::ZPP_PartitionPair b);
		static Dynamic edge_swap_dyn();

		static bool edge_lt( ::zpp_nape::geom::ZPP_PartitionPair a,::zpp_nape::geom::ZPP_PartitionPair b);
		static Dynamic edge_lt_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_PartitionPair */ 
