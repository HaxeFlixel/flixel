package flixel.input;

class FlxInput<T> implements IFlxInput
{
	public var ID:T;

	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;

	public var current:FlxInputState = RELEASED;
	public var last:FlxInputState = RELEASED;

	public function new(ID:T)
	{
		this.ID = ID;
	}

	public function press():Void
	{
		last = current;
		current = pressed ? PRESSED : JUST_PRESSED;
	}

	public function release():Void
	{
		last = current;
		current = pressed ? JUST_RELEASED : RELEASED;
	}

	public function update():Void
	{
		if (last == JUST_RELEASED && current == JUST_RELEASED)
		{
			current = RELEASED;
		}
		else if (last == JUST_PRESSED && current == JUST_PRESSED)
		{
			current = PRESSED;
		}

		last = current;
	}

	public function reset():Void
	{
		current = RELEASED;
		last = RELEASED;
	}

	public function hasState(state:FlxInputState):Bool
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
		return current == JUST_RELEASED;
	}

	inline function get_released():Bool
	{
		return current == RELEASED || justReleased;
	}

	inline function get_pressed():Bool
	{
		return current == PRESSED || justPressed;
	}

	inline function get_justPressed():Bool
	{
		return current == JUST_PRESSED;
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
