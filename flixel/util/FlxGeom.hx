package flixel.util;

import flixel.math.FlxRect;

/**
 * ...
 * @author Zaphod
 */
class FlxGeom
{
	public static inline function inflateBounds(bounds:FlxRect, x:Float, y:Float):FlxRect
	{
		if (x < bounds.x) 
		{
			bounds.width += bounds.x - x;
			bounds.x = x;
		}
		
		if (y < bounds.y) 
		{
			bounds.height += bounds.y - y;
			bounds.y = y;
		}
		
		if (x > bounds.x + bounds.width) 
		{
			bounds.width = x - bounds.x;
		}
		
		if (y > bounds.y + bounds.height) 
		{
			bounds.height = y - bounds.y;
		}
		
		return bounds;
	}
}