package flixel.group; 

import flixel.FlxSprite;

/**
 * FlxSpriteGroup is a special FlxGroup that can be treated like 
 * a single sprite even if it's made up of several member sprites.
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