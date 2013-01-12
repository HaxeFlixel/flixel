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
	public static  var inputs:Array<IInput>;
	
    public function new() {}
	
	#if (cpp || neko)
	public static  var joystickManager:FlxJoystickManager;
	#end
	
	/**
	 * Initiate the default Inputs
	 */
	static public function init(enabledInputs:Inputs = null):Void
	{
		inputs = null;
		inputs = new Array<IInput>();
		
		if ( enabledInputs == null)
			enabledInputs = getDefaultInputs();

		if (enabledInputs.keyboard)
			initKeyboard();
		
		if (enabledInputs.mouse)
			initMouse();
		
		if (enabledInputs.touch)
			initTouch();
		
		#if (cpp || neko)
		if (enabledInputs.joystick)
			initJoystick();
		#end
		
	}
	
	/**
	 * Determine the default Inputs from the compiler conditionals
	 */
	private static function getDefaultInputs( ):Inputs
	{
		var defaults = new Inputs();
		
		#if ( flash || cpp || windows || linux || mac || neko)
		defaults.keyboard = true;
		defaults.mouse = true;
		#end
		
		#if (mobile)
		defaults.touch = true;
		#end
		
		return defaults;
	}
	
	/**
	 * Add an input to the system
	 */
	
	static public function addInput(input:IInput):IInput
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
			var input = cast( inputs[i++], IInput);
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
			var input = cast( inputs[i++], IInput);
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
			var input = cast( inputs[i++], IInput);
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
			var input = cast( inputs[i++], IInput);
			input.reset();
		}
	}
	
	#if (cpp || neko)
	static public function initJoystick():Void
	{
		joystickManager = new FlxJoystickManager();
	}
	#end
	
	static public function initKeyboard():Void
	{
		var key = new FlxKeyboard();
		FlxG.keys = key;
		inputs.push(key);
	}
	
	static public function initMouse():Void
	{
		var mouse = new FlxMouse(FlxG._game._inputContainer);
		FlxG.mouse = mouse;
		inputs.push(mouse);
	}
	
	static public function initTouch():Void
	{
		FlxG.touchManager = new FlxTouchManager();
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		var i:Int = 0;
		var l:Int = inputs.length;
		while(i < l)
		{
			var input = cast( inputs[i++], IInput);
			input.destroy();
		}
	}

}

/**
 * Basic class for a definition of inputs to enable
 */
class Inputs {
	public function new (){}
    public var mouse : Bool;
	public var keyboard : Bool;
	public var touch : Bool;
	public var joystick: Bool;
}
