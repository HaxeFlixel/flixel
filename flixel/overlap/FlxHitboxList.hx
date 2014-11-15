package flixel.overlap;
import flixel.FlxSprite;
import flixel.math.FlxRect;

class FlxHitboxList implements IFlxHitbox
{
	
	//TODO : Implement bounding box
	public var transformedBoundingBox(get,null) : FlxRect;
	public var parent : FlxSprite;
	public var members : Array<IFlxHitbox>;
	
	public function new(sprite : FlxSprite, hitboxes : Array <IFlxHitbox>)
	{
		this.parent = sprite;
		this.members = hitboxes;
	}
	
	public function test (hitbox : IFlxHitbox, overlapData:FlxOverlapData = null) : Bool
	{
		return hitbox.testHitboxList(this, true, overlapData);
	}
	
	public function testCircle (circle : FlxCircle, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testCircleVsHitboxList(circle, this, flip, overlapData);
	}
	
	public function testPolygon (polygon : FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testPolygonVsHitboxList(polygon, this, flip, overlapData);
	}
	
	public function testHitboxList (hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool
	{
		return FlxOverlap2D.testHitboxLists(this, hitboxList, flip, overlapData);
	}
	public function testRay (ray : FlxRay, rayData : FlxRayData = null) : Bool
	{
		return FlxOverlap2D.rayHitboxList(ray, this, rayData);
	}
	
	public function get_transformedBoundingBox()
	{
		return transformedBoundingBox;
	}
}