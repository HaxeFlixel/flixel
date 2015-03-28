#ifndef INCLUDED_flixel_FlxGame
#define INCLUDED_flixel_FlxGame

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/Sprite.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxGame)
HX_DECLARE_CLASS1(flixel,FlxState)
HX_DECLARE_CLASS3(flixel,effects,postprocess,PostProcess)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS3(flixel,system,debug,FlxDebugger)
HX_DECLARE_CLASS3(flixel,system,ui,FlxFocusLostScreen)
HX_DECLARE_CLASS3(flixel,system,ui,FlxSoundTray)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,DirectRenderer)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,OpenGLView)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
namespace flixel{


class HXCPP_CLASS_ATTRIBUTES  FlxGame_obj : public ::openfl::_v2::display::Sprite_obj{
	public:
		typedef ::openfl::_v2::display::Sprite_obj super;
		typedef FlxGame_obj OBJ_;
		FlxGame_obj();
		Void __construct(hx::Null< int >  __o_GameSizeX,hx::Null< int >  __o_GameSizeY,::Class InitialState,hx::Null< Float >  __o_Zoom,hx::Null< int >  __o_UpdateFramerate,hx::Null< int >  __o_DrawFramerate,hx::Null< bool >  __o_SkipSplash,hx::Null< bool >  __o_StartFullscreen);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxGame_obj > __new(hx::Null< int >  __o_GameSizeX,hx::Null< int >  __o_GameSizeY,::Class InitialState,hx::Null< Float >  __o_Zoom,hx::Null< int >  __o_UpdateFramerate,hx::Null< int >  __o_DrawFramerate,hx::Null< bool >  __o_SkipSplash,hx::Null< bool >  __o_StartFullscreen);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxGame_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxGame"); }

		int focusLostFramerate;
		::flixel::system::ui::FlxSoundTray soundTray;
		::flixel::system::debug::FlxDebugger debugger;
		int ticks;
		bool _gameJustStarted;
		::Class _initialState;
		::flixel::FlxState _state;
		int _total;
		int _accumulator;
		int _elapsedMS;
		int _stepMS;
		Float _stepSeconds;
		int _maxAccumulation;
		bool _lostFocus;
		bool _onFocusFiredOnce;
		::flixel::system::ui::FlxFocusLostScreen _focusLostScreen;
		::openfl::_v2::display::Sprite _inputContainer;
		::Class _customSoundTray;
		::Class _customFocusLostScreen;
		bool _skipSplash;
		bool _startFullscreen;
		::flixel::FlxState _requestedState;
		bool _resetGame;
		::openfl::_v2::display::Sprite postProcessLayer;
		Array< ::Dynamic > postProcesses;
		virtual Void create( Dynamic _);
		Dynamic create_dyn();

		virtual Void onFocus( Dynamic _);
		Dynamic onFocus_dyn();

		virtual Void onFocusLost( Dynamic _);
		Dynamic onFocusLost_dyn();

		virtual Void onResize( Dynamic _);
		Dynamic onResize_dyn();

		virtual Void resizeGame( int width,int height);
		Dynamic resizeGame_dyn();

		virtual Void onEnterFrame( Dynamic _);
		Dynamic onEnterFrame_dyn();

		virtual Void resetGame( );
		Dynamic resetGame_dyn();

		virtual Void switchState( );
		Dynamic switchState_dyn();

		virtual Void gameStart( );
		Dynamic gameStart_dyn();

		virtual Void step( );
		Dynamic step_dyn();

		virtual Void update( );
		Dynamic update_dyn();

		virtual Void updateInput( );
		Dynamic updateInput_dyn();

		virtual Void draw( );
		Dynamic draw_dyn();

		Dynamic getTimer;
		inline Dynamic &getTimer_dyn() {return getTimer; }

};

} // end namespace flixel

#endif /* INCLUDED_flixel_FlxGame */ 
