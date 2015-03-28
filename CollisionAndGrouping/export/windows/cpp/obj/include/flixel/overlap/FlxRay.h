#ifndef INCLUDED_flixel_overlap_FlxRay
#define INCLUDED_flixel_overlap_FlxRay

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxVector)
HX_DECLARE_CLASS2(flixel,overlap,FlxRay)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace overlap{


class HXCPP_CLASS_ATTRIBUTES  FlxRay_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxRay_obj OBJ_;
		FlxRay_obj();
		Void __construct(::flixel::math::FlxVector Start,::flixel::math::FlxVector End,bool IsInfinite);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxRay_obj > __new(::flixel::math::FlxVector Start,::flixel::math::FlxVector End,bool IsInfinite);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxRay_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxRay"); }

		::flixel::math::FlxVector start;
		::flixel::math::FlxVector end;
		bool isInfinite;
};

} // end namespace flixel
} // end namespace overlap

#endif /* INCLUDED_flixel_overlap_FlxRay */ 
