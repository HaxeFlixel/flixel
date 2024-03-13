package flixel.group;

import flixel.FlxBasic;
import flixel.group.FlxGroup;

/**
 * An alias for `FlxTypedContainer<FlxBasic>`, meaning any flixel object or basic can be added to a
 * `FlxContainer`, even another `FlxContainer`.
 * @since 5.7.0
 */
typedef FlxContainer = FlxTypedContainer<FlxBasic>;

/**
 * An exclusive `FlxGroup`, meaning that a `FlxBasic` can only be in ONE container at any given time.
 * Adding them to a second container will remove them from any previous container they were in.
 * You can determine which container a basic is in by using the basic's `container` field.
 *
 * ## When to use a group or container
 * `FlxGroups` are better for organising arbitrary groups for things like iterating or collision.
 * `FlxContainers` are recommended when you are adding them to the current `FlxState`, or a
 * child (or grandchild, and so on) of the state.
 * @since 5.7.0
 */
class FlxTypedContainer<T:FlxBasic> extends FlxTypedGroup<T>
{
	/**
	 * @param   maxSize  Maximum amount of members allowed.
	 */
	public function new(maxSize = 0)
	{
		super(maxSize);
	}
	
	override function onMemberAdd(member:T)
	{
		// remove from previous container
		if (member.container != null)
			member.container.remove(member);
		
		member.container = (cast this:FlxContainer);
		super.onMemberAdd(member);
	}
	
	override function onMemberRemove(member:T)
	{
		member.container = null;
		super.onMemberRemove(member);
	}
}
