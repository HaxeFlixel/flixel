/**
* Atari 2600 Breakout
* In Flixel 2.5
* By Richard Davey, Photon Storm
* In 20mins :)
* Original code and video can be found at: http://www.photonstorm.com/archives/1290/video-of-me-coding-breakout-in-flixel-in-20-mins
*/
package;
import nme.display.BitmapInt32;
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
		#if !neko
		bat = new FlxSprite(180, 220).makeGraphic(40, 6, 0xffd63bc3);
		#else
		bat = new FlxSprite(180, 220).makeGraphic(40, 6, {rgb: 0xd63bc3, a: 0xff});
		#end
		bat.immovable = true;
		
		#if !neko
		ball = new FlxSprite(180, 160).makeGraphic(6, 6, 0xffd63bc3);
		#else
		ball = new FlxSprite(180, 160).makeGraphic(6, 6, {rgb: 0xd63bc3, a: 0xff});
		#end
		ball.elasticity = 1;
		ball.maxVelocity.x = 200;
		ball.maxVelocity.y = 200;
		ball.velocity.y = 200;
		
		walls = new FlxGroup();
		
		#if !neko
		leftWall = new FlxSprite(0, 0).makeGraphic(10, 240, 0xffababab);
		#else
		leftWall = new FlxSprite(0, 0).makeGraphic(10, 240, {rgb: 0xababab, a: 0xff});
		#end
		leftWall.immovable = true;
		walls.add(leftWall);
		
		#if !neko
		rightWall = new FlxSprite(310, 0).makeGraphic(10, 240, 0xffababab);
		#else
		rightWall = new FlxSprite(310, 0).makeGraphic(10, 240, {rgb: 0xababab, a: 0xff});
		#end
		rightWall.immovable = true;
		walls.add(rightWall);
		
		#if !neko
		topWall = new FlxSprite(0, 0).makeGraphic(320, 10, 0xffababab);
		#else
		topWall = new FlxSprite(0, 0).makeGraphic(320, 10, {rgb: 0xababab, a: 0xff});
		#end
		topWall.immovable = true;
		walls.add(topWall);
		
		#if !neko
		bottomWall = new FlxSprite(0, 239).makeGraphic(320, 10, 0xff000000);
		#else
		bottomWall = new FlxSprite(0, 239).makeGraphic(320, 10, {rgb: 0x000000, a: 0xff});
		#end
		bottomWall.immovable = true;
		walls.add(bottomWall);
		
		//	Some bricks
		bricks = new FlxGroup();
		
		var bx:Int = 10;
		var by:Int = 30;
		
		#if flash
		var brickColours:Array<UInt> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];
		#elseif (cpp || js)
		var brickColours:Array<Int> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];
		#elseif neko
		var brickColours:Array<BitmapInt32> = [{rgb: 0xd03ad1, a: 0xff}, {rgb: 0xf75352, a: 0xff}, {rgb: 0xfd8014, a: 0xff}, {rgb: 0xff9024, a: 0xff}, {rgb: 0x05b320, a: 0xff}, {rgb: 0x6d65f6, a: 0xff}];
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