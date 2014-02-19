package flixel.group;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxCollisionType;
import flixel.system.layer.frames.FlxFrame;
import flixel.util.FlxPoint;
import flixel.util.FlxSort;

/**
 * FlxSpriteGroup is a special FlxGroup that can be treated like 
 * a single sprite even if it'sFlxSprite made up of several member sprites.
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
	 * variable instead of members.length unless you really know what you're doing!
	 */
	public var length(get, null):Int;
	
	/**
	 * The maximum capacity of this group. Default is 0, meaning no max capacity, and the group can just grow.
	 */
	public var maxSize(get, set):Int;
	
	/**
	 * Optimization to allow setting position of group without transforming children twice.
	 */
	private var _skipTransformChildren:Bool = false;
	
	#if !FLX_NO_DEBUG
	/**
	 * Just a helper variable to check if this group has already been drawn on debug layer
	 */
	private var _isDrawnDebug:Bool = false;
	#end
	
	/**
	 * Create a new FlxSpriteGroup
	 * 
	 * @param	X			The initial X position of the group.
	 * @param	Y			The initial Y position of the group
	 * @param	MaxSize		Maximum amount of members allowed
	 */
	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0)
	{
		super(X, Y);
		maxSize = MaxSize;
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
		scrollFactor	= new FlxPointHelper(this, scrollFactorTransform);
		
		scrollFactor.set(1, 1);
	 	
		initMotionVars();
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use kill() if you want to disable it temporarily only and reset() it later to revive it.
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
		if (scrollFactor != null)	{ scrollFactor.destroy(); scrollFactor = null; }
		
		if (group != null)			{ group.destroy(); group = null; }
		
		super.destroy();
	}
	
	/**
	 * Recursive cloning method: it will create copy of this group which will hold copies of all sprites
	 * 
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
	 * 
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether the object is on screen or not.
	 */
	override public function isOnScreen(?Camera:FlxCamera):Bool 
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
				result = result || sprite.isOnScreen(Camera);
			}
		}
		
		return result;
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps any FlxSprite object from this group.
	 * 
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
	 * Checks to see if a point in 2D world space overlaps any of FlxSprite object's current displayed pixels.
	 * This check is ALWAYS made in screen space, and always takes scroll factors into account.
	 * 
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
		if (moves)
		{
			updateMotion();
		}
		
		group.update();
	}
	
	override public function draw():Void 
	{
		group.draw();
		#if !FLX_NO_DEBUG
		_isDrawnDebug = false;
		#end
	}
	
	/**
	 * Replaces all pixels with specified Color with NewColor pixels. This operation is applied to every nested sprite from this group
	 * 
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
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * 
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
		if (!_isDrawnDebug)	
		{
			group.drawDebug();
			_isDrawnDebug = true;
		}
	}
	#end
	
	/**
	 * Adds a new FlxSprite subclass to the group.
	 * 
	 * @param	Object		The sprite or sprite group you want to add to the group.
	 * @return	The same object that was passed in.
	 */
	public function add(Sprite:FlxSprite):FlxSprite
	{
		Sprite.x += x;
		Sprite.y += y;
		Sprite.alpha *= alpha;
		Sprite.scrollFactor.copyFrom(scrollFactor);
		
		return group.add(Sprite);
	}
	
	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * 
	 * @param	ObjectClass		The class type you want to recycle (e.g. FlxSprite, EvilRobot, etc). Do NOT "new" the class in the parameter!
	 * @param 	ContructorArgs  An array of arguments passed into a newly object if there aren't any dead members to recycle. 
	 * @param 	Force           Force the object to be an ObjectClass and not a super class of ObjectClass. 
	 * @return	A reference to the object that was created.  Don't forget to cast it back to the Class you want (e.g. myObject = myGroup.recycle(myObjectClass) as myObjectClass;).
	 */
	public inline function recycle(ObjectClass:Class<FlxSprite> = null, ContructorArgs:Array<Dynamic> = null, Force:Bool = false):FlxSprite
	{
		return group.recycle(ObjectClass, ContructorArgs, Force);
	}
	
	/**
	 * Removes specified sprite from the group.
	 * 
	 * @param	Object	The FlxSprite you want to remove.
	 * @param	Splice	Whether the object should be cut from the array entirely or not.
	 * @return	The removed object.
	 */
	public function remove(Object:FlxSprite, Splice:Bool = false):FlxSprite
	{
		return group.remove(Object, Splice);
	}
	
	/**
	 * Replaces an existing FlxSprite with a new one.
	 * 
	 * @param	OldObject	The object you want to replace.
	 * @param	NewObject	The new object you want to use instead.
	 * @return	The new object.
	 */
	public inline function replace(OldObject:FlxSprite, NewObject:FlxSprite):FlxSprite
	{
		return group.replace(OldObject, NewObject);
	}
	
	/**
	 * Call this function to sort the group according to a particular value and order. For example, to sort game objects for Zelda-style 
	 * overlaps you might call myGroup.sort(FlxSort.byY, FlxSort.ASCENDING) at the bottom of your FlxState.update() override.
	 * 
	 * @param	Function	The sorting function to use - you can use one of the premade ones in FlxSort or write your own using FlxSort.byValues() as a backend
	 * @param	Order		A FlxGroup constant that defines the sort order.  Possible values are FlxSort.ASCENDING (default) and FlxSort.DESCENDING. 
	 */
	public inline function sort(Function:Int->FlxSprite->FlxSprite->Int, Order:Int = FlxSort.ASCENDING):Void
	{
		group.sort(Function, Order);
	}
	
	/**
	 * Go through and set the specified variable to the specified value on all members of the group.
	 * 
	 * @param	VariableName	The string representation of the variable name you want to modify, for example "visible" or "scrollFactor".
	 * @param	Value			The value you want to assign to that variable.
	 * @param	Recurse			Default value is true, meaning if setAll() encounters a member that is a group, it will call setAll() on that group rather than modifying its variable.
	 */
	public inline function setAll(VariableName:String, Value:Dynamic, Recurse:Bool = true):Void
	{
		group.setAll(VariableName, Value, Recurse);
	}
	
	/**
	 * Go through and call the specified function on all members of the group.
	 * Currently only works on functions that have no required parameters.
	 * 
	 * @param	FunctionName	The string representation of the function you want to call on each object, for example "kill()" or "init()".
	 * @param	Recurse			Default value is true, meaning if callAll() encounters a member that is a group, it will call callAll() on that group rather than calling the group's function.
	 */ 
	public inline function callAll(FunctionName:String, Args:Array<Dynamic> = null, Recurse:Bool = true):Void
	{
		group.callAll(FunctionName, Args, Recurse);
	}
	
	/**
	 * Call this function to retrieve the first object with exists == false in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 * 
	 * @param	ObjectClass		An optional parameter that lets you narrow the results to instances of this particular class.
	 * @param 	Force           Force the object to be an ObjectClass and not a super class of ObjectClass. 
	 * @return	A FlxSprite currently flagged as not existing.
	 */
	public inline function getFirstAvailable(ObjectClass:Class<FlxSprite> = null, Force:Bool = false):FlxSprite
	{
		return group.getFirstAvailable(ObjectClass, Force);
	}
	
	/**
	 * Call this function to retrieve the first index set to 'null'.
	 * Returns -1 if no index stores a null object.
	 * 
	 * @return	An Int indicating the first null slot in the group.
	 */
	public inline function getFirstNull():Int
	{
		return group.getFirstNull();
	}
	
	/**
	 * Call this function to retrieve the first object with exists == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A FlxSprite currently flagged as existing.
	 */
	public inline function getFirstExisting():FlxSprite
	{
		return group.getFirstExisting();
	}
	
	/**
	 * Call this function to retrieve the first object with dead == false in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A FlxSprite currently flagged as not dead.
	 */
	public inline function getFirstAlive():FlxSprite
	{
		return group.getFirstAlive();
	}
	
	/**
	 * Call this function to retrieve the first object with dead == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A FlxSprite currently flagged as dead.
	 */
	public inline function getFirstDead():FlxSprite
	{
		return group.getFirstDead();
	}
	
	/**
	 * Call this function to find out how many members of the group are not dead.
	 * 
	 * @return	The number of FlxSprites flagged as not dead.  Returns -1 if group is empty.
	 */
	public inline function countLiving():Int
	{
		return group.countLiving();
	}
	
	/**
	 * Call this function to find out how many members of the group are dead.
	 * 
	 * @return	The number of FlxSprites flagged as dead.  Returns -1 if group is empty.
	 */
	public inline function countDead():Int
	{
		return group.countDead();
	}
	
	/**
	 * Returns a member at random from the group.
	 * 
	 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
	 * @param	Length		Optional restriction on the number of values you want to randomly select from.
	 * @return	A FlxSprite from the members list.
	 */
	public inline function getRandom(StartIndex:Int = 0, Length:Int = 0):FlxSprite
	{
		return group.getRandom(StartIndex, Length);
	}
	
	/**
	 * Applies a function to all members
	 * 
	 * @param   Function   A function that modifies one element at a time
	 */
	public inline function forEach(Function:FlxSprite->Void):Void
	{
		group.forEach(Function);
	}

	/**
	 * Applies a function to all alive members
	 * 
	 * @param   Function   A function that modifies one element at a time
	 */
	public inline function forEachAlive(Function:FlxSprite->Void):Void
	{
		group.forEachAlive(Function);
	}

	/**
	 * Applies a function to all dead members
	 * 
	 * @param   Function   A function that modifies one element at a time
	 */
	public inline function forEachDead(Function:FlxSprite->Void):Void
	{
		group.forEachDead(Function);
	}

	/**
	 * Applies a function to all existing members
	 * 
	 * @param   Function   A function that modifies one element at a time
	 */
	public function forEachExists(Function:FlxSprite->Void):Void
	{
		group.forEachExists(Function);
	}
	
	/**
	 * Remove all instances of FlxSprite from the list.
	 * WARNING: does not destroy() or kill() any of these objects!
	 */
	public inline function clear():Void
	{
		group.clear();
	}
	
	/**
	 * Calls kill on the group's members and then on the group itself. 
	 * You can revive this group later via revive() after this.
	 */
	override public function kill():Void
	{
		super.kill();
		group.kill();
	}
	
	/**
	 * Revives the group.
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
	 * 
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
	 * @param 	Function 	Function to transform the sprites. Example: function(s:IFlxSprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }
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
	 * 
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
		if (exists && visible != Value)
			transformChildren(visibleTransform, Value);
		return super.set_visible(Value);
	}
	
	override private function set_active(Value:Bool):Bool
	{
		if (exists && active != Value)
			transformChildren(activeTransform, Value);
		return super.set_active(Value);
	}
	
	override private function set_alive(Value:Bool):Bool
	{
		if (exists && alive != Value)
			transformChildren(aliveTransform, Value);
		return super.set_alive(Value);
	}
	
	override private function set_x(Value:Float):Float
	{
		if (!_skipTransformChildren && exists && x != Value)
		{
			var offset:Float = Value - x;
			transformChildren(xTransform, offset);
		}
		
		return x = Value;
	}
	
	override private function set_y(Value:Float):Float
	{
		if (!_skipTransformChildren && exists && y != Value)
		{
			var offset:Float = Value - y;
			transformChildren(yTransform, offset);
		}
		
		return y = Value;
	}
	
	override private function set_angle(Value:Float):Float
	{
		if (exists && angle != Value)
		{
			var offset:Float = Value - angle;
			transformChildren(angleTransform, offset);
		}
		return angle = Value;
	}
	
	override private function set_alpha(Value:Float):Float 
	{
		if (Value > 1)  
		{
			Value = 1;
		}
		else if (Value < 0)  
		{
			Value = 0;
		}
		
		if (exists && alpha != Value)
		{
			var factor:Float = (alpha > 0) ? Value / alpha : 0;
			transformChildren(alphaTransform, factor);
		}
		return alpha = Value;
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
	
	override private function set_solid(Value:Bool):Bool 
	{
		if (exists && solid != Value)
			transformChildren(solidTransform, Value);
		return super.set_solid(Value);
	}
	
	override private function set_color(Value:Int):Int 
	{
		if (exists && color != Value)
			transformChildren(gColorTransform, Value);
		return color = Value;
	}
	
	override private function set_blend(Value:BlendMode):BlendMode 
	{
		if (exists && (blend != Value))
			transformChildren(blendTransform, Value);
		return blend = Value;
	}
	
	/**
	 * Whether the object should use complex render on flash target (which uses draw() method) or not.
	 * WARNING: setting forceComplexRender to true decreases rendering performance for this object by a factor of 10x!
	 */
	override private function set_forceComplexRender(Value:Bool):Bool
	{
		if (exists && forceComplexRender != Value)
			transformChildren(complexRenderTransform, Value);
		return super.set_forceComplexRender(Value);
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override public function set_width(Value:Float):Float
	{
		return Value;
	}
	
	override public function get_width():Float
	{
		if (length == 0)
		{
			return 0;
		}
		
		var minX:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		
		for (member in group.members)
		{
			var minMemberX:Float = member.x;
			var maxMemberX:Float = minMemberX + member.width;
			
			if (maxMemberX > maxX)
			{
				maxX = maxMemberX;
			}
			if (minMemberX < minX)
			{
				minX = minMemberX;
			}
		}
		return (maxX - minX);
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override public function set_height(Value:Float):Float
	{
		return Value;
	}
	
	override public function get_height():Float
	{
		if (length == 0)
		{
			return 0;
		}
		
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;
		
		for (member in group.members)
		{
			var minMemberY:Float = member.y;
			var maxMemberY:Float = minMemberY + member.height;
			
			if (maxMemberY > maxY)
			{
				maxY = maxMemberY;
			}
			if (minMemberY < minY)
			{
				minY = minMemberY;
			}
		}
		return (maxY - minY);
	}
	
	// GROUP FUNCTIONS
	
	private inline function get_length():Int
	{
		return group.length;
	}
	
	private inline function get_maxSize():Int
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
	
	private inline function get_members():Array<FlxSprite>
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
	private function gColorTransform(Sprite:FlxSprite, Color:Int)						{ Sprite.color = Color; }						// set
	private function blendTransform(Sprite:FlxSprite, Blend:BlendMode)					{ Sprite.blend = Blend; }						// set
	private function immovableTransform(Sprite:FlxSprite, Immovable:Bool)				{ Sprite.immovable = Immovable; }				// set
	private function visibleTransform(Sprite:FlxSprite, Visible:Bool)					{ Sprite.visible = Visible; }					// set
	private function activeTransform(Sprite:FlxSprite, Active:Bool)						{ Sprite.active = Active; }						// set
	private function solidTransform(Sprite:FlxSprite, Solid:Bool)						{ Sprite.solid = Solid; }						// set
	private function aliveTransform(Sprite:FlxSprite, Alive:Bool)						{ Sprite.alive = Alive; }						// set
	private function existsTransform(Sprite:FlxSprite, Exists:Bool)						{ Sprite.exists = Exists; }						// set
	private function offsetTransform(Sprite:FlxSprite, Offset:FlxPoint)					{ Sprite.offset.copyFrom(Offset); }				// set
	private function originTransform(Sprite:FlxSprite, Origin:FlxPoint)					{ Sprite.origin.copyFrom(Origin); }				// set
	private function scaleTransform(Sprite:FlxSprite, Scale:FlxPoint)					{ Sprite.scale.copyFrom(Scale); }				// set
	private function scrollFactorTransform(Sprite:FlxSprite, ScrollFactor:FlxPoint)		{ Sprite.scrollFactor.copyFrom(ScrollFactor); }	// set
	// NOT SUPPORTED FUNCTIONALITY
	// THESE METHODS OVERRIDEN FOR SAFETY PURPOSES
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite 
	{
		#if !FLX_NO_DEBUG
		FlxG.log.error("loadGraphicFromSprite() is not supported in FlxSpriteGroups.");
		#end
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Reverse:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadRotatedGraphic(Graphic:Dynamic, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, ?Key:String):FlxSprite 
	{
		#if !FLX_NO_DEBUG
		FlxG.log.error("loadRotatedGraphic() is not supported in FlxSpriteGroups.");
		#end
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function makeGraphic(Width:Int, Height:Int, Color:Int = 0xffffffff, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		#if !FLX_NO_DEBUG
		FlxG.log.error("makeGraphic() is not supported in FlxSpriteGroups.");
		#end
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadGraphicFromTexture(Data:Dynamic, Reverse:Bool = false, Unique:Bool = false, ?FrameName:String):FlxSprite 
	{
		#if !FLX_NO_DEBUG
		FlxG.log.error("loadGraphicFromTexture() is not supported in FlxSpriteGroups.");
		#end
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadRotatedGraphicFromTexture(Data:Dynamic, Image:String, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite 
	{
		#if !FLX_NO_DEBUG
		FlxG.log.error("loadRotatedGraphicFromTexture() is not supported in FlxSpriteGroups.");
		#end
		return this;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return the BitmapData passed in as parameter
	 */
	override private function set_pixels(Value:BitmapData):BitmapData 
	{
		return Value;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return the FlxFrame passed in as parameter
	 */
	override private function set_frame(Value:FlxFrame):FlxFrame 
	{
		return Value;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return WARNING: returns null
	 */
	override private function get_pixels():BitmapData 
	{
		return null;
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return WARNING: returns null
	 */
	override private function get_colorTransform():ColorTransform 
	{
		return null;
	}
	
	/**
	 * Internal function to update the current animation frame.
	 * 
	 * @param	RunOnCpp	Whether the frame should also be recalculated if we're on a non-flash target
	 */
	inline override private function calcFrame(RunOnCpp:Bool = false):Void
	{
		// Nothing to do here
	}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override private function resetHelpers():Void {}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void {}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override private function updateColorTransform():Void {}
	
	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	inline override public function updateFrameData():Void {}
}

/**
 * Helper class to make sure the FlxPoint vars of FlxSpriteGroup members
 * can be updated when the points of the FlxSpriteGroup are changed.
 * IMPORTANT: Calling set(x, y); is MUCH FASTER than setting x, and y separately.
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
