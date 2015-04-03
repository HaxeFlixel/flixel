package flixel.phys.classic;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.phys.IFlxSpace;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.math.FlxVelocity;

@:allow(flixel.phys.classic)
class FlxClassicBody implements flixel.phys.IFlxBody
{	
		public static inline var LEFT:Int	= 0x0001;
	/**
	 * Generic value for "right" Used by facing, allowCollisions, and touching.
	 */
	public static inline var RIGHT:Int	= 0x0010;
	/**
	 * Generic value for "up" Used by facing, allowCollisions, and touching.
	 */
	public static inline var UP:Int		= 0x0100;
	/**
	 * Generic value for "down" Used by facing, allowCollisions, and touching.
	 */
	public static inline var DOWN:Int	= 0x1000;
	/**
	 * Special-case constant meaning no collisions, used mainly by allowCollisions and touching.
	 */
	public static inline var NONE:Int	= 0;
	/**
	 * Special-case constant meaning up, used mainly by allowCollisions and touching.
	 */
	public static inline var CEILING:Int	= UP;
	/**
	 * Special-case constant meaning down, used mainly by allowCollisions and touching.
	 */
	public static inline var FLOOR:Int	= DOWN;
	/**
	 * Special-case constant meaning only the left and right sides, used mainly by allowCollisions and touching.
	 */
	public static inline var WALL:Int	= LEFT | RIGHT;
	/**
	 * Special-case constant meaning any direction, used mainly by allowCollisions and touching.
	 */
	public static inline var ANY:Int	= LEFT | RIGHT | UP | DOWN;
	
	
	public var 	parent : FlxObject;
	public var	space  : IFlxSpace;
	
	public var 	x : Float;
	public var 	y : Float;
	public var 	velocity : FlxPoint;
	public var	drag : FlxPoint;
	public var	maxVelocity : FlxPoint;
	public var 	acceleration : FlxPoint;
	
	public var	angle : Float;
	public var	angularVelocity : Float = 0;
	public var	angularDrag : Float = 0;
	public var	maxAngular : Float = 0;
	public var	angularAcceleration : Float = 0;
	
	public var	mass : Float = 1;
	public var	elasticity : Float = 0;
	
	public var  allowCollisions : Int = ANY;
	public var 	touching : Int = 0;
	public var 	wasTouching : Int = 0;
	
	public var	kinematic : Bool = false;
	public var  collisonXDrag : Bool = false;
	
	public var  collisionGroup : Int = 1;
	public var  collisionMask : Int = 1;
	
	public var 	width : Float;
	public var 	height : Float;
	
	public var  callback : FlxClassicBody->FlxClassicBody->Void;
	
	private var _hull : FlxRect;
	private var last : FlxPoint;
	
	public function new(parent : FlxObject)
	{
		this.parent = parent;
		
		last = FlxPoint.get(parent.x,parent.y);
		velocity = FlxPoint.get(parent.velocity.x, parent.velocity.y);
		maxVelocity = FlxPoint.get(parent.maxVelocity.x, parent.maxVelocity.y);
		drag = FlxPoint.get(0, 0);
		acceleration = FlxPoint.get(parent.acceleration.x, parent.acceleration.y);
		elasticity = parent.elasticity;
		
		angle = parent.angle;
		width = parent.width;
		height = parent.height;
		
		_hull = FlxRect.get();
	}
	
	public function destroy() : Void
	{
		cast(space, FlxClassicSpace).remove(this);
		last.put();
		velocity.put();
		maxVelocity.put;
		acceleration.put();
	}
	
	public function updateBody(elapsed : Float) : Void
	{
		wasTouching = touching;
		
		x = parent.x;
		y = parent.y;
		last.set(x, y);
		
		var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular, elapsed) - angularVelocity);
		angularVelocity += velocityDelta; 
		angle += angularVelocity * elapsed;
		angularVelocity += velocityDelta;
		
		velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x, elapsed) - velocity.x);
		velocity.x += velocityDelta;
		var delta = velocity.x * elapsed;
		velocity.x += velocityDelta;
		x += delta;
		
		velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y, elapsed) - velocity.y);
		velocity.y += velocityDelta;
		delta = velocity.y * elapsed;
		velocity.y += velocityDelta;
		y += delta;
		
		updateHull();
	}
	
	public inline function updateHull()
	{
		_hull.set((x < last.x) ? x : last.x, (y < last.y) ? y : last.y, width + Math.abs(x - last.x), height + Math.abs(y - last.y));
	}
	
	
	/**
	 * Handy function for checking if this object is just landed on a particular surface.
	 * Be sure to check it before calling super.update(), as that will reset the flags.
	 * 
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object just landed on (any of) the specified surface(s) this frame.
	 */
	public inline function justTouched(Direction:Int):Bool
	{
		return ((touching & Direction) > NONE) && ((wasTouching & Direction) <= NONE);
	}
	
	/**
	 * Handy function for checking if this object is touching a particular surface.
	 * Be sure to check it before calling super.update(), as that will reset the flags.
	 * 
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object is touching an object in (any of) the specified direction(s) this frame.
	 */
	public inline function isTouching(Direction:Int):Bool
	{
		return (touching & Direction) > NONE;
	}
}