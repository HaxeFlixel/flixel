package flixel.path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.path.FlxBasePath;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.Graphics;

typedef CenterMode = FlxPathAnchorMode;
/**
 * Determines an object position in relation to the path
 */
 @:using(flixel.path.FlxPath.AnchorTools)
enum FlxPathAnchorMode
{
	
	/**
	 * Align the x,y position of the object on the path.
	 */
	TOP_LEFT;
	
	/**
	 * Align the midpoint of the object on the path.
	 */
	CENTER;
	
	/**
	 * If the object is a FlxSprite, align its origin point on the path.
	 * If it is not a sprite it will use the position.
	 */
	ORIGIN;
	
	/**
	 * Uses the specified offset from the position.
	 */
	CUSTOM(offset:FlxPoint);
}

private class AnchorTools
{
	public static function computeAnchor(mode:FlxPathAnchorMode, object:FlxObject, ?result:FlxPoint):FlxPoint
	{
		result = computeAnchorOffset(mode, object, result);
		return result.add(object.x, object.y);
	}
	
	public static function computeAnchorOffset(mode:FlxPathAnchorMode, object:FlxObject, ?result:FlxPoint):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();
		else
			result.set();
		
		return switch (mode)
		{
			case ORIGIN:
				if (object is FlxSprite)
				{
					result.add(cast(object, FlxSprite).origin.x, cast(object, FlxSprite).origin.y);
				}
				else
				{
					result;
				}
			case CENTER:
				result.add(object.width * 0.5, object.height * 0.5);
			case TOP_LEFT:
				result;
			case CUSTOM(offset):
				result.addPoint(offset);
		}
	}
}

/**
 * This is a simple path data container. Basically a list of points that
 * a `FlxObject` can follow.  Also has code for drawing debug visuals.
 * `FlxTilemap.findPath()` returns a path usable by `FlxPath`, but you can
 * also just make your own, using the `add()` functions below
 * or by creating your own array of points.
 *
 * Every `FlxObject` has a `path` property which can make it move along specified array of way points.
 * Usage example:
 *
 * ```haxe
 * var path = new FlxPath();
 * var points:Array<FlxPoint> = [new FlxPoint(0, 0), new FlxPoint(100, 0)];
 * object.path = path;
 * path.start(points, 50, FORWARD);
 * ```
 *
 * You can also do this in one line:
 *
 * ```haxe
 * object.path = new FlxPath().start([new FlxPoint(0, 0), new FlxPoint(100, 0)], 50, FORWARD);
 * ```
 *
 * ...or using some more chaining:
 *
 * ```haxe
 * object.path = new FlxPath().add(0, 0).add(100, 0).start(50, FORWARD);
 * ```
 *
 * If you are fine with the default values of start (speed, mode, auto-rotate) you can also do:
 *
 * ```haxe
 * object.path = new FlxPath([new FlxPoint(0, 0), new FlxPoint(100, 0)]).start();
 * ```
 */
class FlxPath extends FlxBasePath
{
	/**
	 * Path behavior controls: move from the start of the path to the end then stop.
	 */
	static var _point:FlxPoint = FlxPoint.get();

	/**
	 * The speed at which the object is moving on the path.
	 * When an object completes a non-looping path circuit,
	 * the path's speed will be zeroed out, but the path reference
	 * will NOT be nulled out. So `speed` is a good way
	 * to check if this object is currently following a path or not.
	 */
	public var speed:Float = 0;
	
	/**
	 * Whether to make the object immovable while active.
	 */
	public var immovable(default, set):Bool = false;
	
	/**
	 * The angle in degrees between this object and the next node, where -90 is directly upward, and 0 is to the right.
	 */
	public var angle(default, null):Float = 0;
	
	/**
	 * Legacy method of alignment for the object following the path. If true, align the midpoint of the object on the path, else use the x, y position.
	 */
	@:deprecated("path.autoCenter is deprecated, use centerMode") // 5.7.0
	public var autoCenter(get, set):Bool;
	
	/**
	 * How to center the object on the path.
	 * @since 5.7.0
	 */
	public var centerMode:FlxPathAnchorMode = CENTER;
	
