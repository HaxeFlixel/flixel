package flixel.path;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;

using flixel.util.FlxArrayUtil;

/**
 * Used to find paths in a FlxBaseTilemap.  extend this class and override
 * `getNeighbors` and `getDistance` to create you're own! For top-down maps, it may
 * be wiser to extend FlxDiagonalPathfinder, as it already has a lot of basic helpers.
 * @since 5.0.0
 * 
 * To use, either call `myPathfinder.findPath(myMap, start, end)` or
 * `myMap.findPathCustom(myPathfinder, start, end)`
 */
typedef FlxPathfinder = FlxTypedPathfinder<FlxBaseTilemap<FlxObject>, FlxPathfinderData>;

/**
 * The path data created whenever a `FlxPathfinderData` is used.
 * @since 5.0.0
 */
typedef FlxPathfinderData = FlxTypedPathfinderData<FlxBaseTilemap<FlxObject>>;

/**
 * Typed version of `FlxPathfinder` in case you're using
 * a different `FlxPathfinderData` or FlxTilemap type.
 * @since 5.0.0
 */
class FlxTypedPathfinder<Tilemap:FlxBaseTilemap<FlxObject>, Data:FlxTypedPathfinderData<Tilemap>>
{
	/** Data currently being processed by the pathfinder */
	var createData:FlxPathfinderDataFactory<Tilemap, Data>;

	/**
	 * Creates a FlxTilemapPathPolicy.
	 * 
	 * @param factory     A method to create `FlxTypedPathfinderData` instances.
	 * Note: You don't need to create a new instances of the same policy for different maps.
	 */
	public function new (factory:FlxPathfinderDataFactory<Tilemap, Data>)
	{
		createData = factory;
	}

	/**
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 *
	 * @param map         The map we're moving through.
	 * @param start       The start point in world coordinates.
	 * @param end         The end point in world coordinates.
	 * @param simplify    The simplification method to run on the raw path.  Default value is LINE.
	 * @return An Array of FlxPoints, containing all waypoints from the start to the end.  If no path
	 * could be found, then a null reference is returned.
	 */
	public function findPath(map:Tilemap, start:FlxPoint, end:FlxPoint, simplify:FlxPathSimplifier = LINE):Null<Array<FlxPoint>>
	{
		// Figure out what tile we are starting and ending on.
		var startIndex = map.getTileIndexByCoords(start);
		var endIndex = map.getTileIndexByCoords(end);

		var data = createData(map, startIndex, endIndex);
		var indices = findPathIndicesHelper(data);
		if (indices == null)
			return null;

		var path = getPathPointsFromIndices(data, indices);

		// Reset the start and end points to be exact
		path[0].copyFrom(start);
		path[path.length - 1].copyFrom(end);

		// Some simple path cleanup options
		path = simplifyPath(data, path, simplify);

		data.destroy();

		return path;
	}

	/**
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 *
	 * @param map        The map we're moving through.
	 * @param startIndex The start point in world coordinates.
	 * @param endIndex   The end point in world coordinates.
	 * @return An Array of FlxPoints, containing all waypoints from the start to the end.  If no path could be found,
	 * then a null reference is returned.
	 */
	public inline function findPathIndices(map:Tilemap, startIndex:Int, endIndex:Int)
	{
		final data = createData(map, startIndex, endIndex);
		final indices = findPathIndicesHelper(data);
		data.destroy();
		return indices;
	}

	/**
	 * Helper for findPathIndices, after a data instance is already created.
	 * 
	 * @param data   The pathfinder data for this current search.
	 */
	function findPathIndicesHelper(data:Data)
	{
		// Figure out how far each of the tiles is from the starting tile
		compute(data);
		if (!data.foundEnd)
			return null;

		// Then backtrack on the shortest path.
		return data.getPathIndices();
	}

	function getPathPointsFromIndices(data:Data, indices:Array<Int>)
	{
		// convert indices to world coordinates
		return indices.map(data.map.getTileCoordsByIndex.bind(_, true));
	}

