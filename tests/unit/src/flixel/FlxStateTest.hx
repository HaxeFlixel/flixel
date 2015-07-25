package flixel;

import flixel.FlxG;
import massive.munit.Assert;

class FlxStateTest extends FlxTest
{
	var state:FlxState;
	
	@Before
	function before()
	{
		state = new FlxState();
		destroyable = state;
	}
	
	@Test
	function testSwitchState()
	{
		Assert.areNotEqual(state, FlxG.state);
		
		FlxG.switchState(state);
		
		step(10);
		Assert.areEqual(state, FlxG.state); 
	}
}