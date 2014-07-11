package flixel;

import flixel.FlxG;
import helper.TestUtil;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxSubStateTest extends FlxTest
{
	var subState1:FlxSubState;
	var subState2:FlxSubState;
	
	@Before
	function before()
	{
		subState1 = new FlxSubState();
		subState2 = new FlxSubState();
	}
	
	@Test
	function testOpenSubState()
	{
		FlxG.state.openSubState(subState1);
		TestUtil.step();
		
		Assert.areEqual(subState1, FlxG.state.subState);
	}
	
	@Test // issue 1219
	function testCloseOpenSameFrame()
	{
		FlxG.state.openSubState(subState1);
		TestUtil.step();
		
		FlxG.state.openSubState(subState2);
		subState1.close();
		TestUtil.step();
		
		Assert.areEqual(subState2, FlxG.state.subState);
	}
	
	@Test
	function testDestroy():Void
	{
		TestUtil.testDestroy(subState1);
	}
}