#ifndef INCLUDED_flixel_tile_FlxTileblock
#define INCLUDED_flixel_tile_FlxTileblock

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxSprite.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxTileFrames)
HX_DECLARE_CLASS2(flixel,tile,FlxTileblock)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxTileblock_obj : public ::flixel::FlxSprite_obj{
	public:
		typedef ::flixel::FlxSprite_obj super;
		typedef FlxTileblock_obj OBJ_;
		FlxTileblock_obj();
		Void __construct(int X,int Y,int Width,int Height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTileblock_obj > __new(int X,int Y,int Width,int Height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTileblock_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTileblock"); }

		::flixel::FlxSprite tileSprite;
		virtual Void destroy( );

		virtual ::flixel::tile::FlxTileblock loadFrames( ::flixel::graphics::frames::FlxTileFrames tileFrames,hx::Null< int >  empties);
		Dynamic loadFrames_dyn();

		virtual ::flixel::tile::FlxTileblock loadTiles( Dynamic TileGraphic,hx::Null< int >  TileWidth,hx::Null< int >  TileHeight,hx::Null< int >  Empties);
		Dynamic loadTiles_dyn();

		virtual Void setTile( int x,int y,int index);
		Dynamic setTile_dyn();

};

} // end namespace flixel
} // end namespace tile

#endif /* INCLUDED_flixel_tile_FlxTileblock */ 
