package flixel.tile;

import flixel.FlxObject;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxArrayUtil;

class FlxTilemapPathPolicy<Tile:FlxObject>
{
	/**
	 * Whether tiles can be excluded on their first successful traversal. 
	 */
	public var useSimpleExclusion(default, null):Bool;

	/**
	 * Creates a FlxTilemapPathPolicy
	 * @param useSimpleExclusion Whether tiles can be excluded on their first successful traversal.
	 * Note: You don't need to create a new instances of the same policy for different maps
	 */
	public function new (useSimpleExclusion = true)
	{
		this.useSimpleExclusion = useSimpleExclusion;
	}

	/**
	 * Returns all neighbors this tile can travel to in a single "move".
	 * @param map		The map we're moving through.
	 * @param from		The tile we're moving from.
	 * @param exclude	Tiles that we should avoid
	 * @return A list of tile indices
	 */
	public function getNeighbors(map:FlxBaseTilemap<Tile>, from:Int, ?exclude:Array<Int>):Array<Int>
	{
		throw "FlxTilemapPathPolicy.getNeighbors should not be called, It must be overriden in derived classes";
	}

	/**
	 * Determines the weight or value of moving from one tile to another (lower being more valuable).
	 * @param map	The map we're moving through.
	 * @param from	The tile we moved from.
	 * @param to	The tile we moved to.
	 * @return Float used for comparisons in finding the best route.
	 */
	public function getDistance(map:FlxBaseTilemap<Tile>, from:Int, to:Int):Float
	{
		throw "FlxTilemapPathPolicy.getDistance should not be called, It must be overriden in derived classes";
	}

	/**
	 * Whether or not you've reached the finish. Override this is, say, your object is mutliple tiles big.
	 * @param map	The map we're moving through.
	 * @param tile	The tile to check.
	 * @param end	The actual end tile.
	 * @return Wether you have reached the end.
	 */
	public function isFinished(map:FlxBaseTilemap<Tile>, tile:Int, end:Int):Bool
	{
		return tile == end;
	}

	// --- --- helpers --- ---

	/**
	 * Helper for converting a tile index to a X index.
	 */
	inline function getX(map:FlxBaseTilemap<Tile>, tile:Int)
	{
		return tile % map.widthInTiles;
	}

	/**
	 * Helper for converting a tile index to a Y index.
	 */
	inline function getY(map:FlxBaseTilemap<Tile>, tile:Int)
	{
		return Std.int(tile / map.widthInTiles);
	}

	/**
	 * Helper that gets the collision properties of a tile by it's index.
	 */
	inline function getTileCollisionsByIndex(map:FlxBaseTilemap<Tile>, tile:Int)
	{
		return map.getTileCollisions(map.getTileByIndex(tile));
	}
}

class FlxTilemapDiagonalPathPolicy extends FlxTilemapPathPolicy<FlxObject>
{
	var diagonalPolicy:FlxTilemapDiagonalPolicy;

	public function new(diagonalPolicy:FlxTilemapDiagonalPolicy)
	{
		super();

		this.diagonalPolicy = diagonalPolicy;
	}
	
	override function getNeighbors(map:FlxBaseTilemap<FlxObject>, from:Int, ?excluded:Array<Int>)
	{
		var neighbors = [];
		
		var x = getX(map, from);
		var y = getY(map, from);
		var u = y > 0;
		var d = y < map.heightInTiles - 1;
		var l = x > 0;
		var r = x < map.widthInTiles - 1;

		inline function canGo(to:Int)
		{
			//Todo: check direction flags individually
			return getTileCollisionsByIndex(map, to) == NONE
				&& !FlxArrayUtil.safeContains(excluded, to);
		}

		inline function addIf(condition:Bool, to:Int)
		{
			condition = condition && canGo(to);
			if (condition)
				neighbors.push(to);
			return condition;
		}

		var columns = map.widthInTiles;
		// orthoginals
		var canU = addIf(u, from - columns);
		var canD = addIf(d, from + columns);
		var canL = addIf(l, from - 1);
		var canR = addIf(r, from + 1);

		// diagonals
		if (diagonalPolicy != NONE)
		{
			var length = neighbors.length;
			// only allow diagonal when 2 orthoginals is possible
			addIf(u && l && canU && canL, from - columns - 1);
			addIf(u && r && canU && canR, from - columns + 1);
			addIf(d && l && canD && canL, from + columns - 1);
			addIf(d && r && canD && canR, from + columns + 1);
			if (neighbors.length > length)
				trace('diagonal from:$from to:${neighbors.slice(length)}');
		}

		return neighbors;
	}

	override function getDistance(map:FlxBaseTilemap<FlxObject>, from:Int, to:Int):Float
	{
		if (diagonalPolicy != NONE && (getX(map, from) != getX(map, to)) && (getY(map, from) != getY(map, to)))
		{
			return switch (diagonalPolicy)
			{
				case WIDE: 2.0;
				case NORMAL: 1.0;
				case NONE: 0.0;
			}
		}

		return 1.0;
	}
}

class FlxTilemapPathData
{
	public var distances:Array<Float>;
	public var moves:Array<Int>;
	public var end:Int;
	
	public function new (mapSize:Int)
	{
		distances = [ for (i in 0...mapSize) Math.POSITIVE_INFINITY ];
		moves = [ for (i in 0...mapSize) -1 ];
		end = -1;
	}
}