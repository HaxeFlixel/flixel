package flixel.system.debug.stats;

import openfl.display.BitmapData;
import openfl.system.System;
import openfl.text.TextField;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.system.FlxLinkedList;
import flixel.system.FlxQuadTree;
import flixel.system.debug.DebuggerUtil;
import flixel.system.debug.FlxDebugger.GraphicStats;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;

@:bitmap("assets/images/debugger/buttons/minimize.png")
private class GraphicMinimizeButton extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/maximize.png")
private class GraphicMaximizeButton extends BitmapData {}

/**
 * A simple performance monitor widget, for use in the debugger overlay.
 *
 * @author Adam "Atomic" Saltsman
 * @author Anton Karlov
 */
#if FLX_DEBUG
class Stats extends Window
{
	/**
	 * How often to update the stats, in ms. The lower, the more performance-intense!
	 */
	static inline var UPDATE_DELAY:Int = 250;

	/**
	 * The initial width of the stats window.
	 */
	static inline var INITIAL_WIDTH:Int = 160;

	static inline var FPS_COLOR:FlxColor = 0xff96ff00;
	static inline var MEMORY_COLOR:FlxColor = 0xff009cff;
	static inline var DRAW_TIME_COLOR:FlxColor = 0xffA60004;
	static inline var UPDATE_TIME_COLOR:FlxColor = 0xffdcd400;

	public static inline var LABEL_COLOR:FlxColor = 0xaaffffff;
	public static inline var TEXT_SIZE:Int = 11;
	public static inline var DECIMALS:Int = 1;

	var _leftTextField:TextField;
	var _rightTextField:TextField;

	var _itvTime:Int = 0;
	var _frameCount:Int;
	var _currentTime:Int;

	var fpsGraph:StatsGraph;
	var memoryGraph:StatsGraph;
	var drawTimeGraph:StatsGraph;
	var updateTimeGraph:StatsGraph;

	var flashPlayerFramerate:Float = 0;
	var visibleCount:Int = 0;
	var activeCount:Int = 0;
	var updateTime:Int = 0;
	var drawTime:Int = 0;
	var drawCallsCount:Int = 0;

	var _lastTime:Int = 0;
	var _updateTimer:Int = 0;

	var _update:Array<Int> = [];
	var _updateMarker:Int = 0;

	var _draw:Array<Int> = [];
	var _drawMarker:Int = 0;

	var _drawCalls:Array<Int> = [];
	var _drawCallsMarker:Int = 0;

	var _visibleObject:Array<Int> = [];
	var _visibleObjectMarker:Int = 0;

	var _activeObject:Array<Int> = [];
	var _activeObjectMarker:Int = 0;

	var _paused:Bool = true;

	var _toggleSizeButton:FlxSystemButton;

