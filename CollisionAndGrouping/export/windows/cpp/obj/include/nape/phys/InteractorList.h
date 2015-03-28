#ifndef INCLUDED_nape_phys_InteractorList
#define INCLUDED_nape_phys_InteractorList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,phys,InteractorIterator)
HX_DECLARE_CLASS2(nape,phys,InteractorList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_InteractorList)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  InteractorList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef InteractorList_obj OBJ_;
		InteractorList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< InteractorList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~InteractorList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("InteractorList"); }

		::zpp_nape::util::ZPP_InteractorList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::phys::Interactor obj);
		Dynamic has_dyn();

		virtual ::nape::phys::Interactor at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::phys::Interactor obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::phys::Interactor obj);
		Dynamic unshift_dyn();

		virtual ::nape::phys::Interactor pop( );
		Dynamic pop_dyn();

		virtual ::nape::phys::Interactor shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::phys::Interactor obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::phys::Interactor obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::phys::InteractorIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::phys::InteractorList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::phys::InteractorList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::phys::InteractorList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::phys::InteractorList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::phys::InteractorList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_InteractorList */ 
