package;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

class Ball extends FlxSprite 
{
	public var firstCollision:Bool = false;
	private var direction:String = " ";
	private var isPaused:Bool = false;
	private var c:Float = 0;
	public static inline var BOTTOM:Float = 160;
	public static inline var TOP:Float = 0;
	public var lastPaddleCollidedWith:String = null;
	public var lastWallCollidedWith:String = null;
	
	public var speedX:Float = 4;
	public var speedY:Float = 3;
	public var hitCount:Float = 0;
	
	private var deadYet:Bool = false;
	
	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
		loadGraphic("assets/sphere.png", false, false, 32, 32, false);
	}
	
	override public function update():Void 
	{
		if (!deadYet) 
		{
			super.update();
			if (isPaused) 
			{
				if (firstCollision == false)
				{
					this.x -= speedX;
				}
				
				if (lastPaddleCollidedWith != null && lastPaddleCollidedWith == "leftPaddle") 
				{
					
					if (direction == "right")
						this.x += speedX;
					if (direction == "left")
						this.x -= speedX;
						
					if (direction == "northEast") 
					{
						this.x += speedX;
						this.y -= speedY;
					}
					if (direction == "southEast") 
					{
						this.x += speedX;
						this.y += speedY;
					}
					
					if (direction == "northWest") 
					{
						this.x -= speedX;
						this.y -= speedY;
					}
					
					if (direction == "southWest") 
					{
						this.x += speedX;
						this.y -= speedY;
					}
				}
				
				if (lastPaddleCollidedWith != null && lastPaddleCollidedWith == "rightPaddle") 
				{	
					//if (firstCollision == false)
					//	this.x += speedX;
					if (direction == "right")
						this.x += speedX;
					if (direction == "left")
						this.x -= speedX;
						
					if (direction == "northEast") 
					{
						this.x += speedX;
						this.y -= speedY;
					}
					if (direction == "southEast") 
					{
						this.x += speedX;
						this.y += speedY;
					}
					
					if (direction == "northWest") 
					{
						this.x -= speedX;
						this.y -= speedY;
					}
					
					if (direction == "southWest") 
					{
						this.x -= speedX;
						this.y += speedY;
					}
				}
			}
			
			if (isPaused == false)
				c++;
			if (isPaused == true)
				c = 0;
				
			if (c == 60)
				isPaused = true;
			
			if (this.x >= FlxG.width + 32) 
			{
				PlayState.pScoreLiteral++;
				this.resetPosition();
			}
			if (this.x <= -64) 
			{
				PlayState.eScoreLiteral++;
				this.resetPosition();
			}
			if (lastPaddleCollidedWith != null && lastPaddleCollidedWith == "leftPaddle") 
			{
				if (PlayState.topRightWall.overlapsPoint(new FlxPoint(this.x + 32, this.y))) 
				{
					this.changeDirection("southEast");
				}
				if (PlayState.topLeftWall.overlapsPoint(new FlxPoint( this.x + 32, this.y))) 
				{
					this.changeDirection("southEast");
				}
				if (PlayState.bottomLeftWall.overlapsPoint(new FlxPoint( this.x + 32, this.y + 32))) 
				{
					this.changeDirection("northEast");
				}
				if (PlayState.bottomRightWall.overlapsPoint(new FlxPoint( this.x + 32, this.y + 32))) 
				{
					this.changeDirection("northEast");
				}
			}
			
			if (lastPaddleCollidedWith != null && lastPaddleCollidedWith == "rightPaddle") 
			{
				if (PlayState.topRightWall.overlapsPoint(new FlxPoint( this.x + 32, this.y))) 
				{
					this.changeDirection("southWest");
				}
				if (PlayState.topLeftWall.overlapsPoint(new FlxPoint( this.x + 32, this.y))) 
				{
					this.changeDirection("southWest");
				}
				if (PlayState.bottomLeftWall.overlapsPoint(new FlxPoint( this.x + 32, this.y + 32))) 
				{
					this.changeDirection("northWest");
				}
				if (PlayState.bottomRightWall.overlapsPoint(new FlxPoint( this.x + 32, this.y + 32))) 
				{
					this.changeDirection("northWest");
				}
			}
		}
	}
	
	public function changeDirection(whichWay:String):Void 
	{
		this.direction = whichWay;
	}
	
	private function resetPosition():Void 
	{
		this.x = (FlxG.width / 2) - 16;
		this.y = (FlxG.height / 2) - 16;
		changeDirection("right");
		isPaused = false;
		this.speedX = 4;
		this.speedY = 2;
		this.hitCount = 0;
		this.color = 0xffffffff;
	}
	
	public function increaseTheNeedForSpeed():Void 
	{
		if (this.speedX > 7) 
		{
			
		}
		else 
		{
			this.speedX += 0.3;
			this.speedY += 0.3;
		}
		
		if ( this.hitCount == 3)
		{
			this.color = 0xff663333;
		}
		if ( this.hitCount == 6)
		{
			this.color = 0xff993333;
		}
		if ( this.hitCount == 9 )
		{
			this.color = 0xffcc3333;
		}
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
}