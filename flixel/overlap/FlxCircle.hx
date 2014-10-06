package flixel.overlap;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class FlxCircle implements IFlxHitbox {
	public var parent : FlxSprite;
	
	public var transformedRadius : Float;
	public var transformedX : Float;
	public var transformedY : Float;
	public var transformedBoundingBox : FlxRect;
	
	private var radius : Float;
	private var x : Float;
	private var y : Float;
	
	public function new (sprite : FlxSprite, x : Float, y : Float, radius : Float)
	{
		this.parent = sprite;
		this.x = x;
		this.y = y;
		this.radius = radius;
		transformedBoundingBox = FlxRect.get();
	}
	
	public function test(hitbox : IFlxHitbox, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return hitbox.testCircle(this, true, overlapData, updateTransforms);
	}
	
	public function testCircle(circle:FlxCircle, flip:Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		var c1 = flip ? circle : this;
		var c2 = flip ? this : circle;
		return FlxOverlap2D.testCircles(c1, c2, overlapData, updateTransforms);
	}
	
	public function testPolygon(polygon : FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testCircleVsPolygon(this, polygon, flip, overlapData, updateTransforms);
	}
	
	public function testHitboxList(hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testCircleVsHitboxList (this, hitboxList, flip, overlapData, updateTransforms);
	}
	
	public function testRay(ray : FlxRay, rayData : FlxRayData = null, updateTransform : Bool = true) : Bool
	{
		return FlxOverlap2D.rayCircle(ray, this, rayData, updateTransform);
	}
	
	public function updateTransformed()
	{
		if (parent.scale.x != parent.scale.y)
			throw "Overlapping with different scales won't provide accurate results!";
		
		transformedRadius = radius * (parent.scale.x + parent.scale.y) / 2;
		
		//Create the transform matrix
		var transformMatrix = new FlxMatrix();
		transformMatrix.rotate(parent.angle * FlxAngle.TO_RAD);
		transformMatrix.scale(parent.scale.x, parent.scale.y);
		transformMatrix.translate(parent.x + parent.origin.x * parent.scale.x, parent.y + parent.origin.y * parent.scale.y);
		
		//Make the transform
		var tempPoint = FlxPoint.get(x - parent.origin.x, y - parent.origin.y);
		tempPoint.transform(transformMatrix);
		transformedX = tempPoint.x;
		transformedY = tempPoint.y;
		transformedBoundingBox.set(transformedX - transformedRadius, transformedY - transformedRadius, 2 * transformedRadius, 2 * transformedRadius);
	}
	
	public function destroy()
	{
		transformedBoundingBox.put();
		transformedBoundingBox = null;
	}
}