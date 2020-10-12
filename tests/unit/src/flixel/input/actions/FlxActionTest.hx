package flixel.input.actions;

import flixel.input.FlxInput;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInputAnalog;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.FlxInput.FlxInputState;
import massive.munit.Assert;

class FlxActionTest extends FlxTest
{
	var digital:FlxActionDigital;
	var analog:FlxActionAnalog;

	var digitalCalls:Int = 0;
	var analogCalls:Int = 0;

	var dState:FlxInput<Int>;
	var dInput:FlxActionInputDigital;

	var aInput:FlxActionInputAnalog;

	@Before
	function before():Void
	{
		digital = new FlxActionDigital("digital", null);
		analog = new FlxActionAnalog("analog", null);

		dState = new FlxInput<Int>(0);
		dInput = new FlxActionInputDigitalIFlxInput(dState, FlxInputState.PRESSED);

		aInput = new FlxActionInputAnalogMousePosition(FlxAnalogState.MOVED, FlxAnalogAxis.EITHER);

		digital.add(dInput);
		analog.add(aInput);
	}

	@Test
	function testAddRemoveInputs()
	{
		var oldInputs = digital.inputs.copy();
		digital.removeAll(false);

		var input1 = new FlxActionInputDigitalIFlxInput(null, FlxInputState.PRESSED);
		var input2 = new FlxActionInputDigitalIFlxInput(null, FlxInputState.PRESSED);
		var input3 = new FlxActionInputDigitalIFlxInput(null, FlxInputState.PRESSED);
		digital.add(input1);
		digital.add(input2);
		digital.add(input3);

		Assert.isTrue(digital.inputs.length == 3);

		digital.remove(input1, false);

		Assert.isTrue(digital.inputs.length == 2);
		Assert.isFalse(input1.destroyed);

		input1.destroy();

		Assert.isTrue(input1.destroyed);
		Assert.isTrue(digital.inputs[0] == input2);

		digital.removeAll(true);

		Assert.isTrue(digital.inputs.length == 0);
		Assert.isTrue(input2.destroyed);
		Assert.isTrue(input3.destroyed);

		digital.inputs = oldInputs;
	}

	@Ignore @Test
	function testCallbacks()
	{
		// digital w/ callback

		var value = 0;

		var d:FlxActionDigital = new FlxActionDigital("dCallback", function(a:FlxActionDigital)
		{
			value++;
		});
		d.add(dInput);
		pulseDigital();
		d.check();

		Assert.isTrue(value == 1);

		d.removeAll(false);
		d.destroy();

		// digital w/o callback

		value = 0;

		var d2:FlxActionDigital = new FlxActionDigital("dNoCallback", null);
		d2.add(dInput);
		pulseDigital();
		digital.check();

		Assert.isTrue(value == 0);

		d2.removeAll(false);
		d2.destroy();

		// analog w/ callback

		value = 0;

		var a:FlxActionAnalog = new FlxActionAnalog("aCallback", function(a:FlxActionAnalog)
		{
			value++;
		});
		a.add(aInput);
		pulseAnalog(a);
		var result = analog.check();

		Assert.isTrue(value == 1);

		a.removeAll(false);
		a.destroy();

		// analog w/o callback

		value = 0;

		var a2:FlxActionAnalog = new FlxActionAnalog("aNoCallback", null);
		a2.add(aInput);
		pulseAnalog(a2);
		analog.check();

		Assert.isTrue(value == 0);

		a2.removeAll(false);
		a2.destroy();
	}

	@Test
	function testCheckAndTriggeredDigital()
	{
		clearDigital();

		Assert.isFalse(digital.check());
		Assert.isFalse(digital.triggered);

		pulseDigital();

		Assert.isTrue(digital.check());
		Assert.isTrue(digital.triggered);
	}

	@Ignore @Test
	function testCheckAndTriggeredAnalog()
	{
		clearAnalog();

		Assert.isFalse(analog.check());
		Assert.isFalse(analog.triggered);

		pulseAnalog(analog);

		Assert.isTrue(analog.check());
		Assert.isTrue(analog.triggered);
	}

	@Test
	function testDestroyAction()
	{
		var d:FlxActionDigital = new FlxActionDigital("test", function(_d:FlxActionDigital)
		{
			var blah = true;
		});

		d.destroy();

		Assert.isTrue(d.callback == null);
		Assert.isTrue(d.inputs == null);
	}

	@Test
	function testMatch()
	{
		var other = new FlxActionDigital(digital.name, null);
		Assert.isTrue(digital.match(other));
	}

	@Test
	function testNoInputs()
	{
		var oldInputsD = digital.inputs.copy();
		var oldInputsA = analog.inputs.copy();

		digital.removeAll(false);
		analog.removeAll(false);

		pulseDigital();

		Assert.isFalse(digital.check());

		pulseAnalog(analog);

		Assert.isFalse(analog.check());

		digital.inputs = oldInputsD;
		analog.inputs = oldInputsA;
	}

	function clearDigital()
	{
		dState.release();
		dState.update();
	}

	function pulseDigital()
	{
		step();
		dState.release();
		dState.update();
		step();
		dState.press();
		dState.update();
	}

	function clearAnalog()
	{
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
	}

	@:access(flixel.input.mouse.FlxMouse)
	function pulseAnalog(a:FlxActionAnalog, X:Float = 10.0, Y:Float = 10.0)
	{
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
		step();
		a.update();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		step();
		a.update();
	}

	function moveAnalog(a:FlxActionAnalog, X:Float, Y:Float)
	{
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		a.update();
	}
}
