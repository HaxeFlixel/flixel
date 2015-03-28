#ifndef INCLUDED___ASSET__assets_sounds_flixel_ogg
#define INCLUDED___ASSET__assets_sounds_flixel_ogg

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/media/Sound.h>
HX_DECLARE_CLASS0(__ASSET__assets_sounds_flixel_ogg)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,media,Sound)
HX_DECLARE_CLASS3(openfl,_v2,net,URLRequest)
HX_DECLARE_CLASS2(openfl,media,SoundLoaderContext)


class HXCPP_CLASS_ATTRIBUTES  __ASSET__assets_sounds_flixel_ogg_obj : public ::openfl::_v2::media::Sound_obj{
	public:
		typedef ::openfl::_v2::media::Sound_obj super;
		typedef __ASSET__assets_sounds_flixel_ogg_obj OBJ_;
		__ASSET__assets_sounds_flixel_ogg_obj();
		Void __construct(::openfl::_v2::net::URLRequest stream,::openfl::media::SoundLoaderContext context,Dynamic __o_forcePlayAsMusic);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< __ASSET__assets_sounds_flixel_ogg_obj > __new(::openfl::_v2::net::URLRequest stream,::openfl::media::SoundLoaderContext context,Dynamic __o_forcePlayAsMusic);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~__ASSET__assets_sounds_flixel_ogg_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("__ASSET__assets_sounds_flixel_ogg"); }

		static ::String resourceName;
};


#endif /* INCLUDED___ASSET__assets_sounds_flixel_ogg */ 
