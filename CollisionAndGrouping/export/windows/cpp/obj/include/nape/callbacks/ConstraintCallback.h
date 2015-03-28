#ifndef INCLUDED_nape_callbacks_ConstraintCallback
#define INCLUDED_nape_callbacks_ConstraintCallback

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/callbacks/Callback.h>
HX_DECLARE_CLASS2(nape,callbacks,Callback)
HX_DECLARE_CLASS2(nape,callbacks,ConstraintCallback)
HX_DECLARE_CLASS2(nape,constraint,Constraint)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  ConstraintCallback_obj : public ::nape::callbacks::Callback_obj{
	public:
		typedef ::nape::callbacks::Callback_obj super;
		typedef ConstraintCallback_obj OBJ_;
		ConstraintCallback_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ConstraintCallback_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ConstraintCallback_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ConstraintCallback"); }

		virtual ::nape::constraint::Constraint get_constraint( );
		Dynamic get_constraint_dyn();

		virtual ::String toString( );

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_ConstraintCallback */ 
