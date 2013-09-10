package flixel.animation;

/**
 * ...
 * @author Zaphod
 */
class FlxBaseAnimation
{
	/**
	 * Internal, keeps track of the current index into the tile sheet based on animation or rotation.
	 */
	private var _curIndex:Int = 0;
	
	public function new()
	{
		
	}
	
	public function destroy():Void
	{
		
	}
	
	public function update():Bool
	{
		return false;
	}
	
	public var curIndex(get_curIndex, null):Int;
	
	function get_curIndex():Int 
	{
		return _curIndex;
	}
	
	public function clone():FlxBaseAnimation
	{
		return null;
	}
	
}