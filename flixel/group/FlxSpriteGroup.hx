package flixel.group;

import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * <code>FlxSpriteGroup</code> is a special <code>FlxGroup</code>
 * that can be treated like a <code>FlxSprite</code> due to having
 * x, y and alpha values. It can only contain <code>FlxSprites</code>.
 */
class FlxSpriteGroup extends FlxTypedGroup<IFlxSprite> implements IFlxSprite
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
		offset.destroy(); offset = null;
		origin.destroy(); origin = null;
		scale.destroy(); scale = null;
		velocity.destroy(); velocity = null;
		maxVelocity.destroy(); maxVelocity = null;
		acceleration.destroy(); acceleration = null;
		scrollFactor.destroy(); scrollFactor = null;
		drag.destroy(); drag = null;
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
	override public function add(Sprite:IFlxSprite):IFlxSprite
	{
		Sprite.x += x;
		Sprite.y += y;
		Sprite.alpha += alpha;
		
		if (Std.is(Sprite, FlxSprite))
		{
			return super.add(cast(Sprite, FlxSprite));
		}
		else if (Std.is(Sprite, FlxSpriteGroup))
		{
			return super.add(cast(Sprite, FlxSpriteGroup));
		}
		
		throw "Unsupported type of object. Please extend FlxSpriteGroup class and override its 'add' method to support it.";
		return null;
	}
	
	public function reset(X:Float, Y:Float):Void
	{
		revive();
		setPosition(X, Y);
		
		var sprite:IFlxSprite;
		for (i in 0...length)
		{
			sprite = members[i];
			
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
	@:generic public function transformChildren<T>(Function:FlxSprite->T->Void, Value:T):Void
	{
		var sprite:FlxSprite;
		
		for (i in 0...length)
		{
			sprite = cast members[i];
			
			if (sprite != null && sprite.exists)
			{
				Function(sprite, Value);
			}
		}
	}
	
	/**
	 * Handy function that allows you to quickly transform multiple properties of sprites in this group at a time.
	 * @param	FunctionArray	Array of functions to transform sprites in this group.
	 * @param	ValueArray		Array of values which will be passed to lambda functions
	 */
	@:generic public function multiTransformChildren<T>(FunctionArray:Array<FlxSprite->T->Void>, ValueArray:Array<T>):Void
	{
		var numProps:Int = FunctionArray.length;
		
		if (numProps > ValueArray.length)
		{
			return;
		}
		
		var sprite:FlxSprite;
		var lambda:FlxSprite->T->Void;
		
		for (i in 0...length)
		{
			sprite = cast members[i];
			
			if (sprite != null && sprite.exists)
			{
				for (j in 0...numProps)
				{
					lambda = FunctionArray[j];
					lambda(sprite, ValueArray[j]);
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
	
	private function set_angle(Value:Float):Float
	{
		transformChildren(angleTransform, Value);
		return angle = Value;
	}
	
	private function set_alpha(NewAlpha:Float):Float 
	{
		alpha = NewAlpha;
		
		if (alpha > 1)  
		{
			alpha = 1;
		}
		else if (alpha < 0)  
		{
			alpha = 0;
		}
		
		if (!_skipTransformChildren)
		{
			transformChildren(alphaTransform, alpha);
		}
		
		return NewAlpha;
	}
	
	private function set_facing(Value:Int):Int
	{
		transformChildren(facingTransform, Value);
		return facing = Value;
	}
	
	private function set_immovable(Value:Bool):Bool
	{
		transformChildren(immovableTransform, Value);
		return immovable = Value;
	}
	
	// TRANSFORM FUNCTIONS - STATIC TYPING
	
	private function xTransform(Sprite:FlxSprite, X:Float)							{ Sprite.x += X; }								// addition
	private function yTransform(Sprite:FlxSprite, Y:Float)							{ Sprite.y += Y; }								// addition
	private function angleTransform(Sprite:FlxSprite, Angle:Float)					{ Sprite.angle += Angle; }						// addition
	private function alphaTransform(Sprite:FlxSprite, Alpha:Float)					{ Sprite.alpha += Alpha; }						// addition
	private function facingTransform(Sprite:FlxSprite, Facing:Int)					{ Sprite.facing = Facing; }						// set
	private function immovableTransform(Sprite:FlxSprite, Immovable:Bool)			{ Sprite.immovable = Immovable; }				// set
	private function offsetTransform(Sprite:FlxSprite, Offset:FlxPoint)				{ Sprite.offset.copyFrom(Offset); }				// set
	private function originTransform(Sprite:FlxSprite, Origin:FlxPoint)				{ Sprite.origin.copyFrom(Origin); }				// set
	private function scaleTransform(Sprite:FlxSprite, Scale:FlxPoint)				{ Sprite.scale.copyFrom(Scale); }				// set
	private function velocityTransform(Sprite:FlxSprite, Velocity:FlxPoint)			{ Sprite.velocity.copyFrom(Velocity); }			// set
	private function maxVelocityTransform(Sprite:FlxSprite, MaxVelocity:FlxPoint)	{ Sprite.maxVelocity.copyFrom(MaxVelocity); }	// set
	private function accelerationTranform(Sprite:FlxSprite, Acceleration:FlxPoint)	{ Sprite.acceleration.copyFrom(Acceleration); }	// set
	private function scrollFactorTranform(Sprite:FlxSprite, ScrollFactor:FlxPoint)	{ Sprite.scrollFactor.copyFrom(ScrollFactor); }	// set
	private function dragTranform(Sprite:FlxSprite, Drag:FlxPoint)					{ Sprite.drag.copyFrom(Drag); }					// set
}

/**
 * Helper class to make sure the FlxPoint vars of FlxSpriteGroup members
 * can be updated when the points of the FlxSpriteGroup are changed.
 * WARNING: Calling set(x, y); is MUCH FASTER than setting x, and y separately.
 */
private class FlxPointHelper extends FlxPoint
{
	private var _parent:FlxSpriteGroup;
	private var _transformFunc:FlxSprite->FlxPoint->Void;
	
	public function new(parent:FlxSpriteGroup, transformFunc:FlxSprite->FlxPoint->Void)
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
