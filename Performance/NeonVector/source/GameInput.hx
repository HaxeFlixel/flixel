package;

import flixel.FlxG;
import flixel.math.FlxPoint;

/**
 * @author Masadow
 */
class GameInput
{
	public static var move(get, null):FlxPoint;
	public static var aim(get, null):FlxPoint;
	public static var wasBombButtonPressed(get, never):Bool;
	private static var _mouseLast:FlxPoint;
	public static var aimWithMouse(default, null):Bool = false;

	public static var lengthBeforeNormalize:Float;
	
	public static function create():Void
	{
		move = FlxPoint.get();
		aim = FlxPoint.get();
		_mouseLast = FlxPoint.get();
	}
	
	public static function update():Void
	{
		//Don't enable aiming with the mouse unless the aiming keys aren't in use and the mouse has moved position
		if (FlxG.mouse.pressed) aimWithMouse = true;
		else if (FlxG.keys.anyPressed([LEFT, RIGHT, UP, DOWN])) aimWithMouse = false;
		else if ((FlxG.mouse.x == _mouseLast.x) && (FlxG.mouse.y == _mouseLast.y)) aimWithMouse = false;
		else aimWithMouse = true;
		
		//store the mouse's position to test for mouse movement next frame
		_mouseLast.x = FlxG.mouse.x;
		_mouseLast.y = FlxG.mouse.y;
	}
	
	public static function normalize(Point:FlxPoint):FlxPoint
	{
		//Normalize the length if the player is aiming diagonally
		lengthBeforeNormalize = Math.sqrt(Point.x * Point.x + Point.y * Point.y);
		if (lengthBeforeNormalize != 0) 
		{
				Point.x /= lengthBeforeNormalize;
				Point.y /= lengthBeforeNormalize;
		}
		
		return Point;
	}
	
	public static function get_move():FlxPoint
	{
		move.x = move.y = 0;
		
		if (FlxG.keys.pressed.A) move.x -= 1;
		if (FlxG.keys.pressed.D) move.x += 1;
		if (FlxG.keys.pressed.W) move.y -= 1;
		if (FlxG.keys.pressed.S) move.y += 1;
		
		return normalize(move);
	}
	
	public static function get_aim():FlxPoint
	{
		aim.x = aim.y = 0;
		
		if (aimWithMouse)
		{
			aim.x = FlxG.mouse.x;
			aim.y = FlxG.mouse.y;
			
			return aim;
		}
		else
		{
			if (FlxG.keys.pressed.LEFT) aim.x -= 1;
			if (FlxG.keys.pressed.RIGHT) aim.x += 1;
			if (FlxG.keys.pressed.UP) aim.y += 1;
			if (FlxG.keys.pressed.DOWN) aim.y -= 1;
			
			return normalize(aim);
		}
	}
	
	public static function get_wasBombButtonPressed():Bool
	{
		return FlxG.keys.justPressed.SPACE;
	}
}
