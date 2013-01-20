package org.flixel.addons;

import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxTilemap;
import org.flixel.FlxU;
import org.flixel.system.FlxTile;

/**
 * extended <code>FlxTilemap</code> class that provides collision detection against slopes
 * Based on the original by Dirk Bunk.
 * @author Peter Christiansen
 * @link https://github.com/TheTurnipMaster/SlopeDemo
 */
class FlxTilemapExt extends FlxTilemap
{
	//slope related variables
	private var _snapping:Int;
	private var _slopePoint:FlxPoint;
	private var _objPoint:FlxPoint;
	
	public static inline var SLOPE_FLOOR_LEFT:Int = 0;
	public static inline var SLOPE_FLOOR_RIGHT:Int = 1;
	public static inline var SLOPE_CEIL_LEFT:Int = 2;
	public static inline var SLOPE_CEIL_RIGHT:Int = 3;
	
	private var slopeFloorLeft:Array<Int>;
	private var slopeFloorRight:Array<Int>;
	private var slopeCeilLeft:Array<Int>;
	private var slopeCeilRight:Array<Int>;
	
	public function new()
	{
		super();
		
		_snapping = 2;
		_slopePoint = new FlxPoint();
		_objPoint = new FlxPoint();
		
		slopeFloorLeft = new Array<Int>();
		slopeFloorRight = new Array<Int>();
		slopeCeilLeft = new Array<Int>();
		slopeCeilRight = new Array<Int>();
	}
	
	override public function destroy():Void 
	{
		_slopePoint = null;
		_objPoint = null;
		
		slopeFloorLeft = null;
		slopeFloorRight = null;
		slopeCeilLeft = null;
		slopeCeilRight = null;
		
		super.destroy();
	}

	/**
	 * THIS IS A COPY FROM <code>FlxTilemap</code> BUT IT SOLVES SLOPE COLLISION TOO
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 *
	 * @param Object The <code>FlxObject</code> you are checking for overlaps against.
	 * @param Callback An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a FlxTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param FlipCallbackParams Used to preserve A-B list ordering from FlxObject.separate() - returns the FlxTile object as the second parameter instead.
	 * @param Position Optional, specify a custom position for the tilemap (useful for overlapsAt()-type funcitonality).
	 *
	 * @return Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	override public function overlapsWithCallback(Object:FlxObject, Callback:FlxObject->FlxObject->Bool = null, FlipCallbackParams:Bool = false, Position:FlxPoint = null):Bool
	{
		var results:Bool = false;
		
		var X:Float = x;
		var Y:Float = y;
		if(Position != null)
		{
			X = Position.x;
			Y = Position.y;
		}
		
		//Figure out what tiles we need to check against
		var selectionX:Int = FlxU.floor((Object.x - X) / _tileWidth);
		var selectionY:Int = FlxU.floor((Object.y - Y) / _tileHeight);
		var selectionWidth:Int = selectionX + (FlxU.ceil(Object.width / _tileWidth)) + 1;
		var selectionHeight:Int = selectionY + FlxU.ceil(Object.height / _tileHeight) + 1;
		
		//Then bound these coordinates by the map edges
		if(selectionX < 0)
		{
			selectionX = 0;
		}
		if(selectionY < 0)
		{
			selectionY = 0;
		}
		if(selectionWidth > widthInTiles)
		{
			selectionWidth = widthInTiles;
		}
		if(selectionHeight > heightInTiles)
		{
			selectionHeight = heightInTiles;
		}
		
		//Then loop through this selection of tiles and call FlxObject.separate() accordingly
		var rowStart:Int = selectionY * widthInTiles;
		var row:Int = selectionY;
		var column:Int;
		var tile:FlxTile;
		var overlapFound:Bool;
		var deltaX:Float = X - last.x;
		var deltaY:Float = Y - last.y;
		while(row < selectionHeight)
		{
			column = selectionX;
			while(column < selectionWidth)
			{
				overlapFound = false;
				tile = _tileObjects[_data[rowStart + column]];
				if(tile.allowCollisions != 0)
				{
					tile.x = X + column * _tileWidth;
					tile.y = Y + row * _tileHeight;
					tile.last.x = tile.x - deltaX;
					tile.last.y = tile.y - deltaY;
					if(Callback != null)
					{
						if(FlipCallbackParams)
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
					
					//solve slope collisions if no overlap was found
					/*
					if (overlapFound
						|| (!overlapFound && (tile.index == SLOPE_FLOOR_LEFT || tile.index == SLOPE_FLOOR_RIGHT || tile.index == SLOPE_CEIL_LEFT || tile.index == SLOPE_CEIL_RIGHT)))
					*/
					
