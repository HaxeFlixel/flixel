package flixel.tile;

import flash.errors.ArgumentError;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap;
import massive.munit.Assert;

class FlxTilemapTest extends FlxTest
{
	var tilemap:FlxTilemap;
	
	@Before
	function before():Void
	{
		tilemap = new FlxTilemap();
		destroyable = tilemap;
	}
	
	@Test
	function test1x1Map():Void
	{
		tilemap.loadMap("1", FlxGraphic.fromClass(GraphicAuto), 8, 8);
		
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
}