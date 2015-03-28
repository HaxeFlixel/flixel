#ifndef INCLUDED_openfl_events_EventPhase
#define INCLUDED_openfl_events_EventPhase

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,events,EventPhase)
namespace openfl{
namespace events{


class EventPhase_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef EventPhase_obj OBJ_;

	public:
		EventPhase_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.events.EventPhase"); }
		::String __ToString() const { return HX_CSTRING("EventPhase.") + tag; }

		static ::openfl::events::EventPhase AT_TARGET;
		static inline ::openfl::events::EventPhase AT_TARGET_dyn() { return AT_TARGET; }
		static ::openfl::events::EventPhase BUBBLING_PHASE;
		static inline ::openfl::events::EventPhase BUBBLING_PHASE_dyn() { return BUBBLING_PHASE; }
		static ::openfl::events::EventPhase CAPTURING_PHASE;
		static inline ::openfl::events::EventPhase CAPTURING_PHASE_dyn() { return CAPTURING_PHASE; }
};

} // end namespace openfl
} // end namespace events

#endif /* INCLUDED_openfl_events_EventPhase */ 