					//New generalized slope collisions
					if (overlapFound || (!overlapFound && checkArrays(tile.index)))
					{
						if((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
						{
							tile.mapIndex = rowStart + column;
							tile.callbackFunction(tile, Object);
						}
						results = true;
					}
				}
				else if((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
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
	 * bounds the slope point to the slope
	 * @param slope the slope to fix the slopePoint for
	 */
	private function fixSlopePoint(slope:FlxTile):Void
	{
		_slopePoint.x = FlxU.bound(_slopePoint.x, slope.x, slope.x + _tileWidth);
		_slopePoint.y = FlxU.bound(_slopePoint.y, slope.y, slope.y + _tileHeight);
	}
	
	/**
	 * is called if an object collides with a floor slope
	 * @param slope the floor slope
	 * @param obj the object that collides with that slope
	 */
	private function onCollideFloorSlope(slope:FlxObject, obj:FlxObject):Void
	{
		//set the object's touching flag
		obj.touching = FlxObject.FLOOR;
		
		//adjust the object's velocity
		obj.velocity.y = 0;
		
		//reposition the object
		obj.y = _slopePoint.y - obj.height;
		if (obj.y < slope.y - obj.height) { obj.y = slope.y - obj.height; };
	}
	
	/**
	 * is called if an object collides with a ceiling slope
	 * @param slope the ceiling slope
	 * @param obj the object that collides with that slope
	 */
	private function onCollideCeilSlope(slope:FlxObject, obj:FlxObject):Void
	{
		//set the object's touching flag
		obj.touching = FlxObject.CEILING;
		
		//adjust the object's velocity
		obj.velocity.y = 0;
		
		//reposition the object
		obj.y = _slopePoint.y;
		if (obj.y > slope.y + _tileHeight) { obj.y = slope.y + _tileHeight; };
	}
	
	/**
	 * solves collision against a left-sided floor slope
	 * @param slope the slope to check against
	 * @param obj the object that collides with the slope
	 */
	private function solveCollisionSlopeFloorLeft(slope:FlxObject, obj:FlxObject):Void
	{
		//calculate the corner point of the object
		_objPoint.x = FlxU.floor(obj.x + obj.width + _snapping);
		_objPoint.y = FlxU.floor(obj.y + obj.height);
		
		//calculate position of the point on the slope that the object might overlap
		//this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (slope.y + _tileHeight) - (_slopePoint.x - slope.x);
		
		//fix the slope point to the slope tile
		fixSlopePoint(cast(slope, FlxTile));
		
		//check if the object is inside the slope
		if (_objPoint.x > slope.x + _snapping && _objPoint.x < slope.x + _tileWidth + obj.width + _snapping && _objPoint.y >= _slopePoint.y && _objPoint.y <= slope.y + _tileHeight)
		{
			//call the collide function for the floor slope
			onCollideFloorSlope(slope, obj);
		}
	}
	
	/**
	 * solves collision against a right-sided floor slope
	 * @param slope the slope to check against
	 * @param obj the object that collides with the slope
	 */
	private function solveCollisionSlopeFloorRight(slope:FlxObject, obj:FlxObject):Void
	{
		//calculate the corner point of the object
		_objPoint.x = FlxU.floor(obj.x - _snapping);
		_objPoint.y = FlxU.floor(obj.y + obj.height);
		
		//calculate position of the point on the slope that the object might overlap
		//this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (slope.y + _tileHeight) - (slope.x - _slopePoint.x + _tileWidth);
		
		//fix the slope point to the slope tile
		fixSlopePoint(cast(slope, FlxTile));
		
		//check if the object is inside the slope
		if (_objPoint.x > slope.x - obj.width - _snapping && _objPoint.x < slope.x + _tileWidth + _snapping && _objPoint.y >= _slopePoint.y && _objPoint.y <= slope.y + _tileHeight)
		{
			//call the collide function for the floor slope
			onCollideFloorSlope(slope, obj);
		}
	}
	
	/**
	 * solves collision against a left-sided ceiling slope
	 * @param slope the slope to check against
	 * @param obj the object that collides with the slope
	 */
	private function solveCollisionSlopeCeilLeft(slope:FlxObject, obj:FlxObject):Void
	{
		//calculate the corner point of the object
		_objPoint.x = FlxU.floor(obj.x + obj.width + _snapping);
		_objPoint.y = FlxU.ceil(obj.y);
		
		//calculate position of the point on the slope that the object might overlap
		//this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (slope.y) + (_slopePoint.x - slope.x);
		
		//fix the slope point to the slope tile
		fixSlopePoint(cast(slope, FlxTile));
		
		//check if the object is inside the slope
		if (_objPoint.x > slope.x + _snapping && _objPoint.x < slope.x + _tileWidth + obj.width + _snapping && _objPoint.y <= _slopePoint.y && _objPoint.y >= slope.y)
		{
			//call the collide function for the floor slope
			onCollideCeilSlope(slope, obj);
		}
	}
	
	/**
	 * solves collision against a right-sided ceiling slope
	 * @param slope the slope to check against
	 * @param obj the object that collides with the slope
	 */
	private function solveCollisionSlopeCeilRight(slope:FlxObject, obj:FlxObject):Void
	{
		//calculate the corner point of the object
		_objPoint.x = FlxU.floor(obj.x - _snapping);
		_objPoint.y = FlxU.ceil(obj.y);
		
		//calculate position of the point on the slope that the object might overlap
		//this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (slope.y) + (slope.x - _slopePoint.x + _tileWidth);
		
		//fix the slope point to the slope tile
		fixSlopePoint(cast(slope, FlxTile));
		
		//check if the object is inside the slope
		if (_objPoint.x > slope.x - obj.width - _snapping && _objPoint.x < slope.x + _tileWidth + _snapping && _objPoint.y <= _slopePoint.y && _objPoint.y >= slope.y)
		{
			//call the collide function for the floor slope
			onCollideCeilSlope(slope, obj);
		}
	}
	
	/**
	 * Sets the tiles that are treated as "clouds" or blocks that are only solid from the top.
	 * @param An array containing the numbers of the tiles to be treated as clouds.
	 * 
	 */
	public function setClouds(clouds:Array<Int> = null):Void
	{
		if (clouds != null)
		{
			for (i in 0...(clouds.length))
			{
				setTileProperties(clouds[i], FlxObject.CEILING);			
			}
		}
	}
	
	/**
	 * Sets the slope arrays, which define which tiles are treated as slopes.
	 * @param An array containing the numbers of the tiles to be treated as left floor slopes.
	 * @param An array containing the numbers of the tiles to be treated as right floor slopes.
	 * @param An array containing the numbers of the tiles to be treated as left ceiling slopes.
	 * @param An array containing the numbers of the tiles to be treated as right ceiling slopes.
	 */
	public function setSlopes(leftFloorSlopes:Array<Int> = null, rightFloorSlopes:Array<Int> = null, leftCeilSlopes:Array<Int> = null, rightCeilSlopes:Array<Int> = null):Void
	{
		if (leftFloorSlopes != null)
		{
			slopeFloorLeft = leftFloorSlopes;
		}
		if (rightFloorSlopes != null)
		{
			slopeFloorRight = rightFloorSlopes;
		}
		if (leftCeilSlopes != null)
		{
			slopeCeilLeft = leftCeilSlopes;
		}
		if (rightCeilSlopes != null)
		{
			slopeCeilRight = rightCeilSlopes;
		}
		
		setSlopeProperties();
	}
	
	/**
	 * internal helper function for setting the tiles currently held in the slope arrays to use slope collision.
	 * Note that if you remove items from a slope, this function will not unset the slope property.
	 */
	private function setSlopeProperties():Void
	{
		for (i in 0...(slopeFloorLeft.length))
		{
			setTileProperties(slopeFloorLeft[i], FlxObject.RIGHT | FlxObject.FLOOR, solveCollisionSlopeFloorLeft);			
		}
		for (i in 0...(slopeFloorRight.length))
		{
			setTileProperties(slopeFloorRight[i], FlxObject.LEFT | FlxObject.FLOOR, solveCollisionSlopeFloorRight);
		}
		for (i in 0...(slopeCeilLeft.length))
		{
			setTileProperties(slopeCeilLeft[i], FlxObject.RIGHT | FlxObject.CEILING, solveCollisionSlopeCeilLeft);			
		}
		for (i in 0...(slopeCeilRight.length))
		{
			setTileProperties(slopeCeilRight[i], FlxObject.LEFT | FlxObject.CEILING, solveCollisionSlopeCeilRight);
		}
	}
	
	/**
	 * internal helper function for comparing a tile to the slope arrays to see if a tile should be treated as a slope.
	 * @param The Tile Index number of the Tile you want to check.
	 * 
	 * @return Returns true if the tile is listed in one of the slope arrays.  Otherwise returns false.
	 */
	private function checkArrays(tileIndex:Int):Bool
	{
		for (i in 0...(slopeFloorLeft.length))
		{
			if (slopeFloorLeft[i] == tileIndex)
			{
				return true;
			}
		}	
		for (i in 0...(slopeFloorRight.length))
		{
			if (slopeFloorRight[i] == tileIndex)
			{
				return true;
			}
		}	
		for (i in 0...(slopeCeilLeft.length))
		{
			if (slopeCeilLeft[i] == tileIndex)
			{
				return true;
			}
		}	
		for (i in 0...(slopeCeilRight.length))
		{
			if (slopeCeilRight[i] == tileIndex)
			{
				return true;
			}
		}	
		
		return false;
	}
	
}