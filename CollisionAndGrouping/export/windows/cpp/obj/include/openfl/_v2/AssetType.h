#ifndef INCLUDED_openfl__v2_AssetType
#define INCLUDED_openfl__v2_AssetType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,_v2,AssetType)
namespace openfl{
namespace _v2{


class AssetType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef AssetType_obj OBJ_;

	public:
		AssetType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.AssetType"); }
		::String __ToString() const { return HX_CSTRING("AssetType.") + tag; }

		static ::openfl::_v2::AssetType BINARY;
		static inline ::openfl::_v2::AssetType BINARY_dyn() { return BINARY; }
		static ::openfl::_v2::AssetType FONT;
		static inline ::openfl::_v2::AssetType FONT_dyn() { return FONT; }
		static ::openfl::_v2::AssetType IMAGE;
		static inline ::openfl::_v2::AssetType IMAGE_dyn() { return IMAGE; }
		static ::openfl::_v2::AssetType MOVIE_CLIP;
		static inline ::openfl::_v2::AssetType MOVIE_CLIP_dyn() { return MOVIE_CLIP; }
		static ::openfl::_v2::AssetType MUSIC;
		static inline ::openfl::_v2::AssetType MUSIC_dyn() { return MUSIC; }
		static ::openfl::_v2::AssetType SOUND;
		static inline ::openfl::_v2::AssetType SOUND_dyn() { return SOUND; }
		static ::openfl::_v2::AssetType TEMPLATE;
		static inline ::openfl::_v2::AssetType TEMPLATE_dyn() { return TEMPLATE; }
		static ::openfl::_v2::AssetType TEXT;
		static inline ::openfl::_v2::AssetType TEXT_dyn() { return TEXT; }
};

} // end namespace openfl
} // end namespace _v2

#endif /* INCLUDED_openfl__v2_AssetType */ 
