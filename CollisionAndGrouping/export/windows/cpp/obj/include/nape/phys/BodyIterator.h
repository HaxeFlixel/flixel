#ifndef INCLUDED_nape_phys_BodyIterator
#define INCLUDED_nape_phys_BodyIterator

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,BodyIterator)
HX_DECLARE_CLASS2(nape,phys,BodyList)
HX_DECLARE_CLASS2(nape,phys,Interactor)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  BodyIterator_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BodyIterator_obj OBJ_;
		BodyIterator_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BodyIterator_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BodyIterator_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("BodyIterator"); }

		::nape::phys::BodyList zpp_inner;
		int zpp_i;
		bool zpp_critical;
		::nape::phys::BodyIterator zpp_next;
		virtual bool hasNext( );
		Dynamic hasNext_dyn();

		virtual ::nape::phys::Body next( );
		Dynamic next_dyn();

		static ::nape::phys::BodyIterator zpp_pool;
		static ::nape::phys::BodyIterator get( ::nape::phys::BodyList list);
		static Dynamic get_dyn();

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_BodyIterator */ 
