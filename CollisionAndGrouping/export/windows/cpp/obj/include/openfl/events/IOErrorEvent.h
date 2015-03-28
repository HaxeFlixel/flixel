#ifndef INCLUDED_openfl_events_IOErrorEvent
#define INCLUDED_openfl_events_IOErrorEvent

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/events/ErrorEvent.h>
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS2(openfl,events,ErrorEvent)
HX_DECLARE_CLASS2(openfl,events,IOErrorEvent)
HX_DECLARE_CLASS2(openfl,events,TextEvent)
namespace openfl{
namespace events{


class HXCPP_CLASS_ATTRIBUTES  IOErrorEvent_obj : public ::openfl::events::ErrorEvent_obj{
	public:
		typedef ::openfl::events::ErrorEvent_obj super;
		typedef IOErrorEvent_obj OBJ_;
		IOErrorEvent_obj();
		Void __construct(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable,::String __o_text,hx::Null< int >  __o_id);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< IOErrorEvent_obj > __new(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable,::String __o_text,hx::Null< int >  __o_id);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~IOErrorEvent_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("IOErrorEvent"); }

		virtual ::openfl::_v2::events::Event clone( );

		virtual ::String toString( );

		static ::String IO_ERROR;
};

} // end namespace openfl
} // end namespace events

#endif /* INCLUDED_openfl_events_IOErrorEvent */ 
