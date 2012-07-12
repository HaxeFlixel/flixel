package;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSound;
import org.flixel.FlxSprite;

class Paddle extends FlxSprite
{
	public var gameInitiated:Bool;
	public var ballMC:Ball;
	public var oldSpeedX:Float;
	public var oldSpeedY:Float;
	
	public function new(paddleX:Int, paddleY:Int, imgString:String, gameIniState:Bool, ballClass:Ball) 
	{
		super(paddleX, paddleY, imgString);
		gameInitiated = gameIniState;
		ballMC = ballClass;
		this.immovable = true;
	}
	override public function update():Void 
	{	
		oldSpeedX = ballMC.velocity.x;
		oldSpeedY = ballMC.velocity.y;
		if (FlxG.collide(this, ballMC))
		{
			FlxG.play("BeepSound");
			
			var verticalContact:Bool = (this.justTouched(FlxObject.DOWN) || this.justTouched(FlxObject.UP));
			var horizontalContact:Bool = (this.justTouched(FlxObject.LEFT) || this.justTouched(FlxObject.RIGHT));
			
			if (horizontalContact)
			{
				ballMC.velocity.x = -oldSpeedX;
			}
			else
			{
				ballMC.velocity.x = oldSpeedX;
			}
			
			if (verticalContact)
			{
				ballMC.velocity.y = -oldSpeedY;
			}
			else
			{
				ballMC.velocity.y = oldSpeedY;
			}
		}
		
		if (gameInitiated)
		{
			this.x = FlxG.mouse.x;
			if (this.x > FlxG.width - (this.width)) 
			{
				this.x = FlxG.width - (this.width);
			}
		}
		super.update();
	}
}