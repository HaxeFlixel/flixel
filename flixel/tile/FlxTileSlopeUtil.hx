package flixel.tile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.physics.FlxCollider;
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
@:forward(up, down, left, right, has, hasAny, and, toString)
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
	static public function computeCollisionOverlap(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges, grade:FlxSlopeGrade, maxOverlap:Float, ?result:FlxPoint)
	{
		if (grade == NONE)
			return FlxColliderUtil.computeCollisionOverlapAabb(tile, object, maxOverlap, result);
		
		if (result == null)
			result = FlxPoint.get();
		
		final allowX = FlxG.collision.checkCollisionEdgesX(tile, object);
		final allowY = FlxG.collision.checkCollisionEdgesY(tile, object);
		if (!allowX && !allowY)
			return result.set(0, 0);
		
		// only X
		if (allowX && !allowY)
		{
			final overlapX = computeCollisionOverlapX(tile, object, edges, grade);
			return result.set(Math.isFinite(overlapX) ? overlapX : 0, 0);
		}
		
		// only Y
		if (!allowX && allowY)
		{
			final overlapY = computeCollisionOverlapY(tile, object, edges, grade);
			return result.set(0, Math.isFinite(overlapY) ? overlapY : 0);
		}
		
		result.set(computeCollisionOverlapX(tile, object, edges, grade), computeCollisionOverlapY(tile, object, edges, grade));
		
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
	
	static function checkHitSolidWallX(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges)
	{
		final solidCollisions = edges.and(FlxG.collision.getCollisionEdgesX(tile, object));
		return (solidCollisions.right && object.last.x >= tile.x + tile.width)
			|| (solidCollisions.left && object.last.x + object.width <= tile.x);
	}
	
	static function checkHitSolidWallY(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges)
	{
		final solidCollisions = edges.and(FlxG.collision.getCollisionEdgesY(tile, object));
		return (solidCollisions.down && object.last.y >= tile.y + tile.height)
			|| (solidCollisions.up && object.last.y + object.height <= tile.y);
	}
	
	static public function computeCollisionOverlapX(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges, grade:FlxSlopeGrade)
	{
		final overlapY = computeSlopeOverlapY(tile, object, edges, grade);
		// check if they're hitting the solid edges
		if (overlapY != 0 && checkHitSolidWallX(tile, object, edges) && tile.bounds.overlaps(object.bounds))
			return FlxColliderUtil.computeCollisionOverlapXAabb(tile, object);
		
		// let y separate
		return Math.POSITIVE_INFINITY;
	}
	
	static public function computeCollisionOverlapY(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges, grade:FlxSlopeGrade)
	{
		if (checkHitSolidWallY(tile, object, edges) && tile.bounds.overlaps(object.bounds))
			return FlxColliderUtil.computeCollisionOverlapYAabb(tile, object);
		
		return computeSlopeOverlapY(tile, object, edges, grade);
	}
	
	static function computeSlopeOverlapY(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges, grade:FlxSlopeGrade):Float
	{
		final solidBottom = edges.down;
		final slope = edges.getSlope(grade);
		final useLeftCorner = slope > 0 == solidBottom;
		final objX = useLeftCorner ? max(tile.x, object.x) : min(tile.x + tile.width, object.x + object.width);
		
		// classic slope forumla y = mx + b
		final slopeY = getSlopeYAtHelper(tile, objX, slope, edges.getYIntercept(grade));
		
		// Check if y intercept is outside of this tile
		// TODO:
		final isOutsideTile = !tile.bounds.overlaps(object.bounds);
		
		final isOutsideTileY = (slopeY < tile.y || slopeY >= tile.y + tile.height);
		// final isOutsideTile = (slopeY < tile.y || slopeY >= tile.y + tile.height)
		// 	&& (useLeftCorner ? object.x + object.width < tile.x : object.x >= tile.x + tile.width);
		
		if (isOutsideTile)
			return 0;
		
		// check bottom
		if (solidBottom && object.y + object.height > slopeY)
			return slopeY - (object.y + object.height);
		
		if (!solidBottom && object.y < slopeY)
			return slopeY - object.y;
		
		return 0;
	}
	
	
	inline static var GLUE_SNAP = 2;
	// public static function applyGlueDown(tile:FlxTile, object:FlxObject, glueDownVelocity:Float, edges:FlxSlopeEdges, grade:FlxSlopeGrade)
	public static function applyGlueDown(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges, grade:FlxSlopeGrade, glueDownVelocity:Float, snapping = 1.0)
	{
		if (glueDownVelocity <= 0)
			return;
		
		// final slope = edges.getSlope(grade);
		// final b = tile.y + edges.getYIntercept(grade) * tile.height;
		// final isInTile = (object.x < tile.x + tile.width && object.x + object.width > tile.x); 
		// if (glueDownVelocity > 0 && isInTile && FlxG.collision.getCollisionEdgesY(tile, object).up)
		// if (glueDownVelocity > 0 && isInTile && overlap.y < 0)
		// if (isOnSlope(tile, object))
		if (FlxG.collision.getCollisionEdgesY(tile, object).has(UP))
		{
			final slope = edges.getSlope(grade);
			final yInt = edges.getYIntercept(grade) * tile.height;
			// final useLeftCorner = slope > 0;
			// final objectLastX = useLeftCorner ? object.last.x : object.last.x + object.width;
			final objectLastX = slope > 0 ? object.last.x : object.last.x + object.width;
			// final lastY = slope * (objectLastX - tile.x) + b;
			// function round(n:Float) { return Math.round(n * 100) / 100; }
			// FlxG.watch.addQuick("down", '${round(object.last.y + object.height + 1)} > ${round(lastY)}');
			if (object.last.y < getSlopeYAtHelper(tile, objectLastX, slope, yInt))
			{
				object.velocity.y = glueDownVelocity;
				if (isInSlopeHelper(tile, object, edges.down, slope, yInt, snapping))
					object.touching = object.touching.with(FLOOR);
			}
			// FlxG.watch.addQuick("v", round(object.velocity.y));
		}
	}
	
	static function getSlopeYAt(tile:FlxCollider, worldX:Float, edges:FlxSlopeEdges, grade:FlxSlopeGrade)
	{
		return getSlopeYAtHelper(tile, worldX, edges.getSlope(grade), edges.getYIntercept(grade));
	}
	
	static inline function getSlopeYAtHelper(tile:FlxCollider, worldX:Float, slope:Float, yInt:Float)
	{
		return slope * (worldX - tile.x) + tile.y + (yInt * tile.height);
	}
	
	static function isInSlope(tile:FlxCollider, object:FlxCollider, edges:FlxSlopeEdges, grade:FlxSlopeGrade, margin:Float = 0)
	{
		return isInSlopeHelper(tile, object, edges.down, edges.getSlope(grade), edges.getYIntercept(grade), margin);
	}
	
	static inline function isInSlopeHelper(tile:FlxCollider, object:FlxCollider, solidBottom:Bool, slope:Float, yInt:Float, margin:Float = 0)
	{
		final useLeftCorner = slope > 0;
		final objX = useLeftCorner ? object.x : object.x + object.width;
		final slopeY = getSlopeYAtHelper(tile, objX, slope, yInt);
		
		// check bottom
		return solidBottom
			? (object.y + object.height + margin > slopeY)
			: (object.y - margin < slopeY);
	}
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