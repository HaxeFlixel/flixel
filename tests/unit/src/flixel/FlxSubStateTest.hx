package flixel;

import flixel.FlxG;
import massive.munit.Assert;

class FlxSubStateTest extends FlxTest
{
	var subState1:FlxSubState;
	var subState2:FlxSubState;
	
	@Before
	function before()
	{
		subState1 = new FlxSubState();
		subState2 = new FlxSubState();
		
		destroyable = subState1;
	}
	
	@Test
	function testOpenSubState()
	{
		FlxG.state.openSubState(subState1);
		step();
		
		Assert.areEqual(subState1, FlxG.state.subState);
	}
	
	@Test // #1219
	function testCloseOpenSameFrame()
	{
		FlxG.state.openSubState(subState1);
		step();
		
		FlxG.state.openSubState(subState2);
		subState1.close();
		step();
		
		Assert.areEqual(subState2, FlxG.state.subState);
	}
}