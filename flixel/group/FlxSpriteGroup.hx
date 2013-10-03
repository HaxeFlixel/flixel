package flixel.group;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * <code>FlxSpriteGroup</code> is a special <code>FlxGroup</code>
 * that can be treated like a <code>FlxSprite</code> due to having
 * x, y and alpha values. It can only contain <code>FlxSprites</code>.
 */
class FlxSpriteGroup extends FlxGroup implements IFlxSprite
{
	/**
	 * The x position of this group.
	 */
	public var x(default, set):Float = 0;
	
	/**
	 * The y position of this group.
	 */
	public var y(default, set):Float = 0;
	
	/**
	 * The alpha value of this group.
	 */
	public var alpha(default, set):Float = 1;
	
	/**
	 * Set the angle of a sprite to rotate it. WARNING: rotating sprites decreases rendering
	 * performance for this sprite by a factor of 10x (in Flash target)!
	 */
	public var angle(default, set):Float = 0;
	
	/**
	 * Set <code>facing</code> using <code>FlxObject.LEFT</code>,<code>RIGHT</code>, <code>UP</code>, 
	 * and <code>DOWN</code> to take advantage of flipped sprites and/or just track player orientation more easily.
	 */
	public var facing(default, set):Int = 0;
	
	/**
	 * Whether an object will move/alter position after a collision.
	 */
	public var immovable(default, set):Bool = false;
	
	/**
	 * Controls the position of the sprite's hitbox. Likely needs to be adjusted after
     * changing a sprite's <code>width</code> or <code>height</code>.
	 */
	public var offset:IFlxPoint;
	
	/**
	 * WARNING: The origin of the sprite will default to its center. If you change this, 
	 * the visuals and the collisions will likely be pretty out-of-sync if you do any rotation.
	 */
	public var origin:IFlxPoint;
	
	/**
	 * Change the size of your sprite's graphic. NOTE: Scale doesn't currently affect collisions automatically, you will need to adjust the width, 
	 * height and offset manually. WARNING: scaling sprites decreases rendering performance for this sprite by a factor of 10x!
	 */
	public var scale:IFlxPoint;
	
	/**
	 * The basic speed of this object (in pixels per second).
	 */
	public var velocity:IFlxPoint;
	
	/**
	 * If you are using <code>acceleration</code>, you can use <code>maxVelocity</code> with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocity:IFlxPoint;
	
	/**
	 * How fast the speed of this object is changing (in pixels per second).
	 * Useful for smooth movement and gravity.
	 */
	public var acceleration:IFlxPoint;
	
	/**
	 * This isn't drag exactly, more like deceleration that is only applied
	 * when acceleration is not affecting the sprite.
	 */
	public var drag:IFlxPoint;
	
	/**
	 * Controls how much this object is affected by camera scrolling.
	 * 0 = no movement (e.g. a background layer), 1 = same movement speed as the foreground. Default value: 1, 1.
	 */
	public var scrollFactor:IFlxPoint;
	
