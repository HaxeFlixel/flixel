package flixel.phys.classic;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.phys.IFlxSpace;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.math.FlxVelocity;

class FlxClassicBody implements flixel.phys.IFlxBody
{	
	public var 	parent : FlxObject;
	public var	space  : IFlxSpace;
	
	public var 	x : Float;
	public var 	y : Float;
	public var 	last : FlxPoint;
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
	
	public var  allowCollisions : Int = FlxCollide.ANY;
	public var 	touching : Int = 0;
	
	public var	kinematic : Bool = false;
	public var  collisonXDrag : Bool = false;
	
	public var 	width : Float;
	public var 	height : Float;
	
	public function new(parent : FlxObject, space : FlxClassicSpace)
	{
		this.space = space;
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
		
		space.add(this);
	}
	
	public function destroy() : Void
	{
		space.remove(this);
		last.put();
		velocity.put();
		maxVelocity.put;
		acceleration.put();
	}
	
	public function updateBody(elapsed : Float) : Void
	{
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
		
		parent.x = x;
		parent.y = y;
	}
}