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
	                                        Group:FlxTypedGroup<FlxBasic>, X:Float, Y:Float, InScreenSpace:Bool, Camera:FlxCamera):Bool
	{
		var result:Bool = false;
		if (Group != null)
		{
			var i = 0;
			var l = Group.length;
			var basic:FlxBasic;
			
			while (i < l)
			{
				basic = cast Group.members[i++];
				
				if (basic != null && Callback(basic, X, Y, InScreenSpace, Camera))
				{
					result = true;
					break;
				}
			}
		}
		return result;
	}
	
	@:allow(flixel.FlxObject)
	@:allow(flixel.tile.FlxTilemap)
	@:allow(flixel.system.FlxQuadTree)
	private static inline function resolveGroup(ObjectOrGroup:FlxBasic):FlxTypedGroup<FlxBasic>
	{
		var group:FlxTypedGroup<FlxBasic> = null;
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