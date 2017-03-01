package flixel.input.actions;
import flixel.input.FlxInput;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogClickAndDragMouseMotion;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogMouseMotion;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogMousePosition;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogAxis;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogState;
import flixel.input.mouse.FlxMouseButton;
import flixel.math.FlxPoint;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.PosInfos;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;

import massive.munit.Assert;

/**
 * ...
 * @author 
 */
class FlxActionInputAnalogTest extends FlxTest
{
	private var value0:Int = 0;
	private var value1:Int = 0;
	private var value2:Int = 0;
	private var value3:Int = 0;
	
	@Before
	function before()
	{
	}
	
	@Test
	function testMousePosition()
	{
		var axes = 
		[
			{name:"x", value:FlxAnalogAxis.X}, 
			{name:"y", value:FlxAnalogAxis.Y}, 
			{name:"either", value:FlxAnalogAxis.EITHER},
			{name:"both", value:FlxAnalogAxis.BOTH}
		];
		
		for (a in axes)
		{
			var name = "mouse_pos."+a.name;
			var axis = a.value;
			
			var t = new TestShell(name+".");
			_testMousePosition(t, axis, false);
			
			//Press & release w/o callbacks
			t.assertTrue (name+".move1.just");
			t.assertTrue (name+".move1.value");
			t.assertFalse(name+".move2.just");
			t.assertTrue (name+".move2.value");
			t.assertTrue (name+".stop1.just");
			t.assertTrue (name+".stop1.value");
			t.assertFalse(name+".stop2.just");
			t.assertTrue (name+".stop2.value");
		}
	}
	
	function _testMousePosition(test:TestShell, axis:FlxAnalogAxis, callbacks:Bool)
	{
		var a = new FlxActionInputAnalogMousePosition(FlxAnalogState.MOVED, axis);
		var b = new FlxActionInputAnalogMousePosition(FlxAnalogState.JUST_MOVED, axis);
		var c = new FlxActionInputAnalogMousePosition(FlxAnalogState.STOPPED, axis);
		var d = new FlxActionInputAnalogMousePosition(FlxAnalogState.JUST_STOPPED, axis);
		
		var clear = clearMousePosition;
		var move = moveMousePosition;
		
		var pos1 = new FlxPoint();
		var pos2 = new FlxPoint();
		
		switch(axis)
		{
			case X:      pos1.set(10,  0); pos2.set(20,  0);
			case Y:      pos1.set( 0, 10); pos2.set( 0, 20);
			case EITHER: pos1.set(10,  0); pos2.set(20,  0);
			case BOTH:   pos1.set(10, 10); pos2.set(20, 20);
		}
		
		testInputStates(test, clear, move, [pos1,pos2,pos2,pos2], axis, a, b, c, d, callbacks);
	}
	
	@Test
	function testMouseMotion()
	{
		var axes = 
		[
			{name:"x", value:FlxAnalogAxis.X},
			{name:"y", value:FlxAnalogAxis.Y}, 
			{name:"either", value:FlxAnalogAxis.EITHER},
			{name:"both", value:FlxAnalogAxis.BOTH}
		];
		
		for (a in axes)
		{
			var name = "mouse_move."+a.name;
			var axis = a.value;
			
			var t = new TestShell(name+".");
			_testMouseMotion(t, axis, false);
			
			//Press & release w/o callbacks
			t.assertTrue (name+".move1.just");
			t.assertTrue (name+".move1.value");
			t.assertFalse(name+".move2.just");
			t.assertTrue (name+".move2.value");
			t.assertTrue (name+".stop1.just");
			t.assertTrue (name+".stop1.value");
			t.assertFalse(name+".stop2.just");
			t.assertTrue (name+".stop2.value");
		}
	}
	
	function _testMouseMotion(test:TestShell, axis:FlxAnalogAxis, callbacks:Bool)
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
		
		switch(axis)
		{
			case X: 
				pos1.set( 50,   0);
				pos2.set(100,   0);
				pos3.set(100,   0);
				pos4.set(100,   0);
			case Y:
				pos1.set(  0,  50);
				pos2.set(  0, 100);
				pos3.set(  0, 100);
				pos4.set(  0, 100);
			case EITHER:
				pos1.set( 50,   0);
				pos2.set(100,   0);
				pos3.set(100,   0);
				pos4.set(100,   0);
			case BOTH:
				pos1.set( 50,  50);
				pos2.set(100, 100);
				pos3.set(100, 100);
				pos4.set(100, 100);
		}
		
