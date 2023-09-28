package flixel.path;

import openfl.display.Graphics;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;

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
class FlxPath implements IFlxDestroyable
{
	/**
	 * Move from the start of the path to the end then stop.
	 */
	@:deprecated("Use FORWARD or FlxPathType.FORWARD instead")
	@:noCompletion
	public static inline var FORWARD = FlxPathType.FORWARD;

	/**
	 * Move from the end of the path to the start then stop.
	 */
	@:deprecated("Use BACKWARD or FlxPathType.BACKWARD instead")
	@:noCompletion
	public static inline var BACKWARD = FlxPathType.BACKWARD;

	/**
	 * Move from the start of the path to the end then directly back to the start, and start over.
	 */
	@:deprecated("Use LOOP_FORWARD or FlxPathType.LOOP_FORWARD instead")
	@:noCompletion
	public static inline var LOOP_FORWARD = FlxPathType.LOOP_FORWARD;

	/**
	 * Move from the end of the path to the start then directly back to the end, and start over.
	 */
	@:deprecated("Use LOOP_BACKWARD or FlxPathType.LOOP_BACKWARD instead")
	@:noCompletion
	public static inline var LOOP_BACKWARD = FlxPathType.LOOP_BACKWARD;

	/**
	 * Move from the start of the path to the end then turn around and go back to the start, over and over.
	 */
	@:deprecated("Use YOYO or FlxPathType.YOYO instead")
	@:noCompletion
	public static inline var YOYO = FlxPathType.YOYO;

	/**
	 * Path behavior controls: move from the start of the path to the end then stop.
	 */
	static var _point:FlxPoint = FlxPoint.get();

	/**
	 * The list of FlxPoints that make up the path data.
	 */
	public var nodes(get, set):Array<FlxPoint>;

	/**
	 * An actual array, which holds all the path points.
	 */
	var _nodes:Array<FlxPoint>;

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
	 * Whether the object should auto-center the path or at its origin.
	 */
	public var autoCenter:Bool = true;

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

	/**
	 * Pauses or checks the pause state of the path.
	 */
	public var active:Bool = false;

	public var onComplete:FlxPath->Void;

	#if FLX_DEBUG
	/**
	 * Specify a debug display color for the path. Default is WHITE.
	 */
	public var debugDrawData:FlxPathDrawData = {};

	/**
	 * Setting this to true will prevent the object from appearing
	 * when FlxG.debugger.drawDebug is true.
	 */
	public var ignoreDrawDebug:Bool = false;
	#end

	/**
	 * Tracks which node of the path this object is currently moving toward.
	 */
	public var nodeIndex(default, null):Int = 0;

	public var finished(default, null):Bool = false;

	/**
	 * Whether to limit movement to certain axes.
	 */
	public var axes:FlxAxes = XY;

	/**
	 * Internal tracker for path behavior flags (like looping, yoyo, etc).
	 */
	var _mode:FlxPathType;

	/**
	 * Internal helper for node navigation, specifically yo-yo and backwards movement.
	 */
	var _inc:Int = 1;

	var _wasObjectImmovable:Null<Bool> = null;

	var _firstUpdate:Bool = false;

	/**
	 * Object which will follow this path
	 */
	@:allow(flixel.FlxObject)
	var object:FlxObject;

	public function new(?nodes:Array<FlxPoint>)
	{
		if (nodes != null)
			_nodes = nodes.copy();
		else
			_nodes = [];
	}

