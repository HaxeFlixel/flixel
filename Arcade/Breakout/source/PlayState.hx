package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;

/**
* Atari 2600 Breakout
* 
* @author Davey, Photon Storm
* @link http://www.photonstorm.com/archives/1290/video-of-me-coding-breakout-in-flixel-in-20-mins
*/
class PlayState extends FlxState
{
	private static inline var BAT_SPEED:Int = 350;
	
	private var _bat:FlxSprite;
	private var _ball:FlxSprite;
	
	private var _walls:FlxGroup;
	private var _leftWall:FlxSprite;
	private var _rightWall:FlxSprite;
	private var _topWall:FlxSprite;
	private var _bottomWall:FlxSprite;
	
	private var _bricks:FlxGroup;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		_bat = new FlxSprite(180, 220);
		_bat.makeGraphic(40, 6, FlxColor.MAGENTA);
		_bat.immovable = true;
		
		_ball = new FlxSprite(180, 160);
		_ball.makeGraphic(6, 6, FlxColor.MAGENTA);
		
		_ball.elasticity = 1;
		_ball.maxVelocity.set(200, 200);
		_ball.velocity.y = 200;
		
		_walls = new FlxGroup();
		
		_leftWall = new FlxSprite(0, 0);
		_leftWall.makeGraphic(10, 240, FlxColor.GRAY);
		_leftWall.immovable = true;
		_walls.add(_leftWall);
		
		_rightWall = new FlxSprite(310, 0);
		_rightWall.makeGraphic(10, 240, FlxColor.GRAY);
		_rightWall.immovable = true;
		_walls.add(_rightWall);
		
		_topWall = new FlxSprite(0, 0);
		_topWall.makeGraphic(320, 10, FlxColor.GRAY);
		_topWall.immovable = true;
		_walls.add(_topWall);
		
		_bottomWall = new FlxSprite(0, 239);
		_bottomWall.makeGraphic(320, 10, FlxColor.TRANSPARENT);
		_bottomWall.immovable = true;
		_walls.add(_bottomWall);
		
		// Some bricks
		_bricks = new FlxGroup();
		
		var bx:Int = 10;
		var by:Int = 30;
		
		var brickColours:Array<Int> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];
		
		for (y in 0...6)
		{
			for (x in 0...20)
			{
				var tempBrick:FlxSprite = new FlxSprite(bx, by);
				tempBrick.makeGraphic(15, 15, brickColours[y]);
				tempBrick.immovable = true;
				_bricks.add(tempBrick);
				bx += 15;
			}
			
			bx = 10;
			by += 15;
		}
		
		add(_walls);
		add(_bat);
		add(_ball);
		add(_bricks);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		_bat.velocity.x = 0;
		
		#if FLX_TOUCH
		// Simple routine to move bat to x position of touch
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.x > 10 && touch.x < 270)
				_bat.x = touch.x;
			}
		}
		// Vertical long swipe up or down resets game state
		for (swipe in FlxG.swipes)
		{
			if (swipe.distance > 100)
			{
				if ((swipe.angle < 10 && swipe.angle > -10) || (swipe.angle > 170 || swipe.angle < -170))
				{
					FlxG.resetState();
				}
			}
		}
		#end
		
		if (FlxG.keys.anyPressed([LEFT, A]) && _bat.x > 10)
		{
			_bat.velocity.x = - BAT_SPEED;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]) && _bat.x < 270)
		{
			_bat.velocity.x = BAT_SPEED;
		}
		
		if (FlxG.keys.justReleased.R)
		{
			FlxG.resetState();
		}
		
		if (_bat.x < 10)
		{
			_bat.x = 10;
		}
		
		if (_bat.x > 270)
		{
			_bat.x = 270;
		}
		
		FlxG.collide(_ball, _walls);
		FlxG.collide(_bat, _ball, ping);
		FlxG.collide(_ball, _bricks, hit);
	}
	
	private function hit(Ball:FlxObject, Brick:FlxObject):Void
	{
		Brick.exists = false;
	}
	
	private function ping(Bat:FlxObject, Ball:FlxObject):Void
	{
		var batmid:Int = Std.int(Bat.x) + 20;
		var ballmid:Int = Std.int(Ball.x) + 3;
		var diff:Int;
		
		if (ballmid < batmid)
		{
			// Ball is on the left of the bat
			diff = batmid - ballmid;
			Ball.velocity.x = ( -10 * diff);
		}
		else if (ballmid > batmid)
		{
			// Ball on the right of the bat
			diff = ballmid - batmid;
			Ball.velocity.x = (10 * diff);
		}
		else
		{
			// Ball is perfectly in the middle
			// A little random X to stop it bouncing up!
			Ball.velocity.x = 2 + FlxG.random.int(0, 8);
		}
	}
}