	/**
	 * Creates a new window with fps and memory graphs, as well as other useful stats for debugging.
	 */
	public function new()
	{
		super("Stats", new GraphicStats(0, 0), 0, 0, false);

		var minHeight = if (FlxG.renderTile) 200 else 185;
		minSize.y = minHeight;
		resize(INITIAL_WIDTH, minHeight);

		start();

		var gutter:Int = 5;
		var graphX:Int = gutter;
		var graphY:Int = Std.int(_header.height) + gutter;
		var graphHeight:Int = 40;
		var graphWidth:Int = INITIAL_WIDTH - 20;

		fpsGraph = new StatsGraph(graphX, graphY, graphWidth, graphHeight, FPS_COLOR, "fps");
		addChild(fpsGraph);
		fpsGraph.maxValue = FlxG.drawFramerate;
		fpsGraph.minValue = 0;

		graphY = (Std.int(_header.height) + graphHeight + 20);

		memoryGraph = new StatsGraph(graphX, graphY, graphWidth, graphHeight, MEMORY_COLOR, "MB");
		addChild(memoryGraph);

		graphY = Std.int(_header.height) + gutter;
		graphX += (gutter + graphWidth + 20);
		graphWidth -= 10;

		updateTimeGraph = new StatsGraph(graphX, graphY, graphWidth, graphHeight, UPDATE_TIME_COLOR, "ms", 35, "Update");
		updateTimeGraph.visible = false;
		addChild(updateTimeGraph);

		graphY = Std.int(_header.height) + graphHeight + 20;

		drawTimeGraph = new StatsGraph(graphX, graphY, graphWidth, graphHeight, DRAW_TIME_COLOR, "ms", 35, "Draw");
		drawTimeGraph.visible = false;
		addChild(drawTimeGraph);

		addChild(_leftTextField = DebuggerUtil.createTextField(gutter, (graphHeight * 2) + 45, LABEL_COLOR, TEXT_SIZE));
		addChild(_rightTextField = DebuggerUtil.createTextField(gutter + 75, (graphHeight * 2) + 45, FlxColor.WHITE, TEXT_SIZE));

		_leftTextField.multiline = _rightTextField.multiline = true;

		var drawMethod = "";
		if (FlxG.renderTile)
		{
			drawMethod =
				#if FLX_RENDER_TRIANGLE
				"DrawTrian.";
				#else
				"DrawQuads";
				#end
			drawMethod = '\n$drawMethod:';
		}

		_leftTextField.text = "Update: \nDraw:" + drawMethod + "\nQuadTrees: \nLists:";

		_toggleSizeButton = new FlxSystemButton(new GraphicMaximizeButton(0, 0), toggleSize);
		_toggleSizeButton.alpha = Window.HEADER_ALPHA;
		addChild(_toggleSizeButton);

		updateSize();
	}

	/**
	 * Starts Stats window update logic
	 */
	public function start():Void
	{
		if (_paused)
		{
			_paused = false;
			_itvTime = FlxG.game.ticks;
			_frameCount = 0;
		}
	}

	/**
	 * Stops Stats window
	 */
	public function stop():Void
	{
		_paused = true;
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (fpsGraph != null)
		{
			fpsGraph.destroy();
			removeChild(fpsGraph);
		}
		fpsGraph = null;

		if (memoryGraph != null)
		{
			removeChild(memoryGraph);
		}
		memoryGraph = null;

		if (_leftTextField != null)
		{
			removeChild(_leftTextField);
		}
		_leftTextField = null;

		if (_rightTextField != null)
		{
			removeChild(_rightTextField);
		}
		_rightTextField = null;

		_update = null;
		_draw = null;
		_activeObject = null;
		_visibleObject = null;
		_drawCalls = null;

		super.destroy();
	}

	/**
	 * Called each frame, but really only updates once every second or so, to save on performance.
	 * Takes all the data in the accumulators and parses it into useful performance data.
	 */
	override public function update():Void
	{
		if (_paused)
		{
			return;
		}
		var time:Int = _currentTime = FlxG.game.ticks;

		var elapsed:Int = time - _lastTime;

		if (elapsed > UPDATE_DELAY)
		{
			elapsed = UPDATE_DELAY;
		}
		_lastTime = time;

		_updateTimer += elapsed;

		_frameCount++;

		if (_updateTimer > UPDATE_DELAY)
		{
			fpsGraph.update(currentFps());
			memoryGraph.update(currentMem());
			updateTexts();

			_frameCount = 0;
			_itvTime = _currentTime;

			updateTime = 0;
			for (i in 0..._updateMarker)
			{
				updateTime += _update[i];
			}

			for (i in 0..._activeObjectMarker)
			{
				activeCount += _activeObject[i];
			}
			activeCount = Std.int(divide(activeCount, _activeObjectMarker));

			drawTime = 0;
			for (i in 0..._drawMarker)
			{
				drawTime += _draw[i];
			}

			for (i in 0..._visibleObjectMarker)
			{
				visibleCount += _visibleObject[i];
			}
			visibleCount = Std.int(divide(visibleCount, _visibleObjectMarker));

			if (FlxG.renderTile)
			{
				for (i in 0..._drawCallsMarker)
				{
					drawCallsCount += _drawCalls[i];
				}
				drawCallsCount = Std.int(divide(drawCallsCount, _drawCallsMarker));
			}

			_updateMarker = 0;
			_drawMarker = 0;
			_activeObjectMarker = 0;
			_visibleObjectMarker = 0;
			if (FlxG.renderTile)
			{
				_drawCallsMarker = 0;
			}

			_updateTimer -= UPDATE_DELAY;
		}
	}

