package flixel.system.input;

import flixel.FlxG;
import flixel.system.input.gamepad.FlxGamepadManager;
import flixel.system.input.keyboard.FlxKeyboard;

class FlxInputs {
	
	/**
	 * An array for inputs enabled in the system.
	 */
	public static  var inputs:Array<IFlxInput>;
	
    public function new() {}
	
	/**
	 * Initiate the default Inputs
	 */
	static public function init():Void
	{
		inputs = null;
		inputs = new Array<IFlxInput>();
		
		#if !FLX_NO_KEYBOARD
			initKeyboard();
		#end
		
		#if !FLX_NO_MOUSE
			initMouse();
		#end
		
		#if !FLX_NO_TOUCH
			initTouch();
		#end
		
		#if (!FLX_NO_GAMEPAD && (cpp||neko))
			initGamepad();
		#end
		
	}
	
	/**
	 * Add an input to the system
	 */
	static public function addInput(input:IFlxInput):IFlxInput
	{
		//Don't add repeats
		var l:Int = inputs.length;
		for (i in 0...l)
		{
			if (inputs[i].toString() == inputs.toString())
			{
				return input;
			}
		}
		
		inputs.push(input);
		return input;
	}	
	
	/**
	 * Updates the inputs
	 */
	inline static public function updateInputs():Void
	{
		var i:Int = 0;
		var l:Int = inputs.length;
		while(i < l)
		{
			var input = inputs[i++];
				input.update();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame FocusLost
	 */	
	static public function onFocusLost():Void {
		var i:Int = 0;
		var l:Int = inputs.length;
		while(i < l)
		{
			var input = inputs[i++];
				input.onFocusLost();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame Focus
	 */
	static public function onFocus():Void {
		var i:Int = 0;
		var l:Int = inputs.length;
		while(i < l)
		{
			var input = inputs[i++];
				input.onFocus();
		}
	}
	
	/**
	 * Resets the inputs
	 */
	static public function resetInputs():Void
	{
		var i:Int = 0;
		var l:Int = inputs.length;
		while(i < l)
		{
			var input = inputs[i++];
			input.reset();
		}
	}
	
	#if (!FLX_NO_GAMEPAD && (cpp||neko))
	static public function initGamepad():Void
	{
		var gamepad = new FlxGamepadManager();
		FlxG.gamepadManager = gamepad;
		inputs.push(gamepad);
	}
	#end
	
	#if !FLX_NO_KEYBOARD
	static public function initKeyboard():Void
	{
		var key = new FlxKeyboard();
		FlxG.keys = key;
		inputs.push(key);
	}
	#end

	#if !FLX_NO_MOUSE
	static public function initMouse():Void
	{
		var mouse = new FlxMouse(FlxG.game.inputContainer);
		FlxG.mouse = mouse;
		inputs.push(mouse);
	}
	#end

	#if !FLX_NO_TOUCH
	static public function initTouch():Void
	{
		var touch =  new FlxTouchManager();
		FlxG.touchManager = touch;
		inputs.push(touch);
	}
	#end
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		var i:Int = 0;
		var l:Int = inputs.length;
		while(i < l)
		{
			var input = inputs[i++];
			input.destroy();
			input = null;
		}
	}
}