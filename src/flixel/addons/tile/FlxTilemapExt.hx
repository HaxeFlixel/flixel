package flixel.addons.tile;

import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTile;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;

/**
 * Extended <code>FlxTilemap</code> class that provides collision detection against slopes
 * Based on the original by Dirk Bunk.
 * 
 * @author Peter Christiansen
 * @link https://github.com/TheTurnipMaster/SlopeDemo
 */
class FlxTilemapExt extends FlxTilemap
{
	inline static public var SLOPE_FLOOR_LEFT:Int = 0;
	inline static public var SLOPE_FLOOR_RIGHT:Int = 1;
	inline static public var SLOPE_CEIL_LEFT:Int = 2;
	inline static public var SLOPE_CEIL_RIGHT:Int = 3;
	
	// Slope related variables
	private var _snapping:Int = 2;
	private var _slopePoint:FlxPoint;
	private var _objPoint:FlxPoint;
	
	private var _slopeFloorLeft:Array<Int>;
	private var _slopeFloorRight:Array<Int>;
	private var _slopeCeilLeft:Array<Int>;
	private var _slopeCeilRight:Array<Int>;
	
	public function new()
	{
		super();
		
		_slopePoint = new FlxPoint();
		_objPoint = new FlxPoint();
		
		_slopeFloorLeft = new Array<Int>();
		_slopeFloorRight = new Array<Int>();
		_slopeCeilLeft = new Array<Int>();
		_slopeCeilRight = new Array<Int>();
	}
	
	override public function destroy():Void 
	{
		_slopePoint = null;
		_objPoint = null;
		
		_slopeFloorLeft = null;
		_slopeFloorRight = null;
		_slopeCeilLeft = null;
		_slopeCeilRight = null;
		
		super.destroy();
	}

	/**
	 * THIS IS A COPY FROM <code>FlxTilemap</code> BUT IT SOLVES SLOPE COLLISION TOO
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 *
	 * @param 	Object 				The <code>FlxObject</code> you are checking for overlaps against.
	 * @param 	Callback 			An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a FlxTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param 	FlipCallbackParams 	Used to preserve A-B list ordering from FlxObject.separate() - returns the FlxTile object as the second parameter instead.
	 * @param 	Position 			Optional, specify a custom position for the tilemap (useful for overlapsAt()-type funcitonality).
	 *
	 * @return Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	override public function overlapsWithCallback(Object:FlxObject, ?Callback:FlxObject->FlxObject->Bool, FlipCallbackParams:Bool = false, ?Position:FlxPoint):Bool
	{
		var results:Bool = false;
		
		var X:Float = x;
		var Y:Float = y;
		
		if (Position != null)
		{
			X = Position.x;
			Y = Position.y;
		}
		
		//Figure out what tiles we need to check against
		var selectionX:Int = Math.floor((Object.x - X) / _tileWidth);
		var selectionY:Int = Math.floor((Object.y - Y) / _tileHeight);
		var selectionWidth:Int = selectionX + (Math.ceil(Object.width / _tileWidth)) + 1;
		var selectionHeight:Int = selectionY + Math.ceil(Object.height / _tileHeight) + 1;
		
		//Then bound these coordinates by the map edges
		if (selectionX < 0)
		{
			selectionX = 0;
		}
		if (selectionY < 0)
		{
			selectionY = 0;
		}
		if (selectionWidth > widthInTiles)
		{
			selectionWidth = widthInTiles;
		}
		if (selectionHeight > heightInTiles)
		{
			selectionHeight = heightInTiles;
		}
		
		// Then loop through this selection of tiles and call FlxObject.separate() accordingly
		var rowStart:Int = selectionY * widthInTiles;
		var row:Int = selectionY;
		var column:Int;
		var tile:FlxTile;
		var overlapFound:Bool;
		var deltaX:Float = X - last.x;
		var deltaY:Float = Y - last.y;
		
		while (row < selectionHeight)
		{
			column = selectionX;
			
			while (column < selectionWidth)
			{
				overlapFound = false;
				tile = _tileObjects[_data[rowStart + column]];
				
				if (tile.allowCollisions != 0)
				{
					tile.x = X + column * _tileWidth;
					tile.y = Y + row * _tileHeight;
					tile.last.x = tile.x - deltaX;
					tile.last.y = tile.y - deltaY;
					
					if (Callback != null)
					{
						if (FlipCallbackParams)
						{
							overlapFound = Callback(Object, tile);
						}
						else
						{
							overlapFound = Callback(tile, Object);
						}
					}
					else
					{
						overlapFound = (Object.x + Object.width > tile.x) && (Object.x < tile.x + tile.width) && (Object.y + Object.height > tile.y) && (Object.y < tile.y + tile.height);
					}
					
					// Solve slope collisions if no overlap was found
					/*
					if (overlapFound
						|| (!overlapFound && (tile.index == SLOPE_FLOOR_LEFT || tile.index == SLOPE_FLOOR_RIGHT || tile.index == SLOPE_CEIL_LEFT || tile.index == SLOPE_CEIL_RIGHT)))
					*/
					
