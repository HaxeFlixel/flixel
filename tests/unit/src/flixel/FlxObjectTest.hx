package flixel;

import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.display.BitmapData;

class FlxObjectTest extends FlxTest
{
	var object1:FlxObject;
	var object2:FlxObject;
	var tilemap:FlxTilemap;

	@Before
	function before()
	{
		object1 = new FlxObject();
		object2 = new FlxObject();
		tilemap = new FlxTilemap();
	}

	@Test
	function testXAfterAddingToState():Void
	{
		var object = new FlxObject(33, 445);
		FlxG.state.add(object);

		Assert.areEqual(object.x, 33);
	}

	@Test
	function testYAfterAddingToState():Void
	{
		var object = new FlxSprite(433, 444);
		FlxG.state.add(object);

		Assert.areEqual(object.y, 444);
	}

	@Test
	function testSetPositionAfterAddingToState()
	{
		var object = new FlxSprite(433, 444);
		FlxG.state.add(object);

		object.setPosition(333, 332);

		Assert.areEqual(object.x, 333);
		Assert.areEqual(object.y, 332);

		object.setPosition(453, 545);

		Assert.areEqual(object.x, 453);
		Assert.areEqual(object.y, 545);
	}

	@Test
	function testOverlap():Void
	{
		var object1 = new FlxObject(0, 0, 10, 10);
		var object2 = new FlxObject(0, 0, 10, 10);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		step();

		Assert.isTrue(FlxG.overlap(object1, object2));

		// Move the objects away from each other
		object1.velocity.x = 2000;
		object2.velocity.x = -2000;

		step(60);
		Assert.isFalse(FlxG.overlap(object1, object2));
	}
	
