package flixel.addons;

import flash.geom.ColorTransform;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxArray;
import flixel.util.FlxMath;

/**
 * Some sort of DisplayObjectContainer but very limited.
 * It can contain only other <code>FlxNestedSprites</code>.
 * @author Zaphod
 */
class FlxNestedSprite extends FlxSprite
{
	/**
	 * X position of this sprite relative to parent, 0 by default
	 */
	public var relativeX:Float;
	/**
	 * Y position of this sprite relative to parent, 0 by default
	 */
	public var relativeY:Float;
	
	/**
	 * Angle of this sprite relative to parent
	 */
	public var relativeAngle:Float;
	
	/**
	 * X scale of this sprite relative to parent
	 */
	public var relativeScaleX:Float;
	/**
	 * Y scale of this sprite relative to parent
	 */
	public var relativeScaleY:Float;
	
	/**
	 * X velocity relative to parent sprite
	 */
	public var relativeVelocityX:Float;
	/**
	 * Y velocity relative to parent sprite
	 */
	public var relativeVelocityY:Float;
	/**
	 * Angular velocity relative to parent sprite
	 */
	public var relativeAngularVelocity:Float;
	
	/**
	 * X acceleration relative to parent sprite
	 */
	public var relativeAccelerationX:Float;
	/**
	 * Y acceleration relative to parent sprite
	 */
	public var relativeAccelerationY:Float;
	/**
	 * Angular acceleration relative to parent sprite
	 */
	public var relativeAngularAcceleration:Float;
	
	public var _parentAlpha:Float = 1;
	public var _parentRed:Float = 1;
	public var _parentGreen:Float = 1;
	public var _parentBlue:Float = 1;
	
