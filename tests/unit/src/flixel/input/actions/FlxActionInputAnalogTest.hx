package flixel.input.actions;

import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogClickAndDragMouseMotion;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogGamepad;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogMouseMotion;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogMousePosition;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogAxis;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.mouse.FlxMouseButton;
import flixel.math.FlxPoint;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
#if FLX_GAMEINPUT_API
import lime.ui.Gamepad;
import openfl.ui.GameInput;
import openfl.ui.GameInputControl;
import openfl.ui.GameInputDevice;
#elseif FLX_JOYSTICK_API
import openfl.events.JoystickEvent;
#end

class FlxActionInputAnalogTest extends FlxTest
{
	var value0:Int = 0;
	var value1:Int = 0;
	var value2:Int = 0;
	var value3:Int = 0;

	@Before
	function before() {}

	@Ignore @Test
	function testMousePosition()
	{
		var axes = [
			{name: "x", value: FlxAnalogAxis.X},
			{name: "y", value: FlxAnalogAxis.Y},
			{name: "either", value: FlxAnalogAxis.EITHER},
			{name: "both", value: FlxAnalogAxis.BOTH}
		];

		for (a in axes)
		{
			var name = "mouse_pos." + a.name;
			var axis = a.value;

			var t = new TestShell(name + ".");
			runTestMousePosition(t, axis, false);

			// Press & release w/o callbacks
			t.assertTrue(name + ".move1.just");
			t.assertTrue(name + ".move1.value");
			t.assertFalse(name + ".move2.just");
			t.assertTrue(name + ".move2.value");
			t.assertTrue(name + ".stop1.just");
			t.assertTrue(name + ".stop1.value");
			t.assertFalse(name + ".stop2.just");
			t.assertTrue(name + ".stop2.value");
		}
	}

	function runTestMousePosition(test:TestShell, axis:FlxAnalogAxis, callbacks:Bool)
	{
		var a = new FlxActionInputAnalogMousePosition(FlxAnalogState.MOVED, axis);
		var b = new FlxActionInputAnalogMousePosition(FlxAnalogState.JUST_MOVED, axis);
		var c = new FlxActionInputAnalogMousePosition(FlxAnalogState.STOPPED, axis);
		var d = new FlxActionInputAnalogMousePosition(FlxAnalogState.JUST_STOPPED, axis);

		var clear = clearMousePosition;
		var move = moveMousePosition;

		var pos1 = new FlxPoint();
		var pos2 = new FlxPoint();

		switch (axis)
		{
			case X:
				pos1.set(10, 0);
				pos2.set(20, 0);
			case Y:
				pos1.set(0, 10);
				pos2.set(0, 20);
			case EITHER:
				pos1.set(10, 0);
				pos2.set(20, 0);
			case BOTH:
				pos1.set(10, 10);
				pos2.set(20, 20);
		}

		testInputStates(test, clear, move, [pos1, pos2, pos2, pos2], axis, a, b, c, d, callbacks);
	}

	@Ignore @Test
	function testMouseMotion()
	{
		var axes = [
			{name: "x", value: FlxAnalogAxis.X},
			{name: "y", value: FlxAnalogAxis.Y},
			{name: "either", value: FlxAnalogAxis.EITHER},
			{name: "both", value: FlxAnalogAxis.BOTH}
		];

		for (a in axes)
		{
			var name = "mouse_move." + a.name;
			var axis = a.value;

			var t = new TestShell(name + ".");
			runTestMouseMotion(t, axis, false);

			// Press & release w/o callbacks
			t.assertTrue(name + ".move1.just");
			t.assertTrue(name + ".move1.value");
			t.assertFalse(name + ".move2.just");
			t.assertTrue(name + ".move2.value");
			t.assertTrue(name + ".stop1.just");
			t.assertTrue(name + ".stop1.value");
			t.assertFalse(name + ".stop2.just");
			t.assertTrue(name + ".stop2.value");
		}
	}

