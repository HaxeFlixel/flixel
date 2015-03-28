#ifndef INCLUDED_flixel_system_frontEnds_ConsoleFrontEnd
#define INCLUDED_flixel_system_frontEnds_ConsoleFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,frontEnds,ConsoleFrontEnd)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  ConsoleFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ConsoleFrontEnd_obj OBJ_;
		ConsoleFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ConsoleFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ConsoleFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ConsoleFrontEnd"); }

		bool autoPause;
		virtual Void registerFunction( ::String FunctionAlias,Dynamic Function);
		Dynamic registerFunction_dyn();

		virtual Void registerObject( ::String ObjectAlias,Dynamic AnyObject);
		Dynamic registerObject_dyn();

		virtual Void addCommand( Array< ::String > Aliases,Dynamic ProcessFunction,::String Help,::String ParamHelp,hx::Null< int >  NumParams,hx::Null< int >  ParamCutoff);
		Dynamic addCommand_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_ConsoleFrontEnd */ 
