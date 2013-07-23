package;

import org.flixel.FlxG;
import org.flixel.util.FlxColor;

class Colors
{		
	public static function random():Int
	{
		var flipped:Bool = FlxG.random() < 0.5;
		return FlxColor.makeFromRGBA(genPair(flipped), genPair(flipped), genPair(flipped));
	}
	
	public static function genPair(Flipped:Bool):Int
	{
		if (FlxG.random() < 0.5)
		{
			if (Flipped)
			{
				return 0;
			}
			else
			{
				return 0;
			}
		}
		else
		{
			if (Flipped)
			{
				return 0xff;
			}
			else
			{
				return 0xbb;
			}
		}
		return 0;
		
		switch (Std.int(FlxG.random()*4))
		{
			case 0:
				return 0;
			case 1:
				return 0xff;
			case 2:
				return 0xff;//0x55;
			case 3:
				return 0;//0xAA;
		}
		return 0;
	}
}