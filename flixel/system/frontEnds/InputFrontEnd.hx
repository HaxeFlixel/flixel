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
	 */
	@:generic
	@:deprecated("add is deprecated, use addUniqueType")
	public inline function add<T:IFlxInputManager>(input:T):T
	{
		return addUniqueType(input);
	}
	
	/**
	 * Add an input to the system, unless the same instance was already added
	 */
	@:generic
	public function addInput<T:IFlxInputManager>(input:T):T
	{
		if (!list.contains(input))
			list.push(input);
		
		return input;
	}

	/**
	 * Add an input to the system, unless the same type was already added
	 */
	@:generic
	public function addUniqueType<T:IFlxInputManager>(input:T):T
	{
		// Don't add repeat types
		for (i in list)
		{
			if (FlxStringUtil.sameClassName(input, i, false))
			{
				return input;
			}
		}
		
		list.push(input);
		return input;
	}

	/**
	 * Removes an input from the system
	 *
	 * @param   Input  The input to remove
	 * @return  Bool indicating whether it was removed or not
	 */
	@:generic
	public inline function remove<T:IFlxInputManager>(input:T):Bool
	{
		return list.remove(input);
	}

	/**
	 * Replace an existing input in the system with a new one
	 *
	 * @param   oldInput    The old input to replace
	 * @param   newInput    The new input to put in its place
	 * @param   destroyOld  Whether to destroy the old input
	 * @return  If successful returns `newInput`. Otherwise returns `null`.
	 */
	@:generic
	public function replace<T:IFlxInputManager>(oldInput:T, newInput:T, destroyOld = false):Null<T>
	{
		final index = list.indexOf(oldInput);
		if (index == -1)
			return null;
		
		if (destroyOld)
			oldInput.destroy();
		
		list[index] = newInput;
		return newInput;
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
