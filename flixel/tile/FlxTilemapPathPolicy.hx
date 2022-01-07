package flixel.tile;

import flixel.math.FlxPoint;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;
import flixel.FlxObject;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxArrayUtil;

class FlxTilemapPathPolicy
{
	/**
	 * Whether tiles can be excluded on their first successful traversal. 
	 */
	var autoExclude:Bool;

	/**
	 * Creates a FlxTilemapPathPolicy
	 * @param autoExclude Whether tiles can be excluded on their first successful traversal.
	 * Note: You don't need to create a new instances of the same policy for different maps
	 */
	public function new (autoExclude = true)
	{
		this.autoExclude = autoExclude;
	}

	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic! It's pretty brute.
	 *
	 * @param	map			The map we're moving through.
	 * @param	startIndex	The starting tile's map index.
	 * @param	endIndex	The ending tile's map index.
	 * @param	stopOnEnd	Whether to stop at the end or not (default true)
	 * @return	An array of FlxPoint nodes. If the end tile could not be found, then a null Array is returned instead.
	 */
	public function compute(map:FlxBaseTilemap<FlxObject>, startIndex:Int, endIndex:Int, stopOnEnd:Bool = true):FlxTilemapPathData
	{
		/* the shortest distance it took to get to each index */
		var data = new FlxTilemapPathData(map.widthInTiles * map.heightInTiles, startIndex, endIndex);
		
		var neighbors:Array<Int> = [startIndex];
		var foundEnd:Bool = false;
		var excluded = neighbors.copy();

		while (neighbors.length > 0)
		{
			var current = neighbors;
			neighbors = [];

			for (currentIndex in current)
			{
				if (currentIndex == endIndex)
				{
					foundEnd = true;
					if (stopOnEnd)
					{
						neighbors = [];
						break;
					}
				}

				var cellNeighbors = getNeighbors(map, currentIndex, excluded);
				var distanceSoFar = data.distances[currentIndex];
				for (neighbor in cellNeighbors)
				{
					var oldDistance = data.distances[neighbor];
					if (oldDistance >= 0 && distanceSoFar >= oldDistance)
					{
						// Don't even calculate the new distance
						continue;
					}

					var distance = distanceSoFar + getDistance(map, currentIndex, neighbor);
					if (oldDistance < 0 || distance < oldDistance)
					{
						data.distances[neighbor] = distance;
						data.moves[neighbor] = currentIndex;
						neighbors.push(neighbor);
					}
				}
			}

			// exclude to prevent further useless checks
			if (autoExclude && neighbors.length > 0)
			{
				excluded = excluded.concat(neighbors);
			}
		}
		
		if (!foundEnd)
		{
			data = null;
		}

		return data;
	}

	/**
	 * Returns all neighbors this tile can travel to in a single "move".
	 * @param map		The map we're moving through.
	 * @param from		The tile we're moving from.
	 * @param exclude	Tiles that we should avoid
	 * @return A list of tile indices
	 */
	function getNeighbors(map:FlxBaseTilemap<FlxObject>, from:Int, exclude:Array<Int>):Array<Int>
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
	function getDistance(map:FlxBaseTilemap<FlxObject>, from:Int, to:Int):Int
	{
		throw "FlxTilemapPathPolicy.getDistance should not be called, It must be overriden in derived classes";
	}

	// --- --- helpers --- ---

	/**
	 * Helper for converting a tile index to a X index.
	 */
	inline function getX(map:FlxBaseTilemap<FlxObject>, tile:Int)
	{
		return tile % map.widthInTiles;
	}

	/**
	 * Helper for converting a tile index to a Y index.
	 */
	inline function getY(map:FlxBaseTilemap<FlxObject>, tile:Int)
	{
		return Std.int(tile / map.widthInTiles);
	}

	/**
	 * Helper that gets the collision properties of a tile by it's index.
	 */
	inline function getTileCollisionsByIndex(map:FlxBaseTilemap<FlxObject>, tile:Int)
	{
		return map.getTileCollisions(map.getTileByIndex(tile));
	}
}

class FlxTilemapDiagonalPathPolicy extends FlxTilemapPathPolicy
{
	var diagonalPolicy:FlxTilemapDiagonalPolicy;

	public function new(diagonalPolicy:FlxTilemapDiagonalPolicy)
	{
		super();

		this.diagonalPolicy = diagonalPolicy;
	}
	
