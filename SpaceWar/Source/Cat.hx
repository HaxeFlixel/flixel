package;
import org.flixel.FlxSprite;

class Cat extends FlxSprite 
{	
	public function new(x:Float, y:Float) 
	{
		super(x, y);
		loadGraphic("assets/png/cat.png", true, true, 48, 29);
		velocity.x = -200;
		addAnimation("fly", [0, 1, 2, 3, 4, 5], 6);
	}
	
	override public function update():Void 
	{
		velocity.y = Math.cos(x / 50) * 50;
		play("fly");
		super.update();
	}
}