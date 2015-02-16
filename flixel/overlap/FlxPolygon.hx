package flixel.overlap;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import openfl.geom.Matrix;
import openfl.geom.Point;
import flixel.math.FlxMatrix;


class FlxPolygon implements IFlxHitbox {
	public var parent : FlxSprite;
	
	public var transformedVertices(get,null) : Array<FlxVector>;
	public var transformedBoundingBox(get,null) : FlxRect;
	
	private var _vertices : Array<FlxVector>;
	//Used for the bounding box, this is the max distance between the sprite's origin and the vertices
	private var _maxDistance : Float = 0;
	private var _updated = false;
	
	public function new(sprite : FlxSprite, vertices : Array<FlxPoint>)
	{
		this.parent = sprite;
		
		var maxSquaredDistance : Float = 0;
		this.transformedVertices = new Array<FlxVector>();
		
		this._vertices = new Array<FlxVector>();
		var tempArray = new Array<FlxVector>();
		
		for (i in 0...vertices.length)
		{	
			this._vertices[i] = FlxVector.get(vertices[i].x, vertices[i].y);
			
			tempArray[i] = FlxVector.get();
			
			var squaredDistance = ((vertices[i].x - parent.origin.x) * (vertices[i].x - parent.origin.x) + (vertices[i].y - parent.origin.y) * (vertices[i].y - parent.origin.y));
			if (squaredDistance > maxSquaredDistance)
				maxSquaredDistance = squaredDistance;
		}
		
		if (vertices.length == 2)
		{
			//Add a little padding to make it a triangle
			var temp = FlxVector.get(-(_vertices[1].y - _vertices[0].y), _vertices[1].x - _vertices[0].x);
            temp.truncate(0.0000000001);
            _vertices[2] = _vertices[1].clone().addVector(temp);
			tempArray[2] = FlxVector.get();
			temp.put();
		}
		
		transformedVertices = tempArray;
		
		this._maxDistance = Math.sqrt(maxSquaredDistance);
		transformedBoundingBox = FlxRect.get();
		
		FlxG.signals.preUpdate.add(function() { _updated = false; } );
	}
	
	public function test(hitbox : IFlxHitbox, overlapData:FlxOverlapData = null) : Bool
	{
		return hitbox.testPolygon(this, true, overlapData);
	}
	
	public function testCircle(circle:FlxCircle, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testCircleVsPolygon(circle, this, flip, overlapData);
	}
	
	public function testPolygon(polygon:FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testPolygons(this, polygon, flip, overlapData);
	}
	
	public function testHitboxList (hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testPolygonVsHitboxList(this, hitboxList, flip, overlapData);
	}
	
	public function testRay(ray : FlxRay, rayData : FlxRayData = null) : Bool
	{
		return FlxOverlap2D.rayPolygon(ray, this, rayData);
	}
	
	private function updateTransformed()
	{
		_updated = true;
		
		FlxMatrix.matrix.identity();
		FlxMatrix.matrix.rotate(parent.angle * FlxAngle.TO_RAD);
		FlxMatrix.matrix.scale(parent.scale.x, parent.scale.y);
		FlxMatrix.matrix.translate(parent.x + parent.origin.x, parent.y + parent.origin.y);
		
		for (i in 0..._vertices.length)
		{
			transformedVertices[i].x = _vertices[i].x - parent.origin.x;
			transformedVertices[i].y = _vertices[i].y - parent.origin.y;
			
			transformedVertices[i].transform(FlxMatrix.matrix);
		}
			
		//Create the bounding box
		transformedBoundingBox.set(parent.x + (parent.origin.x - _maxDistance) * parent.scale.x, parent.y + (parent.origin.y - _maxDistance) * parent.scale.y, 2 * _maxDistance * parent.scale.x, 2 * _maxDistance * parent.scale.y);
	}
	
	private inline function get_transformedVertices()
	{
		if (_updated == false)
			updateTransformed();
		return transformedVertices;
	}
	
	private inline function get_transformedBoundingBox()
	{
		if (_updated == false)
			updateTransformed();
		return transformedBoundingBox;
	}
}