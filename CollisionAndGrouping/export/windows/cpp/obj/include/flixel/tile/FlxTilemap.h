#ifndef INCLUDED_flixel_tile_FlxTilemap
#define INCLUDED_flixel_tile_FlxTilemap

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/tile/FlxBaseTilemap.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS2(flixel,math,FlxMatrix)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,tile,FlxBaseTilemap)
HX_DECLARE_CLASS2(flixel,tile,FlxTilemap)
HX_DECLARE_CLASS2(flixel,tile,FlxTilemapBuffer)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,display,BlendMode)
HX_DECLARE_CLASS3(openfl,_v2,geom,ColorTransform)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace flixel{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxTilemap_obj : public ::flixel::tile::FlxBaseTilemap_obj{
	public:
		typedef ::flixel::tile::FlxBaseTilemap_obj super;
		typedef FlxTilemap_obj OBJ_;
		FlxTilemap_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTilemap_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTilemap_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTilemap"); }

		Float tileScaleHack;
		::flixel::math::FlxPoint scale;
		::flixel::graphics::frames::FlxFramesCollection frames;
		::flixel::graphics::FlxGraphic graphic;
		int color;
		Float alpha;
		::openfl::_v2::geom::ColorTransform colorTransform;
		::openfl::_v2::display::BlendMode blend;
		::openfl::_v2::geom::Point _flashPoint;
		::openfl::_v2::geom::Rectangle _flashRect;
		Array< ::Dynamic > _buffers;
		int _tileWidth;
		int _tileHeight;
		Float _scaledTileWidth;
		Float _scaledTileHeight;
		::openfl::_v2::geom::Point _helperPoint;
		int _blendInt;
		::flixel::math::FlxMatrix _matrix;
		virtual Void destroy( );

		virtual ::flixel::graphics::frames::FlxFramesCollection set_frames( ::flixel::graphics::frames::FlxFramesCollection value);
		Dynamic set_frames_dyn();

		virtual Void cacheGraphics( int TileWidth,int TileHeight,Dynamic _tmp_TileGraphic);

		virtual Void initTileObjects( );

		virtual Void computeDimensions( );

		virtual Void updateMap( );

		virtual Void drawDebugOnCamera( ::flixel::FlxCamera Camera);

		virtual Void draw( );

		virtual Void setDirty( hx::Null< bool >  Dirty);

		virtual bool overlapsWithCallback( ::flixel::FlxObject Object,Dynamic Callback,hx::Null< bool >  FlipCallbackParams,::flixel::math::FlxPoint Position);

		virtual int getTileIndexByCoords( ::flixel::math::FlxPoint Coord);

		virtual ::flixel::math::FlxPoint getTileCoordsByIndex( int Index,hx::Null< bool >  Midpoint);

		virtual Array< ::Dynamic > getTileCoords( int Index,hx::Null< bool >  Midpoint);
		Dynamic getTileCoords_dyn();

		virtual Void follow( ::flixel::FlxCamera Camera,hx::Null< int >  Border,hx::Null< bool >  UpdateWorld);
		Dynamic follow_dyn();

		virtual bool ray( ::flixel::math::FlxPoint Start,::flixel::math::FlxPoint End,::flixel::math::FlxPoint Result,hx::Null< Float >  Resolution);

		virtual ::flixel::FlxSprite tileToSprite( int X,int Y,hx::Null< int >  NewTile,Dynamic SpriteFactory);
		Dynamic tileToSprite_dyn();

		virtual Void updateBuffers( );
		Dynamic updateBuffers_dyn();

		virtual Void drawTilemap( ::flixel::tile::FlxTilemapBuffer Buffer,::flixel::FlxCamera Camera);
		Dynamic drawTilemap_dyn();

		virtual Void updateTile( int Index);

		virtual ::flixel::tile::FlxTilemapBuffer createBuffer( ::flixel::FlxCamera camera);
		Dynamic createBuffer_dyn();

		virtual Void onGameResize( int _,int _1);
		Dynamic onGameResize_dyn();

		virtual ::flixel::graphics::FlxGraphic set_graphic( ::flixel::graphics::FlxGraphic Value);
		Dynamic set_graphic_dyn();

		virtual bool set_pixelPerfectRender( bool Value);

		virtual Float set_alpha( Float Alpha);
		Dynamic set_alpha_dyn();

		virtual int set_color( int Color);
		Dynamic set_color_dyn();

		virtual Void updateColorTransform( );
		Dynamic updateColorTransform_dyn();

		virtual ::openfl::_v2::display::BlendMode set_blend( ::openfl::_v2::display::BlendMode Value);
		Dynamic set_blend_dyn();

		virtual Void setScaleXYCallback( ::flixel::math::FlxPoint Scale);
		Dynamic setScaleXYCallback_dyn();

		virtual Void setScaleXCallback( ::flixel::math::FlxPoint Scale);
		Dynamic setScaleXCallback_dyn();

		virtual Void setScaleYCallback( ::flixel::math::FlxPoint Scale);
		Dynamic setScaleYCallback_dyn();

		virtual ::flixel::FlxSprite defaultTileToSprite( Dynamic TileProperties);
		Dynamic defaultTileToSprite_dyn();

		static ::flixel::tile::FlxTilemapBuffer _helperBuffer;
};

} // end namespace flixel
} // end namespace tile

#endif /* INCLUDED_flixel_tile_FlxTilemap */ 
