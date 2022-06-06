package flixel;

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
	function testResetState()
	{
		switchState(TestState.new);
		var state = FlxG.state;
		Assert.areEqual(state, FlxG.state);

		resetState();
		Assert.areNotEqual(state, FlxG.state);
		Assert.isTrue(FlxG.state is TestState);
	}

	@Test // #1676
	function testCancelStateSwitch()
	{
		
		switchState(FinalState.new);
		var finalState = FlxG.state;
		Assert.areEqual(finalState, FlxG.state);

		switchState(FlxState.new);
		Assert.areEqual(finalState, FlxG.state);

		resetState();
		Assert.areEqual(finalState, FlxG.state);
	}
}

class FinalState extends FlxState
{
	override function switchTo(nextState:()->FlxState):Bool
	{
		return false;
	}
}

class TestState extends FlxState {}
