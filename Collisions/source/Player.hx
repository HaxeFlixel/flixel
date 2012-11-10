package;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;


class Player extends FlxSprite
{
	
	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		loadGraphic("assets/player.png", true);
		maxVelocity.x = 100;			//walking speed
		acceleration.y = 400;			//gravity
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = 8;
		height = 10;
		offset.x = 3;
		offset.y = 3;
		
		addAnimation("idle",[0],0,false);
		addAnimation("walk",[1,2,3,0],10,true);
		addAnimation("walk_back",[3,2,1,0],10,true);
		addAnimation("flail",[1,2,3,0],18,true);
		addAnimation("jump",[4],0,false);
	}
	
	override public function update():Void
	{
		//Smooth slidey walking controls
		acceleration.x = 0;
		if(FlxG.keys.LEFT)
			acceleration.x -= drag.x;
		if(FlxG.keys.RIGHT)
			acceleration.x += drag.x;
		
		if(isTouching(FlxObject.FLOOR))
		{
			//Jump controls
			if(FlxG.keys.justPressed("SPACE"))
			{
				velocity.y = -acceleration.y*0.51;
				play("jump");
			}//Animations
			else if(velocity.x > 0)
				play("walk");
			else if(velocity.x < 0)
				play("walk_back");
			else
				play("idle");
		}
		else if(velocity.y < 0)
			play("jump");
		else
			play("flail");
	}
}