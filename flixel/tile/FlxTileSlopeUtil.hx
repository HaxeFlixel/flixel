package flixel.tile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Used to define the "normal" or orthogonal edges of a slope, 
 */
@:forward(up, down, left, right, has, hasAny, and)
enum abstract FlxSlopeEdges(FlxDirectionFlags)
{
	/** ◥ **/
	var NE = cast 0x0110; // UP   | RIGHT
	
	/** ◤ **/
	var NW = cast 0x0101; // UP   | LEFT 
	
	/** ◢ **/
	var SE = cast 0x1010; // DOWN | RIGHT
	
	/** ◣ **/
	var SW = cast 0x1001; // DOWN | LEFT
	
	var self(get, never):FlxSlopeEdges;
	
	inline function get_self():FlxSlopeEdges
	{
		#if (haxe >= version("4.3.0"))
		return abstract;
		#else
		return cast this;
		#end
	}
	
	inline public function isSlopingUp()
	{
		return this.up == this.left;
	}
	
	inline public function getSlopeSign()
	{
		return isSlopingUp() ? -1 : 1;
	}
	
	/**
	 * The position of the slopes y intercept relative to the left of the tile, from `0` to `1`
	 * where `1` is the bottom of the tile and `0` is the top
	 */
	public function getYIntercept(grade:FlxSlopeGrade):Float
	{
		return switch [grade, self]
		{
			case [NONE, _]:
				0;
			case [NORMAL, _]:
				isSlopingUp() ? 1.0 : 0.0;
			case [STEEP (THICK), SE] | [STEEP (THIN ), NW]:  1.0; // slope up
			case [STEEP (THIN ), SE] | [STEEP (THICK), NW]:  2.0; // slope up
			case [GENTLE(THICK), SW] | [GENTLE(THIN ), NE]:  0.0; // slope down
			case [GENTLE(THIN ), SW] | [GENTLE(THICK), NE]:  0.5; // slope down
			case [STEEP (THIN ), SW] | [STEEP (THICK), NE]:  0.0; // slope down
			case [STEEP (THICK), SW] | [STEEP (THIN ), NE]: -1.0; // slope down
			case [GENTLE(THIN ), SE] | [GENTLE(THICK), NW]:  1.0; // slope up
			case [GENTLE(THICK), SE] | [GENTLE(THIN ), NW]:  0.5; // slope up
		}
	}
	
	public function getSlope(grade:FlxSlopeGrade):Float
	{
		return getSlopeSign() * switch grade
		{
			case STEEP(_): 2.0;
			case GENTLE(_): 0.5;
			case NORMAL: 1.0;
			case NONE: 0.0;
		}
	}
	
	public function anyAreSolid(dir:FlxDirectionFlags)
	{
		// return this.not().hasAny(dir);
		return this.hasAny(dir);
	}
}

@:using(flixel.tile.FlxTileSlopeUtil)
enum FlxSlopeGrade
{
	STEEP(type:SlopeGradeType);
	GENTLE(type:SlopeGradeType);
	NORMAL;
	NONE;
}

enum SlopeGradeType
{
	THICK;
	THIN;
}

@:access(flixel.FlxObject)
class FlxTileSlopeUtil
{
	/**
	 * Used to compute collsiion forces on a sloped tile
	 * 
	 * @param edges   Which edges of the tile are normal
	 * @param grade   The slope of the tile
	 * @param downV   How much downward velocity should be used to kep the object on the ground
	 * @param result  Optional result vector, if `null` a new one is created
	 */
	static public function computeCollisionOverlap(tile:FlxTile, object:FlxObject, edges:FlxSlopeEdges, grade:FlxSlopeGrade, downV:Float, ?result:FlxPoint)
	{
		if (grade == NONE)
			return FlxObject.defaultComputeCollisionOverlap(tile, object, result);
		
		if (result == null)
			result = FlxPoint.get();
		
		result.set(computeCollisionOverlapX(tile, object, edges, grade), computeCollisionOverlapY(tile, object, edges, grade, downV));
		
		if (abs(result.x) > min(tile.width, object.width))
			result.x = Math.POSITIVE_INFINITY;
		
		if (abs(result.y) > min(tile.height, object.height))
			result.y = Math.POSITIVE_INFINITY;
		
		// separate on the smaller axis
		if (Math.isFinite(result.x) || Math.isFinite(result.y))
		{
			if (abs(result.x) > abs(result.y))
				result.x = 0;
			else
				result.y = 0;
		}
		else
			result.set(0, 0);
		
		return result;
	}
	
