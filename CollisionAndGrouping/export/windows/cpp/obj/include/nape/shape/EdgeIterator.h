#ifndef INCLUDED_nape_shape_EdgeIterator
#define INCLUDED_nape_shape_EdgeIterator

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,shape,Edge)
HX_DECLARE_CLASS2(nape,shape,EdgeIterator)
HX_DECLARE_CLASS2(nape,shape,EdgeList)
namespace nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  EdgeIterator_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef EdgeIterator_obj OBJ_;
		EdgeIterator_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< EdgeIterator_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~EdgeIterator_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("EdgeIterator"); }

		::nape::shape::EdgeList zpp_inner;
		int zpp_i;
		bool zpp_critical;
		::nape::shape::EdgeIterator zpp_next;
		virtual bool hasNext( );
		Dynamic hasNext_dyn();

		virtual ::nape::shape::Edge next( );
		Dynamic next_dyn();

		static ::nape::shape::EdgeIterator zpp_pool;
		static ::nape::shape::EdgeIterator get( ::nape::shape::EdgeList list);
		static Dynamic get_dyn();

};

} // end namespace nape
} // end namespace shape

#endif /* INCLUDED_nape_shape_EdgeIterator */ 
