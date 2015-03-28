#ifndef INCLUDED_openfl_events_UncaughtErrorEvents
#define INCLUDED_openfl_events_UncaughtErrorEvents

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/events/EventDispatcher.h>
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS2(openfl,events,UncaughtErrorEvents)
namespace openfl{
namespace events{


class HXCPP_CLASS_ATTRIBUTES  UncaughtErrorEvents_obj : public ::openfl::_v2::events::EventDispatcher_obj{
	public:
		typedef ::openfl::_v2::events::EventDispatcher_obj super;
		typedef UncaughtErrorEvents_obj OBJ_;
		UncaughtErrorEvents_obj();
		Void __construct(::openfl::_v2::events::IEventDispatcher target);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< UncaughtErrorEvents_obj > __new(::openfl::_v2::events::IEventDispatcher target);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~UncaughtErrorEvents_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("UncaughtErrorEvents"); }

};

} // end namespace openfl
} // end namespace events

#endif /* INCLUDED_openfl_events_UncaughtErrorEvents */ 
