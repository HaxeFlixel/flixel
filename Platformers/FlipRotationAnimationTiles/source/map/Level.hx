package map;

import entities.Character;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxRect;
import flixel.util.FlxSort;
import flixel.group.FlxGroup;

/**
 * ...
 * @author MrCdK
 */
class Level extends TiledMap
{
	private inline static var PATH_TILESETS = "maps/";
	
	public var backgroundGroup:FlxTypedGroup<FlxTilemapExt>;
	public var foregroundGroup:FlxTypedGroup<FlxTilemapExt>;
	
	public var collisionGroup:FlxTypedGroup<FlxObject>;
	public var characterGroup:FlxTypedGroup<Character>;
	
	public var bounds:FlxRect;

	public function new(level:Dynamic, animFile:Dynamic) 
	{
		super(level);
		
		// background and foreground groups
		backgroundGroup = new FlxTypedGroup<FlxTilemapExt>();
		foregroundGroup = new FlxTypedGroup<FlxTilemapExt>();
		
		// events and collision groups
		characterGroup = new FlxTypedGroup<Character>();
		collisionGroup = new FlxTypedGroup<FlxObject>();
		
		// The bound of the map for the camera
		bounds = FlxRect.get(0, 0, fullWidth, fullHeight);
		
		var tileset:TiledTileSet;
		var tilemap:FlxTilemapExt;
		var layer:TiledLayer;
		
		// Prepare the tile animations
		var animations = TileAnims.getAnimations(animFile);
		
		for (tiledLayer in layers)
		{
			if (tiledLayer.type != TiledLayerType.TILE) continue;
			var layer:TiledTileLayer = cast tiledLayer;
			
			if (layer.properties.contains("tileset"))
				tileset = this.getTileSet(layer.properties.get("tileset"));
			else
				throw "Each layer needs a tileset property with the tileset name";
			
			if (tileset == null)
				throw "The tileset is null";
			
			tilemap = new FlxTilemapExt();
			tilemap.loadMapFromArray(
				layer.tileArray,
				layer.width,
				layer.height,
				PATH_TILESETS + tileset.imageSource,
				tileset.tileWidth,                      // each tileset can have a different tile width or height
				tileset.tileHeight,
				OFF,                                    // disable auto map
				tileset.firstGID                        // IMPORTANT! set the starting tile id to the first tile id of the tileset
			);
			
			var specialTiles:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
			var tile:TiledTile;
			var animData;
			var specialTile:FlxTileSpecial;
			// For each tile in the layer
			for (i in 0...layer.tiles.length)
			{ 
				tile = layer.tiles[i];
				if (tile != null && isSpecialTile(tile, animations))
				{
					specialTile = new FlxTileSpecial(tile.tilesetID, tile.isFlipHorizontally, tile.isFlipVertically, tile.rotate);
					// add animations if exists
					if (animations.exists(tile.tilesetID))
					{
						// Right now, a special tile only can have one animation.
						animData = animations.get(tile.tilesetID)[0];
						// add some speed randomization to the animation
						var randomize:Float = FlxG.random.float( -animData.randomizeSpeed, animData.randomizeSpeed);
						var speed:Float = animData.speed + randomize;
						
						specialTile.addAnimation(animData.frames, speed, animData.framesData);
					}
					specialTiles[i] = specialTile;
				}
				else
				{
					specialTiles[i] = null;
				}
			}
			// set the special tiles (flipped, rotated and/or animated tiles)
			tilemap.setSpecialTiles(specialTiles);
			// set the alpha of the layer
			tilemap.alpha = layer.opacity;
			
			
			if (layer.properties.contains("fg"))
				foregroundGroup.add(tilemap);
			else
				backgroundGroup.add(tilemap);
		}
		
		loadObjects();
	}
	
	public function loadObjects()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT) continue;
			var group:TiledObjectLayer = cast layer;
			
			for (obj in group.objects)
			{
				loadObject(obj, group);
			}
		}
	}
	
	private function loadObject(o:TiledObject, g:TiledObjectLayer)
	{
		var x:Int = o.x;
		var y:Int = o.y;
		
		switch (o.type.toLowerCase())
		{
			case "player":
				var player:Character = new Character(o.name, x, y, "images/chars/"+o.name+".json");
				player.setBoundsMap(bounds);
				player.controllable = true;
				FlxG.camera.follow(player);
				characterGroup.add(player);
				
			case "npc":
				var npc:Character = new Character(o.name, x, y, "images/chars/"+o.name+".json");
				npc.setBoundsMap(bounds);
				characterGroup.add(npc);
				
			case "collision":
				var coll:FlxObject = new FlxObject(x, y, o.width, o.height);
				#if !FLX_NO_DEBUG
				coll.debugBoundingBoxColor = 0xFFFF00FF;
				#end
				coll.immovable = true;
				collisionGroup.add(coll);
		}
	}
	
	public function update(elapsed:Float):Void
	{
		updateCollisions();
		updateEventsOrder();
	}
	
	public function updateEventsOrder():Void
	{
		characterGroup.sort(FlxSort.byY);
	}
	
	public function updateCollisions():Void
	{
		FlxG.collide(characterGroup, collisionGroup);
		FlxG.collide(characterGroup, characterGroup);
	}
	
	private inline function isSpecialTile(tile:TiledTile, animations:Dynamic):Bool
	{
		return (tile.isFlipHorizontally || tile.isFlipVertically || tile.rotate != FlxTileSpecial.ROTATE_0 || animations.exists(tile.tilesetID));
	}
}