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
	@:generic
	public function add<T:IFlxInput>(Input:T):T
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
	
	/**
	 * Removes an input from the system
	 * 
	 * @param	Input	The input to remove
	 * @return	Bool indicating whether it was removed or not
	 */
	
	@:generic
	public function remove<T:IFlxInput>(Input:T):Bool
	{
		var i:Int = 0;
		for (input in list)
		{
			if (input == Input)
			{
				list.splice(i, 1);
				return true;
			}
			i++;
		}
		return false;
	}
	
	/**
	 * Replace an existing input in the system with a new one
	 * 
	 * @param	Old 	The old input to replace
	 * @param	New 	The new input to put in its place
	 * @return	If successful returns New. Otherwise returns null.
	 */
	
	@:generic
	public function replace<T:IFlxInput>(Old:T,New:T):T
	{
		var i:Int = 0;
		var success:Bool = false;
		for (input in list)
		{
			if (input == Old) {
				list[i] = New;			//Replace Old with New
				success = true;
				break;
			}
			i++;
		}
		
		if (success) {
			return New;
		}
		return null;
	}
	
	/**
	 * Resets the inputs.
	 */
	public function reset():Void
	{
		for (input in list)
		{
			input.reset();
		}
	}
	
	private function new()
	{
		list = new Array<IFlxInput>();
	}
	
	/**
	 * Updates the inputs
	 */
	private inline function update():Void
	{
		for (input in list)
		{
			input.update();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame Focus
	 */
	private inline function onFocus():Void
	{
		for (input in list)
		{
			input.onFocus();
		}
	}
	
	/**
	 * Updates the inputs from FlxGame FocusLost
	 */	
	private inline function onFocusLost():Void
	{
		for (input in list)
		{
			input.onFocusLost();
		}
	}
	
	/**
	 * Clean up memory.
	 */
	private inline function destroy():Void
	{
		for (input in list)
		{
			input.destroy();
			input = null;
		}
	}
}