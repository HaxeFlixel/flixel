package flixel.input;

class FlxTypedInput<TKey, TValue, TState>
{
	public var ID:TKey;
	
	public var currentValue:TValue;
	public var lastValue:TValue;
	
	public var current:TState;
	public var last:TState;
	
	public var changed(get, never):Bool;
	
	var dirty = false;
	
	public function new(ID:TKey)
	{
		this.ID = ID;
		reset();
	}
	
	public function change(newValue:TValue):Void
	{
		lastValue = currentValue;
		currentValue = newValue;
		dirty = true;
	}
	
	public function update():Void
	{
		if (!dirty)
		{
			change(currentValue);
		}
		dirty = false;
	}
	
	public function hasState(state:TState):Bool
	{
		throw "Do not directly instantiate Abstract class FlxTypedInput";
	}
	
	public function reset():Void
	{
		throw "Do not directly instantiate Abstract class FlxTypedInput";
	}
	
	inline function get_changed():Bool
	{
		return currentValue != lastValue;
	}
}

class FlxInput<T> extends FlxTypedInput<T, Bool, FlxInputState> implements IFlxInput
{
	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	
	public function new(ID:T)
	{
		super(ID);
	}
	
	public function press():Void
	{
		change(true);
	}
	
	public function release():Void
	{
		change(false);
	}
	
	override function change(newValue:Bool)
	{
		last = current;
		if (newValue)
			current = currentValue ? PRESSED : JUST_PRESSED;
		else
			current = !currentValue ? RELEASED : JUST_RELEASED;
		super.change(newValue);
	}
	
	override function reset()
	{
		currentValue = false;
		lastValue = false;
		current = RELEASED;
		last = RELEASED;
	}
	
	override function hasState(state:FlxInputState)
	{
		return switch (state)
		{
			case JUST_RELEASED: justReleased;
			case RELEASED: released;
			case PRESSED: pressed;
			case JUST_PRESSED: justPressed;
		}
	}
	
	inline function get_justReleased():Bool
	{
		return lastValue == true && currentValue == false;
	}
	
	inline function get_released():Bool
	{
		return currentValue == false;
	}
	
	inline function get_pressed():Bool
	{
		return currentValue == true;
	}
	
	inline function get_justPressed():Bool
	{
		return lastValue == false && currentValue == true;
	}
}

class FlxAnalogInput<K, V:Float> extends FlxTypedInput<K, V, FlxAnalogState>
{
	public var justStopped(get, never):Bool;
	public var stopped(get, never):Bool;
	public var moved(get, never):Bool;
	public var justMoved(get, never):Bool;
	public var delta(get, never):V;
	
	/**
	 * Example: Mouse inputs stop at any value, however thumbsticks stop at 
	 */
	var stopsAtZero = false;
	var resetValue(get, never):V;
	
	public function new(id:K, stopsAtZero:Bool)
	{
		super(id);
		this.stopsAtZero = stopsAtZero;
	}
	
	override function change(newValue:V)
	{
		last = current;
		if (stopsAtZero)
		{
			if (newValue == resetValue)
				current = lastValue == resetValue ? STOPPED : JUST_STOPPED;
			else
				current = lastValue != resetValue ? MOVED : JUST_MOVED;
		}
		else
		{
			if (newValue == currentValue)
				current = currentValue == lastValue ? STOPPED : JUST_STOPPED;
			else
				current = currentValue != lastValue ? MOVED : JUST_MOVED;
		}
		super.change(newValue);
	}
	
	override function reset()
	{
		currentValue = resetValue;
		lastValue = resetValue;
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
	
	inline function get_resetValue():V
	{
		return cast 0;
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
	
	inline function get_delta():V
	{
		return cast lastValue - currentValue;
	}
}

@:enum
abstract FlxInputState(Int) from Int
{
	var JUST_RELEASED = -1;
	var RELEASED = 0;
	var PRESSED = 1;
	var JUST_PRESSED = 2;
}

typedef FlxDigitalState = FlxInputState;
typedef FlxDigitalInput<T> = FlxInput<T>;

@:enum
abstract FlxAnalogState(Int) from Int
{
	var JUST_STOPPED = cast FlxInputState.JUST_RELEASED; // became 0 on this frame
	var STOPPED = cast FlxInputState.RELEASED; // is 0
	var MOVED = cast FlxInputState.PRESSED; // is !0
	var JUST_MOVED = cast FlxInputState.JUST_PRESSED; // became !0 on this frame
}