	static function checkHitSolidWallX(tile:FlxTile, object:FlxObject, edges:FlxSlopeEdges)
	{
		final solidCollisions = edges.and(FlxG.collision.getCollisionEdgeX(tile, object));
		return (solidCollisions.right && object.last.x >= tile.x + tile.width)
			|| (solidCollisions.left && object.last.x + object.width <= tile.x);
	}
	
	static function checkHitSolidWallY(tile:FlxTile, object:FlxObject, edges:FlxSlopeEdges)
	{
		final solidCollisions = edges.and(FlxG.collision.getCollisionEdgeY(tile, object));
		return (solidCollisions.down && object.last.y >= tile.y + tile.height)
			|| (solidCollisions.up && object.last.y + object.height <= tile.y);
	}
	
	static public function computeCollisionOverlapX(tile:FlxTile, object:FlxObject, edges:FlxSlopeEdges, grade:FlxSlopeGrade)
	{
		final overlapY = computeSlopeOverlapY(tile, object, edges, grade, 0);
		// check if they're hitting the solid edges
		if (overlapY != 0 && checkHitSolidWallX(tile, object, edges))
			return FlxObject.defaultComputeCollisionOverlapX(tile, object);
		
		// let y separate
		return Math.POSITIVE_INFINITY;
	}
	
	static public function computeCollisionOverlapY(tile:FlxTile, object:FlxObject, edges:FlxSlopeEdges, grade:FlxSlopeGrade, downV:Float)
	{
		if (checkHitSolidWallY(tile, object, edges))
			return FlxObject.defaultComputeCollisionOverlapY(tile, object);
		
		return computeSlopeOverlapY(tile, object, edges, grade, downV);
	}
	
	inline static var GLUE_SNAP = 2;
	static function computeSlopeOverlapY(tile:FlxTile, object:FlxObject, edges:FlxSlopeEdges, grade:FlxSlopeGrade, downV:Float):Float
	{
		final solidBottom = edges.down;
		final slope = edges.getSlope(grade);
		// b = y intercept in world space
		final b = tile.y + edges.getYIntercept(grade) * tile.height;
		final useLeftCorner = slope > 0 == solidBottom;
		final objX = useLeftCorner ? max(tile.x, object.x) : min(tile.x + tile.width, object.x + object.width);
		
		// classic slope forumla y = mx + b
		final y = slope * (objX - tile.x) + b;
		
		// Check if y intercept is outside of this tile
		final isOutsideTile = (y < tile.y || y > tile.y + tile.height)
			&& (useLeftCorner ? object.x + object.width < tile.x : object.x > tile.x + tile.width);
		
		// check bottom
		if (solidBottom)
		{
			// FlxG.watch.removeQuick("down");
			FlxG.watch.addQuick('in.${grade}', '${object.x < tile.x + tile.width && object.x + object.width > tile.x}');
			if (downV > 0 && (object.x < tile.x + tile.width && object.x + object.width > tile.x))
			{
				// final objectLastX = useLeftCorner ? object.last.x : object.last.x + object.width;
				// final lastY = slope * (objectLastX - tile.x) + b;
				// function round(n:Float) { return Math.round(n * 100) / 100; }
				// FlxG.watch.addQuick("down", '${round(object.last.y + object.height + 1)} > ${round(lastY)}');
				// if (object.last.y + object.height + 1 > lastY)
				// {
					object.touching = FLOOR;
					object.velocity.y = downV;
				// }
				// FlxG.watch.addQuick("v", round(object.velocity.y));
			}
			
			if (object.y + object.height > y)
			{
				if (isOutsideTile)
					return 0;
				
				return y - (object.y + object.height);
			}
		}
		else
		{
			if (isOutsideTile)
				return 0;
			
			// check top
			if (object.y < y)
				return y - object.y;
		}
		
		return 0;
	}
	
	// static function solveCollisionSlopeNorthwest(slope:FlxTile, object:FlxObject):Void
	// {
	// 	if (object.x + object.width > slope.x + slope.width + _snapping)
	// 	{
	// 		return;
	// 	}
	// 	// Calculate the corner point of the object
	// 	final objPos = FlxPoint.get();
	// 	objPos.x = Math.floor(object.x + object.width + _snapping);
	// 	objPos.y = Math.floor(object.y + object.height);

	// 	// Calculate position of the point on the slope that the object might overlap
	// 	// this would be one side of the object projected onto the slope's surface
	// 	_slopePoint.x = objPos.x;
	// 	_slopePoint.y = (slope.y + scaledTileHeight) - (_slopePoint.x - slope.x);

