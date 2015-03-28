#ifndef INCLUDED_nape_callbacks_InteractionCallback
#define INCLUDED_nape_callbacks_InteractionCallback

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/callbacks/Callback.h>
HX_DECLARE_CLASS2(nape,callbacks,Callback)
HX_DECLARE_CLASS2(nape,callbacks,InteractionCallback)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterList)
HX_DECLARE_CLASS2(nape,phys,Interactor)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  InteractionCallback_obj : public ::nape::callbacks::Callback_obj{
	public:
		typedef ::nape::callbacks::Callback_obj super;
		typedef InteractionCallback_obj OBJ_;
		InteractionCallback_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< InteractionCallback_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~InteractionCallback_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("InteractionCallback"); }

		virtual ::nape::phys::Interactor get_int1( );
		Dynamic get_int1_dyn();

		virtual ::nape::phys::Interactor get_int2( );
		Dynamic get_int2_dyn();

		virtual ::nape::dynamics::ArbiterList get_arbiters( );
		Dynamic get_arbiters_dyn();

		virtual ::String toString( );

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_InteractionCallback */ 
