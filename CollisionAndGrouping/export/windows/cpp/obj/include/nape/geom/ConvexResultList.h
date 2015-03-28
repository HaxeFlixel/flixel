#ifndef INCLUDED_nape_geom_ConvexResultList
#define INCLUDED_nape_geom_ConvexResultList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,ConvexResult)
HX_DECLARE_CLASS2(nape,geom,ConvexResultIterator)
HX_DECLARE_CLASS2(nape,geom,ConvexResultList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ConvexResultList)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ConvexResultList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ConvexResultList_obj OBJ_;
		ConvexResultList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ConvexResultList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ConvexResultList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ConvexResultList"); }

		::zpp_nape::util::ZPP_ConvexResultList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::geom::ConvexResult obj);
		Dynamic has_dyn();

		virtual ::nape::geom::ConvexResult at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::geom::ConvexResult obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::geom::ConvexResult obj);
		Dynamic unshift_dyn();

		virtual ::nape::geom::ConvexResult pop( );
		Dynamic pop_dyn();

		virtual ::nape::geom::ConvexResult shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::geom::ConvexResult obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::geom::ConvexResult obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::geom::ConvexResultIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::geom::ConvexResultList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::geom::ConvexResultList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::geom::ConvexResultList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::geom::ConvexResultList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::geom::ConvexResultList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_ConvexResultList */ 
