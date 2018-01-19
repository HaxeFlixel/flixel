package;

import flixel.FlxSprite;
import flixel.math.FlxVector;

/**
 * A colored circle object, used as the targets in the game.
 * @author MSGHero
 */
class Circle
{
	public var center:FlxVector;
	public var radius:Float;
	public var color:Color;
	
	public var graphic:FlxSprite;
	
	public function new(center:FlxVector, radius:Float, color:Color)
	{
		this.center = center;
		this.radius = radius;
		this.color = color;
	}
	
	public function intersectingSegment(segment:Segment):FlxVector
	{
		// circle-segment intersection algorithm
		var closest:FlxVector = null;
		var proj = center.subtractNew(segment.start).dotProdWithNormalizing(segment.vector);
		
		if (proj < 0) closest = segment.start.clone();
		else if (proj > segment.vector.length) closest = segment.getEnd();
		else closest = segment.start.addNew(segment.vector.clone().normalize().scale(proj));
		
		closest.subtractPoint(center);
		
		if (closest.lengthSquared >= radius * radius) closest.set(Math.NaN, Math.NaN);
		
		closest.addPoint(center);
		
		return closest;
	}
	
	public function intersectingCircle(circle:Circle):Bool
	{
		// circle-circle intersection algorithm
		var dist2 = center.subtractNew(circle.center).lengthSquared;
		return dist2 < (radius + circle.radius) * (radius + circle.radius);
	}
}