	/**
	 * Whether the object's angle should be adjusted to the path angle during path follow behavior.
	 */
	public var autoRotate:Bool = false;
	
	/**
	 * The amount of degrees to offset from the path's angle, when `autoRotate` is `true`. To use
	 * flixel 4.11's autoRotate behavior, set this to `90`, so there is no rotation at 0 degrees.
	 * 
	 * @see [Flixel 5.0.0 Migration guide](https://github.com/HaxeFlixel/flixel/wiki/Flixel-5.0.0-Migration-guide)
	 * @since 5.0.0
	 */
	public var angleOffset:Float = 0;
	
	@:deprecated("onComplete is deprecated, use the onEndReached signal, instead")
	public var onComplete:FlxPath->Void;
	
	/**
	 * Tracks which node of the path this object is currently moving toward.
	 */
	@:deprecated("nodeIndex is deprecated, use nextIndex, instead")
	public var nodeIndex(get, never):Int;
	
	/**
	 * Whether to limit movement to certain axes.
	 */
	public var axes:FlxAxes = XY;
	
	/**
	 * Internal tracker for path behavior flags (like looping, yoyo, etc).
	 */
	@:noCompletion
	var _mode(get, set):FlxPathType;
	
	/**
	 * Internal helper for node navigation, specifically yo-yo and backwards movement.
	 */
	@:noCompletion
	var _inc(get, set):Int;

	var _wasObjectImmovable:Null<Bool> = null;

	var _firstUpdate:Bool = false;

	/**
	 * Object which will follow this path
	 */
	@:allow(flixel.FlxObject)
	var object(get, set):FlxObject;
	
	@:haxe.warning("-WDeprecated")
	public function new(?nodes:Array<FlxPoint>)
	{
		super(nodes != null ? nodes.copy() : []);
		
		active = false;
		onEndReached.add(function (_)
		{
			if (onComplete != null)
				onComplete(this);
		});
	}

	/**
	 * Just resets some debugging related variables (for debugger renderer).
	 * Also resets `centerMode` to `CENTER`.
	 * @return This path object.
	 */
	public function reset():FlxPath
	{
		#if FLX_DEBUG
		debugDrawData = {};
		ignoreDrawDebug = false;
		#end
		centerMode = CENTER;
		return this;
	}

	/**
	 * Sets the following properties: `speed`, `mode` and auto rotation.
	 *
	 * @param speed        The speed at which the object is moving on the path.
	 * @param mode         Path following behavior (like looping, horizontal only, etc).
	 * @param autoRotate   Whether the object's angle should be adjusted to the path angle during
	 *                     path follow behavior. Note that moving straight right is 0 degrees, when angle
	 *                     angleOffset is 0.
	 * @return This path object.
	 * @since 4.2.0
	 */
	public function setProperties(speed = 100.0, mode = FlxPathType.FORWARD, autoRotate = false):FlxPath
	{
		this.speed = Math.abs(speed);
		_mode = mode;
		this.autoRotate = autoRotate;
		return this;
	}

	/**
	 * Starts movement along specified path.
	 *
	 * @param nodes              An optional array of path waypoints. If null then previously added points will be used. Movement is not started if the resulting array has no points.
	 * @param speed              The speed at which the object is moving on the path.
	 * @param mode               Path following behavior (like looping, horizontal only, etc).
	 * @param autoRotate         The object's angle should be adjusted to the path angle during path follow behavior.
	 * @param nodesAsReference   To pass the input array as reference (true) or to copy the points (false). Default is false.
	 * @return This path object.
	 */
	public function start(?nodes:Array<FlxPoint>, speed = 100.0, mode = FlxPathType.FORWARD, autoRotate = false,
			nodesAsReference:Bool = false):FlxPath
	{
		if (nodes != null)
		{
			if (nodesAsReference)
			{
				this.nodes = nodes;
			}
			else
			{
				this.nodes = nodes.copy();
			}
		}
		
		setProperties(speed, mode, autoRotate);
		
		if (this.nodes.length > 0)
		{
			restart();
		}
		return this;
	}

	/**
	 * Restarts this path. So object starts movement again from the first (or last) path point
	 * (depends on path movement behavior mode).
	 *
	 * @return This path object.
	 */
	override function restart():FlxPath
	{
		super.restart();
		active = nodes.length > 0;
		return this;
	}

