#ifndef INCLUDED_openfl_events_UncaughtErrorEvent
#define INCLUDED_openfl_events_UncaughtErrorEvent

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/events/ErrorEvent.h>
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS2(openfl,events,ErrorEvent)
HX_DECLARE_CLASS2(openfl,events,TextEvent)
HX_DECLARE_CLASS2(openfl,events,UncaughtErrorEvent)
namespace openfl{
namespace events{


class HXCPP_CLASS_ATTRIBUTES  UncaughtErrorEvent_obj : public ::openfl::events::ErrorEvent_obj{
	public:
		typedef ::openfl::events::ErrorEvent_obj super;
		typedef UncaughtErrorEvent_obj OBJ_;
		UncaughtErrorEvent_obj();
		Void __construct(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable,Dynamic error);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< UncaughtErrorEvent_obj > __new(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable,Dynamic error);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~UncaughtErrorEvent_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("UncaughtErrorEvent"); }

		Dynamic error;
		virtual ::openfl::_v2::events::Event clone( );

		virtual ::String toString( );

		static ::String UNCAUGHT_ERROR;
};

} // end namespace openfl
} // end namespace events

#endif /* INCLUDED_openfl_events_UncaughtErrorEvent */ 