	function runTestMouseMotion(test:TestShell, axis:FlxAnalogAxis, callbacks:Bool)
	{
		var a = new FlxActionInputAnalogMouseMotion(FlxAnalogState.MOVED, axis);
		var b = new FlxActionInputAnalogMouseMotion(FlxAnalogState.JUST_MOVED, axis);
		var c = new FlxActionInputAnalogMouseMotion(FlxAnalogState.STOPPED, axis);
		var d = new FlxActionInputAnalogMouseMotion(FlxAnalogState.JUST_STOPPED, axis);

		var clear = clearMousePosition;
		var move = moveMousePosition;

		var pos1 = new FlxPoint();
		var pos2 = new FlxPoint();
		var pos3 = new FlxPoint();
		var pos4 = new FlxPoint();

		switch (axis)
		{
			case X:
				pos1.set(50, 0);
				pos2.set(100, 0);
				pos3.set(100, 0);
				pos4.set(100, 0);
			case Y:
				pos1.set(0, 50);
				pos2.set(0, 100);
				pos3.set(0, 100);
				pos4.set(0, 100);
			case EITHER:
				pos1.set(50, 0);
				pos2.set(100, 0);
				pos3.set(100, 0);
				pos4.set(100, 0);
			case BOTH:
				pos1.set(50, 50);
				pos2.set(100, 100);
				pos3.set(100, 100);
				pos4.set(100, 100);
		}

		testInputStates(test, clear, move, [pos1, pos2, pos3, pos4], axis, a, b, c, d, callbacks);
	}

	@Ignore @Test
	function testClickAndDragMouseMotion()
	{
		var axes = [
			{name: "x", value: FlxAnalogAxis.X},
			{name: "y", value: FlxAnalogAxis.Y},
			{name: "either", value: FlxAnalogAxis.EITHER},
			{name: "both", value: FlxAnalogAxis.BOTH}
		];

		var buttons = [
			{name: "left", value: FlxMouseButtonID.LEFT},
			{name: "right", value: FlxMouseButtonID.RIGHT},
			{name: "middle", value: FlxMouseButtonID.MIDDLE}
		];

		for (b in buttons)
		{
			var button = b.value;
			for (a in axes)
			{
				var name = "mouse_click_and_drag_move." + b.name + "." + a.name;
				var axis = a.value;

				var t = new TestShell(name + ".");
				runTestClickAndDragMouseMotion(t, button, axis, false);

				// Press & release w/o callbacks
				t.assertTrue(name + ".move1.just");
				t.assertTrue(name + ".move1.value");
				t.assertFalse(name + ".move2.just");
				t.assertTrue(name + ".move2.value");
				t.assertTrue(name + ".stop1.just");
				t.assertTrue(name + ".stop1.value");
				t.assertFalse(name + ".stop2.just");
				t.assertTrue(name + ".stop2.value");
			}
		}
	}

	function runTestClickAndDragMouseMotion(test:TestShell, button:FlxMouseButtonID, axis:FlxAnalogAxis, callbacks:Bool)
	{
		var a = new FlxActionInputAnalogClickAndDragMouseMotion(button, MOVED, axis);
		var b = new FlxActionInputAnalogClickAndDragMouseMotion(button, JUST_MOVED, axis);
		var c = new FlxActionInputAnalogClickAndDragMouseMotion(button, STOPPED, axis);
		var d = new FlxActionInputAnalogClickAndDragMouseMotion(button, JUST_STOPPED, axis);

		var clear = clearClickAndDragMousePosition;
		var move = moveClickAndDragMousePosition.bind(button);

		var pos1 = new FlxPoint();
		var pos2 = new FlxPoint();
		var pos3 = new FlxPoint();
		var pos4 = new FlxPoint();

		switch (axis)
		{
			case X:
				pos1.set(50, 0);
				pos2.set(100, 0);
				pos3.set(100, 0);
				pos4.set(100, 0);
			case Y:
				pos1.set(0, 50);
				pos2.set(0, 100);
				pos3.set(0, 100);
				pos4.set(0, 100);
			case EITHER:
				pos1.set(50, 0);
				pos2.set(100, 0);
				pos3.set(100, 0);
				pos4.set(100, 0);
			case BOTH:
				pos1.set(50, 50);
				pos2.set(100, 100);
				pos3.set(100, 100);
				pos4.set(100, 100);
		}

		testInputStates(test, clear, move, [pos1, pos2, pos3, pos4], axis, a, b, c, d, callbacks);
	}

