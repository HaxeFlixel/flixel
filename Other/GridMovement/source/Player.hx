package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author .:BuzzJeux:.
 */
enum MoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

class Player extends FlxSprite
{
	inline static private var MOVEMENT_SPEED:Int = 2;
	inline static private var TILE_SIZE:Int = 16;
	
	// Flag used to check if char is moving.
	public var moveToNextTile:Bool;
	// Var used to hold moving direction.
	private var moveDirection:MoveDirection;
	
	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		// Make the player.
		makeGraphic(16, 16, 0xffc04040, true);
	}
	
	override public function update():Void
	{
		super.update();  
		
		// Move the player to the next block
		if (moveToNextTile)
		{
			switch(moveDirection)
			{
				case UP:
				y -= MOVEMENT_SPEED;
				case DOWN:
				y += MOVEMENT_SPEED;
				case LEFT:
				x -= MOVEMENT_SPEED;
				case RIGHT:
				x += MOVEMENT_SPEED;
			}
		}
		
		// Check if the player has now reached the next block
		if ((x % TILE_SIZE == 0) && (y % TILE_SIZE == 0))
		{
			moveToNextTile = false;
		}
		
		// Determine which direction to move
		if (FlxG.keys.pressed.DOWN)
		{
			move(MoveDirection.DOWN);
		}
		else if (FlxG.keys.pressed.UP)
		{
			move(MoveDirection.UP);
		}
		else if (FlxG.keys.pressed.LEFT)
		{
			move(MoveDirection.LEFT);
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			move(MoveDirection.RIGHT);
		}
	}
	
	public function move(dir:MoveDirection):Void
	{
		// Only change direction if not already moving
		if (!moveToNextTile)
		{
			moveDirection = dir;
			moveToNextTile = true;
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}
}