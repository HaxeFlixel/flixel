#ifndef INCLUDED_flixel_util_FlxTimer
#define INCLUDED_flixel_util_FlxTimer

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS2(flixel,util,FlxTimer)
HX_DECLARE_CLASS2(flixel,util,FlxTimerManager)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  FlxTimer_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxTimer_obj OBJ_;
		FlxTimer_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTimer_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTimer_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxTimer_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxTimer"); }

		Float time;
		int loops;
		bool active;
		bool finished;
		Dynamic onComplete;
		Dynamic &onComplete_dyn() { return onComplete;}
		Float _timeCounter;
		int _loopsCounter;
		bool _inManager;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual ::flixel::util::FlxTimer start( hx::Null< Float >  Time,Dynamic OnComplete,hx::Null< int >  Loops);
		Dynamic start_dyn();

		virtual ::flixel::util::FlxTimer reset( hx::Null< Float >  NewTime);
		Dynamic reset_dyn();

		virtual Void cancel( );
		Dynamic cancel_dyn();

		virtual Void update( Float elapsed);
		Dynamic update_dyn();

		virtual Float get_timeLeft( );
		Dynamic get_timeLeft_dyn();

		virtual Float get_elapsedTime( );
		Dynamic get_elapsedTime_dyn();

		virtual int get_loopsLeft( );
		Dynamic get_loopsLeft_dyn();

		virtual int get_elapsedLoops( );
		Dynamic get_elapsedLoops_dyn();

		virtual Float get_progress( );
		Dynamic get_progress_dyn();

		static ::flixel::util::FlxTimerManager manager;
};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_FlxTimer */ 
