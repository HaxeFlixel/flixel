package;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;

class Triangles extends FlxGroup
{
	public function new()
	{
		super();
		
		var w:Int = Math.ceil((FlxG.width * 0.5) / 8);
		var h:Int = Math.ceil((FlxG.height * 0.5) / 8);
		
		var sprite:FlxSprite;
		for (r in 0...h)
		{
			for (c in 0...w)
			{
				add(new FlxSprite(c * 8, r * 8).loadGraphic("assets/triangles.png", true));
			}
		}
	}
	
	public function onBeat():Void
	{
		var sprite:FlxSprite;
		for (i in 0...length)
		{
			sprite = cast(members[i], FlxSprite);
			sprite.randomFrame();
			sprite.color = Colors.random();
		}
	}
}