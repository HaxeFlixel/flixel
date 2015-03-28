#ifndef INCLUDED_flixel_system_FlxSound
#define INCLUDED_flixel_system_FlxSound

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxBasic.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,system,FlxSound)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,media,Sound)
HX_DECLARE_CLASS3(openfl,_v2,media,SoundChannel)
HX_DECLARE_CLASS2(openfl,media,SoundTransform)
namespace flixel{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  FlxSound_obj : public ::flixel::FlxBasic_obj{
	public:
		typedef ::flixel::FlxBasic_obj super;
		typedef FlxSound_obj OBJ_;
		FlxSound_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxSound_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxSound_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxSound"); }

		Float x;
		Float y;
		bool persist;
		::String name;
		::String artist;
		Float amplitude;
		Float amplitudeLeft;
		Float amplitudeRight;
		bool autoDestroy;
		Dynamic onComplete;
		Dynamic &onComplete_dyn() { return onComplete;}
		bool playing;
		Float time;
		bool looped;
		::openfl::_v2::media::Sound _sound;
		::openfl::_v2::media::SoundChannel _channel;
		::openfl::media::SoundTransform _transform;
		bool _paused;
		Float _volume;
		Float _volumeAdjust;
		::flixel::FlxObject _target;
		Float _radius;
		bool _proximityPan;
		bool _alreadyPaused;
		virtual Void reset( );
		Dynamic reset_dyn();

		virtual Void destroy( );

		virtual Void update( Float elapsed);

		virtual Void kill( );

		virtual ::flixel::system::FlxSound loadEmbedded( Dynamic EmbeddedSound,hx::Null< bool >  Looped,hx::Null< bool >  AutoDestroy,Dynamic OnComplete);
		Dynamic loadEmbedded_dyn();

		virtual ::flixel::system::FlxSound loadStream( ::String SoundURL,hx::Null< bool >  Looped,hx::Null< bool >  AutoDestroy,Dynamic OnComplete);
		Dynamic loadStream_dyn();

		virtual ::flixel::system::FlxSound proximity( Float X,Float Y,::flixel::FlxObject TargetObject,Float Radius,hx::Null< bool >  Pan);
		Dynamic proximity_dyn();

		virtual ::flixel::system::FlxSound play( hx::Null< bool >  ForceRestart);
		Dynamic play_dyn();

		virtual ::flixel::system::FlxSound resume( );
		Dynamic resume_dyn();

		virtual ::flixel::system::FlxSound pause( );
		Dynamic pause_dyn();

		virtual ::flixel::system::FlxSound stop( );
		Dynamic stop_dyn();

		virtual ::flixel::system::FlxSound fadeOut( hx::Null< Float >  Duration,Dynamic To);
		Dynamic fadeOut_dyn();

		virtual ::flixel::system::FlxSound fadeIn( hx::Null< Float >  Duration,hx::Null< Float >  From,hx::Null< Float >  To);
		Dynamic fadeIn_dyn();

		virtual Void volumeTween( Float f);
		Dynamic volumeTween_dyn();

		virtual Float getActualVolume( );
		Dynamic getActualVolume_dyn();

		virtual Void setPosition( hx::Null< Float >  X,hx::Null< Float >  Y);
		Dynamic setPosition_dyn();

		virtual Void updateTransform( );
		Dynamic updateTransform_dyn();

		virtual Void startSound( Float Position);
		Dynamic startSound_dyn();

		virtual Void stopped( ::openfl::_v2::events::Event event);
		Dynamic stopped_dyn();

		virtual Void cleanup( bool destroySound,hx::Null< bool >  resetPosition,hx::Null< bool >  resetFading);
		Dynamic cleanup_dyn();

		virtual Void gotID3( ::openfl::_v2::events::Event event);
		Dynamic gotID3_dyn();

		virtual Void onFocus( );
		Dynamic onFocus_dyn();

		virtual Void onFocusLost( );
		Dynamic onFocusLost_dyn();

		virtual bool get_playing( );
		Dynamic get_playing_dyn();

		virtual Float get_volume( );
		Dynamic get_volume_dyn();

		virtual Float set_volume( Float Volume);
		Dynamic set_volume_dyn();

		virtual Float get_pan( );
		Dynamic get_pan_dyn();

		virtual Float set_pan( Float pan);
		Dynamic set_pan_dyn();

		virtual bool get_looped( );
		Dynamic get_looped_dyn();

		virtual bool set_looped( bool loop);
		Dynamic set_looped_dyn();

};

} // end namespace flixel
} // end namespace system

#endif /* INCLUDED_flixel_system_FlxSound */ 
