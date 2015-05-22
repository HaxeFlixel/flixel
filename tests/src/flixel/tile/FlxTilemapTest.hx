package flixel.tile;

import flash.display.BitmapData;
import flash.errors.ArgumentError;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap;
import massive.munit.Assert;
using flixel.util.FlxArrayUtil;
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
			1, 0, 0, 1];
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
	}
	
	@Test
	function testLoadMapArray()
	{
		var mapData = [0, 1, 0, 1, 1, 1];
		tilemap.loadMapFromArray(mapData, 3, 2, getBitmapData(), 8, 8);
		
		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		Assert.isTrue([0, 1, 0, 1, 1, 1].equals(tilemap.getData()));
	}
	
	@Test
	function testLoadMap2DArray()
	{
		var mapData = [
			[0, 1, 0],
			[1, 1, 1]];
		tilemap.loadMapFrom2DArray(mapData, getBitmapData(), 8, 8);
		
		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		Assert.isTrue([0, 1, 0, 1, 1, 1].equals(tilemap.getData()));
	}
	
	@Test
	function testLoadMapFromCSVWindowsNewlines()
	{
		testLoadMapFromCSVWithNewline("\r\n");
	}
	
	@Test
	function testLoadMapFromCSVUnixNewlines()
	{
		testLoadMapFromCSVWithNewline("\n");
	}
	
	@Test // issue 1375
	function testLoadMapFromCSVMacNewlines()
	{
		testLoadMapFromCSVWithNewline("\r");
	}
	
	function testLoadMapFromCSVWithNewline(newlines:String)
	{
		tilemap.loadMapFromCSV(sampleMapString.replace("[nl]", newlines), getBitmapData(), 8, 8);
		
		Assert.areEqual(4, tilemap.widthInTiles);
		Assert.areEqual(3, tilemap.heightInTiles);
		Assert.isTrue(sampleMapArray.equals(tilemap.getData()));
	}
	
	function getBitmapData()
	{
		return new BitmapData(16, 8);
	}
}