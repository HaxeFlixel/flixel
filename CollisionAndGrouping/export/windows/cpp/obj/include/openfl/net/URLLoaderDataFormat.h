#ifndef INCLUDED_openfl_net_URLLoaderDataFormat
#define INCLUDED_openfl_net_URLLoaderDataFormat

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,net,URLLoaderDataFormat)
namespace openfl{
namespace net{


class URLLoaderDataFormat_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef URLLoaderDataFormat_obj OBJ_;

	public:
		URLLoaderDataFormat_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.net.URLLoaderDataFormat"); }
		::String __ToString() const { return HX_CSTRING("URLLoaderDataFormat.") + tag; }

		static ::openfl::net::URLLoaderDataFormat BINARY;
		static inline ::openfl::net::URLLoaderDataFormat BINARY_dyn() { return BINARY; }
		static ::openfl::net::URLLoaderDataFormat TEXT;
		static inline ::openfl::net::URLLoaderDataFormat TEXT_dyn() { return TEXT; }
		static ::openfl::net::URLLoaderDataFormat VARIABLES;
		static inline ::openfl::net::URLLoaderDataFormat VARIABLES_dyn() { return VARIABLES; }
};

} // end namespace openfl
} // end namespace net

#endif /* INCLUDED_openfl_net_URLLoaderDataFormat */ 
