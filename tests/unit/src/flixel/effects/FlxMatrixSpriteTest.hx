package flixel.effects;

import flixel.FlxCamera;
import flixel.effects.FlxMatrixSprite;
import flixel.math.FlxPoint;
import massive.munit.Assert;

class FlxMatrixSpriteTest extends FlxTest
{
	var sprite = new FlxMatrixSprite();
	
	@Before
	function before():Void
	{
		sprite = new FlxMatrixSprite();
		sprite.makeGraphic(2, 2);
		sprite.graphic.bitmap.setPixel32(0, 0, 0xFFff0000);
		sprite.graphic.bitmap.setPixel32(1, 0, 0xFF00ff00);
		sprite.graphic.bitmap.setPixel32(0, 1, 0xFF0000ff);
	}
	
	@Test
	function testRender()
	{
		final camera = new FlxCamera();
		camera.pixelPerfectRender = true;
		Assert.isTrue(sprite.isSimpleRenderBlit(camera));
		
		sprite.renderMatrix.translate(5, 10);
		sprite.renderMatrix.scale(2, 4);
		sprite.renderMatrix.rotateByPositive90();
		Assert.isFalse(sprite.isSimpleRenderBlit());
		Assert.isFalse(sprite.isSimpleRender());
	}
	
	@Test @Ignore //#3535
	function testGetPixel()
	{
		final worldPos = FlxPoint.get(0.5, 0.5);
		FlxAssert.colorsEqual(0xFFff0000, sprite.getPixelAt(worldPos));
		sprite.renderMatrix.rotateByPositive90();
		FlxAssert.colorsEqual(0xFF0000ff, sprite.getPixelAt(worldPos));
	}
}
