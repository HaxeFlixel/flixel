#ifndef INCLUDED_flixel_animation_FlxAnimation
#define INCLUDED_flixel_animation_FlxAnimation

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/animation/FlxBaseAnimation.h>
HX_DECLARE_CLASS2(flixel,animation,FlxAnimation)
HX_DECLARE_CLASS2(flixel,animation,FlxAnimationController)
HX_DECLARE_CLASS2(flixel,animation,FlxBaseAnimation)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace animation{


class HXCPP_CLASS_ATTRIBUTES  FlxAnimation_obj : public ::flixel::animation::FlxBaseAnimation_obj{
	public:
		typedef ::flixel::animation::FlxBaseAnimation_obj super;
		typedef FlxAnimation_obj OBJ_;
		FlxAnimation_obj();
		Void __construct(::flixel::animation::FlxAnimationController Parent,::String Name,Array< int > Frames,hx::Null< int >  __o_FrameRate,hx::Null< bool >  __o_Looped);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxAnimation_obj > __new(::flixel::animation::FlxAnimationController Parent,::String Name,Array< int > Frames,hx::Null< int >  __o_FrameRate,hx::Null< bool >  __o_Looped);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxAnimation_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxAnimation"); }

		int frameRate;
		int curFrame;
		int numFrames;
		Float delay;
		bool finished;
		bool paused;
		bool looped;
		bool reversed;
		Array< int > _frames;
		Float _frameTimer;
		virtual Void destroy( );

		virtual Void play( hx::Null< bool >  Force,hx::Null< bool >  Reversed,hx::Null< int >  Frame);
		Dynamic play_dyn();

		virtual Void restart( );
		Dynamic restart_dyn();

		virtual Void stop( );
		Dynamic stop_dyn();

		virtual Void update( Float elapsed);

		virtual ::flixel::animation::FlxBaseAnimation clone( ::flixel::animation::FlxAnimationController Parent);

		virtual int set_frameRate( int value);
		Dynamic set_frameRate_dyn();

		virtual int set_curFrame( int Frame);
		Dynamic set_curFrame_dyn();

		virtual int get_numFrames( );
		Dynamic get_numFrames_dyn();

};

} // end namespace flixel
} // end namespace animation

#endif /* INCLUDED_flixel_animation_FlxAnimation */ 
