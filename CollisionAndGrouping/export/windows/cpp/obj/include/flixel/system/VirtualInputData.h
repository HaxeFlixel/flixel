#ifndef INCLUDED_flixel_system_VirtualInputData
#define INCLUDED_flixel_system_VirtualInputData

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/utils/ByteArray.h>
HX_DECLARE_CLASS2(flixel,system,VirtualInputData)
HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
namespace flixel{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  VirtualInputData_obj : public ::openfl::_v2::utils::ByteArray_obj{
	public:
		typedef ::openfl::_v2::utils::ByteArray_obj super;
		typedef VirtualInputData_obj OBJ_;
		VirtualInputData_obj();
		Void __construct(Dynamic __o_size);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< VirtualInputData_obj > __new(Dynamic __o_size);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~VirtualInputData_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("VirtualInputData"); }

		static ::String resourceName;
};

} // end namespace flixel
} // end namespace system

#endif /* INCLUDED_flixel_system_VirtualInputData */ 
