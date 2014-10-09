package flixel.tile;

import flash.errors.ArgumentError;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap;
import massive.munit.Assert;

class FlxTilemapTest extends FlxTest
{
	var tilemap:FlxTilemap;
	
	@Before
	function before()
	{
		tilemap = new FlxTilemap();
		destroyable = tilemap;
	}
	
	@Test
	function test1x1Map()
	{
		tilemap.loadMapFromCSV("1", FlxGraphic.fromClass(GraphicAuto), 8, 8);
		
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
		tilemap.loadMapFromArray(mapData, 3, 2, FlxGraphic.fromClass(GraphicAuto), 8, 8);
		
		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		FlxAssert.arraysAreEqual([0, 1, 0, 1, 1, 1], tilemap.getData());
	}
	
	@Test
	function testLoadMap2DArray()
	{
		var mapData = [
			[0, 1, 0],
			[1, 1, 1]];
		tilemap.loadMapFrom2DArray(mapData, FlxGraphic.fromClass(GraphicAuto), 8, 8);
		
		Assert.areEqual(3, tilemap.widthInTiles);
		Assert.areEqual(2, tilemap.heightInTiles);
		FlxAssert.arraysAreEqual([0, 1, 0, 1, 1, 1], tilemap.getData());
	}
}