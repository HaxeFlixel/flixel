#ifndef INCLUDED_nape_phys_CompoundList
#define INCLUDED_nape_phys_CompoundList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Compound)
HX_DECLARE_CLASS2(nape,phys,CompoundIterator)
HX_DECLARE_CLASS2(nape,phys,CompoundList)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_CompoundList)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  CompoundList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef CompoundList_obj OBJ_;
		CompoundList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< CompoundList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~CompoundList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("CompoundList"); }

		::zpp_nape::util::ZPP_CompoundList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::phys::Compound obj);
		Dynamic has_dyn();

		virtual ::nape::phys::Compound at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::phys::Compound obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::phys::Compound obj);
		Dynamic unshift_dyn();

		virtual ::nape::phys::Compound pop( );
		Dynamic pop_dyn();

		virtual ::nape::phys::Compound shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::phys::Compound obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::phys::Compound obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::phys::CompoundIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::phys::CompoundList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::phys::CompoundList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::phys::CompoundList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::phys::CompoundList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::phys::CompoundList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_CompoundList */ 
