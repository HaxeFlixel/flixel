#ifndef INCLUDED_cpp_vm_Gc
#define INCLUDED_cpp_vm_Gc

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(cpp,vm,Gc)
namespace cpp{
namespace vm{


class HXCPP_CLASS_ATTRIBUTES  Gc_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Gc_obj OBJ_;
		Gc_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Gc_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Gc_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("Gc"); }

		static Void run( bool major);
		static Dynamic run_dyn();

};

} // end namespace cpp
} // end namespace vm

#endif /* INCLUDED_cpp_vm_Gc */ 
