package flixel.path;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSpriteUtil;
import openfl.display.Graphics;

/**
 * A simple ordered list of nodes that iterates based on conditions. For this class,
 * that condition is not defined, and must be implemented in your extending class.
 * 
 * ## Example
 * The following is an example of a class that moves the target to the next node and
 * and advances the iterator when it is near.
```haxe
class SimplePath extends flixel.path.FlxBasePath
{
	public var speed:Float;
	
	public function new (?nodes, ?target, speed = 100.0)
	{
		this.speed = speed;
		super(nodes, target);
	}
	
	override function isTargetAtNext(elapsed:Float):Bool
	{
		final frameSpeed = elapsed * speed;
		final deltaX = next.x - target.x;
		final deltaY = next.y - target.y;
		// Whether the distance remaining is less than the distance we will travel this frame
		return Math.sqrt(deltaX * deltaX + deltaY * deltaY) <= frameSpeed;
	}
	
	override function updateTarget(elapsed:Float)
	{
		// Aim velocity towards the next node then set magnitude to the desired speed
		target.velocity.set(next.x - target.x, next.y - target.y);
		target.velocity.length = speed;
	}
}
```
 * 
 * @since 5.9.0
 */
typedef FlxBasePath = FlxTypedBasePath<FlxObject>;

/**
 * Typed version of `FlxBasePath` for flexibility in derived classes
 * 
 * @see flixel.path.FlxBasePath
 * @since 5.9.0
 */
class FlxTypedBasePath<TTarget:FlxBasic> extends FlxBasic implements IFlxDestroyable
{
	/** The list of points that make up the path data */
	public var nodes:Array<FlxPoint>;
	
	/** The target traversing our path */
	public var target:TTarget;
	
	/** Behavior when the end(s) are reached */
	public var loopType:FlxPathLoopType = LOOP;
	
	/** The direction the list of nodes is being traversed. `FORWARD` leads to the last node */
	public var direction(default, null) = FlxPathDirection.FORWARD;
	
	/** The length of the `nodes` array */
	public var totalNodes(get, never):Int;
	
	/** Whether this path is done, only `true` when `loopType` is `ONCE` */
	public var finished(get, never):Bool;
	
	/** Called whenenever the end is reached, for `YOYO` this means both ends */
	public var onEndReached(default, null) = new FlxTypedSignal<(FlxTypedBasePath<TTarget>)->Void>();
	
	/** Called whenenever any node reached */
	public var onNodeReached(default, null) = new FlxTypedSignal<(FlxTypedBasePath<TTarget>)->Void>();
	
	/** Called when the end is reached and `loopType1 is `ONCE` */
	public var onFinish(default, null) = new FlxTypedSignal<(FlxTypedBasePath<TTarget>)->Void>();
	
	/** The index of the last node the target has reached, `-1` means "no current node" */
	public var currentIndex(default, null):Int = -1;
	/** The index of the node the target is currently moving toward, `-1` means the path is finished */
	public var nextIndex(default, null):Int = -1;
	
	/** The last node the target has reached */
	public var current(get, never):Null<FlxPoint>;
	/** The node the target is currently moving toward */
	public var next(get, never):Null<FlxPoint>;
	
	/**
	 * Creates a new path. If valid nodes and a target are given it will start immediately.
	 * 
	 * @param   nodes   An Optional array of nodes. Unlike `FlxPath`, no copy is made
	 * @param   target  The target traversing our path
	 */
	public function new (?nodes:Array<FlxPoint>, ?target:TTarget, direction = FORWARD)
	{
		this.nodes = nodes;
		this.target = target;
		this.direction = direction;
		super();
		
		if (nodes != null && nodes.length > 0 && target != null)
			restart();
	}
	
	override function destroy():Void
	{
		FlxDestroyUtil.putArray(nodes);
		nodes = null;
		onEndReached.removeAll();
	}
	
	/**
	 * Sets the current node to the beginning, or the end if `direction` is `BACKWARD`
	 */
	public function restart():FlxTypedBasePath<TTarget>
	{
		currentIndex = getStartingNode();
		setNextIndex();
		
		return this;
	}
	
	function getStartingNode()
	{
		return direction == BACKWARD ? nodes.length - 1 : 0;
	}
	
	function nodeReached()
	{
		advance();
		
		onNodeReached.dispatch(this);
		
		if (finished)
		{
			onFinish.dispatch(this);
		}
	}
	
	/** Iterates to the next node according to the desired `direction` */
	function advance()
	{
		if (finished)
		{
			FlxG.log.warn('Cannot advance after path is finished');
			return;
		}
		
		currentIndex = nextIndex;
		setNextIndex();
	}
	
	/**
	 * Determines the next index based on the current index and direction.
	 * Fires onEndReached if the end is reached
	 */
	function setNextIndex()
	{
		// reached last
		if (currentIndex == nodes.length - 1 && direction == FORWARD)
		{
			nextIndex = switch (loopType)
			{
				case ONCE: -1;
				case LOOP: 0;
				case YOYO:
					direction = BACKWARD;
					currentIndex - 1;
			}
			onEndReached.dispatch(this);
			return;
		}
		
		// reached first
		if (currentIndex == 0 && direction == BACKWARD)
		{
			nextIndex = switch (loopType)
			{
				case ONCE: -1;
				case LOOP: nodes.length - 1;
				case YOYO:
					direction = FORWARD;
					currentIndex + 1;
			}
			onEndReached.dispatch(this);
			return;
		}
		
		nextIndex = currentIndex + direction.toInt();
	}
	
	/**
	 * Change the path node this object is currently at.
	 *
	 * @param  index      The index of the new node out of path.nodes.
	 * @param  direction  Whether to head towards the head or the tail, if `null` the previous
	 *                    value is maintained
	 */
	public function startAt(index:Int):FlxTypedBasePath<TTarget>
	{
		currentIndex = index;
		setNextIndex();
		
		return this;
	}
	
