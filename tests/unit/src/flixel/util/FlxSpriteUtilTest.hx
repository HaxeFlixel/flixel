package flixel.util;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import massive.munit.Assert;
using flixel.util.FlxSpriteUtil;

class FlxSpriteUtilTest extends FlxTest
{
	var sprite:FlxSprite;
	
	@Before
	function before()
	{
		sprite = new FlxSprite();
	}
	
	@Test
	function testDrawCircleDefaultPosition()
	{
		var size = 10;
		var halfSize = 5;
		
		sprite.setPosition(100, 100);
		sprite.makeGraphic(size, size, FlxColor.TRANSPARENT);
		sprite.drawCircle( -1, -1, halfSize, FlxColor.WHITE);
		
		Assert.areEqual(0xffffff, sprite.pixels.getPixel(halfSize, halfSize));
	}
	
	@Test // #1314
	function testDrawPolygonUnmodifiedArray()
	{
		sprite.makeGraphic(10, 10);
		var vertices = [FlxPoint.get(0, 0), FlxPoint.get(10, 10)];
		sprite.drawPolygon(vertices);
		
		Assert.isTrue(vertices[0].equals(FlxPoint.get(0, 0)));
		Assert.isTrue(vertices[1].equals(FlxPoint.get(10, 10)));
	}
}