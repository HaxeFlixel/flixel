#ifndef INCLUDED_nape_dynamics_ContactList
#define INCLUDED_nape_dynamics_ContactList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,Contact)
HX_DECLARE_CLASS2(nape,dynamics,ContactIterator)
HX_DECLARE_CLASS2(nape,dynamics,ContactList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ContactList)
namespace nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ContactList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ContactList_obj OBJ_;
		ContactList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ContactList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ContactList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ContactList"); }

		::zpp_nape::util::ZPP_ContactList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::dynamics::Contact obj);
		Dynamic has_dyn();

		virtual ::nape::dynamics::Contact at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::dynamics::Contact obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::dynamics::Contact obj);
		Dynamic unshift_dyn();

		virtual ::nape::dynamics::Contact pop( );
		Dynamic pop_dyn();

		virtual ::nape::dynamics::Contact shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::dynamics::Contact obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::dynamics::Contact obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::dynamics::ContactIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::dynamics::ContactList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::dynamics::ContactList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::dynamics::ContactList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::dynamics::ContactList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::dynamics::ContactList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace dynamics

#endif /* INCLUDED_nape_dynamics_ContactList */ 
