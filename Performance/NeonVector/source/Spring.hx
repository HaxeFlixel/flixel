package;

import flixel.math.FlxMath;

/**
 * @author Masadow
 */
class Spring
{
	public var end1:PointMass;
	public var end2:PointMass;
	public var targetLength:Float;
	public var stiffness:Float;
	public var damping:Float;
	
	public function new(End1:PointMass, End2:PointMass, Stiffness:Float, Damping:Float)
	{
		end1 = End1;
		end2 = End2;
		stiffness = Stiffness;
		damping = Damping;
		targetLength = 0.95 * FlxMath.getDistance(end1.position, end2.position);
	}
	
	public function update(elapsed:Float):Void
	{
		var _x:Float = end1.position.x - end2.position.x;
		var _y:Float = end1.position.y - end2.position.y;
		
		var _length:Float = Math.sqrt(_x * _x + _y * _y);
		// these springs can only pull, not push
		if (_length <= targetLength) return;
		
		_x = (_x / _length) * (_length - targetLength);
		_y = (_y / _length) * (_length - targetLength);
		var _dvX:Float = end2.velocity.x - end1.velocity.x;
		var _dvY:Float = end2.velocity.y - end1.velocity.y;
		var _forceX:Float = stiffness * _x - _dvX * damping;
		var _forceY:Float = stiffness * _y - _dvY * damping;
		
		end1.applyForce(-_forceX, -_forceY);
		end2.applyForce(_forceX, _forceY);
	}
}