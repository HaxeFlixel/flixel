package;
import org.flixel.FlxG;
import org.flixel.util.FlxPoint;
import org.flixel.FlxSprite;

class Paddle extends FlxSprite 
{
	private var deadYet:Bool = false;
	
	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		loadGraphic("assets/paddle.png", false, false, 16, 64, false);
		this.immovable = true;
	}
	
	override public function update():Void 
	{
		super.update();
		this.checkInput();
		
		if (this.overlaps(PlayState.ball)) 
		{
			//PlayState.ball.changeDirection("right");
			PlayState.ball.hitCount++;
			PlayState.ball.firstCollision = true;
			PlayState.ball.lastPaddleCollidedWith = "leftPaddle";
			PlayState.ball.increaseTheNeedForSpeed();
		}
		
		if (PlayState.ball.overlapsPoint(new FlxPoint(this.x + 16, this.y + 0)) || PlayState.ball.overlapsPoint(new FlxPoint(this.x + 16, this.y + 16))) 
		{
			//trace("Upper Hit!");
			PlayState.ball.changeDirection("northEast");
		}
		
		if (PlayState.ball.overlapsPoint(new FlxPoint(this.x + 16, this.y + 32))) 
		{
			//trace("Center Hit!");
			PlayState.ball.changeDirection("right");
		}
		if (PlayState.ball.overlapsPoint(new FlxPoint(this.x + 16, this.y + 58)) || PlayState.ball.overlapsPoint(new FlxPoint(this.x + 16, this.y + 64))) {
			//trace("Lower Hit!");
			PlayState.ball.changeDirection("southEast");
		}
	}
	
	private function checkInput():Void 
	{
		if (FlxG.keys.W)
			this.y -= 2;
		if (FlxG.keys.S)
			this.y += 2;
	}
}