package flixel.group;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroupIterator;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSort;

typedef FlxSpriteGroup = FlxTypedSpriteGroup<FlxSprite>;

/**
 * `FlxSpriteGroup` is a special `FlxSprite` that can be treated like
 * a single sprite even if it's made up of several member sprites.
 * It shares the `FlxTypedGroup` API, but it doesn't inherit from it.
 */
class FlxTypedSpriteGroup<T:FlxSprite> extends FlxSprite
{
	/**
	 * The actual group which holds all sprites.
	 */
	public var group:FlxTypedGroup<T>;

	/**
	 * The link to a group's `members` array.
	 */
	public var members(get, never):Array<T>;

	/**
	 * The number of entries in the members array. For performance and safety you should check this
	 * variable instead of `members.length` unless you really know what you're doing!
	 */
	public var length(get, never):Int;

	/**
	 * Whether to attempt to preserve the ratio of alpha values of group members, or set them directly through
	 * the alpha property. Defaults to `false` (preservation).
	 * @since 4.5.0
	 */
	public var directAlpha:Bool = false;

	/**
	 * The maximum capacity of this group. Default is `0`, meaning no max capacity, and the group can just grow.
	 */
	public var maxSize(get, set):Int;

	/**
	 * Optimization to allow setting position of group without transforming children twice.
	 */
	var _skipTransformChildren:Bool = false;

	/**
	 * Array of all the `FlxSprite`s that exist in this group for
	 * optimization purposes / static typing on cpp targets.
	 */
	var _sprites:Array<FlxSprite>;