	// Following logic
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (finished || target == null)
			return;
		
		if (isTargetAtNext(elapsed))
		{
			nodeReached();
			if (finished)
				return;
		}
		
		updateTarget(elapsed);
	}
	
	/** Override this with your logic that whether the target has reached the next node */
	function isTargetAtNext(elapsed:Float):Bool
	{
		throw 'isTargetAtNext is not implemented';
	}
	
	/** Override this with your logic that brings the target towards the next node */
	function updateTarget(elapsed:Float) {}
	
	inline function get_totalNodes()
	{
		return nodes != null ? nodes.length : 0;
	}
	
	inline function get_finished()
	{
		return nextIndex < 0;
	}
	
	inline function get_current()
	{
		return nodes != null && currentIndex >= 0 ? nodes[currentIndex] : null;
	}
	
	inline function get_next()
	{
		return nodes != null && nextIndex >= 0? nodes[nextIndex] : null;
	}
	
	/**
	 * Determines to which camera this will draw (or debug draw). The priority is from high to low:
	 * - Whatever value you've manually given the `cameras` or `camera` field
	 * - Any cameras drawing path's `container`, if one exists
	 * - Any cameras drawing path's `target`, if one exists
	 * - The default cameras
	 */
	override function getCameras():Array<FlxCamera>
	{
		return if (_cameras != null)
				_cameras;
			else if (container != null)
				container.getCameras();
			else if (target != null)
				target.getCameras();
			else
				@:privateAccess FlxCamera._defaultCameras;
	}
	
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
	
	override function draw()
	{
		// super.draw();
		
		if (FlxG.debugger.drawDebug && !ignoreDrawDebug)
		{
			FlxBasic.visibleCount++;
			
			for (camera in getCameras())
			{
				drawDebugOnCamera(camera);
			}
		}
	}
	
	/**
	 * Based on this path data, it draws a simple lines-and-boxes representation of the path
	 * if the `drawDebug` mode was toggled in the debugger overlay.
	 * You can use `debugColor` to control the path's appearance.
	 *
	 * @param camera   The camera object the path will draw to.
	 */
	public function drawDebugOnCamera(camera:FlxCamera):Void
	{
		// Set up our global flash graphics object to draw out the path
		var gfx:Graphics = null;
		if (FlxG.renderBlit)
		{
			gfx = FlxSpriteUtil.flashGfx;
			gfx.clear();
		}
		else
		{
			gfx = camera.debugLayer.graphics;
		}
		
		final length = nodes.length;
		// Then fill up the object with node and path graphics
		for (i=>node in nodes)
		{
			// find the screen position of the node on this camera
			final prevNodeScreen = copyWorldToScreenPos(node, camera);

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
			drawNode(gfx, prevNodeScreen, nodeSize, nodeColor);
			
			if (i + 1 < length || loopType == LOOP)
			{
				// draw a line to the next node, if LOOP, get connect the tail and head
				final nextNode = nodes[(i + 1) % length];
				final nextNodeScreen = copyWorldToScreenPos(nextNode, camera);
				drawLine(gfx, prevNodeScreen, nextNodeScreen);
				nextNodeScreen.put();
			}
			prevNodeScreen.put();
		}
		
		if (FlxG.renderBlit)
		{
			// then stamp the path down onto the game buffer
			camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		}
	}
	
	@:access(flixel.FlxCamera)
	function copyWorldToScreenPos(point:FlxPoint, camera:FlxCamera, ?result:FlxPoint)
	{
		result = point.clone(result);
		if (target is FlxObject)
		{
			final object:FlxObject = cast target;
			result.x -= camera.scroll.x * object.scrollFactor.x;
			result.y -= camera.scroll.y * object.scrollFactor.y;
		}
		
		if (FlxG.renderBlit)
		{
			result.x -= camera.viewMarginX;
			result.y -= camera.viewMarginY;
		}
		
		camera.transformPoint(result);
		return result;
	}
	
	inline function drawNode(gfx:Graphics, node:FlxPoint, size:Int, color:FlxColor)
	{
		gfx.beginFill(color.rgb, color.alphaFloat);
		gfx.lineStyle();
		final offset = Math.floor(size * 0.5);
		gfx.drawRect(node.x - offset, node.y - offset, size, size);
		gfx.endFill();
	}
	
	function drawLine(gfx:Graphics, node1:FlxPoint, node2:FlxPoint)
	{
		// then draw a line to the next node
		final color = debugDrawData.lineColor;
		final size = debugDrawData.lineSize;
		gfx.lineStyle(size, color.rgb, color.alphaFloat);
		
		final lineOffset = debugDrawData.lineSize / 2;
		gfx.moveTo(node1.x + lineOffset, node1.y + lineOffset);
		gfx.lineTo(node2.x + lineOffset, node2.y + lineOffset);
	}
	#end
}

/** Path behavior for when an end is reached */
enum abstract FlxPathLoopType(Int) from Int to Int
{
	/** Stops when reaching the end */
	var ONCE = 0x000000;
	
	/** When the end is reached, go back to the other end and start again */
	var LOOP = 0x000010;
	
	/** When the end is reached, change direction and continue */
	var YOYO = 0x001000;
}

/** The direction to traverse the nodes */
enum abstract FlxPathDirection(Bool)
{
	/** Head towards the last node in the array */
	var FORWARD = true;
	
	/** Head towards the first node in the array */
	var BACKWARD = false;
	
	public inline function toInt()
	{
		return this ? 1 : -1;
	}
}

/** The drawing scheme of a path's debug draw */
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
