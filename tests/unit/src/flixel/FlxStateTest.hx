package flixel;

import massive.munit.Assert;
import flixel.util.FlxTimer;

class FlxStateTest extends FlxTest
{
	@Before
	function before()
	{
		destroyable = new FlxState();
		resetGame();
	}

	@Test
	@Ignore // TODO: investigate
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
		Assert.isTrue((FlxG.state is TestState));
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
	
	@Test
	function testOutro()
	{
		var outroState = new OutroState();
		
		FlxG.switchState(outroState);
		step();
		Assert.areEqual(outroState, FlxG.state);
		
		FlxG.switchState(new FlxState());
		step();
		Assert.areEqual(outroState, FlxG.state);
		step();
		Assert.areNotEqual(outroState, FlxG.state);
		
	}
}

class FinalState extends FlxState
{
	override function switchTo(nextState:FlxState):Bool
	{
		return false;
	}
}

class OutroState extends FlxState
{
	override function startOutro(onOutroComplete:()->Void)
	{
		new FlxTimer().start(0, (_)->onOutroComplete());
	}
}

class TestState extends FlxState {}