	/**
	 * Pathfinding helper function, strips out extra points on the same line.
	 *
	 * @param data   The pathfinder data for this current search.
	 * @param points An array of FlxPoint nodes.
	 */
	function simplifyPath(data:Data, points:Array<FlxPoint>, simplify:FlxPathSimplifier):Array<FlxPoint>
	{
		switch(simplify)
		{
			case NONE: points;
			case LINE: simplifyLine(data, points);
			case RAY: simplifyRay(data, points);
			case RAY_STEP(resolution): simplifyRayStep(data, points, resolution);
			case RAY_BOX(width, height): simplifyRayBox(data, points, width, height);
			case CUSTOM(method): points = method(cast data, points);
		}
		return points;
	}

	/**
	 * Pathfinding helper function, strips out extra points on the same line.
	 *
	 * @param data   The pathfinder data for this current search.
	 * @param points An array of FlxPoint nodes.
	 */
	function simplifyLine(data:Data, points:Array<FlxPoint>):Void
	{
		// Loop backwards so we can remove indices
		var i = points.length - 1; // Skip last
		while (i-- > 1) // Skip first, too
		{
			var node = points[i];
			var next = points[i + 1];
			var last = points[i - 1];
			var deltaLast = (node.x - last.x) / (node.y - last.y);
			var deltaNext = (node.x - next.x) / (node.y - next.y);

			if ((last.x == next.x) || (last.y == next.y) || (deltaLast == deltaNext))
				points.remove(node);
		}
	}

	/**
	 * Pathfinding helper function, strips out even more points by raycasting from one
	 * point to the next and dropping unnecessary points.
	 *
	 * @param data   The pathfinder data for this current search.
	 * @param points An array of FlxPoint nodes.
	 */
	function simplifyRay(data:Data, points:Array<FlxPoint>):Void
	{
		// A point used to calculate rays
		var tempPoint = FlxPoint.get();

		var i = 1; // Skip first
		while (i < points.length - 1) // Skip last, too
		{
			// If a ray can be drawn from the 2 adjacent points without hitting a wall
			if (data.map.ray(points[i - 1], points[i + 1], tempPoint))
			{
				// Remove the point inbetween
				points.remove(points[i]);
			}
			else
				i++;
		}

		// Put our temp point back in the pool for reuse 
		tempPoint.put();
	}

	/**
	 * Pathfinding helper function, strips out even more points by raycasting from one
	 * point to the next and dropping unnecessary points.
	 *
	 * @param data   The pathfinder data for this current search.
	 * @param points An array of FlxPoint nodes.
	 */
	function simplifyRayBox(data:Data, points:Array<FlxPoint>, width:Float, height:Float):Void
	{
		// subtract from each side or else it's practically unuable in tight squeezes
		width -= 1;
		height -= 1;

		// A point used to calculate rays
		var p1 = FlxPoint.get();
		var p2 = FlxPoint.get();

		var i = 1; // Skip first
		while (i < points.length - 1) // Skip last, too
		{
			p1.copyFrom(points[i - 1]).subtract(width / 2, height / 2);
			p2.copyFrom(points[i + 1]).subtract(width / 2, height / 2);
			// If a ray can be drawn from the 2 adjacent points without hitting a wall
			if (data.map.ray(p1, p2)                               // top left
			&&  data.map.ray(p1.add(width, 0), p2.add(width, 0))   // top right
			&&  data.map.ray(p1.add(0, height), p2.add(0, height)) // bottom right
			&&  data.map.ray(p1.add(-width, 0), p2.add(-width, 0)))// bottom left
			{
				// Remove the point inbetween
				points.remove(points[i]);
			}
			else
				i++;
		}

		// Put our temp point back in the pool for reuse 
		p1.put();
		p2.put();
	}

