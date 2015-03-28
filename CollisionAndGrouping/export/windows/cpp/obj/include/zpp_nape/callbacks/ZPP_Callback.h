#ifndef INCLUDED_zpp_nape_callbacks_ZPP_Callback
#define INCLUDED_zpp_nape_callbacks_ZPP_Callback

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,BodyCallback)
HX_DECLARE_CLASS2(nape,callbacks,Callback)
HX_DECLARE_CLASS2(nape,callbacks,ConstraintCallback)
HX_DECLARE_CLASS2(nape,callbacks,InteractionCallback)
HX_DECLARE_CLASS2(nape,dynamics,ArbiterList)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Callback)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_Listener)
HX_DECLARE_CLASS2(zpp_nape,constraint,ZPP_Constraint)
HX_DECLARE_CLASS2(zpp_nape,dynamics,ZPP_Arbiter)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_CallbackSet)
HX_DECLARE_CLASS2(zpp_nape,space,ZPP_Space)
namespace zpp_nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Callback_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Callback_obj OBJ_;
		ZPP_Callback_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Callback_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Callback_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Callback"); }

		::nape::callbacks::BodyCallback outer_body;
		::nape::callbacks::ConstraintCallback outer_con;
		::nape::callbacks::InteractionCallback outer_int;
		virtual ::nape::callbacks::BodyCallback wrapper_body( );
		Dynamic wrapper_body_dyn();

		virtual ::nape::callbacks::ConstraintCallback wrapper_con( );
		Dynamic wrapper_con_dyn();

		virtual ::nape::callbacks::InteractionCallback wrapper_int( );
		Dynamic wrapper_int_dyn();

		int event;
		::zpp_nape::callbacks::ZPP_Listener listener;
		::zpp_nape::space::ZPP_Space space;
		int index;
		::zpp_nape::callbacks::ZPP_Callback next;
		::zpp_nape::callbacks::ZPP_Callback prev;
		int length;
		virtual Void push( ::zpp_nape::callbacks::ZPP_Callback obj);
		Dynamic push_dyn();

		virtual Void push_rev( ::zpp_nape::callbacks::ZPP_Callback obj);
		Dynamic push_rev_dyn();

		virtual ::zpp_nape::callbacks::ZPP_Callback pop( );
		Dynamic pop_dyn();

		virtual ::zpp_nape::callbacks::ZPP_Callback pop_rev( );
		Dynamic pop_rev_dyn();

		virtual bool empty( );
		Dynamic empty_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual ::zpp_nape::callbacks::ZPP_Callback splice( ::zpp_nape::callbacks::ZPP_Callback o);
		Dynamic splice_dyn();

		virtual Void rotateL( );
		Dynamic rotateL_dyn();

		virtual Void rotateR( );
		Dynamic rotateR_dyn();

		virtual ::zpp_nape::callbacks::ZPP_Callback cycleNext( ::zpp_nape::callbacks::ZPP_Callback o);
		Dynamic cycleNext_dyn();

		virtual ::zpp_nape::callbacks::ZPP_Callback cyclePrev( ::zpp_nape::callbacks::ZPP_Callback o);
		Dynamic cyclePrev_dyn();

		virtual ::zpp_nape::callbacks::ZPP_Callback at( int i);
		Dynamic at_dyn();

		virtual ::zpp_nape::callbacks::ZPP_Callback rev_at( int i);
		Dynamic rev_at_dyn();

		virtual Void free( );
		Dynamic free_dyn();

		virtual Void alloc( );
		Dynamic alloc_dyn();

		::zpp_nape::phys::ZPP_Interactor int1;
		::zpp_nape::phys::ZPP_Interactor int2;
		::zpp_nape::space::ZPP_CallbackSet set;
		::nape::dynamics::ArbiterList wrap_arbiters;
		::zpp_nape::dynamics::ZPP_Arbiter pre_arbiter;
		bool pre_swapped;
		virtual Void genarbs( );
		Dynamic genarbs_dyn();

		::zpp_nape::phys::ZPP_Body body;
		::zpp_nape::constraint::ZPP_Constraint constraint;
		static bool internal;
		static ::zpp_nape::callbacks::ZPP_Callback zpp_pool;
};

} // end namespace zpp_nape
} // end namespace callbacks

#endif /* INCLUDED_zpp_nape_callbacks_ZPP_Callback */ 
