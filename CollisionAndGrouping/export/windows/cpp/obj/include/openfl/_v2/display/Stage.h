#ifndef INCLUDED_openfl__v2_display_Stage
#define INCLUDED_openfl__v2_display_Stage

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/DisplayObjectContainer.h>
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS2(haxe,ds,IntMap)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,display,Sprite)
HX_DECLARE_CLASS3(openfl,_v2,display,Stage)
HX_DECLARE_CLASS3(openfl,_v2,display,StageQuality)
HX_DECLARE_CLASS3(openfl,_v2,display,TouchInfo)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,MouseEvent)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
HX_DECLARE_CLASS3(openfl,_v2,system,ScreenMode)
HX_DECLARE_CLASS2(openfl,display,Stage3D)
HX_DECLARE_CLASS2(openfl,display,StageAlign)
HX_DECLARE_CLASS2(openfl,display,StageDisplayState)
HX_DECLARE_CLASS2(openfl,display,StageScaleMode)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  Stage_obj : public ::openfl::_v2::display::DisplayObjectContainer_obj{
	public:
		typedef ::openfl::_v2::display::DisplayObjectContainer_obj super;
		typedef Stage_obj OBJ_;
		Stage_obj();
		Void __construct(Dynamic handle,int width,int height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Stage_obj > __new(Dynamic handle,int width,int height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Stage_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Stage"); }

		bool allowsFullScreen;
		bool active;
		Float dpiScale;
		Float frameRate;
		bool isOpenGL;
		Dynamic onKey;
		Dynamic &onKey_dyn() { return onKey;}
		Dynamic onQuit;
		Dynamic &onQuit_dyn() { return onQuit;}
		bool pauseWhenDeactivated;
		Dynamic renderRequest;
		Dynamic &renderRequest_dyn() { return renderRequest;}
		Array< ::Dynamic > stage3Ds;
		int stageHeight;
		int stageWidth;
		::haxe::ds::IntMap __joyAxisData;
		::openfl::_v2::geom::Rectangle __dragBounds;
		::openfl::_v2::display::Sprite __dragObject;
		Float __dragOffsetX;
		Float __dragOffsetY;
		Array< ::Dynamic > __focusOverObjects;
		Float __framePeriod;
		bool __invalid;
		int __lastClickTime;
		Array< ::Dynamic > __lastDown;
		Float __lastRender;
		Array< ::Dynamic > __mouseOverObjects;
		Float __nextRender;
		::haxe::ds::IntMap __touchInfo;
		virtual Void invalidate( );
		Dynamic invalidate_dyn();

		virtual Void resize( int width,int height);
		Dynamic resize_dyn();

		virtual Void setResolution( int width,int height);
		Dynamic setResolution_dyn();

		virtual Void setScreenMode( ::openfl::_v2::system::ScreenMode mode);
		Dynamic setScreenMode_dyn();

		virtual Void setFullscreen( bool full);
		Dynamic setFullscreen_dyn();

		virtual Void showCursor( bool show);
		Dynamic showCursor_dyn();

		virtual Void __checkFocusInOuts( Dynamic event,Array< ::Dynamic > stack);
		Dynamic __checkFocusInOuts_dyn();

		virtual bool __checkInOuts( ::openfl::_v2::events::MouseEvent event,Array< ::Dynamic > stack,::openfl::_v2::display::TouchInfo touchInfo);
		Dynamic __checkInOuts_dyn();

		virtual Void __checkRender( );
		Dynamic __checkRender_dyn();

		virtual Float __doProcessStageEvent( Dynamic event);
		Dynamic __doProcessStageEvent_dyn();

		virtual Dynamic __processStageEvent( Dynamic event);
		Dynamic __processStageEvent_dyn();

		virtual Void __drag( ::openfl::_v2::geom::Point mouse);
		Dynamic __drag_dyn();

		virtual Float __nextFrameDue( Float otherTimers);
		Dynamic __nextFrameDue_dyn();

		virtual Void __onChange( Dynamic event);
		Dynamic __onChange_dyn();

		virtual Void __onFocus( Dynamic event);
		Dynamic __onFocus_dyn();

		virtual Void __onJoystick( Dynamic event,::String type);
		Dynamic __onJoystick_dyn();

		virtual Void __onKey( Dynamic event,::String type);
		Dynamic __onKey_dyn();

		virtual Void __onMouse( Dynamic event,::String type,bool fromMouse);
		Dynamic __onMouse_dyn();

		virtual Void __onRenderContext( bool active);
		Dynamic __onRenderContext_dyn();

		virtual Void __onResize( Float width,Float height);
		Dynamic __onResize_dyn();

		virtual Void __onSysWM( Dynamic event);
		Dynamic __onSysWM_dyn();

		virtual Void __onTouch( Dynamic event,::String type,::openfl::_v2::display::TouchInfo touchInfo);
		Dynamic __onTouch_dyn();

		virtual Void __pollTimers( );
		Dynamic __pollTimers_dyn();

		virtual Void __render( bool sendEnterFrame);
		Dynamic __render_dyn();

		virtual Void __setActive( bool value);
		Dynamic __setActive_dyn();

		virtual Void __startDrag( ::openfl::_v2::display::Sprite sprite,bool lockCenter,::openfl::_v2::geom::Rectangle bounds);
		Dynamic __startDrag_dyn();

		virtual Void __stopDrag( ::openfl::_v2::display::Sprite sprite);
		Dynamic __stopDrag_dyn();

		virtual Float __updateNextWake( );
		Dynamic __updateNextWake_dyn();

		virtual ::openfl::display::StageAlign get_align( );
		Dynamic get_align_dyn();

		virtual ::openfl::display::StageAlign set_align( ::openfl::display::StageAlign value);
		Dynamic set_align_dyn();

		virtual int get_color( );
		Dynamic get_color_dyn();

		virtual int set_color( int value);
		Dynamic set_color_dyn();

		virtual ::openfl::display::StageDisplayState get_displayState( );
		Dynamic get_displayState_dyn();

		virtual ::openfl::display::StageDisplayState set_displayState( ::openfl::display::StageDisplayState value);
		Dynamic set_displayState_dyn();

		virtual Float get_dpiScale( );
		Dynamic get_dpiScale_dyn();

		virtual ::openfl::_v2::display::InteractiveObject get_focus( );
		Dynamic get_focus_dyn();

		virtual ::openfl::_v2::display::InteractiveObject set_focus( ::openfl::_v2::display::InteractiveObject value);
		Dynamic set_focus_dyn();

		virtual Float set_frameRate( Float value);
		Dynamic set_frameRate_dyn();

		virtual bool get_isOpenGL( );
		Dynamic get_isOpenGL_dyn();

		virtual ::openfl::_v2::display::StageQuality get_quality( );
		Dynamic get_quality_dyn();

		virtual ::openfl::_v2::display::StageQuality set_quality( ::openfl::_v2::display::StageQuality value);
		Dynamic set_quality_dyn();

		virtual ::openfl::display::StageScaleMode get_scaleMode( );
		Dynamic get_scaleMode_dyn();

		virtual ::openfl::display::StageScaleMode set_scaleMode( ::openfl::display::StageScaleMode value);
		Dynamic set_scaleMode_dyn();

		virtual ::openfl::_v2::display::Stage get_stage( );

		virtual bool get_stageFocusRect( );
		Dynamic get_stageFocusRect_dyn();

		virtual bool set_stageFocusRect( bool value);
		Dynamic set_stageFocusRect_dyn();

		virtual bool get_autos3d( );
		Dynamic get_autos3d_dyn();

		virtual bool set_autos3d( bool value);
		Dynamic set_autos3d_dyn();

		virtual int get_stageHeight( );
		Dynamic get_stageHeight_dyn();

		virtual int get_stageWidth( );
		Dynamic get_stageWidth_dyn();

		static Float __earlyWakeup;
		static bool __exiting;
		static int OrientationPortrait;
		static int OrientationPortraitUpsideDown;
		static int OrientationLandscapeRight;
		static int OrientationLandscapeLeft;
		static int OrientationFaceUp;
		static int OrientationFaceDown;
		static int OrientationPortraitAny;
		static int OrientationLandscapeAny;
		static int OrientationAny;
		static int efLeftDown;
		static int efShiftDown;
		static int efCtrlDown;
		static int efAltDown;
		static int efCommandDown;
		static int efLocationRight;
		static int efNoNativeClick;
		static Array< ::String > sClickEvents;
		static Array< ::String > sDownEvents;
		static Array< ::String > sUpEvents;
		static Array< ::String > __mouseChanges;
		static Array< ::String > __touchChanges;
		static Dynamic getOrientation;
		static inline Dynamic &getOrientation_dyn() {return getOrientation; }

		static Dynamic getNormalOrientation;
		static inline Dynamic &getNormalOrientation_dyn() {return getNormalOrientation; }

		static Void setFixedOrientation( int orientation);
		static Dynamic setFixedOrientation_dyn();

		static Dynamic shouldRotateInterface;
		static inline Dynamic &shouldRotateInterface_dyn() {return shouldRotateInterface; }

		static Dynamic lime_set_stage_handler;
		static Dynamic &lime_set_stage_handler_dyn() { return lime_set_stage_handler;}
		static Dynamic lime_render_stage;
		static Dynamic &lime_render_stage_dyn() { return lime_render_stage;}
		static Dynamic lime_stage_get_autos3d;
		static Dynamic &lime_stage_get_autos3d_dyn() { return lime_stage_get_autos3d;}
		static Dynamic lime_stage_set_autos3d;
		static Dynamic &lime_stage_set_autos3d_dyn() { return lime_stage_set_autos3d;}
		static Dynamic lime_stage_get_focus_id;
		static Dynamic &lime_stage_get_focus_id_dyn() { return lime_stage_get_focus_id;}
		static Dynamic lime_stage_set_focus;
		static Dynamic &lime_stage_set_focus_dyn() { return lime_stage_set_focus;}
		static Dynamic lime_stage_get_focus_rect;
		static Dynamic &lime_stage_get_focus_rect_dyn() { return lime_stage_get_focus_rect;}
		static Dynamic lime_stage_set_focus_rect;
		static Dynamic &lime_stage_set_focus_rect_dyn() { return lime_stage_set_focus_rect;}
		static Dynamic lime_stage_is_opengl;
		static Dynamic &lime_stage_is_opengl_dyn() { return lime_stage_is_opengl;}
		static Dynamic lime_stage_get_stage_width;
		static Dynamic &lime_stage_get_stage_width_dyn() { return lime_stage_get_stage_width;}
		static Dynamic lime_stage_get_stage_height;
		static Dynamic &lime_stage_get_stage_height_dyn() { return lime_stage_get_stage_height;}
		static Dynamic lime_stage_get_dpi_scale;
		static Dynamic &lime_stage_get_dpi_scale_dyn() { return lime_stage_get_dpi_scale;}
		static Dynamic lime_stage_get_scale_mode;
		static Dynamic &lime_stage_get_scale_mode_dyn() { return lime_stage_get_scale_mode;}
		static Dynamic lime_stage_set_scale_mode;
		static Dynamic &lime_stage_set_scale_mode_dyn() { return lime_stage_set_scale_mode;}
		static Dynamic lime_stage_get_align;
		static Dynamic &lime_stage_get_align_dyn() { return lime_stage_get_align;}
		static Dynamic lime_stage_set_align;
		static Dynamic &lime_stage_set_align_dyn() { return lime_stage_set_align;}
		static Dynamic lime_stage_get_quality;
		static Dynamic &lime_stage_get_quality_dyn() { return lime_stage_get_quality;}
		static Dynamic lime_stage_set_quality;
		static Dynamic &lime_stage_set_quality_dyn() { return lime_stage_set_quality;}
		static Dynamic lime_stage_get_display_state;
		static Dynamic &lime_stage_get_display_state_dyn() { return lime_stage_get_display_state;}
		static Dynamic lime_stage_set_display_state;
		static Dynamic &lime_stage_set_display_state_dyn() { return lime_stage_set_display_state;}
		static Dynamic lime_stage_set_next_wake;
		static Dynamic &lime_stage_set_next_wake_dyn() { return lime_stage_set_next_wake;}
		static Dynamic lime_stage_request_render;
		static Dynamic lime_stage_resize_window;
		static Dynamic &lime_stage_resize_window_dyn() { return lime_stage_resize_window;}
		static Dynamic lime_stage_set_resolution;
		static Dynamic &lime_stage_set_resolution_dyn() { return lime_stage_set_resolution;}
		static Dynamic lime_stage_set_screenmode;
		static Dynamic &lime_stage_set_screenmode_dyn() { return lime_stage_set_screenmode;}
		static Dynamic lime_stage_set_fullscreen;
		static Dynamic &lime_stage_set_fullscreen_dyn() { return lime_stage_set_fullscreen;}
		static Dynamic lime_stage_show_cursor;
		static Dynamic &lime_stage_show_cursor_dyn() { return lime_stage_show_cursor;}
		static Dynamic lime_stage_set_fixed_orientation;
		static Dynamic &lime_stage_set_fixed_orientation_dyn() { return lime_stage_set_fixed_orientation;}
		static Dynamic lime_stage_get_orientation;
		static Dynamic &lime_stage_get_orientation_dyn() { return lime_stage_get_orientation;}
		static Dynamic lime_stage_get_normal_orientation;
		static Dynamic &lime_stage_get_normal_orientation_dyn() { return lime_stage_get_normal_orientation;}
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_Stage */ 
