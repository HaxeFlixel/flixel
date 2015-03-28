#ifndef INCLUDED_openfl__v2_media_SoundChannel
#define INCLUDED_openfl__v2_media_SoundChannel

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/events/EventDispatcher.h>
HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,media,AudioThreadState)
HX_DECLARE_CLASS3(openfl,_v2,media,Sound)
HX_DECLARE_CLASS3(openfl,_v2,media,SoundChannel)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
HX_DECLARE_CLASS2(openfl,media,SoundTransform)
namespace openfl{
namespace _v2{
namespace media{


class HXCPP_CLASS_ATTRIBUTES  SoundChannel_obj : public ::openfl::_v2::events::EventDispatcher_obj{
	public:
		typedef ::openfl::_v2::events::EventDispatcher_obj super;
		typedef SoundChannel_obj OBJ_;
		SoundChannel_obj();
		Void __construct(Dynamic handle,hx::Null< Float >  __o_startTime,hx::Null< int >  __o_loops,::openfl::media::SoundTransform soundTransform);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< SoundChannel_obj > __new(Dynamic handle,hx::Null< Float >  __o_startTime,hx::Null< int >  __o_loops,::openfl::media::SoundTransform soundTransform);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~SoundChannel_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("SoundChannel"); }

		Float leftPeak;
		Float rightPeak;
		::openfl::_v2::events::EventDispatcher __dataProvider;
		Dynamic __handle;
		Float __pitch;
		::openfl::_v2::media::Sound __soundInstance;
		::openfl::media::SoundTransform __transform;
		::openfl::_v2::utils::ByteArray __dynamicBytes;
		bool __thread_completed;
		bool __addedToThread;
		virtual Void stop( );
		Dynamic stop_dyn();

		virtual bool __checkComplete( );
		Dynamic __checkComplete_dyn();

		virtual bool __runCheckComplete( );
		Dynamic __runCheckComplete_dyn();

		virtual Float get_leftPeak( );
		Dynamic get_leftPeak_dyn();

		virtual Float get_rightPeak( );
		Dynamic get_rightPeak_dyn();

		virtual Float get_pitch( );
		Dynamic get_pitch_dyn();

		virtual Float set_pitch( Float value);
		Dynamic set_pitch_dyn();

		virtual Float get_position( );
		Dynamic get_position_dyn();

		virtual Float set_position( Float value);
		Dynamic set_position_dyn();

		virtual ::openfl::media::SoundTransform get_soundTransform( );
		Dynamic get_soundTransform_dyn();

		virtual ::openfl::media::SoundTransform set_soundTransform( ::openfl::media::SoundTransform value);
		Dynamic set_soundTransform_dyn();

		static int __dynamicSoundCount;
		static Array< ::Dynamic > __incompleteList;
		static ::openfl::_v2::media::AudioThreadState __audioState;
		static bool __audioThreadIsIdle;
		static bool __audioThreadRunning;
		static ::openfl::_v2::media::SoundChannel createDynamic( Dynamic handle,::openfl::media::SoundTransform soundTransform,::openfl::_v2::events::EventDispatcher dataProvider);
		static Dynamic createDynamic_dyn();

		static Void __checkCompleteBackgroundThread( );
		static Dynamic __checkCompleteBackgroundThread_dyn();

		static bool __completePending( );
		static Dynamic __completePending_dyn();

		static Void __pollComplete( );
		static Dynamic __pollComplete_dyn();

		static Dynamic lime_sound_channel_is_complete;
		static Dynamic &lime_sound_channel_is_complete_dyn() { return lime_sound_channel_is_complete;}
		static Dynamic lime_sound_channel_get_left;
		static Dynamic &lime_sound_channel_get_left_dyn() { return lime_sound_channel_get_left;}
		static Dynamic lime_sound_channel_get_right;
		static Dynamic &lime_sound_channel_get_right_dyn() { return lime_sound_channel_get_right;}
		static Dynamic lime_sound_channel_get_position;
		static Dynamic &lime_sound_channel_get_position_dyn() { return lime_sound_channel_get_position;}
		static Dynamic lime_sound_channel_set_position;
		static Dynamic &lime_sound_channel_set_position_dyn() { return lime_sound_channel_set_position;}
		static Dynamic lime_sound_channel_get_data_position;
		static Dynamic &lime_sound_channel_get_data_position_dyn() { return lime_sound_channel_get_data_position;}
		static Dynamic lime_sound_channel_stop;
		static Dynamic &lime_sound_channel_stop_dyn() { return lime_sound_channel_stop;}
		static Dynamic lime_sound_channel_create;
		static Dynamic &lime_sound_channel_create_dyn() { return lime_sound_channel_create;}
		static Dynamic lime_sound_channel_set_transform;
		static Dynamic &lime_sound_channel_set_transform_dyn() { return lime_sound_channel_set_transform;}
		static Dynamic lime_sound_channel_set_pitch;
		static Dynamic &lime_sound_channel_set_pitch_dyn() { return lime_sound_channel_set_pitch;}
		static Dynamic lime_sound_channel_needs_data;
		static Dynamic &lime_sound_channel_needs_data_dyn() { return lime_sound_channel_needs_data;}
		static Dynamic lime_sound_channel_add_data;
		static Dynamic &lime_sound_channel_add_data_dyn() { return lime_sound_channel_add_data;}
};

} // end namespace openfl
} // end namespace _v2
} // end namespace media

#endif /* INCLUDED_openfl__v2_media_SoundChannel */ 