		testInputStates(test, clear, move, [pos1,pos2,pos3,pos4], axis, a, b, c, d, callbacks);
	}
	
	@Test
	function testClickAndDragMouseMotion()
	{
		var axes = 
		[
			{name:"x", value:FlxAnalogAxis.X},
			{name:"y", value:FlxAnalogAxis.Y}, 
			{name:"either", value:FlxAnalogAxis.EITHER},
			{name:"both", value:FlxAnalogAxis.BOTH}
		];
		
		var buttons = 
		[
			{name:"left", value:FlxMouseButtonID.LEFT},
			{name:"right", value:FlxMouseButtonID.RIGHT},
			{name:"middle", value:FlxMouseButtonID.MIDDLE}
		];
		
		for (b in buttons)
		{
			var button = b.value;
			for (a in axes)
			{
				var name = "mouse_click_and_drag_move."+b.name+"."+a.name;
				var axis = a.value;
				
				var t = new TestShell(name+".");
				_testClickAndDragMouseMotion(t, button, axis, false);
				
				//Press & release w/o callbacks
				t.assertTrue (name+".move1.just");
				t.assertTrue (name+".move1.value");
				t.assertFalse(name+".move2.just");
				t.assertTrue (name+".move2.value");
				t.assertTrue (name+".stop1.just");
				t.assertTrue (name+".stop1.value");
				t.assertFalse(name+".stop2.just");
				t.assertTrue (name+".stop2.value");
			}
		}
	}
	
	function _testClickAndDragMouseMotion(test:TestShell, button:FlxMouseButtonID, axis:FlxAnalogAxis, callbacks:Bool)
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
		
		switch(axis)
		{
			case X: 
				pos1.set( 50,   0);
				pos2.set(100,   0);
				pos3.set(100,   0);
				pos4.set(100,   0);
			case Y:
				pos1.set(  0,  50);
				pos2.set(  0, 100);
				pos3.set(  0, 100);
				pos4.set(  0, 100);
			case EITHER:
				pos1.set( 50,   0);
				pos2.set(100,   0);
				pos3.set(100,   0);
				pos4.set(100,   0);
			case BOTH:
				pos1.set( 50,  50);
				pos2.set(100, 100);
				pos3.set(100, 100);
				pos4.set(100, 100);
		}
		
		testInputStates(test, clear, move, [pos1,pos2,pos3,pos4], axis, a, b, c, d, callbacks);
	}
	
	function testGamepad()
	{
		//TODO
	}
	
	function testSteam()
	{
		//TODO
	}
	
	/*********/
	
	function getCallback(i:Int){
		return function (a:FlxActionAnalog){
			onCallback(i);
		}
	}
	
	function testInputStates(test:TestShell, clear:Void->Void, move:Float->Float->Array<FlxActionAnalog>->Void, values:Array<FlxPoint>, axis:FlxAnalogAxis, moved:FlxActionInputAnalog, jMoved:FlxActionInputAnalog, stopped:FlxActionInputAnalog, jStopped:FlxActionInputAnalog, testCallbacks:Bool)
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
		
		ajMoved.addInput(jMoved);
		aMoved.addInput(moved);
		ajStopped.addInput(jStopped);
		aStopped.addInput(stopped);
		
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
		
		//JUST moved
		move(x1, y1, arr);
		
		test.testIsTrue(ajMoved.triggered, "just");
		test.testIsTrue(aMoved.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == 1, "callback1");
			test.testIsTrue(value1 == 1, "callback2");
			test.testIsTrue(value2 == 0, "callback3");
			test.testIsTrue(value3 == 0, "callback4");
		}
		
		test.prefix = "move2." + callbackStr;
		
		//STILL moved
		move(x2, y2, arr);
		test.testIsFalse(ajMoved.triggered, "just");
		test.testIsTrue(aMoved.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == 1, "callback1");
			test.testIsTrue(value1 == 2, "callback2");
			test.testIsTrue(value2 == 0, "callback3");
			test.testIsTrue(value3 == 0, "callback4");
		}
		
		test.prefix = "stop1." + callbackStr;
		
		//JUST stopped
		move(x3, y3, arr);
		test.testIsTrue(ajStopped.triggered, "just");
		test.testIsTrue(aStopped.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == 1, "callback1");
			test.testIsTrue(value1 == 2, "callback2");
			test.testIsTrue(value2 == 1, "callback3");
			test.testIsTrue(value3 == 1, "callback4");
		}
		
		test.prefix = "stop2." + callbackStr;
		
		//STILL stopped
		move(x4, y4, arr);
		test.testIsFalse(ajStopped.triggered, "just");
		test.testIsTrue(aStopped.triggered, "value");
		if (testCallbacks)
		{
			test.testIsTrue(value0 == 1, "callback1");
			test.testIsTrue(value1 == 2, "callback2");
			test.testIsTrue(value2 == 1, "callback3");
			test.testIsTrue(value3 == 2, "callback4");
		}
		
		clear();
		clearValues();
		
		aMoved.destroy();
		aStopped.destroy();
		ajMoved.destroy();
		ajStopped.destroy();
	}
	
	@:access(flixel.input.mouse.FlxMouse)
	private function clearClickAndDragMousePosition()
	{
		if (FlxG.mouse == null) return;
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
	
	@:access(flixel.input.mouse.FlxMouse)
	private function clearMousePosition()
	{
		if (FlxG.mouse == null) return;
		FlxG.mouse.setGlobalScreenPositionUnsafe(0, 0);
		step();
		step();
	}
	
	private function moveClickAndDragMousePosition(Button:FlxMouseButtonID, X:Float, Y:Float, arr:Array<FlxActionAnalog>)
	{
		var button:FlxMouseButton = switch(Button)
		{
			case FlxMouseButtonID.LEFT: @:privateAccess FlxG.mouse._leftButton;
			case FlxMouseButtonID.RIGHT: @:privateAccess FlxG.mouse._rightButton;
			case FlxMouseButtonID.MIDDLE: @:privateAccess FlxG.mouse._middleButton;
			default: null;
		}
		
		button.press();
		
		if (FlxG.mouse == null) return;
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		updateActions(arr);
	}
	
	private function moveMousePosition(X:Float, Y:Float, arr:Array<FlxActionAnalog>)
	{
		if (FlxG.mouse == null) return;
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		updateActions(arr);
	}
	
	private function updateActions(arr:Array<FlxActionAnalog>)
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