	/**
	 * Change the path node this object is currently at.
	 *
	 * @param   nodeIndex  The index of the new node out of path.nodes.
	 */
	public function setNode(nodeIndex:Int):FlxPath
	{
		startAt(nodeIndex);
		return this;
	}

	function computeCenter(point:FlxPoint):FlxPoint
	{
		return centerMode.computeAnchor(object, point);
	}
	
	override function isTargetAtNext(elapsed:Float):Bool
	{
		// first check if we need to be pointing at the next node yet
		final center = computeCenter(FlxPoint.get());
		final deltaX = next.x - center.x;
		final deltaY = next.y - center.y;
		center.put();
		
		inline function abs(n:Float) return n > 0 ? n : -n;

		if (axes == X)
		{
			return abs(deltaX) < speed * elapsed;
		}
		
		if (axes == Y)
		{
			return abs(deltaY) < speed * elapsed;
		}
		
		return Math.sqrt(deltaX * deltaX + deltaY * deltaY) < speed * elapsed;
	}
	
	/**
	 * Internal function for moving the object along the path.
	 * The first half of the function decides if the object can advance to the next node in the path,
	 * while the second half handles actually picking a velocity toward the next node.
	 */
	override function updateTarget(elapsed:Float):Void
	{
		if (_firstUpdate)
		{
			if (immovable)
			{
				_wasObjectImmovable = object.immovable;
				object.immovable = true;
			}
			_firstUpdate = false;
		}

		// then just move toward the current node at the requested speed
		if (speed == 0)
			return;
		
		// set velocity based on path mode
		_point = computeCenter(_point);
		final node = next;

		if (!_point.equals(node))
		{
			calculateVelocity(node, axes == X, axes == Y);
		}
		else
		{
			object.velocity.set();
		}

		// then set object rotation if necessary
		if (autoRotate)
		{
			object.angularVelocity = 0;
			object.angularAcceleration = 0;
			object.angle = angle + angleOffset;
		}
	}

	function calculateVelocity(node:FlxPoint, horizontalOnly:Bool, verticalOnly:Bool):Void
	{
		if (horizontalOnly || _point.y == node.y)
		{
			object.velocity.x = (_point.x < node.x) ? speed : -speed;
			angle = (object.velocity.x < 0) ? 180 : 0;

			if (!horizontalOnly)
			{
				object.velocity.y = 0;
			}
		}
		else if (verticalOnly || _point.x == node.x)
		{
			object.velocity.y = (_point.y < node.y) ? speed : -speed;
			angle = (object.velocity.y < 0) ? -90 : 90;

			if (!verticalOnly)
			{
				object.velocity.x = 0;
			}
		}
		else
		{
			var velocity = object.velocity.copyFrom(node).subtractPoint(_point);
			velocity.length = speed;
			angle = velocity.degrees;
		}
	}

	/**
	 * Internal function that decides what node in the path to aim for next based on the behavior flags.
	 *
	 * @return The node (a `FlxPoint`) we are aiming for next.
	 */
	function advancePath(snap:Bool = true):FlxPoint
	{
		advance();
		
		return current;
	}
	
	override function advance()
	{
		if (axes.x)
		{
			object.x = next.x;
			switch (centerMode)
			{
				case ORIGIN:
					if (object is FlxSprite)
						object.x -= (cast object:FlxSprite).origin.x;
				case CUSTOM(offset):
					object.x -= offset.x;
				case CENTER:
					object.x -= object.width * 0.5;
				case TOP_LEFT:
			}
		}
		
		if (axes.y)
		{
			object.y = next.y;
			switch (centerMode)
			{
				case ORIGIN:
					if (object is FlxSprite)
						object.y -= (cast object:FlxSprite).origin.y;
				case CUSTOM(offset):
					object.y -= offset.y;
				case CENTER:
					object.y -= object.height * 0.5;
				case TOP_LEFT:
			}
		}
		
		super.advance();
	}
	
	#if FLX_DEBUG
	