	@Test
	function testGamepad()
	{
		#if flash
		return;
		#end

		var inputs = [
			{input: FlxGamepadInputID.LEFT_ANALOG_STICK, value: FlxAnalogAxis.X, label: "left_stick_x"},
			{input: FlxGamepadInputID.LEFT_ANALOG_STICK, value: FlxAnalogAxis.Y, label: "left_stick_y"},
			{input: FlxGamepadInputID.LEFT_ANALOG_STICK, value: FlxAnalogAxis.EITHER, label: "left_stick_either"},
			{input: FlxGamepadInputID.LEFT_ANALOG_STICK, value: FlxAnalogAxis.BOTH, label: "left_stick_both"},
			{input: FlxGamepadInputID.RIGHT_ANALOG_STICK, value: FlxAnalogAxis.X, label: "right_stick_x"},
			{input: FlxGamepadInputID.RIGHT_ANALOG_STICK, value: FlxAnalogAxis.Y, label: "right_stick_y"},
			{input: FlxGamepadInputID.RIGHT_ANALOG_STICK, value: FlxAnalogAxis.EITHER, label: "right_stick_either"},
			{input: FlxGamepadInputID.RIGHT_ANALOG_STICK, value: FlxAnalogAxis.BOTH, label: "right_stick_both"},
			{input: FlxGamepadInputID.LEFT_TRIGGER, value: FlxAnalogAxis.X, label: "left_trigger_x"},
			{input: FlxGamepadInputID.RIGHT_TRIGGER, value: FlxAnalogAxis.X, label: "right_trigger_x"},
		];

		for (inp in inputs)
		{
			var name = "gamepad." + inp.label;
			var input = inp.input;
			var axis = inp.value;

			var t = new TestShell(name + ".");
			runTestGamepad(t, input, axis, false);

			// Press & release w/o callbacks
			t.assertTrue(name + ".move1.just");
			t.assertTrue(name + ".move1.value");
			t.assertFalse(name + ".move2.just");
			t.assertTrue(name + ".move2.value");
			t.assertTrue(name + ".stop1.just");
			t.assertTrue(name + ".stop1.value");
			t.assertFalse(name + ".stop2.just");
			t.assertTrue(name + ".stop2.value");
		}
	}

	function runTestGamepad(test:TestShell, input:FlxGamepadInputID, axis:FlxAnalogAxis, callbacks:Bool)
	{
		#if FLX_JOYSTICK_API
		FlxG.stage.dispatchEvent(new JoystickEvent(JoystickEvent.DEVICE_ADDED, false, false, 0, 0, 0, 0, 0));
		#elseif (!flash && FLX_GAMEINPUT_API)
		var g = makeFakeGamepad();
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.getByID(0);

		var a = new FlxActionInputAnalogGamepad(input, FlxAnalogState.MOVED, axis, 0);
		var b = new FlxActionInputAnalogGamepad(input, FlxAnalogState.JUST_MOVED, axis, 0);
		var c = new FlxActionInputAnalogGamepad(input, FlxAnalogState.STOPPED, axis, 0);
		var d = new FlxActionInputAnalogGamepad(input, FlxAnalogState.JUST_STOPPED, axis, 0);

		var clear = clearGamepad.bind(gamepad, input);
		var move = moveGamepad.bind(gamepad, input);

		var pos1 = new FlxPoint();
		var pos2 = new FlxPoint();
		var pos3 = new FlxPoint();

		switch (axis)
		{
			case X:
				pos1.set(10, 0);
				pos2.set(20, 0);
				pos3.set(0, 0);
			case Y:
				pos1.set(0, 10);
				pos2.set(0, 20);
				pos3.set(0, 0);
			case EITHER:
				pos1.set(10, 0);
				pos2.set(20, 0);
				pos3.set(0, 0);
			case BOTH:
				pos1.set(10, 10);
				pos2.set(20, 20);
				pos3.set(0, 0);
		}

		testInputStates(test, clear, move, [pos1, pos2, pos3, pos3], axis, a, b, c, d, callbacks);

		#if FLX_JOYSTICK_API
		FlxG.stage.dispatchEvent(new JoystickEvent(JoystickEvent.DEVICE_REMOVED, false, false, 0, 0, 0, 0, 0));
		#elseif (!flash && FLX_GAMEINPUT_API)
		removeGamepad(g);
		#end
	}

	#if (!flash && FLX_GAMEINPUT_API)
	function makeFakeGamepad()
	{
		var xinput = @:privateAccess new Gamepad(0);
		@:privateAccess GameInput.__onGamepadConnect(xinput);
		var gamepad = FlxG.gamepads.getByID(0);
		gamepad.model = FlxGamepadModel.XINPUT;
		var gid:GameInputDevice = @:privateAccess gamepad._device;

		@:privateAccess gid.id = "0";
		@:privateAccess gid.name = "xinput";

		var control:GameInputControl = null;

		for (i in 0...6)
		{
			control = @:privateAccess new GameInputControl(gid, "AXIS_" + i, -1, 1);
			@:privateAccess gid.__axis.set(i, control);
			@:privateAccess gid.__controls.push(control);
		}

		for (i in 0...15)
		{
			control = @:privateAccess new GameInputControl(gid, "BUTTON_" + i, 0, 1);
			@:privateAccess gid.__button.set(i, control);
			@:privateAccess gid.__controls.push(control);
		}

		gamepad.update();
		return xinput;
	}

