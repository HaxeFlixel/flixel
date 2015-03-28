#ifndef INCLUDED_nape_shape_EdgeList
#define INCLUDED_nape_shape_EdgeList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,shape,Edge)
HX_DECLARE_CLASS2(nape,shape,EdgeIterator)
HX_DECLARE_CLASS2(nape,shape,EdgeList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_EdgeList)
namespace nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  EdgeList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef EdgeList_obj OBJ_;
		EdgeList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< EdgeList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~EdgeList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("EdgeList"); }

		::zpp_nape::util::ZPP_EdgeList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::shape::Edge obj);
		Dynamic has_dyn();

		virtual ::nape::shape::Edge at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::shape::Edge obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::shape::Edge obj);
		Dynamic unshift_dyn();

		virtual ::nape::shape::Edge pop( );
		Dynamic pop_dyn();

		virtual ::nape::shape::Edge shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::shape::Edge obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::shape::Edge obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::shape::EdgeIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::shape::EdgeList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::shape::EdgeList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::shape::EdgeList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::shape::EdgeList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::shape::EdgeList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace shape

#endif /* INCLUDED_nape_shape_EdgeList */ 
