#ifndef INCLUDED_flixel_system_frontEnds_SignalFrontEnd
#define INCLUDED_flixel_system_frontEnds_SignalFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,frontEnds,SignalFrontEnd)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxSignal)
HX_DECLARE_CLASS3(flixel,util,_FlxSignal,FlxBaseSignal)
HX_DECLARE_CLASS3(flixel,util,_FlxSignal,FlxSignal0)
HX_DECLARE_CLASS3(flixel,util,_FlxSignal,FlxSignal2)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  SignalFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef SignalFrontEnd_obj OBJ_;
		SignalFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< SignalFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~SignalFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("SignalFrontEnd"); }

		::flixel::util::_FlxSignal::FlxSignal0 stateSwitched;
		::flixel::util::_FlxSignal::FlxSignal2 gameResized;
		::flixel::util::_FlxSignal::FlxSignal0 preGameReset;
		::flixel::util::_FlxSignal::FlxSignal0 postGameReset;
		::flixel::util::_FlxSignal::FlxSignal0 gameStarted;
		::flixel::util::_FlxSignal::FlxSignal0 preUpdate;
		::flixel::util::_FlxSignal::FlxSignal0 postUpdate;
		::flixel::util::_FlxSignal::FlxSignal0 preDraw;
		::flixel::util::_FlxSignal::FlxSignal0 postDraw;
		::flixel::util::_FlxSignal::FlxSignal0 focusGained;
		::flixel::util::_FlxSignal::FlxSignal0 focusLost;
};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_SignalFrontEnd */ 
