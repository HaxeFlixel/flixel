#ifndef INCLUDED_nape_callbacks_ListenerType
#define INCLUDED_nape_callbacks_ListenerType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,ListenerType)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ListenerType_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ListenerType_obj OBJ_;
		ListenerType_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ListenerType_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ListenerType_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ListenerType"); }

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::callbacks::ListenerType get_BODY( );
		static Dynamic get_BODY_dyn();

		static ::nape::callbacks::ListenerType get_CONSTRAINT( );
		static Dynamic get_CONSTRAINT_dyn();

		static ::nape::callbacks::ListenerType get_INTERACTION( );
		static Dynamic get_INTERACTION_dyn();

		static ::nape::callbacks::ListenerType get_PRE( );
		static Dynamic get_PRE_dyn();

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_ListenerType */ 