	/**
	 * Optimization to allow setting position of group without transforming children twice.
	 */
	private var _skipTransformChildren:Bool = false;
	
	
	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
		offset			= new FlxPointHelper(this, offsetTransform );
		origin			= new FlxPointHelper(this, originTransform );
		scale			= new FlxPointHelper(this, scaleTransform );
		velocity		= new FlxPointHelper(this, velocityTransform );
		maxVelocity		= new FlxPointHelper(this, maxVelocityTransform );
		acceleration	= new FlxPointHelper(this, accelerationTranform );
		scrollFactor	= new FlxPointHelper(this, scrollFactorTranform );
		drag			= new FlxPointHelper(this, dragTranform );
	}
	
	override public function destroy():Void
	{
		super.destroy();
		if(offset != null)			{ offset.destroy(); offset = null; }
		if(origin != null)			{ origin.destroy(); origin = null; }
		if(scale != null)			{ scale.destroy(); scale = null; }
		if(velocity != null)		{ velocity.destroy(); velocity = null; }
		if(maxVelocity != null)		{ maxVelocity.destroy(); maxVelocity = null; }
		if(acceleration != null)	{ acceleration.destroy(); acceleration = null; }
		if(scrollFactor != null)	{ scrollFactor.destroy(); scrollFactor = null; }
		if(drag != null)			{ drag.destroy(); drag = null; }
	}
	
	/**
	 * Adds a new <code>FlxBasic</code> subclass (FlxBasic, FlxSprite, Enemy, etc) to the group.
	 * FlxGroup will try to replace a null member of the array first.
	 * Object is translated to coordinates relative to group.
	 * Failing that, FlxGroup will add it to the end of the member array,
	 * assuming there is room for it, and doubling the size of the array if necessary.
	 * WARNING: If the group has a maxSize that has already been met,
	 * the object will NOT be added to the group!
	 * @param	Object		The object you want to add to the group.
	 * @return	The same <code>FlxBasic</code> object that was passed in.
	 */
	override public function add(Basic:FlxBasic):FlxBasic
	{
		if (!Std.is(Basic, IFlxSprite))
			throw "FlxSpriteGroups can only contain objects that implement IFlxSprite.";
		
		var sprite:IFlxSprite = cast Basic;
		sprite.x += x;
		sprite.y += y;
		sprite.alpha *= alpha;
		
		return super.add(Basic);
	}
	
	public function reset(X:Float, Y:Float):Void
	{
		revive();
		setPosition(X, Y);
		
		var sprite:IFlxSprite;
		for (i in 0...length)
		{
			sprite = cast members[i];
			if (sprite != null)
			{
				sprite.reset(X, Y);
			}
		}
	}
	
	/**
	 * Helper function to set the coordinates of this object.
	 * Handy since it only requires one line of code.
	 * @param	X	The new x position
	 * @param	Y	The new y position
	 */
	public function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		// Transform children by the movement delta
		var dx:Float = X - x;
		var dy:Float = Y - y;
		multiTransformChildren([xTransform, yTransform], [dx, dy]);
		
		// don't transform children twice
		_skipTransformChildren = true;
		x = X; // this calls set_x
		y = Y; // this calls set_y
		_skipTransformChildren = false;
	}
	
	/**
	 * Handy function that allows you to quickly transform one property of sprites in this group at a time.
	 * @param 	Function 	Function to transform the sprites. Example: <code>function(s:IFlxSprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }</code>
	 * @param 	Value  		Value which will passed to lambda function
	 */
	@:generic public function transformChildren<T>(Function:IFlxSprite->T->Void, Value:T):Void
	{
		var basic:FlxBasic;
		
		for (i in 0...length)
		{
			basic = members[i];
			
			if (basic != null && basic.exists)
			{
				Function(cast basic, Value);
			}
		}
	}
	
	/**
	 * Handy function that allows you to quickly transform multiple properties of sprites in this group at a time.
	 * @param	FunctionArray	Array of functions to transform sprites in this group.
	 * @param	ValueArray		Array of values which will be passed to lambda functions
	 */
	@:generic public function multiTransformChildren<T>(FunctionArray:Array<IFlxSprite->T->Void>, ValueArray:Array<T>):Void
	{
		var numProps:Int = FunctionArray.length;
		
		if (numProps > ValueArray.length)
		{
			return;
		}
		
		var basic:FlxBasic;
		var lambda:IFlxSprite->T->Void;
		
		for (i in 0...length)
		{
			basic = members[i];
			
			if (basic != null && basic.exists)
			{
				for (j in 0...numProps)
				{
					lambda = FunctionArray[j];
					lambda(cast basic, ValueArray[j]);
				}
			}
		}
	}
	
	// PROPERTIES
	
	private function set_x(NewX:Float):Float
	{
		if (!_skipTransformChildren)
		{
			var offset:Float = NewX - x;
			transformChildren(xTransform, offset);
		}
		
		return x = NewX;
	}
	
	private function set_y(NewY:Float):Float
	{
		if (!_skipTransformChildren)
		{
			var offset:Float = NewY - y;
			transformChildren(yTransform, offset);
		}
		
		return y = NewY;
	}
	
	private function set_angle(NewAngle:Float):Float
	{
		var offset:Float = NewAngle - angle;
		transformChildren(angleTransform, offset);
		return angle = NewAngle;
	}
	
	private function set_alpha(NewAlpha:Float):Float 
	{
		if (NewAlpha > 1)  
		{
			NewAlpha = 1;
		}
		else if (NewAlpha < 0)  
		{
			NewAlpha = 0;
		}
		
		var factor:Float = (alpha > 0) ? NewAlpha / alpha : 0;
		transformChildren(alphaTransform, factor);
		return alpha = NewAlpha;
	}
	
	private function set_facing(Value:Int):Int
	{
		transformChildren(facingTransform, Value);
		return facing = Value;
	}
	
	private function set_immovable(Value:Bool):Bool
	{
		if(immovable != Value)
			transformChildren(immovableTransform, Value);
		return immovable = Value;
	}
	
	private override function set_visible(Value:Bool):Bool
	{
		if(visible != Value)
			transformChildren(visibleTransform, Value);
		return super.set_visible(Value);
	}
	
	private override function set_active(Value:Bool):Bool
	{
		if(active != Value)
			transformChildren(activeTransform, Value);
		return super.set_active(Value);
	}
	
	private override function set_alive(Value:Bool):Bool
	{
		if(alive != Value)
			transformChildren(aliveTransform, Value);
		return super.set_alive(Value);
	}
	
	private override function set_exists(Value:Bool):Bool
	{
		if (exists != Value)
			transformChildren(existsTransform, Value);
		return super.set_exists(Value);
	}
	
	// TRANSFORM FUNCTIONS - STATIC TYPING
	
	private function xTransform(Sprite:IFlxSprite, X:Float)							{ Sprite.x += X; }								// addition
	private function yTransform(Sprite:IFlxSprite, Y:Float)							{ Sprite.y += Y; }								// addition
	private function angleTransform(Sprite:IFlxSprite, Angle:Float)					{ Sprite.angle += Angle; }						// addition
	private function alphaTransform(Sprite:IFlxSprite, Alpha:Float)					{ Sprite.alpha *= Alpha; }						// multiplication
	private function facingTransform(Sprite:IFlxSprite, Facing:Int)					{ Sprite.facing = Facing; }						// set
	private function immovableTransform(Sprite:IFlxSprite, Immovable:Bool)			{ Sprite.immovable = Immovable; }				// set
	private function visibleTransform(Sprite:IFlxSprite, Visible:Bool)				{ Sprite.visible = Visible; }					// set
	private function activeTransform(Sprite:IFlxSprite, Active:Bool)				{ Sprite.active = Active; }						// set
	private function aliveTransform(Sprite:IFlxSprite, Alive:Bool)					{ Sprite.alive = Alive; }						// set
	private function existsTransform(Sprite:IFlxSprite, Exists:Bool)				{ Sprite.exists = Exists; }						// set
	private function offsetTransform(Sprite:IFlxSprite, Offset:FlxPoint)			{ Sprite.offset.copyFrom(Offset); }				// set
	private function originTransform(Sprite:IFlxSprite, Origin:FlxPoint)			{ Sprite.origin.copyFrom(Origin); }				// set
	private function scaleTransform(Sprite:IFlxSprite, Scale:FlxPoint)				{ Sprite.scale.copyFrom(Scale); }				// set
	private function velocityTransform(Sprite:IFlxSprite, Velocity:FlxPoint)		{ Sprite.velocity.copyFrom(Velocity); }			// set
	private function maxVelocityTransform(Sprite:IFlxSprite, MaxVelocity:FlxPoint)	{ Sprite.maxVelocity.copyFrom(MaxVelocity); }	// set
	private function accelerationTranform(Sprite:IFlxSprite, Acceleration:FlxPoint)	{ Sprite.acceleration.copyFrom(Acceleration); }	// set
	private function scrollFactorTranform(Sprite:IFlxSprite, ScrollFactor:FlxPoint)	{ Sprite.scrollFactor.copyFrom(ScrollFactor); }	// set
	private function dragTranform(Sprite:IFlxSprite, Drag:FlxPoint)					{ Sprite.drag.copyFrom(Drag); }					// set
}

/**
 * Helper class to make sure the FlxPoint vars of FlxSpriteGroup members
 * can be updated when the points of the FlxSpriteGroup are changed.
 * WARNING: Calling set(x, y); is MUCH FASTER than setting x, and y separately.
 */
private class FlxPointHelper extends FlxPoint
{
	private var _parent:FlxSpriteGroup;
	private var _transformFunc:IFlxSprite->FlxPoint->Void;
	
	public function new(parent:FlxSpriteGroup, transformFunc:IFlxSprite->FlxPoint->Void)
	{
		_parent = parent;
		super(0, 0);
	}
	
	inline override public function set(X:Float = 0, Y:Float = 0):FlxPointHelper
	{
		super.set(X, Y);
		_parent.transformChildren(_transformFunc, this);
		return this;
	}
	
	inline override private function set_x(Value:Float):Float
	{
		x = Value;
		_parent.transformChildren(_transformFunc, this);
		return x;
	}
	
	inline override private function set_y(Value:Float):Float
	{
		y = Value;
		_parent.transformChildren(_transformFunc, this);
		return y;
	}
	
	inline override public function destroy():Void
	{
		_parent = null;
		_transformFunc = null;
	}
}
