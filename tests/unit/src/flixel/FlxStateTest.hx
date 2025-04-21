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
	@:haxe.warning("-WDeprecated")
	function testResetStateLegacy()
	{
		switchState(TestState.new);
		var state = FlxG.state;
		Assert.areEqual(state, FlxG.state);

		resetState();
		Assert.areNotEqual(state, FlxG.state);
		Assert.isTrue(FlxG.state is TestState);
	}

	@Test
	function testResetState()
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
	function testCancelStateSwitch()
	{
		switchState(FinalState.new);
		final finalState = FlxG.state;

		switchState(FlxState.new);
		Assert.areEqual(finalState, FlxG.state);

		resetState();
		Assert.areEqual(finalState, FlxG.state);
	}
	
	@Test
	function testOutro()
	{
		FlxG.switchState(OutroState.new);
		step();
		Assert.isType(FlxG.state, OutroState);
		
		FlxG.switchState(FlxState.new);
		step();
		Assert.isType(FlxG.state, OutroState);
		step();
		Assert.isNotType(FlxG.state, OutroState);
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
