package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	/**
	 * How big the tiles of the tilemap are.
	 */
	static inline var TILE_SIZE:Int = 32;
	/**
	 * How many pixels to move each frame.
	 */
	static inline var MOVEMENT_SPEED:Int = 2;
	
	var up:FlxActionDigital;
	var down:FlxActionDigital;
	var left:FlxActionDigital;
	var right:FlxActionDigital;
	
	var moveAnalog:FlxActionAnalog;
	
	var trigger1:FlxActionAnalog;
	var trigger2:FlxActionAnalog;
	
	var move:FlxActionAnalog;
	
	var _virtualPad:FlxVirtualPad;
	var _analogWidget:AnalogWidget;
	
	var moveX:Float = 0;
	var moveY:Float = 0;
	
	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		// Make the player graphic.
		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.WHITE);
		
		addInputs();
	}
	
	function addInputs():Void
	{
		//Add on screen virtual pad to demonstrate UI buttons tied to actions
		_virtualPad = new FlxVirtualPad(FULL, NONE);
		_virtualPad.alpha = 0.5;
		_virtualPad.x += 50;
		_virtualPad.y -= 20;
		FlxG.state.add(_virtualPad);
		
		//Add on screen analog indicator to expose values of analog inputs in real time
		_analogWidget = new AnalogWidget();
		_analogWidget.alpha = 0.5;
		_analogWidget.x -= 10;
		_analogWidget.y -= 2;
		FlxG.state.add(_analogWidget);
		
		//digital actions allow for on/off directional movement
		up = new FlxActionDigital();
		down = new FlxActionDigital();
		left = new FlxActionDigital();
		right = new FlxActionDigital();
		
		//these actions don't do anything, but their values are exposed in the analog visualizer
		trigger1 = new FlxActionAnalog();
		trigger2 = new FlxActionAnalog();
		
		//this analog action allows for smooth movement
		move = new FlxActionAnalog();
		
		var manager = new FlxActionManager();
		FlxG.inputs.add(manager);
		manager.addActions([up,down,left,right,trigger1,trigger2,move]);
		
		//Add keyboard inputs
		up.addKey(UP, PRESSED);
		up.addKey(W, PRESSED);
		down.addKey(DOWN, PRESSED);
		down.addKey(S, PRESSED);
		left.addKey(LEFT, PRESSED);
		left.addKey(A, PRESSED);
		right.addKey(RIGHT, PRESSED);
		right.addKey(D, PRESSED);
		
		//Add virtual pad (on-screen button) inputs
		up.addInput(_virtualPad.buttonUp, PRESSED);
		down.addInput(_virtualPad.buttonDown, PRESSED);
		left.addInput(_virtualPad.buttonLeft, PRESSED);
		right.addInput(_virtualPad.buttonRight, PRESSED);
		
		//Add gamepad DPAD inputs
		up.addGamepad(DPAD_UP, PRESSED);
		down.addGamepad(DPAD_DOWN, PRESSED);
		left.addGamepad(DPAD_LEFT, PRESSED);
		right.addGamepad(DPAD_RIGHT, PRESSED);
		
		//Add gamepad analog stick (as simulated DPAD) inputs
		up.addGamepad(LEFT_STICK_DIGITAL_UP, PRESSED);
		down.addGamepad(LEFT_STICK_DIGITAL_DOWN, PRESSED);
		left.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED);
		right.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED);
		
		//Add gamepad analog trigger inputs
		trigger1.addGamepad(LEFT_TRIGGER,  MOVED);
		trigger2.addGamepad(RIGHT_TRIGGER, MOVED);
		
		//Add gamepad analog stick (as actual analog value) motion input
		move.addGamepad(RIGHT_ANALOG_STICK, MOVED, EITHER);
		
		//Add relative mouse movement as motion input
		move.addMouseMotion(MOVED, EITHER);
		
		FlxG.mouse.visible = true;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		velocity.x = 0;
		velocity.y = 0;
		
		y += moveY * MOVEMENT_SPEED;
		x += moveX * MOVEMENT_SPEED;
		
		moveX = 0;
		moveY = 0;
		
		updateDigital();
		updateAnalog();
	}
	
	function updateDigital():Void
	{
		_virtualPad.buttonUp.color = FlxColor.WHITE;
		_virtualPad.buttonDown.color = FlxColor.WHITE;
		_virtualPad.buttonLeft.color = FlxColor.WHITE;
		_virtualPad.buttonRight.color = FlxColor.WHITE;
		
		if (down.triggered)
		{
			_virtualPad.buttonDown.color = FlxColor.LIME;
			moveY = 1;
		}
		else if (up.triggered)
		{
			_virtualPad.buttonUp.color = FlxColor.LIME;
			moveY = -1;
		}
		
		if (left.triggered)
		{
			_virtualPad.buttonLeft.color = FlxColor.LIME;
			moveX = -1;
		}
		else if (right.triggered)
		{
			_virtualPad.buttonRight.color = FlxColor.LIME;
			moveX = 1;
		}
		
		if (moveX != 0 && moveY != 0)
		{
			moveY *= .707;
			moveX *= .707;
		}
	}
	
	function updateAnalog():Void
	{
		_analogWidget.setValues(move.x, move.y);
		_analogWidget.l = trigger1.x;
		_analogWidget.r = trigger2.x;
		
		if (Math.abs(moveX) < 0.001)
			moveX = move.x;
		
		if (Math.abs(moveY) < 0.001)
			moveY = move.y;
	}
}
