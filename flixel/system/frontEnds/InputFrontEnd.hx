package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.interfaces.IFlxInput;
import flixel.util.FlxStringUtil;

@:allow(flixel.FlxGame)
@:allow(flixel.FlxG)
@:allow(flixel.system.replay.FlxReplay)
@:allow(flixel.system.frontEnds.VCRFrontEnd)
class InputFrontEnd
{
	/**
	 * A read-only list of all inputs.
	 */
	public var list(default, null):Array<IFlxInput>;
	
	/**
	 * Add an input to the system
	 * 
	 * @param	Input 	The input to add
	 * @return	The input
	 */
	@:generic public function add<T:IFlxInput>(Input:T):T
	{
		// Don't add repeats
		for (input in list)
		{
			if (FlxStringUtil.sameClassName(Input, input))
			{
				return Input;
			}
		}
		
		list.push(Input);
		return Input;
	}
	
	private function new()
	{
		list = new Array<IFlxInput>();
	}
	
	/**
	 * Resets the inputs.
	 */
	@:allow(flixel.FlxState.resetSubState)
	inline private function reset():Void
	{
		for (input in list)
		{
			input.reset();
		}
	}
	
	/**
	 * Updates the inputs
	 */
	inline private function update():Void
	{
		for (input in list)
		{
			input.update();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame Focus
	 */
	inline private function onFocus():Void 
	{
		for (input in list)
		{
			input.onFocus();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame FocusLost
	 */	
	inline private function onFocusLost():Void
	{
		for (input in list)
		{
			input.onFocusLost();
		}
	}
	
	/**
	 * Clean up memory.
	 */
	inline private function destroy():Void
	{
		for (input in list)
		{
			input.destroy();
			input = null;
		}
	}
}