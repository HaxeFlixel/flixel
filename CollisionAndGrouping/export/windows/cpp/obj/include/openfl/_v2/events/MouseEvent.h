#ifndef INCLUDED_openfl__v2_events_MouseEvent
#define INCLUDED_openfl__v2_events_MouseEvent

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/events/Event.h>
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,MouseEvent)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
namespace openfl{
namespace _v2{
namespace events{


class HXCPP_CLASS_ATTRIBUTES  MouseEvent_obj : public ::openfl::_v2::events::Event_obj{
	public:
		typedef ::openfl::_v2::events::Event_obj super;
		typedef MouseEvent_obj OBJ_;
		MouseEvent_obj();
		Void __construct(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable,hx::Null< Float >  __o_localX,hx::Null< Float >  __o_localY,::openfl::_v2::display::InteractiveObject relatedObject,hx::Null< bool >  __o_ctrlKey,hx::Null< bool >  __o_altKey,hx::Null< bool >  __o_shiftKey,hx::Null< bool >  __o_buttonDown,hx::Null< int >  __o_delta,hx::Null< bool >  __o_commandKey,hx::Null< int >  __o_clickCount);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< MouseEvent_obj > __new(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable,hx::Null< Float >  __o_localX,hx::Null< Float >  __o_localY,::openfl::_v2::display::InteractiveObject relatedObject,hx::Null< bool >  __o_ctrlKey,hx::Null< bool >  __o_altKey,hx::Null< bool >  __o_shiftKey,hx::Null< bool >  __o_buttonDown,hx::Null< int >  __o_delta,hx::Null< bool >  __o_commandKey,hx::Null< int >  __o_clickCount);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~MouseEvent_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("MouseEvent"); }

		bool altKey;
		bool buttonDown;
		int clickCount;
		bool commandKey;
		bool ctrlKey;
		int delta;
		Float localX;
		Float localY;
		::openfl::_v2::display::InteractiveObject relatedObject;
		bool shiftKey;
		Float stageX;
		Float stageY;
		virtual ::openfl::_v2::events::Event clone( );

		virtual ::String toString( );

		virtual Void updateAfterEvent( );
		Dynamic updateAfterEvent_dyn();

		virtual ::openfl::_v2::events::MouseEvent __createSimilar( ::String type,::openfl::_v2::display::InteractiveObject related,::openfl::_v2::display::InteractiveObject target);
		Dynamic __createSimilar_dyn();

		static ::String DOUBLE_CLICK;
		static ::String CLICK;
		static ::String MIDDLE_CLICK;
		static ::String MIDDLE_MOUSE_DOWN;
		static ::String MIDDLE_MOUSE_UP;
		static ::String MOUSE_DOWN;
		static ::String MOUSE_MOVE;
		static ::String MOUSE_OUT;
		static ::String MOUSE_OVER;
		static ::String MOUSE_UP;
		static ::String MOUSE_WHEEL;
		static ::String RIGHT_CLICK;
		static ::String RIGHT_MOUSE_DOWN;
		static ::String RIGHT_MOUSE_UP;
		static ::String ROLL_OUT;
		static ::String ROLL_OVER;
		static int efLeftDown;
		static int efShiftDown;
		static int efCtrlDown;
		static int efAltDown;
		static int efCommandDown;
		static ::openfl::_v2::events::MouseEvent __create( ::String type,Dynamic event,::openfl::_v2::geom::Point local,::openfl::_v2::display::InteractiveObject target);
		static Dynamic __create_dyn();

};

} // end namespace openfl
} // end namespace _v2
} // end namespace events

#endif /* INCLUDED_openfl__v2_events_MouseEvent */ 