	@Test
	function testSeparateX():Void
	{
		final object1 = new FlxObject(5, 0, 10, 10);
		object1.last.x = 10;
		final object2 = new FlxObject(0, 0, 10, 10);
		object2.last.x = -5;
		
		Assert.areEqual(-5, FlxObject.computeOverlapX(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapY(object1, object2));
		Assert.isTrue(FlxG.overlap(object1, object2));
		
		Assert.isTrue(FlxObject.separateX(object1, object2));
		
		Assert.areEqual(0, FlxObject.computeOverlapX(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapY(object1, object2));
		Assert.isFalse(FlxG.overlap(object1, object2));
		Assert.isTrue(object1.x > object2.x);
	}
	
	@Test
	function testSeparateY():Void
	{
		final object1 = new FlxObject(0, 5, 10, 10);
		object1.last.y = 10;
		final object2 = new FlxObject(0, 0, 10, 10);
		object2.last.y = -5;
		
		Assert.areEqual(-5, FlxObject.computeOverlapY(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapX(object1, object2));
		
		Assert.isTrue(FlxObject.separateY(object1, object2));
		
		Assert.areEqual(0, FlxObject.computeOverlapY(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapX(object1, object2));
		Assert.isFalse(FlxG.overlap(object1, object2));
		Assert.isTrue(object1.y > object2.y);
	}
	
	@Test
	function testSeparateOnBothAxisNewlyOverlapping():Void
	{
		final object1 = new FlxObject(11, -1, 10, 10);
		final object2 = new FlxObject(0, 10, 10, 10);
		object2.immovable = true;
		
		object1.setPosition(9, 2);
		
		Assert.isTrue(FlxObject.separate(object1, object2));
		// X-axis resolves first and no collision
		Assert.areEqual(9, object1.x);
		// Y-axis resolves second and is stopped by collision
		Assert.areEqual(0, object1.y);
	}
	
	@Test
	function testSeparateXFromOpposite():Void
	{
		/*
		 * NOTE: An odd y value on either may result in a rounding error where the second
		 * computeOverlapY is 0 but FlxG.overlap returns true
		 */
		final object1 = new FlxObject(20, 0, 10, 10);
		object1.last.x = object1.x - 30;
		final object2 = new FlxObject(0, 0, 10, 10);
		object2.last.x = object2.x + 30;
		
		Assert.areEqual(30, FlxObject.computeOverlapX(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapY(object1, object2));
		
		Assert.isTrue(FlxObject.separateX(object1, object2));
		
		Assert.areEqual(0, FlxObject.computeOverlapX(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapY(object1, object2));
		Assert.isFalse(FlxG.overlap(object1, object2));
		Assert.isTrue(object1.x < object2.x);
	}
	
	@Test
	function testSeparateYFromOpposite():Void
	{
		/*
		 * NOTE: An odd y value on either may result in a rounding error where the second
		 * computeOverlapY is 0 but FlxG.overlap returns true
		 */
		final object1 = new FlxObject(0, 20, 10, 10);
		object1.last.y = object1.y - 30;
		final object2 = new FlxObject(0, 0, 10, 10);
		object2.last.y = object2.y + 30;
		
		Assert.areEqual(30, FlxObject.computeOverlapY(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapX(object1, object2));
		
		Assert.isTrue(FlxObject.separateY(object1, object2));
		
		Assert.areEqual(0, FlxObject.computeOverlapY(object1, object2));
		Assert.areEqual(0, FlxObject.computeOverlapX(object1, object2));
		Assert.isFalse(FlxG.overlap(object1, object2));
		Assert.isTrue(object1.y < object2.y);
	}
	
	@Test // closes #1564, tests #1561
	function testSeparateYAfterX():Void
	{
		var object1 = new FlxObject(8, 4, 8, 12);
		var level = new FlxTilemap();
		level.loadMapFromCSV("0,0,1\n0,0,1\n1,1,1", new BitmapData(16, 8));

		FlxG.state.add(object1);
		FlxG.state.add(level);
		object1.velocity.set(100, 100);
		step();

		Assert.isTrue(FlxG.collide(object1, level));
		Assert.isTrue(FlxMath.equal(16.0, object1.y + object1.height, 0.0002));
	}

	@Test
	// @Ignore("Failing on Travis right now for some reason")
	function testUpdateTouchingFlagsHorizontal():Void
	{
		var object1 = new FlxObject(5, 0, 10, 10);
		var object2 = new FlxObject(20, 0, 10, 10);
		object1.velocity.set(10, 0);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		step(60);
		Assert.isTrue(FlxG.overlap(object1, object2, null, FlxObject.updateTouchingFlags));
		Assert.isTrue (object1.touching.has(RIGHT));
		Assert.isTrue (object2.touching.has(LEFT));
		Assert.isFalse(object1.touching.has(DOWN));
		Assert.isFalse(object2.touching.has(UP));
	}

	@Test // #1556
	// @Ignore("Failing on Travis right now for some reason")
	function testUpdateTouchingFlagsVertical():Void
	{
		var object1 = new FlxObject(0, 5, 10, 10);
		var object2 = new FlxObject(0, 20, 10, 10);
		object1.velocity.set(0, 10);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		step(60);
		Assert.isTrue(FlxG.overlap(object1, object2, null, FlxObject.updateTouchingFlags));
		Assert.isTrue (object1.touching.has(DOWN));
		Assert.isTrue (object2.touching.has(UP));
		Assert.isFalse(object1.touching.has(RIGHT));
		Assert.isFalse(object2.touching.has(LEFT));
	}

	@Test // #1556
	function testUpdateTouchingFlagsNoOverlap():Void
	{
		// Position objects far from each other
		var object1 = new FlxObject(0, 0, 10, 10);
		var object2 = new FlxObject(2000, 20, 10, 6);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		object1.velocity.set(0, 20);
		step(20);
		Assert.isFalse(FlxG.overlap(object1, object2, null, FlxObject.updateTouchingFlags));
		Assert.areEqual(FlxDirectionFlags.NONE, object1.touching);
		Assert.areEqual(FlxDirectionFlags.NONE, object2.touching);
	}

	@Test
	function testVelocityCollidingWithObject():Void
	{
		object2.setSize(100, 10);
		velocityCollidingWith(object2);
	}

	@Test
	function testVelocityCollidingWithTilemap():Void
	{
		tilemap.loadMapFromCSV("1, 1, 1, 1, 1, 1, 1", FlxGraphic.fromClass(GraphicAuto));
		velocityCollidingWith(tilemap);
	}

	function velocityCollidingWith(ground:FlxObject)
	{
		switchState(CollisionState.new);

		ground.setPosition(0, 10);
		object1.setSize(10, 10);
		object1.x = 50;

		FlxG.state.add(object1);
		FlxG.state.add(ground);

		object1.velocity.set(100, 0);

		var lastPos = object1.getPosition();
		step(60, function()
		{
			Assert.isTrue(lastPos.x < object1.x);
			Assert.isTrue(lastPos.y == object1.y);
		});
	}

	@Test // #1313
	function testSetVariablesInReviveOverride()
	{
		object1 = new OverriddenReviveObject();
		object1.reset(0, 0);

		Assert.isTrue(FlxPoint.get(10, 10).equals(object1.getPosition()));
		Assert.isTrue(FlxPoint.get(10, 10).equals(object1.velocity));
	}

	@Test
	function testOverlapsPointInScreenSpace()
	{
		overlapsPointInScreenSpace(true);
	}
	
	@Test
	function testOverlapsPointNotInScreenSpace()
	{
		overlapsPointInScreenSpace(false);
	}

	function overlapsPointInScreenSpace(inScreenSpace:Bool)
	{
		var overlapsPoint = object1.overlapsPoint.bind(_, inScreenSpace, null);
		object1.setPosition(-5, -5);
		object1.setSize(10, 10);

		var rect = object1.getHitbox();
		var topLeft = FlxPoint.get(rect.left, rect.top);
		var bottomLeft = FlxPoint.get(rect.left, rect.bottom - 1);
		var topRight = FlxPoint.get(rect.right - 1, rect.top);
		var bottomRight = FlxPoint.get(rect.right - 1, rect.bottom - 1);

		function assertTrue(p)
			Assert.isTrue(overlapsPoint(p));
		assertTrue(topLeft);
		assertTrue(bottomLeft);
		assertTrue(topRight);
		assertTrue(bottomRight);

		function assertFalse(p)
			Assert.isFalse(overlapsPoint(p));
		assertFalse(topLeft.add(-1, -1));
		assertFalse(bottomLeft.add(-1, 1));
		assertFalse(topRight.add(1, -1));
		assertFalse(bottomRight.add(1, 1));
	}

	@Test
	function testIsOnScreen()
	{
		var object = new FlxObject(0, 0, 1, 1);

		function assertOnScreen(x, y)
		{
			object.setPosition(x, y);
			Assert.isTrue(object.isOnScreen());
		}
		function assertNotOnScreen(x, y)
		{
			object.setPosition(x, y);
			Assert.isFalse(object.isOnScreen());
		}

		assertOnScreen(0, 0);
		assertNotOnScreen(-1, 0);
		assertNotOnScreen(0, -1);

		assertOnScreen(FlxG.width - 1, 0);
		assertNotOnScreen(FlxG.width, 0);

		assertOnScreen(0, FlxG.height - 1);
		assertNotOnScreen(0, FlxG.height);
	}
	
	@Test
	function testScreenCenter()
	{
		var center = FlxPoint.get((FlxG.width - object1.width) / 2, (FlxG.height - object1.height) / 2);
		var offCenter = center.copyTo().add(1000, 1000);
		
		object1.setPosition(offCenter.x, offCenter.y);
		object1.screenCenter(X);
		Assert.areEqual(object1.x, center.x);
		Assert.areEqual(object1.y, offCenter.y);

		object1.setPosition(offCenter.x, offCenter.y);
		object1.screenCenter(Y);
		Assert.areEqual(object1.x, offCenter.x);
		Assert.areEqual(object1.y, center.y);

		object1.setPosition(offCenter.x, offCenter.y);
		object1.screenCenter(XY);
		Assert.areEqual(object1.x, center.x);
		Assert.areEqual(object1.y, center.y);

		object1.setPosition(offCenter.x, offCenter.y);
		object1.screenCenter();
		Assert.areEqual(object1.x, center.x);
		Assert.areEqual(object1.y, center.y);
		
		offCenter.put();
		center.put();
	}

	@Test
	function testGetRotatedBounds()
	{
		var expected = FlxRect.get();
		var rect = FlxRect.get();
		
		var object = new FlxObject(0, 0, 1, 1);
		
		object.angle = 45;
		rect = object.getRotatedBounds(rect);
		var sqrt2 = Math.sqrt(2);
		expected.set(-0.5 * sqrt2, 0, sqrt2, sqrt2);
		FlxAssert.rectsNear(expected, rect);
		
		var w = object.width = 20;
		var h = object.height = 15;
		object.angle =  90;
		FlxAssert.rectsNear(expected.set(-h, 0, h, w), object.getRotatedBounds(rect), 0.0001);
		object.angle = 180;
		FlxAssert.rectsNear(expected.set(-w, -h, w, h), object.getRotatedBounds(rect), 0.0001);
		object.angle = 270;
		FlxAssert.rectsNear(expected.set(0, -w, h, w), object.getRotatedBounds(rect), 0.0001);
		object.angle = 360;
		FlxAssert.rectsNear(expected.set(0, 0, w, h), object.getRotatedBounds(rect), 0.0001);
		
		object.width = 1;
		object.height = 1;
		object.angle = 210;
		rect = object.getRotatedBounds(rect);
		var cos30 = Math.cos(30/180*Math.PI);
		var sumSinCos30 = 0.5 + cos30;//sin30 = 0.5
		expected.set(-cos30, -sumSinCos30, sumSinCos30, sumSinCos30);
		FlxAssert.rectsNear(expected, rect);
		
		expected.put();
	}
}

class CollisionState extends FlxState
{
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(); // collide everything
	}
}

class OverriddenReviveObject extends FlxObject
{
	override public function revive()
	{
		super.revive();
		velocity.set(10, 10);
		setPosition(10, 10);
	}
}