	/**
	 * Just resets some debugging related variables (for debugger renderer).
	 * Also resets `autoCenter` to `true`.
	 * @return This path object.
	 */
	public function reset():FlxPath
	{
		#if FLX_DEBUG
		debugDrawData = {};
		ignoreDrawDebug = false;
		#end
		autoCenter = true;
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
				_nodes = nodes;
			}
			else
			{
				_nodes = nodes.copy();
			}
		}
		setProperties(speed, mode, autoRotate);
		if (_nodes.length > 0)
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
	public function restart():FlxPath
	{
		finished = false;
		_firstUpdate = true;
		active = _nodes.length > 0;
		if (!active)
		{
			return this;
		}

		// get starting node
		if ((_mode == FlxPathType.BACKWARD) || (_mode == FlxPathType.LOOP_BACKWARD))
		{
			nodeIndex = _nodes.length - 1;
			_inc = -1;
		}
		else
		{
			nodeIndex = 0;
			_inc = 1;
		}

		return this;
	}

	/**
	 * Change the path node this object is currently at.
	 *
	 * @param  NodeIndex    The index of the new node out of path.nodes.
	 */
	public function setNode(nodeIndex:Int):FlxPath
	{
		if (nodeIndex < 0)
			nodeIndex = 0;
		else if (nodeIndex > _nodes.length - 1)
			nodeIndex = _nodes.length - 1;

		this.nodeIndex = nodeIndex;
		advancePath();
		return this;
	}

	/**
	 * Internal function for moving the object along the path.
	 * The first half of the function decides if the object can advance to the next node in the path,
	 * while the second half handles actually picking a velocity toward the next node.
	 */
	public function update(elapsed:Float):Void
	{
		if (object == null)
			return;

		if (_firstUpdate)
		{
			if (immovable)
			{
				_wasObjectImmovable = object.immovable;
				object.immovable = true;
			}
			_firstUpdate = false;
		}

		// first check if we need to be pointing at the next node yet
		_point.x = object.x;
		_point.y = object.y;
		if (autoCenter)
		{
			_point.add(object.width * 0.5, object.height * 0.5);
		}
		var node:FlxPoint = _nodes[nodeIndex];
		var deltaX:Float = node.x - _point.x;
		var deltaY:Float = node.y - _point.y;

		var horizontalOnly:Bool = axes == X;
		var verticalOnly:Bool = axes == Y;

		if (horizontalOnly)
		{
			if (((deltaX > 0) ? deltaX : -deltaX) < speed * elapsed)
			{
				node = advancePath();
			}
		}
		else if (verticalOnly)
		{
			if (((deltaY > 0) ? deltaY : -deltaY) < speed * elapsed)
			{
				node = advancePath();
			}
		}
		else
		{
			if (Math.sqrt(deltaX * deltaX + deltaY * deltaY) < speed * elapsed)
			{
				node = advancePath();
			}
		}

		// then just move toward the current node at the requested speed
		if (object != null && speed != 0)
		{
			// set velocity based on path mode
			_point.x = object.x;
			_point.y = object.y;

			if (autoCenter)
			{
				_point.add(object.width * 0.5, object.height * 0.5);
			}

			if (!_point.equals(node))
			{
				calculateVelocity(node, horizontalOnly, verticalOnly);
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

			if (finished)
			{
				cancel();
			}
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
		if (snap)
		{
			var oldNode:FlxPoint = _nodes[nodeIndex];
			if (oldNode != null)
			{
				if (axes.x)
				{
					object.x = oldNode.x;
					if (autoCenter)
						object.x -= object.width * 0.5;
				}
				if (axes.y)
				{
					object.y = oldNode.y;
					if (autoCenter)
						object.y -= object.height * 0.5;
				}
			}
		}

		var callComplete:Bool = false;
		nodeIndex += _inc;

		if (_mode == FlxPathType.BACKWARD)
		{
			if (nodeIndex < 0)
			{
				nodeIndex = 0;
				callComplete = true;
				onEnd();
			}
		}
		else if (_mode == FlxPathType.LOOP_FORWARD)
		{
			if (nodeIndex >= _nodes.length)
			{
				callComplete = true;
				nodeIndex = 0;
			}
		}
		else if (_mode == FlxPathType.LOOP_BACKWARD)
		{
			if (nodeIndex < 0)
			{
				nodeIndex = _nodes.length - 1;
				callComplete = true;
				if (nodeIndex < 0)
				{
					nodeIndex = 0;
				}
			}
		}
		else if (_mode == FlxPathType.YOYO)
		{
			if (_inc > 0)
			{
				if (nodeIndex >= _nodes.length)
				{
					nodeIndex = _nodes.length - 2;
					callComplete = true;
					if (nodeIndex < 0)
					{
						nodeIndex = 0;
					}
					_inc = -_inc;
				}
			}
			else if (nodeIndex < 0)
			{
				nodeIndex = 1;
				callComplete = true;
				if (nodeIndex >= _nodes.length)
				{
					nodeIndex = _nodes.length - 1;
				}
				if (nodeIndex < 0)
				{
					nodeIndex = 0;
				}
				_inc = -_inc;
			}
		}
		else
		{
			if (nodeIndex >= _nodes.length)
			{
				nodeIndex = _nodes.length - 1;
				callComplete = true;
				onEnd();
			}
		}

		if (callComplete && onComplete != null)
		{
			onComplete(this);
		}

		return _nodes[nodeIndex];
	}

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
		finished = true;
		active = false;
		if (_wasObjectImmovable != null)
			object.immovable = _wasObjectImmovable;
		_wasObjectImmovable = null;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		FlxDestroyUtil.putArray(_nodes);
		_nodes = null;
		object = null;
		onComplete = null;
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
		_nodes.push(FlxPoint.get(x, y));
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
		_nodes.insert(index, FlxPoint.get(x, y));
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
			_nodes.push(node);
		}
		else
		{
			_nodes.push(FlxPoint.get(node.x, node.y));
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
			_nodes.insert(index, node);
		}
		else
		{
			_nodes.insert(index, FlxPoint.get(node.x, node.y));
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
		var index:Int = _nodes.indexOf(node);
		if (index >= 0)
		{
			return _nodes.splice(index, 1)[0];
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
		if (_nodes.length <= 0)
		{
			return null;
		}
		if (index >= _nodes.length - 1)
		{
			_nodes.pop();
		}
		return _nodes.splice(index, 1)[0];
	}

	/**
	 * Get the first node in the list.
	 *
	 * @return The first node in the path.
	 */
	public function head():FlxPoint
	{
		if (_nodes.length > 0)
		{
			return _nodes[0];
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
		if (_nodes.length > 0)
		{
			return _nodes[_nodes.length - 1];
		}
		return null;
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
	@:access(flixel.FlxCamera)
	public function drawDebug(?camera:FlxCamera):Void
	{
		if (_nodes == null || _nodes.length <= 0)
		{
			return;
		}

		if (camera == null)
		{
			camera = FlxG.camera;
		}

		var gfx:Graphics = null;

		// Set up our global flash graphics object to draw out the path
		if (FlxG.renderBlit)
		{
			gfx = FlxSpriteUtil.flashGfx;
			gfx.clear();
		}
		else
		{
			gfx = camera.debugLayer.graphics;
		}

		// Then fill up the object with node and path graphics
		var length = _nodes.length;
		for (i in 0...length)
		{
			// get a reference to the current node
			var node = _nodes[i];

			// find the screen position of the node on this camera
			_point.x = node.x - (camera.scroll.x * object.scrollFactor.x); // copied from getScreenPosition()
			_point.y = node.y - (camera.scroll.y * object.scrollFactor.y);

			_point = camera.transformPoint(_point);

			// decide what color this node should be
			var nodeSize:Int = debugDrawData.nodeSize;
			var nodeColor:FlxColor = debugDrawData.nodeColor;
			if (length > 1)
			{
				if (i == 0)
				{
					nodeColor = debugDrawData.startColor;
					nodeSize = debugDrawData.startSize;
				}
				else if (i == length - 1)
				{
					nodeColor = debugDrawData.endColor;
					nodeSize = debugDrawData.endSize;
				}
			}

			// draw a box for the node
			gfx.beginFill(nodeColor.rgb, nodeColor.alphaFloat);
			gfx.lineStyle();
			var nodeOffset = Math.floor(nodeSize * 0.5);
			gfx.drawRect(_point.x - nodeOffset, _point.y - nodeOffset, nodeSize, nodeSize);
			gfx.endFill();

			// then find the next node in the path
			var nextNode:FlxPoint;
			if (i < length - 1)
			{
				nextNode = _nodes[i + 1];
			}
			else
			{
				nextNode = _nodes[i];
			}

			// then draw a line to the next node
			var lineOffset = debugDrawData.lineSize / 2;
			gfx.moveTo(_point.x + lineOffset, _point.y + lineOffset);
			gfx.lineStyle(debugDrawData.lineSize, debugDrawData.lineColor & 0xFFFFFF, debugDrawData.lineColor.alphaFloat);
			_point.x = nextNode.x - (camera.scroll.x * object.scrollFactor.x); // copied from getScreenPosition()
			_point.y = nextNode.y - (camera.scroll.y * object.scrollFactor.y);

			if (FlxG.renderBlit)
				_point.subtract(camera.viewMarginX, camera.viewMarginY);

			gfx.lineTo(_point.x + lineOffset, _point.y + lineOffset);
		}

		if (FlxG.renderBlit)
		{
			// then stamp the path down onto the game buffer
			camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		}
	}
	#end

	function get_nodes():Array<FlxPoint>
	{
		return _nodes;
	}

	function set_nodes(nodes:Array<FlxPoint>):Array<FlxPoint>
	{
		if (nodes != null)
		{
			_nodes = nodes;
		}
		return _nodes;
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

@:structInit
class FlxPathDrawData
{
	public var lineColor  = FlxColor.WHITE;
	public var nodeColor  = FlxColor.WHITE;
	public var startColor = FlxColor.GREEN;
	public var endColor   = FlxColor.RED;
	public var lineSize   = 1;
	public var nodeSize   = 3;
	public var startSize  = 5;
	public var endSize    = 5;
}
