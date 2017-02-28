package tests.unit.src.flixel.input.actions;
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
	
	var aState:FlxObject;
	var aInput:FlxActionInputAnalog;
	
	@Before
	function before():Void 
	{
		digital = new FlxActionDigital("digital", null);
		analog = new FlxActionAnalog("analog", null);
		
		dState = new FlxInput<Int>(0);
		dInput = new FlxActionInputDigitalIFlxInput(clicker, FlxInputState.JUST_PRESSED);
		
		aState = new FlxObject();
		aInput = new FlxActionInputAnalogObjectXY(aState, FlxAnalogAxis.EITHER, aState);
		
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
		
		Assert.isTrue(digital.inputs.length == 1);
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
		
		//digital
		
		var value = 0;
		
		digital.callback = function (a:FlxActionDigital)
		{
			value++;
		}
		
		pulseDigital();
		digital.check();
		
		Assert.isTrue(value == 1);
		
		value = 0;
		digital.callback = null;
		
		pulseDigital();
		digital.check();
		
		Assert.isTrue(value == 0);
		
		//analog
		
		value = 0;
		
		analog.callback = function (a:FlxActionAnalog)
		{
			value++;
		}
		
		pulseAnalog(10, 0);
		analog.check();
		
		Assert.isTrue(value == 1);
		
		value = 0;
		analog.callback = null;
		
		pulseAnalog();
		analog.check();
		
		Assert.isTrue(value == 0);
	}
	
	@Test
	function testCheckAndFireDigital()
	{
		clearDigital();
		
		Assert.isFalse(digital.check());
		Assert.isFalse(digital.fire);
		
		pulseDigital();
		
		Assert.isTrue(digital.check());
		Assert.isTrue(digital.fire);
	}
	
	@Test
	function testCheckAndFireAnalog()
	{
		clearAnalog();
		
		Assert.isFalse(analog.check());
		Assert.isFalse(analog.fire);
		
		pulseAnalog();
		
		Assert.isTrue(analog.check());
		Assert.isTrue(analog.fire);
	}
	
	@Test
	function testDestroy()
	{
		var d:FlxActionDigital = new FlxActionDigital("test", function()
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
		
		pulseAnalog();
		
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
		dState.release();
		dState.update();
		dState.press();
		dState.update();
	}
	
	private function clearAnalog(X:Float, Y:Float)
	{
		aState.x = 0;
		aState.y = 0;
		aState.update(0);
		aState.x = 0;
		aState.y = 0;
		aState.update(0);
	}
	
	private function pulseAnalog(X:Float, Y:Float)
	{
		aState.x = 0;
		aState.y = 0;
		aState.update(0);
		aState.x = X;
		aState.y = Y;
		aState.update(0);
	}
	
	private function moveAnalog(X:Float, Y:Float)
	{
		aState.x = X;
		aState.y = Y;
		aState.update(0);
	}
}