#ifndef INCLUDED_openfl_errors_EOFError
#define INCLUDED_openfl_errors_EOFError

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/errors/Error.h>
HX_DECLARE_CLASS2(openfl,errors,EOFError)
HX_DECLARE_CLASS2(openfl,errors,Error)
namespace openfl{
namespace errors{


class HXCPP_CLASS_ATTRIBUTES  EOFError_obj : public ::openfl::errors::Error_obj{
	public:
		typedef ::openfl::errors::Error_obj super;
		typedef EOFError_obj OBJ_;
		EOFError_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< EOFError_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~EOFError_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("EOFError"); }

};

} // end namespace openfl
} // end namespace errors

#endif /* INCLUDED_openfl_errors_EOFError */ 
