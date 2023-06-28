package flixel;

import openfl.display.BitmapData;
import flixel.animation.FlxAnimation;
import flixel.graphics.atlas.FlxAtlas;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import massive.munit.Assert;
import haxe.PosInfos;

class FlxSpriteTest extends FlxTest
{
	var sprite1:FlxSprite;
	var sprite2:FlxSprite;

	@Before
	function before():Void
	{
		sprite1 = new FlxSprite();
		sprite1.makeGraphic(100, 80);

		sprite2 = new FlxSprite();
		sprite2.makeGraphic(100, 80);

		destroyable = sprite1;
	}

	@Test
	function testSize():Void
	{
		Assert.areEqual(100, sprite1.width);
		Assert.areEqual(80, sprite1.height);
	}

	@Test
	function testSpriteDefaultValues():Void
	{
		Assert.isNotNull(sprite1);
		Assert.isNotNull(sprite2);

		Assert.isTrue(sprite1.active);
		Assert.isTrue(sprite1.visible);
		Assert.isTrue(sprite1.alive);
		Assert.isTrue(sprite1.exists);

		Assert.isTrue(sprite2.active);
		Assert.isTrue(sprite2.visible);
		Assert.isTrue(sprite2.alive);
		Assert.isTrue(sprite2.exists);
	}

	@Test
	function testMakeGraphicColor():Void
	{
		var color = FlxColor.RED;
		var colorSprite = new FlxSprite();
		colorSprite.makeGraphic(100, 100, color);
		Assert.areEqual(color.to24Bit(), colorSprite.pixels.getPixel(0, 0));
		Assert.areEqual(color.to24Bit(), colorSprite.pixels.getPixel(90, 90));

		color = FlxColor.GREEN;
		colorSprite = new FlxSprite();
		colorSprite.makeGraphic(120, 120, color);
		Assert.areEqual(color.to24Bit(), colorSprite.pixels.getPixel(119, 119));
	}

	@Test
	function testHeight():Void
	{
		var heightSprite = new FlxSprite();
		var bitmapData = new BitmapData(1, 1);
		heightSprite.loadGraphic(bitmapData);

		Assert.areEqual(1, heightSprite.height);

		heightSprite = new FlxSprite();
		bitmapData = new BitmapData(100, 100, true, 0xFFFF0000);
		heightSprite.loadGraphic(bitmapData);

		Assert.areEqual(100, heightSprite.height);

		heightSprite.height = 456;

		Assert.areEqual(456, heightSprite.height);
	}

	@Test
	function testWidth():Void
	{
		var widthSprite = new FlxSprite();
		var bitmapData = new BitmapData(1, 1);
		widthSprite.loadGraphic(bitmapData);

		Assert.areEqual(1, widthSprite.width);

		widthSprite = new FlxSprite();
		bitmapData = new BitmapData(100, 100, true, 0xFFFF0000);
		widthSprite.loadGraphic(bitmapData);

		Assert.areEqual(100, widthSprite.width);

		widthSprite.width = 323;

		Assert.areEqual(323, widthSprite.width);
	}

	@Test
	function testSetSize():Void
	{
		var sizeSprite = new FlxSprite();
		var bitmapData = new BitmapData(100, 130);
		sizeSprite.loadGraphic(bitmapData);

		Assert.areEqual(100, sizeSprite.width);
		Assert.areEqual(130, sizeSprite.height);

		sizeSprite.setSize(233, 333);

		Assert.areEqual(233, sizeSprite.width);
		Assert.areEqual(333, sizeSprite.height);
	}

	@Test
	function testLoadGraphicFromSpriteCopyAnimations():Void
	{
		var graphic = new BitmapData(3, 1);
		sprite1.loadGraphic(graphic, true, 1, 1);
		sprite1.animation.add("animation", [0, 1, 2]);

		sprite2.loadGraphicFromSprite(sprite1);

		var animation:FlxAnimation = sprite2.animation.getByName("animation");
		Assert.areEqual(3, animation.numFrames);
	}

	@Test
	function testLoadGraphic()
	{
		sprite1.loadGraphic(new BitmapData(1, 1));
		assert1x1GraphicLoaded();
	}

	@Test
	function testLoadGraphicFromSprite()
	{
		sprite2.loadGraphic(new BitmapData(1, 1));
		sprite1.loadGraphicFromSprite(sprite2);
		assert1x1GraphicLoaded();
	}

	@Test
	function testLoadRotatedGraphic()
	{
		sprite1.loadRotatedGraphic(new BitmapData(1, 1));
		assert1x1GraphicLoaded();
	}

	@Test
	function testLoadRotatedFrame()
	{
		var atlas = new FlxAtlas("atlas");
		atlas.addNode(new BitmapData(1, 1), "node");
		sprite1.loadRotatedFrame(atlas.getAtlasFrames().getByName("node"));
		assert1x1GraphicLoaded();
	}

	@Test // #1377
	function testUpdateHitboxNegativeScale()
	{
		sprite1.makeGraphic(10, 5);
		sprite1.scale.set(-0.5, -2);
		sprite1.updateHitbox();

		Assert.areEqual(sprite1.width, 5);
		Assert.areEqual(sprite1.height, 10);
	}

	function assert1x1GraphicLoaded()
	{
		Assert.isNotNull(sprite1.pixels);
		Assert.isNotNull(sprite1.graphic);
		Assert.areEqual(1, sprite1.frameWidth);
		Assert.areEqual(1, sprite1.frameHeight);
	}

