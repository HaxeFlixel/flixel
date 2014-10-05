package flixel.hitbox;
import flixel.FlxSprite;
import flixel.math.FlxRect;

class FlxHitboxList implements IFlxHitbox
{
	
	//TODO : Implement bounding box
	public var transformedBoundingBox : FlxRect;
	public var parent : FlxSprite;
	public var members : Array<IFlxHitbox>;
	
	public function new(Sprite : FlxSprite, Hitboxes : Array <IFlxHitbox>)
	{
		parent = Sprite;
		members = Hitboxes;
	}
	
	public function test (Hitbox : IFlxHitbox, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return Hitbox.testHitboxList(this, true, overlapData, updateTransforms);
	}
	
	public function testCircle (circle : FlxCircle, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testCircleVsHitboxList(circle, this, flip, overlapData, updateTransforms);
	}
	
	public function testPolygon (polygon : FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testPolygonVsHitboxList(polygon, this, flip, overlapData, updateTransforms);
	}
	
	public function testHitboxList ( hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		return FlxOverlap2D.testHitboxLists( this, hitboxList, flip, overlapData, updateTransforms);
	}
	public function testRay (Ray : FlxRay, rayData : FlxRayData = null, updateTransform : Bool = true) : Bool
	{
		return FlxOverlap2D.rayHitboxList(Ray, this, rayData, updateTransform);
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