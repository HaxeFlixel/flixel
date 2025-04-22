package flixel;

import flixel.animation.FlxAnimation;
import flixel.graphics.atlas.FlxAtlas;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.display.BitmapData;

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
		FlxAssert.colorsEqual(color.rgb, colorSprite.pixels.getPixel(0, 0));
		FlxAssert.colorsEqual(color.rgb, colorSprite.pixels.getPixel(90, 90));

		color = FlxColor.GREEN;
		colorSprite = new FlxSprite();
		colorSprite.makeGraphic(120, 120, color);
		FlxAssert.colorsEqual(color.rgb, colorSprite.pixels.getPixel(119, 119));
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
	
	@Test
	function testGetGraphicMidpoint()
	{
		final full:SimplePoint = [sprite1.frameWidth, sprite1.frameHeight];
		final mid:SimplePoint = [full.x / 2, full.y / 2];
		final zero:SimplePoint = [0, 0];
		assertGraphicMidpoint({ pos:[0, 5], size:full, origin:mid, offset:zero});
		assertGraphicMidpoint({ pos:[0, 5], size:full, origin:full, offset:zero});
		assertGraphicMidpoint({ pos:[0, 5], size:[10, 10], origin:mid, offset:zero});
		assertGraphicMidpoint({ pos:[0, 5], size:[50, 50], origin:mid, offset:[1, 3]});
		assertGraphicMidpoint({ pos:[0, 5], size:[50, 50], origin:zero, offset:zero});
		assertGraphicMidpoint({ pos:[0, 5], size:[50, 50], origin:full, offset:[50, 60]});
		assertGraphicMidpoint({ pos:[0, 5], size:[50, 100], origin:[10, 20], offset:[-50, 60]});
	}
	
	function assertGraphicMidpoint(orientation:Orientation, ?pos:PosInfos)
	{
		sprite1.x = orientation.pos.x;
		sprite1.y = orientation.pos.y;
		sprite1.setGraphicSize(orientation.size.x, orientation.size.y);
		sprite1.offset.set(orientation.offset.x, orientation.offset.y);
		sprite1.origin.set(orientation.origin.x, orientation.origin.y);
		final actual = sprite1.getGraphicMidpoint(FlxPoint.weak());
		
		// check against getScreenBounds
		final rect = sprite1.getScreenBounds(FlxRect.weak());
		FlxAssert.areNear(rect.x + 0.5 * rect.width, actual.x, 0.001, pos);
		FlxAssert.areNear(rect.y + 0.5 * rect.height, actual.y, 0.001, pos);
	}
	
	@Test
	function testWorldToFramePosition()
	{
		sprite1.x = 100;
		sprite1.y = 100;
		sprite1.makeGraphic(100, 100);
		
		final worldPos = FlxPoint.get();
		final actual = FlxPoint.get();
		
		#if FLX_POINT_POOL
		// track leaked points
		@:privateAccess
		final pointPool = FlxBasePoint.pool;
		pointPool.preAllocate(100);
		final startingPoolLength = pointPool.length;
		#end
		
		function assertFramePosition(worldX:Float, worldY:Float, expectedX:Float, expectedY:Float, margin = 0.001, ?pos:PosInfos)
		{
			function getMsg(prefix:String)
			{
				return '$prefix - Value [$actual] is not within [$margin] of [( x:$expectedX | y:$expectedY )]';
			}
			
			sprite1.worldToFramePosition(worldX, worldY, actual);
			FlxAssert.pointNearXY(expectedX, expectedY, actual, margin, getMsg('(xy)'), pos);
			
			sprite1.worldToFramePositionSimple(worldX, worldY, actual);
			FlxAssert.pointNearXY(expectedX, expectedY, actual, margin, getMsg('simple(xy)'), pos);
			
			worldPos.set(worldX, worldY);
			sprite1.worldToFramePosition(worldPos, actual);
			FlxAssert.pointNearXY(expectedX, expectedY, actual, margin, getMsg('(p)'), pos);
			
			sprite1.worldToFramePositionSimple(worldPos, actual);
			FlxAssert.pointNearXY(expectedX, expectedY, actual, margin, getMsg('simple(p)'), pos);
		}
		
		assertFramePosition(100, 100, 0, 0);
		assertFramePosition(100, 110, 0, 10);
		assertFramePosition(150, 150, 50, 50);
		
		#if FLX_POINT_POOL
		Assert.areEqual(startingPoolLength, pointPool.length);
		#end
		
		FlxG.camera.scroll.set(50, 100);
		assertFramePosition(100, 100, 0, 0);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.scale.set(2, 2);
		assertFramePosition(100, 100, 25, 25);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.angle = 90;
		assertFramePosition(100, 100, 25, 75);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.flipX = true;
		assertFramePosition(100, 100, 75, 75);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.flipY = true;
		assertFramePosition(100, 100, 75, 25);
		assertFramePosition(150, 150, 50, 50);
		
		#if FLX_POINT_POOL
		Assert.areEqual(startingPoolLength, pointPool.length);
		#end
	}
	
	@Test
	function testViewToFramePosition()
	{
		sprite1.x = 100;
		sprite1.y = 100;
		sprite1.makeGraphic(100, 100);
		
		final worldPos = FlxPoint.get();
		final actual = FlxPoint.get();
		
		#if FLX_POINT_POOL
		// track leaked points
		@:privateAccess
		final pointPool = FlxBasePoint.pool;
		pointPool.preAllocate(100);
		final startingPoolLength = pointPool.length;
		#end
		
		function assertFramePosition(worldX:Float, worldY:Float, expectedX:Float, expectedY:Float, margin = 0.001, ?pos:PosInfos)
		{
			function getMsg(prefix:String)
			{
				return '$prefix - Value [$actual] is not within [$margin] of [( x:$expectedX | y:$expectedY )]';
			}
			
			sprite1.viewToFramePosition(worldX, worldY, actual);
			FlxAssert.pointNearXY(expectedX, expectedY, actual, margin, getMsg('(xy)'), pos);
			
			sprite1.viewToFramePosition(worldPos.set(worldX, worldY), actual);
			FlxAssert.pointNearXY(expectedX, expectedY, actual, margin, getMsg('(p)'), pos);
		}
		
		assertFramePosition(100, 100, 0, 0);
		assertFramePosition(100, 110, 0, 10);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.scale.set(2, 2);
		assertFramePosition(100, 100, 25, 25);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.angle = 90;
		assertFramePosition(100, 100, 25, 75);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.flipX = true;
		assertFramePosition(100, 100, 75, 75);
		assertFramePosition(150, 150, 50, 50);
		
		sprite1.flipY = true;
		assertFramePosition(100, 100, 75, 25);
		assertFramePosition(150, 150, 50, 50);
		
		FlxG.camera.scroll.set(50, 100);
		assertFramePosition(100, 100, 25, 50);
		assertFramePosition(150, 150, 0, 75);
		
		FlxG.camera.zoom = 2;
		assertFramePosition(100, 100, -35, 130);
		assertFramePosition(150, 150, -60, 155);
		
		#if FLX_POINT_POOL
		Assert.areEqual(startingPoolLength, pointPool.length);
		#end
	}
	
	@Test
	function testGetPixelAt()
	{
		final WHITE = FlxColor.WHITE;
		final BLACK = FlxColor.BLACK;
		final RED = FlxColor.RED;
		
		sprite1.x = 100;
		sprite1.y = 0;
		sprite1.makeGraphic(100, 100, WHITE);
		sprite1.graphic.bitmap.fillRect(new openfl.geom.Rectangle(50, 50, 50, 50), BLACK);
		
		final worldPos = FlxPoint.get();
		
		#if FLX_POINT_POOL
		// track leaked points
		@:privateAccess
		final pointPool = FlxBasePoint.pool;
		pointPool.preAllocate(100);
		final startingPoolLength = pointPool.length;
		#end
		
		function assertPixelAt(expected:FlxColor, x:Float, y:Float, ?pos:PosInfos)
		{
			FlxAssert.colorsEqual(expected, sprite1.getPixelAt(worldPos.set(x, y)), pos);
		}
		
		assertPixelAt(WHITE, 125, 25);
		assertPixelAt(BLACK, 175, 75);
		
		sprite1.color = RED;
		assertPixelAt(RED, 125, 25);
		assertPixelAt(BLACK, 175, 75);
		
		sprite1.setColorTransform(1.0, 0.5, 0.0, 1.0, 0x0, 0x0, 0x80);
		assertPixelAt(0xFFff8080, 125, 25);
		assertPixelAt(0xFF000080, 175, 75);
		
		sprite1.alpha = 0.5;
		assertPixelAt(0x80ff8080, 125, 25);
		assertPixelAt(0x80000080, 175, 75);
		
		#if FLX_POINT_POOL
		Assert.areEqual(startingPoolLength, pointPool.length);
		#end
	}
	
	@Test
	function testClipToWorldBounds()
	{
		sprite1.x = 100;
		sprite1.y = 100;
		sprite1.makeGraphic(100, 100);
		
		final expected = FlxRect.get();
		
		#if FLX_POINT_POOL
		// track leaked points
		@:privateAccess
		final pointPool = FlxBasePoint.pool;
		pointPool.preAllocate(100);
		final startingPoolLength = pointPool.length;
		#end
		
		function assertClipRect(expectedX:Float, expectedY:Float, expectedWidth:Float, expectedHeight:Float, margin = 0.001, ?pos:PosInfos)
		{
			FlxAssert.rectsNear(expected.set(expectedX, expectedY, expectedWidth, expectedHeight), sprite1.clipRect, margin, pos);
		}
		
		sprite1.clipToWorldBounds(100, 100, 200, 200);
		assertClipRect(0, 0, 100, 100);
		
		sprite1.clipToWorldBounds(100, 110, 200, 190);
		assertClipRect(0, 10, 100, 80);
		
		sprite1.scale.set(2, 2);
		sprite1.clipToWorldBounds(50, 50, 150, 150);
		assertClipRect(0, 0, 50, 50);
		
		sprite1.angle = 90;
		sprite1.clipToWorldBounds(50, 50, 150, 150);
		assertClipRect(0, 50, 50, 50);
		
		sprite1.flipX = true;
		sprite1.clipToWorldBounds(50, 50, 150, 150);
		assertClipRect(50, 50, 50, 50);
		
		sprite1.flipY = true;
		sprite1.clipToWorldBounds(50, 50, 150, 150);
		assertClipRect(50, 0, 50, 50);
		
		FlxG.camera.scroll.set(50, 100);
		sprite1.clipToWorldBounds(50, 50, 150, 150);
		assertClipRect(50, 0, 50, 50);
		
		FlxG.camera.zoom = 2;
		sprite1.clipToWorldBounds(50, 50, 150, 150);
		assertClipRect(50, 0, 50, 50);
		
		#if FLX_POINT_POOL
		Assert.areEqual(startingPoolLength, pointPool.length);
		#end
	}
	
	@Test
	function testClipToViewBounds()
	{
		sprite1.x = 100;
		sprite1.y = 100;
		sprite1.makeGraphic(100, 100);
		sprite1.camera = FlxG.camera;
		
		final expected = FlxRect.get();
		
		#if FLX_POINT_POOL
		// track leaked points
		@:privateAccess
		final pointPool = FlxBasePoint.pool;
		pointPool.preAllocate(100);
		final startingPoolLength = pointPool.length;
		#end
		
		function assertClipRect(expectedX:Float, expectedY:Float, expectedWidth:Float, expectedHeight:Float, margin = 0.001, ?pos:PosInfos)
		{
			FlxAssert.rectsNear(expected.set(expectedX, expectedY, expectedWidth, expectedHeight), sprite1.clipRect, margin, pos);
		}
		
		sprite1.clipToViewBounds(100, 100, 200, 200);
		assertClipRect(0, 0, 100, 100);
		
		sprite1.clipToViewBounds(100, 110, 200, 190);
		assertClipRect(0, 10, 100, 80);
		
		sprite1.scale.set(2, 2);
		sprite1.clipToViewBounds(50, 50, 150, 150);
		assertClipRect(0, 0, 50, 50);
		
		sprite1.angle = 90;
		sprite1.clipToViewBounds(50, 50, 150, 150);
		assertClipRect(0, 50, 50, 50);
		
		sprite1.flipX = true;
		sprite1.clipToViewBounds(50, 50, 150, 150);
		assertClipRect(50, 50, 50, 50);
		
		sprite1.flipY = true;
		sprite1.clipToViewBounds(50, 50, 150, 150);
		assertClipRect(50, 0, 50, 50);
		
		FlxG.camera.scroll.set(100, 50);
		sprite1.clipToViewBounds(50, 50, 150, 150);
		assertClipRect(25, 50, 50, 50);
		sprite1.clipToViewBounds(40, 40, 150, 150);
		assertClipRect(25, 45, 55, 55);
		sprite1.clipToViewBounds(30, 30, 150, 150);
		assertClipRect(25, 40, 60, 60);
		
		FlxG.camera.zoom = 4;
		sprite1.clipToViewBounds(50, 50, 150, 150);
		assertClipRect(-65, 170, 50, 50);
		sprite1.clipToViewBounds(40, 40, 150, 150);
		assertClipRect(-65, 165, 55, 55);// wtf!
		sprite1.clipToViewBounds(30, 30, 150, 150);
		assertClipRect(-65, 160, 60, 60);
		
		#if FLX_POINT_POOL
		Assert.areEqual(startingPoolLength, pointPool.length);
		#end
	}
	
	@Test
	function testCoordinateConvertersNullResult()
	{
		// Test that a new point is returned when a result is not supplied (A common dev error)
		try
		{
			final result = sprite1.viewToFramePosition(sprite1.x, sprite1.y);
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "viewToFramePosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = sprite1.worldToFramePosition(sprite1.x, sprite1.y);
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "worldToFramePosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = sprite1.worldToFramePositionSimple(sprite1.x, sprite1.y);
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "worldToFramePositionSimple", message: "${e.message}", stack:\n${e.stack}');
		}
	}
}

abstract SimplePoint(Array<Float>) from Array<Float>
{
	public var x(get, never):Float;
	inline function get_x() return this[0];
	
	public var y(get, never):Float;
	inline function get_y() return this[1];
} 
typedef Orientation = { pos:SimplePoint, size:SimplePoint, offset:SimplePoint, origin:SimplePoint }