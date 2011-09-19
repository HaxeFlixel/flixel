package org.flixel.plugin.photonstorm;

import org.flixel.FlxGroup;
import org.flixel.FlxSprite;

class FlxLinkedGroup extends FlxGroup
{
	
	#if flash
	public function new(MaxSize:UInt = 0)
	#else
	public function new(MaxSize:Int = 0)
	#end
	{
		super(MaxSize);
	}
	
	public function addX(newX:Int):Void
	{
		for (s in members)
		{
			if (s != null && Std.is(s, FlxSprite))
			{
				cast(s, FlxSprite).x += newX;
			}
		}
	}
	
	public function angle(newX:Int):Void
	{
		for (s in members)
		{
			if (s != null && Std.is(s, FlxSprite))
			{
				cast(s, FlxSprite).angle += newX;
			}
		}
	}
	
}