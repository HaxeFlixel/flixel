package;
import org.flixel.FlxSprite;

class AlienBullet extends FlxSprite 
{
	public function new(x:Float, y:Float) 
	{
		super(x, y);
		#if !neko
		makeGraphic(16, 4, 0xFFFFFFFF);
		#else
		makeGraphic(16, 4, {rgb: 0xFFFFFF, a: 0xFF});
		#end
		velocity.x = -1000;
	}
}