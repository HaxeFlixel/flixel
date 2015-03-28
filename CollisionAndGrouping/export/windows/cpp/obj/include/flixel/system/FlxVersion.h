#ifndef INCLUDED_flixel_system_FlxVersion
#define INCLUDED_flixel_system_FlxVersion

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,system,FlxVersion)
namespace flixel{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  FlxVersion_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxVersion_obj OBJ_;
		FlxVersion_obj();
		Void __construct(int Major,int Minor,int Patch);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxVersion_obj > __new(int Major,int Minor,int Patch);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxVersion_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxVersion"); }

		int major;
		int minor;
		int patch;
		virtual ::String toString( );
		Dynamic toString_dyn();

		static Dynamic sha;
};

} // end namespace flixel
} // end namespace system

#endif /* INCLUDED_flixel_system_FlxVersion */ 