	override function getNeighbors(map:FlxBaseTilemap<FlxObject>, from:Int, excluded:Array<Int>)
	{
		var neighbors = [];
		var inBound = getInBoundDirections(map, from);
		var up    = inBound.has(UP   );
		var down  = inBound.has(DOWN );
		var left  = inBound.has(LEFT );
		var right = inBound.has(RIGHT);

		inline function canGoHelper(to:Int, dir:FlxDirectionFlags)
		{
			return !FlxArrayUtil.contains(excluded, to) && this.canGo(map, to, dir);
		}

		function addIf(condition:Bool, to:Int, dir:FlxDirectionFlags)
		{
			var condition = condition && canGoHelper(to, dir);
			if (condition)
				neighbors.push(to);
			
			return condition;
		}

		var columns = map.widthInTiles;

		// orthoginals
		up    = addIf(up   , from - columns, UP   );
		down  = addIf(down , from + columns, DOWN );
		left  = addIf(left , from - 1      , LEFT );
		right = addIf(right, from + 1      , RIGHT);

		// diagonals
		if (diagonalPolicy != NONE)
		{
			// only allow diagonal when 2 orthoginals is possible
			addIf(up    && left , from - columns - 1, UP   | LEFT );
			addIf(up    && right, from - columns + 1, UP   | RIGHT);
			addIf(down  && left , from + columns - 1, DOWN | LEFT );
			addIf(down  && right, from + columns + 1, DOWN | RIGHT);
		}

		return neighbors;
	}
	
	/**
	 * Determines which neighbors are inside the maps bounds
	 * @param map	The map we're bound to.
	 * @param from	The tile index we're moving from.
	 * @return DirectionHelper use fields like u,r,d,l or dl
	 */
	function getInBoundDirections(map:FlxBaseTilemap<FlxObject>, from:Int)
	{
		var x = getX(map, from);
		var y = getY(map, from);
		return FlxDirectionFlags.fromBools
		(
			x > 0,
			x < map.widthInTiles - 1,
			y > 0,
			y < map.heightInTiles - 1
		);
	}
	
	/**
	 * Useful If you want to extend this with slight changes.
	 * @param map	The map we're moving through.
	 * @param to	The tile index we're moving from.
	 * @param dir	The direction we came from.
	 */
	function canGo(map:FlxBaseTilemap<FlxObject>, to:Int, dir:FlxDirectionFlags)
	{
		//Todo: check direction flags individually
		return getTileCollisionsByIndex(map, to) == NONE;
	}

	override function getDistance(map:FlxBaseTilemap<FlxObject>, from:Int, to:Int):Int
	{
		if (diagonalPolicy != NONE && (getX(map, from) != getX(map, to)) && (getY(map, from) != getY(map, to)))
		{
			return switch (diagonalPolicy)
			{
				case WIDE: 2;
				case NORMAL: 1;
				case NONE: 0;
			}
		}

		return 1;
	}
}

class FlxTilemapPathData
{
	/** The distance of every tile from the starting position */
	public var distances:Array<Int>;
	
	/** Every index has the tileIndex that reached it first while computing the path. */
	public var moves:Array<Int>;
	
	/** The start index of path. */
	public var startIndex:Int;
	
	/** The end index of path. */
	public var endIndex:Int;
	
	/**
	 * Mainly a helper class for FlxTilemapPathPolicy. Used to store data while the paths
	 * are computed, but also useful for analyzing the data once it's done somputing.
	 * @param mapSize		The total number of tiles in the map
	 * @param startIndex	The start index of the path.
	 * @param endIndex		The end index of the path.
	 */
	public function new (mapSize:Int, startIndex:Int, endIndex:Int)
	{
		distances = [ for (i in 0...mapSize) -1 ];
		distances[startIndex] = 0;
		
		moves = [ for (i in 0...mapSize) -1 ];
		
		this.startIndex = startIndex;
		this.endIndex = endIndex;
	}
	
	/**
	 * If the desired path was successful, this returns the chain the tile indices used
	 * to get there the fastest. If unsuccessful, null is returned.
	 */
	public function getPathIndices():Null<Array<Int>>
	{
		if (endIndex == startIndex)
			return [startIndex, endIndex];
		
		if (moves[endIndex] == -1)
		{
			FlxG.log.warn("Called `getPathIndices` when no valid path was found");
			return null;
		}
		
		var path = new Array<Int>();
		
		// Start at the end, check `moves` iteratively to see the neighbor that reached here first
		var currentIndex = endIndex;
		while(currentIndex != startIndex)
		{
			path.unshift(currentIndex);
			currentIndex = moves[currentIndex];
		}
		
		return path;
	}
}