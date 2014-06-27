package flixel;

import flixel.FlxG;
import helper.TestUtil;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxStateTest extends FlxTest
{
	var state:FlxState;
	
	@Before
	function before()
	{
		state = new FlxState();
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
	
	@Test
	function testDestroy():Void
	{
		TestUtil.testDestroy(state);
	}
}