	function updateTexts():Void
	{
		var updTime = FlxMath.roundDecimal(divide(updateTime, _updateMarker), DECIMALS);
		var drwTime = FlxMath.roundDecimal(divide(drawTime, _drawMarker), DECIMALS);

		drawTimeGraph.update(drwTime);
		updateTimeGraph.update(updTime);

		_rightTextField.text = activeCount + " (" + updTime + "ms)\n" + visibleCount + " (" + drwTime + "ms)\n"
			+ (FlxG.renderTile ? (drawCallsCount + "\n") : "") + FlxQuadTree._NUM_CACHED_QUAD_TREES + "\n" + FlxLinkedList._NUM_CACHED_FLX_LIST;
	}

	function divide(f1:Float, f2:Float):Float
	{
		return if (f2 == 0) 0 else f1 / f2;
	}

	/**
	 * Calculates current game fps.
	 */
	public inline function currentFps():Float
	{
		return _frameCount / intervalTime();
	}

	/**
	 * Time since performance monitoring started.
	 */
	public inline function intervalTime():Float
	{
		return (_currentTime - _itvTime) / 1000;
	}

	/**
	 * Current RAM consumption.
	 */
	public inline function currentMem():Float
	{
		return (System.totalMemory / 1024) / 1000;
	}

	/**
	 * How long updates took.
	 *
	 * @param 	Time	How long this update took.
	 */
	public function flixelUpdate(Time:Int):Void
	{
		if (_paused)
			return;
		_update[_updateMarker++] = Time;
	}

	/**
	 * How long rendering took.
	 *
	 * @param	Time	How long this render took.
	 */
	public function flixelDraw(Time:Int):Void
	{
		if (_paused)
			return;
		_draw[_drawMarker++] = Time;
	}

	/**
	 * How many objects were updated.
	 *
	 * @param 	Count	How many objects were updated.
	 */
	public function activeObjects(Count:Int):Void
	{
		if (_paused)
			return;
		_activeObject[_activeObjectMarker++] = Count;
	}

	/**
	 * How many objects were rendered.
	 *
	 * @param 	Count	How many objects were rendered.
	 */
	public function visibleObjects(Count:Int):Void
	{
		if (_paused)
			return;
		_visibleObject[_visibleObjectMarker++] = Count;
	}

	/**
	 * How many times drawTiles() method was called.
	 *
	 * @param 	Count	How many times drawTiles() method was called.
	 */
	public function drawCalls(Drawcalls:Int):Void
	{
		if (_paused)
			return;
		_drawCalls[_drawCallsMarker++] = Drawcalls;
	}

	/**
	 * Re-enables tracking of the stats.
	 */
	public function onFocus():Void
	{
		_paused = false;
	}

	/**
	 * Pauses tracking of the stats.
	 */
	public function onFocusLost():Void
	{
		_paused = true;
	}

	function toggleSize():Void
	{
		if (_width == INITIAL_WIDTH)
		{
			resize(INITIAL_WIDTH * 2, _height);
			x -= INITIAL_WIDTH;
			drawTimeGraph.visible = true;
			updateTimeGraph.visible = true;
			_toggleSizeButton.changeIcon(new GraphicMinimizeButton(0, 0));
		}
		else
		{
			resize(INITIAL_WIDTH, _height);
			x += INITIAL_WIDTH;
			drawTimeGraph.visible = false;
			updateTimeGraph.visible = false;
			_toggleSizeButton.changeIcon(new GraphicMaximizeButton(0, 0));
		}

		updateSize();
		bound();
	}

	override function updateSize():Void
	{
		super.updateSize();
		if (_toggleSizeButton != null)
		{
			_toggleSizeButton.x = _width - _toggleSizeButton.width - 3;
			_toggleSizeButton.y = 3;
		}
	}
}
#end
