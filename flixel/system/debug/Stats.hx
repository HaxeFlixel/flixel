package flixel.system.debug;

import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.FlxList;
import flixel.system.FlxQuadTree;

/**
 * A simple performance monitor widget, for use in the debugger overlay.
 */
class Stats extends Window
{
	private static inline var UPDATE_DELAY:Int = 500;
	private static inline var WIDTH:Int = 100;
	
	private var _text:TextField;
	
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
	
	private var _flash:Array<Float>;
	private var _flashMarker:Int = 0;
	
	#if !flash
	private var _drawCalls:Array<Int>;
	private var _drawCallsMarker:Int = 0;
	#end
	
	/**
	 * Creates flashPlayerFramerate new window object.  This Flash-based class is mainly (only?) used by <code>FlxDebugger</code>.
	 * @param 	Title		The name of the window, displayed in the header bar.
	 * @param 	Width		The initial width of the window.
	 * @param 	Height		The initial height of the window.
	 * @param 	Resizable	Whether you can change the size of the window with flashPlayerFramerate drag handle.
	 * @param 	Bounds		A rectangle indicating the valid screen area for the window.
	 */
	public function new(Title:String, Width:Float, Height:Float, Resizable:Bool = true, ?Bounds:Rectangle)
	{
		super(Title, Width, Height, Resizable, Bounds);
		
		// Need to account for the additional drawCalls stat on non-flash targets
		#if flash
		resize(WIDTH, 100);
		#else
		resize(WIDTH, 118);
		#end
		
		var leftText:TextField = createTextField(TextFormatAlign.LEFT, 0xD8D8D8);
		leftText.text = "FPS: \n" + "Mem: \n" + "U: \n" + "D: \n" + #if !flash "DrawTiles: \n" + #end "QuadTrees: \n" + "Lists \n";
		_text = createTextField(TextFormatAlign.RIGHT, 0xffffff);
		
		_update = new Array();
		_draw = new Array();
		_flash = new Array();
		_activeObject = new Array();
		_visibleObject = new Array();
		
		#if !flash
		_drawCalls = new Array();
		#end
	}
	
	/**
	 * Helper function to create a new textfield.
	 * @param	Alignment	The aligment of the textfield
	 * @return 	The created textfield
	 */
	private function createTextField(Alignment:Dynamic, Color:Int):TextField
	{
		var text:TextField = new TextField();
		text.width = WIDTH - 4;
		text.x = 2;
		text.y = 15;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = true;
		text.embedFonts = true;
		text.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, Color, false, false, false, null, null, Alignment);
		addChild(text);
		return text;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_text != null)
		{
			removeChild(_text);
		}
		_text = null;
		_update = null;
		_draw = null;
		_flash = null;
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
		var time:Int = FlxG.game.ticks;
		var elapsed:Int = time - _lastTime;
		_lastTime = FlxG.game.ticks;
		
		if (elapsed > UPDATE_DELAY)
		{
			elapsed = UPDATE_DELAY;
		}
		_lastTime = time;
		
		_updateTimer += elapsed;
		
		if (_updateTimer > UPDATE_DELAY)
		{
			var i:Int = 0;
			var output:String = "";
			
			var flashPlayerFramerate:Float = 0;
			i = 0;
			while (i < _flashMarker)
			{
				flashPlayerFramerate += _flash[i++];
			}
			flashPlayerFramerate /= _flashMarker;
			
			var updateTime:Int = 0;
			i = 0;
			while (i < _updateMarker)
			{
				updateTime += _update[i++];
			}
			
			var activeCount:Int = 0;
			i = 0;
			while(i < _activeObjectMarker)
			{
				activeCount += _activeObject[i++];
			}
			activeCount = Std.int(activeCount / _activeObjectMarker);
			
			var drawTime:Int = 0;
			i = 0;
			while (i < _drawMarker)
			{
				drawTime += _draw[i++];
			}
			
			var visibleCount:Int = 0;
			i = 0;
			while (i < _visibleObjectMarker)
			{
				visibleCount += _visibleObject[i++];
			}
			visibleCount = Std.int(visibleCount / _visibleObjectMarker);
			
			#if !flash
			var drawCallsCount:Int = 0;
			i = 0;
			while (i < _drawCallsMarker)
			{
				drawCallsCount += _drawCalls[i++];
			}
			drawCallsCount = Std.int(drawCallsCount / _drawCallsMarker);
			#end
			
			output += Std.int(1 / (flashPlayerFramerate / 1000)) + " / " + FlxG.flashFramerate + " \n";
			output += Math.round(System.totalMemory * 0.000000954 * 100) / 100 + " MB" + " \n";
			output += activeCount + " (" + Std.int(updateTime / _updateMarker) + "ms)" + " \n";
			output += visibleCount + " (" + Std.int(drawTime / _drawMarker) + "ms)" + " \n";
			#if !flash
			output += Std.string(drawCallsCount) + " \n";
			#end
			output += Std.string(FlxQuadTree._NUM_CACHED_QUAD_TREES) + " \n";
			output += Std.string(FlxList._NUM_CACHED_FLX_LIST) + " \n";
			
			_text.text = output;
			_text.selectable = false;
			
			_updateMarker = 0;
			_drawMarker = 0;
			_flashMarker = 0;
			_activeObjectMarker = 0;
			_visibleObjectMarker = 0;
			#if !flash
			_drawCallsMarker = 0;
			#end
			_updateTimer -= UPDATE_DELAY;
		}
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
	 * Keep track of how long the Flash player and browser take.
	 * @param 	Time	How long Flash/browser took.
	 */
	inline public function flash(Time:Int):Void
	{
		_flash[_flashMarker++] = Time;
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
