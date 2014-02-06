package flixel.system.debug;

import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flixel.FlxG;
import flixel.system.debug.FlxDebugger;
import flixel.system.FlxList;
import flixel.system.FlxQuadTree;
import flixel.util.FlxColor;
import flixel.util.FlxMath;

/**
 * A simple performance monitor widget, for use in the debugger overlay.
 * 
 * @author Adam "Atomic" Saltsman
 * @author Anton Karlov
 */
#if !FLX_NO_DEBUG
class Stats extends Window
{
	/**
	 * How often to update the stats, in ms. The lower, the more performance-intense!
	 */
	private static inline var UPDATE_DELAY:Int = 250;
	/**
	 * The initial width of the stats window.
	 */
	private static inline var INITIAL_WIDTH:Int = 160;
	/**
	 * The minimal height of the window.
	 */
	private static inline var MIN_HEIGHT:Int = #if flash 180 #else 195 #end;
	/**
	 * The color of the fps graph.
	 */
	private static inline var FPS_COLOR:Int = 0xff96ff00;
	/**
	 * The color of the memory graph.
	 */
	private static inline var MEMORY_COLOR:Int = 0xff009cff;
	/**
	 * The label color.
	 */
	public static inline var LABEL_COLOR:Int = 0xaaffffff;
	/**
	 * The textfield size color.
	 */
	public static inline var TEXT_SIZE:Int = 11;
	/**
	 * The amount of decimals to display for the stats.
	 */
	public static inline var DECIMALS:Int = 1;
	
	private var _leftTextField:TextField;
	private var _rightTextField:TextField;
	
	private var _itvTime:Int = 0;
	private var _initTime:Int;
	private var _frameCount:Int;
	private var _totalCount:Int;
	private var _currentTime:Int;
	
	private var fpsGraph:StatsGraph;
	private var memoryGraph:StatsGraph;
	
	private var flashPlayerFramerate:Float = 0;
	private var visibleCount:Int = 0;
	private var activeCount:Int = 0;
	private var updateTime:Int = 0;
	private var drawTime:Int = 0;
	
	private var _lastTime:Int = 0;
	private var _updateTimer:Int = 0;
	
	private var _update:Array<Int>;
	private var _updateMarker:Int = 0;
	
	private var _draw:Array<Int>;
	private var _drawMarker:Int = 0;
	
	private var _visibleObject:Array<Int>;
	private var _visibleObjectMarker:Int = 0;
	
	private var _activeObject:Array<Int>;
	private var _activeObjectMarker:Int = 0;
	
	private var _paused:Bool = true;
	
	#if !flash
	private var drawCallsCount:Int = 0;
	private var _drawCalls:Array<Int>;
	private var _drawCallsMarker:Int = 0;
	#end
	
	/**
	 * Creates a new window with fps and memory graphs, as well as other useful stats for debugging.
	 */
	public function new()
	{
		super("stats", new GraphicStats(0, 0), 0, 0, false);
		
		minSize.y = MIN_HEIGHT;
		resize(INITIAL_WIDTH, MIN_HEIGHT);
		
		start();
		
		_update = [];
		_draw = [];
		_activeObject = [];
		_visibleObject = [];
		
		#if !flash
		_drawCalls = [];
		#end
		
		var graphHeight:Int = 40;
		var gutter:Int = 5;
		
		fpsGraph = new StatsGraph(gutter, Std.int(_header.height) + 5, INITIAL_WIDTH - 10, graphHeight, FPS_COLOR, "fps");
		addChild(fpsGraph);	
		fpsGraph.maxValue = FlxG.drawFramerate;
		fpsGraph.minValue = 0;
		
		memoryGraph = new StatsGraph(gutter, Std.int(_header.height) +  graphHeight + 20, INITIAL_WIDTH - 10, graphHeight, MEMORY_COLOR, "MB");
		addChild(memoryGraph);
		
		addChild(_leftTextField = DebuggerUtil.createTextField(gutter, (graphHeight * 2) + 45, LABEL_COLOR, TEXT_SIZE));
		addChild(_rightTextField = DebuggerUtil.createTextField(gutter + 70, (graphHeight * 2) + 45, FlxColor.WHITE, TEXT_SIZE));
		
		_leftTextField.multiline = _rightTextField.multiline = true;
		_leftTextField.wordWrap = _rightTextField.wordWrap = true;
		
		_leftTextField.text = "Update: \nDraw:" + #if !flash "\nDrawTiles:" + #end "\nQuadTrees: \nLists:";
	}
	
