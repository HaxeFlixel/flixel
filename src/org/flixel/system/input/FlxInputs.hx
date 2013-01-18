package org.flixel.system.input;

import org.flixel.FlxGame;
import org.flixel.FlxBasic;
import org.flixel.FlxG;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;

class FlxInputs {
	
	/**
	 * An array for inputs enabled in the system.
	 */
	public static  var inputs:Array<IFlxInput>;
	
    public function new() {}
	
	/**
	 * Initiate the default Inputs
	 */
	static public function init(enabledInputs:FlxInputList = null):Void
	{
		inputs = null;
		inputs = new Array<IFlxInput>();
		
		if ( enabledInputs == null)
			enabledInputs = getDefaultInputs();
		
		#if (keyboard)
		if (enabledInputs.keyboard)
			initKeyboard();
		#end
		
		#if (mouse)
		if (enabledInputs.mouse)
			initMouse();
		#end
		
		#if (touch)
		if (enabledInputs.touch)
			initTouch();
		#end
		
		#if (joystick)
		if (enabledInputs.joystick)
			initJoystick();
		#end
		
	}
	
	/**
	 * Determine the default Inputs from the compiler conditionals
	 * You must make sure mobile conditional is set in nmml file with 
	 * <set name="mobile" if="android" /> and so on...
	 */
	private static function getDefaultInputs( ):FlxInputList
	{
		var defaults = new FlxInputList();

		#if (keyboard)
		defaults.keyboard = true;
		#end
		
		#if (joystick)
		defaults.joystick = true;
		#end
		
		#if (mouse)
		defaults.mouse = true;
		#end

		#if touch
		defaults.touch = true;
		#end
		
		return defaults;
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
			var input = cast( inputs[i++], IFlxInput);
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
			var input = cast( inputs[i++], IFlxInput);
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
			var input = cast( inputs[i++], IFlxInput);
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
			var input = cast( inputs[i++], IFlxInput);
			input.reset();
		}
	}
	
	#if (joystick)
	static public function initJoystick():Void
	{
		var joy = new FlxJoystickManager();
		FlxG.joystickManager = joy;
		inputs.push(joy);
	}
	#end
	
	#if (keyboard)
	static public function initKeyboard():Void
	{
		var key = new FlxKeyboard();
		FlxG.keys = key;
		inputs.push(key);
	}
	#end

	#if (mouse)
	static public function initMouse():Void
	{
		var mouse = new FlxMouse(FlxG._game._inputContainer);
		FlxG.mouse = mouse;
		inputs.push(mouse);
	}
	#end

	#if (touch)
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
			var input = cast( inputs[i++], IFlxInput);
			input.destroy();
			input = null;
		}
	}

}

/**
 * Basic class for a definition of inputs to enable
 */
class FlxInputList {
	public function new (){}
    public var mouse : Bool;
	public var keyboard : Bool;
	public var touch : Bool;
	public var joystick: Bool;
}
