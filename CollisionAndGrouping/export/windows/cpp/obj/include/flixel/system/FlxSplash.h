#ifndef INCLUDED_flixel_system_FlxSplash
#define INCLUDED_flixel_system_FlxSplash

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxState.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxState)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,system,FlxSplash)
HX_DECLARE_CLASS2(flixel,tweens,FlxTween)
HX_DECLARE_CLASS2(flixel,util,FlxTimer)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,Graphics)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,text,TextField)
namespace flixel{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  FlxSplash_obj : public ::flixel::FlxState_obj{
	public:
		typedef ::flixel::FlxState_obj super;
		typedef FlxSplash_obj OBJ_;
		FlxSplash_obj();
		Void __construct(Dynamic MaxSize);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxSplash_obj > __new(Dynamic MaxSize);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxSplash_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxSplash"); }

		::openfl::_v2::display::Sprite _sprite;
		::openfl::_v2::display::Graphics _gfx;
		::openfl::_v2::text::TextField _text;
		Array< Float > _times;
		Array< int > _colors;
		Dynamic _functions;
		int _curPart;
		int _cachedBgColor;
		bool _cachedTimestep;
		bool _cachedAutoPause;
		virtual Void create( );

		virtual Void destroy( );

		virtual Void onResize( int Width,int Height);

		virtual Void timerCallback( ::flixel::util::FlxTimer Timer);
		Dynamic timerCallback_dyn();

		virtual Void drawGreen( );
		Dynamic drawGreen_dyn();

		virtual Void drawYellow( );
		Dynamic drawYellow_dyn();

		virtual Void drawRed( );
		Dynamic drawRed_dyn();

		virtual Void drawBlue( );
		Dynamic drawBlue_dyn();

		virtual Void drawLightBlue( );
		Dynamic drawLightBlue_dyn();

		virtual Void onComplete( ::flixel::tweens::FlxTween Tween);
		Dynamic onComplete_dyn();

		static ::Class nextState;
};

} // end namespace flixel
} // end namespace system

#endif /* INCLUDED_flixel_system_FlxSplash */ 
