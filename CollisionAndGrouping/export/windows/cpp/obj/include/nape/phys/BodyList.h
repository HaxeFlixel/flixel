#ifndef INCLUDED_nape_phys_BodyList
#define INCLUDED_nape_phys_BodyList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,BodyIterator)
HX_DECLARE_CLASS2(nape,phys,BodyList)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_BodyList)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  BodyList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BodyList_obj OBJ_;
		BodyList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BodyList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BodyList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("BodyList"); }

		::zpp_nape::util::ZPP_BodyList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::phys::Body obj);
		Dynamic has_dyn();

		virtual ::nape::phys::Body at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::phys::Body obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::phys::Body obj);
		Dynamic unshift_dyn();

		virtual ::nape::phys::Body pop( );
		Dynamic pop_dyn();

		virtual ::nape::phys::Body shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::phys::Body obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::phys::Body obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::phys::BodyIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::phys::BodyList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::phys::BodyList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::phys::BodyList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::phys::BodyList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::phys::BodyList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_BodyList */ 
