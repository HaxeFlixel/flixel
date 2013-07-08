/**
* Atari 2600 Breakout
* In Flixel 2.5
* By Richard Davey, Photon Storm
* In 20mins :)
* Original code and video can be found at: http://www.photonstorm.com/archives/1290/video-of-me-coding-breakout-in-flixel-in-20-mins
*/
package;

import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxTileblock;


class Breakout extends FlxState
{
	private var bat:FlxSprite;
	private var ball:FlxSprite;
	
	private var walls:FlxGroup;
	private var leftWall:FlxSprite;
	private var rightWall:FlxSprite;
	private var topWall:FlxSprite;
	private var bottomWall:FlxSprite;
	
	private var bricks:FlxGroup;
	
	public function new() 
	{  
		super();
	}
	
	override public function create():Void
	{
		bat = new FlxSprite(180, 220).makeGraphic(40, 6, 0xffd63bc3);
		bat.immovable = true;
		
		ball = new FlxSprite(180, 160).makeGraphic(6, 6, 0xffd63bc3);
		ball.elasticity = 1;
		ball.maxVelocity.x = 200;
		ball.maxVelocity.y = 200;
		ball.velocity.y = 200;
		
		walls = new FlxGroup();
		
		leftWall = new FlxSprite(0, 0).makeGraphic(10, 240, 0xffababab);
		leftWall.immovable = true;
		walls.add(leftWall);
		
		rightWall = new FlxSprite(310, 0).makeGraphic(10, 240, 0xffababab);
		rightWall.immovable = true;
		walls.add(rightWall);
		
		topWall = new FlxSprite(0, 0).makeGraphic(320, 10, 0xffababab);
		topWall.immovable = true;
		walls.add(topWall);
		
		bottomWall = new FlxSprite(0, 239).makeGraphic(320, 10, 0xff000000);
		bottomWall.immovable = true;
		walls.add(bottomWall);
		
		//	Some bricks
		bricks = new FlxGroup();
		
		var bx:Int = 10;
		var by:Int = 30;
		
		#if flash
		var brickColours:Array<UInt> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];
		#else
		var brickColours:Array<Int> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];
		#end
		
		for (y in 0...6)
		{
			for (x in 0...20)
			{
				var tempBrick:FlxSprite = new FlxSprite(bx, by);
				tempBrick.makeGraphic(15, 15, brickColours[y]);
				tempBrick.immovable = true;
				bricks.add(tempBrick);
				bx += 15;
			}
			
			bx = 10;
			by += 15;
		}
		
		add(walls);
		add(bat);
		add(ball);
		add(bricks);
	}
	
	override public function update():Void
	{
		super.update();
		
		bat.velocity.x = 0;
		
		if (FlxG.keys.LEFT && bat.x > 10)
		{
			bat.velocity.x = -300;
		}
		else if (FlxG.keys.RIGHT && bat.x < 270)
		{
			bat.velocity.x = 300;
		}
		
		if (bat.x < 10)
		{
			bat.x = 10;
		}
		
		if (bat.x > 270)
		{
			bat.x = 270;
		}
		
		FlxG.collide(ball, walls);
		FlxG.collide(bat, ball, ping);
		FlxG.collide(ball, bricks, hit);
	}
	
	private function hit(_ball:FlxObject, _brick:FlxObject):Void
	{
		_brick.exists = false;
	}
	
	private function ping(_bat:FlxObject, _ball:FlxObject):Void
	{
		var batmid:Int = Std.int(_bat.x) + 20;
		var ballmid:Int = Std.int(_ball.x) + 3;
		var diff:Int;
		
		if (ballmid < batmid)
		{
			//	Ball is on the left of the bat
			diff = batmid - ballmid;
			ball.velocity.x = ( -10 * diff);
		}
		else if (ballmid > batmid)
		{
			//	Ball on the right of the bat
			diff = ballmid - batmid;
			ball.velocity.x = (10 * diff);
		}
		else
		{
			//	Ball is perfectly in the middle
			//	A little random X to stop it bouncing up!
			ball.velocity.x = 2 + Std.int(Math.random() * 8);
		}
	}
	
}