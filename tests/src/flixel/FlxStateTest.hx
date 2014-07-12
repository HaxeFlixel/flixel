package flixel;

import flixel.FlxG;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxStateTest extends FlxTest
{
	var state:FlxState;
	
	@Before
	function before()
	{
		state = new FlxState();
		destroyable = state;
	}
	
	@AsyncTest
	function testSwitchState(factory:AsyncFactory)
	{
		Assert.areNotEqual(state, FlxG.state);
		
		FlxG.switchState(state);
		
		delay(this, factory, function() { 
			Assert.areEqual(state, FlxG.state); 
		});
	}
}