package flixel.path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSpriteUtil;
import openfl.display.Graphics;

class FlxBasePath<TTarget:FlxBasic> extends FlxBasic implements IFlxDestroyable
{
	/**
	 * The list of FlxPoints that make up the path data.
	 */
	public var nodes:Array<FlxPoint>;
	
	public var target:TTarget;
	
	public var length(get, never):Int;
	public var finished(get, never):Bool;
	
	public var onComplete(default, null) = new FlxTypedSignal<(FlxBasePath<TTarget>)->Void>();
	
	/**
	 * Tracks which node of the path this object is currently moving toward.
	 */
	public var currentIndex(default, null):Int = 0;
	public var nextIndex(default, null):Null<Int> = null;
	
	public var current(get, never):Null<FlxPoint>;
	public var next(get, never):Null<FlxPoint>;
	
	/**
	 * Path behavior flag (like looping, yoyo, etc)
	 */
	public var loop:FlxPathLoop = LOOP;
	
	public var direction = FlxPathDirection.FORWARD;
	
	public function new (?nodes:Array<FlxPoint>, ?target:TTarget)
	{
		this.nodes = nodes;
		this.target = target;
		super();
		
		if (nodes != null && nodes.length > 0)
			restartPath();
	}
	
	/**
	 * Clean up memory.
	 */
	override function destroy():Void
	{
		FlxDestroyUtil.putArray(nodes);
		nodes = null;
		onComplete.removeAll();
	}
	
	public function restartPath(direction = FlxPathDirection.FORWARD):FlxBasePath<TTarget>
	{
		this.direction = direction;
		currentIndex = getStartingNode();
		setNextIndex();
		
		return this;
	}
	
	public function getStartingNode()
	{
		return direction == BACKWARD ? nodes.length - 1 : 0;
	}
	
	public function advance()
	{
		if (finished)
		{
			FlxG.log.warn('Cannot advance after path is finished');
			return;
		}
		
		currentIndex = nextIndex;
		setNextIndex();
	}
	
	function setNextIndex()
	{
		// reached last
		if (currentIndex == nodes.length - 1 && direction == FORWARD)
		{
			nextIndex = switch (loop)
			{
				case ONCE: null;
				case LOOP: 0;
				case YOYO:
					direction = BACKWARD;
					currentIndex - 1;
			}
			onComplete.dispatch(this);
			return;
		}
		
		// reached first
		if (currentIndex == 0 && direction == BACKWARD)
		{
			nextIndex = switch (loop)
			{
				case ONCE: null;
				case LOOP: nodes.length - 1;
				case YOYO:
					direction = FORWARD;
					currentIndex + 1;
			}
			onComplete.dispatch(this);
			return;
		}
		
		nextIndex = currentIndex + direction.toInt();
	}
	
	/**
	 * Change the path node this object is currently at.
	 *
	 * @param  index    The index of the new node out of path.nodes.
	 */
	public function startAt(index:Int, ?direction:FlxPathDirection):FlxBasePath<TTarget>
	{
		if (direction != null)
			this.direction = direction;
		
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
			advance();
		}
		
		updateTarget(elapsed);
	}
	
	/** Override this with your logic that whether the target has reached the next node */
	function isTargetAtNext(elapsed:Float)
	{
		return false;
	}
	
	/** Override this with your logic that brings the target towards the next node */
	function updateTarget(elapsed:Float) {}
	
	inline function get_length()
	{
		return nodes != null ? nodes.length : 0;
	}
	
	inline function get_finished()
	{
		return nextIndex == null;
	}
	
	inline function get_current()
	{
		return nodes != null ? nodes[currentIndex] : null;
	}
	
	inline function get_next()
	{
		return nodes != null ? nodes[nextIndex] : null;
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
		if (nodes == null || nodes.length <= 0)
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
		
		final _point = FlxPoint.get();

		// Then fill up the object with node and path graphics
		var length = nodes.length;
		for (i in 0...length)
		{
			// get a reference to the current node
			var node = nodes[i];

			// find the screen position of the node on this camera
			_point.x = node.x;// - (camera.scroll.x * target.scrollFactor.x); // copied from getScreenPosition()
			_point.y = node.y;// - (camera.scroll.y * target.scrollFactor.y);

			camera.transformPoint(_point);

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
				nextNode = nodes[i + 1];
			}
			else
			{
				nextNode = nodes[i];
			}

			// then draw a line to the next node
			var lineOffset = debugDrawData.lineSize / 2;
			gfx.moveTo(_point.x + lineOffset, _point.y + lineOffset);
			gfx.lineStyle(debugDrawData.lineSize, debugDrawData.lineColor & 0xFFFFFF, debugDrawData.lineColor.alphaFloat);
			_point.x = nextNode.x;// - (camera.scroll.x * target.scrollFactor.x); // copied from getScreenPosition()
			_point.y = nextNode.y;// - (camera.scroll.y * target.scrollFactor.y);

			if (FlxG.renderBlit)
				_point.subtract(camera.viewMarginX, camera.viewMarginY);

			gfx.lineTo(_point.x + lineOffset, _point.y + lineOffset);
		}

		if (FlxG.renderBlit)
		{
			// then stamp the path down onto the game buffer
			camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		}
		
		_point.put();
	}
	#end
}

/**
 * Path behavior controls
 */
enum abstract FlxPathLoop(Int) from Int to Int
{
	/**
	 * Move from the start of the path to the end then stop.
	 */
	var ONCE = 0x000000;
	
	/**
	 * Move from the start of the path to the end then directly back to the start, and start over.
	 */
	var LOOP = 0x000010;
	
	/**
	 * Move from the start of the path to the end then turn around and go back to the start, over and over.
	 */
	var YOYO = 0x001000;
}

enum abstract FlxPathDirection(Bool)
{
	var FORWARD = true;
	var BACKWARD = false;
	
	public function toInt()
	{
		return this ? 1 : -1;
	}
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