	/**
	 * List of all nested sprites
	 */
	private var _children:Array<FlxNestedSprite>;
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic) 
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
	
	/**
	 * WARNING: This will remove this sprite entirely. Use <code>kill()</code> if you 
	 * want to disable it temporarily only and <code>reset()</code> it later to revive it.
	 * Used to clean up memory.
	 */
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
	 * Adds the <code>FlxNestedSprite</code> to the children list.
	 * @param	Child	The <code>FlxNestedSprite</code> to add.
	 * @return	The added <code>FlxNestedSprite</code>.
	 */
	public function add(Child:FlxNestedSprite):FlxNestedSprite
	{
		if (FlxArray.indexOf(_children, Child) < 0)
		{
			_children.push(Child);
			Child.velocity.x = Child.velocity.y = 0;
			Child.acceleration.x = Child.acceleration.y = 0;
			Child.scrollFactor.x = scrollFactor.x;
			Child.scrollFactor.y = scrollFactor.y;
			
			Child._parentAlpha = this.alpha;
			Child.alpha = Child.alpha;

			var thisRed:Float = (_color >> 16) / 255;
			var thisGreen:Float = (_color >> 8 & 0xff) / 255;
			var thisBlue:Float = (_color & 0xff) / 255;
			
			Child._parentRed = thisRed;
			Child._parentGreen = thisGreen;
			Child._parentBlue = thisBlue;
			Child.color = Child.color;
		}
		
		return Child;
	}
	
	/**
	 * Removes the <code>FlxNestedSprite</code> from the children list.
	 * @param	Child	The <code>FlxNestedSprite</code> to remove.
	 * @return	The removed <code>FlxNestedSprite</code>.
	 */
	public function remove(Child:FlxNestedSprite):FlxNestedSprite
	{
		var index:Int = FlxArray.indexOf(_children, Child);
		
		if (index >= 0)
		{
			_children.splice(index, 1);
		}
		
		return Child;
	}
	
	/**
	 * Removes the <code>FlxNestedSprite</code> from the position in the children list.
	 * @param	Index	Index to remove.
	 */
	public function removeAt(Index:Int = 0):FlxNestedSprite
	{
		if (_children.length < Index || Index < 0)
		{
			return null;
		}
		
		var child:FlxNestedSprite = _children[Index];
		_children.splice(Index, 1);
		
		return child;
	}
	
	/**
	 * Removes all children sprites from this sprite.
	 */
	public function removeAll():Void
	{
		var i:Int = _children.length;
		while (i > 0)
		{
			removeAt(--i);
		}
	}
	
	/**
	 * All Graphics in this list.
	 */
	inline public var children(get, never):Array<FlxNestedSprite>;
	
	inline private function get_children():Array<FlxNestedSprite> 
	{ 
		return _children; 
	}
	
	/**
	 * Amount of Graphics in this list.
	 */
	public var count(get, never):Int;
	
	private function get_count():Int 
	{ 
		return _children.length; 
	}
	
	public function preUpdate():Void 
	{
		FlxBasic._ACTIVECOUNT++;
		
		if (_flickerTimer > 0)
		{
			_flickerTimer -= FlxG.elapsed;
			
			if(_flickerTimer <= 0)
			{
				_flickerTimer = 0;
				_flicker = false;
			}
		}
		
		last.x = x;
		last.y = y;
		
		if ((path != null) && (pathSpeed != 0) && (path.nodes[_pathNodeIndex] != null))
		{
			updatePathMotion();
		}
		
		for (child in _children)
		{
			child.preUpdate();
		}
	}
	
	override public function update():Void 
	{
		preUpdate();
		
		for (child in _children)
		{
			child.update();
		}
		
		postUpdate();
	}
	
	public function postUpdate():Void 
	{
		if (moves)
		{
			updateMotion();
		}
		
		wasTouching = touching;
		touching = FlxObject.NONE;
		updateAnimation();
		
		
		var delta:Float;
		var velocityDelta:Float;
		var dt:Float = FlxG.elapsed;
		
		velocityDelta = 0.5 * (FlxMath.computeVelocity(relativeAngularVelocity, relativeAngularAcceleration, angularDrag, maxAngular) - relativeAngularVelocity);
		relativeAngularVelocity += velocityDelta; 
		relativeAngle += relativeAngularVelocity * dt;
		relativeAngularVelocity += velocityDelta;
		
		velocityDelta = 0.5 * (FlxMath.computeVelocity(relativeVelocityX, relativeAccelerationX, drag.x, maxVelocity.x) - relativeVelocityX);
		relativeVelocityX += velocityDelta;
		delta = relativeVelocityX * dt;
		relativeVelocityX += velocityDelta;
		relativeX += delta;
		
		velocityDelta = 0.5 * (FlxMath.computeVelocity(relativeVelocityY, relativeAccelerationY, drag.y, maxVelocity.y) - relativeVelocityY);
		relativeVelocityY += velocityDelta;
		delta = relativeVelocityY * dt;
		relativeVelocityY += velocityDelta;
		relativeY += delta;
		
		
		for (child in _children)
		{
			child.velocity.x = child.velocity.y = 0;
			child.acceleration.x = child.acceleration.y = 0;
			child.angularVelocity = child.angularAcceleration = 0;
			child.postUpdate();
			
			if (simpleRenderSprite())
			{
				child.x = x + child.relativeX - offset.x;
				child.y = y + child.relativeY - offset.y;
			}
			else
			{
				var radians:Float = angle * FlxAngle.TO_RAD;
				var cos:Float = Math.cos(radians);
				var sin:Float = Math.sin(radians);
				
				var dx:Float = child.relativeX - offset.x;
				var dy:Float = child.relativeY - offset.y;
				
				var relX:Float = (dx * cos * scale.x - dy * sin * scale.y);
				var relY:Float = (dx * sin * scale.x + dy * cos * scale.y);
				
				child.x = x + relX;
				child.y = y + relY;
			}
			
			child.angle = angle + child.relativeAngle;
			child.scale.x = scale.x * child.relativeScaleX;
			child.scale.y = scale.y * child.relativeScaleY;
			
			child.velocity.x = velocity.x;
			child.velocity.y = velocity.y;
			child.acceleration.x = acceleration.x;
			child.acceleration.y = acceleration.y;
		}
	}
	
	override public function draw():Void 
	{
		super.draw();
		
		for (child in _children)
		{
			child.draw();
		}
	}
	
	#if !FLX_NO_DEBUG
	override public function drawDebug():Void 
	{
		super.drawDebug();
		
		for (child in _children)
		{
			child.drawDebug();
		}
	}
	#end
	
	override private function set_alpha(Alpha:Float):Float
	{
		if (Alpha > 1)
		{
			Alpha = 1;
		}
		if (Alpha < 0)
		{
			Alpha = 0;
		}
		if (Alpha == alpha)
		{
			return alpha;
		}
		alpha = Alpha;
		alpha *= _parentAlpha;
		#if flash
		if ((alpha != 1) || (_color != 0x00ffffff))
		{
			var red:Float = (_color >> 16) * _parentRed / 255;
			var green:Float = (_color >> 8 & 0xff) * _parentGreen / 255;
			var blue:Float = (_color & 0xff) * _parentBlue / 255;
			
			if (_colorTransform == null)
			{
				_colorTransform = new ColorTransform(red, green, blue, alpha);
			}
			else
			{
				_colorTransform.redMultiplier = red;
				_colorTransform.greenMultiplier = green;
				_colorTransform.blueMultiplier = blue;
				_colorTransform.alphaMultiplier = alpha;
			}
			_useColorTransform = true;
		}
		else
		{
			if (_colorTransform != null)
			{
				_colorTransform.redMultiplier = 1;
				_colorTransform.greenMultiplier = 1;
				_colorTransform.blueMultiplier = 1;
				_colorTransform.alphaMultiplier = 1;
			}
			_useColorTransform = false;
		}
		dirty = true;
		#end
		
		if (_children != null)
		{
			for (child in _children)
			{
				child.alpha *= alpha;
				child._parentAlpha = alpha;
			}
		}
		
		return alpha;
	}
	
	override private function set_color(Color:Int):Int
	{
		Color &= 0x00ffffff;
		
		var combinedRed:Float = (Color >> 16) * _parentRed / 255;
		var combinedGreen:Float = (Color >> 8 & 0xff) * _parentGreen / 255;
		var combinedBlue:Float = (Color & 0xff) * _parentBlue / 255;
		
		var combinedColor:Int = Std.int(combinedRed * 255) << 16 | Std.int(combinedGreen * 255) << 8 | Std.int(combinedBlue * 255);
		
		if (_color == combinedColor)
		{
			return _color;
		}
		_color = combinedColor;
		if ((alpha != 1) || (_color != 0x00ffffff))
		{
			if (_colorTransform == null)
			{
				_colorTransform = new ColorTransform(combinedRed, combinedGreen, combinedBlue, alpha);
			}
			else
			{
				_colorTransform.redMultiplier = combinedRed;
				_colorTransform.greenMultiplier = combinedGreen;
				_colorTransform.blueMultiplier = combinedBlue;
				_colorTransform.alphaMultiplier = alpha;
			}
			_useColorTransform = true;
		}
		else
		{
			if (_colorTransform != null)
			{
				_colorTransform.redMultiplier = 1;
				_colorTransform.greenMultiplier = 1;
				_colorTransform.blueMultiplier = 1;
				_colorTransform.alphaMultiplier = 1;
			}
			_useColorTransform = false;
		}
		
		dirty = true;
		
		#if !flash
		_red = combinedRed;
		_green = combinedGreen;
		_blue = combinedBlue;
		#end
		
		for (child in _children)
		{
			var childColor:Int = child.color;
			
			var childRed:Float = (childColor >> 16) / (255 * child._parentRed);
			var childGreen:Float = (childColor >> 8 & 0xff) / (255 * child._parentGreen);
			var childBlue:Float = (childColor & 0xff) / (255 * child._parentBlue);
			
			combinedColor = Std.int(childRed * combinedRed * 255) << 16 | Std.int(childGreen * combinedGreen * 255) << 8 | Std.int(childBlue * combinedBlue * 255);
			
			child.color = combinedColor;
			
			child._parentRed = combinedRed;
			child._parentGreen = combinedGreen;
			child._parentBlue = combinedBlue;
		}
		
		return _color;
	}
}