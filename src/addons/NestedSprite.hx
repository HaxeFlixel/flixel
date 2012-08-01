package addons;

import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxU;

/**
 * ...
 * @author Zaphod
 */

class NestedSprite extends FlxSprite
{
	private static var _degToRad:Float = Math.PI / 180;
	
	/**
	 * List of all nested sprites
	 */
	private var _children:Array<NestedSprite>;
	
	/**
	 * Position of this sprite relative to parent.
	 * By default it is equal to (0, 0)
	 */
	public var relativeX:Float;
	public var relativeY:Float;
	
	/**
	 * Angle of this sprite relative to parent
	 */
	public var relativeAngle:Float;
	
	/**
	 * Scale of this sprite relative to parent
	 */
	public var relativeScaleX:Float;
	public var relativeScaleY:Float;
	
	/**
	 * Velocities relative to parent sprite
	 */
	public var relativeVelocityX:Float;
	public var relativeVelocityY:Float;
	public var relativeAngularVelocity:Float;
	
	/**
	 * Accelerations relative to parent sprite
	 */
	public var relativeAccelerationX:Float;
	public var relativeAccelerationY:Float;
	public var relativeAngularAcceleration:Float;
	
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:Dynamic = null) 
	{
		super(X, Y, SimpleGraphic);
		
		_children = [];
		relativeX = 0;
		relativeY = 0;
		relativeAngle = 0;
		relativeScaleX = 1;
		relativeScaleY = 1;
		
		relativeVelocityX = 0;
		relativeVelocityY = 0;
		relativeAngularVelocity = 0;
		
		relativeAccelerationX = 0;
		relativeAccelerationY = 0;
		relativeAngularAcceleration = 0;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		for (child in _children)
		{
			child.destroy();
		}
		
		_children = null;
	}
	
	/**
	 * Adds the FlxSprite to the children list.
	 * @param	graphic		The FlxSprite to add.
	 * @return	The added FlxSprite.
	 */
	public function add(Child:NestedSprite):NestedSprite
	{
		if (FlxU.ArrayIndexOf(_children, Child) < 0)
		{
			_children.push(Child);
			Child.velocity.x = Child.velocity.y = 0;
			Child.acceleration.x = Child.acceleration.y = 0;
			Child.scrollFactor.x = this.scrollFactor.x;
			Child.scrollFactor.y = this.scrollFactor.y;
		}
		
		return Child;
	}
	
	/**
	 * Removes the FlxSprite from the children list.
	 * @param	graphic		The FlxSprite to remove.
	 * @return	The removed FlxSprite.
	 */
	public function remove(Child:NestedSprite):NestedSprite
	{
		var index:Int = FlxU.ArrayIndexOf(_children, Child);
		if (index >= 0)
		{
			_children.splice(index, 1);
		}
		
		return Child;
	}
	
	/**
	 * Removes the FlxSprite from the position in the children list.
	 * @param	index		Index to remove.
	 */
	public function removeAt(Index:Int = 0):NestedSprite
	{
		if (_children.length < Index || Index < 0)
		{
			return null;
		}
		
		var child:NestedSprite = _children[Index];
		_children.splice(Index, 1);
		return child;
	}
	
	/**
	 * Removes all children sprites from this sprite.
	 */
	public function removeAll():Void
	{
		var l:Int = _children.length - 1;
		var i:Int = l;
		while (i >= 0)
		{
			removeAt(i);
			i--;
		}
	}
	
	/**
	 * All Graphics in this list.
	 */
	public var children(getChildren, null):Array<NestedSprite>;
	private function getChildren():Array<NestedSprite> 
	{ 
		return _children; 
	}
	
	/**
	 * Amount of Graphics in this list.
	 */
	public var count(getCount, null):Int;
	private function getCount():Int 
	{ 
		return _children.length; 
	}
	
	override public function preUpdate():Void 
	{
		super.preUpdate();
		
		for (child in _children)
		{
			child.preUpdate();
		}
	}
	
	override public function update():Void 
	{
		super.update();
		
		for (child in _children)
		{
			child.update();
		}
	}
	
	override public function postUpdate():Void 
	{
		super.postUpdate();
		
		for (child in _children)
		{
			child.velocity.x = child.velocity.y = 0;
			child.acceleration.x = child.acceleration.y = 0;
			child.angularVelocity = child.angularAcceleration = 0;
			child.postUpdate();
			
			if (this.simpleRender)
			{
				child.x = this.x + child.relativeX - this.offset.x;
				child.y = this.y + child.relativeY - this.offset.y;
			}
			else
			{
				var radians:Float = this.angle * _degToRad;
				var cos:Float = Math.cos(radians);
				var sin:Float = Math.sin(radians);
				
				var dx:Float = child.relativeX - this.offset.x;
				var dy:Float = child.relativeY - this.offset.y;
				
				var relX:Float = (dx * cos * this.scale.x - dy * sin * this.scale.y);
				var relY:Float = (dx * sin * this.scale.x + dy * cos * this.scale.y);
				
				child.x = this.x + relX;
				child.y = this.y + relY;
			}
			
			child.angle = this.angle + child.relativeAngle;
			child.scale.x = this.scale.x * child.relativeScaleX;
			child.scale.y = this.scale.y * child.relativeScaleY;
			
			child.velocity.x = this.velocity.x;
			child.velocity.y = this.velocity.y;
			child.acceleration.x = this.acceleration.x;
			child.acceleration.y = this.acceleration.y;
		}
	}
	
	override private function updateMotion():Void 
	{
		super.updateMotion();
		
		var delta:Float;
		var velocityDelta:Float;
		var dt:Float = FlxG.elapsed;
		
		velocityDelta = 0.5 * (FlxU.computeVelocity(relativeAngularVelocity, relativeAngularAcceleration, angularDrag, maxAngular) - relativeAngularVelocity);
		relativeAngularVelocity += velocityDelta; 
		relativeAngle += relativeAngularVelocity * dt;
		relativeAngularVelocity += velocityDelta;
		
		velocityDelta = 0.5 * (FlxU.computeVelocity(relativeVelocityX, relativeAccelerationX, drag.x, maxVelocity.x) - relativeVelocityX);
		relativeVelocityX += velocityDelta;
		delta = relativeVelocityX * dt;
		relativeVelocityX += velocityDelta;
		relativeX += delta;
		
		velocityDelta = 0.5 * (FlxU.computeVelocity(relativeVelocityY, relativeAccelerationY, drag.y, maxVelocity.y) - relativeVelocityY);
		relativeVelocityY += velocityDelta;
		delta = relativeVelocityY * dt;
		relativeVelocityY += velocityDelta;
		relativeY += delta;
	}
	
	override public function draw():Void 
	{
		super.draw();
		
		for (child in _children)
		{
			child.draw();
		}
	}
	
}