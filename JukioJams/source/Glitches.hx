package;
import org.flixel.FlxG;
import org.flixel.FlxGroup;

class Glitches extends FlxGroup
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
			sprite = cast(members[i], Glitch);
			sprite.reset(Std.int(FlxG.random() * 16) * 16, Std.int(FlxG.random() * 12) * 16);
		}
	}
}