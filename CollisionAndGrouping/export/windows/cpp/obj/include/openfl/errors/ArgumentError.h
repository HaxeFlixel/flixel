#ifndef INCLUDED_openfl_errors_ArgumentError
#define INCLUDED_openfl_errors_ArgumentError

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/errors/Error.h>
HX_DECLARE_CLASS2(openfl,errors,ArgumentError)
HX_DECLARE_CLASS2(openfl,errors,Error)
namespace openfl{
namespace errors{


class HXCPP_CLASS_ATTRIBUTES  ArgumentError_obj : public ::openfl::errors::Error_obj{
	public:
		typedef ::openfl::errors::Error_obj super;
		typedef ArgumentError_obj OBJ_;
		ArgumentError_obj();
		Void __construct(::String __o_inMessage);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ArgumentError_obj > __new(::String __o_inMessage);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ArgumentError_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ArgumentError"); }

};

} // end namespace openfl
} // end namespace errors

#endif /* INCLUDED_openfl_errors_ArgumentError */ 
