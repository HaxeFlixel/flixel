package flixel;

import flixel.FlxG;
import flixel.FlxState;
import massive.munit.Assert;

class FlxStateTest extends FlxTest
{
	@Before
	function before()
	{
		destroyable = new FlxState();
		resetGame();
	}
	
	@Test
	function testSwitchState()
	{
		var state = new FlxState();
		
		Assert.areNotEqual(state, FlxG.state);
		switchState(state);
		Assert.areEqual(state, FlxG.state);
	}
	
	@Test
	function testResetState()
	{
		var state = new TestState();
		switchState(state);
		Assert.areEqual(state, FlxG.state);
		
		resetState();
		Assert.areNotEqual(state, FlxG.state);
		Assert.isTrue(Std.is(FlxG.state, TestState));
	}
	
	@Test // #1676
	function testCancelStateSwitch()
	{
		var finalState = new FinalState();
		switchState(finalState);
		Assert.areEqual(finalState, FlxG.state);
		
		switchState(new FlxState());
		Assert.areEqual(finalState, FlxG.state);
		
		resetState();
		Assert.areEqual(finalState, FlxG.state);
	}
}

class FinalState extends FlxState
{
	override public function switchTo(nextState:FlxState):Bool 
	{
		return false;
	}
}

class TestState extends FlxState {}