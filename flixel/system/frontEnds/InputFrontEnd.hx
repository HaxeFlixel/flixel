package flixel.system.frontEnds;

import flixel.input.IFlxInputManager;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

/**
 * Accessed via `FlxG.inputs`.
 */
class InputFrontEnd
{
	/**
	 * A read-only list of all inputs.
	 */
	public var list(default, null):Array<IFlxInputManager> = [];

	/**
	 * Whether inputs are reset on state switches.
	 * Disable if you need persistent input states across states.
	 */
	public var resetOnStateSwitch:Bool = true;

	/**
	 * Add an input to the system
	 *
	 * @param	Input 	The input to add
	 * @return	The input
	 */
	@:generic
	public function add<T:IFlxInputManager>(Input:T):T
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
	public function remove<T:IFlxInputManager>(Input:T):Bool
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
	public function replace<T:IFlxInputManager>(Old:T, New:T):T
	{
		var i:Int = 0;
		var success:Bool = false;
		for (input in list)
		{
			if (input == Old)
			{
				list[i] = New; // Replace Old with New
				success = true;
				break;
			}
			i++;
		}

		if (success)
		{
			return New;
		}
		return null;
	}

	public function reset():Void
	{
		for (input in list)
		{
			input.reset();
		}
	}

	@:allow(flixel.FlxG)
	function new() {}

	@:allow(flixel.FlxGame)
	inline function update():Void
	{
		for (input in list)
		{
			input.update();
		}
	}

	@:allow(flixel.FlxGame)
	inline function onFocus():Void
	{
		for (input in list)
		{
			input.onFocus();
		}
	}

	@:allow(flixel.FlxGame)
	inline function onFocusLost():Void
	{
		for (input in list)
		{
			input.onFocusLost();
		}
	}

	@:allow(flixel.FlxGame)
	@:allow(flixel.FlxState.resetSubState)
	function onStateSwitch():Void
	{
		if (resetOnStateSwitch)
		{
			reset();
		}
	}

	function destroy():Void
	{
		for (input in list)
		{
			input = FlxDestroyUtil.destroy(input);
		}
	}
}