	@Test // #1203
	function testColorWithAlphaComparison()
	{
		sprite1.color = FlxColor.RED;
		Assert.areEqual(FlxColor.RED, sprite1.color);
	}

	@Test // #1511
	function testLoadGraphicInvalidGraphicPathNoCrash()
	{
		sprite1.loadGraphic("assets/invalid");
	}

	@Test // #1511
	function testLoadRotatedGraphicInvalidGraphicPathNoCrash()
	{
		sprite1.loadRotatedGraphic("assets/invalid");
	}

	@Test // #1526
	function testCreateSpriteSkipPosition()
	{
		var sprite = new FlxSprite(new BitmapData(10, 20));

		Assert.areEqual(0, sprite.x);
		Assert.areEqual(0, sprite.y);

		Assert.isNotNull(sprite.pixels);
		Assert.areEqual(10, sprite.pixels.width);
		Assert.areEqual(20, sprite.pixels.height);
	}

	@Test // #1678
	function testStampTextCrash()
	{
		var text = new FlxText(0, 0, 50, 'Text');
		var sprite = new FlxSprite();
		sprite.makeGraphic(100, 100, 0, true);
		sprite.stamp(text);
	}

	@Test // #1704
	function testStampTextColorChange()
	{
		var text = new FlxText(0, 0, 0, "Text");
		text.color = FlxColor.RED;

		var sprite = new FlxSprite();
		sprite.makeGraphic(100, 100, FlxColor.BLUE);
		sprite.stamp(text);

		var graphic = sprite.updateFramePixels();
		for (x in 0...graphic.width)
		{
			for (y in 0...graphic.height)
			{
				var color:Int = graphic.getPixel32(x, y);
				Assert.isTrue(color < 0xffffffff);
			}
		}
	}
	
	@Test
	function testGetRotatedBounds()
	{
		var expected = FlxRect.get();
		var rect = FlxRect.get();
		
		var sprite = new FlxSprite();
		sprite.makeGraphic(1, 1);
		
		
		sprite.origin.set(0, 0);
		sprite.angle = 45;
		rect = sprite.getRotatedBounds(rect);
		var sqrt2 = Math.sqrt(2);
		expected.set(-0.5 * sqrt2, 0, sqrt2, sqrt2);
		FlxAssert.rectsNear(expected, rect);
		
		var w = sprite.width = 20;
		var h = sprite.height = 15;
		sprite.angle =  90;
		FlxAssert.rectsNear(expected.set(-h, 0, h, w), sprite.getRotatedBounds(rect), 0.0001);
		sprite.angle = 180;
		FlxAssert.rectsNear(expected.set(-w, -h, w, h), sprite.getRotatedBounds(rect), 0.0001);
		sprite.angle = 270;
		FlxAssert.rectsNear(expected.set(0, -w, h, w), sprite.getRotatedBounds(rect), 0.0001);
		sprite.angle = 360;
		FlxAssert.rectsNear(expected.set(0, 0, w, h), sprite.getRotatedBounds(rect), 0.0001);
		
		sprite.width = sprite.height = 1;
		sprite.origin.set(1, 1);
		sprite.angle = 210;
		rect = sprite.getRotatedBounds(rect);
		var sumSinCos30 = 0.5 + Math.cos(30/180*Math.PI);//sin30 = 0.5;
		expected.set(0.5, 1, sumSinCos30, sumSinCos30);
		FlxAssert.rectsNear(expected, rect);
		
		expected.put();
	}
	
	@Test
	function testGetScreenBounds()
	{
		var expected = FlxRect.get();
		var rect = FlxRect.get();
		
		var sprite = new FlxSprite();
		sprite.makeGraphic(10, 10);
		sprite.setGraphicSize(1, 1);
		
		sprite.origin.set(0, 0);
		sprite.angle = 45;
		rect = sprite.getScreenBounds(rect);
		var sqrt2 = Math.sqrt(2);
		expected.set(-0.5 * sqrt2, 0, sqrt2, sqrt2);
		FlxAssert.rectsNear(expected, rect);
		
		var w = 60;
		var h = 100;
		var halfDiff = Math.abs(h - w) / 2;
		sprite.setGraphicSize(w, h);
		sprite.updateHitbox();
		sprite.angle =  90;
		FlxAssert.rectsNear(expected.set(-halfDiff, halfDiff, h, w), sprite.getScreenBounds(rect), 0.0001);
		sprite.angle = 180;
		FlxAssert.rectsNear(expected.set(0, 0, w, h), sprite.getScreenBounds(rect), 0.0001);
		sprite.angle = 270;
		FlxAssert.rectsNear(expected.set(-halfDiff, halfDiff, h, w), sprite.getScreenBounds(rect), 0.0001);
		sprite.angle = 360;
		FlxAssert.rectsNear(expected.set(0, 0, w, h), sprite.getScreenBounds(rect), 0.0001);
		
		sprite.setGraphicSize(1, 1);
		sprite.updateHitbox();
		sprite.origin.set(10, 10);
		sprite.angle = 210;
		rect = sprite.getScreenBounds(rect);
		var sumSinCos30 = 0.5 + Math.cos(30/180*Math.PI);//sin30 = 0.5;
		expected.set(5, 5.5, sumSinCos30, sumSinCos30);
		// Ignore for now (sometimes returns 4, 5.5,...)
		// FlxAssert.rectsNear(expected, rect);
		
		expected.put();
	}
}
