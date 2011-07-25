package;

import flash.media.Sound;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxBasic;

/**
 * ...
 * @author Zaphod
 */
class Hero extends FlxSprite
{
	
	public var bullets:Array<FlxBasic>;
	private var bulletIndex:Int;
	
	public function new() 
	{
		super(FlxG.width * 0.5, FlxG.height - 100);
		makeGraphic(50, 50, 0xffff0000);
		bulletIndex = 0;
	}
	
	override public function update():Void 
	{
		velocity.x = 0;
		if (FlxG.keys.LEFT)
		{
			velocity.x -= 250;
		}
		if (FlxG.keys.RIGHT)
		{
			velocity.x += 250;
		}
		if (FlxG.keys.justPressed("SPACE"))
		{
			//FlxG.play(Shoot);
			
			bulletIndex++;
			if (bulletIndex >= bullets.length - 1)
			{
				bulletIndex = 0;
			}
			trace(bulletIndex);
			var bullet:FlxSprite = cast(bullets[bulletIndex], FlxSprite);
			bullet.reset(x + width * 0.5 - bullet.width, y);
			bullet.velocity.y = -400;
		}
		
		super.update();
	}
	
}