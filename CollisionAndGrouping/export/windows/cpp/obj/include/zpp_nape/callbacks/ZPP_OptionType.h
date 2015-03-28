#ifndef INCLUDED_zpp_nape_callbacks_ZPP_OptionType
#define INCLUDED_zpp_nape_callbacks_ZPP_OptionType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,CbTypeList)
HX_DECLARE_CLASS2(nape,callbacks,OptionType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_OptionType)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CbType)
namespace zpp_nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ZPP_OptionType_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_OptionType_obj OBJ_;
		ZPP_OptionType_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_OptionType_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_OptionType_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_OptionType"); }

		::nape::callbacks::OptionType outer;
		Dynamic handler;
		Dynamic &handler_dyn() { return handler;}
		::zpp_nape::util::ZNPList_ZPP_CbType includes;
		::zpp_nape::util::ZNPList_ZPP_CbType excludes;
		::nape::callbacks::CbTypeList wrap_includes;
		::nape::callbacks::CbTypeList wrap_excludes;
		virtual Void setup_includes( );
		Dynamic setup_includes_dyn();

		virtual Void setup_excludes( );
		Dynamic setup_excludes_dyn();

		virtual bool excluded( ::zpp_nape::util::ZNPList_ZPP_CbType xs);
		Dynamic excluded_dyn();

		virtual bool included( ::zpp_nape::util::ZNPList_ZPP_CbType xs);
		Dynamic included_dyn();

		virtual bool compatible( ::zpp_nape::util::ZNPList_ZPP_CbType xs);
		Dynamic compatible_dyn();

		virtual bool nonemptyintersection( ::zpp_nape::util::ZNPList_ZPP_CbType xs,::zpp_nape::util::ZNPList_ZPP_CbType ys);
		Dynamic nonemptyintersection_dyn();

		virtual Void effect_change( ::zpp_nape::callbacks::ZPP_CbType val,bool included,bool added);
		Dynamic effect_change_dyn();

		virtual Void append_type( ::zpp_nape::util::ZNPList_ZPP_CbType list,::zpp_nape::callbacks::ZPP_CbType val);
		Dynamic append_type_dyn();

		virtual ::zpp_nape::callbacks::ZPP_OptionType set( ::zpp_nape::callbacks::ZPP_OptionType options);
		Dynamic set_dyn();

		virtual Void append( ::zpp_nape::util::ZNPList_ZPP_CbType list,Dynamic val);
		Dynamic append_dyn();

		static ::nape::callbacks::OptionType argument( Dynamic val);
		static Dynamic argument_dyn();

};

} // end namespace zpp_nape
} // end namespace callbacks

#endif /* INCLUDED_zpp_nape_callbacks_ZPP_OptionType */ 
