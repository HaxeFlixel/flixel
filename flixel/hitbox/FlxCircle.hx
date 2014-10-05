package flixel.hitbox;

import flixel.FlxSprite;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class FlxCircle implements IFlxHitbox {
	public var parent : FlxSprite;
	
	private var radius : Float;
	private var x : Float;
	private var y : Float;
	
	public var transformedRadius : Float;
	public var transformedX : Float;
	public var transformedY : Float;
	public var transformedBoundingBox : FlxRect;
	
	
	public function new (Sprite : FlxSprite, X : Float, Y : Float, Radius : Float)
	{
		parent = Sprite;
		x = X;
		y = Y;
		radius = Radius;
		transformedBoundingBox = FlxRect.get();
	}
	
	public function test(Hitbox : IFlxHitbox, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return Hitbox.testCircle(this, true, overlapData, updateTransforms);
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
	
	public function testHitboxList ( HitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testCircleVsHitboxList (this, HitboxList, flip, overlapData, updateTransforms);
	}
	
	public function testRay(ray : FlxRay, rayData : FlxRayData = null, updateTransform : Bool = true):Bool
	{
		return FlxOverlap2D.rayCircle(ray, this, rayData, updateTransform);
	}
	
	public function updateTransformed()
	{
		if (parent.scale.x != parent.scale.y)
			throw "Can't overlap with different scales";
		
		transformedRadius = radius * (parent.scale.x + parent.scale.y) / 2;
		
		//Create the transform matrix
		var transformMatrix = new FlxMatrix();
		transformMatrix.rotate(-parent.angle);
		transformMatrix.scale(parent.scale.x, parent.scale.y);
		transformMatrix.makeTranslation(parent.x + parent.origin.x * parent.scale.x, parent.y + parent.origin.y * parent.scale.y);
		
		//Make the transform
		var tempPoint = transformMatrix.transformPoint(FlxPoint.get(x - parent.origin.x, y - parent.origin.y));
		transformedX = tempPoint.x;
		transformedY = tempPoint.y;
		transformedBoundingBox.set(transformedX - transformedRadius, transformedY - transformedRadius, 2 * transformedRadius, 2 * transformedRadius);
	}
}