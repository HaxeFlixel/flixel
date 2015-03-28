#ifndef INCLUDED_flixel_tile_FlxBaseTilemap
#define INCLUDED_flixel_tile_FlxBaseTilemap

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxObject.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,tile,FlxBaseTilemap)
HX_DECLARE_CLASS2(flixel,tile,FlxTilemapAutoTiling)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxBaseTilemap_obj : public ::flixel::FlxObject_obj{
	public:
		typedef ::flixel::FlxObject_obj super;
		typedef FlxBaseTilemap_obj OBJ_;
		FlxBaseTilemap_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxBaseTilemap_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxBaseTilemap_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxBaseTilemap"); }

		::flixel::tile::FlxTilemapAutoTiling _auto;
		int widthInTiles;
		int heightInTiles;
		int totalTiles;
		Array< int > customTileRemap;
		Array< int > _randomIndices;
		Array< ::Dynamic > _randomChoices;
		Dynamic _randomLambda;
		Dynamic &_randomLambda_dyn() { return _randomLambda;}
		Dynamic _tileObjects;
		int _startingIndex;
		Array< int > _data;
		int _drawIndex;
		int _collideIndex;
		virtual Void updateTile( int Index);
		Dynamic updateTile_dyn();

		virtual Void cacheGraphics( int TileWidth,int TileHeight,Dynamic TileGraphic);
		Dynamic cacheGraphics_dyn();

		virtual Void initTileObjects( );
		Dynamic initTileObjects_dyn();

		virtual Void updateMap( );
		Dynamic updateMap_dyn();

		virtual Void computeDimensions( );
		Dynamic computeDimensions_dyn();

		virtual int getTileIndexByCoords( ::flixel::math::FlxPoint Coord);
		Dynamic getTileIndexByCoords_dyn();

		virtual ::flixel::math::FlxPoint getTileCoordsByIndex( int Index,hx::Null< bool >  Midpoint);
		Dynamic getTileCoordsByIndex_dyn();

		virtual bool ray( ::flixel::math::FlxPoint Start,::flixel::math::FlxPoint End,::flixel::math::FlxPoint Result,hx::Null< Float >  Resolution);
		Dynamic ray_dyn();

		virtual bool overlapsWithCallback( ::flixel::FlxObject Object,Dynamic Callback,hx::Null< bool >  FlipCallbackParams,::flixel::math::FlxPoint Position);
		Dynamic overlapsWithCallback_dyn();

		virtual Void setDirty( hx::Null< bool >  Dirty);
		Dynamic setDirty_dyn();

		virtual Void destroy( );

		virtual ::flixel::tile::FlxBaseTilemap loadMapFromCSV( ::String MapData,Dynamic TileGraphic,hx::Null< int >  TileWidth,hx::Null< int >  TileHeight,::flixel::tile::FlxTilemapAutoTiling AutoTile,hx::Null< int >  StartingIndex,hx::Null< int >  DrawIndex,hx::Null< int >  CollideIndex);
		Dynamic loadMapFromCSV_dyn();

		virtual ::flixel::tile::FlxBaseTilemap loadMapFromArray( Array< int > MapData,int WidthInTiles,int HeightInTiles,Dynamic TileGraphic,hx::Null< int >  TileWidth,hx::Null< int >  TileHeight,::flixel::tile::FlxTilemapAutoTiling AutoTile,hx::Null< int >  StartingIndex,hx::Null< int >  DrawIndex,hx::Null< int >  CollideIndex);
		Dynamic loadMapFromArray_dyn();

		virtual ::flixel::tile::FlxBaseTilemap loadMapFrom2DArray( Array< ::Dynamic > MapData,Dynamic TileGraphic,hx::Null< int >  TileWidth,hx::Null< int >  TileHeight,::flixel::tile::FlxTilemapAutoTiling AutoTile,hx::Null< int >  StartingIndex,hx::Null< int >  DrawIndex,hx::Null< int >  CollideIndex);
		Dynamic loadMapFrom2DArray_dyn();

		virtual Void loadMapHelper( Dynamic TileGraphic,hx::Null< int >  TileWidth,hx::Null< int >  TileHeight,::flixel::tile::FlxTilemapAutoTiling AutoTile,hx::Null< int >  StartingIndex,hx::Null< int >  DrawIndex,hx::Null< int >  CollideIndex);
		Dynamic loadMapHelper_dyn();

		virtual Void postGraphicLoad( );
		Dynamic postGraphicLoad_dyn();

		virtual Void applyAutoTile( );
		Dynamic applyAutoTile_dyn();

		virtual Void applyCustomRemap( );
		Dynamic applyCustomRemap_dyn();

		virtual Void randomizeIndices( );
		Dynamic randomizeIndices_dyn();

		virtual Void autoTile( int Index);
		Dynamic autoTile_dyn();

		virtual Void setCustomTileMappings( Array< int > mappings,Array< int > randomIndices,Array< ::Dynamic > randomChoices,Dynamic randomLambda);
		Dynamic setCustomTileMappings_dyn();

		virtual int getTile( int X,int Y);
		Dynamic getTile_dyn();

		virtual int getTileByIndex( int Index);
		Dynamic getTileByIndex_dyn();

		virtual int getTileCollisions( int Index);
		Dynamic getTileCollisions_dyn();

		virtual Array< int > getTileInstances( int Index);
		Dynamic getTileInstances_dyn();

		virtual bool setTile( int X,int Y,int Tile,hx::Null< bool >  UpdateGraphics);
		Dynamic setTile_dyn();

		virtual bool setTileByIndex( int Index,int Tile,hx::Null< bool >  UpdateGraphics);
		Dynamic setTileByIndex_dyn();

		virtual Void setTileProperties( int Tile,hx::Null< int >  AllowCollisions,Dynamic Callback,::Class CallbackFilter,hx::Null< int >  Range);
		Dynamic setTileProperties_dyn();

		virtual Array< int > getData( hx::Null< bool >  Simple);
		Dynamic getData_dyn();

		virtual Array< ::Dynamic > findPath( ::flixel::math::FlxPoint Start,::flixel::math::FlxPoint End,hx::Null< bool >  Simplify,hx::Null< bool >  RaySimplify,hx::Null< bool >  WideDiagonal);
		Dynamic findPath_dyn();

		virtual Array< int > computePathDistance( int StartIndex,int EndIndex,bool WideDiagonal,hx::Null< bool >  StopOnEnd);
		Dynamic computePathDistance_dyn();

		virtual Void walkPath( Array< int > Data,int Start,Array< ::Dynamic > Points);
		Dynamic walkPath_dyn();

		virtual Void simplifyPath( Array< ::Dynamic > Points);
		Dynamic simplifyPath_dyn();

		virtual Void raySimplifyPath( Array< ::Dynamic > Points);
		Dynamic raySimplifyPath_dyn();

		virtual bool overlaps( ::flixel::FlxBasic ObjectOrGroup,hx::Null< bool >  InScreenSpace,::flixel::FlxCamera Camera);

		virtual bool tilemapOverlapsCallback( ::flixel::FlxBasic ObjectOrGroup,hx::Null< Float >  X,hx::Null< Float >  Y,hx::Null< bool >  InScreenSpace,::flixel::FlxCamera Camera);
		Dynamic tilemapOverlapsCallback_dyn();

		virtual bool overlapsAt( Float X,Float Y,::flixel::FlxBasic ObjectOrGroup,hx::Null< bool >  InScreenSpace,::flixel::FlxCamera Camera);

		virtual bool tilemapOverlapsAtCallback( ::flixel::FlxBasic ObjectOrGroup,Float X,Float Y,bool InScreenSpace,::flixel::FlxCamera Camera);
		Dynamic tilemapOverlapsAtCallback_dyn();

		virtual bool overlapsPoint( ::flixel::math::FlxPoint WorldPoint,hx::Null< bool >  InScreenSpace,::flixel::FlxCamera Camera);

		virtual ::flixel::math::FlxRect getBounds( ::flixel::math::FlxRect Bounds);
		Dynamic getBounds_dyn();

};

} // end namespace flixel
} // end namespace tile

#endif /* INCLUDED_flixel_tile_FlxBaseTilemap */ 
