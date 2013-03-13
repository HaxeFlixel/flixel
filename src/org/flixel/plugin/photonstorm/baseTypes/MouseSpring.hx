package org.flixel.plugin.photonstorm.baseTypes;
#if !FLX_NO_MOUSE
import org.flixel.FlxG;
import org.flixel.plugin.photonstorm.FlxExtendedSprite;

class MouseSpring 
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
	
	private var retainVelocity:Bool;
	
	private var vx:Float;
	private var vy:Float;

	private var dx:Float;
	private var dy:Float;
	
	private var ax:Float;
	private var ay:Float;
	
	/**
	 * Adds a spring between the mouse and a Sprite.
	 * 
	 * @param	sprite				The FlxExtendedSprite to which this spring is attached
	 * @param	retainVelocity		true to retain the velocity of the spring when the mouse is released, or false to clear it
	 * @param	tension				The tension of the spring, smaller numbers create springs closer to the mouse pointer
	 * @param	friction			The friction applied to the spring as it moves
	 * @param	gravity				The gravity controls how far "down" the spring hangs (use a negative value for it to hang up!)
	 */
	public function new(sprite:FlxExtendedSprite, retainVelocity:Bool = false, tension:Float = 0.1, friction:Float = 0.95, gravity:Float = 0)
	{
		vx = 0;
		vy = 0;
		dx = 0;
		dy = 0;
		ax = 0;
		ay = 0;
		
		this.sprite = sprite;
		this.retainVelocity = retainVelocity;
		this.tension = tension;
		this.friction = friction;
		this.gravity = gravity;
	}
	
	/**
	 * Updates the spring physics and repositions the sprite
	 */
	public function update():Void
	{
		dx = FlxG.mouse.x - sprite.springX;
		dy = FlxG.mouse.y - sprite.springY;
		
		ax = dx * tension;
		ay = dy * tension;
		
		vx += ax;
		vy += ay;
		
		vy += gravity;
		vx *= friction;
		vy *= friction;
		
		sprite.x += vx;
		sprite.y += vy;
	}
	
	/**
	 * Resets the internal spring physics
	 */
	public function reset():Void
	{
		vx = 0;
		vy = 0;
	
		dx = 0;
		dy = 0;
		
		ax = 0;
		ay = 0;
	}
	
}
#end