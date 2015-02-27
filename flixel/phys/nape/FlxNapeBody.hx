package flixel.phys.nape;

import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.phys.IFlxBody;
import nape.geom.Vec2;
import nape.phys.Body;
import flixel.math.FlxPoint;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.shape.Shape;

class FlxNapeBody implements IFlxBody
{
	public var napeBody : Body;
	
	public var 	parent : FlxObject;
	public var	space  : IFlxSpace;
	
	public var 	x : Float;
	public var 	y : Float;
	public var 	velocity : FlxPoint;
	public var	maxVelocity : FlxPoint;
	public var 	acceleration : FlxPoint;
	
	public var	angle : Float = 0;
	public var	angularVelocity : Float = 0;
	public var	maxAngular : Float = 0;
	public var	angularAcceleration : Float = 0;
	
	public var	mass : Float = 1;
	public var	elasticity : Float = 0;
	
	public var	kinematic : Bool = false;
	
	public function new(parent : FlxObject, space : FlxNapeSpace, createRectBody : Bool = true)
	{
		this.parent = parent;
		this.space = space;
		
		if (createRectBody)
		{
			napeBody = new Body(BodyType.DYNAMIC, Vec2.weak(parent.x + parent.origin.x, parent.y + parent.origin.y));
			napeBody.shapes.add(new Polygon(Polygon.rect( -parent.width / 2, -parent.height / 2, parent.width, parent.height)));
			space.add(this);
		}
		
		velocity = FlxPoint.get();
		maxVelocity = FlxPoint.get(10000,10000);
		acceleration = FlxPoint.get(0,0);
	}
	
	public function updateBody()
	{
		x = parent.x;
		FlxG.log.add(y = parent.y);
		napeBody.mass = mass;
		napeBody.position.setxy(x + parent.origin.x, y + parent.origin.y);
		napeBody.velocity.setxy(Math.max(Math.min(velocity.x,maxVelocity.x),-maxVelocity.x), Math.max(Math.min(velocity.y,maxVelocity.y),-maxVelocity.y));
		napeBody.force.setxy(acceleration.x * mass, acceleration.y * mass);
		napeBody.type = kinematic ? BodyType.KINEMATIC : BodyType.DYNAMIC;		
		
		napeBody.rotation = angle * FlxAngle.TO_RAD;

		napeBody.angularVel = angularVelocity;
	}
	
	public function updateParent()
	{
		x = parent.x = napeBody.position.x - parent.origin.x;
		y = parent.y = napeBody.position.y - parent.origin.y;
		velocity.set(napeBody.velocity.x, napeBody.velocity.y);
		angularVelocity = napeBody.angularVel;
	}
	
	public function destroy() : Void
	{
		velocity.put();
		velocity = null;
		maxVelocity.put();
		maxVelocity = null;
		acceleration.put();
		acceleration = null;
	}
}