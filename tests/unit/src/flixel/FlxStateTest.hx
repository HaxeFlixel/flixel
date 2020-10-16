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
	function testSwitchState()
	{
		var state = new FlxState();
		
		assertStatesAreNotEqual(state, FlxG.state);
		switchState(state);
		assertStatesAreEqual(state, FlxG.state);
	}

	@Test
	function testResetState()
	{
		var state = new TestState();
		switchState(state);
		assertStatesAreEqual(state, FlxG.state);

		resetState();
		assertStatesAreNotEqual(state, FlxG.state);
		Assert.isTrue((FlxG.state is TestState));
	}

	@Test // #1676
	function testCancelStateSwitch()
	{
		var finalState = new FinalState();
		switchState(finalState);
		assertStatesAreEqual(finalState, FlxG.state);

		switchState(new FlxState());
		assertStatesAreEqual(finalState, FlxG.state);

		resetState();
		assertStatesAreEqual(finalState, FlxG.state);
	}
	
	// Assert.areEqual seems to fail with states on neko and cpp so let's just avoid it
	inline function assertStatesAreEqual(state1:FlxState, state2:FlxState)
	{
		Assert.isTrue(state1 == state2, 'Value [$state1] was not equal to value [$state2]');
	}
	
	inline function assertStatesAreNotEqual(state1:FlxState, state2:FlxState)
	{
		Assert.isFalse(state1 == state2, 'Value [$state1] was equal to value [$state2]');
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
