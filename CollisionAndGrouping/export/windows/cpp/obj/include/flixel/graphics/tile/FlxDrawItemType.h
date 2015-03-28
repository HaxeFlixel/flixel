#ifndef INCLUDED_flixel_graphics_tile_FlxDrawItemType
#define INCLUDED_flixel_graphics_tile_FlxDrawItemType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,graphics,tile,FlxDrawItemType)
namespace flixel{
namespace graphics{
namespace tile{


class FlxDrawItemType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxDrawItemType_obj OBJ_;

	public:
		FlxDrawItemType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.graphics.tile.FlxDrawItemType"); }
		::String __ToString() const { return HX_CSTRING("FlxDrawItemType.") + tag; }

		static ::flixel::graphics::tile::FlxDrawItemType TILES;
		static inline ::flixel::graphics::tile::FlxDrawItemType TILES_dyn() { return TILES; }
		static ::flixel::graphics::tile::FlxDrawItemType TRIANGLES;
		static inline ::flixel::graphics::tile::FlxDrawItemType TRIANGLES_dyn() { return TRIANGLES; }
};

} // end namespace flixel
} // end namespace graphics
} // end namespace tile

#endif /* INCLUDED_flixel_graphics_tile_FlxDrawItemType */ 
