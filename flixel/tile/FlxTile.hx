package flixel.tile;

import flixel.FlxObject;
import flixel.graphics.frames.FlxFrame;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxSignal;

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
	public var callbackFunction:(FlxObject, FlxObject)->Void = null;
	
	/**
	 * Dispatched whenever FlxG.collide resolves a collision with a tile of this type
	 * @since 5.9.0
	 */
	public var onCollide = new FlxTypedSignal<(FlxTile, FlxObject)->Void>();
	
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
	public var tilemap:FlxTypedTilemap<FlxTile>;

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
	 * @param   tilemap          A reference to the tilemap object creating the tile.
	 * @param   index            The actual core map data index for this tile type.
	 * @param   width            The width of the tile.
	 * @param   height           The height of the tile.
	 * @param   visible          Whether the tile is visible or not.
	 * @param   allowCollisions  The collision flags for the object.  By default this value is ANY or NONE depending on the parameters sent to loadMap().
	 */
	public function new(tilemap:FlxTypedTilemap<FlxTile>, index:Int, width:Float, height:Float, visible:Bool, allowCollisions:FlxDirectionFlags)
	{
		super(0, 0, width, height);

		immovable = true;
		moves = false;

		this.tilemap = tilemap;
		this.index = index;
		this.visible = visible;
		this.allowCollisions = allowCollisions;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();

		callbackFunction = null;
		tilemap = null;
		frame = null;
		onCollide.removeAll();
	}
	
	/**
	 * Whether this tile overlaps the object. this should be called directly after calling
	 * `orient` to ensure this tile is in the correct world space.
	 * 
	 * This method is dynamic, meaning you can set custom behavior per tile, without extension.
	 * @since 5.9.0
	 */
	public dynamic function overlapsObject(object:FlxObject):Bool
	{
		return object.x + object.width > x
			&& object.x < x + width
			&& object.y + object.height > y
			&& object.y < y + height
			&& (filter == null || Std.isOfType(object, filter));
	}
	
	/**
	 * Places this tile in the world according to the desired map location. 
	 * often used before calling `overlapsObject`
	 * 
	 * This method is dynamic, meaning you can set custom behavior per tile, without extension.
	 * 
	 * @param   xPos    May be the true or a theoretical x of the map, based on what called this
	 * @param   yPos    May be the true or a theoretical y of the map, based on what called this
	 * @param   col     The tilemap column where this is being placed
	 * @param   row     The tilemap row where this is being placed
	 * @since 5.9.0
	 */
	public dynamic function orientAt(xPos:Float, yPos:Float, col:Int, row:Int)
	{
		mapIndex = (row * tilemap.widthInTiles) + col;
		width = tilemap.scaledTileWidth;
		height = tilemap.scaledTileHeight;
		x = xPos + col * width;
		y = yPos + row * height;
		last.x = x - (xPos - tilemap.last.x);
		last.y = y - (yPos - tilemap.last.y);
	}
	
	/**
	 * Places this tile in the world according to the desired map location. 
	 * often used before calling `overlapsObject`
	 * 
	 * Calls `orientAt` with the tilemap's current position
	 * 
	 * @param   col     The tilemap column where this is being placed
	 * @param   row     The tilemap row where this is being placed
	 * @since 5.9.0
	 */
	public inline function orient(col:Int, row:Int)
	{
		orientAt(tilemap.x, tilemap.y, col, row);
	}
	
	/**
	 * Places this tile in the world according to the desired map location. 
	 * often used before calling `overlapsObject`
	 * 
	 * Calls `orientAt` with the tilemap's current position
	 * 
	 * **Note:** A tile's mapIndex can be calculated via `row * widthInTiles + column`
	 * 
	 * @param   mapIndex  The desired location in the map
	 * @since 5.9.0
	 */
	public inline function orientByIndex(mapIndex:Int)
	{
		orientAtByIndex(tilemap.x, tilemap.y, mapIndex);
	}
	
	/**
	 * Places this tile in the world according to the desired map location. 
	 * often used before calling `overlapsObject`
	 * 
	 * Calls `orientAt` with the tilemap's current position
	 * 
	 * **Note:** A tile's mapIndex can be calculated via `row * widthInTiles + column`
	 * 
	 * @param   mapIndex  The desired location in the map
	 * @since 5.9.0
	 */
	public inline function orientAtByIndex(xPos:Float, yPos:Float, mapIndex:Int)
	{
		orientAt(xPos, yPos, tilemap.getColumn(mapIndex), tilemap.getRow(mapIndex));
	}
}
