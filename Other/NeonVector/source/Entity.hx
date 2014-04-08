package ;
import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.FlxG;

/**
 * @author Masadow
 */
class Entity extends FlxSprite
{
	@:isVar public var type(get, set):UInt;
	public var radius:Float = 0;
	public var hitboxRadius:Float = 0;
	public var moveSpeed:Float = 0;
	public var moveAcceleration:Float = 0;
	private var cooldownTimer:FlxTimer;
	private var _position : FlxPoint;
	public var position(get, set):FlxPoint;
	private var hitEdgeOfScreen:Bool = false;
	public var cooldown:Float = 0.075;
	
	public function get_type() : UInt
	{
		return type;
	}
	
	public function set_type(Value : UInt) : UInt
	{
		return type = Value;
	}
	
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		_position = FlxPoint.get();
		
		blend = SCREEN;
		cooldownTimer = FlxTimer.start();
		cooldownTimer.finished = true;
	}
	
	override public function draw():Void
	{
		super.draw();
	}
	
	override public function update():Void
	{
		super.update();
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}
	
	public function collidesWith(Object:Entity, Distance:Float):Void
	{
			
	}
	
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
	
	public function get_position():FlxPoint
	{
		_position.x = x + radius;
		_position.y = y + radius;
		
		return _position;
	}
	
	public function set_position(Value:FlxPoint):FlxPoint
	{
		x = Value.x - radius;
		y = Value.y - radius;
		
		_position.x = Value.x;
		_position.y = Value.y;
		return _position;
	}
	
	public static function toRadians(AngleInDegrees:Float):Float
	{
		return ((90 + AngleInDegrees) * Math.PI) / 180;
	}
	
	public static function toDegrees(AngleInRadians:Float):Float
	{
		return (AngleInRadians * 180) / Math.PI;
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
	
	public static function Interpolate(Value1:Float, Value2:Float, WeightOfValue2:Float):Float
	{
		return (Value1 + (Value2 - Value1) * WeightOfValue2);
	}
	
	public static function InterpolateRGB(ColorA:UInt, ColorB:UInt, WeightOfColorB:Float):UInt
	{
		var _r:Int = Std.int(Interpolate(0xff & (ColorA >> 16), 0xff & (ColorB >> 16), WeightOfColorB));
		var _g:Int = Std.int(Interpolate(0xff & (ColorA >> 8), 0xff & (ColorB >> 8), WeightOfColorB));
		var _b:Int = Std.int(Interpolate(0xff & ColorA, 0xff & ColorB, WeightOfColorB));
		
		return (_r << 16) | (_g << 8) | _b;
	}
	
	/**
	 * Modified from http://www.therealjoshua.com/code/flex/calico/src/com/flashfactory/calico/utils/ColorMathUtil.as
	 * Converts Hue, Saturation, Value to RRGGBB format
	 * @Hue Angle between 0-360
	 * @Saturation Float between 0 and 1
	 * @Value Float between 0 and 1
	 */
	public static function HSVtoRGB(Hue:Float, Saturation:Float, Value:Float):UInt
	{
		var hi:Int = Math.floor(Hue/60) % 6;
		var f:Float = Hue/60 - Math.floor(Hue/60);
		var p:Float = (Value * (1 - Saturation));
		var q:Float = (Value * (1 - f * Saturation));
		var t:Float = (Value * (1 - (1 - f) * Saturation));
		
		var r:Float=0;
		var g:Float=0;
		var b:Float=0;
		switch(hi)
		{
			case 0: r = Value;       	g = t;              b = p;
			case 1: r = q;				g = Value;        	b = p;
			case 2: r = p;            	g = Value;       	b = t;
			case 3: r = p;            	g = q;              b = Value;
			case 4: r = t;				g = p;              b = Value;
			case 5: r = Value;        	g = p;              b = q;
		}
		
		return Math.round(r * 255) << 16 | Math.round(g * 255) << 8 | Math.round(b * 255);
	}
}
