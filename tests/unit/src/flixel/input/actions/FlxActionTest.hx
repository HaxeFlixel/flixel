package flixel.input.actions;

import flixel.FlxObject;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionInputAnalog;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.FlxInput.FlxInputState;

import massive.munit.Assert;

/**
 * ...
 * @author 
 */
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
		dInput = new FlxActionInputDigitalIFlxInput(dState, FlxInputState.JUST_PRESSED);
		
		aInput = new FlxActionInputAnalogMousePosition(FlxAnalogState.MOVED, FlxAnalogAxis.EITHER);
		
		digital.addInput(dInput);
		analog.addInput(aInput);
	}
	
	@Test
	function testAddRemoveInputs()
	{
		var oldInputs = digital.inputs.copy();
		digital.removeAllInputs(false);
		
		var input1 = new FlxActionInputDigitalIFlxInput(null, FlxInputState.JUST_PRESSED);
		var input2 = new FlxActionInputDigitalIFlxInput(null, FlxInputState.JUST_PRESSED);
		var input3 = new FlxActionInputDigitalIFlxInput(null, FlxInputState.JUST_PRESSED);
		digital.addInput(input1);
		digital.addInput(input2);
		digital.addInput(input3);
		
		Assert.isTrue(digital.inputs.length == 3);
		
		digital.removeInput(input1, false);
		
		Assert.isTrue(digital.inputs.length == 2);
		Assert.isFalse(input1.destroyed);
		
		input1.destroy();
		
		Assert.isTrue(input1.destroyed);
		Assert.isTrue(digital.inputs[0] == input2);
		
		digital.removeAllInputs(true);
		
		Assert.isTrue(digital.inputs.length == 0);
		Assert.isTrue(input2.destroyed);
		Assert.isTrue(input3.destroyed);
		
		digital.inputs = oldInputs;
	}
	
	@Test
	function testCallbacks(){
		
		//digital w/ callback
		
		var value = 0;
		
		var d:FlxActionDigital = new FlxActionDigital("dCallback", function (a:FlxActionDigital)
			{
				value++;
			}
		);
		d.addInput(dInput);
		pulseDigital();
		d.check();
		
		Assert.isTrue(value == 1);
		
		d.removeAllInputs(false);
		d.destroy();
		
		//digital w/o callback
		
		value = 0;
		
		var d2:FlxActionDigital = new FlxActionDigital("dNoCallback", null);
		d2.addInput(dInput);
		pulseDigital();
		digital.check();
		
		Assert.isTrue(value == 0);
		
		d2.removeAllInputs(false);
		d2.destroy();
		
		//analog w/ callback
		
		value = 0;
		
		var a:FlxActionAnalog = new FlxActionAnalog("aCallback", function (a:FlxActionAnalog)
			{
				value++;
			}
		);
		a.addInput(aInput);
		pulseAnalog(a);
		var result = analog.check();
		
		Assert.isTrue(value == 1);
		
		a.removeAllInputs(false);
		a.destroy();
		
		//analog w/o callback
		
		value = 0;
		
		var a2:FlxActionAnalog = new FlxActionAnalog("aNoCallback", null);
		a2.addInput(aInput);
		pulseAnalog(a2);
		analog.check();
		
		Assert.isTrue(value == 0);
		
		a2.removeAllInputs(false);
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
	
	@Test
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
			}
		);
		
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
	function testNoInputs(){
		var oldInputsD = digital.inputs.copy();
		var oldInputsA = analog.inputs.copy();
		
		digital.removeAllInputs(false);
		analog.removeAllInputs(false);
		
		pulseDigital();
		
		Assert.isFalse(digital.check());
		
		pulseAnalog(analog);
		
		Assert.isFalse(analog.check());
		
		digital.inputs = oldInputsD;
		analog.inputs = oldInputsA;
	}
	
	/*****/
	
	private function clearDigital()
	{
		dState.release();
		dState.update();
		
	}
	
	private function pulseDigital()
	{
		step();
		dState.release();
		dState.update();
		step();
		dState.press();
		dState.update();
	}
	
	private function clearAnalog()
	{
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
	}
	
	@:access(flixel.input.mouse.FlxMouse)
	private function pulseAnalog(a:FlxActionAnalog, X:Float=10.0, Y:Float=10.0)
	{
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
		step();
		a.update();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		step();
		a.update();
	}
	
	private function moveAnalog(a:FlxActionAnalog, X:Float, Y:Float)
	{
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		a.update();
	}
}