	/**
	 * Pathfinding helper function, strips out even more points by rayStepping from one
	 * point to the next and dropping unnecessary points.
	 *
	 * @param data       The pathfinder data for this current search.
	 * @param points     An array of FlxPoint nodes.
	 * @param reolution  Defaults to 1, meaning check every tile or so.  Higher means more checks!
	 */
	function simplifyRayStep(data:Data, points:Array<FlxPoint>, resolution:Float):Void
	{
		// A point used to calculate rays
		var tempPoint = FlxPoint.get();

		var i = 1; // Skip first
		while (i < points.length - 1) // Skip last, too
		{
			// If a ray can be drawn from the 2 adjacent points without hitting a wall
			if (data.map.rayStep(points[i - 1], points[i + 1], tempPoint, resolution))
			{
				// Remove the point inbetween
				points.remove(points[i]);
			}
			else
				i++;
		}

		// Put our temp point back in the pool for reuse 
		tempPoint.put();
	}
	
	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic! It's pretty brute.
	 *
	 * @param map        The map we're moving through.
	 * @param startIndex The starting tile's map index.
	 * @param endIndex   The ending tile's map index.
	 * @param stopOnEnd  Whether to stop at the end or not. default true.
	 * @return An array of FlxPoint nodes.  If the end tile could not be found, then a null Array is returned instead.
	 */
	public inline function computePathData(map:Tilemap, startIndex:Int, endIndex:Int, stopOnEnd:Bool = true):Data
	{
		return compute(createData(map, startIndex, endIndex), stopOnEnd);
	}
	
	/**
	 * Actually begins the brute pathfinding process.
	 * 
	 * @param data      The pathfinder data for this current search.
	 * @param stopOnEnd Whether to stop at the end or not. default true.
	 * @return The pathfinder data that was passed in.
	 */
	function compute(data:Data, stopOnEnd:Bool = true):Data
	{
		if (!hasValidInitialData(data))
			return null;

		var current = [data.startIndex];
		while (current.length > 0)
		{
			var neighbors = new Array<Int>();

			// check all the current tiles for new paths
			for (currentIndex in current)
			{
				// Get all traversible neighbors
				var cellNeighbors = getNeighbors(data, currentIndex);
				
				// Compare the distance travelled to get there compared to previous paths
				var distanceSoFar = data.distances[currentIndex];
				for (neighbor in cellNeighbors)
				{
					var oldDistance = data.distances[neighbor];
					if (oldDistance != -1 && distanceSoFar >= oldDistance)
					{
						// Don't even calculate the new distance
						continue;
					}

					// Replace previous paths if this is shorter
					var distance = distanceSoFar + getDistance(data, currentIndex, neighbor);
					if (oldDistance == -1 || distance < oldDistance)
					{
						data.distances[neighbor] = distance;
						// mark moves with the tile we came from
						data.moves[neighbor] = currentIndex;
						neighbors.push(neighbor);
					}
				}
			}

			// exclude to prevent further redundant checks
			for (neighbor in neighbors)
			{
				if (isTileSolved(data, neighbor))
					data.excluded.push(neighbor);
			}

			// check if we're done
			data.foundEnd = isComplete(data);
			if (stopOnEnd && data.foundEnd)
				break;

			// do this again with all the new neighbors
			current = neighbors;
		}
		
		return data;
	}

	/**
	 * Intended to be overriden according to your pathfinder extension's needs.
	 * Returns all neighbors this tile can travel to in a single "move".
	 * 
	 * @param from The tile we're moving from.
	 * @return A list of tile indices.
	 */
	function getNeighbors(data:Data, from:Int):Array<Int>
	{
		throw "FlxTilemapPathPolicy.getNeighbors should not be called, It must be overriden in derived classes";
	}

	/**
	 * Intended to be overriden according to your pathfinder extension's needs.  Otherwise throws an error
	 * 
	 * Determines the weight or value of moving from one tile to another (lower being more valuable).
	 * 
	 * @param from The tile we moved from.
	 * @param to   The tile we moved to.
	 * @return Float used for comparisons in finding the best route.
	 */
	function getDistance(data:Data, from:Int, to:Int):Int
	{
		throw "FlxTilemapPathPolicy.getDistance should not be called, It must be overriden in derived classes";
	}

	/**
	 * Intended to be overriden according to your pathfinder extension's needs.
	 * 
	 * Determines whether the path has found the solution and can stop.  By default it
	 * checks if there is any valid move to the end posiion.  
	 * 
	 * Note: The pathfinder will still continue computing paths if `stopOnEnd` is false.
	 */
	function isComplete(data:Data):Bool
	{
		return data.moves[data.endIndex] != -1;
	}

