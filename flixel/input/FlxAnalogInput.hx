package flixel.input;

import flixel.input.FlxInput;

class FlxAnalogInput<K> extends FlxTypedInput<K, Float, FlxAnalogState>
{
	public var justStopped(get, never):Bool;
	public var stopped(get, never):Bool;
	public var moved(get, never):Bool;
	public var justMoved(get, never):Bool;
	public var delta(get, never):Float;
	
	/**
	 * Example: Mouse inputs stop at any value, however thumbsticks stop at 0
	 */
	var stopsAtZero = false;
	
	public function new(id:K, stopsAtZero:Bool)
	{
		super(id);
		this.stopsAtZero = stopsAtZero;
	}
	
	override function change(newValue:Float)
	{
		last = current;
		if (stopsAtZero)
		{
			if (newValue == 0)
				current = lastValue == 0 ? STOPPED : JUST_STOPPED;
			else
				current = lastValue != 0 ? MOVED : JUST_MOVED;
		}
		else
		{
			if (newValue == currentValue)
				current = currentValue == lastValue ? STOPPED : JUST_STOPPED;
			else
				current = currentValue != lastValue ? MOVED : JUST_MOVED;
		}
		return super.change(newValue);
	}
	
	override function reset()
	{
		currentValue = 0;
		lastValue = 0;
		current = STOPPED;
		last = STOPPED;
	}
	
	override function hasState(state:FlxAnalogState)
	{
		return switch (state)
		{
			case JUST_STOPPED: justStopped;
			case STOPPED: stopped;
			case MOVED: moved;
			case JUST_MOVED: justMoved;
		}
	}
	
	inline function get_justStopped():Bool
	{
		return current == JUST_STOPPED;
	}
	
	inline function get_stopped():Bool
	{
		return current == STOPPED || justStopped;
	}
	
	inline function get_moved():Bool
	{
		return current == MOVED || justMoved;
	}
	
	inline function get_justMoved():Bool
	{
		return current == JUST_MOVED;
	}
	
	inline function get_delta():Float
	{
		return cast lastValue - currentValue;
	}
}

// TODO: improve doc
@:enum
abstract FlxAnalogState(Int) from Int
{
	/** Became 0 on this frame */
	var JUST_STOPPED = cast FlxInputState.JUST_RELEASED;
	
	/** Is 0 */
	var STOPPED = cast FlxInputState.RELEASED;
	
	/** Is not 0 */
	var MOVED = cast FlxInputState.PRESSED;
	
	/** Was 0, became non-zero on this frame */
	var JUST_MOVED = cast FlxInputState.JUST_PRESSED;
}