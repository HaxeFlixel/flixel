#ifndef INCLUDED_openfl__v2_media_InternalAudioType
#define INCLUDED_openfl__v2_media_InternalAudioType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,media,InternalAudioType)
namespace openfl{
namespace _v2{
namespace media{


class InternalAudioType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef InternalAudioType_obj OBJ_;

	public:
		InternalAudioType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.media.InternalAudioType"); }
		::String __ToString() const { return HX_CSTRING("InternalAudioType.") + tag; }

		static ::openfl::_v2::media::InternalAudioType MUSIC;
		static inline ::openfl::_v2::media::InternalAudioType MUSIC_dyn() { return MUSIC; }
		static ::openfl::_v2::media::InternalAudioType SOUND;
		static inline ::openfl::_v2::media::InternalAudioType SOUND_dyn() { return SOUND; }
		static ::openfl::_v2::media::InternalAudioType UNKNOWN;
		static inline ::openfl::_v2::media::InternalAudioType UNKNOWN_dyn() { return UNKNOWN; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace media

#endif /* INCLUDED_openfl__v2_media_InternalAudioType */ 
