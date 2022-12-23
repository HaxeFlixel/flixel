package flixel.input;

class FlxInput<T> extends FlxTypedInput<T, Bool, FlxInputState> implements IFlxInput
{
	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;

	public function new(id:T)
	{
		super(id);
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
		
		return super.change(newValue);
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
		return !currentValue;
	}

	inline function get_pressed():Bool
	{
		return currentValue;
	}

	inline function get_justPressed():Bool
	{
		return lastValue == false && currentValue == true;
	}
}

@:enum
abstract FlxInputState(Int) from Int
{
	var JUST_RELEASED = -1;
	var RELEASED = 0;
	var PRESSED = 1;
	var JUST_PRESSED = 2;
	
	public var pressed(get, never):Bool;
	function get_pressed() return this > 0;
	
	public var released(get, never):Bool;
	function get_released() return !pressed;
}

typedef FlxDigitalState = FlxInputState;