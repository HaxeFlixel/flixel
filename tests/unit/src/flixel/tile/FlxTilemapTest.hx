package flixel.tile;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.display.BitmapData;
import openfl.errors.ArgumentError;

using StringTools;

// null safety breaks on 4.2
#if (haxe >= version("4.3.0")) @:nullSafety(Strict) #end
class FlxTilemapTest extends FlxTest
{
	var tilemap:FlxTilemap = new FlxTilemap();
	var sampleMapString:String = "";
	var sampleMapArray:Array<Int> = [];

	@Before
	function before()
	{
		tilemap = new FlxTilemap();
		destroyable = tilemap;

		sampleMapString = "0,1,0,1[nl]1,1,1,1[nl]1,0,0,1[nl]";
		sampleMapArray = [
			0, 1, 0, 1,
			1, 1, 1, 1,
			1, 0, 0, 1
		];
	}

	@Test
	function test1x1Map()
	{
		tilemap.loadMapFromCSV("1", getBitmapData(), 8, 8);

		try
		{
			tilemap.draw();
		}
		catch (error:ArgumentError)
		{
			Assert.fail(error.message);
		}

		Assert.areEqual(1, tilemap.getData()[0]);
		Assert.areEqual(1, tilemap.getData(true)[0]);
		Assert.areEqual(1, tilemap.getTileIndex(0));
	}
	
	@Test
	function testLoadMapArray()
	{
		final mapData = 
		[
			0, 1, 0,
			1, 1, 1
		];
		tilemap.loadMapFromArray(mapData, 3, 2, getBitmapData(), 8, 8);
		
		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		FlxAssert.arraysEqual([0, 1, 0, 1, 1, 1], tilemap.getData());
	}
	
	@Test
	function testLoadMap2DArray()
	{
		final mapData =
		[
			[0, 1, 0],
			[1, 1, 1]
		];
		tilemap.loadMapFrom2DArray(mapData, getBitmapData(), 8, 8);
		
		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		FlxAssert.arraysEqual([0, 1, 0, 1, 1, 1], tilemap.getData());
	}
	
	@Test
	function testAutoTiling()
	{
		final mapData = 
		[
			0, 0, 1, 0, 0,
			0, 0, 1, 0, 0,
			0, 1, 1, 1, 1,
			0, 0, 0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 5, 3, getBitmapData(), 8, 8, AUTO);

		Assert.areEqual(5, tilemap.widthInTiles);
		Assert.areEqual(3, tilemap.heightInTiles);
		
		assertSolidData(mapData);
		assertData
		([
			0, 0, 6,  0,  0,
			0, 0, 6,  0,  0,
			0, 3, 12, 11, 11,
			0, 0, 0,  0,  0
		]);
		
		tilemap.setTileIndex(2, 0);
		
		assertSolidData
		([
			0, 0, 0, 0, 0,
			0, 0, 1, 0, 0,
			0, 1, 1, 1, 1,
			0, 0, 0, 0, 0
		]);
		
		assertData
		([
			0, 0, 0,  0,  0,
			0, 0, 5,  0,  0,
			0, 3, 12, 11, 11,
			0, 0, 0,  0,  0
		]);
	}
	
	function assertSolidData(expected:Array<Int>, ?msg:String, ?info:PosInfos)
	{
		FlxAssert.arraysEqual(expected, tilemap.getData(true), msg, info);
	}
	
	function assertData(expected:Array<Int>, ?msg:String, ?info:PosInfos)
	{
		FlxAssert.arraysEqual(expected, tilemap.getData(false), msg, info);
	}
	
	@Test
	@:haxe.warning("-WDeprecated")
	function testLoadMapFromGraphic()
	{
		var map = new BitmapData(2, 2);
		map.setPixel32(0, 0, FlxColor.WHITE);
		map.setPixel32(1, 0, FlxColor.BLACK);
		map.setPixel32(0, 1, FlxColor.BLUE);
		map.setPixel32(1, 1, FlxColor.YELLOW);

		tilemap.loadMapFromGraphic(map, false, 1, [FlxColor.WHITE, FlxColor.BLACK, FlxColor.BLUE, FlxColor.YELLOW], new BitmapData(4, 1));
		FlxAssert.arraysEqual([0, 1, 2, 3], tilemap.getData());
	}

	@Test
	function testLoadMapFromCSVWindowsNewlines()
	{
		testLoadMapFromCSVWithNewline(sampleMapString, "\r\n");
	}

	@Test
	function testLoadMapFromCSVUnixNewlines()
	{
		testLoadMapFromCSVWithNewline(sampleMapString, "\n");
	}

	@Test // #1375
	function testLoadMapFromCSVMacNewlines()
	{
		testLoadMapFromCSVWithNewline(sampleMapString, "\r");
	}

	@Test // #1511
	function testLoadMapInvalidGraphicPathNoCrash()
	{
		tilemap.loadMapFromArray([1], 1, 1, "assets/invalid");
	}

	@Test // #1546
	@:haxe.warning("-WDeprecated")
	function testOffMapOverlap()
	{
		tilemap.loadMapFrom2DArray([[1], [0]], getBitmapData(), 8, 8);
		var sprite = new FlxSprite(-2, 10);
		Assert.isFalse(tilemap.overlapsWithCallback(sprite));
	}
	
	@Test // #1546
	// same as testOffMapOverlap but with objectOverlapsTiles
	function testOffMapOverlap2()
	{
		tilemap.loadMapFrom2DArray([[1], [0]], getBitmapData(), 8, 8);
		final obj = new FlxObject(-10, 10, 8, 8);
		Assert.isFalse(tilemap.objectOverlapsTiles(obj));
		
		obj.x = 8;
		obj.y = 8;
		Assert.isFalse(tilemap.objectOverlapsTiles(obj));
	}

	@Test // #1550
	function testLoadMapFromCSVTrailingNewline()
	{
		testLoadMapFromCSVWithNewline(sampleMapString + "[nl]", "\n");
	}

	function testLoadMapFromCSVWithNewline(csv:String, newlines:String)
	{
		tilemap.loadMapFromCSV(csv.replace("[nl]", newlines), getBitmapData(), 8, 8);

		Assert.areEqual(4, tilemap.widthInTiles);
		Assert.areEqual(3, tilemap.heightInTiles);
		FlxAssert.arraysEqual(sampleMapArray, tilemap.getData());
	}

