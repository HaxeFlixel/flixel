#ifndef INCLUDED_flixel_overlap_FlxOverlapData
#define INCLUDED_flixel_overlap_FlxOverlapData

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxVector)
HX_DECLARE_CLASS2(flixel,overlap,FlxOverlapData)
HX_DECLARE_CLASS2(flixel,overlap,IFlxHitbox)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace overlap{


class HXCPP_CLASS_ATTRIBUTES  FlxOverlapData_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxOverlapData_obj OBJ_;
		FlxOverlapData_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxOverlapData_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxOverlapData_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxOverlapData"); }

		Float overlap;
		::flixel::math::FlxVector separation;
		::flixel::overlap::IFlxHitbox hitbox1;
		::flixel::overlap::IFlxHitbox hitbox2;
		::flixel::math::FlxVector unitVector;
		virtual ::flixel::overlap::FlxOverlapData copyFrom( ::flixel::overlap::FlxOverlapData other);
		Dynamic copyFrom_dyn();

};

} // end namespace flixel
} // end namespace overlap

#endif /* INCLUDED_flixel_overlap_FlxOverlapData */ 