	/**
	 * While this doesn't override `FlxBasic.drawDebug()`, the behavior is very similar.
	 * Based on this path data, it draws a simple lines-and-boxes representation of the path
	 * if the `drawDebug` mode was toggled in the debugger overlay.
	 * You can use `debugColor` to control the path's appearance.
	 *
	 * @param camera   The camera object the path will draw to.
	 */
	@:deprecated("FlxPath.debugDraw() is deprecated, use draw() OR drawDebugOnCamera(camera), instead")
	public function drawDebug(?camera:FlxCamera):Void
	{
		if (nodes == null || nodes.length <= 0 || ignoreDrawDebug)
			return;
		
		if (camera == null)
			camera = FlxG.camera;
		
		drawDebugOnCamera(camera);
	}
	#end

	/**
	 * Stops the path's movement.
	 *
	 * @return This path object.
	 */
	public function cancel():FlxPath
	{
		onEnd();

		if (object != null)
		{
			object.velocity.set(0, 0);
		}
		return this;
	}

	/**
	 * Called when the path ends, either by completing normally or via `cancel()`.
	 */
	function onEnd():Void
	{
		active = false;
		if (_wasObjectImmovable != null)
			object.immovable = _wasObjectImmovable;
		
		_wasObjectImmovable = null;
	}

	/**
	 * Add a new node to the end of the path at the specified location.
	 *
	 * @param x   X position of the new path point in world coordinates.
	 * @param y   Y position of the new path point in world coordinates.
	 *
	 * @return This path object.
	 */
	public function add(x:Float, y:Float):FlxPath
	{
		nodes.push(FlxPoint.get(x, y));
		return this;
	}

	/**
	 * Add a new node to the path at the specified location and index within the path.
	 *
	 * @param x       X position of the new path point in world coordinates.
	 * @param y       Y position of the new path point in world coordinates.
	 * @param index   Where within the list of path nodes to insert this new point.
	 *
	 * @return This path object.
	 */
	public function addAt(x:Float, y:Float, index:Int):FlxPath
	{
		if (index < 0)
			return this;
		nodes.insert(index, FlxPoint.get(x, y));
		return this;
	}

	/**
	 * Sometimes its easier or faster to just pass a point object instead of separate X and Y coordinates.
	 * This also gives you the option of not creating a new node but actually adding that specific
	 * FlxPoint object to the path.  This allows you to do neat things, like dynamic paths.
	 *
	 * @param node          The point in world coordinates you want to add to the path.
	 * @param asReference   Whether to add the point as a reference, or to create a new point with the specified values.
	 *
	 * @return This path object.
	 */
	public function addPoint(node:FlxPoint, asReference:Bool = false):FlxPath
	{
		if (asReference)
		{
			nodes.push(node);
		}
		else
		{
			nodes.push(FlxPoint.get(node.x, node.y));
		}
		return this;
	}

	/**
	 * Sometimes its easier or faster to just pass a point object instead of separate X and Y coordinates.
	 * This also gives you the option of not creating a new node but actually adding that specific
	 * FlxPoint object to the path.  This allows you to do neat things, like dynamic paths.
	 *
	 * @param node        The point in world coordinates you want to add to the path.
	 * @param index       Where within the list of path nodes to insert this new point.
	 * @param asReference Whether to add the point as a reference, or to create a new point with the specified values.
	 *
	 * @return This path object.
	 */
	public function addPointAt(node:FlxPoint, index:Int, asReference:Bool = false):FlxPath
	{
		if (index < 0)
			return this;
		if (asReference)
		{
			nodes.insert(index, node);
		}
		else
		{
			nodes.insert(index, FlxPoint.get(node.x, node.y));
		}
		return this;
	}

	/**
	 * Remove a node from the path.
	 * NOTE: only works with points added by reference or with references from nodes itself!
	 *
	 * @param node   The point object you want to remove from the path.
	 * @return The node that was excised.  Returns null if the node was not found.
	 */
	public function remove(node:FlxPoint):FlxPoint
	{
		var index:Int = nodes.indexOf(node);
		if (index >= 0)
		{
			return nodes.splice(index, 1)[0];
		}
		return null;
	}

