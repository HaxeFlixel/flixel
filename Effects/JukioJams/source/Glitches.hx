package;

import flixel.group.FlxTypedGroup;
import flixel.util.FlxRandom;

class Glitches extends FlxTypedGroup<Glitch>
{
	public function new()
	{
		super();
		
		for (i in 0...16)
		{
			add(new Glitch());
		}
	}
	
	public function onBeat():Void
	{
		var sprite:Glitch;
		
		for (i in 0...length)
		{
			members[i].reset(Std.int(FlxRandom.float() * 16) * 16, Std.int(FlxRandom.float() * 12) * 16);
		}
	}
}