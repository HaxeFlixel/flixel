#ifndef INCLUDED_flixel_system_frontEnds_PluginFrontEnd
#define INCLUDED_flixel_system_frontEnds_PluginFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS3(flixel,system,frontEnds,PluginFrontEnd)
HX_DECLARE_CLASS2(flixel,tweens,FlxTweenManager)
HX_DECLARE_CLASS2(flixel,util,FlxPathManager)
HX_DECLARE_CLASS2(flixel,util,FlxTimerManager)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  PluginFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef PluginFrontEnd_obj OBJ_;
		PluginFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< PluginFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~PluginFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("PluginFrontEnd"); }

		virtual ::flixel::tweens::FlxTweenManager add_flixel_tweens_FlxTweenManager( ::flixel::tweens::FlxTweenManager Plugin);
		Dynamic add_flixel_tweens_FlxTweenManager_dyn();

		virtual ::flixel::util::FlxTimerManager add_flixel_util_FlxTimerManager( ::flixel::util::FlxTimerManager Plugin);
		Dynamic add_flixel_util_FlxTimerManager_dyn();

		virtual ::flixel::util::FlxPathManager add_flixel_util_FlxPathManager( ::flixel::util::FlxPathManager Plugin);
		Dynamic add_flixel_util_FlxPathManager_dyn();

		Array< ::Dynamic > list;
		virtual ::flixel::FlxBasic get( ::Class ClassType);
		Dynamic get_dyn();

		virtual ::flixel::FlxBasic remove( ::flixel::FlxBasic Plugin);
		Dynamic remove_dyn();

		virtual bool removeType( ::Class ClassType);
		Dynamic removeType_dyn();

		virtual Void update( Float elapsed);
		Dynamic update_dyn();

		virtual Void draw( );
		Dynamic draw_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_PluginFrontEnd */ 
