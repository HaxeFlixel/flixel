package flixel.input.gamepad;

class FlxGamepadButton
{
	public var id:Int;
	public var current:Int;
	public var last:Int;
	
	#if flash
	private var _pressed:Bool = false;
	#end
	
	public function new(ID:Int, Current:Int = 0, Last:Int = 0)
	{
		id = ID;
		current = Current;
		last = Last;
	}
	
	public function reset():Void
	{
		current = 0;
		last = 0;
	}
	
	public function release():Void
	{
		// simulate button onUp event which does not exist on flash
		#if flash
		if (!_pressed)
		{
			return;
		}
		_pressed = false;
		#end
		
		last = current;
		if (current > 0) 
		{
			current = -1;
		}
		else 
		{
			current = 0;
		}
	}
	
	public function press():Void
	{
		// simulate button onDown event which does not exist on flash
		#if flash
		if (_pressed)
		{
			return;
		}
		_pressed = true;
		#end
		
		last = current;
		if (current > 0)
		{
			current = 1;
		}
		else 
		{
			current = 2;
		}
	}
}