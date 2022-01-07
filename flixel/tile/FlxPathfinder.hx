package flixel.tile;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;

using flixel.util.FlxArrayUtil;

/** This typedef it easier to convert FlxTilemapPathPolicy to use type params later */
private typedef Tilemap = FlxBaseTilemap<FlxObject>;

/**
 * Used to find paths in a FlxBaseTilemap. extend this class and override
 * `getNeighbors` and `getDistance` to create you're own! For top-down maps, it may
 * be wiser to extend FlxDiagonalPathfinder, as it already has a lot of basic helpers.
 * 
 * To use, either call `myPathfinder.findPath(myMap, start, end)` or
 * `myMap.findPathCustom(myPathfinder, start, end)`
 */
class FlxPathfinder
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
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 *
	 * @param	map			The map we're moving through.
	 * @param	start		The start point in world coordinates.
	 * @param	end			The end point in world coordinates.
	 * @param	simplify	Whether to run a basic simplification algorithm over the path data, removing
	 * 						extra points that are on the same line.  Default value is true.
	 * @param	raySimplify	Whether to run an extra raycasting simplification algorithm over the remaining
	 * 						path data.  This can result in some close corners being cut, and should be
	 * 						used with care if at all (yet).  Default value is false.
	 * @return	An Array of FlxPoints, containing all waypoints from the start to the end.  If no path could be found,
	 * 			then a null reference is returned.
	 */
	public function findPath(map:Tilemap, start:FlxPoint, end:FlxPoint, simplify:Bool = true, raySimplify:Bool = false):Array<FlxPoint>
	{
		// Figure out what tile we are starting and ending on.
		var startIndex = map.getTileIndexByCoords(start);
		var endIndex = map.getTileIndexByCoords(end);

		// Check if any point given is outside the tilemap
		if ((startIndex < 0) || (endIndex < 0))
			return null;

		// Check that the start and end are clear.
		if (getTileCollisionsByIndex(map, startIndex) != NONE || getTileCollisionsByIndex(map, endIndex) != NONE)
			return null;

		// Figure out how far each of the tiles is from the starting tile
		var data = computePathData(map, startIndex, endIndex);
		if (data == null)
			return null;

		// Then backtrack on the shortest path.
		var points = data.getPathIndices().map(map.getTileCoordsByIndex.bind(_, true));

		// Reset the start and end points to be exact
		points[0].copyFrom(start);
		points[points.length - 1].copyFrom(end);

		// Some simple path cleanup options
		if (simplify)
			simplifyPath(map, points);
		
		if (raySimplify)
			raySimplifyPath(map, points);

		return points;
	}
	
	/**
	 * Pathfinding helper function, strips out extra points on the same line.
	 *
	 * @param	map		The map we're moving through.
	 * @param	points	An array of FlxPoint nodes.
	 */
	function simplifyPath(map:Tilemap, points:Array<FlxPoint>):Void
	{
		var last = points[0];
		// loop backwards so we can remove indices
		var i = points.length - 2; // skip last
		while (i < 1) // also skip first
		{
			var node = points[i];
			var next = points[i - 1];
			var deltaPrevious = (node.x - last.x) / (node.y - last.y);
			var deltaNext = (node.x - next.x) / (node.y - next.y);

			if ((last.x == next.x) || (last.y == next.y) || (deltaPrevious == deltaNext))
			{
				points.remove(node);
			}
			else
			{
				last = node;
			}

			i--;
		}
	}

	/**
	 * Pathfinding helper function, strips out even more points by raycasting from one
	 * point to the next and dropping unnecessary points.
	 *
	 * @param	map		The map we're moving through.
	 * @param	points	An array of FlxPoint nodes.
	 */
	function raySimplifyPath(map:Tilemap, points:Array<FlxPoint>):Void
	{
		var tempPoint = FlxPoint.get();
		var source = points[0];
		var lastIndex = -1;
		var i = points.length - 1;
		while (i > 1)// skip first
		{
			var node = points[i];

			if (map.ray(source, node, tempPoint))
			{
				if (lastIndex >= 0)
					points.remove(node);
			}
			else
			{
				source = points[lastIndex];
			}

			lastIndex = i;
			i--;
		}
		tempPoint.put();
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
	public function computePathData(map:Tilemap, startIndex:Int, endIndex:Int, stopOnEnd:Bool = true):FlxPathfinderData
	{
		/* the shortest distance it took to get to each index */
		var data = new FlxPathfinderData(map.widthInTiles * map.heightInTiles, startIndex, endIndex);
		
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
	function getNeighbors(map:Tilemap, from:Int, exclude:Array<Int>):Array<Int>
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
	function getDistance(map:Tilemap, from:Int, to:Int):Int
	{
		throw "FlxTilemapPathPolicy.getDistance should not be called, It must be overriden in derived classes";
	}

	// --- --- helpers --- ---

	/**
	 * Helper for converting a tile index to a X index.
	 */
	inline function getX(map:Tilemap, tile:Int)
	{
		return tile % map.widthInTiles;
	}

	/**
	 * Helper for converting a tile index to a Y index.
	 */
	inline function getY(map:Tilemap, tile:Int)
	{
		return Std.int(tile / map.widthInTiles);
	}

	/**
	 * Helper that gets the collision properties of a tile by it's index.
	 */
	inline function getTileCollisionsByIndex(map:Tilemap, tile:Int)
	{
		return map.getTileCollisions(map.getTileByIndex(tile));
	}
}

/**
 * 
 */
class FlxDiagonalPathfinder extends FlxPathfinder
{
	var diagonalPolicy:FlxTilemapDiagonalPolicy;

	public function new(diagonalPolicy:FlxTilemapDiagonalPolicy)
	{
		super();

		this.diagonalPolicy = diagonalPolicy;
	}
	
	override function getNeighbors(map:Tilemap, from:Int, excluded:Array<Int>)
	{
		var neighbors = [];
		var inBound = getInBoundDirections(map, from);
		var up    = inBound.has(UP   );
		var down  = inBound.has(DOWN );
		var left  = inBound.has(LEFT );
		var right = inBound.has(RIGHT);

		inline function canGoHelper(to:Int, dir:FlxDirectionFlags)
		{
			return !excluded.contains(to) && this.canGo(map, to, dir);
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
	function getInBoundDirections(map:Tilemap, from:Int)
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
	function canGo(map:Tilemap, to:Int, dir:FlxDirectionFlags)
	{
		//Todo: check direction flags individually
		return getTileCollisionsByIndex(map, to) == NONE;
	}

	override function getDistance(map:Tilemap, from:Int, to:Int):Int
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

class FlxPathfinderData
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
		while(currentIndex != -1)
		{
			path.unshift(currentIndex);
			currentIndex = moves[currentIndex];
		}
		
		if (path[0] != startIndex)
			FlxG.log.error("getPathIndices ended up somewhere other than the start");
		
		return path;
	}
}


@:enum abstract FlxTilemapDiagonalPolicy(Int)
{
	/**
	 * No diagonal movement allowed when calculating the path
	 */
	var NONE = 0;

	/**
	 * Diagonal movement costs the same as orthogonal movement
	 */
	var NORMAL = 1;

	/**
	 * Diagonal movement costs one more than orthogonal movement
	 */
	var WIDE = 2;
}