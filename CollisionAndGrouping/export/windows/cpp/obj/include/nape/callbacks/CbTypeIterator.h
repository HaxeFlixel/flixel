#ifndef INCLUDED_nape_callbacks_CbTypeIterator
#define INCLUDED_nape_callbacks_CbTypeIterator

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,CbType)
HX_DECLARE_CLASS2(nape,callbacks,CbTypeIterator)
HX_DECLARE_CLASS2(nape,callbacks,CbTypeList)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  CbTypeIterator_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef CbTypeIterator_obj OBJ_;
		CbTypeIterator_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< CbTypeIterator_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~CbTypeIterator_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("CbTypeIterator"); }

		::nape::callbacks::CbTypeList zpp_inner;
		int zpp_i;
		bool zpp_critical;
		::nape::callbacks::CbTypeIterator zpp_next;
		virtual bool hasNext( );
		Dynamic hasNext_dyn();

		virtual ::nape::callbacks::CbType next( );
		Dynamic next_dyn();

		static ::nape::callbacks::CbTypeIterator zpp_pool;
		static ::nape::callbacks::CbTypeIterator get( ::nape::callbacks::CbTypeList list);
		static Dynamic get_dyn();

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_CbTypeIterator */ 
