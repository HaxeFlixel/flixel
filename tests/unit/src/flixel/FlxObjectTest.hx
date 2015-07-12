package flixel;

import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
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
		
		//Move the objects away from eachother
		object1.velocity.x = 2000;
		object2.velocity.x = -2000;
		
		step(60);
		Assert.isFalse(FlxG.overlap(object1, object2));
	}
	
	@Test
	function testUpdateTouchingFlagsHorizontal():Void
	{
		var object1 = new FlxObject(0, 0, 10, 10);
		var object2 = new FlxObject(20, 2, 10, 6);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		object1.velocity.set(20, 0);
		step(20);
		Assert.isTrue(FlxG.overlap(object1, object2, null, FlxObject.updateTouchingFlags));
		Assert.areEqual(object1.touching, FlxObject.RIGHT);
		Assert.areEqual(object2.touching, FlxObject.LEFT);
	}
	
	@Test // #1556
	function testUpdateTouchingFlagsVertical():Void
	{
		var object1 = new FlxObject(0, 0, 10, 10);
		var object2 = new FlxObject(2, 20, 10, 6);
		FlxG.state.add(object1);
		FlxG.state.add(object2);
		object1.velocity.set(0, 20);
		step(20);
		Assert.isTrue(FlxG.overlap(object1, object2, null, FlxObject.updateTouchingFlags));
		Assert.areEqual(object1.touching, FlxObject.DOWN);
		Assert.areEqual(object2.touching, FlxObject.UP);
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
		Assert.areEqual(object1.touching, FlxObject.NONE);
		Assert.areEqual(object2.touching, FlxObject.NONE);
	}
	
	@Test
	function testVelocityCollidingWithObject()
	{
		object2.setSize(100, 10);
		velocityColldingWith(object2);
	}
	
	@Test
	function testVelocityCollidingWithTilemap()
	{
		tilemap.loadMapFromCSV("1, 1, 1, 1, 1, 1, 1", FlxGraphic.fromClass(GraphicAuto));
		velocityColldingWith(tilemap);
	}
	
	function velocityColldingWith(ground:FlxObject)
	{
		FlxG.switchState(new CollisionState());
		
		ground.setPosition(0, 10);
		object1.setSize(10, 10);
		object1.x = 50;
		
		step();
		
		FlxG.state.add(object1);
		FlxG.state.add(ground);
		
		object1.velocity.set(100, 0);
		
		var lastPos = object1.toPoint();
		step(60, function()
		{
			Assert.isTrue(lastPos.x < object1.x);
			Assert.isTrue(lastPos.y == object1.y);
		});
	}
	
	@Test // #1313
	function testSetVariablesInReviveOverride()
	{
		object1 = new OverridenReviveObject();
		object1.reset(0, 0);
		
		Assert.isTrue(FlxPoint.get(10, 10).equals(object1.toPoint()));
		Assert.isTrue(FlxPoint.get(10, 10).equals(object1.velocity));
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

class OverridenReviveObject extends FlxObject
{
	override public function revive()
	{
		super.revive();
		velocity.set(10, 10);
		setPosition(10, 10);
	}
}