	function removeGamepad(g:Gamepad)
	{
		@:privateAccess GameInput.__onGamepadDisconnect(g);
	}
	#end

	function getCallback(i:Int)
	{
		return function(a:FlxActionAnalog)
		{
			onCallback(i);
		}
	}

	function testInputStates(test:TestShell, clear:Void->Void, move:Float->Float->Array<FlxActionAnalog>->Void, values:Array<FlxPoint>, axis:FlxAnalogAxis,
			moved:FlxActionInputAnalog, jMoved:FlxActionInputAnalog, stopped:FlxActionInputAnalog, jStopped:FlxActionInputAnalog, testCallbacks:Bool)
	{
		var aMoved:FlxActionAnalog;
		var ajMoved:FlxActionAnalog;
		var aStopped:FlxActionAnalog;
		var ajStopped:FlxActionAnalog;

		if (!testCallbacks)
		{
			ajMoved = new FlxActionAnalog("jMoved", null);
			aMoved = new FlxActionAnalog("moved", null);
			ajStopped = new FlxActionAnalog("jStopped", null);
			aStopped = new FlxActionAnalog("stopped", null);
		}
		else
		{
			ajMoved = new FlxActionAnalog("jMoved", getCallback(0));
			aMoved = new FlxActionAnalog("moved", getCallback(1));
			ajStopped = new FlxActionAnalog("jStopped", getCallback(2));
			aStopped = new FlxActionAnalog("stopped", getCallback(3));
		}

		ajMoved.add(jMoved);
		aMoved.add(moved);
		ajStopped.add(jStopped);
		aStopped.add(stopped);

		var arr = [aMoved, ajMoved, aStopped, ajStopped];

		clear();

		var callbackStr = (testCallbacks ? "callbacks." : "");

		test.prefix = "move1." + callbackStr;

		var x1 = values[0].x;
		var y1 = values[0].y;

		var x2 = values[1].x;
		var y2 = values[1].y;

		var x3 = values[2].x;
		var y3 = values[2].y;

		var x4 = values[3].x;
		var y4 = values[3].y;

		// JUST moved
		move(x1, y1, arr);

		test.testBool(ajMoved.triggered, "just");
		test.testBool(aMoved.triggered, "value");
		if (testCallbacks)
		{
			test.testBool(value0 == 1, "callback1");
			test.testBool(value1 == 1, "callback2");
			test.testBool(value2 == 0, "callback3");
			test.testBool(value3 == 0, "callback4");
		}

		test.prefix = "move2." + callbackStr;

		// STILL moved
		move(x2, y2, arr);
		test.testBool(ajMoved.triggered, "just");
		test.testBool(aMoved.triggered, "value");
		if (testCallbacks)
		{
			test.testBool(value0 == 1, "callback1");
			test.testBool(value1 == 2, "callback2");
			test.testBool(value2 == 0, "callback3");
			test.testBool(value3 == 0, "callback4");
		}

		test.prefix = "stop1." + callbackStr;

		// JUST stopped
		move(x3, y3, arr);
		test.testBool(ajStopped.triggered, "just");
		test.testBool(aStopped.triggered, "value");
		if (testCallbacks)
		{
			test.testBool(value0 == 1, "callback1");
			test.testBool(value1 == 2, "callback2");
			test.testBool(value2 == 1, "callback3");
			test.testBool(value3 == 1, "callback4");
		}

		test.prefix = "stop2." + callbackStr;

		// STILL stopped
		move(x4, y4, arr);
		test.testBool(ajStopped.triggered, "just");
		test.testBool(aStopped.triggered, "value");
		if (testCallbacks)
		{
			test.testBool(value0 == 1, "callback1");
			test.testBool(value1 == 2, "callback2");
			test.testBool(value2 == 1, "callback3");
			test.testBool(value3 == 2, "callback4");
		}

		clear();
		clearValues();

		aMoved.destroy();
		aStopped.destroy();
		ajMoved.destroy();
		ajStopped.destroy();
	}

	@:access(flixel.input.mouse.FlxMouse)
	function clearClickAndDragMousePosition()
	{
		if (FlxG.mouse == null)
			return;
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);

		var left = @:privateAccess FlxG.mouse._leftButton;
		var right = @:privateAccess FlxG.mouse._rightButton;
		var middle = @:privateAccess FlxG.mouse._middleButton;

