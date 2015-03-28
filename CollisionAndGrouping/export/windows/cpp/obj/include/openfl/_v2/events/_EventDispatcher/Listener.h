#ifndef INCLUDED_openfl__v2_events__EventDispatcher_Listener
#define INCLUDED_openfl__v2_events__EventDispatcher_Listener

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS4(openfl,_v2,events,_EventDispatcher,Listener)
namespace openfl{
namespace _v2{
namespace events{
namespace _EventDispatcher{


class HXCPP_CLASS_ATTRIBUTES  Listener_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Listener_obj OBJ_;
		Listener_obj();
		Void __construct(Dynamic callback,bool useCapture,int priority);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Listener_obj > __new(Dynamic callback,bool useCapture,int priority);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Listener_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Listener"); }

		Dynamic callback;
		Dynamic &callback_dyn() { return callback;}
		int priority;
		bool useCapture;
		virtual bool match( Dynamic callback,bool useCapture);
		Dynamic match_dyn();

};

} // end namespace openfl
} // end namespace _v2
} // end namespace events
} // end namespace _EventDispatcher

#endif /* INCLUDED_openfl__v2_events__EventDispatcher_Listener */ 
