#ifndef INCLUDED_zpp_nape_callbacks_ZPP_BodyListener
#define INCLUDED_zpp_nape_callbacks_ZPP_BodyListener

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/callbacks/ZPP_Listener.h>
HX_DECLARE_CLASS2(nape,callbacks,BodyCallback)
HX_DECLARE_CLASS2(nape,callbacks,BodyListener)
HX_DECLARE_CLASS2(nape,callbacks,Callback)
HX_DECLARE_CLASS2(nape,callbacks,Listener)
HX_DECLARE_CLASS2(nape,callbacks,OptionType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_BodyListener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_OptionType)
namespace zpp_nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ZPP_BodyListener_obj : public ::zpp_nape::callbacks::ZPP_Listener_obj{
	public:
		typedef ::zpp_nape::callbacks::ZPP_Listener_obj super;
		typedef ZPP_BodyListener_obj OBJ_;
		ZPP_BodyListener_obj();
		Void __construct(::nape::callbacks::OptionType options,int event,Dynamic handler);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_BodyListener_obj > __new(::nape::callbacks::OptionType options,int event,Dynamic handler);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_BodyListener_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_BodyListener"); }

		::nape::callbacks::BodyListener outer_zn;
		::zpp_nape::callbacks::ZPP_OptionType options;
		Dynamic handler;
		Dynamic &handler_dyn() { return handler;}
		virtual Void immutable_options( );
		Dynamic immutable_options_dyn();

		virtual Void addedToSpace( );

		virtual Void removedFromSpace( );

		virtual Void cbtype_change( ::zpp_nape::callbacks::ZPP_CbType cb,bool included,bool added);
		Dynamic cbtype_change_dyn();

		virtual Void invalidate_precedence( );

		virtual Void swapEvent( int newev);

};

} // end namespace zpp_nape
} // end namespace callbacks

#endif /* INCLUDED_zpp_nape_callbacks_ZPP_BodyListener */ 
