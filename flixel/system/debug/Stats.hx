package flixel.system.debug;

import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.FlxList;
import flixel.system.FlxQuadTree;
import flixel.util.FlxMath;

#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

/**
 * A simple performance monitor widget, for use in the debugger overlay.
 * 
 * @author Adam "Atomic" Saltsman
 * @author Anton Karlov
 */
class Stats extends Window
{
	private static inline var UPDATE_DELAY:Int = 500;
	private static inline var WIDTH:Int = 450;
	
	public var minFps:Float;
	public var maxFps:Float;
	public var minMem:Float;
	public var maxMem:Float;
	private var history:Int = 60;
	
	private var fpsList:Array<Float>;
	private var memList:Array<Float>;
	
	private var _itvTime:Int = 0;
	private var _initTime:Int;
	private var _frameCount:Int;
	private var _totalCount:Int;
	private var _currentTime:Int;
	
	private var _tfMaxFps:TextField;
	private var _tfMinFps:TextField;
	private var _tfMaxMem:TextField;
	private var _tfMinMem:TextField;
	private var _tfInfo:TextField;
	
	private var _fpsBox:Shape;
	private var _memBox:Shape;
	private var _display:Shape;
	
	private var _defaultFormat:TextFormat;
	
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
	
	#if !flash
	private var drawCallsCount:Int = 0;
	private var _drawCalls:Array<Int>;
	private var _drawCallsMarker:Int = 0;
	#end
	
	/**
	 * Creates flashPlayerFramerate new window object.  This Flash-based class is mainly (only?) used by <code>FlxDebugger</code>.
	 * @param 	Title		The name of the window, displayed in the header bar.
	 * @param	IconPath	Path to the icon to use for the window header.
	 * @param 	Width		The initial width of the window.
	 * @param 	Height		The initial height of the window.
	 * @param 	Resizable	Whether you can change the size of the window with flashPlayerFramerate drag handle.
	 * @param 	Bounds		A rectangle indicating the valid screen area for the window.
	 */
	public function new(Title:String, ?IconPath:String, Width:Float, Height:Float, Resizable:Bool = true, ?Bounds:Rectangle)
	{
		super(Title, IconPath, Width, Height, Resizable, Bounds);
		
		resize(WIDTH, 170);
		
		fpsList = [];
		memList = [];
		
		_defaultFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xffffff);
		
		_tfMaxFps = makeLabel(2, 15, _defaultFormat);
		addChild(_tfMaxFps);
		
		_tfMinFps = makeLabel(2, 52, _defaultFormat);
		addChild(_tfMinFps);
		
		_tfMaxMem = makeLabel(2, 78, _defaultFormat);
		addChild(_tfMaxMem);
		
		_tfMinMem = makeLabel(2, 115, _defaultFormat);
		addChild(_tfMinMem);
		
		_tfInfo = makeLabel(57, 132, _defaultFormat);
		_tfInfo.multiline = true;
		_tfInfo.height = 32;
		_tfInfo.width = _width;
		addChild(_tfInfo);
		
		_display = new Shape();
		_display.y = 10;
		addChild(_display);
		
		_fpsBox = new Shape();
		_fpsBox.x = 60;
		_fpsBox.y = 65;
		addChild(_fpsBox);
		
		_memBox = new Shape();
		_memBox.x = 60;
		_memBox.y = 128;
		addChild(_memBox);
		
		minFps = FlxMath.MAX_VALUE;
		maxFps = FlxMath.MIN_VALUE;
		minMem = FlxMath.MAX_VALUE;
		maxMem = FlxMath.MIN_VALUE;
		
		draw();
		
		_initTime = _itvTime = FlxG.game.ticks;
        _totalCount = _frameCount = 0;
		
		_update = new Array();
		_draw = new Array();
		_activeObject = new Array();
		_visibleObject = new Array();
		
