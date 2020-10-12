package flixel.input.actions;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputType;
import massive.munit.Assert;

class FlxActionInputTest extends FlxTest
{
	@Before
	function before() {}

	@Test
	function testCompareState()
	{
		var fake = new FakeFlxActionInput();

		inline function compare(a:FlxInputState, b:FlxInputState):Bool
		{
			return fake.testCompareState(a, b);
		}

		Assert.isTrue(compare(FlxInputState.PRESSED, FlxInputState.PRESSED));
		Assert.isTrue(compare(FlxInputState.PRESSED, FlxInputState.JUST_PRESSED));
		Assert.isFalse(compare(FlxInputState.PRESSED, FlxInputState.RELEASED));
		Assert.isFalse(compare(FlxInputState.PRESSED, FlxInputState.JUST_RELEASED));

		Assert.isTrue(compare(FlxInputState.RELEASED, FlxInputState.RELEASED));
		Assert.isTrue(compare(FlxInputState.RELEASED, FlxInputState.JUST_RELEASED));
		Assert.isFalse(compare(FlxInputState.RELEASED, FlxInputState.PRESSED));
		Assert.isFalse(compare(FlxInputState.RELEASED, FlxInputState.JUST_PRESSED));

		Assert.isTrue(compare(FlxInputState.JUST_RELEASED, FlxInputState.JUST_RELEASED));
		Assert.isFalse(compare(FlxInputState.JUST_RELEASED, FlxInputState.RELEASED));
		Assert.isFalse(compare(FlxInputState.JUST_RELEASED, FlxInputState.PRESSED));
		Assert.isFalse(compare(FlxInputState.JUST_RELEASED, FlxInputState.JUST_PRESSED));

		Assert.isTrue(compare(FlxInputState.JUST_PRESSED, FlxInputState.JUST_PRESSED));
		Assert.isFalse(compare(FlxInputState.JUST_PRESSED, FlxInputState.RELEASED));
		Assert.isFalse(compare(FlxInputState.JUST_PRESSED, FlxInputState.PRESSED));
		Assert.isFalse(compare(FlxInputState.JUST_PRESSED, FlxInputState.JUST_RELEASED));
	}
}

class FakeFlxActionInput extends FlxActionInput
{
	public function new()
	{
		super(FlxInputType.DIGITAL, FlxInputDevice.OTHER, 0, FlxInputState.PRESSED);
	}

	public function testCompareState(a:FlxInputState, b:FlxInputState):Bool
	{
		return compareState(a, b);
	}
}
