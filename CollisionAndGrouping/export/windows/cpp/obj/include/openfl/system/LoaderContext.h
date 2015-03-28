#ifndef INCLUDED_openfl_system_LoaderContext
#define INCLUDED_openfl_system_LoaderContext

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,system,ApplicationDomain)
HX_DECLARE_CLASS2(openfl,system,LoaderContext)
HX_DECLARE_CLASS2(openfl,system,SecurityDomain)
namespace openfl{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  LoaderContext_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef LoaderContext_obj OBJ_;
		LoaderContext_obj();
		Void __construct(hx::Null< bool >  __o_checkPolicyFile,::openfl::system::ApplicationDomain applicationDomain,::openfl::system::SecurityDomain securityDomain);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< LoaderContext_obj > __new(hx::Null< bool >  __o_checkPolicyFile,::openfl::system::ApplicationDomain applicationDomain,::openfl::system::SecurityDomain securityDomain);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~LoaderContext_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("LoaderContext"); }

		bool allowCodeImport;
		bool allowLoadBytesCodeExecution;
		::openfl::system::ApplicationDomain applicationDomain;
		bool checkPolicyFile;
		::openfl::system::SecurityDomain securityDomain;
};

} // end namespace openfl
} // end namespace system

#endif /* INCLUDED_openfl_system_LoaderContext */ 
