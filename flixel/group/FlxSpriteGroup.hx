package flixel.group; 

import flixel.FlxSprite;

/**
 * FlxSpriteGroup is a special FlxSprite that can be treated like 
 * a single sprite even if it's made up of several member sprites.
 * It shares the FlxTypedGroup API, but it doesn't inherit from it.
 */
class FlxSpriteGroup extends FlxTypedSpriteGroup<FlxSprite>
{
	/**
	 * @param	X			The initial X position of the group
	 * @param	Y			The initial Y position of the group
	 * @param	MaxSize		Maximum amount of members allowed
	 */
	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0)
	{
		super(X, Y);
		maxSize = MaxSize;
	}
}