	/**
	 * Remove a node from the path using the specified position in the list of path nodes.
	 *
	 * @param index   Where within the list of path nodes you want to remove a node.
	 * @return The node that was excised.  Returns null if there were no nodes in the path.
	 */
	public function removeAt(index:Int):FlxPoint
	{
		if (nodes.length <= 0)
		{
			return null;
		}
		if (index >= nodes.length - 1)
		{
			nodes.pop();
		}
		return nodes.splice(index, 1)[0];
	}

	/**
	 * Get the first node in the list.
	 *
	 * @return The first node in the path.
	 */
	public function head():FlxPoint
	{
		if (nodes.length > 0)
		{
			return nodes[0];
		}
		return null;
	}

	/**
	 * Get the last node in the list.
	 *
	 * @return The last node in the path.
	 */
	public function tail():FlxPoint
	{
		if (nodes.length > 0)
		{
			return nodes[nodes.length - 1];
		}
		return null;
	}
	
	inline function get_nodeIndex()
	{
		return nextIndex;
	}

	function set_immovable(value:Bool):Bool
	{
		if (_firstUpdate || finished || value == immovable)
			return this.immovable = value;

		if (value)
		{
			_wasObjectImmovable = object.immovable;
			object.immovable = true;
		}
		else if (_wasObjectImmovable != null)
		{
			object.immovable = _wasObjectImmovable;
			_wasObjectImmovable = null;
		}

		return this.immovable = value;
	}
	
	// deprecated 5.7.0
	@:noCompletion
	function set_autoCenter(value:Bool):Bool
	{
		centerMode = value ? CENTER : TOP_LEFT;
		return value;
	}
	
	// deprecated 5.7.0
	@:noCompletion
	function get_autoCenter():Bool
	{
		return centerMode.match(CENTER);
	}
	
	function get__inc()
	{
		return direction.toInt();
	}
	
	function set__inc(value:Int):Int
	{
		direction = value < 0 ? FlxPathDirection.BACKWARD : FlxPathDirection.FORWARD;
		return value;
	}
	
	function get__mode()
	{
		final isForward = direction == FlxPathDirection.FORWARD;
		return switch(loopType)
		{
			case FlxPathLoopType.ONCE:
				isForward ? FlxPathType.FORWARD : FlxPathType.BACKWARD;
			case FlxPathLoopType.LOOP:
				isForward ? FlxPathType.LOOP_FORWARD : FlxPathType.LOOP_BACKWARD;
			case FlxPathLoopType.YOYO:
				FlxPathType.YOYO;
		}
	}
	
	function set__mode(value:FlxPathType):FlxPathType
	{
		loopType = switch (value)
		{
			case FlxPathType.YOYO:
				FlxPathLoopType.YOYO;
			case FlxPathType.FORWARD | FlxPathType.BACKWARD:
				FlxPathLoopType.ONCE;
			case FlxPathType.LOOP_FORWARD | FlxPathType.LOOP_BACKWARD:
				FlxPathLoopType.LOOP;
		}
		
		direction = switch (value)
		{
			case FlxPathType.YOYO:
				direction;
			case FlxPathType.FORWARD | FlxPathType.LOOP_FORWARD:
				FlxPathDirection.FORWARD;
			case FlxPathType.BACKWARD | FlxPathType.LOOP_BACKWARD:
				FlxPathDirection.BACKWARD;
		}
		
		return value;
	}
	
	function get_object()
	{
		return target;
	}
	
	function set_object(value:FlxObject)
	{
		return target = value;
	}
}

/**
 * Path behavior controls
 */
enum abstract FlxPathType(Int) from Int to Int
{
	/**
	 * Move from the start of the path to the end then stop.
	 */
	var FORWARD = 0x000000;

	/**
	 * Move from the end of the path to the start then stop.
	 */
	var BACKWARD = 0x000001;

	/**
	 * Move from the start of the path to the end then directly back to the start, and start over.
	 */
	var LOOP_FORWARD = 0x000010;

	/**
	 * Move from the end of the path to the start then directly back to the end, and start over.
	 */
	var LOOP_BACKWARD = 0x000100;

	/**
	 * Move from the start of the path to the end then turn around and go back to the start, over and over.
	 */
	var YOYO = 0x001000;
}