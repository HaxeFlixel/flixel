#ifndef INCLUDED_nape_callbacks_CbTypeList
#define INCLUDED_nape_callbacks_CbTypeList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,CbType)
HX_DECLARE_CLASS2(nape,callbacks,CbTypeIterator)
HX_DECLARE_CLASS2(nape,callbacks,CbTypeList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_CbTypeList)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  CbTypeList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef CbTypeList_obj OBJ_;
		CbTypeList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< CbTypeList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~CbTypeList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("CbTypeList"); }

		::zpp_nape::util::ZPP_CbTypeList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::callbacks::CbType obj);
		Dynamic has_dyn();

		virtual ::nape::callbacks::CbType at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::callbacks::CbType obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::callbacks::CbType obj);
		Dynamic unshift_dyn();

		virtual ::nape::callbacks::CbType pop( );
		Dynamic pop_dyn();

		virtual ::nape::callbacks::CbType shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::callbacks::CbType obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::callbacks::CbType obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::callbacks::CbTypeIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::callbacks::CbTypeList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::callbacks::CbTypeList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::callbacks::CbTypeList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::callbacks::CbTypeList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::callbacks::CbTypeList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_CbTypeList */ 
