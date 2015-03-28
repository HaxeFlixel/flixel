#ifndef INCLUDED_openfl_display_FrameLabel
#define INCLUDED_openfl_display_FrameLabel

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/events/EventDispatcher.h>
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS2(openfl,display,FrameLabel)
namespace openfl{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  FrameLabel_obj : public ::openfl::_v2::events::EventDispatcher_obj{
	public:
		typedef ::openfl::_v2::events::EventDispatcher_obj super;
		typedef FrameLabel_obj OBJ_;
		FrameLabel_obj();
		Void __construct(::String name,int frame);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FrameLabel_obj > __new(::String name,int frame);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FrameLabel_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FrameLabel"); }

		int frame;
		::String name;
		int __frame;
		::String __name;
		virtual int get_frame( );
		Dynamic get_frame_dyn();

		virtual ::String get_name( );
		Dynamic get_name_dyn();

};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_FrameLabel */ 
