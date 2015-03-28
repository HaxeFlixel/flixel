#ifndef INCLUDED_openfl_events_SampleDataEvent
#define INCLUDED_openfl_events_SampleDataEvent

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/events/Event.h>
HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
HX_DECLARE_CLASS2(openfl,events,SampleDataEvent)
namespace openfl{
namespace events{


class HXCPP_CLASS_ATTRIBUTES  SampleDataEvent_obj : public ::openfl::_v2::events::Event_obj{
	public:
		typedef ::openfl::_v2::events::Event_obj super;
		typedef SampleDataEvent_obj OBJ_;
		SampleDataEvent_obj();
		Void __construct(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< SampleDataEvent_obj > __new(::String type,hx::Null< bool >  __o_bubbles,hx::Null< bool >  __o_cancelable);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~SampleDataEvent_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("SampleDataEvent"); }

		::openfl::_v2::utils::ByteArray data;
		Float position;
		virtual ::openfl::_v2::events::Event clone( );

		virtual ::String toString( );

		static ::String SAMPLE_DATA;
};

} // end namespace openfl
} // end namespace events

#endif /* INCLUDED_openfl_events_SampleDataEvent */ 
