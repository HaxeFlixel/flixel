package flixel.tile;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.display.BitmapData;
import openfl.errors.ArgumentError;

using StringTools;

class FlxTilemapTest extends FlxTest
{
	var tilemap:FlxTilemap;
	var sampleMapString:String;
	var sampleMapArray:Array<Int>;

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
		Assert.areEqual(1000, tilemap.getColumnAt(tilemap.getColumnPos(1000)));
		Assert.areEqual(10 + 3 * size, tilemap.getColumnPos(3));
		Assert.areEqual(10 + 3 * size + half, tilemap.getColumnPos(3, true));
		Assert.areEqual(10 + 1000 * size, tilemap.getColumnPos(1000));
		
		Assert.areEqual(0, tilemap.getRowAt(tilemap.getRowPos(0)));
		Assert.areEqual(1, tilemap.getRowAt(tilemap.getRowPos(1)));
		Assert.areEqual(2, tilemap.getRowAt(tilemap.getRowPos(2)));
		Assert.areEqual(1000, tilemap.getRowAt(tilemap.getRowPos(1000)));
		Assert.areEqual(20 + 2 * size, tilemap.getRowPos(2));
		Assert.areEqual(20 + 2 * size + half, tilemap.getRowPos(2, true));
		Assert.areEqual(20 + 1000 * size, tilemap.getRowPos(1000));
		
		Assert.areEqual(null, tilemap.getTilePos(1000));
		Assert.areEqual(null, tilemap.getTilePos(-1));
		
		
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
		final mapData = [0];
		tilemap.loadMapFromArray(mapData, 1, 1, getBitmapData(), 8, 8);
		step();
		
		tilemap.x = 0;
		tilemap.last.x = 0;
		final tile = tilemap.getTileData(0);
		tile.orient(0, 0);
		
		Assert.areEqual(tile.x, tile.last.x);
		Assert.areEqual(0, tile.x);
		
		tilemap.last.x = 10;
		tilemap.x = 10;
		tile.orient(0, 0);
		
		Assert.areEqual(tilemap.x - tilemap.last.x, tile.x - tile.last.x);
		Assert.areEqual(tile.x, tile.last.x);
	}
	
	@Test
	@:haxe.warning("-WDeprecated")
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
		var getIndexResult:FlxTile = null;
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
	
	function getBitmapData()
	{
		return new BitmapData(8*16, 8);
	}
}