					// New generalized slope collisions
					if (overlapFound || (!overlapFound && checkArrays(tile.index)))
					{
						if ((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
						{
							tile.mapIndex = rowStart + column;
							tile.callbackFunction(tile, Object);
						}
						results = true;
					}
				}
				else if ((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
				{
					tile.mapIndex = rowStart + column;
					tile.callbackFunction(tile, Object);
				}
				column++;
			}
			
			rowStart += widthInTiles;
			row++;
		}
		
		return results;
	}
	
	/**
	 * Sets the tiles that are treated as "clouds" or blocks that are only solid from the top.
	 * 
	 * @param 	Clouds	An array containing the numbers of the tiles to be treated as clouds.
	 */
	public function setClouds(?Clouds:Array<Int>):Void
	{
		if (Clouds != null)
		{
			for (i in 0...(Clouds.length))
			{
				setTileProperties(Clouds[i], FlxObject.CEILING);			
			}
		}
	}
	
	/**
	 * Sets the slope arrays, which define which tiles are treated as slopes.
	 * 
	 * @param 	LeftFloorSlopes 	An array containing the numbers of the tiles to be treated as left floor slopes.
	 * @param 	RightFloorSlopes	An array containing the numbers of the tiles to be treated as right floor slopes.
	 * @param 	LeftCeilSlopes		An array containing the numbers of the tiles to be treated as left ceiling slopes.
	 * @param 	RightCeilSlopes		An array containing the numbers of the tiles to be treated as right ceiling slopes.
	 */
	public function setSlopes(?LeftFloorSlopes:Array<Int>, ?RightFloorSlopes:Array<Int>, ?LeftCeilSlopes:Array<Int>, ?RightCeilSlopes:Array<Int>):Void
	{
		if (LeftFloorSlopes != null)
		{
			_slopeFloorLeft = LeftFloorSlopes;
		}
		if (RightFloorSlopes != null)
		{
			_slopeFloorRight = RightFloorSlopes;
		}
		if (LeftCeilSlopes != null)
		{
			_slopeCeilLeft = LeftCeilSlopes;
		}
		if (RightCeilSlopes != null)
		{
			_slopeCeilRight = RightCeilSlopes;
		}
		
		setSlopeProperties();
	}
	
	/**
	 * Bounds the slope point to the slope
	 * 
	 * @param 	Slope 	The slope to fix the slopePoint for
	 */
	private function fixSlopePoint(Slope:FlxTile):Void
	{
		_slopePoint.x = FlxMath.bound(_slopePoint.x, Slope.x, Slope.x + _tileWidth);
		_slopePoint.y = FlxMath.bound(_slopePoint.y, Slope.y, Slope.y + _tileHeight);
	}
	
	/**
	 * Ss called if an object collides with a floor slope
	 * 
	 * @param 	Slope	The floor slope
	 * @param	Object 	The object that collides with that slope
	 */
	private function onCollideFloorSlope(Slope:FlxObject, Object:FlxObject):Void
	{
		// Set the object's touching flag
		Object.touching = FlxObject.FLOOR;
		
		// Adjust the object's velocity
		Object.velocity.y = 0;
		
		// Reposition the object
		Object.y = _slopePoint.y - Object.height;
		
		if (Object.y < Slope.y - Object.height) 
		{ 
			Object.y = Slope.y - Object.height; 
		}
	}
	
	/**
	 * Is called if an object collides with a ceiling slope
	 * 
	 * @param 	Slope 	The ceiling slope
	 * @param 	Object 	The object that collides with that slope
	 */
	private function onCollideCeilSlope(Slope:FlxObject, Object:FlxObject):Void
	{
		// Set the object's touching flag
		Object.touching = FlxObject.CEILING;
		
		// Adjust the object's velocity
		Object.velocity.y = 0;
		
		// Reposition the object
		Object.y = _slopePoint.y;
		
		if (Object.y > Slope.y + _tileHeight) 
		{ 
			Object.y = Slope.y + _tileHeight; 
		}
	}
	
