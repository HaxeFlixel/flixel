#ifndef INCLUDED_flixel_tweens_FlxTweenManager
#define INCLUDED_flixel_tweens_FlxTweenManager

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxBasic.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS2(flixel,tweens,FlxTween)
HX_DECLARE_CLASS2(flixel,tweens,FlxTweenManager)
HX_DECLARE_CLASS3(flixel,tweens,misc,AngleTween)
HX_DECLARE_CLASS3(flixel,tweens,misc,ColorTween)
HX_DECLARE_CLASS3(flixel,tweens,misc,NumTween)
HX_DECLARE_CLASS3(flixel,tweens,misc,VarTween)
HX_DECLARE_CLASS3(flixel,tweens,motion,CircularMotion)
HX_DECLARE_CLASS3(flixel,tweens,motion,CubicMotion)
HX_DECLARE_CLASS3(flixel,tweens,motion,LinearMotion)
HX_DECLARE_CLASS3(flixel,tweens,motion,LinearPath)
HX_DECLARE_CLASS3(flixel,tweens,motion,Motion)
HX_DECLARE_CLASS3(flixel,tweens,motion,QuadMotion)
HX_DECLARE_CLASS3(flixel,tweens,motion,QuadPath)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace tweens{


class HXCPP_CLASS_ATTRIBUTES  FlxTweenManager_obj : public ::flixel::FlxBasic_obj{
	public:
		typedef ::flixel::FlxBasic_obj super;
		typedef FlxTweenManager_obj OBJ_;
		FlxTweenManager_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTweenManager_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTweenManager_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTweenManager"); }

		virtual ::flixel::tweens::motion::QuadPath add_flixel_tweens_motion_QuadPath( ::flixel::tweens::motion::QuadPath Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_motion_QuadPath_dyn();

		virtual ::flixel::tweens::motion::LinearPath add_flixel_tweens_motion_LinearPath( ::flixel::tweens::motion::LinearPath Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_motion_LinearPath_dyn();

		virtual ::flixel::tweens::motion::CircularMotion add_flixel_tweens_motion_CircularMotion( ::flixel::tweens::motion::CircularMotion Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_motion_CircularMotion_dyn();

		virtual ::flixel::tweens::motion::CubicMotion add_flixel_tweens_motion_CubicMotion( ::flixel::tweens::motion::CubicMotion Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_motion_CubicMotion_dyn();

		virtual ::flixel::tweens::motion::QuadMotion add_flixel_tweens_motion_QuadMotion( ::flixel::tweens::motion::QuadMotion Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_motion_QuadMotion_dyn();

		virtual ::flixel::tweens::motion::LinearMotion add_flixel_tweens_motion_LinearMotion( ::flixel::tweens::motion::LinearMotion Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_motion_LinearMotion_dyn();

		virtual ::flixel::tweens::misc::ColorTween add_flixel_tweens_misc_ColorTween( ::flixel::tweens::misc::ColorTween Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_misc_ColorTween_dyn();

		virtual ::flixel::tweens::misc::AngleTween add_flixel_tweens_misc_AngleTween( ::flixel::tweens::misc::AngleTween Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_misc_AngleTween_dyn();

		virtual ::flixel::tweens::misc::NumTween add_flixel_tweens_misc_NumTween( ::flixel::tweens::misc::NumTween Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_misc_NumTween_dyn();

		virtual ::flixel::tweens::misc::VarTween add_flixel_tweens_misc_VarTween( ::flixel::tweens::misc::VarTween Tween,hx::Null< bool >  Start);
		Dynamic add_flixel_tweens_misc_VarTween_dyn();

		Array< ::Dynamic > _tweens;
		virtual Void destroy( );

		virtual Void update( Float elapsed);

		virtual ::flixel::tweens::FlxTween remove( ::flixel::tweens::FlxTween Tween);
		Dynamic remove_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

};

} // end namespace flixel
} // end namespace tweens

#endif /* INCLUDED_flixel_tweens_FlxTweenManager */ 
