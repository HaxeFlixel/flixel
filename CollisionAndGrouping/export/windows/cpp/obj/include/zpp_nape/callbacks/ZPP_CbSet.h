#ifndef INCLUDED_zpp_nape_callbacks_ZPP_CbSet
#define INCLUDED_zpp_nape_callbacks_ZPP_CbSet

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,constraint,ConstraintList)
HX_DECLARE_CLASS2(nape,phys,InteractorList)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbSet)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_InteractionListener)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_CbSetManager)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_BodyListener)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CbSetPair)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_CbType)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_ConstraintListener)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_InteractionListener)
HX_DECLARE_CLASS2(zpp_nape,util,ZNPList_ZPP_Interactor)
namespace zpp_nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ZPP_CbSet_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_CbSet_obj OBJ_;
		ZPP_CbSet_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_CbSet_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_CbSet_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_CbSet"); }

		::zpp_nape::util::ZNPList_ZPP_CbType cbTypes;
		int count;
		::zpp_nape::callbacks::ZPP_CbSet next;
		int id;
		::zpp_nape::space::ZPP_CbSetManager manager;
		::zpp_nape::util::ZNPList_ZPP_CbSetPair cbpairs;
		virtual Void increment( );
		Dynamic increment_dyn();

		virtual bool decrement( );
		Dynamic decrement_dyn();

		virtual Void invalidate_pairs( );
		Dynamic invalidate_pairs_dyn();

		::zpp_nape::util::ZNPList_ZPP_InteractionListener listeners;
		bool zip_listeners;
		virtual Void invalidate_listeners( );
		Dynamic invalidate_listeners_dyn();

		virtual Void validate_listeners( );
		Dynamic validate_listeners_dyn();

		virtual Void realvalidate_listeners( );
		Dynamic realvalidate_listeners_dyn();

		::zpp_nape::util::ZNPList_ZPP_BodyListener bodylisteners;
		bool zip_bodylisteners;
		virtual Void invalidate_bodylisteners( );
		Dynamic invalidate_bodylisteners_dyn();

		virtual Void validate_bodylisteners( );
		Dynamic validate_bodylisteners_dyn();

		virtual Void realvalidate_bodylisteners( );
		Dynamic realvalidate_bodylisteners_dyn();

		::zpp_nape::util::ZNPList_ZPP_ConstraintListener conlisteners;
		bool zip_conlisteners;
		virtual Void invalidate_conlisteners( );
		Dynamic invalidate_conlisteners_dyn();

		virtual Void validate_conlisteners( );
		Dynamic validate_conlisteners_dyn();

		virtual Void realvalidate_conlisteners( );
		Dynamic realvalidate_conlisteners_dyn();

		virtual Void validate( );
		Dynamic validate_dyn();

		::zpp_nape::util::ZNPList_ZPP_Interactor interactors;
		::nape::phys::InteractorList wrap_interactors;
		::zpp_nape::util::ZNPList_ZPP_Constraint constraints;
		::nape::constraint::ConstraintList wrap_constraints;
		virtual Void addConstraint( ::zpp_nape::constraint::ZPP_Constraint con);
		Dynamic addConstraint_dyn();

		virtual Void addInteractor( ::zpp_nape::phys::ZPP_Interactor intx);
		Dynamic addInteractor_dyn();

		virtual Void remConstraint( ::zpp_nape::constraint::ZPP_Constraint con);
		Dynamic remConstraint_dyn();

		virtual Void remInteractor( ::zpp_nape::phys::ZPP_Interactor intx);
		Dynamic remInteractor_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		static ::zpp_nape::callbacks::ZPP_CbSet zpp_pool;
		static bool setlt( ::zpp_nape::callbacks::ZPP_CbSet a,::zpp_nape::callbacks::ZPP_CbSet b);
		static Dynamic setlt_dyn();

		static ::zpp_nape::callbacks::ZPP_CbSet get( ::zpp_nape::util::ZNPList_ZPP_CbType cbTypes);
		static Dynamic get_dyn();

		static bool compatible( ::zpp_nape::callbacks::ZPP_InteractionListener i,::zpp_nape::callbacks::ZPP_CbSet a,::zpp_nape::callbacks::ZPP_CbSet b);
		static Dynamic compatible_dyn();

		static bool empty_intersection( ::zpp_nape::callbacks::ZPP_CbSet a,::zpp_nape::callbacks::ZPP_CbSet b);
		static Dynamic empty_intersection_dyn();

		static bool single_intersection( ::zpp_nape::callbacks::ZPP_CbSet a,::zpp_nape::callbacks::ZPP_CbSet b,::zpp_nape::callbacks::ZPP_InteractionListener i);
		static Dynamic single_intersection_dyn();

		static Void find_all( ::zpp_nape::callbacks::ZPP_CbSet a,::zpp_nape::callbacks::ZPP_CbSet b,int event,Dynamic cb);
		static Dynamic find_all_dyn();

};

} // end namespace zpp_nape
} // end namespace callbacks

#endif /* INCLUDED_zpp_nape_callbacks_ZPP_CbSet */ 
