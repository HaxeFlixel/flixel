#ifndef INCLUDED_flixel_graphics_frames_FlxFrameCollectionType
#define INCLUDED_flixel_graphics_frames_FlxFrameCollectionType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrameCollectionType)
HX_DECLARE_CLASS2(flixel,ui,FlxBarFillDirection)
namespace flixel{
namespace graphics{
namespace frames{


class FlxFrameCollectionType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxFrameCollectionType_obj OBJ_;

	public:
		FlxFrameCollectionType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.graphics.frames.FlxFrameCollectionType"); }
		::String __ToString() const { return HX_CSTRING("FlxFrameCollectionType.") + tag; }

		static ::flixel::graphics::frames::FlxFrameCollectionType ATLAS;
		static inline ::flixel::graphics::frames::FlxFrameCollectionType ATLAS_dyn() { return ATLAS; }
		static ::flixel::graphics::frames::FlxFrameCollectionType BAR(::flixel::ui::FlxBarFillDirection type);
		static Dynamic BAR_dyn();
		static ::flixel::graphics::frames::FlxFrameCollectionType CLIPPED;
		static inline ::flixel::graphics::frames::FlxFrameCollectionType CLIPPED_dyn() { return CLIPPED; }
		static ::flixel::graphics::frames::FlxFrameCollectionType FILTER;
		static inline ::flixel::graphics::frames::FlxFrameCollectionType FILTER_dyn() { return FILTER; }
		static ::flixel::graphics::frames::FlxFrameCollectionType FONT;
		static inline ::flixel::graphics::frames::FlxFrameCollectionType FONT_dyn() { return FONT; }
		static ::flixel::graphics::frames::FlxFrameCollectionType IMAGE;
		static inline ::flixel::graphics::frames::FlxFrameCollectionType IMAGE_dyn() { return IMAGE; }
		static ::flixel::graphics::frames::FlxFrameCollectionType TILES;
		static inline ::flixel::graphics::frames::FlxFrameCollectionType TILES_dyn() { return TILES; }
		static ::flixel::graphics::frames::FlxFrameCollectionType USER(::String type);
		static Dynamic USER_dyn();
};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxFrameCollectionType */ 
