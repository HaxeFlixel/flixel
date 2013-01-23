package;

import nme.display.BitmapInt32;
import org.flixel.FlxG;
import org.flixel.FlxSprite;

class Boid extends FlxSprite
{
	private var _mass:Float;
	private var _position:Vector2D;
	private var _velocity:Vector2D;
	private var _maxForce:Float;
	private var _maxSpeed:Float;
	
	private var _circleRadius:Int = 6; 		// The radius of the circle
	private var _wanderAngle:Float = 0; 	// The change to the current direction. Produces sustained turned, keeps it from being jerky. Makes it smooth
	private var _wanderChange:Float = 1; 	// The amount to change the angle each frame.
	
	private var _slowingDistance:Float = 20;// Slowing distance, you can adjust this
	
	#if flash
	public function new(X:Float, Y:Float, size:Float = 10, scale:Float = 1, Color:UInt = 0xff222222)
	#elseif neko
	public function new(X:Float, Y:Float, size:Float = 10, scale:Float = 1, Color:BitmapInt32 = null)
	#else
	public function new(X:Float, Y:Float, size:Float = 10, scale:Float = 1, Color:Int = 0xff222222)
	#end
	{
		super(X, Y);
		
		#if neko
		if (Color == null)
		{
			Color = { rgb:0xff222222, a: 0xff };
		}
		#end
		
		makeGraphic(Std.int(size * scale), Std.int(size * scale), Color);
		
		maxVelocity.x = maxVelocity.y = 100;			// walking speed
		acceleration.x = acceleration.y = 400;			// gravity					
		drag.x = drag.y = maxVelocity.x * 4;			// deceleration (sliding to a stop)
		
		solid = true;
		moves = true;
		immovable = false;
		
		_mass = 2;
		_position = new Vector2D(X,Y);
		_velocity = new Vector2D();
		_maxForce = 2;
		_maxSpeed = 2;
	}
	
	override public function update():Void
	{
		super.update();
		
		// keep it witin its max speed
		_velocity.truncate(_maxSpeed);
		
		// move it
		_position = _position.add(_velocity);
		
		// keep it on screen
		if(_position.x > FlxG.width) _position.x = 0;
		if(_position.x < 0) _position.x = FlxG.width;
		if(_position.y > FlxG.height) _position.y = 0;
		if(_position.y < 0) _position.y = FlxG.height;
		
		x = _position.x;
		y = _position.y;
		
		// rotation = the velocity's angle converted to degrees
		angle = _velocity.angle * 180 / Math.PI;
	}
	
	public function seek(target:Vector2D):Void 
	{
		var desiredVelocity:Vector2D = target.subtract(_position).normalize().multiply(_maxSpeed); 
		var steeringForce:Vector2D = desiredVelocity.subtract(_velocity);
		_velocity.add(steeringForce.divide(_mass));
	}
	
	public function flee(target:Vector2D):Void
	{
		var desiredVelocity:Vector2D = target.subtract(_position).normalize().multiply(_maxSpeed);
		var steeringForce:Vector2D = desiredVelocity.subtract(_velocity);
		_velocity.add(steeringForce.divide(_mass).multiply(-1));
	}
	
	public function pursue(target:Boid):Void 
	{
		var distance:Float = target._position.distance(_position);
		var T:Float = distance / target._maxSpeed;
		var targetPosition:Vector2D = target._position.cloneVector().add(target._velocity.cloneVector().multiply(T));
		seek(targetPosition);
	}
	
	public function evade(target:Boid):Void
	{
		var distance:Float = target._position.distance(_position);
		var T:Float = distance / target._maxSpeed;
		var targetPosition:Vector2D = target._position.cloneVector().add(target._velocity.cloneVector().multiply(T));
		flee(targetPosition);
	}
	
	public function wander():Void 
	{
		var circleMiddle:Vector2D = _velocity.cloneVector().normalize().multiply(_circleRadius); //circle middle is the the velocity pushed out to the radius.
		var wanderForce:Vector2D = new Vector2D();
		wanderForce.length = 3;//force length, can be changed to get a different motion
		wanderForce.angle = _wanderAngle;//set the angle to move
		_wanderAngle += Math.random() * _wanderChange - _wanderChange * .5;//change the angle randomly to make it wander
		var force:Vector2D = circleMiddle.add(wanderForce);//apply the force
		_velocity.add(force);//then update
	}
	
	public function arrive(target:Vector2D):Void
	{
		var desiredVelocity:Vector2D = target.cloneVector().subtract(_position).normalize();//find the straight path and normalize it
		var distance:Float = _position.distance(target);//find the distance
		if(distance > _slowingDistance){//if its still too far away
			desiredVelocity.multiply(_maxSpeed);//go at full speed
		} else {
			desiredVelocity.multiply(_maxSpeed * distance/_slowingDistance);//if not, slow down
		}
		
		var force:Vector2D = desiredVelocity.subtract(_velocity).truncate(_maxForce);//keep the force within the max
		_velocity.add(force);//apply the force
	}
}