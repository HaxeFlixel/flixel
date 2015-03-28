#ifndef INCLUDED_flixel_system_frontEnds_SoundFrontEnd
#define INCLUDED_flixel_system_frontEnds_SoundFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,system,FlxSound)
HX_DECLARE_CLASS3(flixel,system,frontEnds,SoundFrontEnd)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,media,Sound)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  SoundFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef SoundFrontEnd_obj OBJ_;
		SoundFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< SoundFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~SoundFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("SoundFrontEnd"); }

		::flixel::system::FlxSound music;
		bool muted;
		Dynamic volumeHandler;
		Dynamic &volumeHandler_dyn() { return volumeHandler;}
		Array< int > volumeUpKeys;
		Array< int > volumeDownKeys;
		Array< int > muteKeys;
		bool soundTrayEnabled;
		::flixel::group::FlxTypedGroup list;
		Float volume;
		virtual Void playMusic( Dynamic Music,hx::Null< Float >  Volume,hx::Null< bool >  Looped);
		Dynamic playMusic_dyn();

		virtual ::flixel::system::FlxSound load( Dynamic EmbeddedSound,hx::Null< Float >  Volume,hx::Null< bool >  Looped,hx::Null< bool >  AutoDestroy,hx::Null< bool >  AutoPlay,::String URL,Dynamic OnComplete);
		Dynamic load_dyn();

		virtual ::openfl::_v2::media::Sound cache( ::String EmbeddedSound);
		Dynamic cache_dyn();

		virtual Void cacheAll( );
		Dynamic cacheAll_dyn();

		virtual ::flixel::system::FlxSound play( Dynamic EmbeddedSound,hx::Null< Float >  Volume,hx::Null< bool >  Looped,hx::Null< bool >  AutoDestroy,Dynamic OnComplete);
		Dynamic play_dyn();

		virtual ::flixel::system::FlxSound stream( ::String URL,hx::Null< Float >  Volume,hx::Null< bool >  Looped,hx::Null< bool >  AutoDestroy,Dynamic OnComplete);
		Dynamic stream_dyn();

		virtual Void pause( );
		Dynamic pause_dyn();

		virtual Void resume( );
		Dynamic resume_dyn();

		virtual Void destroy( hx::Null< bool >  ForceDestroy);
		Dynamic destroy_dyn();

		virtual Void toggleMuted( );
		Dynamic toggleMuted_dyn();

		virtual Void changeVolume( Float Amount);
		Dynamic changeVolume_dyn();

		virtual Void showSoundTray( );
		Dynamic showSoundTray_dyn();

		virtual Void update( Float elapsed);
		Dynamic update_dyn();

		virtual Void onFocusLost( );
		Dynamic onFocusLost_dyn();

		virtual Void onFocus( );
		Dynamic onFocus_dyn();

		virtual Void loadSavedPrefs( );
		Dynamic loadSavedPrefs_dyn();

		virtual Float set_volume( Float Volume);
		Dynamic set_volume_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_SoundFrontEnd */ 
