#ifndef INCLUDED_Lambda
#define INCLUDED_Lambda

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(Lambda)


class HXCPP_CLASS_ATTRIBUTES  Lambda_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Lambda_obj OBJ_;
		Lambda_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Lambda_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Lambda_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("Lambda"); }

		static Dynamic array( Dynamic it);
		static Dynamic array_dyn();

		static bool has( Dynamic it,Dynamic elt);
		static Dynamic has_dyn();

};


#endif /* INCLUDED_Lambda */ 
