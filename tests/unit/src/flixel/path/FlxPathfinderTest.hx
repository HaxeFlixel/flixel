package flixel.path;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.path.FlxPathfinder;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.display.BitmapData;

using StringTools;

class FlxPathfinderTest extends FlxTest
{
	static inline var UNIT = 8;
	
	var bigMover:BigMoverPathfinder;
	var map4x4:FlxTilemap;
	var map6x5:FlxTilemap;
	var _start:FlxPoint;
	var _end:FlxPoint;

	@Before
	function before()
	{
		final bitmapData = new BitmapData(UNIT * 16, UNIT);
		bigMover = new BigMoverPathfinder(2, 2);
		
		map4x4 = new FlxTilemap();
		map4x4.loadMapFromCSV(TileData.CSV_4X4, bitmapData, UNIT, UNIT, AUTO);

		map6x5 = new FlxTilemap();
		map6x5.loadMapFromCSV(TileData.CSV_6X5, bitmapData, UNIT, UNIT, AUTO);

		_start = FlxPoint.get();
		_end = FlxPoint.get();
	}

	@Test
	function testFindPath()
	{
		// no diagonal, no simplify
		assertFindPath(map4x4, start(0, 0), end(2, 0), NONE, NONE, [0,4,8,12,13,14,15,11,7,3,2]);

		// simplify
		assertFindPath(map4x4, start(0, 0), end(2, 0), LINE, NONE, [0,12,15,3,2]);

		// diagonal
		assertFindPath(map4x4, start(0, 0), end(2, 0), NONE, NORMAL, [0,4,8,13,14,15,11,7,2]);

		// diagonal, simplify
		assertFindPath(map4x4, start(0, 0), end(2, 0), LINE, NORMAL, [0,8,13,15,7,2]);

		// impossible to leave start
		assertFindPath(map4x4, start(1, 0), end(2, 0), LINE, NORMAL, null);

		// impossible to reach end
		assertFindPath(map4x4, start(0, 0), end(1, 0), LINE, NORMAL, null);
	}
	
	
	@Test // custom pathfinder
	function testCustomPathfinder()
	{
		// no diagonal, no simplify
		assertCustomFindPath(map6x5, start(0, 0), end(4, 0), NONE, NONE, [0,6,12,18,19,20,21,22,16,10,4]);

		// simplify
		assertCustomFindPath(map6x5, start(0, 0), end(4, 0), LINE, NONE, [0,18,22,4]);

		// diagonal
		assertCustomFindPath(map6x5, start(0, 0), end(4, 0), NONE, NORMAL, [0,6,12,19,20,21,22,16,10,4]);

		// diagonal, simplify
		assertCustomFindPath(map6x5, start(0, 0), end(4, 0), LINE, NORMAL, [0,12,19,22,4]);

		// impossible to leave start
		assertCustomFindPath(map6x5, start(1, 0), end(4, 0), LINE, NORMAL, null);

		// impossible to reach end
		assertCustomFindPath(map6x5, start(0, 0), end(5, 0), LINE, NORMAL, null);
	}

	function assertFindPath(map:FlxTilemap, start:FlxPoint, end:FlxPoint, simplify:FlxPathSimplifier = LINE,
		diagonal:FlxTilemapDiagonalPolicy = NORMAL, expected:Array<Int>, ?info:PosInfos)
	{
		var points = map.findPath(start, end, simplify, diagonal);
		FlxAssert.arraysEqual(expected, pointsToIndices(map, points), info);
	}
	
	function assertCustomFindPath(map:FlxTilemap, start:FlxPoint, end:FlxPoint, simplify:FlxPathSimplifier = LINE,
		diagonal:FlxTilemapDiagonalPolicy = NORMAL, expected:Array<Int>, ?info:PosInfos)
	{
		bigMover.diagonalPolicy = diagonal;
		var points = map.findPathCustom(bigMover, start, end, simplify);
		FlxAssert.arraysEqual(expected, pointsToIndices(map, points), info);
	}
	
	function pointsToIndices(map:FlxTilemap, points:Array<FlxPoint>, put:Bool = true)
	{
		if (points == null)
			return null;
		
		var indices = new Array<Int>();
		var i = points.length;
		while (i-- > 0)
		{
			indices.unshift(map.getTileIndexByCoords(points[i]));
			if (put)
				points.pop().put();
		}
		return indices;
	}
	
	inline function getTilePos(point:FlxPoint, x:Int, y:Int)
	{
		return point.set(UNIT * (x + 0.5), UNIT * (y + 0.5));
	}
	
	inline function start(x:Int, y:Int)
	{
		return getTilePos(_start, x, y);
	}
	
	inline function end(x:Int, y:Int)
	{
		return getTilePos(_end, x, y);
	}
}

class TileData
{
	public static inline var CSV_4X4
		= "0,1,0,0\n"
		+ "0,1,0,0\n"
		+ "0,0,1,0\n"
		+ "0,0,0,0\n"
		;

	public static inline var CSV_6X5  
		= "0,0,1,1,0,0\n"
		+ "0,0,1,1,0,0\n"
		+ "0,0,0,1,0,0\n"
		+ "0,0,0,0,0,0\n"
		+ "0,0,0,0,0,0\n"
		;
}


class BigMoverPathfinder extends FlxDiagonalPathfinder
{
	public var widthInTiles:Int;
	public var heightInTiles:Int;

	public function new(widthInTiles:Int, heightInTiles:Int, diagonalPolicy:FlxTilemapDiagonalPolicy = NONE)
	{
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		super(diagonalPolicy);
	}

	override function getInBoundDirections(data:FlxPathfinderData, from:Int)
	{
		var x = data.getX(from);
		var y = data.getY(from);
		return FlxDirectionFlags.fromBools
		(
			x > 0,
			x < data.map.widthInTiles - widthInTiles,
			y > 0,
			y < data.map.heightInTiles - heightInTiles
		);
	}

	override function canGo(data:FlxPathfinderData, to:Int, dir:FlxDirectionFlags = ANY)
	{
		final cols = data.map.widthInTiles;

		for (x in 0...widthInTiles)
		{
			for (y in 0...heightInTiles)
			{
				if (!super.canGo(data, to + x + (y * cols), dir))
					return false;
			}
		}

		return true;
	}

	override function hasValidInitialData(data:FlxPathfinderData):Bool
	{
		final cols = data.map.widthInTiles;
		final maxX = data.map.widthInTiles - widthInTiles;
		final maxY = data.map.heightInTiles - heightInTiles;
		return data.hasValidStartEnd()
			&& data.getX(data.startIndex) <= maxX
			&& data.getY(data.startIndex) <= maxY
			&& data.getX(data.endIndex) <= maxX
			&& data.getY(data.endIndex) <= maxY
			&& canGo(data, data.startIndex)
			&& canGo(data, data.endIndex);
	}
}