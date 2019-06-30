package flixel;

import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.math.FlxMath;
import massive.munit.Assert;

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
	@Ignore("Failing on Travis right now for some reason")
	function testUpdateTouchingFlagsHorizontal():Void
	{
		var object1 = new FlxObject(0, 0, 10, 10);
		var object2 = new FlxObject(20, 2, 10, 6);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		object1.velocity.set(20, 0);
		step(20);
		Assert.isTrue(FlxG.overlap(object1, object2, null, FlxObject.updateTouchingFlags));
		Assert.areEqual(FlxObject.RIGHT, object1.touching);
		Assert.areEqual(FlxObject.LEFT, object2.touching);
	}

	@Test // #1556
	@Ignore("Failing on Travis right now for some reason")
	function testUpdateTouchingFlagsVertical():Void
	{
		var object1 = new FlxObject(0, 0, 10, 10);
		var object2 = new FlxObject(2, 20, 10, 6);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		object1.velocity.set(0, 20);
		step(20);
		Assert.isTrue(FlxG.overlap(object1, object2, null, FlxObject.updateTouchingFlags));
		Assert.areEqual(FlxObject.DOWN, object1.touching);
		Assert.areEqual(FlxObject.UP, object2.touching);
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
		Assert.areEqual(FlxObject.NONE, object1.touching);
		Assert.areEqual(FlxObject.NONE, object2.touching);
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
		switchState(new CollisionState());

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
	function testOverlapsPoint()
	{
		overlapsPointInScreenSpace(true);
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
