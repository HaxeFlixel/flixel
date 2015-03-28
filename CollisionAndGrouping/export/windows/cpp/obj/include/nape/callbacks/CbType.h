#ifndef INCLUDED_nape_callbacks_CbType
#define INCLUDED_nape_callbacks_CbType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,CbType)
HX_DECLARE_CLASS2(nape,callbacks,OptionType)
HX_DECLARE_CLASS2(nape,constraint,ConstraintList)
HX_DECLARE_CLASS2(nape,phys,InteractorList)
HX_DECLARE_CLASS2(zpp_nape,callbacks,ZPP_CbType)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  CbType_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef CbType_obj OBJ_;
		CbType_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< CbType_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~CbType_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("CbType"); }

		::zpp_nape::callbacks::ZPP_CbType zpp_inner;
		virtual int get_id( );
		Dynamic get_id_dyn();

		virtual ::nape::callbacks::OptionType including( Dynamic includes);
		Dynamic including_dyn();

		virtual ::nape::callbacks::OptionType excluding( Dynamic excludes);
		Dynamic excluding_dyn();

		virtual Dynamic get_userData( );
		Dynamic get_userData_dyn();

		virtual ::nape::phys::InteractorList get_interactors( );
		Dynamic get_interactors_dyn();

		virtual ::nape::constraint::ConstraintList get_constraints( );
		Dynamic get_constraints_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::callbacks::CbType get_ANY_BODY( );
		static Dynamic get_ANY_BODY_dyn();

		static ::nape::callbacks::CbType get_ANY_CONSTRAINT( );
		static Dynamic get_ANY_CONSTRAINT_dyn();

		static ::nape::callbacks::CbType get_ANY_SHAPE( );
		static Dynamic get_ANY_SHAPE_dyn();

		static ::nape::callbacks::CbType get_ANY_COMPOUND( );
		static Dynamic get_ANY_COMPOUND_dyn();

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_CbType */ 
