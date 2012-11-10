package;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

class Ship extends FlxSprite 
{
	public function new() 
	{
		super();
	}

	override public function update():Void 
	{
		var shield:Bool = PlayState.shield;
		var control:String = ControlsSelect.control;
		
		if (control == "mouse") 
		{	
			x = FlxG.mouse.x;
			y = FlxG.mouse.y;	
		}
		
		if (shield == true) 
		{
			loadGraphic("assets/png/shipShield.png");
		}
		else 
		{
			loadGraphic("assets/png/ship.png");
		}
		
		velocity.x = 0;
		velocity.y = 0;
		
		if (FlxG.keys.LEFT && control == "keyboard") 
		{
			velocity.x = -270;
		}
		else if (FlxG.keys.RIGHT && control == "keyboard") 
		{
			velocity.x = 270;
		}
		if (FlxG.keys.UP && control == "keyboard") 
		{
			velocity.y = -270;
		}
		else if (FlxG.keys.DOWN && control == "keyboard") 
		{
			velocity.y = 270;
		}
		
		super.update();
		
		if (x > FlxG.width - width - 10) 
		{
			x = FlxG.width - width - 10;
		}
		else if (x < 10) 
		{
			x = 10;
		}
		if (y > FlxG.height - height - 10) 
		{
			y = FlxG.height - height - 10;
		}
		else if (y < 10) 
		{
			y = 10;
		}
	}
	
	public function getBulletSpawnPosition():FlxPoint 
	{
		var p:FlxPoint = new FlxPoint(x + 12, y + 12);
		return p;
	}
}