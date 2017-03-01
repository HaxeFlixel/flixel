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
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalSteam;
import flixel.input.actions.FlxActionInputDigitalTest.TestShell;
import flixel.input.actions.FlxActionInputDigitalTest.TestShellResult;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.PosInfos;
import lime.ui.Gamepad;
import openfl.ui.GameInput;
import openfl.ui.GameInputDevice;

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
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//Press & release w/o callbacks
		assertTrue ("press1.just");
		assertTrue ("press1.value");
		assertFalse("press2.just");
		assertTrue ("press2.value");
		assertTrue ("release1.just");
		assertTrue ("release1.value");
		assertFalse("release2.just");
		assertTrue ("release2.value");
		
		test.destroy();
	}
	
	@Test
	function testIFlxInputCallbacks()
	{
		var test = new TestShell("");
		
		_testIFlxInput(test, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//Press & release w/ callbacks
		assertTrue ("press1.callbacks.just");
		assertTrue ("press1.callbacks.value");
		assertFalse("press2.callbacks.just");
		assertTrue ("press2.callbacks.value");
		assertTrue ("release1.callbacks.just");
		assertTrue ("release1.callbacks.value");
		assertFalse("release2.callbacks.just");
		assertTrue ("release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("press1.callbacks.callback1");
		assertTrue("press1.callbacks.callback2");
		assertTrue("press1.callbacks.callback3");
		assertTrue("press1.callbacks.callback4");
		assertTrue("press2.callbacks.callback1");
		assertTrue("press2.callbacks.callback2");
		assertTrue("press2.callbacks.callback3");
		assertTrue("press2.callbacks.callback4");
		assertTrue("release1.callbacks.callback1");
		assertTrue("release1.callbacks.callback2");
		assertTrue("release1.callbacks.callback3");
		assertTrue("release1.callbacks.callback4");
		assertTrue("release2.callbacks.callback1");
		assertTrue("release2.callbacks.callback2");
		assertTrue("release2.callbacks.callback3");
		assertTrue("release2.callbacks.callback4");
		
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
	function testFlxMouseButtonLeft()
	{
		var test = new TestShell("");
		
		test.name = "left.";
		_testFlxMouseButton(test, FlxMouseButtonID.LEFT, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//LEFT mouse button
		
		//Press & release w/o callbacks
		assertTrue ("left.press1.just");
		assertTrue ("left.press1.value");
		assertFalse("left.press2.just");
		assertTrue ("left.press2.value");
		assertTrue ("left.release1.just");
		assertTrue ("left.release1.value");
		assertFalse("left.release2.just");
		assertTrue ("left.release2.value");
		
		test.destroy();
	}
	
	@Test
	function testFlxMouseButtonCallbacksLeft()
	{
		var test = new TestShell("");
		
		test.name = "left.";
		_testFlxMouseButton(test, FlxMouseButtonID.LEFT, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//LEFT mouse button
		
		//Press & release w/ callbacks
		assertTrue ("left.press1.callbacks.just");
		assertTrue ("left.press1.callbacks.value");
		assertFalse("left.press2.callbacks.just");
		assertTrue ("left.press2.callbacks.value");
		assertTrue ("left.release1.callbacks.just");
		assertTrue ("left.release1.callbacks.value");
		assertFalse("left.release2.callbacks.just");
		assertTrue ("left.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("left.press1.callbacks.callback1");
		assertTrue("left.press1.callbacks.callback2");
		assertTrue("left.press1.callbacks.callback3");
		assertTrue("left.press1.callbacks.callback4");
		assertTrue("left.press2.callbacks.callback1");
		assertTrue("left.press2.callbacks.callback2");
		assertTrue("left.press2.callbacks.callback3");
		assertTrue("left.press2.callbacks.callback4");
		assertTrue("left.release1.callbacks.callback1");
		assertTrue("left.release1.callbacks.callback2");
		assertTrue("left.release1.callbacks.callback3");
		assertTrue("left.release1.callbacks.callback4");
		assertTrue("left.release2.callbacks.callback1");
		assertTrue("left.release2.callbacks.callback2");
		assertTrue("left.release2.callbacks.callback3");
		assertTrue("left.release2.callbacks.callback4");
		
		test.destroy();
	}
	
	@Test
	function testFlxMouseButtonMiddle()
	{
		var test = new TestShell("");
		
		test.name = "middle.";
		_testFlxMouseButton(test, FlxMouseButtonID.MIDDLE, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//MIDDLE mouse button
		
		//Press & release w/o callbacks
		assertTrue ("middle.press1.just");
		assertTrue ("middle.press1.value");
		assertFalse("middle.press2.just");
		assertTrue ("middle.press2.value");
		assertTrue ("middle.release1.just");
		assertTrue ("middle.release1.value");
		assertFalse("middle.release2.just");
		assertTrue ("middle.release2.value");
		
		test.destroy();
	}
	
	@Test
	function testFlxMouseButtonCallbacksMiddle()
	{
		var test = new TestShell("");
		
		test.name = "middle.";
		_testFlxMouseButton(test, FlxMouseButtonID.MIDDLE, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//MIDDLE mouse button
		
		//Press & release w/ callbacks
		assertTrue ("middle.press1.callbacks.just");
		assertTrue ("middle.press1.callbacks.value");
		assertFalse("middle.press2.callbacks.just");
		assertTrue ("middle.press2.callbacks.value");
		assertTrue ("middle.release1.callbacks.just");
		assertTrue ("middle.release1.callbacks.value");
		assertFalse("middle.release2.callbacks.just");
		assertTrue ("middle.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("middle.press1.callbacks.callback1");
		assertTrue("middle.press1.callbacks.callback2");
		assertTrue("middle.press1.callbacks.callback3");
		assertTrue("middle.press1.callbacks.callback4");
		assertTrue("middle.press2.callbacks.callback1");
		assertTrue("middle.press2.callbacks.callback2");
		assertTrue("middle.press2.callbacks.callback3");
		assertTrue("middle.press2.callbacks.callback4");
		assertTrue("middle.release1.callbacks.callback1");
		assertTrue("middle.release1.callbacks.callback2");
		assertTrue("middle.release1.callbacks.callback3");
		assertTrue("middle.release1.callbacks.callback4");
		assertTrue("middle.release2.callbacks.callback1");
		assertTrue("middle.release2.callbacks.callback2");
		assertTrue("middle.release2.callbacks.callback3");
		assertTrue("middle.release2.callbacks.callback4");
		
		test.destroy();
	}
	
	@Test
	function testFlxMouseButtonRight()
	{
		var test = new TestShell("");
		
		test.name = "right.";
		_testFlxMouseButton(test, FlxMouseButtonID.RIGHT, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//RIGHT mouse button
		
		//Press & release w/o callbacks
		assertTrue ("right.press1.just");
		assertTrue ("right.press1.value");
		assertFalse("right.press2.just");
		assertTrue ("right.press2.value");
		assertTrue ("right.release1.just");
		assertTrue ("right.release1.value");
		assertFalse("right.release2.just");
		assertTrue ("right.release2.value");
		
		test.destroy();
	}
	
	@Test
	function testFlxMouseButtonCallbacksRight()
	{
		var test = new TestShell("");
		
		test.name = "right.";
		_testFlxMouseButton(test, FlxMouseButtonID.RIGHT, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//RIGHT mouse button
		
		//Press & release w/ callbacks
		assertTrue ("right.press1.callbacks.just");
		assertTrue ("right.press1.callbacks.value");
		assertFalse("right.press2.callbacks.just");
		assertTrue ("right.press2.callbacks.value");
		assertTrue ("right.release1.callbacks.just");
		assertTrue ("right.release1.callbacks.value");
		assertFalse("right.release2.callbacks.just");
		assertTrue ("right.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("right.press1.callbacks.callback1");
		assertTrue("right.press1.callbacks.callback2");
		assertTrue("right.press1.callbacks.callback3");
		assertTrue("right.press1.callbacks.callback4");
		assertTrue("right.press2.callbacks.callback1");
		assertTrue("right.press2.callbacks.callback2");
		assertTrue("right.press2.callbacks.callback3");
		assertTrue("right.press2.callbacks.callback4");
		assertTrue("right.release1.callbacks.callback1");
		assertTrue("right.release1.callbacks.callback2");
		assertTrue("right.release1.callbacks.callback3");
		assertTrue("right.release1.callbacks.callback4");
		assertTrue("right.release2.callbacks.callback1");
		assertTrue("right.release2.callbacks.callback2");
		assertTrue("right.release2.callbacks.callback3");
		assertTrue("right.release2.callbacks.callback4");
		
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
	function testFlxKeyboardA()
	{
		var test = new TestShell("");
		
		test.name = "A.";
		_testFlxKeyboard(test, FlxKey.A, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//A Key
		
		//Press & release w/o callbacks
		assertTrue ("A.press1.just");
		assertTrue ("A.press1.value");
		assertFalse("A.press2.just");
		assertTrue ("A.press2.value");
		assertTrue ("A.release1.just");
		assertTrue ("A.release1.value");
		assertFalse("A.release2.just");
		assertTrue ("A.release2.value");
	}
	
	@Test
	function testFlxKeyboardCallbacksA()
	{
		var test = new TestShell("");
		
		test.name = "A.";
		_testFlxKeyboard(test, FlxKey.A, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//A Key
		
		//Press & release w/ callbacks
		assertTrue ("A.press1.callbacks.just");
		assertTrue ("A.press1.callbacks.value");
		assertFalse("A.press2.callbacks.just");
		assertTrue ("A.press2.callbacks.value");
		assertTrue ("A.release1.callbacks.just");
		assertTrue ("A.release1.callbacks.value");
		assertFalse("A.release2.callbacks.just");
		assertTrue ("A.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("A.press1.callbacks.callback1");
		assertTrue("A.press1.callbacks.callback2");
		assertTrue("A.press1.callbacks.callback3");
		assertTrue("A.press1.callbacks.callback4");
		assertTrue("A.press2.callbacks.callback1");
		assertTrue("A.press2.callbacks.callback2");
		assertTrue("A.press2.callbacks.callback3");
		assertTrue("A.press2.callbacks.callback4");
		assertTrue("A.release1.callbacks.callback1");
		assertTrue("A.release1.callbacks.callback2");
		assertTrue("A.release1.callbacks.callback3");
		assertTrue("A.release1.callbacks.callback4");
		assertTrue("A.release2.callbacks.callback1");
		assertTrue("A.release2.callbacks.callback2");
		assertTrue("A.release2.callbacks.callback3");
		assertTrue("A.release2.callbacks.callback4");
	}
	
	@Test
	function testFlxKeyboardCONTROL()
	{
		var test = new TestShell("");
		
		test.name = "CONTROL.";
		_testFlxKeyboard(test, FlxKey.CONTROL, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//CONTROL Key
		
		//Press & release w/o callbacks
		assertTrue ("CONTROL.press1.just");
		assertTrue ("CONTROL.press1.value");
		assertFalse("CONTROL.press2.just");
		assertTrue ("CONTROL.press2.value");
		assertTrue ("CONTROL.release1.just");
		assertTrue ("CONTROL.release1.value");
		assertFalse("CONTROL.release2.just");
		assertTrue ("CONTROL.release2.value");
	}
	
	@Test
	function testFlxKeyboardCallbacksCONTROL()
	{
		var test = new TestShell("");
		
		test.name = "CONTROL.";
		_testFlxKeyboard(test, FlxKey.CONTROL, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//CONTROL Key
		
		//Press & release w/ callbacks
		assertTrue ("CONTROL.press1.callbacks.just");
		assertTrue ("CONTROL.press1.callbacks.value");
		assertFalse("CONTROL.press2.callbacks.just");
		assertTrue ("CONTROL.press2.callbacks.value");
		assertTrue ("CONTROL.release1.callbacks.just");
		assertTrue ("CONTROL.release1.callbacks.value");
		assertFalse("CONTROL.release2.callbacks.just");
		assertTrue ("CONTROL.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("CONTROL.press1.callbacks.callback1");
		assertTrue("CONTROL.press1.callbacks.callback2");
		assertTrue("CONTROL.press1.callbacks.callback3");
		assertTrue("CONTROL.press1.callbacks.callback4");
		assertTrue("CONTROL.press2.callbacks.callback1");
		assertTrue("CONTROL.press2.callbacks.callback2");
		assertTrue("CONTROL.press2.callbacks.callback3");
		assertTrue("CONTROL.press2.callbacks.callback4");
		assertTrue("CONTROL.release1.callbacks.callback1");
		assertTrue("CONTROL.release1.callbacks.callback2");
		assertTrue("CONTROL.release1.callbacks.callback3");
		assertTrue("CONTROL.release1.callbacks.callback4");
		assertTrue("CONTROL.release2.callbacks.callback1");
		assertTrue("CONTROL.release2.callbacks.callback2");
		assertTrue("CONTROL.release2.callbacks.callback3");
		assertTrue("CONTROL.release2.callbacks.callback4");
	}
	
	@Test
	function testFlxKeyboardF1()
	{
		var test = new TestShell("");
		
		test.name = "F1.";
		_testFlxKeyboard(test, FlxKey.F1, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//F1 Key
		
		//Press & release w/o callbacks
		assertTrue ("F1.press1.just");
		assertTrue ("F1.press1.value");
		assertFalse("F1.press2.just");
		assertTrue ("F1.press2.value");
		assertTrue ("F1.release1.just");
		assertTrue ("F1.release1.value");
		assertFalse("F1.release2.just");
		assertTrue ("F1.release2.value");
	}
	
	@Test
	function testFlxKeyboardCallbacksF1()
	{
		var test = new TestShell("");
		
		test.name = "F1.";
		_testFlxKeyboard(test, FlxKey.F1, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//F1 Key
		
		//Press & release w/ callbacks
		assertTrue ("F1.press1.callbacks.just");
		assertTrue ("F1.press1.callbacks.value");
		assertFalse("F1.press2.callbacks.just");
		assertTrue ("F1.press2.callbacks.value");
		assertTrue ("F1.release1.callbacks.just");
		assertTrue ("F1.release1.callbacks.value");
		assertFalse("F1.release2.callbacks.just");
		assertTrue ("F1.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("F1.press1.callbacks.callback1");
		assertTrue("F1.press1.callbacks.callback2");
		assertTrue("F1.press1.callbacks.callback3");
		assertTrue("F1.press1.callbacks.callback4");
		assertTrue("F1.press2.callbacks.callback1");
		assertTrue("F1.press2.callbacks.callback2");
		assertTrue("F1.press2.callbacks.callback3");
		assertTrue("F1.press2.callbacks.callback4");
		assertTrue("F1.release1.callbacks.callback1");
		assertTrue("F1.release1.callbacks.callback2");
		assertTrue("F1.release1.callbacks.callback3");
		assertTrue("F1.release1.callbacks.callback4");
		assertTrue("F1.release2.callbacks.callback1");
		assertTrue("F1.release2.callbacks.callback2");
		assertTrue("F1.release2.callbacks.callback3");
		assertTrue("F1.release2.callbacks.callback4");
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
	function testFlxMouseWheelPositive()
	{
		var test = new TestShell("");
		
		test.name = "positive.";
		_testFlxMouseWheel(test, true, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//POSITIVE
		
		//Press & release w/o callbacks
		assertTrue ("positive.press1.just");
		assertTrue ("positive.press1.value");
		assertFalse("positive.press2.just");
		assertTrue ("positive.press2.value");
		assertTrue ("positive.release1.just");
		assertTrue ("positive.release1.value");
		assertFalse("positive.release2.just");
		assertTrue ("positive.release2.value");
	}
	
	@Test
	function testFlxMouseWheelCallbacksPositive()
	{
		var test = new TestShell("");
		
		test.name = "positive.";
		_testFlxMouseWheel(test, true, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//POSITIVE
		
		//Press & release w/ callbacks
		assertTrue ("positive.press1.callbacks.just");
		assertTrue ("positive.press1.callbacks.value");
		assertFalse("positive.press2.callbacks.just");
		assertTrue ("positive.press2.callbacks.value");
		assertTrue ("positive.release1.callbacks.just");
		assertTrue ("positive.release1.callbacks.value");
		assertFalse("positive.release2.callbacks.just");
		assertTrue ("positive.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("positive.press1.callbacks.callback1");
		assertTrue("positive.press1.callbacks.callback2");
		assertTrue("positive.press1.callbacks.callback3");
		assertTrue("positive.press1.callbacks.callback4");
		assertTrue("positive.press2.callbacks.callback1");
		assertTrue("positive.press2.callbacks.callback2");
		assertTrue("positive.press2.callbacks.callback3");
		assertTrue("positive.press2.callbacks.callback4");
		assertTrue("positive.release1.callbacks.callback1");
		assertTrue("positive.release1.callbacks.callback2");
		assertTrue("positive.release1.callbacks.callback3");
		assertTrue("positive.release1.callbacks.callback4");
		assertTrue("positive.release2.callbacks.callback1");
		assertTrue("positive.release2.callbacks.callback2");
		assertTrue("positive.release2.callbacks.callback3");
		assertTrue("positive.release2.callbacks.callback4");
	}
	
	@Test
	function testFlxMouseWheelNegative()
	{
		var test = new TestShell("");
		
		test.name = "negative.";
		_testFlxMouseWheel(test, true, false);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//NEGATIVE
		
		//Press & release w/o callbacks
		assertTrue ("negative.press1.just");
		assertTrue ("negative.press1.value");
		assertFalse("negative.press2.just");
		assertTrue ("negative.press2.value");
		assertTrue ("negative.release1.just");
		assertTrue ("negative.release1.value");
		assertFalse("negative.release2.just");
		assertTrue ("negative.release2.value");
	}
	
	@Test
	function testFlxMouseWheelCallbacksNegative()
	{
		var test = new TestShell("");
		
		test.name = "negative.";
		_testFlxMouseWheel(test, true, true);
		
		inline function assertTrue    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedTrue   , info); };
		inline function assertFalse   (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedFalse  , info); };
		inline function assertNull    (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNull   , info); };
		inline function assertNotNull (id:String, ?info:PosInfos) { Assert.isTrue(test.get(id).testedNotNull, info); };
		
		//NEGATIVE
		
		//Press & release w/ callbacks
		assertTrue ("negative.press1.callbacks.just");
		assertTrue ("negative.press1.callbacks.value");
		assertFalse("negative.press2.callbacks.just");
		assertTrue ("negative.press2.callbacks.value");
		assertTrue ("negative.release1.callbacks.just");
		assertTrue ("negative.release1.callbacks.value");
		assertFalse("negative.release2.callbacks.just");
		assertTrue ("negative.release2.callbacks.value");
		
		//Callbacks themselves
		assertTrue("negative.press1.callbacks.callback1");
		assertTrue("negative.press1.callbacks.callback2");
		assertTrue("negative.press1.callbacks.callback3");
		assertTrue("negative.press1.callbacks.callback4");
		assertTrue("negative.press2.callbacks.callback1");
		assertTrue("negative.press2.callbacks.callback2");
		assertTrue("negative.press2.callbacks.callback3");
		assertTrue("negative.press2.callbacks.callback4");
		assertTrue("negative.release1.callbacks.callback1");
		assertTrue("negative.release1.callbacks.callback2");
		assertTrue("negative.release1.callbacks.callback3");
		assertTrue("negative.release1.callbacks.callback4");
		assertTrue("negative.release2.callbacks.callback1");
		assertTrue("negative.release2.callbacks.callback2");
		assertTrue("negative.release2.callbacks.callback3");
		assertTrue("negative.release2.callbacks.callback4");
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
	
	function makeFakeGamepad():Dynamic
	{
		#if FLX_JOYSTICK_API
			//TODO:
		#elseif FLX_GAMEINPUT_API
			//TODO: 
		#end
		return null;
	}
	
	@Test
	function testFlxGamepad()
	{
		//TODO: make a fake gamepad somehow
		
		#if FLX_JOYSTICK_API
		
		#elseif FLX_GAMEINPUT_API
			
		#end
		
	}
	
	function _testFlxGamepad(test:TestShell, g:FlxGamepad, inputID:FlxGamepadInputID, callbacks:Bool)
	{
		/*
		var a = new FlxActionInputDigitalGamepad(inputID, FlxInputState.PRESSED);
		var b = new FlxActionInputDigitalGamepad(inputID, FlxInputState.JUST_PRESSED);
		var c = new FlxActionInputDigitalGamepad(inputID, FlxInputState.RELEASED);
		var d = new FlxActionInputDigitalGamepad(inputID, FlxInputState.JUST_RELEASED);
		
		var clear = clearFlxGamepad.bind(g, inputID);
		var click = clickFlxGamepad.bind(g, inputID);
		
		testInputStates(test, clear, click, a, b, c, d, callbacks);
		*/
	}
	
	@Test
	function testSteam()
	{
	
	}
	
	function _testSteam(test:TestShell, actionHandle:Int, callbacks:Bool)
	{
		/*
		var a = new FlxActionInputDigitalSteam(actionHandle, FlxInputState.PRESSED);
		var b = new FlxActionInputDigitalSteam(actionHandle, FlxInputState.JUST_PRESSED);
		var c = new FlxActionInputDigitalSteam(actionHandle, FlxInputState.RELEASED);
		var d = new FlxActionInputDigitalSteam(actionHandle, FlxInputState.JUST_RELEASED);
		
		var clear = clearSteam.bind(actionHandle);
		var click = clearSteam.bind(actionHandle);
		
		testInputStates(test, clear, click, a, b, c, d, callbacks);
		*/
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
	
	@:access(flixel.input.gamepad.FlxGamepad)
	private function clearFlxGamepad(gamepad:FlxGamepad, ID:FlxGamepadInputID)
	{
		var input:FlxInput<Int> = gamepad.buttons[gamepad.mapping.getRawID(ID)];
		input.release();
		step();
		input.update();
		step();
		input.update();
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
	
	@:access(flixel.input.gamepad.FlxGamepad)
	private function clickFlxGamepad(gamepad:FlxGamepad, ID:FlxGamepadInputID, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		var input:FlxInput<Int> = gamepad.buttons[gamepad.mapping.getRawID(ID)];
		if (pressed) input.press();
		else input.release();
		for (a in arr) { a.update(); }
	}
	
	@:access(flixel.input.mouse.FlxMouse)
	private function moveFlxMouseWheel(positive:Bool, pressed:Bool, arr:Array<FlxActionDigital>)
	{
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
		return {
			id:"unknown id(" + id + ")",
			testedTrue:false,
			testedFalse:false,
			testedNull:false,
			testedNotNull:false
		};
	}
	
	public function assertIsTrue(b:Bool, id:String)
	{
		assert(id, b == true);
	}
	
	public function assertIsFalse(b:Bool, id:String)
	{
		assert(id, false, b == false);
	}
	
	public function assertIsNull(d:Dynamic, id:String)
	{
		assert(id, false, false, d == null);
	}
	
	public function assertIsNotNull(d:Dynamic, id:String)
	{
		assert(id, false, false, false, d != null);
	}
	
	private function assert(id:String, tTrue:Bool=false, tFalse:Bool=false, tNull:Bool=false, tNNull:Bool=false)
	{
		results.push
		(
			{
				id:name + prefix + id,
				testedTrue:tTrue,
				testedFalse:tFalse,
				testedNull:tNull,
				testedNotNull:tNNull
			}
		);
	}
}

typedef TestShellResult = {
	id:String,
	testedTrue:Bool,
	testedFalse:Bool,
	testedNull:Bool,
	testedNotNull:Bool
}

typedef MyInput = FlxInput<Int>;