package;

import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.FlxG;

/**
 * @author Masadow
 */
class Entity extends FlxSprite
{
	public var type(default, set):UInt = 0;
	public var radius:Float = 0;
	public var hitboxRadius:Float = 0;
	public var moveSpeed:Float = 0;
	public var moveAcceleration:Float = 0;
	private var cooldownTimer:FlxTimer;
	private var _position : FlxPoint;
	public var position(get, set):FlxPoint;
	private var hitEdgeOfScreen:Bool = false;
	public var cooldown:Float = 0.075;
	
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		_position = FlxPoint.get();
		
		#if !js
		blend = SCREEN;
		#end
		cooldownTimer = new FlxTimer();
		cooldownTimer.finished = true;
	}
	
	public function collidesWith(elapsed:Float, Object:Entity, Distance:Float):Void {}
	
	public function clampToScreen():Bool
	{
		var _wasClamped:Bool = false;
		//clamp the position to be within the bounds of the screen
		if (x < 0) 
		{
			x = 0;
			_wasClamped = true;
		}
		else if (x + 2 * hitboxRadius > FlxG.width) 
		{
			x = FlxG.width - 2 * hitboxRadius;
			_wasClamped = true;
		}
		if (y < 0) 
		{
			y = 0;
			_wasClamped = true;
		}
		else if (y + 2 * hitboxRadius > FlxG.height) 
		{
			y = FlxG.height - 2 * hitboxRadius;
			_wasClamped = true;
		}
		return _wasClamped;
	}
	
	private function get_position():FlxPoint
	{
		_position.x = x + radius;
		_position.y = y + radius;
		
		return _position;
	}
	
	private function set_position(Value:FlxPoint):FlxPoint
	{
		x = Value.x - radius;
		y = Value.y - radius;
		
		_position.x = Value.x;
		_position.y = Value.y;
		return _position;
	}
	
	private function set_type(Value:UInt) 
	{
		return type = Value;
	}
	
	public static function angleInDegrees(Vector:FlxPoint):Float
	{
		var _angleInRadians:Float = Math.atan2(Vector.y, Vector.x);
		return (_angleInRadians / Math.PI) * 180;
	}
	
	public static function angleInRadians(Vector:FlxPoint):Float
	{
		return Math.atan2(Vector.y, Vector.x);
	}
	
	public static function interpolate(Value1:Float, Value2:Float, WeightOfValue2:Float):Float
	{
		return (Value1 + (Value2 - Value1) * WeightOfValue2);
	}
}