		left.update();
		right.update();
		middle.update();

		step();
		step();
	}

	@:access(flixel.input.gamepad.FlxGamepad)
	function clearGamepad(Gamepad:FlxGamepad, Input:FlxGamepadInputID)
	{
		if (Input == FlxGamepadInputID.LEFT_ANALOG_STICK || Input == FlxGamepadInputID.RIGHT_ANALOG_STICK)
		{
			var stick:FlxGamepadAnalogStick = Gamepad.mapping.getAnalogStick(Input);
			moveStick(Gamepad, stick, 0.0, 0.0);
		}
		else
		{
			moveTrigger(Gamepad, Input, 0.0);
		}
		step();
		step();
	}

	@:access(flixel.input.gamepad.FlxGamepad)
	function moveTrigger(Gamepad:FlxGamepad, Input:FlxGamepadInputID, X:Float)
	{
		#if FLX_JOYSTICK_API
		var fakeAxisRawID:Int = Gamepad.mapping.checkForFakeAxis(Input);
		if (fakeAxisRawID == -1)
		{
			// regular axis value
			var rawID = Gamepad.mapping.getRawID(Input);
			Gamepad.applyAxisFlip(X, Input);
			Gamepad.axis[rawID] = X;
		}
		else
		{
			// if analog isn't supported for this input, return the correct digital button input instead
			var btn:FlxGamepadButton = Gamepad.getButton(fakeAxisRawID);
			if (btn != null)
			{
				btn.release();
			}
		}
		#elseif (FLX_GAMEINPUT_API && !flash)
		var rawAxisID = Gamepad.mapping.getRawID(Input);
		var control:GameInputControl = Gamepad._device.getControlAt(rawAxisID);
		@:privateAccess control.value = X;
		#end
	}

	@:access(flixel.input.gamepad.FlxGamepad)
	function moveStick(Gamepad:FlxGamepad, stick:FlxGamepadAnalogStick, X:Float, Y:Float)
	{
		#if FLX_JOYSTICK_API
		Gamepad.axis[stick.x] = X;
		Gamepad.axis[stick.y] = Y;
		#elseif (FLX_GAMEINPUT_API && !flash)
		var controlX:GameInputControl = Gamepad._device.getControlAt(stick.x);
		var controlY:GameInputControl = Gamepad._device.getControlAt(stick.y);
		@:privateAccess controlX.value = X;
		@:privateAccess controlY.value = Y;
		#end
	}

	@:access(flixel.input.mouse.FlxMouse)
	function clearMousePosition()
	{
		if (FlxG.mouse == null)
			return;
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
		step();
		step();
	}

	function moveClickAndDragMousePosition(Button:FlxMouseButtonID, X:Float, Y:Float, arr:Array<FlxActionAnalog>)
	{
		var button:FlxMouseButton = switch (Button)
		{
			case FlxMouseButtonID.LEFT: @:privateAccess FlxG.mouse._leftButton;
			case FlxMouseButtonID.RIGHT: @:privateAccess FlxG.mouse._rightButton;
			case FlxMouseButtonID.MIDDLE: @:privateAccess FlxG.mouse._middleButton;
			default: null;
		}

		button.press();

		if (FlxG.mouse == null)
			return;
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		updateActions(arr);
	}

	@:access(flixel.input.gamepad.FlxGamepad)
	function moveGamepad(Gamepad:FlxGamepad, Input:FlxGamepadInputID, X:Float, Y:Float, arr:Array<FlxActionAnalog>)
	{
		step();

		if (Input == FlxGamepadInputID.LEFT_ANALOG_STICK || Input == FlxGamepadInputID.RIGHT_ANALOG_STICK)
		{
			var stick = Gamepad.mapping.getAnalogStick(Input);
			moveStick(Gamepad, stick, X, Y);
		}
		else
		{
			moveTrigger(Gamepad, Input, X);
		}

		updateActions(arr);
	}

	function moveMousePosition(X:Float, Y:Float, arr:Array<FlxActionAnalog>)
	{
		if (FlxG.mouse == null)
			return;
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		updateActions(arr);
	}

	function updateActions(arr:Array<FlxActionAnalog>)
	{
		for (a in arr)
		{
			if (a == null)
				continue;
			a.update();
		}
	}

	function onCallback(i:Int)
	{
		switch (i)
		{
			case 0:
				value0++;
			case 1:
				value1++;
			case 2:
				value2++;
			case 3:
				value3++;
		}
	}

	function clearValues()
	{
		value0 = value1 = value2 = value3 = 0;
	}
}
