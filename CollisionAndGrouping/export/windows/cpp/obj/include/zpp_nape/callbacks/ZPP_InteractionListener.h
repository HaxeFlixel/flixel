#ifndef INCLUDED_zpp_nape_callbacks_ZPP_InteractionListener
#define INCLUDED_zpp_nape_callbacks_ZPP_InteractionListener

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <zpp_nape/callbacks/ZPP_Listener.h>
HX_DECLARE_CLASS2(nape,callbacks,Callback)
HX_DECLARE_CLASS2(nape,callbacks,InteractionCallback)
HX_DECLARE_CLASS2(nape,callbacks,InteractionListener)
HX_DECLARE_CLASS2(nape,callbacks,Listener)
HX_DECLARE_CLASS2(nape,callbacks,OptionType)
HX_DECLARE_CLASS2(nape,callbacks,PreCallback)
HX_DECLARE_CLASS2(nape,callbacks,PreFlag)
HX_DECLARE_CLASS2(nape,callbacks,PreListener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbSet)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_InteractionListener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_OptionType)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CbSet)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CbType)
namespace zpp_nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ZPP_InteractionListener_obj : public ::zpp_nape::callbacks::ZPP_Listener_obj{
	public:
		typedef ::zpp_nape::callbacks::ZPP_Listener_obj super;
		typedef ZPP_InteractionListener_obj OBJ_;
		ZPP_InteractionListener_obj();
		Void __construct(::nape::callbacks::OptionType options1,::nape::callbacks::OptionType options2,int event,int type);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_InteractionListener_obj > __new(::nape::callbacks::OptionType options1,::nape::callbacks::OptionType options2,int event,int type);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_InteractionListener_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_InteractionListener"); }

		::nape::callbacks::InteractionListener outer_zni;
		::nape::callbacks::PreListener outer_znp;
		int itype;
		::zpp_nape::callbacks::ZPP_OptionType options1;
		::zpp_nape::callbacks::ZPP_OptionType options2;
		Dynamic handleri;
		Dynamic &handleri_dyn() { return handleri;}
		bool allowSleepingCallbacks;
		bool pure;
		Dynamic handlerp;
		Dynamic &handlerp_dyn() { return handlerp;}
		virtual Void setInteractionType( int itype);
		Dynamic setInteractionType_dyn();

		virtual Void wake( );
		Dynamic wake_dyn();

		virtual Void CbSetset( ::zpp_nape::util::ZNPList_ZPP_CbSet A,::zpp_nape::util::ZNPList_ZPP_CbSet B,Dynamic lambda);
		Dynamic CbSetset_dyn();

		virtual Void CbTypeset( ::zpp_nape::util::ZNPList_ZPP_CbType A,::zpp_nape::util::ZNPList_ZPP_CbType B,Dynamic lambda);
		Dynamic CbTypeset_dyn();

		virtual Void with_uniquesets( bool fresh);
		Dynamic with_uniquesets_dyn();

		virtual Void with_union( Dynamic lambda);
		Dynamic with_union_dyn();

		virtual Void addedToSpace( );

		virtual Void removedFromSpace( );

		virtual Void invalidate_precedence( );

		virtual Void cbtype_change1( ::zpp_nape::callbacks::ZPP_CbType cb,bool included,bool added);
		Dynamic cbtype_change1_dyn();

		virtual Void cbtype_change2( ::zpp_nape::callbacks::ZPP_CbType cb,bool included,bool added);
		Dynamic cbtype_change2_dyn();

		virtual Void cbtype_change( ::zpp_nape::callbacks::ZPP_OptionType options,::zpp_nape::callbacks::ZPP_CbType cb,bool included,bool added);
		Dynamic cbtype_change_dyn();

		virtual Void swapEvent( int newev);

		static ::zpp_nape::util::ZNPList_ZPP_CbSet UCbSet;
		static ::zpp_nape::util::ZNPList_ZPP_CbSet VCbSet;
		static ::zpp_nape::util::ZNPList_ZPP_CbSet WCbSet;
		static ::zpp_nape::util::ZNPList_ZPP_CbType UCbType;
		static ::zpp_nape::util::ZNPList_ZPP_CbType VCbType;
		static ::zpp_nape::util::ZNPList_ZPP_CbType WCbType;
};

} // end namespace zpp_nape
} // end namespace callbacks

#endif /* INCLUDED_zpp_nape_callbacks_ZPP_InteractionListener */ 