	@Test // #1617
	function testRayEmpty()
	{
		var mapData = [0, 0, 0]; // 3x1
		tilemap.loadMapFromArray(mapData, 3, 1, getBitmapData(), 8, 8);

		Assert.isTrue(tilemap.ray(new FlxPoint(0, tilemap.height / 2), new FlxPoint(tilemap.width, tilemap.height / 2)));
	}

	@Test // #1617
	function testRayStraight()
	{
		var mapData = [0, 1, 0]; // 3x1 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 1, getBitmapData(), 8, 8);

		Assert.isFalse(tilemap.ray(new FlxPoint(0, tilemap.height / 2), new FlxPoint(tilemap.width, tilemap.height / 2)));
	}

	@Test // #1617
	function testRayImperfectDiagonal()
	{
		var mapData = [0, 0, 0, 0, 1, 0, 0, 0, 0]; // 3x3 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);

		Assert.isFalse(tilemap.ray(new FlxPoint(0, 0), new FlxPoint(tilemap.width - tilemap.width / 8, tilemap.height)));
	}

	@Test // #1617
	function testRayPerfectDiagonal()
	{
		var mapData = [0, 0, 0, 0, 1, 0, 0, 0, 0]; // 3x3 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);

		Assert.isFalse(tilemap.ray(new FlxPoint(0, 0), new FlxPoint(tilemap.width, tilemap.height)));
	}

