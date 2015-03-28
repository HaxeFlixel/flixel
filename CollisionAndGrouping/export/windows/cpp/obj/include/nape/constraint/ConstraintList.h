#ifndef INCLUDED_nape_constraint_ConstraintList
#define INCLUDED_nape_constraint_ConstraintList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,constraint,Constraint)
HX_DECLARE_CLASS2(nape,constraint,ConstraintIterator)
HX_DECLARE_CLASS2(nape,constraint,ConstraintList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ConstraintList)
namespace nape{
namespace constraint{


class HXCPP_CLASS_ATTRIBUTES  ConstraintList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ConstraintList_obj OBJ_;
		ConstraintList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ConstraintList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ConstraintList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ConstraintList"); }

		::zpp_nape::util::ZPP_ConstraintList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::constraint::Constraint obj);
		Dynamic has_dyn();

		virtual ::nape::constraint::Constraint at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::constraint::Constraint obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::constraint::Constraint obj);
		Dynamic unshift_dyn();

		virtual ::nape::constraint::Constraint pop( );
		Dynamic pop_dyn();

		virtual ::nape::constraint::Constraint shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::constraint::Constraint obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::constraint::Constraint obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::constraint::ConstraintIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::constraint::ConstraintList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::constraint::ConstraintList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::constraint::ConstraintList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::constraint::ConstraintList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::constraint::ConstraintList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace constraint

#endif /* INCLUDED_nape_constraint_ConstraintList */ 
