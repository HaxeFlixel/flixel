package flixel.system.input;

class FlxJoyButton
{
	public var id:Int;
	public var current:Int;
	public var last:Int;
	
	public function new(id:Int, current:Int = 0, last:Int = 0)
	{
		this.id = id;
		this.current = current;
		this.last = last;
	}
	
	public function reset():Void
	{
		this.current = 0;
		this.last = 0;
	}
}