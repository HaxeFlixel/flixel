#ifndef INCLUDED_openfl__v2_net_URLRequest
#define INCLUDED_openfl__v2_net_URLRequest

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS3(openfl,_v2,net,URLRequest)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
HX_DECLARE_CLASS2(openfl,net,URLRequestHeader)
namespace openfl{
namespace _v2{
namespace net{


class HXCPP_CLASS_ATTRIBUTES  URLRequest_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef URLRequest_obj OBJ_;
		URLRequest_obj();
		Void __construct(::String url);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< URLRequest_obj > __new(::String url);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~URLRequest_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("URLRequest"); }

		int authType;
		::String contentType;
		::String cookieString;
		::String credentials;
		Dynamic data;
		bool followRedirects;
		::String method;
		Array< ::Dynamic > requestHeaders;
		::String url;
		::String userAgent;
		bool verbose;
		::openfl::_v2::utils::ByteArray __bytes;
		virtual Void basicAuth( ::String user,::String password);
		Dynamic basicAuth_dyn();

		virtual Void digestAuth( ::String user,::String password);
		Dynamic digestAuth_dyn();

		virtual Void __prepare( );
		Dynamic __prepare_dyn();

		static int AUTH_BASIC;
		static int AUTH_DIGEST;
		static int AUTH_GSSNEGOTIATE;
		static int AUTH_NTLM;
		static int AUTH_DIGEST_IE;
		static int AUTH_DIGEST_ANY;
};

} // end namespace openfl
} // end namespace _v2
} // end namespace net

#endif /* INCLUDED_openfl__v2_net_URLRequest */ 
