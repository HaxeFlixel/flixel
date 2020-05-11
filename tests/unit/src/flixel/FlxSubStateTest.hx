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
		var state1 = new FlxState();
		var state2 = new FlxState();
		state1.destroySubStates = false;
		FlxG.switchState(state1);
		step();
		FlxG.state.openSubState(subState1);
		step();

		Assert.areEqual(state1.subState, subState1);
		subState1.close();
		step();
		Assert.isNull(state1.subState);

		FlxG.switchState(state2);
		step();
		FlxG.state.openSubState(subState1);
		step();

		Assert.areEqual(state2.subState, subState1);
		subState1.close();
		step();
		Assert.isNull(state2.subState);
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
