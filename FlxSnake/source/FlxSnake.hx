/**
* FlxSnake for Flixel 2.23 - 19th March 2010
* 
* Cursor keys to move. Red squares are fruit. Snake can wrap around screen edges.
* 
* @author Richard Davey, Photon Storm <rich@photonstorm.com>
*/

package;

import flash.Lib;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

class FlxSnake extends FlxState
{
	private var score:FlxText;
	private var fruit:FlxSprite;
	
	private var isAlive:Bool;
	private var snakeHead:FlxSprite;
	private var snakeBody:FlxGroup;
	private var addSegment:Bool;

	private var nextMove:Int;
	private var snakeSpeed:Int;
	
	public function new() 
	{
		super();
	}
	
	override public function create():Void
	{
		isAlive = true;
		addSegment = false;
		snakeSpeed = 150;
		nextMove = Lib.getTimer() + snakeSpeed * 2;
		
		//	Let's create the body pieces, we'll start with 3 pieces plus a head. Each piece is 8x8
		snakeBody = new FlxGroup();
		
		spawnNewBody(64 + 8, Math.floor(FlxG.height / 2));
		spawnNewBody(64 + 16, Math.floor(FlxG.height / 2));
		spawnNewBody(64 + 24, Math.floor(FlxG.height / 2));
		spawnNewBody(64 + 32, Math.floor(FlxG.height / 2));
		
		//	Get the head piece from the body For easy later reference, and also visually change the colour a little
		snakeHead = cast(snakeBody.members[0], FlxSprite);
		snakeHead.makeGraphic(8, 8, 0xFF00FF00);
		snakeHead.facing = FlxObject.LEFT;
		
		//	Something to eat
		fruit = new FlxSprite(0, 0).makeGraphic(8, 8, 0xFFFF0000);
		placeFruit();
		
		//	Simple score
		score = new FlxText(0, 0, 200);
		Reg.score = 0;
		
		add(snakeBody);
		add(fruit);
		add(score);
	}
	
	override public function update():Void
	{
		super.update();
		
		if (isAlive)
		{
			//	Collision Checks
			
			//	1) First did we hit the fruit?
			if (snakeHead.overlaps(fruit))
			{
				Reg.score += 10;
				placeFruit();
				addSegment = true;
				FlxG.play("Beep");
				
				//	Get a little faster each time
				if (snakeSpeed > 50)
				{
					snakeSpeed -= 10;
				}
			}
			
			//	2) Did we hit ourself? :)
			//	We set the deadSnake callback to stop the QuadTree killing both objects, as we want them on-screen with the game over message
			FlxG.overlap(snakeHead, snakeBody, deadSnake);
			
			score.text = "Score: " + Std.string(Reg.score);
			
			if (FlxG.keys.UP)
			{
				snakeHead.facing = FlxObject.UP;
			}
			else if (FlxG.keys.DOWN)
			{
				snakeHead.facing = FlxObject.DOWN;
			}
			else if (FlxG.keys.LEFT)
			{
				snakeHead.facing = FlxObject.LEFT;
			}
			else if (FlxG.keys.RIGHT)
			{
				snakeHead.facing = FlxObject.RIGHT;
			}
			
			if (Lib.getTimer() > nextMove)
			{
				moveSnakeParts();
				nextMove = Lib.getTimer() + snakeSpeed;
			}
		}
		else
		{
			score.text = "GAME OVER! Score: " + Std.string(Reg.score);
		}
	}
	
	private function deadSnake(object1:FlxObject, object2:FlxObject):Void
	{
		isAlive = false;
		FlxG.play("Flixel");
	}
	
	private function placeFruit(?object1:FlxObject = null, ?object2:FlxObject = null):Void
	{
		//	Pick a random place to put the fruit down
		
		fruit.x = Std.int(Math.random() * (FlxG.width / 8) - 1) * 8;
		fruit.y = Std.int(Math.random() * (FlxG.height / 8) - 1) * 8;
		
		//	Check that the coordinates we picked aren't already covering the snake, if they are then run this function again
		FlxG.overlap(fruit, snakeBody, placeFruit);
	}
	
	private function moveSnakeParts():Void
	{
		//	Move the head in the direction it is facing
		//	If it hits the edge of the screen it wraps around
		
		var oldX:Int = Math.floor(snakeHead.x);
		var oldY:Int = Math.floor(snakeHead.y);
		
		var currentMember:FlxSprite = cast(snakeBody.members[snakeBody.members.length - 1], FlxSprite);
		var previousMember:FlxSprite;
		
		var addX:Int = 0;
		var addY:Int = 0;
		
		if (addSegment)
		{
			addX = Math.floor(currentMember.x);
			addY = Math.floor(currentMember.y);
		}
		
		switch (snakeHead.facing)
		{
			case FlxObject.LEFT:
				if (snakeHead.x == 0)
				{
					snakeHead.x = FlxG.width - 8;
				}
				else
				{
					snakeHead.x -= 8;
				}
				
			case FlxObject.RIGHT:
				if (snakeHead.x == FlxG.width - 8)
				{
					snakeHead.x = 0;
				}
				else
				{
					snakeHead.x += 8;
				}
				
			case FlxObject.UP:
				if (snakeHead.y == 0)
				{
					snakeHead.y = FlxG.height - 8;
				}
				else
				{
					snakeHead.y -= 8;
				}
				
			case FlxObject.DOWN:
				if (snakeHead.y == FlxG.height - 8)
				{
					snakeHead.y = 0;
				}
				else
				{
					snakeHead.y += 8;
				}
		}
		
		//	And now interate the movement down to the rest of the body parts
		//	The easiest way to do this is simply to work our way backwards through the body pieces!
		var s:Int = snakeBody.members.length - 1;
		while(s > 0)
		{
			currentMember = cast(snakeBody.members[s], FlxSprite);
			//	We need to keep the x/y/facing values from the snake part, to pass onto the next one in the chain
			if (s == 1)
			{
				currentMember.x = oldX;
				currentMember.y = oldY;
			}
			else
			{
				previousMember = cast(snakeBody.members[s - 1], FlxSprite);
				
				currentMember.x = previousMember.x;
				currentMember.y = previousMember.y;
			}
			
			s--;
		}
		
		//	Are we adding a new snake segment? If so then put it where the final piece used to be
		if (addSegment)
		{
			spawnNewBody(addX, addY);
			addSegment = false;
		}
		
	}
	
	private function spawnNewBody(_x:Int, _y:Int):Void
	{
		snakeBody.add(new FlxSprite(_x, _y).makeGraphic(8, 8, 0xFF008000));
	}
	
}