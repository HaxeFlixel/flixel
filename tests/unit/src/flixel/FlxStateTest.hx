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
		final state = new FlxState();
		
		Assert.areNotEqual(state, FlxG.state);
		switchState(state);
		Assert.areEqual(state, FlxG.state);
		
		// Make sure this compiles
		switchState(FlxState.new);
		
		var nextState:FlxState = null;
		function createState()
		{
			return nextState = new FlxState();
		}
		
		Assert.areNotEqual(nextState, FlxG.state);
		switchState(createState);
		Assert.areEqual(nextState, FlxG.state);
	}

	@Test
	function testResetStateInstance()
	{
		var state = new TestState();
		switchState(state);
		Assert.areEqual(state, FlxG.state);

		resetState();
		Assert.areNotEqual(state, FlxG.state);
		Assert.isTrue((FlxG.state is TestState));
	}

	@Test
	function testResetStateFunction()
	{
		var nextState:TestState = null;
		function createState()
		{
			return nextState = new TestState();
		}
		
		switchState(createState);
		Assert.areEqual(nextState, FlxG.state);
		
		final oldState = nextState;
		resetState();
		Assert.areNotEqual(oldState, FlxG.state);
		Assert.areEqual(nextState, FlxG.state);
		Assert.isTrue((FlxG.state is TestState));
	}
	
	@Test // #1676
	function testCancelStateSwitchInstance()
	{
		var finalState = new FinalStateLegacy();
		switchState(finalState);
		Assert.areEqual(finalState, FlxG.state);

		switchState(new FlxState());
		Assert.areEqual(finalState, FlxG.state);

		resetState();
		Assert.areEqual(finalState, FlxG.state);
	}
	
	@Test // #1676
	function testCancelStateSwitchFunction()
	{
		switchState(FinalState.new);
		final finalState = FlxG.state;

		switchState(new FlxState());
		Assert.areEqual(finalState, FlxG.state);

		switchState(FlxState.new);
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

class FinalStateLegacy extends FlxState
{
	/* prevents state switches */
	override function switchTo(state)
	{
		return false;
	}
}

class FinalState extends FlxState
{
	/* prevents state switches */
	override function startOutro(onOutroComplete:()->Void)
	{
		// startOutro(onOutroComplete); 
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