	@Test // #1617
	function testRayAdvanced()
	{
		var mapData = [
			0, 0, 0,
			0, 1, 0,
			0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		
		final startP = FlxPoint.get();
		final endP = FlxPoint.get();
		
		function assertRay(expected:FlxRayResult, start:FlxPoint, end:FlxPoint, checkDir = true, ?msg:String, ?pos:PosInfos)
		{
			final actual = tilemap.rayAdvanced(start, end, checkDir);
			if (actual.equals(expected))
				Assert.assertionCount++;
			else if (msg != null)
				Assert.fail(msg, pos);
			else
				Assert.fail('Expected rayAdvanced($start, $end, $checkDir)to be ${resultToString(expected)}, got ${resultToString(actual)}', pos);
		}
		
		inline function getPos(index:Int, result:FlxPoint)
		{
			if (tilemap.getTilePos(index, true, result) == null)
				throw 'Expected valid tile at index $index';
			
			return result;
		}
		inline function setStart(index:Int) return getPos(index, startP);
		inline function setEnd  (index:Int) return getPos(index, endP  );
		
		function assertRayStopped(start:FlxPoint, end:FlxPoint, checkDir = true, ?msg:String, ?pos:PosInfos)
		{
			// Test start and end verbatim, then offset x and test again to ensure both pure-vertical and sloped tests
			final result = tilemap.rayAdvanced(start, end, checkDir);
			if (result.match(STOPPED(_, _, _, _)))
				Assert.assertionCount++;
			else if (msg != null)
				Assert.fail(msg, pos);
			else
				Assert.fail('Expected rayAdvanced($start, $end, $checkDir) to be STOPPED', pos);
		}
		
		function assertRayNotStopped(start:FlxPoint, end:FlxPoint, checkDir = true, ?msg:String, ?pos:PosInfos)
		{
			assertRay(END, start, end, checkDir, 'Expected rayAdvanced($start, $end, $checkDir) to be NOT STOPPED', pos);
		}
		
		tilemap.setTileProperties(1, ANY);
		
		final tl = 0; final tc = 1; final tr = 2;
		final lc = 3; final c  = 4; final rc = 5;
		final bl = 6; final bc = 7; final br = 8;
		
		assertRayNotStopped(setStart(tl), setEnd(tr));
		assertRayNotStopped(setStart(tr), setEnd(tl));
		assertRayNotStopped(setStart(tl), setEnd(bl));
		assertRayNotStopped(setStart(bl), setEnd(tl));
		assertRayNotStopped(setStart(bl), setEnd(br));
		assertRayNotStopped(setStart(br), setEnd(bl));
		assertRayNotStopped(setStart(tr), setEnd(br));
		assertRayNotStopped(setStart(br), setEnd(tr));
		
		// For all purely vertical tests, also check at a slight angle, since the code is different
		assertRayNotStopped(setStart(tl).subtract(1, 0), setEnd(bl));
		assertRayNotStopped(setStart(bl).subtract(1, 0), setEnd(tl));
		assertRayNotStopped(setStart(tr).subtract(1, 0), setEnd(br));
		assertRayNotStopped(setStart(br).subtract(1, 0), setEnd(tr));
		
		function testDirections(allowCollisions:FlxDirectionFlags, ?pos)
		{
			tilemap.setTileProperties(1, allowCollisions);
			function assertRaySimplified(dir:FlxDirection, x, y, start, end, label:String, ?pos)
			{
				final expected = allowCollisions.has(dir) ? STOPPED(c, x, y, EDGE(dir)) : END;
				final actual = tilemap.rayAdvanced(setStart(start), setEnd(end), true);
				if (actual.equals(expected))
					Assert.assertionCount++;
				else
					Assert.fail('Expected rayAdvanced[$label]($startP, $endP) '
						+ 'to be ${resultToString(expected)}, got ${resultToString(actual)}', pos);
			}
			
			// check pure vertical and horizontal
			assertRaySimplified(LEFT ,  8, 12, lc, rc, "L->R", pos);
			assertRaySimplified(RIGHT, 16, 12, rc, lc, "R->L", pos);
			assertRaySimplified(UP   , 12,  8, tc, bc, "T->B", pos);
			assertRaySimplified(DOWN, 12, 16, bc, tc, "B->T", pos);
			
			// then check at various slopes
			assertRaySimplified(UP  , 14,  8, tc, br, "T->BR", pos);
			assertRaySimplified(UP  , 10,  8, tc, bl, "T->BL", pos);
			assertRaySimplified(DOWN, 14, 16, bc, tr, "B->TR", pos);
			assertRaySimplified(DOWN, 10, 16, bc, tl, "B->TL", pos);
		}
		
		testDirections(ANY);
		testDirections(ANY.without(LEFT ));
		testDirections(ANY.without(RIGHT));
		testDirections(ANY.without(UP   ));
		testDirections(ANY.without(DOWN ));
		testDirections(LEFT .with(RIGHT));
		testDirections(LEFT .with(UP   ));
		testDirections(LEFT .with(DOWN ));
		testDirections(RIGHT.with(UP   ));
		testDirections(RIGHT.with(DOWN ));
		testDirections(DOWN .with(UP   ));
		testDirections(LEFT );
		testDirections(RIGHT);
		testDirections(UP   );
		testDirections(DOWN );
		testDirections(NONE);
		
		// checkDir:false (always a hit if the tile allows any conditions)
		tilemap.setTileProperties(1, UP);
		
		// check pure vertical and horizontal
		assertRay(STOPPED(c,  8, 12, EDGE(LEFT )), setStart(lc), setEnd(rc), false);
		assertRay(STOPPED(c, 16, 12, EDGE(RIGHT)), setStart(rc), setEnd(lc), false);
		assertRay(STOPPED(c, 12,  8, EDGE(UP   )), setStart(tc), setEnd(bc), false);
		assertRay(STOPPED(c, 12, 16, EDGE(DOWN )), setStart(bc), setEnd(tc), false);
		
		// then check at various slopes
		assertRay(STOPPED(c, 14,  8, EDGE(UP  )), setStart(tc), setEnd(br), false);
		assertRay(STOPPED(c, 10,  8, EDGE(UP  )), setStart(tc), setEnd(bl), false);
		assertRay(STOPPED(c, 14, 16, EDGE(DOWN)), setStart(bc), setEnd(tr), false);
		assertRay(STOPPED(c, 10, 16, EDGE(DOWN)), setStart(bc), setEnd(tl), false);
	}
	
	function resultToString(result:FlxRayResult)
	{
		return switch result
		{
			case STOPPED(index, x, y, EDGE(dir)): 'STOPPED($index, $x, $y, EDGE($dir))';
			default: Std.string(result);
		}
	}

	@Test
	function testNegativeIndicesTreatedAsZero()
	{
		tilemap.loadMapFromCSV("-1,1", getBitmapData(), 8, 8);
		FlxAssert.arraysEqual([0, 1], tilemap.getData());
		
		Assert.areEqual(0, tilemap.getTileIndex(0));
	}

	@Test // #1520
	function testLoadMapFromCSVTrailingComma()
	{
		tilemap.loadMapFromCSV("1,", getBitmapData(), 8, 8);
		FlxAssert.arraysEqual([1], tilemap.getData());
	}

	@Test
	function testLoadMapFromCSVInvalidIndices()
	{
		var exceptionThrown = false;
		try
		{
			tilemap.loadMapFromCSV("1,f,1", getBitmapData(), 8, 8);
		}
		catch (e:Dynamic)
		{
			exceptionThrown = true;
		}

		Assert.isTrue(exceptionThrown);
	}

	@Test // #1835
	function testOverlapsPointCrash()
	{
		tilemap.loadMapFromCSV("1,", getBitmapData(), 8, 8);
		var point = FlxPoint.get(1000, 1000);
		Assert.isFalse(tilemap.overlapsPoint(point, false));
		Assert.isFalse(tilemap.overlapsPoint(point, true));
	}

	@Test // #2024
	function testOverlapsPointOutOfBounds()
	{
		tilemap.loadMapFrom2DArray([[1]], new BitmapData(2, 1));
		function overlaps(x, y)
			return tilemap.overlapsPoint(FlxPoint.get(x, y));
		
		Assert.isFalse(overlaps(-1, -1));
		Assert.isTrue(overlaps(0, 0));
		Assert.isFalse(overlaps(1, 1));
	}
	
	@Test // #3158
	function testIsOverlappingTile()
	{
		final mapData =
		[
			0, 0, 0,
			0, 1, 0,
			0, 0, 0
		]; // 3x3 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		
		final obj = new FlxObject(4, 12, 8, 8);
		var count = 0;
		final result = tilemap.isOverlappingTile(obj, (tile)->{ count++; return tile.solid; } );
		// should be touching bottom-left 4 tiles only
		Assert.isTrue(result);
		// wont need to check all 4 before finding
		Assert.areEqual(2, count);
		
		// test position
		count = 0;
		final result = tilemap.isOverlappingTile(obj, (tile)->{ count++; return tile.solid; }, FlxPoint.get(0, 8));
		// should be touching top-left 4 tiles only
		Assert.isTrue(result);
		Assert.areEqual(4, count);
	}
	
	@Test
	function testWallLeft()
	{
		final mapData = [
			1, 0, 0,
			1, 0, 0,
			1, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		
		final obj = new FlxObject(0, 0, 8, 8);
		
		// move up-left towards a left wal, make sure we only separate on the X
		for (i in 0...40)
		{
			// check a bunch of locations
			obj.x = 4;
			obj.y = 4 + (i / 10);
			obj.touching = NONE;
			obj.last.set(12, obj.y + 8);
			FlxG.collide(tilemap, obj);
			
			final result = obj.touching.toString();
			Assert.areEqual(LEFT.toString(), result, 'Value [$result] was not equal to expected value [L] on i=$i');
		}
	}
	
	@Test
	function testWallRight()
	{
		final mapData = [
			0, 0, 1,
			0, 0, 1,
			0, 0, 1
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		
		final obj = new FlxObject(0, 0, 8, 8);
		
		// move up-right towards a right wall, make sure we only separate on the X
		for (i in 0...40)
		{
			// check a bunch of locations
			obj.x = 12;
			obj.y = 4 + (i / 10);
			obj.touching = NONE;
			obj.last.set(4, obj.y + 8);
			FlxG.collide(tilemap, obj);
			
			final result = obj.touching.toString();
			Assert.areEqual(RIGHT.toString(), result, 'Value [$result] was not equal to expected value [R] on i=$i');
		}
	}
	
	@Test
	function testWallTop()
	{
		final mapData = [
			1, 1, 1,
			0, 0, 0,
			0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		
		final obj = new FlxObject(0, 0, 8, 8);
		
		// move up-left towards a ceiling, make sure we only separate on the Y
		for (i in 0...40)
		{
			// check a bunch of locations
			obj.x = 4 + (i / 10);
			obj.y = 4;
			obj.touching = NONE;
			obj.last.set(obj.x + 8, 12);
			FlxG.collide(tilemap, obj);
			
			final result = obj.touching.toString();
			Assert.areEqual(UP.toString(), result, 'Value [$result] was not equal to expected value [U] on i=$i');
		}
	}
	
	@Test
	function testWallBottom()
	{
		final mapData = [
			0, 0, 0,
			0, 0, 0,
			1, 1, 1
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		
		final obj = new FlxObject(0, 0, 8, 8);
		
		// move down-right towards a floor, make sure we only separate on the Y
		for (i in 0...40)
		{
			// check a bunch of locations
			obj.x = 12 - (i / 10);
			obj.y = 12;
			obj.touching = NONE;
			obj.last.set(obj.x - 8, 4);
			FlxG.collide(tilemap, obj);
			
			final result = obj.touching.toString();
			Assert.areEqual(DOWN.toString(), result, 'Value [$result] was not equal to expected value [D] on i=$i');
		}
	}
	
	@Test
	function testMapIndex()
	{
		final mapData = [
			0, 0, 0,
			0, 1, 0,
			0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		tilemap.x += 10;
		tilemap.y += 20;
		tilemap.scale.set(2, 2);
		
		Assert.areEqual(16, tilemap.scaledTileWidth);
		Assert.areEqual(16, tilemap.scaledTileHeight);
		Assert.areEqual(16, tilemap.getTileWidth());
		Assert.areEqual(16, tilemap.getTileHeight());
		
		final size = 16;
		final half = 8;
		
		Assert.areEqual(tilemap.getTileIndex(4), tilemap.getTileIndex(1, 1));
		Assert.areEqual(1, tilemap.getTileIndex(4));
		Assert.areEqual(2, tilemap.getColumn(8));
		Assert.areEqual(2, tilemap.getRow(8));
		
		Assert.areEqual(-1, tilemap.getMapIndex(1000, 1));
		Assert.areEqual(-1, tilemap.getTileIndex(1000, 1));
		Assert.areEqual(8, tilemap.getMapIndexAt(10 + 2 * size + half, 20 + 2 * size + half));
		Assert.areEqual(0, tilemap.getTileIndexAt(10 + 2 * size + half, 20 + 2 * size + half));
		Assert.areEqual(-1, tilemap.getTileIndexAt(10 + 1000 * size + half, 20 + 2 * size + half));
		
		Assert.areEqual(tilemap.getTileData(4), tilemap.getTileData(1, 1));
		Assert.areEqual(tilemap.getTileData(1, 1), tilemap.getTileDataAt(10 + 1 * size + half, 20 + 1 * size + half));
	}
	
	function testGetColumnRowAt()
	{
		
		final mapData = [
			0, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 0, 0,
		];
		tilemap.y += 10;
		tilemap.loadMapFromArray(mapData, 4, 3, getBitmapData(), 8, 8);
		
		Assert.areEqual(tilemap.getColumnAt(24, true), tilemap.getColumnAt(24, false));
		Assert.areEqual(3, tilemap.getColumnAt(24));
		Assert.areNotEqual(tilemap.getColumnAt(32, true), tilemap.getColumnAt(32, false));
		Assert.areEqual(4, tilemap.getColumnAt(32, true));
		Assert.areEqual(5, tilemap.getColumnAt(32, false));
		
		Assert.areEqual(tilemap.getRowAt(10 + 16, true), tilemap.getRowAt(10 + 16, false));
		Assert.areEqual(2, tilemap.getRowAt(10 + 16));
		Assert.areNotEqual(tilemap.getRowAt(10 + 24, true), tilemap.getRowAt(10 + 24, false));
		Assert.areEqual(3, tilemap.getRowAt(10 + 24, true));
		Assert.areEqual(4, tilemap.getRowAt(10 + 24, false));
	}
	
	@Test
	function testGetColumnRowPosAt()
	{
		final mapData = [
			0, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 0, 0,
		];
		tilemap.x += 10;
		tilemap.y += 20;
		tilemap.loadMapFromArray(mapData, 4, 3, getBitmapData(), 8, 8);
		
		Assert.areEqual(10 + 24    , tilemap.getColumnPosAt(10 + 24));
		Assert.areEqual(10 + 32    , tilemap.getColumnPosAt(10 + 32    , false));
		Assert.areEqual(10 + 32 + 4, tilemap.getColumnPosAt(10 + 32    , true));
		Assert.areEqual(10 + 32    , tilemap.getColumnPosAt(10 + 32 + 4, false));
		Assert.areEqual(10 + 32 + 4, tilemap.getColumnPosAt(10 + 32 + 4, true));
		
		Assert.areEqual(20 + 16    , tilemap.getRowPosAt(20 + 16));
		Assert.areEqual(20 + 24    , tilemap.getRowPosAt(20 + 24    , false));
		Assert.areEqual(20 + 24 + 4, tilemap.getRowPosAt(20 + 24    , true));
		Assert.areEqual(20 + 24    , tilemap.getRowPosAt(20 + 24 + 4, false));
		Assert.areEqual(20 + 24 + 4, tilemap.getRowPosAt(20 + 24 + 4, true));
	}
	
	@Test
	function testColumnRowPos()
	{
		tilemap.loadMapFromArray(sampleMapArray, 4, 3, getBitmapData(), 8, 8);
		tilemap.x = 10;
		tilemap.y = 20;
		tilemap.scale.set(2, 2);
		
		final size = 16;
		final half = 8;
		
		Assert.areEqual(0, tilemap.getColumnAt(tilemap.getColumnPos(0)));
		Assert.areEqual(1, tilemap.getColumnAt(tilemap.getColumnPos(1)));
		Assert.areEqual(2, tilemap.getColumnAt(tilemap.getColumnPos(2)));
		Assert.areEqual(3, tilemap.getColumnAt(tilemap.getColumnPos(3)));
		Assert.areEqual(0, tilemap.getColumnAt(10 + 0 * size));
		Assert.areEqual(1, tilemap.getColumnAt(10 + 1 * size));
		Assert.areEqual(2, tilemap.getColumnAt(10 + 2 * size));
		Assert.areEqual(3, tilemap.getColumnAt(10 + 3 * size));
		Assert.areEqual(0, tilemap.getColumnAt(10 + 0 * size + half));
		Assert.areEqual(1, tilemap.getColumnAt(10 + 1 * size + half));
		Assert.areEqual(2, tilemap.getColumnAt(10 + 2 * size + half));
		Assert.areEqual(3, tilemap.getColumnAt(10 + 3 * size + half));
		Assert.areEqual(1000, tilemap.getColumnAt(tilemap.getColumnPos(1000)));
		Assert.areEqual(10 + 3 * size, tilemap.getColumnPos(3));
		Assert.areEqual(10 + 3 * size + half, tilemap.getColumnPos(3, true));
		Assert.areEqual(10 + 1000 * size, tilemap.getColumnPos(1000));
		
		Assert.areEqual(0, tilemap.getRowAt(tilemap.getRowPos(0)));
		Assert.areEqual(1, tilemap.getRowAt(tilemap.getRowPos(1)));
		Assert.areEqual(2, tilemap.getRowAt(tilemap.getRowPos(2)));
		Assert.areEqual(0, tilemap.getRowAt(20 + 0 * size));
		Assert.areEqual(1, tilemap.getRowAt(20 + 1 * size));
		Assert.areEqual(2, tilemap.getRowAt(20 + 2 * size));
		Assert.areEqual(0, tilemap.getRowAt(20 + 0 * size + half));
		Assert.areEqual(1, tilemap.getRowAt(20 + 1 * size + half));
		Assert.areEqual(2, tilemap.getRowAt(20 + 2 * size + half));
		Assert.areEqual(1000, tilemap.getRowAt(tilemap.getRowPos(1000)));
		Assert.areEqual(20 + 2 * size, tilemap.getRowPos(2));
		Assert.areEqual(20 + 2 * size + half, tilemap.getRowPos(2, true));
		Assert.areEqual(20 + 1000 * size, tilemap.getRowPos(1000));
		
		final testPoint = FlxPoint.get(100, 50);
		Assert.areEqual(null, tilemap.getTilePos(1000)); // null is returned
		FlxAssert.pointsEqualXY(100, 50, testPoint); // result is unchanged
		Assert.areEqual(null, tilemap.getTilePos(-1));
		FlxAssert.pointsEqualXY(100, 50, testPoint);
		
		
		inline function assertPosEqual(expectedX:Float, expectedY:Float, actual:FlxPoint, ?infos:PosInfos)
		{
			Assert.areEqual(expectedX, actual.x, 'Point x [${actual.x}] was not equal to expected value [$expectedX]', infos);
			Assert.areEqual(expectedY, actual.y, 'Point y [${actual.y}] was not equal to expected value [$expectedY]', infos);
		}
		
		assertPosEqual(10 + -size, 20 + -size, tilemap.getTilePos(-1, -1));
		assertPosEqual(10 + size, 20 + size, tilemap.getTilePos(1, 1));
		assertPosEqual(10 + 1000 * size, 20 + 1000 * size, tilemap.getTilePos(1000, 1000));
		assertPosEqual(10 + 1000 * size, 20 + 1000 * size, tilemap.getTilePosAt(10 + 1000 * size, 20 + 1000 * size));
	}
	
	@Test
	function testTileExists()
	{
		final mapData = [
			0, 0, 0,
			0, 1, 0,
			0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		tilemap.x = 10;
		tilemap.y = 20;
		tilemap.scale.set(2, 2);
		
		final size = 16;
		
		Assert.isTrue(tilemap.tileExists(4));
		Assert.isTrue(tilemap.tileExists(1, 1));
		Assert.isFalse(tilemap.tileExists(9));
		Assert.isFalse(tilemap.tileExists(3, 1));
		Assert.isFalse(tilemap.tileExists(1, 3));
		Assert.isFalse(tilemap.tileExists(5, 5));
		
		Assert.isTrue(tilemap.tileExistsAt(10 + 1 * size, 20 + 1 * size));
		Assert.isFalse(tilemap.tileExistsAt(10 + 3 * size, 20 + 1 * size));
		Assert.isFalse(tilemap.tileExistsAt(10 + 1 * size, 20 + 3 * size));
		Assert.isFalse(tilemap.tileExistsAt(10 + 5 * size, 20 + 5 * size));
	}
	
	@Test
	function testColumnRowExists()
	{
		final mapData = [
			0, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 4, 3, getBitmapData(), 8, 8);
		tilemap.x = 10;
		tilemap.y = 20;
		tilemap.scale.set(2, 2);
		
		final size = 16;
		
		Assert.isFalse(tilemap.columnExists(5));
		Assert.isFalse(tilemap.rowExists(5));
		Assert.isFalse(tilemap.tileExists(5, 5));
		Assert.isFalse(tilemap.columnExistsAt(10 + 5 * size));
		Assert.isFalse(tilemap.rowExistsAt(20 + 5 * size));
		Assert.isFalse(tilemap.tileExistsAt(10 + 5 * size, 20 + 5 * size));
		
		Assert.isFalse(tilemap.columnExists(4));
		Assert.isFalse(tilemap.rowExists(4));
		Assert.isFalse(tilemap.tileExists(4, 4));
		Assert.isFalse(tilemap.columnExistsAt(10 + 4 * size));
		Assert.isFalse(tilemap.rowExistsAt(20 + 4 * size));
		
		Assert.isTrue(tilemap.columnExists(3));
		Assert.isFalse(tilemap.rowExists(3));
		Assert.isFalse(tilemap.tileExists(3, 3));
		Assert.isTrue(tilemap.columnExistsAt(10 + 3 * size));
		Assert.isFalse(tilemap.rowExistsAt(20 + 3 * size));
		Assert.isFalse(tilemap.tileExistsAt(10 + 3 * size, 20 + 3 * size));
		
		Assert.isTrue(tilemap.columnExists(2));
		Assert.isTrue(tilemap.rowExists(2));
		Assert.isTrue(tilemap.tileExists(2, 2));
		Assert.isTrue(tilemap.columnExistsAt(10 + 2 * size));
		Assert.isTrue(tilemap.rowExistsAt(20 + 2 * size));
		Assert.isTrue(tilemap.tileExistsAt(10 + 2 * size, 20 + 2 * size));
		
		Assert.isTrue(tilemap.columnExists(1));
		Assert.isTrue(tilemap.rowExists(1));
		Assert.isTrue(tilemap.tileExists(1, 1));
		Assert.isTrue(tilemap.columnExistsAt(10 + 1 * size));
		Assert.isTrue(tilemap.rowExistsAt(20 + 1 * size));
		Assert.isTrue(tilemap.tileExistsAt(10 + 1 * size, 20 + 1 * size));
		
		Assert.isTrue(tilemap.columnExists(0));
		Assert.isTrue(tilemap.rowExists(0));
		Assert.isTrue(tilemap.tileExists(0, 0));
		Assert.isTrue(tilemap.columnExistsAt(10));
		Assert.isTrue(tilemap.rowExistsAt(20));
		Assert.isTrue(tilemap.tileExistsAt(10, 20));
		
		Assert.isFalse(tilemap.columnExists(-1));
		Assert.isFalse(tilemap.rowExists(-1));
		Assert.isFalse(tilemap.tileExists(-1, -1));
		Assert.isFalse(tilemap.columnExistsAt(10 - 1));
		Assert.isFalse(tilemap.rowExistsAt(20 - 1));
		Assert.isFalse(tilemap.tileExistsAt(10 - 1, 20 - 1));
	}
	
	@Test
	function testGetAllMapIndices()
	{
		final mapData = [
			0, 0, 0,
			0, 1, 0,
			0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		tilemap.x = 10;
		tilemap.y = 20;
		tilemap.scale.set(2, 2);
		
		FlxAssert.arraysEqual([4], tilemap.getAllMapIndices(1));
		
		final pos = tilemap.getAllTilePos(1);
		Assert.areEqual(1, pos.length);
		Assert.areEqual(10 + 16, pos[0].x);
		Assert.areEqual(20 + 16, pos[0].y);
		
		FlxAssert.arraysEqual([0,1,2,3,5,6,7,8], tilemap.getAllMapIndices(0));
		FlxAssert.arraysEqual([0,1,2,3,5,6,7,8], tilemap.getAllTilePos(0).map((p)->tilemap.getMapIndex(p)));
		FlxAssert.arraysEqual([0,1,2,3,5,6,7,8], tilemap.getAllTilePos(0, true).map((p)->tilemap.getMapIndex(p)));
		final all = new Array<Int>();
		tilemap.forEachMapIndex(0, all.push);
		FlxAssert.arraysEqual([0,1,2,3,5,6,7,8], all);
	}
	
	@Test
	function testOrientDelta()
	{
		final mapData = [
			0, 0, 0,
			0, 1, 0,
			0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		step();
		
		tilemap.x = 0;
		tilemap.last.x = 0;
		final tile = tilemap.getTileData(0);
		tile.orient(0, 0);
		Assert.areEqual(0, tile.last.x);
		Assert.areEqual(0, tile.x);
		
		final tile = tilemap.getTileData(4, true);// get oriented
		Assert.areEqual(8, tile.last.x);
		Assert.areEqual(8, tile.x);
		
		tilemap.last.set(0, 5);
		tilemap.x = 10;
		tilemap.y = 10;
		final tile = tilemap.getTileData(1, 1, true);// get oriented
		
		Assert.areEqual(8, tile.last.x);
		Assert.areEqual(13, tile.last.y);
		Assert.areEqual(18, tile.x);
		Assert.areEqual(18, tile.y);
		
		final tileA = tilemap.getTileData(1, 1);
		final tileB = tilemap.getTileData(4);
		final tileC = tilemap.getTileDataAt(22, 22);
		final tileD = tilemap.getTileData(FlxPoint.weak(22, 22));
		Assert.areEqual(tileA, tileB);
		Assert.areEqual(tileA, tileC);
		Assert.areEqual(tileA, tileD);
		Assert.areNotEqual(null, tileA);
	}
	
	@Test
	function testNegativeIndex()
	{
		final mapData = [
			0, 0, 0,
			0, 1, 0,
			0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData(), 8, 8);
		
		tilemap.setTileIndex(0, -2);
		Assert.areEqual(-2, tilemap.getTileIndex(0));
		
		// cover entire map
		final object = new FlxObject(4, 4, 16, 16);
		object.last.set(object.x, object.y);
		
		var overlapResult = true;
		var rayResult = false;
		var rayStepResult = false;
		var getIndexResult:Null<FlxTile> = null;
		try
		{
			overlapResult = tilemap.overlaps(object);
			rayResult = tilemap.ray(FlxPoint.weak(0, 0), new FlxPoint(tilemap.width, tilemap.height));
			rayStepResult = tilemap.rayStep(FlxPoint.weak(0, 0), new FlxPoint(tilemap.width, tilemap.height));
			getIndexResult = tilemap.getTileData(0);
			// TODO: more tests?
		}
		catch(e)
		{
			Assert.fail('Exception throw: ' + e.toString());
		}
		Assert.isTrue(overlapResult);
		Assert.isFalse(rayResult);
		Assert.isFalse(rayStepResult);
		Assert.isNull(getIndexResult);
	}
	
	@Test
	function testForEachInRay()
	{
		final mapData = [
		//  0, 1, 2, 3, 4, 5, 6, 7, 8, 9 - Map indices
			0, 1, 2, 3, 0, 0, 0, 4, 5, 6,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 10, 2, getBitmapData(), 8, 8);
		tilemap.setTileIndex(4, -1);
		tilemap.setTileIndex(5, -1);
		tilemap.setTileIndex(6, -1);
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		tilemap.forEachInRay(FlxPoint.weak(4, 4), FlxPoint.weak(84, 4), function (index, tile, entry)
		{
			final isNullIndex = index >= 4 && index <= 6;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			final expectedEntry = index == 0 ? START : EDGE(LEFT);
			Assert.isTrue(entry.equals(expectedEntry), 'Expected entry $expectedEntry got $entry');
			Assert.areEqual(callCount, index, 'Reached index $index without reaching index $callCount');
			callCount++;
		});
		Assert.areEqual(10, callCount);
		Assert.areEqual(3, nullCount);
		
		// Test left skip ends
		var expectedIndex = 8;
		tilemap.forEachInRay(FlxPoint.weak(68, 4), FlxPoint.weak(14, 4), function (index, tile, entry)
		{
			Assert.isTrue(index == 8 ? entry.equals(START) : entry.equals(EDGE(RIGHT)));
			Assert.areEqual(expectedIndex, index, tile == null ? null : 'Reached tile $index at ${tile.x} | ${tile.y}');
			expectedIndex--;
		});
		Assert.areEqual(0, expectedIndex);
	}
	
	@Test
	function testFindInRay()
	{
		final mapData = [
		//  0, 1, 2, 3, 4, 5, 6, 7, 8, 9 - columns
			0, 1, 2, 3, 0, 0, 0, 4, 5, 6,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 10, 2, getBitmapData(), 8, 8);
		tilemap.setTileIndex(4, -1);
		tilemap.setTileIndex(5, -1);
		tilemap.setTileIndex(6, -1);
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		final result = tilemap.findInRay(FlxPoint.weak(4, 4), FlxPoint.weak(76, 4), function (index, tile, entry)
		{
			final isNullIndex = index >= 4 && index <= 6;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
				
			final expectedEntry = index == 0 ? START : EDGE(LEFT);
			Assert.isTrue(entry.equals(expectedEntry), 'Expected entry $expectedEntry got $entry');
			Assert.areEqual(callCount, index, 'Reached index $index without reaching index $callCount');
			++callCount;
			return index == 9;
		});
		final expectedResult = STOPPED(9, 72, 4, EDGE(LEFT));
		Assert.isTrue(result.equals(expectedResult), 'Expected ${resultToString(expectedResult)}, got ${resultToString(result)}');
		Assert.areEqual(3, nullCount);
		
		callCount = 0;
		final result = tilemap.findInRay(FlxPoint.weak(4, 4), FlxPoint.weak(76, 4), function (_, _, _)
		{
			callCount++;
			return false;
		});
		Assert.isTrue(result.equals(END), 'Expected END, got ${resultToString(result)}');
		Assert.areEqual(10, callCount);
		
		// Test left skip ends
		var expectedIndex = 8;
		final result = tilemap.findInRay(FlxPoint.weak(68, 4), FlxPoint.weak(14, 4), function (index:Int, tile:Null<FlxTile>, entry:FlxRayEntry)
		{
			final expectedEntry = index == 8 ? START : EDGE(RIGHT);
			Assert.isTrue(entry.equals(expectedEntry), 'Expected entry $expectedEntry got $entry');
			Assert.areEqual(expectedIndex, index, tile == null ? null : 'Reached tile $index at ${tile.x} | ${tile.y}');
			expectedIndex--;
			return index == 1;
		});
		final expectedResult = STOPPED(1, 16, 4, EDGE(RIGHT));
		Assert.isTrue(result.equals(expectedResult), 'Expected ${resultToString(expectedResult)}, got ${resultToString(result)}');
		Assert.areEqual(0, expectedIndex);
	}
	
	@Test
	function testFindIndexInRay()
	{
		final mapData = [
		//  0, 1, 2, 3, 4, 5, 6, 7, 8, 9 - columns
			0, 1, 2, 3, 0, 0, 0, 4, 5, 6,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		];
		tilemap.loadMapFromArray(mapData, 10, 2, getBitmapData(), 8, 8);
		tilemap.setTileIndex(4, -1);
		tilemap.setTileIndex(5, -1);
		tilemap.setTileIndex(6, -1);
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		final result = tilemap.findIndexInRay(FlxPoint.weak(4, 4), FlxPoint.weak(76, 4), function (index:Int, tile:Null<FlxTile>, entry:FlxRayEntry)
		{
			final isNullIndex = index >= 4 && index <= 6;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			final expectedEntry = index == 0 ? START : EDGE(LEFT);
			Assert.isTrue(entry.equals(expectedEntry), 'Expected entry $expectedEntry got $entry');
			Assert.areEqual(callCount, index, 'Reached index $index without reaching index $callCount');
			++callCount;
			return index == 9;
		});
		Assert.areEqual(3, nullCount);
		Assert.areEqual(9, result);
		
		callCount = 0;
		final result = tilemap.findIndexInRay(FlxPoint.weak(4, 4), FlxPoint.weak(76, 4), function (_, _, _)
		{
			callCount++;
			return false;
		});
		Assert.areEqual(-1, result);
		Assert.areEqual(10, callCount);
		
		var expectedIndex = 8;
		final result = tilemap.findIndexInRay(FlxPoint.weak(68, 4), FlxPoint.weak(14, 4), function (index, _, entry)
		{
			final expectedEntry = index == 8 ? START : EDGE(RIGHT);
			Assert.isTrue(entry.equals(expectedEntry), 'Expected entry $expectedEntry got $entry');
			
			Assert.areEqual(expectedIndex, index, 'Expected index $expectedIndex, got $index');
			expectedIndex--;
			return index == 1;
		});
		Assert.areEqual(1, result);
		Assert.areEqual(0, expectedIndex);
	}
	
	@Test
	function testForEachInRow()
	{
		final mapData = [
		//  0, 1, 2, 3, 4, 5, 6, 7, 8, 9 - Map indices
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 1, 2, 3, 0, 0, 0, 4, 5, 6
		];
		tilemap.loadMapFromArray(mapData, 10, 2, getBitmapData(), 8, 8);
		tilemap.setTileIndex(14, -1);
		tilemap.setTileIndex(15, -1);
		tilemap.setTileIndex(16, -1);
		
		try
		{
			tilemap.forEachInRow(2, 0, 8, (_, _)->{});
			Assert.fail("Expected error t be thrown for invalid row");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		tilemap.forEachInRow(1, 0, 100, function (index:Int, tile:Null<FlxTile>)
		{
			final isNullIndex = index >= 14 && index <= 16;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			Assert.areEqual(callCount, index - 10, 'Reached index $index without reaching index $callCount');
			callCount++;
		});
		Assert.areEqual(10, callCount);
		Assert.areEqual(3, nullCount);
		
		var expectedIndex = 18;
		tilemap.forEachInRow(1, 8, 1, function (index, _)
		{
			Assert.areEqual(expectedIndex, index, 'Expected index $expectedIndex, got $index');
			expectedIndex--;
		});
		Assert.areEqual(10, expectedIndex);
	}
	
	@Test
	function testFindInRow()
	{
		final mapData = [
		//  0, 1, 2, 3, 4, 5, 6, 7, 8, 9 - Map indices
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 1, 2, 3, 0, 0, 0, 4, 5, 6
		];
		tilemap.loadMapFromArray(mapData, 10, 2, getBitmapData(), 8, 8);
		tilemap.setTileIndex(14, -1);
		tilemap.setTileIndex(15, -1);
		tilemap.setTileIndex(16, -1);
		
		try
		{
			tilemap.findInRow(2, 0, 8, (_, _)->false);
			Assert.fail("Expected error t be thrown for invalid row");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		final result = tilemap.findInRow(1, 0, 100, function (index:Int, tile:Null<FlxTile>)
		{
			final isNullIndex = index >= 14 && index <= 16;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			Assert.areEqual(callCount, index - 10, 'Reached index $index without reaching index $callCount');
			callCount++;
			return index == 19;
		});
		Assert.isNotNull(result);
		if (result == null) throw "check needed for null safety";
		Assert.areEqual(72, result.x);
		Assert.areEqual(8, result.y);
		Assert.areEqual(10, callCount);
		Assert.areEqual(3, nullCount);
		
		var expectedIndex = 18;
		tilemap.findInRow(1, 8, 1, function (index, _)
		{
			Assert.areEqual(expectedIndex, index, 'Expected index $expectedIndex, got $index');
			expectedIndex--;
			return false;
		});
		Assert.areEqual(10, expectedIndex);
	}
	
	@Test
	function testFindIndexInRow()
	{
		final mapData = [
		//  0, 1, 2, 3, 4, 5, 6, 7, 8, 9 - Map indices
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 1, 2, 3, 0, 0, 0, 4, 5, 6
		];
		tilemap.loadMapFromArray(mapData, 10, 2, getBitmapData(), 8, 8);
		tilemap.setTileIndex(14, -1);
		tilemap.setTileIndex(15, -1);
		tilemap.setTileIndex(16, -1);
		
		try
		{
			tilemap.findIndexInRow(2, 0, 8, (i,t)->false);
			Assert.fail("Expected error t be thrown for invalid row");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		final result = tilemap.findIndexInRow(1, 0, 100, function (index:Int, tile:Null<FlxTile>)
		{
			final isNullIndex = index >= 14 && index <= 16;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			Assert.areEqual(callCount, index - 10, 'Reached index $index without reaching index $callCount');
			callCount++;
			return index == 19;
		});
		Assert.areEqual(10, callCount);
		Assert.areEqual(3, nullCount);
		Assert.areEqual(19, result);
		
		var expectedIndex = 18;
		final result = tilemap.findIndexInRow(1, 8, 1, function (index, _)
		{
			Assert.areEqual(expectedIndex, index, 'Expected index $expectedIndex, got $index');
			expectedIndex--;
			return false;
		});
		Assert.areEqual(10, expectedIndex);
	}
	
	@Test
	function testFindInColumn()
	{
		final mapData = [
			0, 0, // 0
			0, 1, // 1
			0, 2, // 2
			0, 3, // 3
			0, 0, // 4
			0, 0, // 5
			0, 0, // 6
			0, 4, // 7
			0, 5, // 8
			0, 6  // 9
		];
		tilemap.loadMapFromArray(mapData, 2, 10, getBitmapData(), 8, 8);
		tilemap.setTileIndex(9, -1);
		tilemap.setTileIndex(11, -1);
		tilemap.setTileIndex(13, -1);
		
		try
		{
			tilemap.findInColumn(2, 0, 8, (i,t)->false);
			Assert.fail("Expected error t be thrown for invalid row");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		final result = tilemap.findInColumn(1, 0, 100, function (index, tile)
		{
			final isNullIndex = index == 9 || index == 11 || index == 13;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			Assert.areEqual(index, callCount * 2 + 1, 'Reached index $index without reaching index $callCount');
			callCount++;
			return index == 19;
		});
		Assert.isNotNull(result);
		if (result == null) throw "check needed for null safety";
		Assert.areEqual(8, result.x);
		Assert.areEqual(72, result.y);
		Assert.areEqual(10, callCount);
		Assert.areEqual(3, nullCount);
		
		var expectedIndex = 17;
		final result = tilemap.findInColumn(1, 8, 1, function (index, _)
		{
			Assert.areEqual(expectedIndex, index, 'Expected index $expectedIndex, got $index');
			expectedIndex -= 2;
			return false;
		});
		Assert.areEqual(1, expectedIndex);
	}
	
	
	@Test
	function testFindIndexInColumn()
	{
		final mapData = [
			0, 0, // 0
			0, 1, // 1
			0, 2, // 2
			0, 3, // 3
			0, 0, // 4
			0, 0, // 5
			0, 0, // 6
			0, 4, // 7
			0, 5, // 8
			0, 6  // 9
		];
		tilemap.loadMapFromArray(mapData, 2, 10, getBitmapData(), 8, 8);
		tilemap.setTileIndex(9, -1);
		tilemap.setTileIndex(11, -1);
		tilemap.setTileIndex(13, -1);
		
		try
		{
			tilemap.findIndexInColumn(2, 0, 8, (i,t)->false);
			Assert.fail("Expected error t be thrown for invalid row");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		final result = tilemap.findIndexInColumn(1, 0, 100, function (index, tile)
		{
			final isNullIndex = index == 9 || index == 11 || index == 13;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			Assert.areEqual(index, callCount * 2 + 1, 'Reached index $index without reaching index $callCount');
			callCount++;
			return index == 19;
		});
		Assert.isNotNull(19);
		Assert.areEqual(10, callCount);
		Assert.areEqual(3, nullCount);
		
		var expectedIndex = 17;
		final result = tilemap.findIndexInColumn(1, 8, 1, function (index, _)
		{
			Assert.areEqual(expectedIndex, index, 'Expected index $expectedIndex, got $index');
			expectedIndex -= 2;
			return false;
		});
		Assert.areEqual(-1, result);
		Assert.areEqual(1, expectedIndex);
	}
	
	@Test
	function testForEachInColumn()
	{
		final mapData = [
			0, 0, // 0
			0, 1, // 1
			0, 2, // 2
			0, 3, // 3
			0, 0, // 4
			0, 0, // 5
			0, 0, // 6
			0, 4, // 7
			0, 5, // 8
			0, 6  // 9
		];
		tilemap.loadMapFromArray(mapData, 2, 10, getBitmapData(), 8, 8);
		tilemap.setTileIndex(9, -1);
		tilemap.setTileIndex(11, -1);
		tilemap.setTileIndex(13, -1);
		
		try
		{
			tilemap.forEachInColumn(2, 0, 8, (i,t)->false);
			Assert.fail("Expected error t be thrown for invalid row");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		// Test all overloads
		var callCount = 0;
		var nullCount = 0;
		tilemap.forEachInColumn(1, 0, 100, function (index, tile)
		{
			final isNullIndex = index == 9 || index == 11 || index == 13;
			Assert.areEqual(isNullIndex, tile == null, 'Expected index $index to be, ${isNullIndex ? "null" : "non-null"}');
			if (isNullIndex)
				nullCount++;
			
			Assert.areEqual(index, callCount * 2 + 1, 'Reached index $index without reaching index $callCount');
			callCount++;
		});
		Assert.areEqual(10, callCount);
		Assert.areEqual(3, nullCount);
		
		var expectedIndex = 17;
		tilemap.forEachInColumn(1, 8, 1, function (index, _)
		{
			Assert.areEqual(expectedIndex, index, 'Expected index $expectedIndex, got $index');
			expectedIndex -= 2;
		});
		Assert.areEqual(1, expectedIndex);
	}
	
	function getBitmapData()
	{
		return new BitmapData(8*16, 8);
	}
}
