#ifndef INCLUDED_zpp_nape_dynamics_ZPP_IContact
#define INCLUDED_zpp_nape_dynamics_ZPP_IContact

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_IContact)
namespace zpp_nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ZPP_IContact_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_IContact_obj OBJ_;
		ZPP_IContact_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_IContact_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_IContact_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_IContact"); }

		Float r1x;
		Float r1y;
		Float r2x;
		Float r2y;
		Float nMass;
		Float tMass;
		Float bounce;
		Float friction;
		Float jnAcc;
		Float jtAcc;
		Float lr1x;
		Float lr1y;
		Float lr2x;
		Float lr2y;
		::zpp_nape::dynamics::ZPP_IContact next;
		virtual ::zpp_nape::dynamics::ZPP_IContact elem( );
		Dynamic elem_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact begin( );
		Dynamic begin_dyn();

		bool _inuse;
		bool modified;
		bool pushmod;
		int length;
		virtual Void setbegin( ::zpp_nape::dynamics::ZPP_IContact i);
		Dynamic setbegin_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact add( ::zpp_nape::dynamics::ZPP_IContact o);
		Dynamic add_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact inlined_add( ::zpp_nape::dynamics::ZPP_IContact o);
		Dynamic inlined_add_dyn();

		virtual Void addAll( ::zpp_nape::dynamics::ZPP_IContact x);
		Dynamic addAll_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact insert( ::zpp_nape::dynamics::ZPP_IContact cur,::zpp_nape::dynamics::ZPP_IContact o);
		Dynamic insert_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact inlined_insert( ::zpp_nape::dynamics::ZPP_IContact cur,::zpp_nape::dynamics::ZPP_IContact o);
		Dynamic inlined_insert_dyn();

		virtual Void pop( );
		Dynamic pop_dyn();

		virtual Void inlined_pop( );
		Dynamic inlined_pop_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact pop_unsafe( );
		Dynamic pop_unsafe_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact inlined_pop_unsafe( );
		Dynamic inlined_pop_unsafe_dyn();

		virtual Void remove( ::zpp_nape::dynamics::ZPP_IContact obj);
		Dynamic remove_dyn();

		virtual bool try_remove( ::zpp_nape::dynamics::ZPP_IContact obj);
		Dynamic try_remove_dyn();

		virtual Void inlined_remove( ::zpp_nape::dynamics::ZPP_IContact obj);
		Dynamic inlined_remove_dyn();

		virtual bool inlined_try_remove( ::zpp_nape::dynamics::ZPP_IContact obj);
		Dynamic inlined_try_remove_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact erase( ::zpp_nape::dynamics::ZPP_IContact pre);
		Dynamic erase_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact inlined_erase( ::zpp_nape::dynamics::ZPP_IContact pre);
		Dynamic inlined_erase_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact splice( ::zpp_nape::dynamics::ZPP_IContact pre,int n);
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

		virtual bool has( ::zpp_nape::dynamics::ZPP_IContact obj);
		Dynamic has_dyn();

		virtual bool inlined_has( ::zpp_nape::dynamics::ZPP_IContact obj);
		Dynamic inlined_has_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact front( );
		Dynamic front_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact back( );
		Dynamic back_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact iterator_at( int ind);
		Dynamic iterator_at_dyn();

		virtual ::zpp_nape::dynamics::ZPP_IContact at( int ind);
		Dynamic at_dyn();

};

} // end namespace zpp_nape
} // end namespace dynamics

#endif /* INCLUDED_zpp_nape_dynamics_ZPP_IContact */ 
