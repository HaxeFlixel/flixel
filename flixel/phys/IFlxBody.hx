package flixel.phys;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

interface IFlxBody extends IFlxDestroyable
{
	public var 	parent : FlxObject;
	public var	space  : IFlxSpace;
	
	public var 	position : FlxPoint;
	public var 	last : FlxPoint;
	public var 	velocity : FlxPoint;
	public var	maxVelocity : FlxPoint;
	public var 	acceleration : FlxPoint;
	
	public var	angle : Float;
	public var	angularVelocity : Float;
	public var	maxAngular : Float;
	public var	angularAcceleration : Float;
	
	public var	mass : Float;
	public var	elasticity : Float;
	
	public var	kinematic : Bool;
	
	public function destroy() : Void;
}