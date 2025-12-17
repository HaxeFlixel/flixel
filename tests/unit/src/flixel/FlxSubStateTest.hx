package flixel;

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

	@Test // #1971
	function testOpenPersistentSubStateFromNewParent()
	{
		FlxG.switchState(FlxStateNoDestroySubState.new.bind(false));
		step();
		FlxG.state.openSubState(subState1);
		step();

		Assert.areEqual(FlxG.state.subState, subState1);
		subState1.close();
		step();
		Assert.isNull(FlxG.state.subState);

		FlxG.switchState(FlxStateNoDestroySubState.new.bind(true));
		step();
		FlxG.state.openSubState(subState1);
		step();

		Assert.areEqual(FlxG.state.subState, subState1);
		subState1.close();
		step();
		Assert.isNull(FlxG.state.subState);
	}

	@Test // #2023
	function testCallbacks()
	{
		var opened = false;
		var closed = false;

		subState1.openCallback = function() opened = true;
		subState1.closeCallback = function() closed = true;

		FlxG.state.openSubState(subState1);
		step();

		Assert.isTrue(opened);
		Assert.isFalse(closed);

		FlxG.state.closeSubState();
		step();

		Assert.isTrue(opened);
		Assert.isTrue(closed);
	}
}

class FlxStateNoDestroySubState extends FlxState
{
	public function new (destroySubStates)
	{
		super();
		this.destroySubStates = destroySubStates;
	}
}