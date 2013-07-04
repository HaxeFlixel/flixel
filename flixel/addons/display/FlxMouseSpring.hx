package flixel.addons.display;

#if !FLX_NO_MOUSE
import flixel.FlxG;

class FlxMouseSpring 
{
	public var sprite:FlxExtendedSprite;
	/**
	 * The tension of the spring, smaller numbers create springs closer to the mouse pointer
	 * @default 0.1
	 */
	public var tension:Float;
	/**
	 * The friction applied to the spring as it moves
	 * @default 0.95
	 */
	public var friction:Float;
	/**
	 * The gravity controls how far "down" the spring hangs (use a negative value for it to hang up!)
	 * @default 0
	 */
	public var gravity:Float;
	
	private var _retainVelocity:Bool;
	
	private var _vx:Float = 0;
	private var _vy:Float = 0;

	private var _dx:Float = 0;
	private var _dy:Float = 0;
	
	private var _ax:Float = 0;
	private var _ay:Float = 0;
	
	/**
	 * Adds a spring between the mouse and a <code>FlxExtendedSprite</code>.
	 * 
	 * @param	Sprite			The FlxExtendedSprite to which this spring is attached
	 * @param	RetainVelocity	True to retain the velocity of the spring when the mouse is released, or false to clear it
	 * @param	Tension			The tension of the spring, smaller numbers create springs closer to the mouse pointer
	 * @param	Friction		The friction applied to the spring as it moves
	 * @param	Gravity			The gravity controls how far "down" the spring hangs (use a negative value for it to hang up!)
	 */
	public function new(Sprite:FlxExtendedSprite, RetainVelocity:Bool = false, Tension:Float = 0.1, Friction:Float = 0.95, Gravity:Float = 0)
	{
		sprite = Sprite;
		_retainVelocity = RetainVelocity;
		tension = Tension;
		friction = Friction;
		gravity = Gravity;
	}
	
	/**
	 * Updates the spring physics and repositions the sprite
	 */
	public function update():Void
	{
		_dx = FlxG.mouse.x - sprite.springX;
		_dy = FlxG.mouse.y - sprite.springY;
		
		_ax = _dx * tension;
		_ay = _dy * tension;
		
		_vx += _ax;
		_vy += _ay;
		
		_vy += gravity;
		_vx *= friction;
		_vy *= friction;
		
		sprite.x += _vx;
		sprite.y += _vy;
	}
	
	/**
	 * Resets the internal spring physics
	 */
	public function reset():Void
	{
		_vx = 0;
		_vy = 0;
		
		_dx = 0;
		_dy = 0;
		
		_ax = 0;
		_ay = 0;
	}
}
#end