	// 	var tileId:Int = slope.index;
	// 	if (checkThinSteep(tileId))
	// 	{
	// 		if (_slopePoint.x - slope.x <= scaledTileWidth / 2)
	// 		{
	// 			return;
	// 		}
	// 		else
	// 		{
	// 			_slopePoint.y = slope.y + scaledTileHeight * (2 - (2 * (_slopePoint.x - slope.x) / scaledTileWidth)) + _snapping;
	// 			if (_downwardsGlue && object.velocity.x > 0)
	// 				object.velocity.x *= 1 - (1 - _slopeSlowDownFactor) * 3;
	// 		}
	// 	}
	// 	else if (checkThickSteep(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + scaledTileHeight * (1 - (2 * ((_slopePoint.x - slope.x) / scaledTileWidth))) + _snapping;
	// 		if (_downwardsGlue && object.velocity.x > 0)
	// 			object.velocity.x *= 1 - (1 - _slopeSlowDownFactor) * 3;
	// 	}
	// 	else if (checkThickGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + (scaledTileHeight - _slopePoint.x + slope.x) / 2;
	// 		if (_downwardsGlue && object.velocity.x > 0)
	// 			object.velocity.x *= _slopeSlowDownFactor;
	// 	}
	// 	else if (checkThinGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + scaledTileHeight - (_slopePoint.x - slope.x) / 2;
	// 		if (_downwardsGlue && object.velocity.x > 0)
	// 			object.velocity.x *= _slopeSlowDownFactor;
	// 	}
	// 	else
	// 	{
	// 		if (_downwardsGlue && object.velocity.x > 0)
	// 			object.velocity.x *= _slopeSlowDownFactor;
	// 	}
	// 	// Fix the slope point to the slope tile
	// 	fixSlopePoint(slope);

	// 	// Check if the object is inside the slope
	// 	if (objPos.x > slope.x + _snapping
	// 		&& objPos.x < slope.x + scaledTileWidth + object.width + _snapping
	// 		&& objPos.y >= _slopePoint.y
	// 		&& objPos.y <= slope.y + scaledTileHeight)
	// 	{
	// 		// Call the collide function for the floor slope
	// 		onCollideFloorSlope(slope, object);
	// 	}
	// }
	
	// static function solveCollisionSlopeNortheast(slope:FlxTile, object:FlxObject):Void
	// {
	// 	if (object.x < slope.x - _snapping)
	// 	{
	// 		return;
	// 	}
	// 	// Calculate the corner point of the object
	// 	_objPoint.x = Math.floor(object.x - _snapping);
	// 	_objPoint.y = Math.floor(object.y + object.height);

	// 	// Calculate position of the point on the slope that the object might overlap
	// 	// this would be one side of the object projected onto the slope's surface
	// 	_slopePoint.x = _objPoint.x;
	// 	_slopePoint.y = (slope.y + scaledTileHeight) - (slope.x - _slopePoint.x + scaledTileWidth);

	// 	var tileId:Int = slope.index;
	// 	if (checkThinSteep(tileId))
	// 	{
	// 		if (_slopePoint.x - slope.x >= scaledTileWidth / 2)
	// 		{
	// 			return;
	// 		}
	// 		else
	// 		{
	// 			_slopePoint.y = slope.y + scaledTileHeight * 2 * ((_slopePoint.x - slope.x) / scaledTileWidth) + _snapping;
	// 		}
	// 		if (_downwardsGlue && object.velocity.x < 0)
	// 			object.velocity.x *= 1 - (1 - _slopeSlowDownFactor) * 3;
	// 	}
	// 	else if (checkThickSteep(tileId))
	// 	{
	// 		_slopePoint.y = slope.y - scaledTileHeight * (1 + (2 * ((slope.x - _slopePoint.x) / scaledTileWidth))) + _snapping;
	// 		if (_downwardsGlue && object.velocity.x < 0)
	// 			object.velocity.x *= 1 - (1 - _slopeSlowDownFactor) * 3;
	// 	}
	// 	else if (checkThickGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + (scaledTileHeight - slope.x + _slopePoint.x - scaledTileWidth) / 2;
	// 		if (_downwardsGlue && object.velocity.x < 0)
	// 			object.velocity.x *= _slopeSlowDownFactor;
	// 	}
	// 	else if (checkThinGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + scaledTileHeight - (slope.x - _slopePoint.x + scaledTileWidth) / 2;
	// 		if (_downwardsGlue && object.velocity.x < 0)
	// 			object.velocity.x *= _slopeSlowDownFactor;
	// 	}
	// 	else
	// 	{
	// 		if (_downwardsGlue && object.velocity.x < 0)
	// 			object.velocity.x *= _slopeSlowDownFactor;
	// 	}
	// 	// Fix the slope point to the slope tile
	// 	fixSlopePoint(slope);
		
