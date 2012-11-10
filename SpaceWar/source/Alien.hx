package;
import org.flixel.FlxSprite;

class Alien extends FlxSprite 
{
	public function new(x:Float, y:Float) 
	{
		super(x, y);
		loadGraphic("assets/png/alien.png", true, false, 36, 32);
		velocity.x = -200;
		addAnimation("alien_fly", [0, 1], 2);
	}
	
	override public function update():Void 
	{
		velocity.y = Math.cos(x / 50) * 50;
		play("alien_fly");
		super.update();
	}
}