	/**
	 * Solves collision against a left-sided floor slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	private function solveCollisionSlopeFloorLeft(Slope:FlxObject, Object:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Object.x + Object.width + _snapping);
		_objPoint.y = Math.floor(Object.y + Object.height);
		
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (Slope.y + _tileHeight) - (_slopePoint.x - Slope.x);
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x + _snapping && _objPoint.x < Slope.x + _tileWidth + Object.width + _snapping && _objPoint.y >= _slopePoint.y && _objPoint.y <= Slope.y + _tileHeight)
		{
			// Call the collide function for the floor slope
			onCollideFloorSlope(Slope, Object);
		}
	}
	
	/**
	 * Solves collision against a right-sided floor slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	private function solveCollisionSlopeFloorRight(Slope:FlxObject, Object:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Object.x - _snapping);
		_objPoint.y = Math.floor(Object.y + Object.height);
		
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (Slope.y + _tileHeight) - (Slope.x - _slopePoint.x + _tileWidth);
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x - Object.width - _snapping && _objPoint.x < Slope.x + _tileWidth + _snapping && _objPoint.y >= _slopePoint.y && _objPoint.y <= Slope.y + _tileHeight)
		{
			// Call the collide function for the floor slope
			onCollideFloorSlope(Slope, Object);
		}
	}
	
	/**
	 * Solves collision against a left-sided ceiling slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Obj 	The object that collides with the slope
	 */
	private function solveCollisionSlopeCeilLeft(Slope:FlxObject, Obj:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Obj.x + Obj.width + _snapping);
		_objPoint.y = Math.ceil(Obj.y);
		
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (Slope.y) + (_slopePoint.x - Slope.x);
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x + _snapping && _objPoint.x < Slope.x + _tileWidth + Obj.width + _snapping && _objPoint.y <= _slopePoint.y && _objPoint.y >= Slope.y)
		{
			// Call the collide function for the floor slope
			onCollideCeilSlope(Slope, Obj);
		}
	}
	
	/**
	 * Solves collision against a right-sided ceiling slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Obj 	The object that collides with the slope
	 */
	private function solveCollisionSlopeCeilRight(Slope:FlxObject, Obj:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Obj.x - _snapping);
		_objPoint.y = Math.ceil(Obj.y);
		
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (Slope.y) + (Slope.x - _slopePoint.x + _tileWidth);
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x - Obj.width - _snapping && _objPoint.x < Slope.x + _tileWidth + _snapping && _objPoint.y <= _slopePoint.y && _objPoint.y >= Slope.y)
		{
			// Call the collide function for the floor slope
			onCollideCeilSlope(Slope, Obj);
		}
	}
	
	/**
	 * Internal helper function for setting the tiles currently held in the slope arrays to use slope collision.
	 * Note that if you remove items from a slope, this function will not unset the slope property.
	 */
	private function setSlopeProperties():Void
	{
		for (i in 0..._slopeFloorLeft.length)
		{
			setTileProperties(_slopeFloorLeft[i], FlxObject.RIGHT | FlxObject.FLOOR, solveCollisionSlopeFloorLeft);			
		}
		for (i in 0..._slopeFloorRight.length)
		{
			setTileProperties(_slopeFloorRight[i], FlxObject.LEFT | FlxObject.FLOOR, solveCollisionSlopeFloorRight);
		}
		for (i in 0..._slopeCeilLeft.length)
		{
			setTileProperties(_slopeCeilLeft[i], FlxObject.RIGHT | FlxObject.CEILING, solveCollisionSlopeCeilLeft);			
		}
		for (i in 0..._slopeCeilRight.length)
		{
			setTileProperties(_slopeCeilRight[i], FlxObject.LEFT | FlxObject.CEILING, solveCollisionSlopeCeilRight);
		}
	}
	
	/**
	 * Internal helper function for comparing a tile to the slope arrays to see if a tile should be treated as a slope.
	 * 
	 * @param 	TileIndex	The Tile Index number of the Tile you want to check.
	 * @return	Returns true if the tile is listed in one of the slope arrays. Otherwise returns false.
	 */
	private function checkArrays(TileIndex:Int):Bool
	{
		for (i in 0..._slopeFloorLeft.length)
		{
			if (_slopeFloorLeft[i] == TileIndex)
			{
				return true;
			}
		}	
		for (i in 0..._slopeFloorRight.length)
		{
			if (_slopeFloorRight[i] == TileIndex)
			{
				return true;
			}
		}	
		for (i in 0..._slopeCeilLeft.length)
		{
			if (_slopeCeilLeft[i] == TileIndex)
			{
				return true;
			}
		}	
		for (i in 0..._slopeCeilRight.length)
		{
			if (_slopeCeilRight[i] == TileIndex)
			{
				return true;
			}
		}	
		
		return false;
	}
}