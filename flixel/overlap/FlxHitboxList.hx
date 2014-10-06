package flixel.overlap;
import flixel.FlxSprite;
import flixel.math.FlxRect;

class FlxHitboxList implements IFlxHitbox
{
	
	//TODO : Implement bounding box
	public var transformedBoundingBox : FlxRect;
	public var parent : FlxSprite;
	public var members : Array<IFlxHitbox>;
	
	public function new(sprite : FlxSprite, hitboxes : Array <IFlxHitbox>)
	{
		this.parent = sprite;
		this.members = hitboxes;
	}
	
	public function test (hitbox : IFlxHitbox, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return hitbox.testHitboxList(this, true, overlapData, updateTransforms);
	}
	
	public function testCircle (circle : FlxCircle, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testCircleVsHitboxList(circle, this, flip, overlapData, updateTransforms);
	}
	
	public function testPolygon (polygon : FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testPolygonVsHitboxList(polygon, this, flip, overlapData, updateTransforms);
	}
	
	public function testHitboxList (hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testHitboxLists(this, hitboxList, flip, overlapData, updateTransforms);
	}
	public function testRay (ray : FlxRay, rayData : FlxRayData = null, updateTransform : Bool = true) : Bool
	{
		return FlxOverlap2D.rayHitboxList(ray, this, rayData, updateTransform);
	}
	
	public function updateTransformed() : Void
	{
		for (hitbox in members)
		{
			if (hitbox != this)
			{
				hitbox.parent = parent;
				hitbox.updateTransformed();
			}
		}
	}
}