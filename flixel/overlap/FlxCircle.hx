package flixel.overlap;

import flixel.FlxSprite;
import flixel.util.FlxSignal;
import flixel.math.FlxAngle;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.geom.Matrix;

class FlxCircle implements IFlxHitbox {
	public var parent : FlxSprite;
	
	public var transformedRadius(get,null) : Float;
	public var transformedX(get,null) : Float;
	public var transformedY(get,null) : Float;
	public var transformedBoundingBox(get,null) : FlxRect;
	
	private static var _tempPoint = FlxPoint.get();
	
	private var _radius : Float;
	private var _x : Float;
	private var _y : Float;
	private var _updated = false;
	
	public function new (sprite : FlxSprite, x : Float, y : Float, radius : Float)
	{
		this.parent = sprite;
		this._x = x;
		this._y = y;
		this._radius = radius;
		transformedBoundingBox = FlxRect.get();
		
		FlxG.signals.preUpdate.add(function() { _updated = false; } );
	}
	
	public function test(hitbox : IFlxHitbox, overlapData:FlxOverlapData = null) : Bool
	{
		return hitbox.testCircle(this, true, overlapData);
	}
	
	public function testCircle(circle:FlxCircle, flip:Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		var c1 = flip ? circle : this;
		var c2 = flip ? this : circle;
		return FlxOverlap2D.testCircles(c1, c2, overlapData);
	}
	
	public function testPolygon(polygon : FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testCircleVsPolygon(this, polygon, flip, overlapData);
	}
	
	public function testHitboxList(hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testCircleVsHitboxList (this, hitboxList, flip, overlapData);
	}
	
	public function testRay(ray : FlxRay, rayData : FlxRayData = null) : Bool
	{
		return FlxOverlap2D.rayCircle(ray, this, rayData);
	}
	
	private function updateTransformed()
	{
		_updated = true;
		
		if (parent.scale.x != parent.scale.y)
			throw "Overlapping with different scales won't provide accurate results!";
		
		transformedRadius = _radius * (parent.scale.x + parent.scale.y) / 2;
		
		//Create the transform matrix
		FlxMatrix.MATRIX.identity();
		FlxMatrix.MATRIX.rotate(parent.angle * FlxAngle.TO_RAD);
		FlxMatrix.MATRIX.scale(parent.scale.x, parent.scale.y);
		FlxMatrix.MATRIX.translate(parent.x + parent.origin.x * parent.scale.x, parent.y + parent.origin.y * parent.scale.y);
		
		//Make the transform
		_tempPoint.set(_x - parent.origin.x, _y - parent.origin.y);
		_tempPoint.transform(FlxMatrix.MATRIX);
		transformedX = _tempPoint.x;
		transformedY = _tempPoint.y;
		transformedBoundingBox.set(transformedX - transformedRadius, transformedY - transformedRadius, 2 * transformedRadius, 2 * transformedRadius);
	}
	
	private inline function get_transformedX() : Float
	{
		if (_updated == false)
			updateTransformed();
		return transformedX;
	}
	
	private inline function get_transformedY() : Float
	{
		if (_updated == false)
			updateTransformed();
		return transformedY;
	}
	
	private inline function get_transformedRadius() : Float
	{
		if (_updated == false)
			updateTransformed();
		return transformedRadius;
	}
	
	private inline function get_transformedBoundingBox() : FlxRect
	{
		if (_updated == false)
			updateTransformed();
		return transformedBoundingBox;
	}
}