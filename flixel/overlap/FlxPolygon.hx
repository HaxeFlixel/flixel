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
	
	private var vertices : Array<FlxVector>;
	//Used for the bounding box, this is the max distance between the sprite's origin and the vertices
	private var maxDistance : Float = 0;
	
	public var transformedVertices : Array<FlxVector>;
	public var transformedBoundingBox : FlxRect;
	
	public function new(sprite : FlxSprite, vertices : Array<FlxPoint>)
	{
		if (vertices.length == 2)
			throw "There are possibly bugs with this, don't use 2 vertices with Polygon";
		this.parent = sprite;
		
		var maxSquaredDistance : Float = 0;
		this.transformedVertices = new Array<FlxVector>();
		
		this.vertices = new Array<FlxVector>();
		
		for (i in 0...vertices.length)
		{	
			this.vertices[i] = FlxVector.get(vertices[i].x, vertices[i].y);
			
			transformedVertices[i] = FlxVector.get();
			
			var squaredDistance = ((vertices[i].x - parent.origin.x) * (vertices[i].x - parent.origin.x) + (vertices[i].y - parent.origin.y) * (vertices[i].y - parent.origin.y));
			if (squaredDistance > maxSquaredDistance)
				maxSquaredDistance = squaredDistance;
		}
		maxDistance = Math.sqrt(maxSquaredDistance);
		transformedBoundingBox = FlxRect.get();
	}
	
	public function test(hitbox : IFlxHitbox, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return hitbox.testPolygon(this, true, overlapData, updateTransforms);
	}
	
	public function testCircle(circle:FlxCircle, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testCircleVsPolygon(circle, this, flip, overlapData, updateTransforms);
	}
	
	public function testPolygon(polygon:FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testPolygons(this, polygon, flip, overlapData, updateTransforms);
	}
	
	public function testHitboxList (hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testPolygonVsHitboxList(this, hitboxList, flip, overlapData, updateTransforms);
	}
	
	public function testRay(ray : FlxRay, rayData : FlxRayData = null, updateTransform : Bool = true) : Bool
	{
		return FlxOverlap2D.rayPolygon(ray, this, rayData, updateTransform);
	}
	
	public function updateTransformed()
	{
		var transMatrix = new FlxMatrix();
		transMatrix.rotate(parent.angle * FlxAngle.TO_RAD);
		transMatrix.scale(parent.scale.x, parent.scale.y);
		transMatrix.translate(parent.x + parent.origin.x, parent.y + parent.origin.y);
		
		for (i in 0...vertices.length)
		{
			transformedVertices[i].x = vertices[i].x - parent.origin.x;
			transformedVertices[i].y = vertices[i].y - parent.origin.y;
			
			transformedVertices[i].transform(transMatrix);
		}
			
		//Create the bounding box
		transformedBoundingBox.set(parent.x + (parent.origin.x - maxDistance) * parent.scale.x, parent.y + (parent.origin.y - maxDistance) * parent.scale.y, 2 * maxDistance * parent.scale.x, 2 * maxDistance * parent.scale.y);
	}
}