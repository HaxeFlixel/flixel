package flixel.util;

import flixel.FlxSprite;
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
}