package flixel.util;

import flash.display.Graphics;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

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
 * path.start(points, 50, FlxPath.FORWARD);
 * ```
 *
 * You can also do this in one line:
 *
 * ```haxe
 * object.path = new FlxPath().start([new FlxPoint(0, 0), new FlxPoint(100, 0)], 50, FlxPath.FORWARD);
 * ```
 *
 * ...or using some more chaining:
 *
 * ```haxe
 * object.path = new FlxPath().add(0, 0).add(100, 0).start(50, FlxPath.FORWARD);
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
	 * Path behavior controls: move from the start of the path to the end then stop.
	 */
	public static inline var FORWARD:Int = 0x000000;

	/**
	 * Path behavior controls: move from the end of the path to the start then stop.
	 */
	public static inline var BACKWARD:Int = 0x000001;

	/**
	 * Path behavior controls: move from the start of the path to the end then directly back to the start, and start over.
	 */
	public static inline var LOOP_FORWARD:Int = 0x000010;

	/**
	 * Path behavior controls: move from the end of the path to the start then directly back to the end, and start over.
	 */
	public static inline var LOOP_BACKWARD:Int = 0x000100;

	/**
	 * Path behavior controls: move from the start of the path to the end then turn around and go back to the start, over and over.
	 */
	public static inline var YOYO:Int = 0x001000;

	/**
	 * Path behavior controls: ignores any vertical component to the path data, only follows side to side.
	 */
	public static inline var HORIZONTAL_ONLY:Int = 0x010000;

	/**
	 * Path behavior controls: ignores any horizontal component to the path data, only follows up and down.
	 */
	public static inline var VERTICAL_ONLY:Int = 0x100000;

	/**
	 * Internal helper for keeping new variable instantiations under control.
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
	 * The angle in degrees between this object and the next node, where 0 is directly upward, and 90 is to the right.
	 */
	public var angle:Float = 0;

	/**
	 * Whether the object should auto-center the path or at its origin.
	 */
	public var autoCenter:Bool = true;

	/**
	 * Pauses or checks the pause state of the path.
	 */
	public var active:Bool = false;

	public var onComplete:FlxPath->Void;

	#if FLX_DEBUG
	/**
	 * Specify a debug display color for the path. Default is white.
	 */
	public var debugColor:FlxColor = 0xffffff;

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
	 * Internal tracker for path behavior flags (like looping, horizontal only, etc).
	 */
	var _mode:Int;

	/**
	 * Internal helper for node navigation, specifically yo-yo and backwards movement.
	 */
	var _inc:Int = 1;

	/**
	 * Internal flag for whether the object's angle should be adjusted to the path angle during path follow behavior.
	 */
	var _autoRotate:Bool = false;

	var _wasObjectImmovable:Null<Bool> = null;

	var _firstUpdate:Bool = false;

	/**
	 * Object which will follow this path
	 */
	@:allow(flixel.FlxObject)
	var object:FlxObject;

	public function new(?Nodes:Array<FlxPoint>)
	{
		if (Nodes != null)
			_nodes = Nodes.copy();
		else
			_nodes = [];
	}

	/**
	 * Just resets some debugging related variables (for debugger renderer).
	 * Also resets `autoCenter` to `true`.
	 * @return	This path object.
	 */
	public function reset():FlxPath
	{
		#if FLX_DEBUG
		debugColor = 0xffffff;
		ignoreDrawDebug = false;
		#end
		autoCenter = true;
		return this;
	}

	/**
	 * Sets the following properties: `speed`, `mode` and auto rotation.
	 *
	 * @param	Speed			The speed at which the object is moving on the path.
	 * @param	Mode			Path following behavior (like looping, horizontal only, etc).
	 * @param	AutoRotate		Whether the object's angle should be adjusted to the path angle during path follow behavior.
	 * @return	This path object.
	 * @since   4.2.0
	 */
	public function setProperties(Speed:Float = 100, Mode:Int = FlxPath.FORWARD, AutoRotate:Bool = false):FlxPath
	{
		speed = Math.abs(Speed);
		_mode = Mode;
		_autoRotate = AutoRotate;
		return this;
	}

	/**
	 * Starts movement along specified path.
	 *
	 * @param	Nodes				An optional array of path waypoints. If null then previously added points will be used. Movement is not started if the resulting array has no points.
	 * @param	Speed				The speed at which the object is moving on the path.
	 * @param	Mode				Path following behavior (like looping, horizontal only, etc).
	 * @param	AutoRotate			Whether the object's angle should be adjusted to the path angle during path follow behavior.
	 * @param   NodesAsReference 	Whether to pass the input array as reference (true) or to copy the points (false). Default is false.
	 * @return	This path object.
	 */
	public function start(?Nodes:Array<FlxPoint>, Speed:Float = 100, Mode:Int = FlxPath.FORWARD, AutoRotate:Bool = false,
			NodesAsReference:Bool = false):FlxPath
	{
		if (Nodes != null)
		{
			if (NodesAsReference)
			{
				_nodes = Nodes;
			}
			else
			{
				_nodes = Nodes.copy();
			}
		}
		setProperties(Speed, Mode, AutoRotate);
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
	 * @return	This path object.
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
		if ((_mode == FlxPath.BACKWARD) || (_mode == FlxPath.LOOP_BACKWARD))
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
	public function setNode(NodeIndex:Int):FlxPath
	{
		if (NodeIndex < 0)
			NodeIndex = 0;
		else if (NodeIndex > _nodes.length - 1)
			NodeIndex = _nodes.length - 1;

		nodeIndex = NodeIndex;
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
			_wasObjectImmovable = object.immovable;
			object.immovable = true;
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

		var horizontalOnly:Bool = (_mode & FlxPath.HORIZONTAL_ONLY) > 0;
		var verticalOnly:Bool = (_mode & FlxPath.VERTICAL_ONLY) > 0;

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
			if (_autoRotate)
			{
				object.angularVelocity = 0;
				object.angularAcceleration = 0;
				object.angle = angle;
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
			angle = (object.velocity.x < 0) ? -90 : 90;

			if (!horizontalOnly)
			{
				object.velocity.y = 0;
			}
		}
		else if (verticalOnly || _point.x == node.x)
		{
			object.velocity.y = (_point.y < node.y) ? speed : -speed;
			angle = (object.velocity.y < 0) ? 0 : 180;

			if (!verticalOnly)
			{
				object.velocity.x = 0;
			}
		}
		else
		{
			object.velocity.x = (_point.x < node.x) ? speed : -speed;
			object.velocity.y = (_point.y < node.y) ? speed : -speed;

			angle = _point.angleBetween(node);

			object.velocity.set(0, -speed);
			object.velocity.rotate(FlxPoint.weak(0, 0), angle);
		}
	}

	/**
	 * Internal function that decides what node in the path to aim for next based on the behavior flags.
	 *
	 * @return	The node (a `FlxPoint`) we are aiming for next.
	 */
	function advancePath(Snap:Bool = true):FlxPoint
	{
		if (Snap)
		{
			var oldNode:FlxPoint = _nodes[nodeIndex];
			if (oldNode != null)
			{
				if ((_mode & FlxPath.VERTICAL_ONLY) == 0)
				{
					object.x = oldNode.x;
					if (autoCenter)
						object.x -= object.width * 0.5;
				}
				if ((_mode & FlxPath.HORIZONTAL_ONLY) == 0)
				{
					object.y = oldNode.y;
					if (autoCenter)
						object.y -= object.height * 0.5;
				}
			}
		}

		var callComplete:Bool = false;
		nodeIndex += _inc;

		if ((_mode & FlxPath.BACKWARD) > 0)
		{
			if (nodeIndex < 0)
			{
				nodeIndex = 0;
				callComplete = true;
				onEnd();
			}
		}
		else if ((_mode & FlxPath.LOOP_FORWARD) > 0)
		{
			if (nodeIndex >= _nodes.length)
			{
				callComplete = true;
				nodeIndex = 0;
			}
		}
		else if ((_mode & FlxPath.LOOP_BACKWARD) > 0)
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
		else if ((_mode & FlxPath.YOYO) > 0)
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
	 * @return	This path object.
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
	 * @param	X	X position of the new path point in world coordinates.
	 * @param	Y	Y position of the new path point in world coordinates.
	 *
	 * @return	This path object.
	 */
	public function add(X:Float, Y:Float):FlxPath
	{
		_nodes.push(FlxPoint.get(X, Y));
		return this;
	}

	/**
	 * Add a new node to the path at the specified location and index within the path.
	 *
	 * @param	X		X position of the new path point in world coordinates.
	 * @param	Y		Y position of the new path point in world coordinates.
	 * @param	Index	Where within the list of path nodes to insert this new point.
	 *
	 * @return	This path object.
	 */
	public function addAt(X:Float, Y:Float, Index:Int):FlxPath
	{
		if (Index < 0)
			return this;
		_nodes.insert(Index, FlxPoint.get(X, Y));
		return this;
	}

	/**
	 * Sometimes its easier or faster to just pass a point object instead of separate X and Y coordinates.
	 * This also gives you the option of not creating a new node but actually adding that specific
	 * FlxPoint object to the path.  This allows you to do neat things, like dynamic paths.
	 *
	 * @param	Node			The point in world coordinates you want to add to the path.
	 * @param	AsReference		Whether to add the point as a reference, or to create a new point with the specified values.
	 *
	 * @return	This path object.
	 */
	public function addPoint(Node:FlxPoint, AsReference:Bool = false):FlxPath
	{
		if (AsReference)
		{
			_nodes.push(Node);
		}
		else
		{
			_nodes.push(FlxPoint.get(Node.x, Node.y));
		}
		return this;
	}

	/**
	 * Sometimes its easier or faster to just pass a point object instead of separate X and Y coordinates.
	 * This also gives you the option of not creating a new node but actually adding that specific
	 * FlxPoint object to the path.  This allows you to do neat things, like dynamic paths.
	 *
	 * @param	Node			The point in world coordinates you want to add to the path.
	 * @param	Index			Where within the list of path nodes to insert this new point.
	 * @param	AsReference		Whether to add the point as a reference, or to create a new point with the specified values.
	 *
	 *	@return	This path object.
	 */
	public function addPointAt(Node:FlxPoint, Index:Int, AsReference:Bool = false):FlxPath
	{
		if (Index < 0)
			return this;
		if (AsReference)
		{
			_nodes.insert(Index, Node);
		}
		else
		{
			_nodes.insert(Index, FlxPoint.get(Node.x, Node.y));
		}
		return this;
	}

	/**
	 * Remove a node from the path.
	 * NOTE: only works with points added by reference or with references from nodes itself!
	 *
	 * @param	Node	The point object you want to remove from the path.
	 * @return	The node that was excised.  Returns null if the node was not found.
	 */
	public function remove(Node:FlxPoint):FlxPoint
	{
		var index:Int = _nodes.indexOf(Node);
		if (index >= 0)
		{
			return _nodes.splice(index, 1)[0];
		}
		return null;
	}

	/**
	 * Remove a node from the path using the specified position in the list of path nodes.
	 *
	 * @param	Index	Where within the list of path nodes you want to remove a node.
	 * @return	The node that was excised.  Returns null if there were no nodes in the path.
	 */
	public function removeAt(Index:Int):FlxPoint
	{
		if (_nodes.length <= 0)
		{
			return null;
		}
		if (Index >= _nodes.length - 1)
		{
			_nodes.pop();
		}
		return _nodes.splice(Index, 1)[0];
	}

	/**
	 * Get the first node in the list.
	 *
	 * @return	The first node in the path.
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
	 * @return	The last node in the path.
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
	 * @param	Camera		The camera object the path will draw to.
	 */
	@:access(flixel.FlxCamera)
	public function drawDebug(?Camera:FlxCamera):Void
	{
		if (_nodes == null || _nodes.length <= 0)
		{
			return;
		}
		if (Camera == null)
		{
			Camera = FlxG.camera;
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
			gfx = Camera.debugLayer.graphics;
		}

		// Then fill up the object with node and path graphics
		var node:FlxPoint;
		var nextNode:FlxPoint;
		var i:Int = 0;
		var l:Int = _nodes.length;
		while (i < l)
		{
			// get a reference to the current node
			node = _nodes[i];

			// find the screen position of the node on this camera
			_point.x = node.x - (Camera.scroll.x * object.scrollFactor.x); // copied from getScreenPosition()
			_point.y = node.y - (Camera.scroll.y * object.scrollFactor.y);

			_point = Camera.transformPoint(_point);

			// decide what color this node should be
			var nodeSize:Int = 2;
			if ((i == 0) || (i == l - 1))
			{
				nodeSize *= 2;
			}
			var nodeColor:FlxColor = debugColor;
			if (l > 1)
			{
				if (i == 0)
				{
					nodeColor = FlxColor.GREEN;
				}
				else if (i == l - 1)
				{
					nodeColor = FlxColor.RED;
				}
			}

			// draw a box for the node
			gfx.beginFill(nodeColor, 0.5);
			gfx.lineStyle();
			gfx.drawRect(_point.x - nodeSize * 0.5, _point.y - nodeSize * 0.5, nodeSize, nodeSize);
			gfx.endFill();

			// then find the next node in the path
			var lineAlpha:Float = 0.3;
			if (i < l - 1)
			{
				nextNode = _nodes[i + 1];
			}
			else
			{
				nextNode = _nodes[i];
			}

			// then draw a line to the next node
			gfx.moveTo(_point.x, _point.y);
			gfx.lineStyle(1, debugColor, lineAlpha);
			_point.x = nextNode.x - (Camera.scroll.x * object.scrollFactor.x); // copied from getScreenPosition()
			_point.y = nextNode.y - (Camera.scroll.y * object.scrollFactor.y);

			if (FlxG.renderBlit)
				_point.subtract(Camera.viewOffsetX, Camera.viewOffsetY);

			gfx.lineTo(_point.x, _point.y);

			i++;
		}

		if (FlxG.renderBlit)
		{
			// then stamp the path down onto the game buffer
			Camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		}
	}
	#end

	function get_nodes():Array<FlxPoint>
	{
		return _nodes;
	}

	function set_nodes(Nodes:Array<FlxPoint>):Array<FlxPoint>
	{
		if (Nodes != null)
		{
			_nodes = Nodes;
		}
		return _nodes;
	}
}
