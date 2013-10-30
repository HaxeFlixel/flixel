package flixel.group;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;

import flixel.system.layer.frames.FlxFrame;
import flixel.system.FlxCollisionType;

/**
 * <code>FlxSpriteGroup</code> is a special <code>FlxGroup</code>
 * that can be treated like a <code>FlxSprite</code> due to having
 * x, y and alpha values. It can only contain <code>FlxSprites</code>.
 */
class FlxSpriteGroup2 extends FlxSprite implements IFlxSprite
{
	public var group:FlxTypedGroup<FlxSprite>;
	
	public var members(get, null):Array<FlxSprite>;
	
	public var length(get, null):Int;
	
	public var maxSize(get, set):Int;
	
	/**
	 * Optimization to allow setting position of group without transforming children twice.
	 */
	private var _skipTransformChildren:Bool = false;
	
	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0)
	{
		super(X, Y);
		maxSize = MaxSize;
	}
	
	override private function initVars():Void 
	{
		collisionType = FlxCollisionType.SPRITEGROUP;
		offset			= new FlxPointHelper(this, offsetTransform);
		origin			= new FlxPointHelper(this, originTransform);
		scale			= new FlxPointHelper(this, scaleTransform);
		velocity		= new FlxPointHelper(this, velocityTransform);
		maxVelocity		= new FlxPointHelper(this, maxVelocityTransform);
		acceleration	= new FlxPointHelper(this, accelerationTransform);
		scrollFactor	= new FlxPointHelper(this, scrollFactorTransform);
		drag			= new FlxPointHelper(this, dragTransform);
	}
	
	override public function destroy():Void
	{
		if (offset != null)			{ offset.destroy(); offset = null; }
		if (origin != null)			{ origin.destroy(); origin = null; }
		if (scale != null)			{ scale.destroy(); scale = null; }
		if (velocity != null)		{ velocity.destroy(); velocity = null; }
		if (maxVelocity != null)	{ maxVelocity.destroy(); maxVelocity = null; }
		if (acceleration != null)	{ acceleration.destroy(); acceleration = null; }
		if (scrollFactor != null)	{ scrollFactor.destroy(); scrollFactor = null; }
		if (drag != null)			{ drag.destroy(); drag = null; }
		
		if (group != null)			{ group.destroy(); group = null; }
		
		super.destroy();
	}
	
	override public function clone(NewSprite:FlxSprite = null):FlxSpriteGroup2 
	{
		if (NewSprite == null || !Std.is(NewSprite, FlxSpriteGroup2))
		{
			NewSprite = new FlxSpriteGroup2(0, 0, group.maxSize);
		}
		
		var cloned:FlxSpriteGroup2 = cast NewSprite;
		cloned.maxSize = group.maxSize;
		
		for (basic in group.members)
		{
			if (basic != null)
			{
				cloned.add(basic.clone());
			}
		}
		return cloned;
	}
	
	override public function onScreen(Camera:FlxCamera = null):Bool 
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		var result:Bool = false;
		for (sprite in group.members)
		{
			if (sprite != null && sprite.exists && sprite.visible)
			{
				result = result || sprite.onScreen(Camera);
			}
		}
		
		return result;
	}
	
	override public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool 
	{
		var result:Bool = false;
		for (sprite in group.members)
		{
			if (sprite != null && sprite.exists && sprite.visible)
			{
				result = result || sprite.overlapsPoint(point, InScreenSpace, Camera);
			}
		}
		
		return result;
	}
	
	override public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool 
	{
		var result:Bool = false;
		for (sprite in group.members)
		{
			if (sprite != null && sprite.exists && sprite.visible)
			{
				result = result || sprite.pixelsOverlapPoint(point, Mask, Camera);
			}
		}
		
		return result;
	}
	
	#if flash
	override private function calcFrame():Void
	#else
	override private function calcFrame(AreYouSure:Bool = false):Void
	#end
	{
		for (sprite in group.members)
		{
			if (sprite == null) continue;
			#if flash
			sprite.calcFrame();
			#else
			sprite.calcFrame(AreYouSure);
			#end
		}
	}
	
	override public function update():Void 
	{
		group.update();
	}
	
	override public function draw():Void 
	{
		group.draw();
	}
	
	override public function loadfromSprite(Sprite:FlxSprite):FlxSprite 
	{
		return this;
	}
	
	override public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Reverse:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		return this;
	}
	
	override public function loadRotatedGraphic(Graphic:Dynamic, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, ?Key:String):FlxSprite 
	{
		return this;
	}
	
	override public function makeGraphic(Width:Int, Height:Int, Color:Int = 0xffffffff, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		return this;
	}
	
	override public function loadImageFromTexture(Data:Dynamic, Reverse:Bool = false, Unique:Bool = false, ?FrameName:String):FlxSprite 
	{
		return this;
	}
	
	override public function loadRotatedImageFromTexture(Data:Dynamic, Image:String, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite 
	{
		return this;
	}
	
	override private function resetHelpers():Void 
	{
		// Nothing to do here
	}
	
	override public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void 
	{
		// Nothing to do here
	}
	
	override public function replaceColor(Color:Int, NewColor:Int, FetchPositions:Bool = false):Array<FlxPoint> 
	{
		var positions:Array<FlxPoint> = null;
		if (FetchPositions)
		{
			positions = new Array<FlxPoint>();
		}
		
		var spritePositions:Array<FlxPoint>;
		for (sprite in group.members)
		{
			if (sprite != null)
			{
				spritePositions = sprite.replaceColor(Color, NewColor, FetchPositions);
				if (FetchPositions)
				{
					positions = positions.concat(spritePositions);
				}
			}
		}
		
		return positions;
	}
	
	override private function updateColorTransform():Void 
	{
		// Nothing to do here
	}
	
	override public function updateFrameData():Void 
	{
		// Nothing to do here
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * 
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
		group.drawDebug();
	}
	#end
	
	public function add(Sprite:FlxSprite):FlxSprite
	{
		Sprite.x += x;
		Sprite.y += y;
		Sprite.alpha *= alpha;
		group.add(Sprite);
		return Sprite;
	}
	
	public function recycle(ObjectClass:Class<FlxSprite> = null, ContructorArgs:Array<Dynamic> = null):FlxSprite
	{
		return group.recycle(ObjectClass, ContructorArgs);
	}
	
	public function remove(Object:FlxSprite, Splice:Bool = false):FlxSprite
	{
		return group.remove(Object, Splice);
	}
	
	public function replace(OldObject:FlxSprite, NewObject:FlxSprite):FlxSprite
	{
		return group.replace(OldObject, NewObject);
	}
	
	public function sort(Index:String = "y", Order:Int = -1):Void
	{
		group.sort(Index, Order);
	}
	
	public function setAll(VariableName:String, Value:Dynamic, Recurse:Bool = true):Void
	{
		group.setAll(VariableName, Value, Recurse);
	}
	
	public function callAll(FunctionName:String, Args:Array<Dynamic> = null, Recurse:Bool = true):Void
	{
		group.callAll(FunctionName, Recurse);
	}
	
	public function getFirstAvailable(ObjectClass:Class<FlxSprite> = null):FlxSprite
	{
		return group.getFirstAvailable(ObjectClass);
	}
	
	public function getFirstNull():Int
	{
		return group.getFirstNull();
	}
	
	public function getFirstExisting():FlxSprite
	{
		return group.getFirstExisting();
	}
	
	public function getFirstAlive():FlxSprite
	{
		return group.getFirstAlive();
	}
	
	public function getFirstDead():FlxSprite
	{
		return group.getFirstDead();
	}
	
	public function countLiving():Int
	{
		return group.countLiving();
	}
	
	public function countDead():Int
	{
		return group.countDead();
	}
	
	public function getRandom(StartIndex:Int = 0, Length:Int = 0):FlxSprite
	{
		return group.getRandom(StartIndex, Length);
	}
	
	public function clear():Void
	{
		group.clear();
	}
	
	override public function kill():Void
	{
		super.kill();
		group.kill();
	}
	
	override public function revive():Void
	{
		super.revive();
		group.revive();
	}
	
	override public function reset(X:Float, Y:Float):Void
	{
		revive();
		setPosition(X, Y);
		
		var sprite:FlxSprite;
		for (i in 0...length)
		{
			sprite = group.members[i];
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
	override public function setPosition(X:Float = 0, Y:Float = 0):Void
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
		if (group == null) 
		{
			return;
		}
		
		var sprite:FlxSprite;
		
		for (i in 0...length)
		{
			sprite = group.members[i];
			
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
		if (group == null) return;
		
		var numProps:Int = FunctionArray.length;
		
		if (numProps > ValueArray.length)
		{
			return;
		}
		
		var basic:FlxSprite;
		var lambda:FlxSprite->T->Void;
		
		for (i in 0...length)
		{
			basic = group.members[i];
			
			if (basic != null && basic.exists)
			{
				for (j in 0...numProps)
				{
					lambda = FunctionArray[j];
					lambda(basic, ValueArray[j]);
				}
			}
		}
	}
	
	// PROPERTIES
	
	override private function set_exists(Value:Bool):Bool
	{
		if (exists != Value)
			transformChildren(existsTransform, Value);
		return super.set_exists(Value);
	}
	
	override private function set_visible(Value:Bool):Bool
	{
		if(exists && visible != Value)
			transformChildren(visibleTransform, Value);
		return super.set_visible(Value);
	}
	
	override private function set_active(Value:Bool):Bool
	{
		if(exists && active != Value)
			transformChildren(activeTransform, Value);
		return super.set_active(Value);
	}
	
	override private function set_alive(Value:Bool):Bool
	{
		if(exists && alive != Value)
			transformChildren(aliveTransform, Value);
		return super.set_alive(Value);
	}
	
	override private function set_x(NewX:Float):Float
	{
		if (!_skipTransformChildren && exists && x != NewX)
		{
			var offset:Float = NewX - x;
			transformChildren(xTransform, offset);
		}
		
		return x = NewX;
	}
	
	override private function set_y(NewY:Float):Float
	{
		if (!_skipTransformChildren && exists && y != NewY)
		{
			var offset:Float = NewY - y;
			transformChildren(yTransform, offset);
		}
		
		return y = NewY;
	}
	
	override private function set_angle(NewAngle:Float):Float
	{
		if (exists && angle != NewAngle)
		{
			var offset:Float = NewAngle - angle;
			transformChildren(angleTransform, offset);
		}
		return angle = NewAngle;
	}
	
	override private function set_alpha(NewAlpha:Float):Float 
	{
		if (NewAlpha > 1)  
		{
			NewAlpha = 1;
		}
		else if (NewAlpha < 0)  
		{
			NewAlpha = 0;
		}
		
		if (exists && alpha != NewAlpha)
		{
			var factor:Float = (alpha > 0) ? NewAlpha / alpha : 0;
			transformChildren(alphaTransform, factor);
		}
		return super.set_alpha(NewAlpha);
	}
	
	override private function set_facing(Value:Int):Int
	{
		if(exists && facing != Value)
			transformChildren(facingTransform, Value);
		return facing = Value;
	}
	
	override private function set_moves(Value:Bool):Bool
	{
		if (exists && moves != Value)
			transformChildren(movesTransform, Value);
		return moves = Value;
	}
	
	override private function set_immovable(Value:Bool):Bool
	{
		if(exists && immovable != Value)
			transformChildren(immovableTransform, Value);
		return immovable = Value;
	}
	
	override private function set_origin(Value:IFlxPoint):IFlxPoint
	{
		if (exists && origin != Value)
			transformChildren(originTransform, Value);
		return origin = Value;
	}
	
	override private function set_offset(Value:IFlxPoint):IFlxPoint
	{
		if (exists && offset != Value)
			transformChildren(offsetTransform, Value);
		return offset = Value;
	}
	
	override private function set_scale(Value:IFlxPoint):IFlxPoint
	{
		if (exists && scale != Value)
			transformChildren(scaleTransform, Value);
		return scale = Value;
	}
	
	override private function set_scrollFactor(Value:IFlxPoint):IFlxPoint
	{
		if (exists && scrollFactor != Value)
			transformChildren(scrollFactorTransform, Value);
		return scrollFactor = Value;
	}
	
	override private function set_velocity(Value:IFlxPoint):IFlxPoint 
	{
		if (exists && velocity != Value)
			transformChildren(velocityTransform, Value);
		return velocity = Value;
	}
	
	override private function set_acceleration(Value:IFlxPoint):IFlxPoint 
	{
		if (exists && acceleration != Value)
			transformChildren(accelerationTransform, Value);
		return acceleration = Value;
	}
	
	override private function set_drag(Value:IFlxPoint):IFlxPoint 
	{
		if (exists && drag != Value)
			transformChildren(dragTransform, Value);
		return drag = Value;
	}
	
	override private function set_maxVelocity(Value:IFlxPoint):IFlxPoint 
	{
		if (exists && maxVelocity != Value)
			transformChildren(maxVelocityTransform, Value);
		return maxVelocity = Value;
	}
	
	override private function get_pixels():BitmapData 
	{
		return null;
	}
	
	override private function set_pixels(Pixels:BitmapData):BitmapData 
	{
		return Pixels;
	}
	
	override private function set_frame(Value:FlxFrame):FlxFrame 
	{
		return Value;
	}
	
	override private function set_color(Color:Int):Int 
	{
		if (exists && color != Color)
			transformChildren(colorTransformF, Color);
		return color = Color;
	}
	
	override private function get_colorTransform():ColorTransform 
	{
		return null;
	}
	
	override private function set_blend(Blend:BlendMode):BlendMode 
	{
		if (exists && _blend != Blend)
			transformChildren(blenfTransform, Blend);
		return _blend = Blend;
	}
	
	override private function set_solid(Solid:Bool):Bool 
	{
		if (exists && solid != Solid)
			transformChildren(solidTransform, Solid);
		return super.set_solid(Solid);
	}
	
	/**
	 * Whether the object should use complex render on flash target (which uses draw() method) or not.
	 * WARNING: setting forceComplexRender to true decreases rendering performance for this object by a factor of 10x!
	 * @default false
	 */
	override private function set_forceComplexRender(Value:Bool):Bool
	{
		if (exists && forceComplexRender != Value)
			transformChildren(complexRenderTransform, Value);
		return super.set_forceComplexRender(Value);
	}
	
	private function get_length():Int
	{
		return group.length;
	}
	
	private function get_maxSize():Int
	{
		return group.maxSize;
	}
	
	private function set_maxSize(Size:Int):Int
	{
		if (group == null)
		{
			group = new FlxTypedGroup<FlxSprite>(Size);
			return Size;
		}
		
		return group.maxSize = Size;
	}
	
	private function get_members():Array<FlxSprite>
	{
		return group.members;
	}
	
	// TRANSFORM FUNCTIONS - STATIC TYPING
	
	private function xTransform(Sprite:FlxSprite, X:Float)								{ Sprite.x += X; }								// addition
	private function yTransform(Sprite:FlxSprite, Y:Float)								{ Sprite.y += Y; }								// addition
	private function angleTransform(Sprite:FlxSprite, Angle:Float)						{ Sprite.angle += Angle; }						// addition
	private function alphaTransform(Sprite:FlxSprite, Alpha:Float)						{ Sprite.alpha *= Alpha; }						// multiplication
	private function facingTransform(Sprite:FlxSprite, Facing:Int)						{ Sprite.facing = Facing; }						// set
	private function movesTransform(Sprite:FlxSprite, Moves:Bool)						{ Sprite.moves = Moves; }						// set
	private function complexRenderTransform(Sprite:FlxSprite, Complex:Bool)				{ Sprite.forceComplexRender = Complex; }		// set
	private function colorTransformF(Sprite:FlxSprite, Color:Int)						{ Sprite.color = Color; }						// set
	private function blenfTransform(Sprite:FlxSprite, Blend:BlendMode)					{ Sprite.blend = Blend; }						// set
	private function immovableTransform(Sprite:FlxSprite, Immovable:Bool)				{ Sprite.immovable = Immovable; }				// set
	private function visibleTransform(Sprite:FlxSprite, Visible:Bool)					{ Sprite.visible = Visible; }					// set
	private function activeTransform(Sprite:FlxSprite, Active:Bool)						{ Sprite.active = Active; }						// set
	private function solidTransform(Sprite:FlxSprite, Solid:Bool)						{ Sprite.solid = Solid; }						// set
	private function aliveTransform(Sprite:FlxSprite, Alive:Bool)						{ Sprite.alive = Alive; }						// set
	private function existsTransform(Sprite:FlxSprite, Exists:Bool)						{ Sprite.exists = Exists; }						// set
	private function offsetTransform(Sprite:FlxSprite, Offset:IFlxPoint)				{ Sprite.offset.copyFrom(Offset); }				// set
	private function originTransform(Sprite:FlxSprite, Origin:IFlxPoint)				{ Sprite.origin.copyFrom(Origin); }				// set
	private function scaleTransform(Sprite:FlxSprite, Scale:IFlxPoint)					{ Sprite.scale.copyFrom(Scale); }				// set
	private function velocityTransform(Sprite:FlxSprite, Velocity:IFlxPoint)			{ Sprite.velocity.copyFrom(Velocity); }			// set
	private function maxVelocityTransform(Sprite:FlxSprite, MaxVelocity:IFlxPoint)		{ Sprite.maxVelocity.copyFrom(MaxVelocity); }	// set
	private function accelerationTransform(Sprite:FlxSprite, Acceleration:IFlxPoint)	{ Sprite.acceleration.copyFrom(Acceleration); }	// set
	private function scrollFactorTransform(Sprite:FlxSprite, ScrollFactor:IFlxPoint)	{ Sprite.scrollFactor.copyFrom(ScrollFactor); }	// set
	private function dragTransform(Sprite:FlxSprite, Drag:IFlxPoint)					{ Sprite.drag.copyFrom(Drag); }					// set
}

/**
 * Helper class to make sure the FlxPoint vars of FlxSpriteGroup members
 * can be updated when the points of the FlxSpriteGroup are changed.
 * WARNING: Calling set(x, y); is MUCH FASTER than setting x, and y separately.
 */
private class FlxPointHelper extends FlxPoint
{
	private var _parent:FlxSpriteGroup2;
	private var _transformFunc:FlxSprite->FlxPoint->Void;
	
	public function new(parent:FlxSpriteGroup2, transformFunc:FlxSprite->IFlxPoint->Void)
	{
		_parent = parent;
		_transformFunc = transformFunc;
		super(0, 0);
	}
	
	override public function set(X:Float = 0, Y:Float = 0):FlxPointHelper
	{
		super.set(X, Y);
		_parent.transformChildren(_transformFunc, this);
		return this;
	}
	
	override private function set_x(Value:Float):Float
	{
		super.set_x(Value);
		_parent.transformChildren(_transformFunc, this);
		return Value;
	}
	
	override private function set_y(Value:Float):Float
	{
		super.set_y(Value);
		_parent.transformChildren(_transformFunc, this);
		return Value;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		_parent = null;
		_transformFunc = null;
	}
}