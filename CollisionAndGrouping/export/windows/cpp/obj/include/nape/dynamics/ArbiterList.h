#ifndef INCLUDED_nape_dynamics_ArbiterList
#define INCLUDED_nape_dynamics_ArbiterList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,dynamics,Arbiter)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterIterator)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterList)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ArbiterList)
namespace nape{
namespace dynamics{


class HXCPP_CLASS_ATTRIBUTES  ArbiterList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ArbiterList_obj OBJ_;
		ArbiterList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ArbiterList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ArbiterList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ArbiterList"); }

		::zpp_nape::util::ZPP_ArbiterList zpp_inner;
		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual int zpp_gl( );
		Dynamic zpp_gl_dyn();

		virtual Void zpp_vm( );
		Dynamic zpp_vm_dyn();

		virtual bool has( ::nape::dynamics::Arbiter obj);
		Dynamic has_dyn();

		virtual ::nape::dynamics::Arbiter at( int index);
		Dynamic at_dyn();

		virtual bool push( ::nape::dynamics::Arbiter obj);
		Dynamic push_dyn();

		virtual bool unshift( ::nape::dynamics::Arbiter obj);
		Dynamic unshift_dyn();

		virtual ::nape::dynamics::Arbiter pop( );
		Dynamic pop_dyn();

		virtual ::nape::dynamics::Arbiter shift( );
		Dynamic shift_dyn();

		virtual bool add( ::nape::dynamics::Arbiter obj);
		Dynamic add_dyn();

		virtual bool remove( ::nape::dynamics::Arbiter obj);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual ::nape::dynamics::ArbiterIterator iterator( );
		Dynamic iterator_dyn();

		virtual ::nape::dynamics::ArbiterList copy( hx::Null< bool >  deep);
		Dynamic copy_dyn();

		virtual Void merge( ::nape::dynamics::ArbiterList xs);
		Dynamic merge_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual ::nape::dynamics::ArbiterList foreach( Dynamic lambda);
		Dynamic foreach_dyn();

		virtual ::nape::dynamics::ArbiterList filter( Dynamic lambda);
		Dynamic filter_dyn();

		static ::nape::dynamics::ArbiterList fromArray( Array< ::Dynamic > array);
		static Dynamic fromArray_dyn();

};

} // end namespace nape
} // end namespace dynamics

#endif /* INCLUDED_nape_dynamics_ArbiterList */ 
