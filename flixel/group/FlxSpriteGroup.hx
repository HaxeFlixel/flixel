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
class FlxSpriteGroup extends FlxSprite
{
	/**
	 * The actual group which holds all sprites
	 */
	public var group:FlxTypedGroup<FlxSprite>;
	
	/**
	 * The link to a group's members array
	 */
	public var members(get, null):Array<FlxSprite>;
	
	/**
	 * The number of entries in the members array. For performance and safety you should check this 
	 * variable instead of <code>members.length</code> unless you really know what you're doing!
	 */
	public var length(get, null):Int;
	
	/**
	 * The maximum capacity of this group. Default is 0, meaning no max capacity, and the group can just grow.
	 */
	public var maxSize(get, set):Int;
	
	/**
	 * Whether <code>revive()</code> also revives all members of this group. 
	 * False by default.
	 */
	public var autoReviveMembers(get, set):Bool;
	
	/**
	 * Optimization to allow setting position of group without transforming children twice.
	 */
	private var _skipTransformChildren:Bool = false;
	
	/**
	 * Create a new <code>FlxSpriteGroup</code>
	 * @param	X			The initial X position of the group.
	 * @param	Y			The initial Y position of the group
	 * @param	MaxSize		Maximum amount of members allowed
	 */
	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0)
	{
		super(X, Y);
		maxSize = MaxSize;
		autoReviveMembers = false;
	}
	
	/**
	 * This method is used for initialization of variables of complex types.
	 * Don't forget to call super.initVars() if you'll override this method, 
	 * or you'll get null object error and app will crash
	 */
	override private function initVars():Void 
	{
		collisionType	= FlxCollisionType.SPRITEGROUP;
		offset			= new FlxPointHelper(this, offsetTransform);
		origin			= new FlxPointHelper(this, originTransform);
		scale			= new FlxPointHelper(this, scaleTransform);
		velocity		= new FlxPointHelper(this, velocityTransform);
		maxVelocity		= new FlxPointHelper(this, maxVelocityTransform);
		acceleration	= new FlxPointHelper(this, accelerationTransform);
		scrollFactor	= new FlxPointHelper(this, scrollFactorTransform);
		drag			= new FlxPointHelper(this, dragTransform);
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use <code>kill()</code> if you want to disable it temporarily only and <code>reset()</code> it later to revive it.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	override public function destroy():Void
	{
		if (offset != null)			
		{ 
			offset.destroy(); 
			offset = null; 
		}
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
	
	/**
	 * Recursive cloning method: it will create copy of this group which will hold copies of all sprites
	 * @param	NewSprite	optional sprite group to copy to
	 * @return	copy of this sprite group
	 */
	override public function clone(NewSprite:FlxSprite = null):FlxSpriteGroup 
	{
		if (NewSprite == null || !Std.is(NewSprite, FlxSpriteGroup))
		{
			NewSprite = new FlxSpriteGroup(0, 0, group.maxSize);
		}
		
		var cloned:FlxSpriteGroup = cast NewSprite;
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
	
	/**
	 * Check and see if any sprite in this group is currently on screen.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether the object is on screen or not.
	 */
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
	
	/**
	 * Checks to see if a point in 2D world space overlaps any <code>FlxSprite</code> object from this group.
	 * @param	Point			The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this group.
	 */
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
	
	/**
	 * Checks to see if a point in 2D world space overlaps any of <code>FlxSprite</code> object's current displayed pixels.
	 * This check is ALWAYS made in screen space, and always takes scroll factors into account.
	 * @param	Point		The point in world space you want to check.
	 * @param	Mask		Used in the pixel hit test to determine what counts as solid.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
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
	
	override public function update():Void 
	{
		group.update();
	}
	
	override public function draw():Void 
	{
		group.draw();
		#if !FLX_NO_DEBUG
		isDrawnDebug = false;
		#end
	}
	
	/**
	 * Replaces all pixels with specified Color with NewColor pixels. This operation is applied to every nested sprite from this group
	 * @param	Color				Color to replace
	 * @param	NewColor			New color
	 * @param	FetchPositions		Whether we need to store positions of pixels which colors were replaced
	 * @return	Array replaced pixels positions
	 */
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
	
	#if !FLX_NO_DEBUG
	/**
	 * Just a helper variable to check if this group has already been drawn on debug layer
	 */
	private var isDrawnDebug:Bool = false;
	
	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
		if (!isDrawnDebug)	
		{
			group.drawDebug();
			isDrawnDebug = true;
		}
	}
	#end
	
	/**
	 * Adds a new <code>FlxSprite</code> subclass to the group.
	 * @param	Object		The sprite or sprite group you want to add to the group.
	 * @return	The same object that was passed in.
	 */
	public function add(Sprite:FlxSprite):FlxSprite
	{
		Sprite.x += x;
		Sprite.y += y;
		Sprite.alpha *= alpha;
		group.add(Sprite);
		return Sprite;
	}
	
	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * @param	ObjectClass		The class type you want to recycle (e.g. FlxSprite, EvilRobot, etc). Do NOT "new" the class in the parameter!
	 * @param 	ContructorArgs  An array of arguments passed into a newly object if there aren't any dead members to recycle. 
	 * @param 	Force           Force the object to be an ObjectClass and not a super class of ObjectClass. 
	 * @return	A reference to the object that was created.  Don't forget to cast it back to the Class you want (e.g. myObject = myGroup.recycle(myObjectClass) as myObjectClass;).
	 */
	inline public function recycle(ObjectClass:Class<FlxSprite> = null, ContructorArgs:Array<Dynamic> = null, Force:Bool = false):FlxSprite
	{
		return group.recycle(ObjectClass, ContructorArgs, Force);
	}
	
	/**
	 * Removes specified sprite from the group.
	 * @param	Object	The <code>FlxSprite</code> you want to remove.
	 * @param	Splice	Whether the object should be cut from the array entirely or not.
	 * @return	The removed object.
	 */
	public function remove(Object:FlxSprite, Splice:Bool = false):FlxSprite
	{
		return group.remove(Object, Splice);
	}
	
	/**
	 * Replaces an existing <code>FlxSprite</code> with a new one.
	 * 
	 * @param	OldObject	The object you want to replace.
	 * @param	NewObject	The new object you want to use instead.
	 * @return	The new object.
	 */
	inline public function replace(OldObject:FlxSprite, NewObject:FlxSprite):FlxSprite
	{
		return group.replace(OldObject, NewObject);
	}
	
	/**
	 * Call this function to sort the group according to a particular value and order.
	 * For example, to sort game objects for Zelda-style overlaps you might call
	 * <code>myGroup.sort("y",ASCENDING)</code> at the bottom of your
	 * <code>FlxState.update()</code> override.  To sort all existing objects after
	 * a big explosion or bomb attack, you might call <code>myGroup.sort("exists",DESCENDING)</code>.
	 * 
	 * @param	Index	The <code>String</code> name of the member variable you want to sort on.  Default value is "y".
	 * @param	Order	A <code>FlxGroup</code> constant that defines the sort order.  Possible values are <code>ASCENDING</code> and <code>DESCENDING</code>.  Default value is <code>ASCENDING</code>.  
	 */
	inline public function sort(Index:String = "y", Order:Int = -1):Void
	{
		group.sort(Index, Order);
	}
	
	/**
	 * Go through and set the specified variable to the specified value on all members of the group.
	 * 
	 * @param	VariableName	The string representation of the variable name you want to modify, for example "visible" or "scrollFactor".
	 * @param	Value			The value you want to assign to that variable.
	 * @param	Recurse			Default value is true, meaning if <code>setAll()</code> encounters a member that is a group, it will call <code>setAll()</code> on that group rather than modifying its variable.
	 */
	inline public function setAll(VariableName:String, Value:Dynamic, Recurse:Bool = true):Void
	{
		group.setAll(VariableName, Value, Recurse);
	}
	
	/**
	 * Go through and call the specified function on all members of the group.
	 * Currently only works on functions that have no required parameters.
	 * 
	 * @param	FunctionName	The string representation of the function you want to call on each object, for example "kill()" or "init()".
	 * @param	Recurse			Default value is true, meaning if <code>callAll()</code> encounters a member that is a group, it will call <code>callAll()</code> on that group rather than calling the group's function.
	 */ 
	inline public function callAll(FunctionName:String, Args:Array<Dynamic> = null, Recurse:Bool = true):Void
	{
		group.callAll(FunctionName, Args, Recurse);
	}
	
	/**
	 * Call this function to retrieve the first object with exists == false in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 * 
	 * @param	ObjectClass		An optional parameter that lets you narrow the results to instances of this particular class.
	 * @param 	Force           Force the object to be an ObjectClass and not a super class of ObjectClass. 
	 * @return	A <code>FlxSprite</code> currently flagged as not existing.
	 */
	inline public function getFirstAvailable(ObjectClass:Class<FlxSprite> = null, Force:Bool = false):FlxSprite
	{
		return group.getFirstAvailable(ObjectClass, Force);
	}
	
	/**
	 * Call this function to retrieve the first index set to 'null'.
	 * Returns -1 if no index stores a null object.
	 * 
	 * @return	An <code>Int</code> indicating the first null slot in the group.
	 */
	inline public function getFirstNull():Int
	{
		return group.getFirstNull();
	}
	
	/**
	 * Call this function to retrieve the first object with exists == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>FlxSprite</code> currently flagged as existing.
	 */
	inline public function getFirstExisting():FlxSprite
	{
		return group.getFirstExisting();
	}
	
	/**
	 * Call this function to retrieve the first object with dead == false in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>FlxSprite</code> currently flagged as not dead.
	 */
	inline public function getFirstAlive():FlxSprite
	{
		return group.getFirstAlive();
	}
	
	/**
	 * Call this function to retrieve the first object with dead == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>FlxSprite</code> currently flagged as dead.
	 */
	inline public function getFirstDead():FlxSprite
	{
		return group.getFirstDead();
	}
	
	/**
	 * Call this function to find out how many members of the group are not dead.
	 * 
	 * @return	The number of <code>FlxSprite</code>s flagged as not dead.  Returns -1 if group is empty.
	 */
	inline public function countLiving():Int
	{
		return group.countLiving();
	}
	
	/**
	 * Call this function to find out how many members of the group are dead.
	 * 
	 * @return	The number of <code>FlxSprite</code>s flagged as dead.  Returns -1 if group is empty.
	 */
	inline public function countDead():Int
	{
		return group.countDead();
	}
	
	/**
	 * Returns a member at random from the group.
	 * 
	 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
	 * @param	Length		Optional restriction on the number of values you want to randomly select from.
	 * @return	A <code>FlxSprite</code> from the members list.
	 */
	inline public function getRandom(StartIndex:Int = 0, Length:Int = 0):FlxSprite
	{
		return group.getRandom(StartIndex, Length);
	}
	
	/**
	 * Remove all instances of <code>FlxSprite</code> from the list.
	 * WARNING: does not destroy() or kill() any of these objects!
	 */
	inline public function clear():Void
	{
		group.clear();
	}
	
	/**
	 * Calls kill on the group's members and then on the group itself. 
	 * You can revive this group later via <code>revive()</code> after this.
	 */
	override public function kill():Void
	{
		super.kill();
		group.kill();
	}
	
	/**
	 * Revives the group itself (and all of it's members if 
	 * <code>autoReviveMembers</code> has been set to true.
	 */
	override public function revive():Void
	{
		super.revive();
		group.revive();
	}
	
	/**
	 * Helper function for the sort process.
	 * 
	 * @param 	Obj1	The first object being sorted.
	 * @param	Obj2	The second object being sorted.
	 * @return	An integer value: -1 (Obj1 before Obj2), 0 (same), or 1 (Obj1 after Obj2).
	 */
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
	
	// PROPERTIES GETTERS/SETTERS
	
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
		if (exists && facing != Value)
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
		if (exists && immovable != Value)
			transformChildren(immovableTransform, Value);
		return immovable = Value;
	}
	
	override private function set_origin(Value:FlxPoint):FlxPoint
	{
		if (exists && origin != Value && Value != null)
			transformChildren(originTransform, Value);
		return origin = Value;
	}
	
	override private function set_offset(Value:FlxPoint):FlxPoint
	{
		if (exists && offset != Value && Value != null)
			transformChildren(offsetTransform, Value);
		return offset = Value;
	}
	
	override private function set_scale(Value:FlxPoint):FlxPoint
	{
		if (exists && scale != Value && Value != null)
			transformChildren(scaleTransform, Value);
		return scale = Value;
	}
	
	override private function set_scrollFactor(Value:FlxPoint):FlxPoint
	{
		if (exists && scrollFactor != Value && Value != null)
			transformChildren(scrollFactorTransform, Value);
		return scrollFactor = Value;
	}
	
	override private function set_velocity(Value:FlxPoint):FlxPoint 
	{
		if (exists && velocity != Value && Value != null)
			transformChildren(velocityTransform, Value);
		return velocity = Value;
	}
	
	override private function set_acceleration(Value:FlxPoint):FlxPoint 
	{
		if (exists && acceleration != Value && Value != null)
			transformChildren(accelerationTransform, Value);
		return acceleration = Value;
	}
	
	override private function set_drag(Value:FlxPoint):FlxPoint 
	{
		if (exists && drag != Value && Value != null)
			transformChildren(dragTransform, Value);
		return drag = Value;
	}
	
	override private function set_maxVelocity(Value:FlxPoint):FlxPoint 
	{
		if (exists && maxVelocity != Value && Value != null)
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
	
	private function get_autoReviveMembers():Bool
	{
		return group.autoReviveMembers;
	}
	
	private function set_autoReviveMembers(Value:Bool):Bool
	{
		return group.autoReviveMembers = Value;
	}
	
	// TRANSFORM FUNCTIONS - STATIC TYPING
	
	private function xTransform(Sprite:FlxSprite, X:Float)								{ Sprite.x += X; }								// addition
	private function yTransform(Sprite:FlxSprite, Y:Float)								{ Sprite.y += Y; }								// addition
	private function angleTransform(Sprite:FlxSprite, Angle:Float)						{ Sprite.angle += Angle; }						// addition
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
	private function offsetTransform(Sprite:FlxSprite, Offset:FlxPoint)					{ Sprite.offset.copyFrom(Offset); }				// set
	private function originTransform(Sprite:FlxSprite, Origin:FlxPoint)					{ Sprite.origin.copyFrom(Origin); }				// set
	private function scaleTransform(Sprite:FlxSprite, Scale:FlxPoint)					{ Sprite.scale.copyFrom(Scale); }				// set
	private function velocityTransform(Sprite:FlxSprite, Velocity:FlxPoint)				{ Sprite.velocity.copyFrom(Velocity); }			// set
	private function maxVelocityTransform(Sprite:FlxSprite, MaxVelocity:FlxPoint)		{ Sprite.maxVelocity.copyFrom(MaxVelocity); }	// set
	private function accelerationTransform(Sprite:FlxSprite, Acceleration:FlxPoint)		{ Sprite.acceleration.copyFrom(Acceleration); }	// set
	private function scrollFactorTransform(Sprite:FlxSprite, ScrollFactor:FlxPoint)		{ Sprite.scrollFactor.copyFrom(ScrollFactor); }	// set
	private function dragTransform(Sprite:FlxSprite, Drag:FlxPoint)						{ Sprite.drag.copyFrom(Drag); }					// set
	private function alphaTransform(Sprite:FlxSprite, Alpha:Float)						{ if(Sprite.alpha > 0) Sprite.alpha *= Alpha;	// set if Sprite.alpha <= 0, else multiply
																						  else Sprite.alpha = Alpha; }
	// NOT SUPPORTED FUNCTIONALITY
	// THESE METHODS OVERRIDEN FOR SAFETY PURPOSES
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	inline override public function loadfromSprite(Sprite:FlxSprite):FlxSprite 
	{
		throw("'loadfromSprite' is not supported in FlxSpriteGroups.")
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	inline override public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Reverse:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	inline override public function loadRotatedGraphic(Graphic:Dynamic, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, ?Key:String):FlxSprite 
	{
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	inline override public function makeGraphic(Width:Int, Height:Int, Color:Int = 0xffffffff, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	inline override public function loadImageFromTexture(Data:Dynamic, Reverse:Bool = false, Unique:Bool = false, ?FrameName:String):FlxSprite 
	{
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	inline override public function loadRotatedImageFromTexture(Data:Dynamic, Image:String, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite 
	{
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	#if flash
	inline override private function calcFrame():Void
	#else
	inline override private function calcFrame(AreYouSure:Bool = false):Void
	#end
	{
		// Nothing to do here
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override private function resetHelpers():Void {  }
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void {  }
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override private function updateColorTransform():Void {  }
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override public function updateFrameData():Void {  }
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
