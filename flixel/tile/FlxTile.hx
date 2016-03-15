package flixel.tile;

import flixel.FlxObject;
import flixel.graphics.frames.FlxFrame;

/**
 * A simple helper object for FlxTilemap that helps expand collision opportunities and control.
 * You can use FlxTilemap.setTileProperties() to alter the collision properties and
 * callback functions and filters for this object to do things like one-way tiles or whatever.
 */
class FlxTile extends FlxObject
{
	/**
	 * Filters used for overlap/collision vs different classes on this tile.
	 * Use `FlxBaseTilemap.addTileFilter()` and `FlxBaseTilemap.removeTileFilter()`
	 */
	public var filters:Map<String, FlxTileFilter> = null;
	/**
	 * A reference to the tilemap this tile object belongs to.
	 */
	public var tilemap:FlxTilemap;
	/**
	 * The index of this tile type in the core map data.
	 * For example, if your map only has 16 kinds of tiles in it,
	 * this number is usually between 0 and 15.
	 */
	public var index:Int;
	/**
	 * The current map index of this tile object at this moment.
	 * You can think of tile objects as moving around the tilemap helping with collisions.
	 * This value is only reliable and useful if used from the callback function.
	 */
	public var mapIndex:Int = 0;
	
	/**
	 * Frame graphic for this tile.
	 */
	public var frame:FlxFrame;
	
	/**
	 * Instantiate this new tile object.  This is usually called from FlxTilemap.loadMap().
	 * 
	 * @param 	Tilemap			A reference to the tilemap object creating the tile.
	 * @param 	Index			The actual core map data index for this tile type.
	 * @param 	Width			The width of the tile.
	 * @param 	Height			The height of the tile.
	 * @param 	Visible			Whether the tile is visible or not.
	 * @param 	AllowCollisions	The collision flags for the object.  By default this value is ANY or NONE depending on the parameters sent to loadMap().
	 */
	public function new(Tilemap:FlxTilemap, Index:Int, Width:Float, Height:Float, Visible:Bool, AllowCollisions:Int)
	{
		super(0, 0, Width, Height);
		
		immovable = true;
		moves = false;
		
		tilemap = Tilemap;
		index = Index;
		visible = Visible;
		allowCollisions = AllowCollisions;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (filters != null)
		{
			for (f in filters)
			{
				f.overlapCallback = null;
				f.processCallback = null;
				f = null;
			}
			filters = null;
		}
		tilemap = null;
		frame = null;
		
		super.destroy();
	}
}
class FlxTileFilter
{
	/**
	 * Collision flags for this filter.
	 * Defaults to ANY
	 */
	public var collisions:Int = FlxObject.ANY;
	
	/**
	 * This function is called whenever an object hits a tile of this type.
	 * This function should take the form myFunction(Tile:FlxTile,Object:FlxObject):Void.
	 * Defaults to null
	 */
	public var overlapCallback:FlxTile->FlxObject->Void = null;
	
	/**
	 * This function, if set, will be called when overlap is detected, and `overlapCallback` will only be called if this returns `true`.
	 * Should take the form of myFunction(Tile:FlxTile,Object:FlxObject):Bool
	 * Use `FlxObject.seperate()` to allow collision on this tile.
	 */
	public var processCallback:FlxTile->FlxObject->Bool = null;
	
	public function new(?collisions:Int = FlxObject.ANY, ?overlapCallback:FlxTile->FlxObject->Void, ?processCallback:FlxTile->FlxObject->Bool)
	{
		this.collisions = collisions;
		this.overlapCallback = overlapCallback;
		this.processCallback = processCallback;
	}
	
}