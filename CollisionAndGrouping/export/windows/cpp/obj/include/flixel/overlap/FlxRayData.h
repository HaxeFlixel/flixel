#ifndef INCLUDED_flixel_overlap_FlxRayData
#define INCLUDED_flixel_overlap_FlxRayData

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,overlap,FlxRay)
HX_DECLARE_CLASS2(flixel,overlap,FlxRayData)
HX_DECLARE_CLASS2(flixel,overlap,IFlxHitbox)
namespace flixel{
namespace overlap{


class HXCPP_CLASS_ATTRIBUTES  FlxRayData_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxRayData_obj OBJ_;
		FlxRayData_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxRayData_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxRayData_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxRayData"); }

		::flixel::overlap::IFlxHitbox hitbox;
		::flixel::overlap::FlxRay ray;
		Float start;
		Float end;
};

} // end namespace flixel
} // end namespace overlap

#endif /* INCLUDED_flixel_overlap_FlxRayData */ 
