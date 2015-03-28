#ifndef INCLUDED_openfl_system_ApplicationDomain
#define INCLUDED_openfl_system_ApplicationDomain

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,system,ApplicationDomain)
namespace openfl{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  ApplicationDomain_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ApplicationDomain_obj OBJ_;
		ApplicationDomain_obj();
		Void __construct(::openfl::system::ApplicationDomain parentDomain);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ApplicationDomain_obj > __new(::openfl::system::ApplicationDomain parentDomain);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ApplicationDomain_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ApplicationDomain"); }

		::openfl::system::ApplicationDomain parentDomain;
		virtual Dynamic getDefinition( ::String name);
		Dynamic getDefinition_dyn();

		virtual bool hasDefinition( ::String name);
		Dynamic hasDefinition_dyn();

		static ::openfl::system::ApplicationDomain currentDomain;
};

} // end namespace openfl
} // end namespace system

#endif /* INCLUDED_openfl_system_ApplicationDomain */ 
