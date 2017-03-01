package flixel.input.actions;
import flixel.FlxState;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalMouseWheel;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalGamepad;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalIFlxInput;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalKeyboard;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalMouse;
import flixel.input.FlxInput;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxActionInputDigitalTest.TestShell;
import flixel.input.actions.FlxActionInputDigitalTest.TestShellResult;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;


import massive.munit.Assert;

/**
 * ...
 * @author 
 */
class FlxActionInputDigitalTest extends FlxTest
{
	private var action:FlxActionDigital;
	
	private var value0:Int = 0;
	private var value1:Int = 0;
	private var value2:Int = 0;
	private var value3:Int = 0;
	
	@Before
	function before()
	{
		
	}
	
	@Test
	function testIFlxInput()
	{
		var test = new TestShell("");
		
		_testIFlxInput(test, true);
		_testIFlxInput(test, false);
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("press1.just").pass);
		Assert.isTrue(test.get("press1.value").pass);
		Assert.isTrue(test.get("press2.just").pass);
		Assert.isTrue(test.get("press2.value").pass);
		Assert.isTrue(test.get("release1.just").pass);
		Assert.isTrue(test.get("release1.value").pass);
		Assert.isTrue(test.get("release2.just").pass);
		Assert.isTrue(test.get("release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("press1.callbacks.just").pass);
		Assert.isTrue(test.get("press1.callbacks.value").pass);
		Assert.isTrue(test.get("press2.callbacks.just").pass);
		Assert.isTrue(test.get("press2.callbacks.value").pass);
		Assert.isTrue(test.get("release1.callbacks.just").pass);
		Assert.isTrue(test.get("release1.callbacks.value").pass);
		Assert.isTrue(test.get("release2.callbacks.just").pass);
		Assert.isTrue(test.get("release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("release2.callbacks.callback4").pass);
		
		test.destroy();
	}
	
	function _testIFlxInput(test:TestShell, callbacks:Bool)
	{
		var state = new FlxInput<Int>(0);
		
		var a = new FlxActionInputDigitalIFlxInput(state, FlxInputState.PRESSED);
		var b = new FlxActionInputDigitalIFlxInput(state, FlxInputState.JUST_PRESSED);
		var c = new FlxActionInputDigitalIFlxInput(state, FlxInputState.RELEASED);
		var d = new FlxActionInputDigitalIFlxInput(state, FlxInputState.JUST_RELEASED);
		
		var clear = clearFlxInput.bind(state);
		var click = clickFlxInput.bind(state);
		
		testInputStates(test, clear, click, a, b, c, d, callbacks);
	}
	
	@Test
	function testFlxMouseButton()
	{
		var test = new TestShell("");
		
		test.name = "left.";
		_testFlxMouseButton(test, FlxMouseButtonID.LEFT, false);
		_testFlxMouseButton(test, FlxMouseButtonID.LEFT, true);
		
		test.name = "right.";
		_testFlxMouseButton(test, FlxMouseButtonID.RIGHT, false);
		_testFlxMouseButton(test, FlxMouseButtonID.RIGHT, true);
		
		test.name = "middle.";
		_testFlxMouseButton(test, FlxMouseButtonID.MIDDLE, false);
		_testFlxMouseButton(test, FlxMouseButtonID.MIDDLE, true);
		
		//LEFT mouse button
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("left.press1.just").pass);
		Assert.isTrue(test.get("left.press1.value").pass);
		Assert.isTrue(test.get("left.press2.just").pass);
		Assert.isTrue(test.get("left.press2.value").pass);
		Assert.isTrue(test.get("left.release1.just").pass);
		Assert.isTrue(test.get("left.release1.value").pass);
		Assert.isTrue(test.get("left.release2.just").pass);
		Assert.isTrue(test.get("left.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("left.press1.callbacks.just").pass);
		Assert.isTrue(test.get("left.press1.callbacks.value").pass);
		Assert.isTrue(test.get("left.press2.callbacks.just").pass);
		Assert.isTrue(test.get("left.press2.callbacks.value").pass);
		Assert.isTrue(test.get("left.release1.callbacks.just").pass);
		Assert.isTrue(test.get("left.release1.callbacks.value").pass);
		Assert.isTrue(test.get("left.release2.callbacks.just").pass);
		Assert.isTrue(test.get("left.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("left.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("left.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("left.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("left.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("left.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("left.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("left.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("left.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("left.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("left.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("left.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("left.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("left.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("left.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("left.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("left.release2.callbacks.callback4").pass);
		
		//RIGHT mouse button
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("right.press1.just").pass);
		Assert.isTrue(test.get("right.press1.value").pass);
		Assert.isTrue(test.get("right.press2.just").pass);
		Assert.isTrue(test.get("right.press2.value").pass);
		Assert.isTrue(test.get("right.release1.just").pass);
		Assert.isTrue(test.get("right.release1.value").pass);
		Assert.isTrue(test.get("right.release2.just").pass);
		Assert.isTrue(test.get("right.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("right.press1.callbacks.just").pass);
		Assert.isTrue(test.get("right.press1.callbacks.value").pass);
		Assert.isTrue(test.get("right.press2.callbacks.just").pass);
		Assert.isTrue(test.get("right.press2.callbacks.value").pass);
		Assert.isTrue(test.get("right.release1.callbacks.just").pass);
		Assert.isTrue(test.get("right.release1.callbacks.value").pass);
		Assert.isTrue(test.get("right.release2.callbacks.just").pass);
		Assert.isTrue(test.get("right.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("right.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("right.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("right.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("right.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("right.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("right.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("right.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("right.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("right.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("right.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("right.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("right.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("right.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("right.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("right.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("right.release2.callbacks.callback4").pass);
		
		//MIDDLE mouse button
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("middle.press1.just").pass);
		Assert.isTrue(test.get("middle.press1.value").pass);
		Assert.isTrue(test.get("middle.press2.just").pass);
		Assert.isTrue(test.get("middle.press2.value").pass);
		Assert.isTrue(test.get("middle.release1.just").pass);
		Assert.isTrue(test.get("middle.release1.value").pass);
		Assert.isTrue(test.get("middle.release2.just").pass);
		Assert.isTrue(test.get("middle.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("middle.press1.callbacks.just").pass);
		Assert.isTrue(test.get("middle.press1.callbacks.value").pass);
		Assert.isTrue(test.get("middle.press2.callbacks.just").pass);
		Assert.isTrue(test.get("middle.press2.callbacks.value").pass);
		Assert.isTrue(test.get("middle.release1.callbacks.just").pass);
		Assert.isTrue(test.get("middle.release1.callbacks.value").pass);
		Assert.isTrue(test.get("middle.release2.callbacks.just").pass);
		Assert.isTrue(test.get("middle.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("middle.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("middle.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("middle.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("middle.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("middle.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("middle.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("middle.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("middle.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("middle.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("middle.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("middle.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("middle.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("middle.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("middle.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("middle.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("middle.release2.callbacks.callback4").pass);
		
		test.destroy();
	}
	
	function _testFlxMouseButton(test:TestShell, buttonID:FlxMouseButtonID, callbacks:Bool)
	{
		var button:FlxMouseButton = switch(buttonID)
		{
			case FlxMouseButtonID.LEFT: @:privateAccess FlxG.mouse._leftButton;
			case FlxMouseButtonID.RIGHT: @:privateAccess FlxG.mouse._rightButton;
			case FlxMouseButtonID.MIDDLE: @:privateAccess FlxG.mouse._middleButton;
			default: null;
		}
		
		var a = new FlxActionInputDigitalMouse(buttonID, FlxInputState.PRESSED);
		var b = new FlxActionInputDigitalMouse(buttonID, FlxInputState.JUST_PRESSED);
		var c = new FlxActionInputDigitalMouse(buttonID, FlxInputState.RELEASED);
		var d = new FlxActionInputDigitalMouse(buttonID, FlxInputState.JUST_RELEASED);
		
		var clear = clearMouseButton.bind(button);
		var click = clickMouseButton.bind(button);
		
		testInputStates(test, clear, click, a, b, c, d, callbacks);
	}
	
	@Test
	function testFlxKeyboard()
	{
		var test = new TestShell("");
		
		test.name = "A.";
		_testFlxKeyboard(test, FlxKey.A, false);
		_testFlxKeyboard(test, FlxKey.A, true);
		
		test.name = "CTRL.";
		_testFlxKeyboard(test, FlxKey.CONTROL, false);
		_testFlxKeyboard(test, FlxKey.CONTROL, true);
		
		test.name = "F1.";
		_testFlxKeyboard(test, FlxKey.F1, false);
		_testFlxKeyboard(test, FlxKey.F1, true);
		
		//A Key
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("A.press1.just").pass);
		Assert.isTrue(test.get("A.press1.value").pass);
		Assert.isTrue(test.get("A.press2.just").pass);
		Assert.isTrue(test.get("A.press2.value").pass);
		Assert.isTrue(test.get("A.release1.just").pass);
		Assert.isTrue(test.get("A.release1.value").pass);
		Assert.isTrue(test.get("A.release2.just").pass);
		Assert.isTrue(test.get("A.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("A.press1.callbacks.just").pass);
		Assert.isTrue(test.get("A.press1.callbacks.value").pass);
		Assert.isTrue(test.get("A.press2.callbacks.just").pass);
		Assert.isTrue(test.get("A.press2.callbacks.value").pass);
		Assert.isTrue(test.get("A.release1.callbacks.just").pass);
		Assert.isTrue(test.get("A.release1.callbacks.value").pass);
		Assert.isTrue(test.get("A.release2.callbacks.just").pass);
		Assert.isTrue(test.get("A.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("A.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("A.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("A.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("A.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("A.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("A.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("A.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("A.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("A.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("A.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("A.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("A.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("A.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("A.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("A.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("A.release2.callbacks.callback4").pass);
		
		//CTRL Key
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("CTRL.press1.just").pass);
		Assert.isTrue(test.get("CTRL.press1.value").pass);
		Assert.isTrue(test.get("CTRL.press2.just").pass);
		Assert.isTrue(test.get("CTRL.press2.value").pass);
		Assert.isTrue(test.get("CTRL.release1.just").pass);
		Assert.isTrue(test.get("CTRL.release1.value").pass);
		Assert.isTrue(test.get("CTRL.release2.just").pass);
		Assert.isTrue(test.get("CTRL.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("CTRL.press1.callbacks.just").pass);
		Assert.isTrue(test.get("CTRL.press1.callbacks.value").pass);
		Assert.isTrue(test.get("CTRL.press2.callbacks.just").pass);
		Assert.isTrue(test.get("CTRL.press2.callbacks.value").pass);
		Assert.isTrue(test.get("CTRL.release1.callbacks.just").pass);
		Assert.isTrue(test.get("CTRL.release1.callbacks.value").pass);
		Assert.isTrue(test.get("CTRL.release2.callbacks.just").pass);
		Assert.isTrue(test.get("CTRL.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("CTRL.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("CTRL.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("CTRL.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("CTRL.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("CTRL.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("CTRL.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("CTRL.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("CTRL.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("CTRL.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("CTRL.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("CTRL.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("CTRL.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("CTRL.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("CTRL.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("CTRL.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("CTRL.release2.callbacks.callback4").pass);
		
		//F1 Key
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("F1.press1.just").pass);
		Assert.isTrue(test.get("F1.press1.value").pass);
		Assert.isTrue(test.get("F1.press2.just").pass);
		Assert.isTrue(test.get("F1.press2.value").pass);
		Assert.isTrue(test.get("F1.release1.just").pass);
		Assert.isTrue(test.get("F1.release1.value").pass);
		Assert.isTrue(test.get("F1.release2.just").pass);
		Assert.isTrue(test.get("F1.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("F1.press1.callbacks.just").pass);
		Assert.isTrue(test.get("F1.press1.callbacks.value").pass);
		Assert.isTrue(test.get("F1.press2.callbacks.just").pass);
		Assert.isTrue(test.get("F1.press2.callbacks.value").pass);
		Assert.isTrue(test.get("F1.release1.callbacks.just").pass);
		Assert.isTrue(test.get("F1.release1.callbacks.value").pass);
		Assert.isTrue(test.get("F1.release2.callbacks.just").pass);
		Assert.isTrue(test.get("F1.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("F1.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("F1.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("F1.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("F1.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("F1.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("F1.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("F1.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("F1.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("F1.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("F1.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("F1.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("F1.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("F1.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("F1.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("F1.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("F1.release2.callbacks.callback4").pass);
	}
	
	function _testFlxKeyboard(test:TestShell, key:FlxKey, callbacks:Bool)
	{
		var a = new FlxActionInputDigitalKeyboard(key, FlxInputState.PRESSED);
		var b = new FlxActionInputDigitalKeyboard(key, FlxInputState.JUST_PRESSED);
		var c = new FlxActionInputDigitalKeyboard(key, FlxInputState.RELEASED);
		var d = new FlxActionInputDigitalKeyboard(key, FlxInputState.JUST_RELEASED);
		
		var clear = clearFlxKey.bind(key);
		var click = clickFlxKey.bind(key);
		
		testInputStates(test, clear, click, a, b, c, d, callbacks);
	}
	
	@Test
	function testFlxMouseWheel()
	{
		var test = new TestShell("");
		
		test.name = "positive.";
		_testFlxMouseWheel(test, true, false);
		_testFlxMouseWheel(test, true, true);
		
		test.name = "negative.";
		_testFlxMouseWheel(test, true, false);
		_testFlxMouseWheel(test, true, true);
		
		//POSITIVE
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("positive.press1.just").pass);
		Assert.isTrue(test.get("positive.press1.value").pass);
		Assert.isTrue(test.get("positive.press2.just").pass);
		Assert.isTrue(test.get("positive.press2.value").pass);
		Assert.isTrue(test.get("positive.release1.just").pass);
		Assert.isTrue(test.get("positive.release1.value").pass);
		Assert.isTrue(test.get("positive.release2.just").pass);
		Assert.isTrue(test.get("positive.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("positive.press1.callbacks.just").pass);
		Assert.isTrue(test.get("positive.press1.callbacks.value").pass);
		Assert.isTrue(test.get("positive.press2.callbacks.just").pass);
		Assert.isTrue(test.get("positive.press2.callbacks.value").pass);
		Assert.isTrue(test.get("positive.release1.callbacks.just").pass);
		Assert.isTrue(test.get("positive.release1.callbacks.value").pass);
		Assert.isTrue(test.get("positive.release2.callbacks.just").pass);
		Assert.isTrue(test.get("positive.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("positive.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("positive.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("positive.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("positive.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("positive.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("positive.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("positive.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("positive.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("positive.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("positive.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("positive.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("positive.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("positive.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("positive.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("positive.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("positive.release2.callbacks.callback4").pass);
		
		//NEGATIVE
		
		//Press & release w/o callbacks
		Assert.isTrue(test.get("negative.press1.just").pass);
		Assert.isTrue(test.get("negative.press1.value").pass);
		Assert.isTrue(test.get("negative.press2.just").pass);
		Assert.isTrue(test.get("negative.press2.value").pass);
		Assert.isTrue(test.get("negative.release1.just").pass);
		Assert.isTrue(test.get("negative.release1.value").pass);
		Assert.isTrue(test.get("negative.release2.just").pass);
		Assert.isTrue(test.get("negative.release2.value").pass);
		
		//Press & release w/ callbacks
		Assert.isTrue(test.get("negative.press1.callbacks.just").pass);
		Assert.isTrue(test.get("negative.press1.callbacks.value").pass);
		Assert.isTrue(test.get("negative.press2.callbacks.just").pass);
		Assert.isTrue(test.get("negative.press2.callbacks.value").pass);
		Assert.isTrue(test.get("negative.release1.callbacks.just").pass);
		Assert.isTrue(test.get("negative.release1.callbacks.value").pass);
		Assert.isTrue(test.get("negative.release2.callbacks.just").pass);
		Assert.isTrue(test.get("negative.release2.callbacks.value").pass);
		
		//Callbacks themselves
		Assert.isTrue(test.get("negative.press1.callbacks.callback1").pass);
		Assert.isTrue(test.get("negative.press1.callbacks.callback2").pass);
		Assert.isTrue(test.get("negative.press1.callbacks.callback3").pass);
		Assert.isTrue(test.get("negative.press1.callbacks.callback4").pass);
		Assert.isTrue(test.get("negative.press2.callbacks.callback1").pass);
		Assert.isTrue(test.get("negative.press2.callbacks.callback2").pass);
		Assert.isTrue(test.get("negative.press2.callbacks.callback3").pass);
		Assert.isTrue(test.get("negative.press2.callbacks.callback4").pass);
		Assert.isTrue(test.get("negative.release1.callbacks.callback1").pass);
		Assert.isTrue(test.get("negative.release1.callbacks.callback2").pass);
		Assert.isTrue(test.get("negative.release1.callbacks.callback3").pass);
		Assert.isTrue(test.get("negative.release1.callbacks.callback4").pass);
		Assert.isTrue(test.get("negative.release2.callbacks.callback1").pass);
		Assert.isTrue(test.get("negative.release2.callbacks.callback2").pass);
		Assert.isTrue(test.get("negative.release2.callbacks.callback3").pass);
		Assert.isTrue(test.get("negative.release2.callbacks.callback4").pass);
	}
	
	function _testFlxMouseWheel(test:TestShell, positive:Bool, callbacks:Bool)
	{
		var a = new FlxActionInputDigitalMouseWheel(positive, FlxInputState.PRESSED);
		var b = new FlxActionInputDigitalMouseWheel(positive, FlxInputState.JUST_PRESSED);
		var c = new FlxActionInputDigitalMouseWheel(positive, FlxInputState.RELEASED);
		var d = new FlxActionInputDigitalMouseWheel(positive, FlxInputState.JUST_RELEASED);
		
		var clear = clearFlxMouseWheel;
		var move = moveFlxMouseWheel.bind(positive);
		
		testInputStates(test, clear, move, a, b, c, d, callbacks);
	}
	
	/*********/
	
	function getCallback(i:Int){
		return function (a:FlxActionDigital){
			onCallback(i);
		}
	}
	
	function testInputStates(test:TestShell, clear:Void->Void, click:Bool->Array<FlxActionDigital>->Void, pressed:FlxActionInputDigital, jPressed:FlxActionInputDigital, released:FlxActionInputDigital, jReleased:FlxActionInputDigital, testCallbacks:Bool)
	{
		var aPressed:FlxActionDigital;
		var ajPressed:FlxActionDigital;
		var aReleased:FlxActionDigital;
		var ajReleased:FlxActionDigital;
		
		if (!testCallbacks)
		{
			ajPressed = new FlxActionDigital("jPressed", null);
			aPressed = new FlxActionDigital("pressed", null);
			ajReleased = new FlxActionDigital("jReleased", null);
			aReleased = new FlxActionDigital("released", null);
		}
		else
		{
			ajPressed = new FlxActionDigital("jPressed", getCallback(0));
			aPressed = new FlxActionDigital("pressed", getCallback(1));
			ajReleased = new FlxActionDigital("jReleased", getCallback(2));
			aReleased = new FlxActionDigital("released", getCallback(3));
		}
		
		ajPressed.addInput(jPressed);
		aPressed.addInput(pressed);
		ajReleased.addInput(jReleased);
		aReleased.addInput(released);
		
		var arr = [aPressed, ajPressed, aReleased, ajReleased];
		
		clear();
		
		var callbackStr = (testCallbacks ? "callbacks." : "");
		
		test.prefix = "press1." + callbackStr;
		
		//JUST PRESSED
		click(true, arr);
		test.assertIsTrue(ajPressed.triggered, "just");
		test.assertIsTrue(aPressed.triggered, "value");
		if (testCallbacks)
		{
			test.assertIsTrue(value0 == 1, "callback1");
			test.assertIsTrue(value1 == 1, "callback2");
			test.assertIsTrue(value2 == 0, "callback3");
			test.assertIsTrue(value3 == 0, "callback4");
		}
		
		test.prefix = "press2." + callbackStr;
		
		//STILL PRESSED
		click(true, arr);
		test.assertIsFalse(ajPressed.triggered, "just");
		test.assertIsTrue(aPressed.triggered, "value");
		if (testCallbacks)
		{
			test.assertIsTrue(value0 == 1, "callback1");
			test.assertIsTrue(value1 == 2, "callback2");
			test.assertIsTrue(value2 == 0, "callback3");
			test.assertIsTrue(value3 == 0, "callback4");
		}
		
		test.prefix = "release1." + callbackStr;
		
		//JUST RELEASED
		click(false, arr);
		test.assertIsTrue(ajReleased.triggered, "just");
		test.assertIsTrue(aReleased.triggered, "value");
		if (testCallbacks)
		{
			test.assertIsTrue(value0 == 1, "callback1");
			test.assertIsTrue(value1 == 2, "callback2");
			test.assertIsTrue(value2 == 1, "callback3");
			test.assertIsTrue(value3 == 1, "callback4");
		}
		
		test.prefix = "release2." + callbackStr;
		
		//STILL RELEASED
		click(false, arr);
		test.assertIsFalse(ajReleased.triggered, "just");
		test.assertIsTrue(aReleased.triggered, "value");
		if (testCallbacks)
		{
			test.assertIsTrue(value0 == 1, "callback1");
			test.assertIsTrue(value1 == 2, "callback2");
			test.assertIsTrue(value2 == 1, "callback3");
			test.assertIsTrue(value3 == 2, "callback4");
		}
		
		clear();
		clearValues();
		
		aPressed.destroy();
		aReleased.destroy();
		ajPressed.destroy();
		ajReleased.destroy();
	}
	
	@:access(flixel.input.mouse.FlxMouse)
	private function clearFlxMouseWheel()
	{
		FlxG.mouse.wheel = 0;
		step();
		step();
	}
	
	@:access(flixel.input.FlxKeyManager)
	private function clearFlxKey(key:FlxKey)
	{
		var input:FlxInput<Int> = FlxG.keys._keyListMap.get(key);
		input.release();
		step();
		input.update();
		step();
		input.update();
	}
	
	private function clearMouseButton(button:FlxMouseButton)
	{
		button.release();
		step();
		button.update();
		step();
		button.update();
	}
	
	private function clearFlxInput(thing:FlxInput<Int>)
	{
		thing.release();
		step();
		thing.update();
		step();
		thing.update();
	}
	
	@:access(flixel.input.mouse.FlxMouse)
	private function moveFlxMouseWheel(positive:Bool, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		trace("moveFlxMouseWheel(" + positive+"," + pressed + ")");
		if (pressed)
		{
			if (positive)
			{
				FlxG.mouse.wheel = 1;
			}
			else
			{
				FlxG.mouse.wheel = -1;
			}
		}
		else
		{
			FlxG.mouse.wheel = 0;
		}
		for (a in arr) { a.update(); }
		step();
	}
	
	@:access(flixel.input.FlxKeyManager)
	private function clickFlxKey(key:FlxKey, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		var input:FlxInput<Int> = FlxG.keys._keyListMap.get(key);
		step();
		input.update();
		if (pressed) input.press();
		else input.release();
		for (a in arr) {a.update(); }
	}
	
	private function clickMouseButton(button:FlxMouseButton, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		step();
		button.update();
		if (pressed) button.press();
		else button.release();
		for (a in arr) { a.update(); }
	}
	
	private function clickFlxInput(thing:FlxInput<Int>, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		step();
		thing.update();
		if (pressed) thing.press();
		else thing.release();
		for (a in arr){ a.update(); }
	}
	
	private function onCallback(i:Int)
	{
		switch(i){
			case 0: value0++;
			case 1: value1++;
			case 2: value2++;
			case 3: value3++;
		}
	}
	
	private function clearValues()
	{
		value0 = value1 = value2 = value3 = 0;
	}
}

class TestShell implements IFlxDestroyable
{
	public var name:String;
	public var results:Array<TestShellResult>;
	public var prefix:String = "";
	
	public function new(Name:String)
	{
		name = Name;
		results = [];
	}
	
	public function destroy()
	{
		FlxArrayUtil.clearArray(results);
	}
	
	public function get(id:String):TestShellResult
	{
		for (result in results){
			if (result.id == id) return result;
		}
		return {id:"unknown id("+id+")",pass:false};
	}
	
	public function assertIsTrue(b:Bool, id:String)
	{
		assert(b, id);
	}
	
	public function assertIsFalse(b:Bool, id:String)
	{
		assert(!b, id);
	}
	
	private function assert(b:Bool, id:String)
	{
		results.push({id:name + prefix + id, pass:b});
	}
}

typedef TestShellResult = {
	id:String,
	pass:Bool
}

typedef MyInput = FlxInput<Int>;