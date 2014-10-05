package flixel.hitbox;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

//Provide a common interface for hitboxes
interface IFlxHitbox {
	//The sprite the hitbox will belong to
	public var parent : FlxSprite;
	//Not much use, going to be implemented later with FlxQuadTree. An FlxRect that contains the whole hitbox.
	public var transformedBoundingBox : FlxRect;
	
	//The testing functions for each hitbox
	public function test (Hitbox : IFlxHitbox, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool;
	public function testCircle (Circle : FlxCircle, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool;
	public function testPolygon (Polygon : FlxPolygon, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool;
	public function testHitboxList ( HitboxList : FlxHitboxList, flip : Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true) : Bool;
	public function testRay (Ray : FlxRay, rayData : FlxRayData = null, updateTransform : Bool = true) : Bool;
	
	//Update the transformed parameters according to the parent's position
	public function updateTransformed() : Void;
}