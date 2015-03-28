#ifndef INCLUDED_zpp_nape_phys_ZPP_Interactor
#define INCLUDED_zpp_nape_phys_ZPP_Interactor

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,CbType)
HX_DECLARE_CLASS2(nape,callbacks,CbTypeList)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Callback)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbSet)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbType)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_InteractionListener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_InteractionGroup)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Compound)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_CallbackSet)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CallbackSet)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CbType)
namespace zpp_nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Interactor_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Interactor_obj OBJ_;
		ZPP_Interactor_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Interactor_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Interactor_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Interactor"); }

		::nape::phys::Interactor outer_i;
		int id;
		Dynamic userData;
		::zpp_nape::shape::ZPP_Shape ishape;
		::zpp_nape::phys::ZPP_Body ibody;
		::zpp_nape::phys::ZPP_Compound icompound;
		virtual bool isShape( );
		Dynamic isShape_dyn();

		virtual bool isBody( );
		Dynamic isBody_dyn();

		virtual bool isCompound( );
		Dynamic isCompound_dyn();

		virtual Void __iaddedToSpace( );
		Dynamic __iaddedToSpace_dyn();

		virtual Void __iremovedFromSpace( );
		Dynamic __iremovedFromSpace_dyn();

		virtual Void wake( );
		Dynamic wake_dyn();

		::zpp_nape::util::ZNPList_ZPP_CallbackSet cbsets;
		virtual ::zpp_nape::space::ZPP_Space getSpace( );
		Dynamic getSpace_dyn();

		::zpp_nape::dynamics::ZPP_InteractionGroup group;
		::zpp_nape::util::ZNPList_ZPP_CbType cbTypes;
		::zpp_nape::callbacks::ZPP_CbSet cbSet;
		::nape::callbacks::CbTypeList wrap_cbTypes;
		virtual Void setupcbTypes( );
		Dynamic setupcbTypes_dyn();

		virtual Void immutable_cbTypes( );
		Dynamic immutable_cbTypes_dyn();

		virtual Void wrap_cbTypes_subber( ::nape::callbacks::CbType pcb);
		Dynamic wrap_cbTypes_subber_dyn();

		virtual bool wrap_cbTypes_adder( ::nape::callbacks::CbType cb);
		Dynamic wrap_cbTypes_adder_dyn();

		virtual Void insert_cbtype( ::zpp_nape::callbacks::ZPP_CbType cb);
		Dynamic insert_cbtype_dyn();

		virtual Void alloc_cbSet( );
		Dynamic alloc_cbSet_dyn();

		virtual Void dealloc_cbSet( );
		Dynamic dealloc_cbSet_dyn();

		virtual Void setGroup( ::zpp_nape::dynamics::ZPP_InteractionGroup group);
		Dynamic setGroup_dyn();

		virtual Void immutable_midstep( ::String n);
		Dynamic immutable_midstep_dyn();

		virtual ::zpp_nape::dynamics::ZPP_InteractionGroup lookup_group( );
		Dynamic lookup_group_dyn();

		virtual Void copyto( ::nape::phys::Interactor ret);
		Dynamic copyto_dyn();

		static ::zpp_nape::space::ZPP_CallbackSet get( ::zpp_nape::phys::ZPP_Interactor i1,::zpp_nape::phys::ZPP_Interactor i2);
		static Dynamic get_dyn();

		static Void int_callback( ::zpp_nape::space::ZPP_CallbackSet set,::zpp_nape::callbacks::ZPP_InteractionListener x,::zpp_nape::callbacks::ZPP_Callback cb);
		static Dynamic int_callback_dyn();

};

} // end namespace zpp_nape
} // end namespace phys

#endif /* INCLUDED_zpp_nape_phys_ZPP_Interactor */ 
