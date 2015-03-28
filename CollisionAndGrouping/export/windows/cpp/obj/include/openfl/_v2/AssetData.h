#ifndef INCLUDED_openfl__v2_AssetData
#define INCLUDED_openfl__v2_AssetData

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,_v2,AssetData)
HX_DECLARE_CLASS2(openfl,_v2,AssetType)
namespace openfl{
namespace _v2{


class HXCPP_CLASS_ATTRIBUTES  AssetData_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef AssetData_obj OBJ_;
		AssetData_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< AssetData_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~AssetData_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("AssetData"); }

		::String id;
		::String path;
		::openfl::_v2::AssetType type;
};

} // end namespace openfl
} // end namespace _v2

#endif /* INCLUDED_openfl__v2_AssetData */ 
