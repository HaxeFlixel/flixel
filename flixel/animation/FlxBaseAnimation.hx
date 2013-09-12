package flixel.animation;

import flixel.FlxSprite;

/**
 * ...
 * @author Zaphod
 */
class FlxBaseAnimation
{
	public var sprite:FlxSprite;
	
	/**
	 * Keeps track of the current index into the tile sheet based on animation or rotation.
	 * Allow access to private var from FlxAnimationController.
	 */
	public var curIndex:Int = 0;
	
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
	
	public function clone(Sprite:FlxSprite):FlxBaseAnimation
	{
		return null;
	}
	
}