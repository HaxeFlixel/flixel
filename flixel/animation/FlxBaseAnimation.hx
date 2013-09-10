package flixel.animation;
import flixel.FlxSprite;

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
	
	public var sprite:FlxSprite;
	
	public function new(Sprite:FlxSprite)
	{
		sprite = Sprite;
	}
	
	public function destroy():Void
	{
		sprite = null;
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
	
	public function clone(Sprite:FlxSprite):FlxBaseAnimation
	{
		return null;
	}
	
}