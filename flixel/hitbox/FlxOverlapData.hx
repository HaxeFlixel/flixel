package flixel.hitbox;

import flixel.math.FlxVector;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class FlxOverlapData{
	
        /** the overlap amount */
    public var overlap : Float = 0; 
        /** a vector that when subtracted to shape 1 will separate it from shape 2 */
    public var separation : FlxVector;
    
        /** the first shape */
    public var hitbox1 : IFlxHitbox;
        /** the second shape */
    public var hitbox2 : IFlxHitbox;
        /** unit vector on the axis of the collision (the normal of the face that was collided with) */
    public var unitVector : FlxVector; 
    
	public function copyFrom(other : FlxOverlapData) : FlxOverlapData
	{
		overlap = other.overlap;
		separation = FlxVector.get(other.separation.x,other.separation.y);
		hitbox1 = other.hitbox1;
		hitbox2 = other.hitbox2;
		unitVector = FlxVector.get(other.unitVector.x,other.unitVector.y);
		
		return this;
	}
}