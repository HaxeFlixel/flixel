package;
import org.flixel.FlxG;
import org.flixel.util.FlxPoint;

class EnemyPaddle extends Paddle 
{
	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
	}
	
	override private function checkInput():Void 
	{
		if (FlxG.keys.UP)
			this.y -= 2;
		if (FlxG.keys.DOWN)
			this.y += 2;
	}
	
	override public function update():Void 
	{	
		this.checkInput();
		if (this.overlaps(PlayState.ball)) 
		{
			//PlayState.ball.changeDirection("left");
			PlayState.ball.hitCount++;
			PlayState.ball.firstCollision = true;
			PlayState.ball.lastPaddleCollidedWith = "rightPaddle";	
			PlayState.ball.increaseTheNeedForSpeed();
		}
		
		if (PlayState.ball.overlapsPoint(new FlxPoint(this.x, this.y + 0)) || PlayState.ball.overlapsPoint( new FlxPoint(this.x, this.y + 16))) 
		{
			//trace("Upper Hit!");
			PlayState.ball.changeDirection("northWest");
		}
		
		if (PlayState.ball.overlapsPoint( new FlxPoint(this.x, this.y + 32))) 
		{
			//trace("Center Hit!");
			PlayState.ball.changeDirection("left");
		}
		if (PlayState.ball.overlapsPoint( new FlxPoint(this.x, this.y + 58)) || PlayState.ball.overlapsPoint(new FlxPoint(this.x, this.y + 64))) 
		{
			//trace("Lower Hit!");
			PlayState.ball.changeDirection("southWest");
		}
	}
}