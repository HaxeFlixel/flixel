package flixel.input;

import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import massive.munit.Assert;

class FlxPointerTest
{
	var pointer:FlxPointer;
	
	@Before
	function before()
	{
		pointer = new FlxPointer();
		
		FlxG.game.x = 0;
		FlxG.game.y = 0;
		FlxG.camera.zoom = 1;
		FlxG.camera.scroll.set(0, 0);
		FlxG.camera.setSize(640, 480);
		FlxG.camera.setPosition(0, 0);
	}
	
	@Test
	function testZero()
	{
		final zero = FlxPoint.get(0, 0);
		pointer.setRawPositionUnsafe(0, 0);
		final p = FlxPoint.get();
		FlxAssert.pointsEqual(zero, pointer.getGamePosition(p));
		Assert.areEqual(0, pointer.gameX);
		Assert.areEqual(0, pointer.gameY);
		FlxAssert.pointsEqual(zero, pointer.getViewPosition(p));
		Assert.areEqual(0, pointer.viewX);
		Assert.areEqual(0, pointer.viewY);
		FlxAssert.pointsEqual(zero, pointer.getWorldPosition(p));
		Assert.areEqual(0, pointer.x);
		Assert.areEqual(0, pointer.y);
	}
	
	@Test
	function testNonZero()
	{
		final result = FlxPoint.get();
		final expected = FlxPoint.get();
		inline function p(x, y) return expected.set(x, y);
		
		//Note: FlxG.scaleMode may be different on github actions compared to local
		
		FlxG.game.x -= 10;
		FlxG.camera.zoom = 2.0;
		FlxG.camera.scroll.set(-5, -15);
		Assert.areEqual(1, FlxG.camera.initialZoom);
		Assert.areEqual(640, FlxG.camera.width);
		Assert.areEqual(480, FlxG.camera.height);
		FlxG.camera.setSize(560, 480);
		FlxG.camera.setPosition(20, 12);
		Assert.areEqual(140, FlxG.camera.viewMarginX);// 560/4
		Assert.areEqual(120, FlxG.camera.viewMarginY);// 480/4
		
		pointer.setRawPositionUnsafe(50 * FlxG.scaleMode.scale.x, 50 * FlxG.scaleMode.scale.y);
		FlxAssert.pointsEqual(p( 50,  50), pointer.getGamePosition  (result));
		FlxAssert.pointsEqual(p( 15,  19), pointer.getViewPosition  (result));
		FlxAssert.pointsEqual(p(150, 124), pointer.getWorldPosition (result));
		Assert.areEqual( 50, pointer.gameX);
		Assert.areEqual( 50, pointer.gameY);
		Assert.areEqual( 15, pointer.viewX);
		Assert.areEqual( 19, pointer.viewY);
		Assert.areEqual(150, pointer.x);
		Assert.areEqual(124, pointer.y);
	}
	
	@Test
	function testNullResult()
	{
		// Test that a new point is returned when a result is not supplied (A common dev error)
		try
		{
			final result = pointer.getPosition();
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "getPosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = pointer.getWorldPosition();
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "getWorldPosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = pointer.getViewPosition();
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "getViewPosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = pointer.getGamePosition();
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "getGamePosition", message: "${e.message}", stack:\n${e.stack}');
		}
	}
}
