#ifndef INCLUDED_zpp_nape_dynamics_ZPP_Contact
#define INCLUDED_zpp_nape_dynamics_ZPP_Contact

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,Contact)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Contact)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_IContact)
namespace zpp_nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Contact_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Contact_obj OBJ_;
		ZPP_Contact_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Contact_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Contact_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Contact"); }

		::nape::dynamics::Contact outer;
		virtual ::nape::dynamics::Contact wrapper( );
		Dynamic wrapper_dyn();

		Float px;
		Float py;
		virtual Void position_validate( );
		Dynamic position_validate_dyn();

		::nape::geom::Vec2 wrap_position;
		virtual Void getposition( );
		Dynamic getposition_dyn();

		virtual bool inactiveme( );
		Dynamic inactiveme_dyn();

		::zpp_nape::dynamics::ZPP_Arbiter arbiter;
		::zpp_nape::dynamics::ZPP_IContact inner;
		bool active;
		bool posOnly;
		int stamp;
		int hash;
		bool fresh;
		Float dist;
		Float elasticity;
		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		::zpp_nape::dynamics::ZPP_Contact next;
		virtual ::zpp_nape::dynamics::ZPP_Contact elem( );
		Dynamic elem_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact begin( );
		Dynamic begin_dyn();

		bool _inuse;
		bool modified;
		bool pushmod;
		int length;
		virtual Void setbegin( ::zpp_nape::dynamics::ZPP_Contact i);
		Dynamic setbegin_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact add( ::zpp_nape::dynamics::ZPP_Contact o);
		Dynamic add_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact inlined_add( ::zpp_nape::dynamics::ZPP_Contact o);
		Dynamic inlined_add_dyn();

		virtual Void addAll( ::zpp_nape::dynamics::ZPP_Contact x);
		Dynamic addAll_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact insert( ::zpp_nape::dynamics::ZPP_Contact cur,::zpp_nape::dynamics::ZPP_Contact o);
		Dynamic insert_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact inlined_insert( ::zpp_nape::dynamics::ZPP_Contact cur,::zpp_nape::dynamics::ZPP_Contact o);
		Dynamic inlined_insert_dyn();

		virtual Void pop( );
		Dynamic pop_dyn();

		virtual Void inlined_pop( );
		Dynamic inlined_pop_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact pop_unsafe( );
		Dynamic pop_unsafe_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact inlined_pop_unsafe( );
		Dynamic inlined_pop_unsafe_dyn();

		virtual Void remove( ::zpp_nape::dynamics::ZPP_Contact obj);
		Dynamic remove_dyn();

		virtual bool try_remove( ::zpp_nape::dynamics::ZPP_Contact obj);
		Dynamic try_remove_dyn();

		virtual Void inlined_remove( ::zpp_nape::dynamics::ZPP_Contact obj);
		Dynamic inlined_remove_dyn();

		virtual bool inlined_try_remove( ::zpp_nape::dynamics::ZPP_Contact obj);
		Dynamic inlined_try_remove_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact erase( ::zpp_nape::dynamics::ZPP_Contact pre);
		Dynamic erase_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact inlined_erase( ::zpp_nape::dynamics::ZPP_Contact pre);
		Dynamic inlined_erase_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact splice( ::zpp_nape::dynamics::ZPP_Contact pre,int n);
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

		virtual bool has( ::zpp_nape::dynamics::ZPP_Contact obj);
		Dynamic has_dyn();

		virtual bool inlined_has( ::zpp_nape::dynamics::ZPP_Contact obj);
		Dynamic inlined_has_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact front( );
		Dynamic front_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact back( );
		Dynamic back_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact iterator_at( int ind);
		Dynamic iterator_at_dyn();

		virtual ::zpp_nape::dynamics::ZPP_Contact at( int ind);
		Dynamic at_dyn();

		static bool internal;
		static ::zpp_nape::dynamics::ZPP_Contact zpp_pool;
};

} // end namespace zpp_nape
} // end namespace dynamics

#endif /* INCLUDED_zpp_nape_dynamics_ZPP_Contact */ 
