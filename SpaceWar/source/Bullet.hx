package;
import org.flixel.FlxSprite;

class Bullet extends FlxSprite 
{
	public function new(x:Float, y:Float):Void 
	{
		super(x, y);
		makeGraphic(16, 4, 0xFFFFFFFF);
		velocity.x = 1000;
	}
}