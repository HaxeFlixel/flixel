package flixel.system.frontEnds;

import flixel.system.input.IFlxInput;
import flixel.FlxG;

class InputFrontEnd
{
	/**
	 * An array container for plugins.
	 */
	public var list(default, null):Array<IFlxInput>;
	
	public function new()
	{
		list = new Array<IFlxInput>();
	}
	
	/**
	 * Add an input to the system
	 * 
	 * @param	Input 	The input to add
	 * @return	The input
	 */
	public function add(Input:IFlxInput):IFlxInput
	{
		// Don't add repeats
		for (input in list)
		{
			if (input.toString() == Input.toString())
			{
				return Input;
			}
		}
		
		list.push(Input);
		return Input;
	}
	
	/**
	 * Resets the inputs.
	 */
	inline public function reset():Void
	{
		for (input in list)
		{
			input.reset();
		}
	}
	
	/**
	 * Updates the inputs
	 */
	inline public function update():Void
	{
		for (input in list)
		{
			input.update();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame Focus
	 */
	inline public function onFocus():Void 
	{
		for (input in list)
		{
			input.onFocus();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame FocusLost
	 */	
	inline public function onFocusLost():Void
	{
		for (input in list)
		{
			input.onFocusLost();
		}
	}
	
	/**
	 * Clean up memory.
	 */
	inline public function destroy():Void
	{
		for (input in list)
		{
			input.destroy();
			input = null;
		}
	}
}