	/**
	 * @param   X         The initial X position of the group.
	 * @param   Y         The initial Y position of the group.
	 * @param   MaxSize   Maximum amount of members allowed.
	 */
	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0)
	{
		super(X, Y);
		group = new FlxTypedGroup<T>(MaxSize);
		_sprites = cast group.members;
	}

	/**
	 * This method is used for initialization of variables of complex types.
	 * Don't forget to call `super.initVars()` if you'll override this method,
	 * or you'll get `null` object error and app will crash.
	 */
	override function initVars():Void
	{
		flixelType = SPRITEGROUP;

		offset = new FlxCallbackPoint(offsetCallback);
		origin = new FlxCallbackPoint(originCallback);
		scale = new FlxCallbackPoint(scaleCallback);
		scrollFactor = new FlxCallbackPoint(scrollFactorCallback);

		scale.set(1, 1);
		scrollFactor.set(1, 1);

		initMotionVars();
	}

	/**
	 * **WARNING:** A destroyed `FlxBasic` can't be used anymore.
	 * It may even cause crashes if it is still part of a group or state.
	 * You may want to use `kill()` instead if you want to disable the object temporarily only and `revive()` it later.
	 *
	 * This function is usually not called manually (Flixel calls it automatically during state switches for all `add()`ed objects).
	 *
	 * Override this function to `null` out variables manually or call `destroy()` on class members if necessary.
	 * Don't forget to call `super.destroy()`!
	 */
	override public function destroy():Void
	{
		// normally don't have to destroy FlxPoints, but these are FlxCallbackPoints!
		offset = FlxDestroyUtil.destroy(offset);
		origin = FlxDestroyUtil.destroy(origin);
		scale = FlxDestroyUtil.destroy(scale);
		scrollFactor = FlxDestroyUtil.destroy(scrollFactor);

		group = FlxDestroyUtil.destroy(group);
		_sprites = null;

		super.destroy();
	}

	/**
	 * Recursive cloning method: it will create a copy of this group which will hold copies of all sprites
	 *
	 * @return  copy of this sprite group
	 */
	override public function clone():FlxTypedSpriteGroup<T>
	{
		var newGroup = new FlxTypedSpriteGroup<T>(x, y, maxSize);
		for (sprite in group.members)
		{
			if (sprite != null)
			{
				newGroup.add(cast sprite.clone());
			}
		}
		return newGroup;
	}

	/**
	 * Check and see if any sprite in this group is currently on screen.
	 *
	 * @param   Camera   Specify which game camera you want. If `null`, it will just grab the first global camera.
	 * @return  Whether the object is on screen or not.
	 */
	override public function isOnScreen(?Camera:FlxCamera):Bool
	{
		for (sprite in _sprites)
		{
			if (sprite != null && sprite.exists && sprite.visible && sprite.isOnScreen(Camera))
				return true;
		}

		return false;
	}

	/**
	 * Checks to see if a point in 2D world space overlaps any `FlxSprite` object from this group.
	 *
	 * @param   Point           The point in world space you want to check.
	 * @param   InScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 * @param   Camera          Specify which game camera you want. If `null`, it will just grab the first global camera.
	 * @return  Whether or not the point overlaps this group.
	 */
	override public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var result:Bool = false;
		for (sprite in _sprites)
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
	 * @param   Point    The point in world space you want to check.
	 * @param   Mask     Used in the pixel hit test to determine what counts as solid.
	 * @param   Camera   Specify which game camera you want.  If `null`, it will just grab the first global camera.
	 * @return  Whether or not the point overlaps this object.
	 */
	override public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		var result:Bool = false;
		for (sprite in _sprites)
		{
			if (sprite != null && sprite.exists && sprite.visible)
			{
				result = result || sprite.pixelsOverlapPoint(point, Mask, Camera);
			}
		}

		return result;
	}

	override public function update(elapsed:Float):Void
	{
		group.update(elapsed);

		if (moves)
			updateMotion(elapsed);
	}

	override public function draw():Void
	{
		group.draw();

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	/**
	 * Replaces all pixels with specified `Color` with `NewColor` pixels.
	 * WARNING: very expensive (especially on big graphics) as it iterates over every single pixel.
	 *
	 * @param   Color            Color to replace
	 * @param   NewColor         New color
	 * @param   FetchPositions   Whether we need to store positions of pixels which colors were replaced.
	 * @return  `Array` with replaced pixels positions
	 */
	override public function replaceColor(Color:Int, NewColor:Int, FetchPositions:Bool = false):Array<FlxPoint>
	{
		var positions:Array<FlxPoint> = null;
		if (FetchPositions)
		{
			positions = new Array<FlxPoint>();
		}

		var spritePositions:Array<FlxPoint>;
		for (sprite in _sprites)
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

	/**
	 * Adds a new `FlxSprite` subclass to the group.
	 *
	 * @param   Sprite   The sprite or sprite group you want to add to the group.
	 * @return  The same object that was passed in.
	 */
	public function add(Sprite:T):T
	{
		preAdd(Sprite);
		return group.add(Sprite);
	}

	/**
	 * Inserts a new `FlxSprite` subclass to the group at the specified position.
	 *
	 * @param   Position The position that the new sprite or sprite group should be inserted at.
	 * @param   Sprite   The sprite or sprite group you want to insert into the group.
	 * @return  The same object that was passed in.
	 *
	 * @since 4.3.0
	 */
	public function insert(Position:Int, Sprite:T):T
	{
		preAdd(Sprite);
		return group.insert(Position, Sprite);
	}

	/**
	 * Adjusts the position and other properties of the soon-to-be child of this sprite group.
	 * Private helper to avoid duplicate code in `add()` and `insert()`.
	 *
	 * @param	Sprite	The sprite or sprite group that is about to be added or inserted into the group.
	 */
	function preAdd(Sprite:T):Void
	{
		var sprite:FlxSprite = cast Sprite;
		sprite.x += x;
		sprite.y += y;
		sprite.alpha *= alpha;
		sprite.scrollFactor.copyFrom(scrollFactor);
		sprite.cameras = _cameras; // _cameras instead of cameras because get_cameras() will not return null

		if (clipRect != null)
			clipRectTransform(sprite, clipRect);
	}

	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * It behaves differently depending on whether `maxSize` equals `0` or is bigger than `0`.
	 *
	 * `maxSize > 0` / "rotating-recycling" (used by `FlxEmitter`):
	 *   - at capacity:  returns the next object in line, no matter its properties like `alive`, `exists` etc.
	 *   - otherwise:    returns a new object.
	 *
	 * `maxSize == 0` / "grow-style-recycling"
	 *   - tries to find the first object with `exists == false`
	 *   - otherwise: adds a new object to the `members` array
	 *
	 * WARNING: If this function needs to create a new object, and no object class was provided,
	 * it will return `null` instead of a valid object!
	 *
	 * @param   ObjectClass     The class type you want to recycle (e.g. `FlxSprite`, `EvilRobot`, etc).
	 * @param   ObjectFactory   Optional factory function to create a new object
	 *                          if there aren't any dead members to recycle.
	 *                          If `null`, `Type.createInstance()` is used,
	 *                          which requires the class to have no constructor parameters.
	 * @param   Force           Force the object to be an `ObjectClass` and not a super class of `ObjectClass`.
	 * @param   Revive          Whether recycled members should automatically be revived
	 *                          (by calling `revive()` on them).
	 * @return  A reference to the object that was created.
	 */
	public inline function recycle(?ObjectClass:Class<T>, ?ObjectFactory:Void->T, Force:Bool = false, Revive:Bool = true):T
	{
		return group.recycle(ObjectClass, ObjectFactory, Force, Revive);
	}

	/**
	 * Removes the specified sprite from the group.
	 *
	 * @param   Sprite   The `FlxSprite` you want to remove.
	 * @param   Splice   Whether the object should be cut from the array entirely or not.
	 * @return  The removed sprite.
	 */
	public function remove(Sprite:T, Splice:Bool = false):T
	{
		var sprite:FlxSprite = cast Sprite;
		sprite.x -= x;
		sprite.y -= y;
		// alpha
		sprite.cameras = null;
		return group.remove(Sprite, Splice);
	}

	/**
	 * Replaces an existing `FlxSprite` with a new one.
	 *
	 * @param   OldObject   The sprite you want to replace.
	 * @param   NewObject   The new object you want to use instead.
	 * @return  The new sprite.
	 */
	public inline function replace(OldObject:T, NewObject:T):T
	{
		return group.replace(OldObject, NewObject);
	}

	/**
	 * Call this function to sort the group according to a particular value and order.
	 * For example, to sort game objects for Zelda-style overlaps you might call
	 * `group.sort(FlxSort.byY, FlxSort.ASCENDING)` at the bottom of your `FlxState#update()` override.
	 *
	 * @param   Function   The sorting function to use - you can use one of the premade ones in
	 *                     `FlxSort` or write your own using `FlxSort.byValues()` as a "backend".
	 * @param   Order      A constant that defines the sort order.
	 *                     Possible values are `FlxSort.ASCENDING` (default) and `FlxSort.DESCENDING`.
	 */
	public inline function sort(Function:Int->T->T->Int, Order:Int = FlxSort.ASCENDING):Void
	{
		group.sort(Function, Order);
	}

	/**
	 * Call this function to retrieve the first object with `exists == false` in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 *
	 * @param   ObjectClass   An optional parameter that lets you narrow the
	 *                        results to instances of this particular class.
	 * @param   Force         Force the object to be an `ObjectClass` and not a super class of `ObjectClass`.
	 * @return  A `FlxSprite` currently flagged as not existing.
	 */
	public inline function getFirstAvailable(?ObjectClass:Class<T>, Force:Bool = false):T
	{
		return group.getFirstAvailable(ObjectClass, Force);
	}

	/**
	 * Call this function to retrieve the first index set to `null`.
	 * Returns `-1` if no index stores a `null` object.
	 *
	 * @return  An `Int` indicating the first `null` slot in the group.
	 */
	public inline function getFirstNull():Int
	{
		return group.getFirstNull();
	}

	/**
	 * Call this function to retrieve the first object with `exists == true` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `FlxSprite` currently flagged as existing.
	 */
	public inline function getFirstExisting():T
	{
		return group.getFirstExisting();
	}

	/**
	 * Call this function to retrieve the first object with `dead == false` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `FlxSprite` currently flagged as not dead.
	 */
	public inline function getFirstAlive():T
	{
		return group.getFirstAlive();
	}

	/**
	 * Call this function to retrieve the first object with `dead == true` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `FlxSprite` currently flagged as dead.
	 */
	public inline function getFirstDead():T
	{
		return group.getFirstDead();
	}

	/**
	 * Call this function to find out how many members of the group are not dead.
	 *
	 * @return  The number of `FlxSprite`s flagged as not dead. Returns `-1` if group is empty.
	 */
	public inline function countLiving():Int
	{
		return group.countLiving();
	}

	/**
	 * Call this function to find out how many members of the group are dead.
	 *
	 * @return  The number of `FlxSprite`s flagged as dead. Returns `-1` if group is empty.
	 */
	public inline function countDead():Int
	{
		return group.countDead();
	}

	/**
	 * Returns a member at random from the group.
	 *
	 * @param   StartIndex  Optional offset off the front of the array.
	 *                      Default value is `0`, or the beginning of the array.
	 * @param   Length      Optional restriction on the number of values you want to randomly select from.
	 * @return  A `FlxSprite` from the `members` list.
	 */
	public inline function getRandom(StartIndex:Int = 0, Length:Int = 0):T
	{
		return group.getRandom(StartIndex, Length);
	}

	/**
	 * Iterate through every member
	 *
	 * @return An iterator
	 */
	public inline function iterator(?filter:T->Bool):FlxTypedGroupIterator<T>
	{
		return new FlxTypedGroupIterator<T>(members, filter);
	}

	/**
	 * Applies a function to all members.
	 *
	 * @param   Function   A function that modifies one element at a time.
	 * @param   Recurse    Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEach(Function:T->Void, Recurse:Bool = false):Void
	{
		group.forEach(Function, Recurse);
	}

	/**
	 * Applies a function to all `alive` members.
	 *
	 * @param   Function   A function that modifies one element at a time.
	 * @param   Recurse    Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEachAlive(Function:T->Void, Recurse:Bool = false):Void
	{
		group.forEachAlive(Function, Recurse);
	}

	/**
	 * Applies a function to all dead members.
	 *
	 * @param   Function   A function that modifies one element at a time.
	 * @param   Recurse    Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEachDead(Function:T->Void, Recurse:Bool = false):Void
	{
		group.forEachDead(Function, Recurse);
	}

	/**
	 * Applies a function to all existing members.
	 *
	 * @param   Function   A function that modifies one element at a time.
	 * @param   Recurse    Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEachExists(Function:T->Void, Recurse:Bool = false):Void
	{
		group.forEachExists(Function, Recurse);
	}

	/**
	 * Applies a function to all members of type `Class<K>`.
	 *
	 * @param   ObjectClass   A class that objects will be checked against before Function is applied, ex: `FlxSprite`.
	 * @param   Function      A function that modifies one element at a time.
	 * @param   Recurse       Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEachOfType<K>(ObjectClass:Class<K>, Function:K->Void, Recurse:Bool = false)
	{
		group.forEachOfType(ObjectClass, Function, Recurse);
	}

	/**
	 * Remove all instances of `FlxSprite` from the list.
	 * WARNING: does not `destroy()` or `kill()` any of these objects!
	 */
	public inline function clear():Void
	{
		group.clear();
	}

	/**
	 * Calls `kill()` on the group's members and then on the group itself.
	 * You can revive this group later via `revive()` after this.
	 */
	override public function kill():Void
	{
		_skipTransformChildren = true;
		super.kill();
		_skipTransformChildren = false;
		group.kill();
	}

	/**
	 * Revives the group.
	 */
	override public function revive():Void
	{
		_skipTransformChildren = true;
		super.revive(); // calls set_exists and set_alive
		_skipTransformChildren = false;
		group.revive();
	}

	override public function reset(X:Float, Y:Float):Void
	{
		for (sprite in _sprites)
		{
			if (sprite != null)
				sprite.reset(sprite.x + X - x, sprite.y + Y - y);
		}
		
		// prevent any transformations on children, mainly from setter overrides
		_skipTransformChildren = true;
		
		// recreate super.reset() but call super.revive instead of revive
		touching = NONE;
		wasTouching = NONE;
		x = X;
		y = Y;
		// last.set(x, y); // null on sprite groups
		velocity.set();
		super.revive();
		
		_skipTransformChildren = false;
	}

	/**
	 * Helper function to set the coordinates of this object.
	 * Handy since it only requires one line of code.
	 *
	 * @param   X   The new x position
	 * @param   Y   The new y position
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
	 *
	 * @param   Function   Function to transform the sprites. Example:
	 *                     `function(sprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }`
	 * @param   Value      Value which will passed to lambda function.
	 */
	@:generic
	public function transformChildren<V>(Function:T->V->Void, Value:V):Void
	{
		if (_skipTransformChildren || group == null)
			return;

		for (sprite in _sprites)
		{
			if (sprite != null)
				Function(cast sprite, Value);
		}
	}

	/**
	 * Handy function that allows you to quickly transform multiple properties of sprites in this group at a time.
	 *
	 * @param   FunctionArray   `Array` of functions to transform sprites in this group.
	 * @param   ValueArray      `Array` of values which will be passed to lambda functions
	 */
	@:generic
	public function multiTransformChildren<V>(FunctionArray:Array<T->V->Void>, ValueArray:Array<V>):Void
	{
		if (_skipTransformChildren || group == null)
			return;

		var numProps:Int = FunctionArray.length;
		if (numProps > ValueArray.length)
			return;

		var lambda:T->V->Void;
		for (sprite in _sprites)
		{
			if ((sprite != null) && sprite.exists)
			{
				for (i in 0...numProps)
				{
					lambda = FunctionArray[i];
					lambda(cast sprite, ValueArray[i]);
				}
			}
		}
	}

	// PROPERTIES GETTERS/SETTERS

	override function set_camera(Value:FlxCamera):FlxCamera
	{
		if (camera != Value)
			transformChildren(cameraTransform, Value);
		return super.set_camera(Value);
	}

	override function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera>
	{
		if (cameras != Value)
			transformChildren(camerasTransform, Value);
		return super.set_cameras(Value);
	}

	override function set_exists(Value:Bool):Bool
	{
		if (exists != Value)
			transformChildren(existsTransform, Value);
		return super.set_exists(Value);
	}

	override function set_visible(Value:Bool):Bool
	{
		if (exists && visible != Value)
			transformChildren(visibleTransform, Value);
		return super.set_visible(Value);
	}

	override function set_active(Value:Bool):Bool
	{
		if (exists && active != Value)
			transformChildren(activeTransform, Value);
		return super.set_active(Value);
	}

	override function set_alive(Value:Bool):Bool
	{
		if (alive != Value)
			transformChildren(aliveTransform, Value);
		return super.set_alive(Value);
	}

	override function set_x(Value:Float):Float
	{
		if (exists && x != Value)
			transformChildren(xTransform, Value - x);// offset
		return x = Value;
	}

	override function set_y(Value:Float):Float
	{
		if (exists && y != Value)
			transformChildren(yTransform, Value - y);// offset
		return y = Value;
	}

	override function set_angle(Value:Float):Float
	{
		if (exists && angle != Value)
			transformChildren(angleTransform, Value - angle);// offset
		return angle = Value;
	}

	override function set_alpha(Value:Float):Float
	{
		Value = FlxMath.bound(Value, 0, 1);

		if (exists && alpha != Value)
		{
			var factor:Float = (alpha > 0) ? Value / alpha : 0;
			if (!directAlpha && alpha != 0)
				transformChildren(alphaTransform, factor);
			else
				transformChildren(directAlphaTransform, Value);
		}
		return alpha = Value;
	}

	override function set_facing(Value:Int):Int
	{
		if (exists && facing != Value)
			transformChildren(facingTransform, Value);
		return facing = Value;
	}

	override function set_flipX(Value:Bool):Bool
	{
		if (exists && flipX != Value)
			transformChildren(flipXTransform, Value);
		return flipX = Value;
	}

	override function set_flipY(Value:Bool):Bool
	{
		if (exists && flipY != Value)
			transformChildren(flipYTransform, Value);
		return flipY = Value;
	}

	override function set_moves(Value:Bool):Bool
	{
		if (exists && moves != Value)
			transformChildren(movesTransform, Value);
		return moves = Value;
	}

	override function set_immovable(Value:Bool):Bool
	{
		if (exists && immovable != Value)
			transformChildren(immovableTransform, Value);
		return immovable = Value;
	}

	override function set_solid(Value:Bool):Bool
	{
		if (exists && solid != Value)
			transformChildren(solidTransform, Value);
		return super.set_solid(Value);
	}

	override function set_color(Value:Int):Int
	{
		if (exists && color != Value)
			transformChildren(gColorTransform, Value);
		return color = Value;
	}

	override function set_blend(Value:BlendMode):BlendMode
	{
		if (exists && blend != Value)
			transformChildren(blendTransform, Value);
		return blend = Value;
	}

	override function set_clipRect(rect:FlxRect):FlxRect
	{
		if (exists)
			transformChildren(clipRectTransform, rect);
		return super.set_clipRect(rect);
	}

	override function set_pixelPerfectRender(Value:Bool):Bool
	{
		if (exists && pixelPerfectRender != Value)
			transformChildren(pixelPerfectTransform, Value);
		return super.set_pixelPerfectRender(Value);
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override function set_width(Value:Float):Float
	{
		return Value;
	}

	override function get_width():Float
	{
		if (length == 0)
			return 0;

		var minX:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;

		for (member in _sprites)
		{
			if (member == null)
				continue;
			var minMemberX:Float = member.x;
			var maxMemberX:Float = minMemberX + member.width;

			if (maxMemberX > maxX)
				maxX = maxMemberX;
			if (minMemberX < minX)
				minX = minMemberX;
		}
		return maxX - minX;
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override function set_height(Value:Float):Float
	{
		return Value;
	}

	override function get_height():Float
	{
		if (length == 0)
		{
			return 0;
		}

		var minY:Float = Math.POSITIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;

		for (member in _sprites)
		{
			if (member == null)
				continue;
			var minMemberY:Float = member.y;
			var maxMemberY:Float = minMemberY + member.height;

			if (maxMemberY > maxY)
				maxY = maxMemberY;
			if (minMemberY < minY)
				minY = minMemberY;
		}
		return maxY - minY;
	}

	// GROUP FUNCTIONS

	inline function get_length():Int
	{
		return group.length;
	}

	inline function get_maxSize():Int
	{
		return group.maxSize;
	}

	inline function set_maxSize(Size:Int):Int
	{
		return group.maxSize = Size;
	}

	inline function get_members():Array<T>
	{
		return group.members;
	}

	// TRANSFORM FUNCTIONS - STATIC TYPING

	inline function xTransform(Sprite:FlxSprite, X:Float)
		Sprite.x += X; // addition

	inline function yTransform(Sprite:FlxSprite, Y:Float)
		Sprite.y += Y; // addition

	inline function angleTransform(Sprite:FlxSprite, Angle:Float)
		Sprite.angle += Angle; // addition

	inline function alphaTransform(Sprite:FlxSprite, Alpha:Float)
	{
		if (Sprite.alpha != 0 || Alpha == 0)
			Sprite.alpha *= Alpha; // multiplication
		else
			Sprite.alpha = 1 / Alpha; // direct set to avoid stuck sprites
	}

	inline function directAlphaTransform(Sprite:FlxSprite, Alpha:Float)
		Sprite.alpha = Alpha; // direct set

	inline function facingTransform(Sprite:FlxSprite, Facing:Int)
		Sprite.facing = Facing;

	inline function flipXTransform(Sprite:FlxSprite, FlipX:Bool)
		Sprite.flipX = FlipX;

	inline function flipYTransform(Sprite:FlxSprite, FlipY:Bool)
		Sprite.flipY = FlipY;

	inline function movesTransform(Sprite:FlxSprite, Moves:Bool)
		Sprite.moves = Moves;

	inline function pixelPerfectTransform(Sprite:FlxSprite, PixelPerfect:Bool)
		Sprite.pixelPerfectRender = PixelPerfect;

	inline function gColorTransform(Sprite:FlxSprite, Color:Int)
		Sprite.color = Color;

	inline function blendTransform(Sprite:FlxSprite, Blend:BlendMode)
		Sprite.blend = Blend;

	inline function immovableTransform(Sprite:FlxSprite, Immovable:Bool)
		Sprite.immovable = Immovable;

	inline function visibleTransform(Sprite:FlxSprite, Visible:Bool)
		Sprite.visible = Visible;

	inline function activeTransform(Sprite:FlxSprite, Active:Bool)
		Sprite.active = Active;

	inline function solidTransform(Sprite:FlxSprite, Solid:Bool)
		Sprite.solid = Solid;

	inline function aliveTransform(Sprite:FlxSprite, Alive:Bool)
		Sprite.alive = Alive;

	inline function existsTransform(Sprite:FlxSprite, Exists:Bool)
		Sprite.exists = Exists;

	inline function cameraTransform(Sprite:FlxSprite, Camera:FlxCamera)
		Sprite.camera = Camera;

	inline function camerasTransform(Sprite:FlxSprite, Cameras:Array<FlxCamera>)
		Sprite.cameras = Cameras;

	inline function offsetTransform(Sprite:FlxSprite, Offset:FlxPoint)
		Sprite.offset.copyFrom(Offset);

	inline function originTransform(Sprite:FlxSprite, Origin:FlxPoint)
		Sprite.origin.copyFrom(Origin);

	inline function scaleTransform(Sprite:FlxSprite, Scale:FlxPoint)
		Sprite.scale.copyFrom(Scale);

	inline function scrollFactorTransform(Sprite:FlxSprite, ScrollFactor:FlxPoint)
		Sprite.scrollFactor.copyFrom(ScrollFactor);

	inline function clipRectTransform(Sprite:FlxSprite, ClipRect:FlxRect)
	{
		if (ClipRect == null)
			Sprite.clipRect = null;
		else
			Sprite.clipRect = FlxRect.get(ClipRect.x - Sprite.x + x, ClipRect.y - Sprite.y + y, ClipRect.width, ClipRect.height);
	}

	// Functions for the FlxCallbackPoint
	inline function offsetCallback(Offset:FlxPoint)
		transformChildren(offsetTransform, Offset);

	inline function originCallback(Origin:FlxPoint)
		transformChildren(originTransform, Origin);

	inline function scaleCallback(Scale:FlxPoint)
		transformChildren(scaleTransform, Scale);

	inline function scrollFactorCallback(ScrollFactor:FlxPoint)
		transformChildren(scrollFactorTransform, ScrollFactor);

	// NON-SUPPORTED FUNCTIONALITY
	// THESE METHODS ARE OVERRIDDEN FOR SAFETY PURPOSES

	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite
	{
		#if FLX_DEBUG
		throw "This function is not supported in FlxSpriteGroup";
		#end
		return this;
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FlxSprite
	{
		return this;
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadRotatedGraphic(Graphic:FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false,
			AutoBuffer:Bool = false, ?Key:String):FlxSprite
	{
		#if FLX_DEBUG
		throw "This function is not supported in FlxSpriteGroup";
		#end
		return this;
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function makeGraphic(Width:Int, Height:Int, Color:Int = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
	{
		#if FLX_DEBUG
		throw "This function is not supported in FlxSpriteGroup";
		#end
		return this;
	}

	override function set_pixels(Value:BitmapData):BitmapData
	{
		return Value;
	}

	override function set_frame(Value:FlxFrame):FlxFrame
	{
		return Value;
	}

	override function get_pixels():BitmapData
	{
		return null;
	}

	/**
	 * Internal function to update the current animation frame.
	 *
	 * @param	RunOnCpp	Whether the frame should also be recalculated if we're on a non-flash target
	 */
	override inline function calcFrame(RunOnCpp:Bool = false):Void
	{
		// Nothing to do here
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override inline function resetHelpers():Void {}

	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override public inline function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void {}

	override function set_frames(Frames:FlxFramesCollection):FlxFramesCollection
	{
		return Frames;
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override inline function updateColorTransform():Void {}
}