	/**
	 * Intended to be overriden according to your pathfinder extension's needs.
	 * 
	 * Determines whether the tile has found the shortest path and can be avoided.
	 * By default it returns true.
	 */
	function isTileSolved(data:Data, tile:Int):Bool
	{
		return true;
	}

	/**
	 * Intended to be overriden according to your pathfinder extension's needs.
	 * 
	 * Determines whether the pathfinder should even bother computing paths.  By default it
	 * makes sure the supplied start and end positions are valid and have collision:NONE.
	 */
	function hasValidInitialData(data:Data):Bool
	{
		return data.hasValidStartEnd()
			&& data.getTileCollisionsByIndex(data.startIndex) == NONE
			&& data.getTileCollisionsByIndex(data.endIndex) == NONE;
	}
}

/**
 * A basic implementation of FlxPathfinder that allows for different diagonal policies.
 * @since 5.0.0
 */
class FlxDiagonalPathfinder extends FlxPathfinder
{
	public var diagonalPolicy:FlxTilemapDiagonalPolicy;

	public function new(diagonalPolicy:FlxTilemapDiagonalPolicy = NONE)
	{
		super(FlxPathfinderData.new);

		this.diagonalPolicy = diagonalPolicy;
	}
	
	override function getNeighbors(data:FlxPathfinderData, from:Int)
	{
		var neighbors = [];
		var inBound = getInBoundDirections(data, from);
		var up    = inBound.has(UP   );
		var down  = inBound.has(DOWN );
		var left  = inBound.has(LEFT );
		var right = inBound.has(RIGHT);

		inline function canGoHelper(to:Int, dir:FlxDirectionFlags)
		{
			return !data.isExcluded(to) && this.canGo(data, to, dir);
		}

		function addIf(condition:Bool, to:Int, dir:FlxDirectionFlags)
		{
			var condition = condition && canGoHelper(to, dir);
			if (condition)
				neighbors.push(to);
			
			return condition;
		}

		var columns = data.map.widthInTiles;

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
	 * Determines which neighbors are inside the maps bounds.
	 * 
	 * @param from The tile index we're moving from.
	 * @return Direction flags indicating the direction.
	 */
	function getInBoundDirections(data:FlxPathfinderData, from:Int)
	{
		var x = data.getX(from);
		var y = data.getY(from);
		return FlxDirectionFlags.fromBools
		(
			x > 0,
			x < data.map.widthInTiles - 1,
			y > 0,
			y < data.map.heightInTiles - 1
		);
	}
	
	/**
	 * Useful If you want to extend this with slight changes.
	 * 
	 * @param data The pathfinder data for this current search.
	 * @param to   The tile index we're moving from.
	 * @param dir  The direction we came from.
	 */
	function canGo(data:FlxPathfinderData, to:Int, dir:FlxDirectionFlags = ANY)
	{
		//Todo: check direction flags individually
		return data.getTileCollisionsByIndex(to) == NONE;
	}

	override function getDistance(data:FlxPathfinderData, from:Int, to:Int):Int
	{
		if (diagonalPolicy != NONE && (data.getX(from) != data.getX(to)) && (data.getY(from) != data.getY(to)))
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

/**
 * Usually just FlxPathfinderData.new, but can be any function that takes a map and 2
 * indices and returns whatever FlxPathfinderData you're looking for.
 * @since 5.0.0
 */
typedef FlxPathfinderDataFactory<Tilemap:FlxBaseTilemap<FlxObject>, Data:FlxTypedPathfinderData<Tilemap>>
	= (map:Tilemap, startIndex:Int, endIndex:Int)->Data;

/**
 * The data used by Pathfinders to "solve" a single pathfinding request. A new Instance
 * gets created whenever you request pathfinder computations. Extend this class if your
 * pathfinding needs require special iterative data.
 * @since 5.0.0
 */
@:allow(flixel.path.FlxTypedPathfinder)
class FlxTypedPathfinderData<Tilemap:FlxBaseTilemap<FlxObject>>
{
	/** The start index of path */
	public var startIndex(default, null):Int;

	/** The end index of path */
	public var endIndex(default, null):Int;

	/** The end index of path */
	public var map(default, null):Tilemap;

	/** The distance of every tile from the starting position */
	public var distances(default, null):Array<Int>;

	/** Every index has the tileIndex that reached it first while computing the path */
	public var moves(default, null):Array<Int>;

	/** Every index has the tileIndex that reached it first while computing the path */
	public var excluded(default, null):Array<Int>;

	/** Whether a path from startIndex to endIndex was found */
	public var foundEnd(default, null):Bool;

	#if debug
	public var numChecks = 0;
	#end

	/**
	 * Mainly a helper class for FlxTilemapPathPolicy.  Used to store data while the paths
	 * are computed, but also useful for analyzing the data once it's done somputing.
	 * 
	 * @param mapSize    The total number of tiles in the map
	 * @param startIndex The start index of the path
	 * @param endIndex   The end index of the path
	 */
	public function new (map:Tilemap, startIndex:Int, endIndex:Int)
	{
		this.map = map;
		distances = [ for (i in 0...map.totalTiles) -1 ];
		distances[startIndex] = 0;
		
		moves = [ for (i in 0...map.totalTiles) -1 ];
		
		excluded = [startIndex];
		
		this.startIndex = startIndex;
		this.endIndex = endIndex;
	}
	
	/**
	 * If possible, this returns the tile indices used to get there the fastest.
	 * If impossible, null is returned.
	 */
	public function getPathIndicesTo(index:Int):Null<Array<Int>>
	{
		if (index == startIndex)
			return [startIndex, index];
		
		if (moves[index] == -1)
			return null;
		
		var path = new Array<Int>();
		
		// Start at the end, check `moves` iteratively to see the neighbor that reached here first
		while(index != -1)
		{
			path.unshift(index);
			index = moves[index];
		}
		
		if (path[0] != startIndex)
			FlxG.log.error("getPathIndices ended up somewhere other than the start");
		
		return path;
	}
	
	/**
	 * If the desired start to end path was successful, this returns the tile indices used
	 * to get there the fastest.  If unsuccessful, null is returned.
	 */
	public inline function getPathIndices():Null<Array<Int>>
	{
		return getPathIndicesTo(endIndex);
	}

	public function hasValidStartEnd()
	{
		return startIndex >= 0
			&& endIndex >= 0
			&& startIndex < map.totalTiles
			&& endIndex < map.totalTiles;
	}

	public function destroy()
	{
		map = null;
		distances = null;
		moves = null;
		excluded = null;
	}

	// --- --- helpers --- ---

	/**
	 * Whether the specified index is excluded as a possible path.
	 * Meaning no shorter paths to it can be found.
	 */
	inline function isExcluded(index:Int)
	{
		return excluded.contains(index);
	}

	/**
	 * Helper for converting a tile index to a X index.
	 */
	inline function getX(tile:Int)
	{
		return tile % map.widthInTiles;
	}

	/**
	 * Helper for converting a tile index to a Y index.
	 */
	inline function getY(tile:Int)
	{
		return Std.int(tile / map.widthInTiles);
	}

	/**
	 * Helper that gets the collision properties of a tile by it's index.
	 */
	inline function getTileCollisionsByIndex(tile:Int)
	{
		#if debug numChecks++; #end
		return map.getTileCollisions(map.getTileByIndex(tile));
	}
}

enum FlxPathSimplifier
{
	/**
	 * No simplification
	 */
	NONE;

	/**
	 * Removes nodes that are directly in line with it's neighbors
	 */
	LINE;

	/**
	 * Removes nodes who'with neighbors that have no walls directly blocking
	 * Uses `tilemap.ray`.
	 */
	RAY;

	/**
	 * Removes nodes who'with neighbors that have no walls directly blocking
	 * Uses `tilemap.rayStep`.
	 */
	RAY_STEP(resolution:Float);

	/**
	 * Removes nodes who'with neighbors that have no walls directly
	 * blocking a box of the given size. Assumes centered origin
	 * Uses `tilemap.ray`.
	 */
	RAY_BOX(width:Float, height:Float);

	/**
	 * calls the method to simplify
	 */
	CUSTOM(method:(FlxPathfinderData, Array<FlxPoint>)->Array<FlxPoint>);
}

/**
 * The policy to use with `FlxDiagonalPathfinder`.
 * @since 5.0.0
 */
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