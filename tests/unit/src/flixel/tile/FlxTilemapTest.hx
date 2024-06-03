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
		tilemap.loadMapFromCSV("1", getBitmapData());

		try
		{
			tilemap.draw();
		}
		catch (error:ArgumentError)
		{
			Assert.fail(error.message);
		}

		Assert.areEqual(1, tilemap.getData()[0]);
	}

	@Test
	function testLoadMapArray()
	{
		var mapData = [0, 1, 0, 1, 1, 1];
		tilemap.loadMapFromArray(mapData, 3, 2, getBitmapData());

		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		FlxAssert.arraysEqual([0, 1, 0, 1, 1, 1], tilemap.getData());
	}

	@Test
	function testLoadMap2DArray()
	{
		var mapData = [[0, 1, 0], [1, 1, 1]];
		tilemap.loadMapFrom2DArray(mapData, getBitmapData());

		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		FlxAssert.arraysEqual([0, 1, 0, 1, 1, 1], tilemap.getData());
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
		tilemap.loadMapFrom2DArray([[1], [0]], getBitmapData());
		var sprite = new FlxSprite(-2, 10);
		Assert.isFalse(tilemap.overlapsWithCallback(sprite));
	}
	
	@Test // #1546
	// same as testOffMapOverlap but with processOverlaps
	function testOffMapOverlap2()
	{
		tilemap.loadMapFrom2DArray([[1], [0]], getBitmapData());
		var sprite = new FlxSprite(-2, 10);
		Assert.isFalse(tilemap.processOverlaps(sprite));
	}

	@Test // #1550
	function testLoadMapFromCSVTrailingNewline()
	{
		testLoadMapFromCSVWithNewline(sampleMapString + "[nl]", "\n");
	}

	function testLoadMapFromCSVWithNewline(csv:String, newlines:String)
	{
		tilemap.loadMapFromCSV(csv.replace("[nl]", newlines), getBitmapData());

		Assert.areEqual(4, tilemap.widthInTiles);
		Assert.areEqual(3, tilemap.heightInTiles);
		FlxAssert.arraysEqual(sampleMapArray, tilemap.getData());
	}

	@Test // #1617
	function testRayEmpty()
	{
		var mapData = [0, 0, 0]; // 3x1
		tilemap.loadMapFromArray(mapData, 3, 1, getBitmapData());

		Assert.isTrue(tilemap.ray(new FlxPoint(0, tilemap.height / 2), new FlxPoint(tilemap.width, tilemap.height / 2)));
	}

	@Test // #1617
	function testRayStraight()
	{
		var mapData = [0, 1, 0]; // 3x1 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 1, getBitmapData());

		Assert.isFalse(tilemap.ray(new FlxPoint(0, tilemap.height / 2), new FlxPoint(tilemap.width, tilemap.height / 2)));
	}

	@Test // #1617
	function testRayImperfectDiagonal()
	{
		var mapData = [0, 0, 0, 0, 1, 0, 0, 0, 0]; // 3x3 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData());

		Assert.isFalse(tilemap.ray(new FlxPoint(0, 0), new FlxPoint(tilemap.width - tilemap.width / 8, tilemap.height)));
	}

	@Test // #1617
	function testRayPerfectDiagonal()
	{
		var mapData = [0, 0, 0, 0, 1, 0, 0, 0, 0]; // 3x3 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData());

		Assert.isFalse(tilemap.ray(new FlxPoint(0, 0), new FlxPoint(tilemap.width, tilemap.height)));
	}

	@Test
	function testNegativeIndicesTreatedAsZero()
	{
		tilemap.loadMapFromCSV("-1,1", getBitmapData());
		FlxAssert.arraysEqual([0, 1], tilemap.getData());
	}

	@Test // #1520
	function testLoadMapFromCSVTrailingComma()
	{
		tilemap.loadMapFromCSV("1,", getBitmapData());
		FlxAssert.arraysEqual([1], tilemap.getData());
	}

	@Test
	function testLoadMapFromCSVInvalidIndices()
	{
		var exceptionThrown = false;
		try
		{
			tilemap.loadMapFromCSV("1,f,1", getBitmapData());
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
		tilemap.loadMapFromCSV("1,", getBitmapData());
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
		final mapData = [0, 0, 0, 0, 1, 0, 0, 0, 0]; // 3x3 with a solid block in the middle
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData());
		
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
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData());
		
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
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData());
		
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
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData());
		
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
		tilemap.loadMapFromArray(mapData, 3, 3, getBitmapData());
		
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
	
	function assertPixelHasColor(x:Int, color:UInt, ?info:PosInfos)
	{
		Assert.areEqual(FlxG.camera.buffer.getPixel(x, 0), color, info);
	}

	function getBitmapData()
	{
		return new BitmapData(16, 8);
	}
}