	/**
	 * Starts Stats window update logic
	 */
	public function start():Void
	{
		if (_paused)
		{
			_paused = false;
			_initTime = _itvTime = FlxG.game.ticks;
			_totalCount = _frameCount = 0;
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
		
		#if !flash
		_drawCalls = null;
		#end
		
		super.destroy();
	}
	
	/**
	 * Called each frame, but really only updates once every second or so, to save on performance.
	 * Takes all the data in the accumulators and parses it into useful performance data.
	 */
	public function update():Void
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
        _totalCount++;
		
		if (_updateTimer > UPDATE_DELAY)
		{
			fpsGraph.update(currentFps(), averageFps());
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
			activeCount = Std.int(activeCount / _activeObjectMarker);
			
			drawTime = 0;
			for (i in 0..._drawMarker)
			{
				drawTime += _draw[i];
			}
			
			for (i in 0..._visibleObjectMarker)
			{
				visibleCount += _visibleObject[i];
			}
			visibleCount = Std.int(visibleCount / _visibleObjectMarker);
			
			#if !flash
			for (i in 0..._drawCallsMarker)
			{
				drawCallsCount += _drawCalls[i];
			}
			drawCallsCount = Std.int(drawCallsCount / _drawCallsMarker);
			#end
			
			_updateMarker = 0;
			_drawMarker = 0;
			_activeObjectMarker = 0;
			_visibleObjectMarker = 0;
			#if !flash
			_drawCallsMarker = 0;
			#end
			
			_updateTimer -= UPDATE_DELAY;
		}
	}
	
	private function updateTexts():Void
	{
		var updTime = FlxMath.roundDecimal(updateTime / _updateMarker, DECIMALS);
		var drwTime = FlxMath.roundDecimal(drawTime / _drawMarker, DECIMALS);
		
		_rightTextField.text = 	activeCount + " (" + updTime + "ms)\n"
								+ visibleCount + " (" + drwTime + "ms)\n" 
								#if !flash
								+ drawCallsCount + "\n"
								#end 
								+ FlxQuadTree._NUM_CACHED_QUAD_TREES + "\n"
								+ FlxList._NUM_CACHED_FLX_LIST;
	}
	
	/**
	 * Calculates current game fps.
	 */
	public inline function currentFps():Float
	{
		return _frameCount / intervalTime();
	}
	
	/**
	 * Calculates average game fps (takes whole time the game is running).
	 */
	public inline function averageFps():Float
	{
		return _totalCount / runningTime();
	}
	
	/**
	 * Application life time.
	 */
	public inline function runningTime():Float
	{
		return (_currentTime - _initTime) / 1000;
	}
	
	/**
	 * Time since perfomance monitoring started.
	 */
	public inline function intervalTime():Float
	{
		return (_currentTime - _itvTime) / 1000;
	}
	
	/**
	 * Current RAM consumtion.
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
		if (_paused) return;
		_update[_updateMarker++] = Time;
	}
	
	/**
	 * How long rendering took.
	 * 
	 * @param	Time	How long this render took.
	 */
	public function flixelDraw(Time:Int):Void
	{
		if (_paused) return;
		_draw[_drawMarker++] = Time;
	}
	
	/**
	 * How many objects were updated.
	 * 
	 * @param 	Count	How many objects were updated.
	 */
	public function activeObjects(Count:Int):Void
	{
		if (_paused) return;
		_activeObject[_activeObjectMarker++] = Count;
	}
	
	/**
	 * How many objects were rendered.
	 * 
	 * @param 	Count	How many objects were rendered.
	 */
	public function visibleObjects(Count:Int):Void
	{
		if (_paused) return;
		_visibleObject[_visibleObjectMarker++] = Count;
	}
	
	#if !flash
	/**
	 * How many times drawTiles() method was called.
	 * 
	 * @param 	Count	How many times drawTiles() method was called.
	 */
	public function drawCalls(Drawcalls:Int):Void
	{
		if (_paused) return;
		_drawCalls[_drawCallsMarker++] = Drawcalls;
	}
	#end
	
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
}
#end