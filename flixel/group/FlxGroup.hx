package flixel.group;

import flixel.FlxBasic;

/**
 * This is an organizational class that can update and render a bunch of <code>FlxBasic</code>s.
 * NOTE: Although <code>FlxGroup</code> extends <code>FlxBasic</code>, it will not automatically
 * add itself to the global collisions quad tree, it will only add its members.
 */
class FlxGroup extends FlxTypedGroup<FlxBasic>
{
	/**
	 * @param	MaxSize		Maximum amount of allowed members
	 */
	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
	}
}