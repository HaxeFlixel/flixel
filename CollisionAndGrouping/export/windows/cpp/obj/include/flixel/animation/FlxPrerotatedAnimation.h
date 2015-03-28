#ifndef INCLUDED_flixel_animation_FlxPrerotatedAnimation
#define INCLUDED_flixel_animation_FlxPrerotatedAnimation

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/animation/FlxBaseAnimation.h>
HX_DECLARE_CLASS2(flixel,animation,FlxAnimationController)
HX_DECLARE_CLASS2(flixel,animation,FlxBaseAnimation)
HX_DECLARE_CLASS2(flixel,animation,FlxPrerotatedAnimation)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace animation{


class HXCPP_CLASS_ATTRIBUTES  FlxPrerotatedAnimation_obj : public ::flixel::animation::FlxBaseAnimation_obj{
	public:
		typedef ::flixel::animation::FlxBaseAnimation_obj super;
		typedef FlxPrerotatedAnimation_obj OBJ_;
		FlxPrerotatedAnimation_obj();
		Void __construct(::flixel::animation::FlxAnimationController Parent,Float Baked);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxPrerotatedAnimation_obj > __new(::flixel::animation::FlxAnimationController Parent,Float Baked);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxPrerotatedAnimation_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxPrerotatedAnimation"); }

		int rotations;
		Float baked;
		Float angle;
		virtual Float set_angle( Float Value);
		Dynamic set_angle_dyn();

		virtual int set_curIndex( int Value);

		virtual ::flixel::animation::FlxBaseAnimation clone( ::flixel::animation::FlxAnimationController Parent);

		static ::String PREROTATED;
};

} // end namespace flixel
} // end namespace animation

#endif /* INCLUDED_flixel_animation_FlxPrerotatedAnimation */ 
