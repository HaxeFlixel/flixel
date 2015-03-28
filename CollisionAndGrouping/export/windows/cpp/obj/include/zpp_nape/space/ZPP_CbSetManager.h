#ifndef INCLUDED_zpp_nape_space_ZPP_CbSetManager
#define INCLUDED_zpp_nape_space_ZPP_CbSetManager

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbSet)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbSetPair)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_CbSetManager)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CbType)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Set_ZPP_CbSet)
namespace zpp_nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  ZPP_CbSetManager_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_CbSetManager_obj OBJ_;
		ZPP_CbSetManager_obj();
		Void __construct(::zpp_nape::space::ZPP_Space space);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_CbSetManager_obj > __new(::zpp_nape::space::ZPP_Space space);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_CbSetManager_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_CbSetManager"); }

		::zpp_nape::util::ZPP_Set_ZPP_CbSet cbsets;
		::zpp_nape::space::ZPP_Space space;
		virtual ::zpp_nape::callbacks::ZPP_CbSet get( ::zpp_nape::util::ZNPList_ZPP_CbType cbTypes);
		Dynamic get_dyn();

		virtual Void remove( ::zpp_nape::callbacks::ZPP_CbSet set);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void validate( );
		Dynamic validate_dyn();

		virtual ::zpp_nape::callbacks::ZPP_CbSetPair pair( ::zpp_nape::callbacks::ZPP_CbSet a,::zpp_nape::callbacks::ZPP_CbSet b);
		Dynamic pair_dyn();

		virtual bool valid_listener( ::zpp_nape::callbacks::ZPP_Listener i);
		Dynamic valid_listener_dyn();

};

} // end namespace zpp_nape
} // end namespace space

#endif /* INCLUDED_zpp_nape_space_ZPP_CbSetManager */ 
