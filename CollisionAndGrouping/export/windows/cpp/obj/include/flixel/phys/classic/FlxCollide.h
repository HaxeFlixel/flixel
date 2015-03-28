#ifndef INCLUDED_flixel_phys_classic_FlxCollide
#define INCLUDED_flixel_phys_classic_FlxCollide

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxClassicBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxCollide)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace phys{
namespace classic{


class HXCPP_CLASS_ATTRIBUTES  FlxCollide_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxCollide_obj OBJ_;
		FlxCollide_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxCollide_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxCollide_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxCollide"); }

		static Void collide( Array< ::Dynamic > array,int iterationNumber);
		static Dynamic collide_dyn();

		static Float SEPARATE_BIAS;
		static int LEFT;
		static int RIGHT;
		static int UP;
		static int DOWN;
		static int NONE;
		static int CEILING;
		static int FLOOR;
		static int WALL;
		static int ANY;
		static ::flixel::math::FlxRect _firstSeparateFlxRect;
		static ::flixel::math::FlxRect _secondSeparateFlxRect;
		static bool separate( ::flixel::phys::classic::FlxClassicBody Object1,::flixel::phys::classic::FlxClassicBody Object2);
		static Dynamic separate_dyn();

		static bool separateX( ::flixel::phys::classic::FlxClassicBody Object1,::flixel::phys::classic::FlxClassicBody Object2);
		static Dynamic separateX_dyn();

		static bool separateY( ::flixel::phys::classic::FlxClassicBody Object1,::flixel::phys::classic::FlxClassicBody Object2);
		static Dynamic separateY_dyn();

};

} // end namespace flixel
} // end namespace phys
} // end namespace classic

#endif /* INCLUDED_flixel_phys_classic_FlxCollide */ 
