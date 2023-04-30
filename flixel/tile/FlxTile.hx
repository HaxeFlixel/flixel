package flixel.tile;

import flixel.FlxObject;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDirectionFlags;

/**
 * A simple helper object for FlxTilemap that helps expand collision opportunities and control.
 * You can use FlxTilemap.setTileProperties() to alter the collision properties and
 * callback functions and filters for this object to do things like one-way tiles or whatever.
 */
class FlxTile extends FlxObject
{
	/**
	 * This function is called whenever an object hits a tile of this type.
	 * This function should take the form myFunction(Tile:FlxTile,Object:FlxObject):void.
	 * Defaults to null, set through FlxTilemap.setTileProperties().
	 */
	public var callbackFunction:FlxObject->FlxObject->Void = null;

	/**
	 * Each tile can store its own filter class for their callback functions.
	 * That is, the callback will only be triggered if an object with a class
	 * type matching the filter touched it.
	 * Defaults to null, set through FlxTilemap.setTileProperties().
	 */
	public var filter:Class<FlxObject>;

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
	public function new(Tilemap:FlxTilemap, Index:Int, Width:Float, Height:Float, Visible:Bool, AllowCollisions:FlxDirectionFlags)
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
		callbackFunction = null;
		tilemap = null;
		frame = null;

		super.destroy();
	}
}
