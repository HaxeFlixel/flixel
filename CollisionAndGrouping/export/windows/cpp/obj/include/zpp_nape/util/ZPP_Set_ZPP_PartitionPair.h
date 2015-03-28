#ifndef INCLUDED_zpp_nape_util_ZPP_Set_ZPP_PartitionPair
#define INCLUDED_zpp_nape_util_ZPP_Set_ZPP_PartitionPair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_PartitionPair)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_PartitionPair)
namespace zpp_nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Set_ZPP_PartitionPair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Set_ZPP_PartitionPair_obj OBJ_;
		ZPP_Set_ZPP_PartitionPair_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Set_ZPP_PartitionPair_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Set_ZPP_PartitionPair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Set_ZPP_PartitionPair"); }

		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		Dynamic lt;
		Dynamic &lt_dyn() { return lt;}
		Dynamic swapped;
		Dynamic &swapped_dyn() { return swapped;}
		::zpp_nape::geom::ZPP_PartitionPair data;
		::zpp_nape::util::ZPP_Set_ZPP_PartitionPair prev;
		::zpp_nape::util::ZPP_Set_ZPP_PartitionPair next;
		::zpp_nape::util::ZPP_Set_ZPP_PartitionPair parent;
		int colour;
		virtual bool verify( );
		Dynamic verify_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual bool singular( );
		Dynamic singular_dyn();

		virtual int size( );
		Dynamic size_dyn();

		virtual bool has( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic has_dyn();

		virtual ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair find( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic find_dyn();

		virtual bool has_weak( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic has_weak_dyn();

		virtual ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair find_weak( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic find_weak_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair lower_bound( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic lower_bound_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair first( );
		Dynamic first_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair pop_front( );
		Dynamic pop_front_dyn();

		virtual Void remove( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic remove_dyn();

		virtual ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair successor_node( ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair cur);
		Dynamic successor_node_dyn();

		virtual ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair predecessor_node( ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair cur);
		Dynamic predecessor_node_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair successor( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic successor_dyn();

		virtual ::zpp_nape::geom::ZPP_PartitionPair predecessor( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic predecessor_dyn();

		virtual Void remove_node( ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair cur);
		Dynamic remove_node_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void clear_with( Dynamic lambda);
		Dynamic clear_with_dyn();

		virtual ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair clear_node( ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair node,Dynamic lambda);
		Dynamic clear_node_dyn();

		virtual Void __fix_neg_red( ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair negred);
		Dynamic __fix_neg_red_dyn();

		virtual Void __fix_dbl_red( ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair x);
		Dynamic __fix_dbl_red_dyn();

		virtual bool try_insert_bool( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic try_insert_bool_dyn();

		virtual ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair try_insert( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic try_insert_dyn();

		virtual ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair insert( ::zpp_nape::geom::ZPP_PartitionPair obj);
		Dynamic insert_dyn();

		static ::zpp_nape::util::ZPP_Set_ZPP_PartitionPair zpp_pool;
};

} // end namespace zpp_nape
} // end namespace util

#endif /* INCLUDED_zpp_nape_util_ZPP_Set_ZPP_PartitionPair */ 
