package flixel.input.actions;
import flixel.FlxState;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.input.IFlxInputManager;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalMouseWheel;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalGamepad;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalIFlxInput;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalKeyboard;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalMouse;
import flixel.input.FlxInput;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalSteam;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.Json;
import haxe.PosInfos;
import lime.ui.Gamepad;
import openfl.events.JoystickEvent;
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
		var t = new TestShell("iflxinput.");
		
		_testIFlxInput(t, false);
		
		//Press & release w/o callbacks
		t.assertTrue ("iflxinput.press1.just");
		t.assertTrue ("iflxinput.press1.value");
		t.assertFalse("iflxinput.press2.just");
		t.assertTrue ("iflxinput.press2.value");
		t.assertTrue ("iflxinput.release1.just");
		t.assertTrue ("iflxinput.release1.value");
		t.assertFalse("iflxinput.release2.just");
		t.assertTrue ("iflxinput.release2.value");
	}
	
	@Test
	function testIFlxInputCallbacks()
	{
		var t = new TestShell("iflxinput.");
		
		_testIFlxInput(t, true);
		
		//Press & release w/ callbacks
		t.assertTrue ("iflxinput.press1.callbacks.just");
		t.assertTrue ("iflxinput.press1.callbacks.value");
		t.assertFalse("iflxinput.press2.callbacks.just");
		t.assertTrue ("iflxinput.press2.callbacks.value");
		t.assertTrue ("iflxinput.release1.callbacks.just");
		t.assertTrue ("iflxinput.release1.callbacks.value");
		t.assertFalse("iflxinput.release2.callbacks.just");
		t.assertTrue ("iflxinput.release2.callbacks.value");
		
		//Callbacks themselves (1-4: pressed, just_pressed, released, just_released)
		for (i in 1...5)
		{
			t.assertTrue("iflxinput.press1.callbacks.callback"+i);
			t.assertTrue("iflxinput.press2.callbacks.callback"+i);
			t.assertTrue("iflxinput.release1.callbacks.callback"+i);
			t.assertTrue("iflxinput.release2.callbacks.callback"+i);
		}
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
		var buttons = 
		[
			{name:"left", value:FlxMouseButtonID.LEFT}, 
			{name:"right", value:FlxMouseButtonID.RIGHT}, 
			{name:"middle", value:FlxMouseButtonID.MIDDLE}
		];
		
		for (button in buttons)
		{
			var name = button.name;
			var value = button.value;
			
			var t = new TestShell(name+".");
			_testFlxMouseButton(t, value, false);
			
			//Press & release w/o callbacks
			t.assertTrue (name+".press1.just");
			t.assertTrue (name+".press1.value");
			t.assertFalse(name+".press2.just");
			t.assertTrue (name+".press2.value");
			t.assertTrue (name+".release1.just");
			t.assertTrue (name+".release1.value");
			t.assertFalse(name+".release2.just");
			t.assertTrue (name+".release2.value");
		}
		
	}
	
	@Test
	function testFlxMouseButtonCallbacks()
	{
		var buttons = 
		[
			{name:"left", value:FlxMouseButtonID.LEFT},
			{name:"right", value:FlxMouseButtonID.RIGHT},
			{name:"middle", value:FlxMouseButtonID.MIDDLE}
		];
		
		for (button in buttons)
		{
			var name = button.name;
			var value = button.value;
			
			var t = new TestShell(name+".");
			_testFlxMouseButton(t, value, true);
			
			//Press & release w/ callbacks
			t.assertTrue (name+".press1.callbacks.just");
			t.assertTrue (name+".press1.callbacks.value");
			t.assertFalse(name+".press2.callbacks.just");
			t.assertTrue (name+".press2.callbacks.value");
			t.assertTrue (name+".release1.callbacks.just");
			t.assertTrue (name+".release1.callbacks.value");
			t.assertFalse(name+".release2.callbacks.just");
			t.assertTrue (name+".release2.callbacks.value");
			
			//Callbacks themselves (1-4: pressed, just_pressed, released, just_released)
			for (i in 1...5)
			{
				t.assertTrue(name+".press1.callbacks.callback"+i);
				t.assertTrue(name+".press2.callbacks.callback"+i);
				t.assertTrue(name+".release1.callbacks.callback"+i);
				t.assertTrue(name+".release2.callbacks.callback"+i);
			}
		}
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
	
	private function getGamepadButtons():Array<FlxGamepadInputID>
	{
		return 
		[
			FlxGamepadInputID.A,
			FlxGamepadInputID.B,
			FlxGamepadInputID.X,
			FlxGamepadInputID.Y,
			FlxGamepadInputID.LEFT_SHOULDER,
			FlxGamepadInputID.RIGHT_SHOULDER,
			FlxGamepadInputID.BACK,
			FlxGamepadInputID.START,
			FlxGamepadInputID.LEFT_STICK_CLICK,
			FlxGamepadInputID.RIGHT_STICK_CLICK,
			FlxGamepadInputID.GUIDE,
			FlxGamepadInputID.DPAD_UP,
			FlxGamepadInputID.DPAD_DOWN,
			FlxGamepadInputID.DPAD_LEFT,
			FlxGamepadInputID.DPAD_RIGHT
		];
		
		//Things that have to be tested separately:
		// - LEFT/RIGHT_TRIGGER (digitized) and LEFT/RIGHT_TRIGGER_BUTTON
		// - LEFT/RIGHT_STICK_DIGITAL_UP/DOWN/LEFT/RIGHT
	}
	
	private function getFlxKeys():Array<String>
	{
		//Trying to get these values directly from FlxG.keys.fromStringMap will cause the thing to hard crash whenever I try to do *ANY* logical test to exclude "ANY" from the returned array.
		//It's really creepy and weird!
		var arr = ["NUMPADSEVEN", "PERIOD", "ESCAPE", "A", "NUMPADEIGHT", "SIX", "B", "C", "D", "E", "ONE", "F", "LEFT", "G", "H", "ALT", "I", "J", "K", "CAPSLOCK", "L", "M", "N", "O", "P", "NUMPADTHREE", "SEMICOLON", "Q", "R", "S", "T", "NUMPADSIX", "U", "BACKSLASH", "V", "W", "X", "NUMPADONE", "Y", "Z", "UP", "QUOTE", "SLASH", "BACKSPACE", "HOME", "SHIFT", "DOWN", "F10", "F11", "FOUR", "SPACE", "F12", "ZERO", "PAGEUP", "F1", "DELETE", "F2", "TWO", "F3", "SEVEN", "F4", "F5", "EIGHT", "GRAVEACCENT", "F6", "NUMPADMULTIPLY", "F7", "PAGEDOWN", "F8", "FIVE", "NINE", "NUMPADFOUR", "F9", "TAB", "COMMA", "RBRACKET", "ENTER", "PRINTSCREEN", "INSERT", "END", "RIGHT", "LBRACKET", "CONTROL", "THREE", "NUMPADNINE", "NUMPADFIVE", "NUMPADTWO"];
		
		//these values will hard crash the test and I don't know why
		var problems = ["PLUS", "MINUS", "NUMPADPLUS", "NUMPADMINUS", "NUMPADPERIOD", "NUMPADZERO"];
		
		var arr2 = [];
		for (key in arr)
		{
			if (problems.indexOf(key) != -1)
			{
				arr2.push(key);
			}
		}
		
		return arr2;
	}
	
	@Test
	function testFlxKeyboard()
	{
		var keys = getFlxKeys();
		
		for (key in keys)
		{
			var t = new TestShell(key + ".");
			_testFlxKeyboard(t, key, false);
			
			//Press & release w/o callbacks
			t.assertTrue (key+".press1.just");
			t.assertTrue (key+".press1.value");
			t.assertFalse(key+".press2.just");
			t.assertTrue (key+".press2.value");
			t.assertTrue (key+".release1.just");
			t.assertTrue (key+".release1.value");
			t.assertFalse(key+".release2.just");
			t.assertTrue (key+".release2.value");
			
			//Test "ANY" key input as well:
			t.assertTrue (key+"any.press1.just");
			t.assertTrue (key+"any.press1.value");
			t.assertFalse(key+"any.press2.just");
			t.assertTrue (key+"any.press2.value");
			t.assertTrue (key+"any.release1.just");
			t.assertTrue (key+"any.release1.value");
			t.assertFalse(key+"any.release2.just");
			t.assertTrue (key+"any.release2.value");
		}
	}
	
	@Test
	function testFlxKeyboardCallbacks()
	{
		var keys = getFlxKeys();
		
		for (key in keys)
		{
			var t = new TestShell(key + ".");
			
			_testFlxKeyboard(t, key, true);
			
			//Press & release w/ callbacks
			t.assertTrue (key+".press1.callbacks.just");
			t.assertTrue (key+".press1.callbacks.value");
			t.assertFalse(key+".press2.callbacks.just");
			t.assertTrue (key+".press2.callbacks.value");
			t.assertTrue (key+".release1.callbacks.just");
			t.assertTrue (key+".release1.callbacks.value");
			t.assertFalse(key+".release2.callbacks.just");
			t.assertTrue (key+".release2.callbacks.value");
			
			//Test "ANY" key input as well:
			t.assertTrue (key+"any.press1.callbacks.just");
			t.assertTrue (key+"any.press1.callbacks.value");
			t.assertFalse(key+"any.press2.callbacks.just");
			t.assertTrue (key+"any.press2.callbacks.value");
			t.assertTrue (key+"any.release1.callbacks.just");
			t.assertTrue (key+"any.release1.callbacks.value");
			t.assertFalse(key+"any.release2.callbacks.just");
			t.assertTrue (key+"any.release2.callbacks.value");
			
			//Callbacks themselves (1-4: pressed, just_pressed, released, just_released)
			for (i in 1...5)
			{
				t.assertTrue(key+".press1.callbacks.callback"+i);
				t.assertTrue(key+".press2.callbacks.callback"+i);
				t.assertTrue(key+".release1.callbacks.callback"+i);
				t.assertTrue(key+".release2.callbacks.callback"+i);
				
				t.assertTrue(key+".any.press1.callbacks.callback"+i);
				t.assertTrue(key+".any.press2.callbacks.callback"+i);
				t.assertTrue(key+".any.release1.callbacks.callback"+i);
				t.assertTrue(key+".any.release2.callbacks.callback"+i);
			}
		}
	}
	
	function _testFlxKeyboard(test:TestShell, key:FlxKey, callbacks:Bool)
	{
		var a = new FlxActionInputDigitalKeyboard(key, FlxInputState.PRESSED);
		var b = new FlxActionInputDigitalKeyboard(key, FlxInputState.JUST_PRESSED);
		var c = new FlxActionInputDigitalKeyboard(key, FlxInputState.RELEASED);
		var d = new FlxActionInputDigitalKeyboard(key, FlxInputState.JUST_RELEASED);
		
		var aAny = new FlxActionInputDigitalKeyboard("ANY", FlxInputState.PRESSED);
		var bAny = new FlxActionInputDigitalKeyboard("ANY", FlxInputState.JUST_PRESSED);
		var cAny = new FlxActionInputDigitalKeyboard("ANY", FlxInputState.RELEASED);
		var dAny = new FlxActionInputDigitalKeyboard("ANY", FlxInputState.JUST_RELEASED);
		
		var clear = clearFlxKey.bind(key);
		var click = clickFlxKey.bind(key);
		
		testInputStates(test, clear, click, a, b, c, d, callbacks);
		test.name = test.name + "any.";
		testInputStates(test, clear, click, aAny, bAny, cAny, dAny, callbacks);
	}
	
	@Test
	function testFlxMouseWheel()
	{
		var polarities =
		[
			{name:"positive", value:true},
			{name:"negative", value:false}
		];
		
		for (polarity in polarities)
		{
			var name = polarity.name;
			var value = polarity.value;
			
			var t = new TestShell(name+".");
			_testFlxMouseWheel(t, value, false);
			
			//Press & release w/o callbacks
			t.assertTrue (name+".press1.just");
			t.assertTrue (name+".press1.value");
			t.assertFalse(name+".press2.just");
			t.assertTrue (name+".press2.value");
			t.assertTrue (name+".release1.just");
			t.assertTrue (name+".release1.value");
			t.assertFalse(name+".release2.just");
			t.assertTrue (name+".release2.value");
		}
	}
	
	@Test
	function testFlxMouseWheelCallbacks()
	{
		var polarities = 
		[
			{name:"positive", value:true},
			{name:"negative", value:false}
		];
		
		for (polarity in polarities)
		{
			var name = polarity.name;
			var value = polarity.value;
			
			var t = new TestShell(name+".");
			_testFlxMouseWheel(t, value, true);
			
			//Press & release w/ callbacks
			t.assertTrue (name+".press1.callbacks.just");
			t.assertTrue (name+".press1.callbacks.value");
			t.assertFalse(name+".press2.callbacks.just");
			t.assertTrue (name+".press2.callbacks.value");
			t.assertTrue (name+".release1.callbacks.just");
			t.assertTrue (name+".release1.callbacks.value");
			t.assertFalse(name+".release2.callbacks.just");
			t.assertTrue (name+".release2.callbacks.value");
			
			//Callbacks themselves (1-4: pressed, just_pressed, released, just_released)
			for (i in 1...5)
			{
				t.assertTrue(name+".press1.callbacks.callback"+i);
				t.assertTrue(name+".press2.callbacks.callback"+i);
				t.assertTrue(name+".release1.callbacks.callback"+i);
				t.assertTrue(name+".release2.callbacks.callback"+i);
			}
		}
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
	
	@Test
	function testFlxGamepad()
	{
		var buttons = getGamepadButtons();
		
		for (btn in buttons)
		{
			var t = new TestShell(btn + ".");
			
			_testFlxGamepad(t, btn, false, false);
			
			//Press & release w/ callbacks
			t.assertTrue (btn+".press1.just");
			t.assertTrue (btn+".press1.value");
			t.assertFalse(btn+".press2.just");
			t.assertTrue (btn+".press2.value");
			t.assertTrue (btn+".release1.just");
			t.assertTrue (btn+".release1.value");
			t.assertFalse(btn+".release2.just");
			t.assertTrue (btn+".release2.value");
		}
	}
	
	@Test
	function testFlxGamepadAny()
	{
		var buttons = getGamepadButtons();
		
		for (btn in buttons)
		{
			var t = new TestShell(btn + ".any.");
			
			_testFlxGamepad(t, btn, false, true);
			
			//Press & release w/ callbacks
			//Test "ANY" button input
			t.assertTrue (btn+".any.press1.just");
			t.assertTrue (btn+".any.press1.value");
			t.assertFalse(btn+".any.press2.just");
			t.assertTrue (btn+".any.press2.value");
			t.assertTrue (btn+".any.release1.just");
			t.assertTrue (btn+".any.release1.value");
			t.assertFalse(btn+".any.release2.just");
			t.assertTrue (btn+".any.release2.value");
		}
	}
	
	@Test
	function testFlxGamepadCallbacks()
	{
		var buttons = getGamepadButtons();
		
		for (btn in buttons)
		{
			var t = new TestShell(btn + ".");
			
			_testFlxGamepad(t, btn, true, false);
			
			//Press & release w/o callbacks
			t.assertTrue (btn+".press1.callbacks.just");
			t.assertTrue (btn+".press1.callbacks.value");
			t.assertFalse(btn+".press2.callbacks.just");
			t.assertTrue (btn+".press2.callbacks.value");
			t.assertTrue (btn+".release1.callbacks.just");
			t.assertTrue (btn+".release1.callbacks.value");
			t.assertFalse(btn+".release2.callbacks.just");
			t.assertTrue (btn+".release2.callbacks.value");
			
			//Callbacks themselves (1-4: pressed, just_pressed, released, just_released)
			for (i in 1...5)
			{
				t.assertTrue(btn+".press1.callbacks.callback"+i);
				t.assertTrue(btn+".press2.callbacks.callback"+i);
				t.assertTrue(btn+".release1.callbacks.callback"+i);
				t.assertTrue(btn+".release2.callbacks.callback"+i);
			}
		}
	}
	
	@Test
	function testFlxGamepadAnyCallbacks()
	{
		var buttons = getGamepadButtons();
		
		for (btn in buttons)
		{
			var t = new TestShell(btn + ".any.");
			
			_testFlxGamepad(t, btn, true, true);
			
			//Press & release w/ callbacks
			//Test "ANY" button input
			t.assertTrue (btn+".any.press1.callbacks.just");
			t.assertTrue (btn+".any.press1.callbacks.value");
			t.assertFalse(btn+".any.press2.callbacks.just");
			t.assertTrue (btn+".any.press2.callbacks.value");
			t.assertTrue (btn+".any.release1.callbacks.just");
			t.assertTrue (btn+".any.release1.callbacks.value");
			t.assertFalse(btn+".any.release2.callbacks.just");
			t.assertTrue (btn+".any.release2.callbacks.value");
			
			//Callbacks themselves (1-4: pressed, just_pressed, released, just_released)
			for (i in 1...5)
			{
				t.assertTrue(btn+".any.press1.callbacks.callback"+i);
				t.assertTrue(btn+".any.press2.callbacks.callback"+i);
				t.assertTrue(btn+".any.release1.callbacks.callback"+i);
				t.assertTrue(btn+".any.release2.callbacks.callback"+i);
			}
		}
	}
	
	function _testFlxGamepad(test:TestShell, inputID:FlxGamepadInputID, callbacks:Bool, any:Bool)
	{
		var a:FlxActionInputDigitalGamepad;
		var b:FlxActionInputDigitalGamepad;
		var c:FlxActionInputDigitalGamepad;
		var d:FlxActionInputDigitalGamepad;
		
		//NOTE: I found that gamepad tests can fail in unexpected ways for "RELEASED" actions if 
		//your gamepad ID is "FIRST_ACTIVE"... since "first active" means "the first gamepad with
		//any non-released input" -- if there's no input on a given frame, then no gamepad is returned 
		//that frame to register the releases! a strict reading of the API perhaps would not see this as a bug?
		//In any case, we might consider warning about this unexpected (bug logically valid?) edge case
		//when using FIRST_ACTIVE as the gamepad ID and RELEASED/JUST_RELEASED as the trigger
		
		var stateGrid:InputStateGrid = null;
		
		if (!any)
		{
			a = new FlxActionInputDigitalGamepad(inputID, FlxInputState.PRESSED, 0);
			b = new FlxActionInputDigitalGamepad(inputID, FlxInputState.JUST_PRESSED, 0);
			c = new FlxActionInputDigitalGamepad(inputID, FlxInputState.RELEASED, 0);
			d = new FlxActionInputDigitalGamepad(inputID, FlxInputState.JUST_RELEASED, 0);
		}
		else
		{
			a = new FlxActionInputDigitalGamepad(FlxGamepadInputID.ANY, FlxInputState.PRESSED, 0);
			b = new FlxActionInputDigitalGamepad(FlxGamepadInputID.ANY, FlxInputState.JUST_PRESSED, 0);
			c = new FlxActionInputDigitalGamepad(FlxGamepadInputID.ANY, FlxInputState.RELEASED, 0);
			d = new FlxActionInputDigitalGamepad(FlxGamepadInputID.ANY, FlxInputState.JUST_RELEASED, 0);
			
			stateGrid = 
			{
				press1   : [1, 1, 0, 1],
				press2   : [1, 2, 0, 2],
				release1 : [1, 2, 1, 3],
				release2 : [1, 2, 1, 4]
			};
		}
		
		#if FLX_JOYSTICK_API
		
		var clear = clearJoystick.bind(inputID);
		var click = clickJoystick.bind(inputID);
		testInputStates(test, clear, click, a, b, c, d, callbacks, stateGrid);
		
		#elseif FLX_GAMEPAD_API
		
		//TODO, not yet implemented:
		
		/*
		var clear = clearGamepad.bind(inputID);
		var click = clickGamepad.bind(inputID);
		testInputStates(test, clear, click, a, b, c, d, callbacks, stateGrid);
		*/
		
		#end
	}
	
	@Test
	function testFlxActionManagerInit()
	{
		var manager = _createFlxActionManager();
		
		Assert.isTrue(manager.numSets == 3);
		
		var t = new TestShell("actionSetJson.");
		
		var sets = 
		[
			"MenuControls", 
			"MapControls", 
			"BattleControls"
		];
		
		var analog = 
		[
			["menu_move"],
			["scroll_map", "move_map"],
			["move"]
		];
		
		var digital = 
		[
			["menu_up", "menu_down", "menu_left", "menu_right", "menu_select", "menu_menu", "menu_cancel", "menu_thing_1", "menu_thing_2", "menu_thing_3"],
			["map_select", "map_exit", "map_menu", "map_journal"],
			["punch", "kick", "jump"]
		];
		
		_testFlxActionManagerInit(t, manager, sets, analog, digital);
		
		t.assertTrue("actionSetJson.MenuControls.indexExists");
		t.assertTrue("actionSetJson.MenuControls.nameMatches");
		t.assertTrue("actionSetJson.MenuControls.setExists");
		t.assertTrue("actionSetJson.MenuControls.hasDigital");
		t.assertTrue("actionSetJson.MenuControls.hasAnalog");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_up.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_down.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_left.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_right.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_select.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_menu.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_cancel.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_thing_1.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_thing_2.exists");
		t.assertTrue("actionSetJson.MenuControls.digital.menu_thing_3.exists");
		t.assertTrue("actionSetJson.MenuControls.analog.menu_move.exists");
		t.assertTrue("actionSetJson.MenuControls.activatedFor.MOUSE");
		t.assertTrue("actionSetJson.MenuControls.activatedFor.KEYBOARD");
		t.assertTrue("actionSetJson.MenuControls.activatedFor.GAMEPAD");
		t.assertTrue("actionSetJson.MenuControls.activatedFor.STEAM_CONTROLLER");
		t.assertTrue("actionSetJson.MenuControls.activatedFor.ALL");
		t.assertTrue("actionSetJson.MenuControls.activatedForAll.MOUSE");
		t.assertTrue("actionSetJson.MenuControls.activatedForAll.KEYBOARD");
		t.assertTrue("actionSetJson.MenuControls.activatedForAll.GAMEPAD");
		t.assertTrue("actionSetJson.MenuControls.activatedForAll.STEAM_CONTROLLER");
		
		t.assertTrue("actionSetJson.MapControls.indexExists");
		t.assertTrue("actionSetJson.MapControls.nameMatches");
		t.assertTrue("actionSetJson.MapControls.setExists");
		t.assertTrue("actionSetJson.MapControls.hasDigital");
		t.assertTrue("actionSetJson.MapControls.hasAnalog");
		t.assertTrue("actionSetJson.MapControls.digital.map_select.exists");
		t.assertTrue("actionSetJson.MapControls.digital.map_exit.exists");
		t.assertTrue("actionSetJson.MapControls.digital.map_menu.exists");
		t.assertTrue("actionSetJson.MapControls.digital.map_journal.exists");
		t.assertTrue("actionSetJson.MapControls.analog.scroll_map.exists");
		t.assertTrue("actionSetJson.MapControls.analog.move_map.exists");
		t.assertTrue("actionSetJson.MapControls.activatedFor.MOUSE");
		t.assertTrue("actionSetJson.MapControls.activatedFor.KEYBOARD");
		t.assertTrue("actionSetJson.MapControls.activatedFor.GAMEPAD");
		t.assertTrue("actionSetJson.MapControls.activatedFor.STEAM_CONTROLLER");
		t.assertTrue("actionSetJson.MapControls.activatedFor.ALL");
		t.assertTrue("actionSetJson.MapControls.activatedForAll.MOUSE");
		t.assertTrue("actionSetJson.MapControls.activatedForAll.KEYBOARD");
		t.assertTrue("actionSetJson.MapControls.activatedForAll.GAMEPAD");
		t.assertTrue("actionSetJson.MapControls.activatedForAll.STEAM_CONTROLLER");
		
		t.assertTrue("actionSetJson.BattleControls.indexExists");
		t.assertTrue("actionSetJson.BattleControls.nameMatches");
		t.assertTrue("actionSetJson.BattleControls.setExists");
		t.assertTrue("actionSetJson.BattleControls.hasDigital");
		t.assertTrue("actionSetJson.BattleControls.hasAnalog");
		t.assertTrue("actionSetJson.BattleControls.digital.punch.exists");
		t.assertTrue("actionSetJson.BattleControls.digital.kick.exists");
		t.assertTrue("actionSetJson.BattleControls.digital.jump.exists");
		t.assertTrue("actionSetJson.BattleControls.analog.move.exists");
		t.assertTrue("actionSetJson.BattleControls.activatedFor.MOUSE");
		t.assertTrue("actionSetJson.BattleControls.activatedFor.KEYBOARD");
		t.assertTrue("actionSetJson.BattleControls.activatedFor.GAMEPAD");
		t.assertTrue("actionSetJson.BattleControls.activatedFor.STEAM_CONTROLLER");
		t.assertTrue("actionSetJson.BattleControls.activatedFor.ALL");
		t.assertTrue("actionSetJson.BattleControls.activatedForAll.MOUSE");
		t.assertTrue("actionSetJson.BattleControls.activatedForAll.KEYBOARD");
		t.assertTrue("actionSetJson.BattleControls.activatedForAll.GAMEPAD");
		t.assertTrue("actionSetJson.BattleControls.activatedForAll.STEAM_CONTROLLER");
		
		manager.destroy();
	}
	
	private function _createFlxActionManager():FlxActionManager
	{
		var manager = new FlxActionManager();
		
		var actionsText = '{"actionSets":[{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]},{"name":"MapControls","analogActions":["scroll_map","move_map"],"digitalActions":["map_select","map_exit","map_menu","map_journal"]},{"name":"BattleControls","analogActions":["move"],"digitalActions":["punch","kick","jump"]}]}';
		var actionsJSON = Json.parse(actionsText);
		
		manager.initFromJSON(actionsJSON, null, null);
		
		return manager;
	}
	
	function _testFlxActionManagerInit(test:TestShell, manager:FlxActionManager, sets:Array<String>, analog:Array<Array<String>>, digital:Array<Array<String>>)
	{
		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];
			
			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);
			
			test.prefix = set + ".";
			
			test.testIsTrue(setIndex != -1, "indexExists");
			test.testIsTrue(setName == set, "nameMatches");
			test.testIsTrue(setObject != null, "setExists");
			test.testIsTrue(setObject.digitalActions != null && setObject.digitalActions.length > 0, "hasDigital");
			test.testIsTrue(setObject.analogActions != null && setObject.analogActions.length > 0, "hasAnalog");
			
			for (j in 0...setObject.digitalActions.length)
			{
				var d:FlxActionDigital = setObject.digitalActions[j];
				test.testIsTrue(digitals.indexOf(d.name) != -1, "digital."+d.name+".exists");
			}
			
			for (j in 0...setObject.analogActions.length)
			{
				var a:FlxActionAnalog = setObject.analogActions[j];
				test.testIsTrue(analogs.indexOf(a.name) != -1, "analog." + a.name+".exists");
			}
			
			var devices:Array<FlxInputDevice> = 
			[
					MOUSE,
					KEYBOARD,
					GAMEPAD,
					STEAM_CONTROLLER,
					ALL
			];
			
			for (k in 0...devices.length)
			{
				var device = devices[k];
				manager.activateSet(setIndex, device);
				var activatedSet = manager.getSetActivatedForDevice(device);
				
				test.testIsTrue(setObject == activatedSet, "activatedFor." + device);
				if (device == ALL)
				{
					test.testIsTrue(setObject == activatedSet, "activatedForAll." + FlxInputDevice.MOUSE);
					test.testIsTrue(setObject == activatedSet, "activatedForAll." + FlxInputDevice.KEYBOARD);
					test.testIsTrue(setObject == activatedSet, "activatedForAll." + FlxInputDevice.GAMEPAD);
					test.testIsTrue(setObject == activatedSet, "activatedForAll." + FlxInputDevice.STEAM_CONTROLLER);
				}
			}
		}
	}
	
	@Test
	function testSteamDigital()
	{
		
	}
	
	function _testSteam(test:TestShell, actionHandle:Int, callbacks:Bool)
	{
		/*
		var a:FlxActionInputDigitalSteam;
		var b:FlxActionInputDigitalSteam;
		var c:FlxActionInputDigitalSteam;
		var d:FlxActionInputDigitalSteam;
		
		var stateGrid:InputStateGrid = null;
		
		a = @:privateAccess new FlxActionInputDigitalSteam(actionHandle, FlxInputState.PRESSED, 0);
		b = @:privateAccess new FlxActionInputDigitalSteam(actionHandle, FlxInputState.JUST_PRESSED, 0);
		c = @:privateAccess new FlxActionInputDigitalSteam(actionHandle, FlxInputState.RELEASED, 0);
		d = @:privateAccess new FlxActionInputDigitalSteam(actionHandle, FlxInputState.JUST_RELEASED, 0);
		
		var clear = clearSteam.bind(actionHandle);
		var click = clickSteam.bind(actionHandle);
		
		testInputStates(test, clear, click, a, b, c, d, callbacks, stateGrid);
		*/
	}
	
	/*********/
	
	function getCallback(i:Int){
		return function (a:FlxActionDigital){
			onCallback(i);
		}
	}
	
	function testInputStates(test:TestShell, clear:Void->Void, click:Bool->Array<FlxActionDigital>->Void, pressed:FlxActionInputDigital, jPressed:FlxActionInputDigital, released:FlxActionInputDigital, jReleased:FlxActionInputDigital, testCallbacks:Bool, ?g:InputStateGrid)
	{
		if (g == null)
		{
			g =
			{
				press1   : [1, 1, 0, 0],
				press2   : [1, 2, 0, 0],
				release1 : [1, 2, 1, 1],
				release2 : [1, 2, 1, 2]
			};
		}
		
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
		clearValues();
		
		var callbackStr = (testCallbacks ? "callbacks." : "");
		
		test.prefix = "press1." + callbackStr;
		
		//JUST PRESSED
		click(true, arr);
		
		test.testIsTrue(ajPressed.triggered, "just");
		test.testIsTrue(aPressed.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == g.press1[0], "callback1");
			test.testIsTrue(value1 == g.press1[1], "callback2");
			test.testIsTrue(value2 == g.press1[2], "callback3");
			test.testIsTrue(value3 == g.press1[3], "callback4");
		}
		
		test.prefix = "press2." + callbackStr;
		
		//STILL PRESSED
		click(true, arr);
		//trace("press2 " + value0 + " " + value1 + " " + value2 + " " + value3);
		
		test.testIsFalse(ajPressed.triggered, "just");
		test.testIsTrue(aPressed.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == g.press2[0], "callback1");
			test.testIsTrue(value1 == g.press2[1], "callback2");
			test.testIsTrue(value2 == g.press2[2], "callback3");
			test.testIsTrue(value3 == g.press2[3], "callback4");
		}
		
		test.prefix = "release1." + callbackStr;
		
		//JUST RELEASED
		click(false, arr);
		//trace("release1 " + value0 + " " + value1 + " " + value2 + " " + value3 + " vs " + g.release1);
		
		test.testIsTrue(ajReleased.triggered, "just");
		test.testIsTrue(aReleased.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == g.release1[0], "callback1");
			test.testIsTrue(value1 == g.release1[1], "callback2");
			test.testIsTrue(value2 == g.release1[2], "callback3");
			test.testIsTrue(value3 == g.release1[3], "callback4");
		}
		
		test.prefix = "release2." + callbackStr;
		
		//STILL RELEASED
		click(false, arr);
		//trace("release2 " + value0 + " " + value1 + " " + value2 + " " + value3 + " vs " + g.release2);
		
		test.testIsFalse(ajReleased.triggered, "just");
		test.testIsTrue(aReleased.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == g.release2[0], "callback1");
			test.testIsTrue(value1 == g.release2[1], "callback2");
			test.testIsTrue(value2 == g.release2[2], "callback3");
			test.testIsTrue(value3 == g.release2[3], "callback4");
		}
		
		clear();
		clearValues();
		
		aPressed.destroy();
		aReleased.destroy();
		ajPressed.destroy();
		ajReleased.destroy();
	}
	
	private function clearSteam(actionHandle:Int)
	{
		SteamMock.setDigitalAction(actionHandle, false);
		SteamMock.update();
		step();
		SteamMock.update();
		step();
	}
	
	private function clearJoystick(ID:FlxGamepadInputID)
	{
		FlxG.stage.dispatchEvent(new JoystickEvent(JoystickEvent.BUTTON_UP, false, false, 0, ID, 0, 0, 0));
		step();
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
		if (FlxG.mouse == null) return;
		FlxG.mouse.wheel = 0;
		step();
		step();
	}
	
	@:access(flixel.input.FlxKeyManager)
	private function clearFlxKey(key:FlxKey)
	{
		var input:FlxInput<Int> = FlxG.keys._keyListMap.get(key);
		if (input == null) return;
		input.release();
		step();
		input.update();
		step();
		input.update();
	}
	
	private function clearMouseButton(button:FlxMouseButton)
	{
		if (button == null) return;
		button.release();
		step();
		button.update();
		step();
		button.update();
	}
	
	private function clearFlxInput(thing:FlxInput<Int>)
	{
		if (thing == null) return;
		thing.release();
		step();
		thing.update();
		step();
		thing.update();
	}
	
	private function clickSteam(actionHandle:Int, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		//updateActions(arr);
	}
	
	private function clickJoystick(ID:FlxGamepadInputID, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		var event = pressed ? JoystickEvent.BUTTON_DOWN : JoystickEvent.BUTTON_UP;
		FlxG.stage.dispatchEvent(new JoystickEvent(event, false, false, 0, ID, 0, 0, 0));
		
		var g = FlxG.gamepads.getByID(0);
		
		step();
		updateActions(arr);
	}
	
	@:access(flixel.input.gamepad.FlxGamepad)
	private function clickFlxGamepad(gamepad:FlxGamepad, ID:FlxGamepadInputID, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		var input:FlxInput<Int> = gamepad.buttons[gamepad.mapping.getRawID(ID)];
		if (input == null) return;
		if (pressed) input.press();
		else input.release();
		updateActions(arr);
	}
	
	@:access(flixel.input.mouse.FlxMouse)
	private function moveFlxMouseWheel(positive:Bool, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		if (FlxG.mouse == null) return;
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
		updateActions(arr);
		step();
	}
	
	@:access(flixel.input.FlxKeyManager)
	private function clickFlxKey(key:FlxKey, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		if (FlxG.keys == null || FlxG.keys._keyListMap == null) return;
		
		var input:FlxInput<Int> = FlxG.keys._keyListMap.get(key);
		if (input == null) return;
		
		step();
		
		input.update();
		
		if (pressed)
		{
			input.press();
		}
		else
		{
			input.release();
		}
		
		updateActions(arr);
		
	}
	
	private function clickMouseButton(button:FlxMouseButton, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		if (button == null) return;
		step();
		button.update();
		if (pressed) button.press();
		else button.release();
		updateActions(arr);
	}
	
	private function clickFlxInput(thing:FlxInput<Int>, pressed:Bool, arr:Array<FlxActionDigital>)
	{
		if (thing == null) return;
		step();
		thing.update();
		if (pressed) thing.press();
		else thing.release();
		updateActions(arr);
	}
	
	private function updateActions(arr:Array<FlxActionDigital>)
	{
		for (a in arr)
		{
			if (a == null) continue;
			a.update();
		}
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

typedef InputStateGrid = 
{
	press1:Array<Int>,
	press2:Array<Int>,
	release1:Array<Int>,
	release2:Array<Int>
}