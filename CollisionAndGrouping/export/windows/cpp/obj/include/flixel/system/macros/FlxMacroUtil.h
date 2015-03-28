#ifndef INCLUDED_flixel_system_macros_FlxMacroUtil
#define INCLUDED_flixel_system_macros_FlxMacroUtil

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,macros,FlxMacroUtil)
namespace flixel{
namespace system{
namespace macros{


class HXCPP_CLASS_ATTRIBUTES  FlxMacroUtil_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxMacroUtil_obj OBJ_;
		FlxMacroUtil_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxMacroUtil_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxMacroUtil_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxMacroUtil"); }

};

} // end namespace flixel
} // end namespace system
} // end namespace macros

#endif /* INCLUDED_flixel_system_macros_FlxMacroUtil */ 
