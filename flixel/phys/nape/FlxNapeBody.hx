package flixel.phys.nape;

import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.phys.IFlxBody;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import flixel.math.FlxPoint;
import nape.phys.BodyType;
import nape.phys.Material;
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
	
	public var  collisionGroup : Int;
	public var  collisionMask  : Int;
	
	public var	mass : Float = 1;
	public var	elasticity : Float = 0;
	
	public var	kinematic : Bool = false;
	
	private var _filter : InteractionFilter;
	private var _material : Material;
	
	public function new(parent : FlxObject, createRectBody : Bool = true)
	{
		this.parent = parent;
		
		if (createRectBody)
		{
			napeBody = new Body(BodyType.DYNAMIC, Vec2.weak(parent.x + parent.origin.x, parent.y + parent.origin.y));
			napeBody.shapes.add(new Polygon(Polygon.rect( -parent.width / 2, -parent.height / 2, parent.width, parent.height)));
		}
		
		_filter = new InteractionFilter();
		_material = new Material();
		
		velocity = FlxPoint.get();
		maxVelocity = FlxPoint.get(10000,10000);
		acceleration = FlxPoint.get(0,0);
	}
	
	public function updateBody()
	{
		x = parent.x;
		y = parent.y;
		napeBody.mass = mass;
		napeBody.position.setxy(x + parent.origin.x, y + parent.origin.y);
		napeBody.velocity.setxy(Math.max(Math.min(velocity.x,maxVelocity.x),-maxVelocity.x), Math.max(Math.min(velocity.y,maxVelocity.y),-maxVelocity.y));
		napeBody.force.setxy(acceleration.x * mass, acceleration.y * mass);
		napeBody.type = kinematic ? BodyType.KINEMATIC : BodyType.DYNAMIC;
		
		_filter.collisionGroup = collisionGroup;
		_filter.collisionMask = collisionMask;
		napeBody.setShapeFilters(_filter);
		
		_material.elasticity = elasticity;
		napeBody.setShapeMaterials(_material);
		
		napeBody.rotation = angle * FlxAngle.TO_RAD;

		napeBody.angularVel = angularVelocity * FlxAngle.TO_RAD;
	}
	
	public function updateParent()
	{
		x = parent.x = napeBody.position.x - parent.origin.x;
		y = parent.y = napeBody.position.y - parent.origin.y;
		angle = parent.angle = napeBody.rotation * FlxAngle.TO_DEG;
		velocity.set(napeBody.velocity.x, napeBody.velocity.y);
		angularVelocity = napeBody.angularVel * FlxAngle.TO_DEG;
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