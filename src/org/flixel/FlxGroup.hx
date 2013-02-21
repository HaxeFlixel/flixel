package org.flixel;

import org.flixel.system.layer.Atlas;

/**
 * This is an organizational class that can update and render a bunch of <code>FlxBasic</code>s.
 * NOTE: Although <code>FlxGroup</code> extends <code>FlxBasic</code>, it will not automatically
 * add itself to the global collisions quad tree, it will only add its members.
 */
class FlxGroup extends FlxTypedGroup<FlxBasic>
{
	/**
	 * Constructor
	 */
	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
	}
}