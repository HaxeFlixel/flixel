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

		if (enabledInputs.keyboard)
			initKeyboard();
		
		if (enabledInputs.mouse)
			initMouse();
		
		if (enabledInputs.touch)
			initTouch();
		
		#if (desktop)
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
		
		#if (desktop || neko || flash)
		defaults.keyboard = true;
		defaults.mouse = true;
		#end

		#if mobile
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
	
	#if (desktop)
	static public function initJoystick():Void
	{
		var joy = new FlxJoystickManager();
		FlxG.joystickManager = joy;
		inputs.push(joy);
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
		var touch =  new FlxTouchManager();
		FlxG.touchManager = touch;
		inputs.push(touch);
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
