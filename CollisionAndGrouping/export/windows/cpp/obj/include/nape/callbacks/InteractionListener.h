#ifndef INCLUDED_nape_callbacks_InteractionListener
#define INCLUDED_nape_callbacks_InteractionListener

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/callbacks/Listener.h>
HX_DECLARE_CLASS2(nape,callbacks,Callback)
HX_DECLARE_CLASS2(nape,callbacks,CbEvent)
HX_DECLARE_CLASS2(nape,callbacks,InteractionCallback)
HX_DECLARE_CLASS2(nape,callbacks,InteractionListener)
HX_DECLARE_CLASS2(nape,callbacks,InteractionType)
HX_DECLARE_CLASS2(nape,callbacks,Listener)
HX_DECLARE_CLASS2(nape,callbacks,OptionType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_InteractionListener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  InteractionListener_obj : public ::nape::callbacks::Listener_obj{
	public:
		typedef ::nape::callbacks::Listener_obj super;
		typedef InteractionListener_obj OBJ_;
		InteractionListener_obj();
		Void __construct(::nape::callbacks::CbEvent event,::nape::callbacks::InteractionType interactionType,Dynamic options1,Dynamic options2,Dynamic handler,hx::Null< int >  __o_precedence);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< InteractionListener_obj > __new(::nape::callbacks::CbEvent event,::nape::callbacks::InteractionType interactionType,Dynamic options1,Dynamic options2,Dynamic handler,hx::Null< int >  __o_precedence);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~InteractionListener_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("InteractionListener"); }

		::zpp_nape::callbacks::ZPP_InteractionListener zpp_inner_zn;
		virtual ::nape::callbacks::OptionType get_options1( );
		Dynamic get_options1_dyn();

		virtual ::nape::callbacks::OptionType set_options1( ::nape::callbacks::OptionType options1);
		Dynamic set_options1_dyn();

		virtual ::nape::callbacks::OptionType get_options2( );
		Dynamic get_options2_dyn();

		virtual ::nape::callbacks::OptionType set_options2( ::nape::callbacks::OptionType options2);
		Dynamic set_options2_dyn();

		virtual ::nape::callbacks::InteractionType get_interactionType( );
		Dynamic get_interactionType_dyn();

		virtual ::nape::callbacks::InteractionType set_interactionType( ::nape::callbacks::InteractionType interactionType);
		Dynamic set_interactionType_dyn();

		virtual Dynamic get_handler( );
		Dynamic get_handler_dyn();

		virtual Dynamic set_handler( Dynamic handler);
		Dynamic set_handler_dyn();

		virtual bool get_allowSleepingCallbacks( );
		Dynamic get_allowSleepingCallbacks_dyn();

		virtual bool set_allowSleepingCallbacks( bool allowSleepingCallbacks);
		Dynamic set_allowSleepingCallbacks_dyn();

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_InteractionListener */ 
