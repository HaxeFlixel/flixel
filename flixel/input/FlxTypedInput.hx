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

	public function new(id:TKey)
	{
		this.ID = id;
		reset();
	}

	public function change(newValue:TValue)
	{
		lastValue = currentValue;
		currentValue = newValue;
		dirty = true;
		return newValue;
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