		#if !flash
		_drawCalls = new Array();
		#end
	}
	
	/**
	 * Helper method for label creation.
	 *
	 * @param        X         label x position.
	 * @param        Y         label y position.
	 * @param        Format         label text format.
	 * @return                new label text field at specified position and format
	 */
	private function makeLabel(X:Float, Y:Float, Format:TextFormat = null):TextField
	{
		var tf:TextField = new TextField();
		tf.x = X;
		tf.y = Y;
		tf.height = 16;
		tf.multiline = false;
		tf.wordWrap = false;
		tf.embedFonts = true;
		tf.selectable = false;
		#if flash
		tf.antiAliasType = AntiAliasType.NORMAL;
		tf.gridFitType = GridFitType.PIXEL;
		#end
		tf.defaultTextFormat = Format;
		tf.text = "";
		return tf;
	}
	
	/**
	 * Draw graph axis
	 */
	private function draw():Void
	{
		_display.graphics.clear();
		_display.graphics.beginFill(0x000000, 0.5);
		_display.graphics.lineStyle(1, 0x5e5f5f, 1);

		_display.graphics.moveTo(60, 55);
		_display.graphics.lineTo(60, 10);
		_display.graphics.moveTo(60, 55);
		_display.graphics.lineTo(_width - 7, 55);

		_display.graphics.moveTo(60, 118);
		_display.graphics.lineTo(60, 73);
		_display.graphics.moveTo(60, 118);
		_display.graphics.lineTo(_width - 7, 118);
		_display.graphics.endFill();
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_tfInfo != null)
		{
			removeChild(_tfInfo);
		}
		_tfInfo = null;
		
		if (_tfMaxFps != null)
		{
			removeChild(_tfMaxFps);
		}
		_tfMaxFps = null;
		
		if (_tfMinFps != null)
		{
			removeChild(_tfMinFps);
		}
		_tfMinFps = null;
		
		if (_tfMaxMem != null)
		{
			removeChild(_tfMaxMem);
		}
		_tfMaxMem = null;
		
		if (_tfMinMem != null)
		{
			removeChild(_tfMinMem);
		}
		_tfMinMem = null;
		
		if (_fpsBox != null)
		{
			removeChild(_fpsBox);
		}
		_fpsBox = null;
		
		if (_memBox != null)
		{
			removeChild(_memBox);
		}
		_memBox = null;
		
		if (_display != null)
		{
			removeChild(_display);
		}
		_display = null;
		
		_defaultFormat = null;
		_update = null;
		_draw = null;
		_activeObject = null;
		_visibleObject = null;
		
		fpsList = null;
		memList = null;
		
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
			(visible) ? updateDisplay() : updateMinMax();
			updateDisplay();
			fpsList.unshift(currentFps());
			memList.unshift(currentMem());
			
			if (fpsList.length > history)
			{
				fpsList.pop();
			}
			
			if (memList.length > history)
			{
				memList.pop();
			}
			
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
	
	/**
	 * Update displayable perfomance values.
	 */
	private function updateDisplay():Void
	{
		updateMinMax();
		redrawDisplay();
	}
	
	/**
	 * Update range values for perfomance graph.
	 */
	private function updateMinMax():Void
	{
		minFps = Math.min(currentFps(), minFps);
		maxFps = Math.max(currentFps(), maxFps);
		
		minMem = Math.min(currentMem(), minMem);
		maxMem = Math.max(currentMem(), maxMem);
	}
	
	/**
	 * Redraw perfomance graph and update displayed text info.
	 */
	private function redrawDisplay():Void
	{
		if (runningTime() >= 1)
		{
			_tfMinFps.text = Std.int(10 * minFps) / 10 + " fps";
			_tfMaxFps.text = Std.int(10 * maxFps) / 10 + " fps";
			_tfMinMem.text = Std.int(10 * minMem) / 10 + " mb";
			_tfMaxMem.text = Std.int(10 * maxMem) / 10 + " mb";
		}
		
		var output:String = "Current " + (Std.int(10 * currentFps()) / 10) + " fps : ";
		output += "Average " + (Std.int(10 * averageFps()) / 10) + " fps : ";
		output += "Memory Used " + (Std.int(10 * currentMem()) / 10) + "mb\n";
		
		output += "Upd " + activeCount + " (" + Std.int(updateTime / _updateMarker) + "ms)" + " : ";
		output += "Draw " + visibleCount + " (" + Std.int(drawTime / _drawMarker) + "ms)" + " : ";
		#if !flash
		output += "DrawTiles " + Std.string(drawCallsCount) + " : ";
		#end
		output += "QuadTrees " + Std.string(FlxQuadTree._NUM_CACHED_QUAD_TREES) + " : ";
		output += "Lists " + Std.string(FlxList._NUM_CACHED_FLX_LIST);
		
		_tfInfo.text = output;
		
		var vec:Graphics = _fpsBox.graphics;
		vec.clear();
		vec.lineStyle(1, 0x96ff00, 1);

		var i:Int = 0;
		var len:Int = fpsList.length;
		var height:Int = 45;
		var width:Int = _width - 67;
		var inc:Float = width / (history - 1);
		var rateRange:Float = maxFps - minFps;
		var value:Float;
		
		for (i in 0...len)
		{
			value = (fpsList[i] - minFps) / rateRange;
			(i == 0) ? vec.moveTo(0, -value * height) : vec.lineTo(i * inc, -value * height);
		}
		
		vec = _memBox.graphics;
		vec.clear();
		vec.lineStyle(1, 0x009cff, 1);
		
		len = memList.length;
		rateRange = maxMem - minMem;
		for (i in 0...len)
		{
			value = (memList[i] - minMem) / rateRange;
			(i == 0) ? vec.moveTo(0, -value * height) : vec.lineTo(i * inc, -value * height);
		}
	}
	
	/**
	 * Calculates current game fps.
	 */
	inline public function currentFps():Float
	{
		return _frameCount / intervalTime();
	}
	
	/**
	 * Calculates average game fps (takes whole time the game is running).
	 */
	inline public function averageFps():Float
	{
		return _totalCount / runningTime();
	}
	
	/**
	 * Application life time.
	 */
	inline public function runningTime():Float
	{
		return (_currentTime - _initTime) / 1000;
	}
	
	/**
	 * Time since perfomance monitoring started.
	 */
	inline public function intervalTime():Float
	{
		return (_currentTime - _itvTime) / 1000;
	}
	
	/**
	 * Current RAM consumtion by this game.
	 */
	inline public function currentMem():Float
	{
		return (System.totalMemory / 1024) / 1000;
	}
	
	/**
	 * Keep track of how long updates take.
	 * @param 	Time	How long this update took.
	 */
	inline public function flixelUpdate(Time:Int):Void
	{
		_update[_updateMarker++] = Time;
	}
	
	/**
	 * Keep track of how long renders take.
	 * @param	Time	How long this render took.
	 */
	inline public function flixelDraw(Time:Int):Void
	{
		_draw[_drawMarker++] = Time;
	}
	
	/**
	 * Keep track of how many objects were updated.
	 * @param 	Count	How many objects were updated.
	 */
	inline public function activeObjects(Count:Int):Void
	{
		_activeObject[_activeObjectMarker++] = Count;
	}
	
	/**
	 * Keep track of how many objects were updated.
	 * @param 	Count	How many objects were updated.
	 */
	inline public function visibleObjects(Count:Int):Void
	{
		_visibleObject[_visibleObjectMarker++] = Count;
	}
	
	#if !flash
	/**
	 * Keep track of how many times drawTiles() method was called.
	 * @param 	Count	How many times drawTiles() method was called.
	 */
	inline public function drawCalls(Drawcalls:Int):Void
	{
		_drawCalls[_drawCallsMarker++] = Drawcalls;
	}
	#end
}