package flixel.group;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.system.FlxCollisionType;
import flixel.tile.FlxTilemap;

/**
 * This is an organizational class that can update and render a bunch of FlxBasics.
 * NOTE: Although FlxGroup extends FlxBasic, it will not automatically
 * add itself to the global collisions quad tree, it will only add its members.
 */
class FlxGroup extends FlxTypedGroup<FlxBasic>
{
	/**
	 * Helper function for overlap functions in FlxObject and FlxTilemap.
	 */
	@:allow(flixel.FlxObject)
	@:allow(flixel.tile.FlxTilemap)
	private static inline function overlaps(Callback:FlxBasic->Float->Float->Bool->FlxCamera->Bool, 
	                                       ObjectOrGroup:FlxBasic, X:Float, Y:Float, InScreenSpace:Bool, Camera:FlxCamera):Bool
	{
		var result:Bool = false;
		var group:FlxGroup = resolveGroup(ObjectOrGroup);
		if (group != null)
		{
			for (basic in group._basics)
			{
				if (Callback(basic, X, Y, InScreenSpace, Camera))
				{
					result = true;
					break;
				}
			}
		}
		return result;
	}
	
	private static inline function resolveGroup(ObjectOrGroup:FlxBasic):FlxGroup
	{
		var group:FlxGroup = null;
		if ((ObjectOrGroup.collisionType == FlxCollisionType.SPRITEGROUP) || 
		    (ObjectOrGroup.collisionType == FlxCollisionType.GROUP))
		{
			if (ObjectOrGroup.collisionType == FlxCollisionType.GROUP)
			{
				group = cast ObjectOrGroup;
			}
			else if (ObjectOrGroup.collisionType == FlxCollisionType.SPRITEGROUP)
			{
				group = cast cast(ObjectOrGroup, FlxSpriteGroup).group;
			}
		}
		return group;
	}
}