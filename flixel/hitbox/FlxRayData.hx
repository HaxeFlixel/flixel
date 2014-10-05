package flixel.hitbox;

class FlxRayData {
	
	/**
	 * shape the intersection was with.
	 */
	public var hitbox:IFlxHitbox;
	public var ray:FlxRay;
	
	/**
	 * distance along ray that the intersection occurred at divided by the length of the ray (so start is always 0<=start<=1 if the ray is not inFinite )
	 */
	public var start:Float;
	public var end:Float;
	
	public function new() { }
}
