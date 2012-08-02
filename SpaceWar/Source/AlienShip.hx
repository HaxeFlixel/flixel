package;
import org.flixel.FlxG;
import org.flixel.FlxSprite;

class AlienShip extends FlxSprite 
{
	private var shotClock:Float;
	
	public function new(x:Float, y:Float) 
	{
		super(x, y);
		loadGraphic("assets/png/alienship.png", true, false, 32, 40);
		velocity.x = -200;
		resetShotClock();
		addAnimation("alienship_fly", [0, 1], 2);
	}
	
	override public function update():Void 
	{
		play("alienship_fly");	
		shotClock -= FlxG.elapsed;
		
		if (shotClock <= 0) 
		{	
			resetShotClock();
			var bullet:FlxSprite = cast(cast(FlxG.state, PlayState).alienBullets.recycle(), FlxSprite);
			bullet.reset(x + width/2 - bullet.width/2, y + 20);
			bullet.velocity.x = -500;
		}
		
		super.update();
	}
	
	private function resetShotClock():Void 
	{	
		shotClock = 1;
	}
}