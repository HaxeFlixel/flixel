#ifndef INCLUDED_nape_callbacks_ConstraintListener
#define INCLUDED_nape_callbacks_ConstraintListener

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/callbacks/Listener.h>
HX_DECLARE_CLASS2(nape,callbacks,Callback)
HX_DECLARE_CLASS2(nape,callbacks,CbEvent)
HX_DECLARE_CLASS2(nape,callbacks,ConstraintCallback)
HX_DECLARE_CLASS2(nape,callbacks,ConstraintListener)
HX_DECLARE_CLASS2(nape,callbacks,Listener)
HX_DECLARE_CLASS2(nape,callbacks,OptionType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_ConstraintListener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ConstraintListener_obj : public ::nape::callbacks::Listener_obj{
	public:
		typedef ::nape::callbacks::Listener_obj super;
		typedef ConstraintListener_obj OBJ_;
		ConstraintListener_obj();
		Void __construct(::nape::callbacks::CbEvent event,Dynamic options,Dynamic handler,hx::Null< int >  __o_precedence);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ConstraintListener_obj > __new(::nape::callbacks::CbEvent event,Dynamic options,Dynamic handler,hx::Null< int >  __o_precedence);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ConstraintListener_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ConstraintListener"); }

		::zpp_nape::callbacks::ZPP_ConstraintListener zpp_inner_zn;
		virtual ::nape::callbacks::OptionType get_options( );
		Dynamic get_options_dyn();

		virtual ::nape::callbacks::OptionType set_options( ::nape::callbacks::OptionType options);
		Dynamic set_options_dyn();

		virtual Dynamic get_handler( );
		Dynamic get_handler_dyn();

		virtual Dynamic set_handler( Dynamic handler);
		Dynamic set_handler_dyn();

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_ConstraintListener */ 
