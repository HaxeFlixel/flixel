package flixel.overlap;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

//Provide a common interface for hitboxes
interface IFlxHitbox {
	//The sprite the hitbox will belong to
	public var parent : FlxSprite;
	//Not much use, going to be implemented later with FlxQuadTree. An FlxRect that contains the whole hitbox.
	public var transformedBoundingBox(get,null) : FlxRect;
	
	//The testing functions for each hitbox
	public function test (hitbox : IFlxHitbox, overlapData:FlxOverlapData = null) : Bool;
	public function testCircle (circle : FlxCircle, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool;
	public function testPolygon (polygon : FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool;
	public function testHitboxList (hitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null) : Bool;
	public function testRay (ray : FlxRay, rayData : FlxRayData = null) : Bool;
}