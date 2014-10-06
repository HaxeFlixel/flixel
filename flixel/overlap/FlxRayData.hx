package flixel.overlap;

class FlxRayData {
	
	/**
	 * shape the intersection was with.
	 */
	public var hitbox:IFlxHitbox;
	public var ray:FlxRay;
	
	/**
	 * distance along ray that the intersection occurred at.
	 */
	public var start:Float;
	public var end:Float;
	
	public function new() { }
}