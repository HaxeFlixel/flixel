#ifndef INCLUDED_nape_shape_ShapeList
#define INCLUDED_nape_shape_ShapeList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(nape,shape,ShapeIterator)
HX_DECLARE_CLASS2(nape,shape,ShapeList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ShapeList)
namespace nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  ShapeList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ShapeList_obj OBJ_;
		ShapeList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ShapeList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ShapeList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ShapeList"); }

		::zpp_nape::util::ZPP_ShapeList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual bool has( ::nape::shape::Shape obj);
		Dynamic has_dyn();

		virtual ::nape::shape::Shape at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::shape::Shape obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::shape::Shape obj);
		Dynamic unshift_dyn();

		virtual ::nape::shape::Shape pop( );
		Dynamic pop_dyn();

		virtual ::nape::shape::Shape shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::shape::Shape obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::shape::Shape obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::shape::ShapeIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::shape::ShapeList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::shape::ShapeList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::shape::ShapeList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::shape::ShapeList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::shape::ShapeList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace shape

#endif /* INCLUDED_nape_shape_ShapeList */ 
