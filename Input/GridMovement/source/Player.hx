package;

import flixel.FlxG;
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
	/**
	 * How big the tiles of the tilemap are.
	 */
	inline static private var TILE_SIZE:Int = 16;
	/**
	 * How many pixels to move each frame. Has to be a divider of TILE_SIZE 
	 * to work as expected (move one block at a time), because we use the
	 * modulo-operator to check whether the next block has been reached.
	 */
	inline static private var MOVEMENT_SPEED:Int = 2;
	
	/**
	 * Flag used to check if char is moving.
	 */ 
	public var moveToNextTile:Bool;
	/**
	 * Var used to hold moving direction.
	 */ 
	private var moveDirection:MoveDirection;
	
	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		// Make the player graphic.
		makeGraphic(TILE_SIZE, TILE_SIZE, 0xffc04040);
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
		
		// Check for WASD or arrow key presses and move accordingly
		if (FlxG.keys.anyPressed(["DOWN", "S"]))
		{
			moveTo(MoveDirection.DOWN);
		}
		else if (FlxG.keys.anyPressed(["UP", "W"]))
		{
			moveTo(MoveDirection.UP);
		}
		else if (FlxG.keys.anyPressed(["LEFT", "A"]))
		{
			moveTo(MoveDirection.LEFT);
		}
		else if (FlxG.keys.anyPressed(["RIGHT", "D"]))
		{
			moveTo(MoveDirection.RIGHT);
		}
	}
	
	public function moveTo(Direction:MoveDirection):Void
	{
		// Only change direction if not already moving
		if (!moveToNextTile)
		{
			moveDirection = Direction;
			moveToNextTile = true;
		}
	}
}