	// 	// Check if the object is inside the slope
	// 	if (_objPoint.x > slope.x - object.width - _snapping
	// 		&& _objPoint.x < slope.x + scaledTileWidth + _snapping
	// 		&& _objPoint.y >= _slopePoint.y
	// 		&& _objPoint.y <= slope.y + scaledTileHeight)
	// 	{
	// 		// Call the collide function for the floor slope
	// 		onCollideFloorSlope(slope, object);
	// 	}
	// }
	
	// static function solveCollisionSlopeSouthwest(slope:FlxTile, object:FlxObject):Void
	// {
	// 	// Calculate the corner point of the object
	// 	_objPoint.x = Math.floor(object.x + object.width + _snapping);
	// 	_objPoint.y = Math.ceil(object.y);
		
	// 	// Calculate position of the point on the slope that the object might overlap
	// 	// this would be one side of the object projected onto the slope's surface
	// 	_slopePoint.x = _objPoint.x;
	// 	_slopePoint.y = slope.y + (_slopePoint.x - slope.x);
		
	// 	var tileId:Int = slope.index;
	// 	if (checkThinSteep(tileId))
	// 	{
	// 		if (_slopePoint.x - slope.x <= scaledTileWidth / 2)
	// 		{
	// 			return;
	// 		}
	// 		else
	// 		{
	// 			_slopePoint.y = slope.y - scaledTileHeight * (1 + (2 * ((slope.x - _slopePoint.x) / scaledTileWidth))) - _snapping;
	// 		}
	// 	}
	// 	else if (checkThickSteep(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + scaledTileHeight * 2 * ((_slopePoint.x - slope.x) / scaledTileWidth) - _snapping;
	// 	}
	// 	else if (checkThickGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + scaledTileHeight - (slope.x - _slopePoint.x + scaledTileWidth) / 2;
	// 	}
	// 	else if (checkThinGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + (scaledTileHeight - slope.x + _slopePoint.x - scaledTileWidth) / 2;
	// 	}
		
	// 	// Fix the slope point to the slope tile
	// 	fixSlopePoint(slope);
		
	// 	// Check if the object is inside the slope
	// 	if (_objPoint.x > slope.x + _snapping
	// 		&& _objPoint.x < slope.x + scaledTileWidth + object.width + _snapping
	// 		&& _objPoint.y <= _slopePoint.y
	// 		&& _objPoint.y >= slope.y)
	// 	{
	// 		// Call the collide function for the floor slope
	// 		onCollideCeilSlope(slope, object);
	// 	}
	// }
	
	// static function solveCollisionSlopeSoutheast(slope:FlxTile, object:FlxObject):Void
	// {
	// 	// Calculate the corner point of the object
	// 	_objPoint.x = Math.floor(object.x - _snapping);
	// 	_objPoint.y = Math.ceil(object.y);
		
	// 	// Calculate position of the point on the slope that the object might overlap
	// 	// this would be one side of the object projected onto the slope's surface
	// 	_slopePoint.x = _objPoint.x;
	// 	_slopePoint.y = (slope.y) + (slope.x - _slopePoint.x + scaledTileWidth);
		
	// 	var tileId:Int = slope.index;
	// 	if (checkThinSteep(tileId))
	// 	{
	// 		if (_slopePoint.x - slope.x >= scaledTileWidth / 2)
	// 		{
	// 			return;
	// 		}
	// 		else
	// 		{
	// 			_slopePoint.y = slope.y + scaledTileHeight * (1 - (2 * ((_slopePoint.x - slope.x) / scaledTileWidth))) - _snapping;
	// 		}
	// 	}
	// 	else if (checkThickSteep(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + scaledTileHeight * (2 - (2 * (_slopePoint.x - slope.x) / scaledTileWidth)) - _snapping;
	// 	}
	// 	else if (checkThickGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + scaledTileHeight - (_slopePoint.x - slope.x) / 2;
	// 	}
	// 	else if (checkThinGentle(tileId))
	// 	{
	// 		_slopePoint.y = slope.y + (scaledTileHeight - _slopePoint.x + slope.x) / 2;
	// 	}
		
	// 	// Fix the slope point to the slope tile
	// 	fixSlopePoint(slope);
		
	// 	// Check if the object is inside the slope
	// 	if (_objPoint.x > slope.x - object.width - _snapping
	// 		&& _objPoint.x < slope.x + scaledTileWidth + _snapping
	// 		&& _objPoint.y <= _slopePoint.y
	// 		&& _objPoint.y >= slope.y)
	// 	{
	// 		// Call the collide function for the floor slope
	// 		onCollideCeilSlope(slope, object);
	// 	}
	// }
}

private inline function abs(n:Float)
{
	return n > 0 ? n : -n;
}

private inline function min(a:Float, b:Float)
{
	return a < b ? a : b;
}

private inline function max(a:Float, b:Float)
{
	return a > b ? a : b;
}