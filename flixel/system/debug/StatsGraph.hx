package flixel.system.debug;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormatAlign;
import flixel.util.FlxColor;
import flixel.util.FlxMath;

/**
 * This is a helper function for the stats window to draw a graph with given values.
 */
#if !FLX_NO_DEBUG
class StatsGraph extends Sprite
{
	private static inline var AXIS_COLOR:Int = 0xffffff;
	private static inline var AXIS_ALPHA:Float = 0.5;
	private static inline var LABEL_WIDTH:Int = 50;
	private static inline var HISTORY_MAX:Int = 30;
	
	private var _axis:Shape;
	private var _axisWidth:Int;
	private var _width:Int;
	private var _height:Int;
	private var _unit:String;
	
	public var minLabel:TextField;
	public var curLabel:TextField;
	public var maxLabel:TextField;
	public var avgLabel:TextField;
	
	public var minValue:Float = FlxMath.MAX_VALUE;
	public var maxValue:Float = FlxMath.MIN_VALUE;
	
	public var graphColor:Int;
	
	public var history:Array<Float>;
	
	/**
	 * Creates a new stats gaph.
	 * 
	 * @param	X
	 * @param	Y
	 * @param	Width
	 * @param	Height
	 */
	public function new(X:Int, Y:Int, Width:Int, Height:Int, GraphColor:Int, Unit:String)
	{
		super();
		x = X;
		y = Y;
		_width = Width;
		_height = Height;
		graphColor = GraphColor;
		_unit = Unit;
		
		history = [];
		
		_axis = new Shape();
		_axis.x = x + LABEL_WIDTH;
		
		maxLabel = DebuggerUtil.createTextField(0, 0, Stats.LABEL_COLOR, Stats.TEXT_SIZE);
		curLabel = DebuggerUtil.createTextField(0, (_height / 2) - (Stats.TEXT_SIZE / 2), graphColor, Stats.TEXT_SIZE);
		minLabel = DebuggerUtil.createTextField(0, _height - Stats.TEXT_SIZE, Stats.LABEL_COLOR, Stats.TEXT_SIZE);
		avgLabel = DebuggerUtil.createTextField((_width / 2), (_height / 2) - (Stats.TEXT_SIZE / 2), Stats.LABEL_COLOR, Stats.TEXT_SIZE);
		avgLabel.width = _width;
		avgLabel.defaultTextFormat.align = TextFormatAlign.CENTER;
		//avgLabel.defaultTextFormat.bold = true;
		avgLabel.alpha = 0.5;
		
		addChild(_axis);
		addChild(maxLabel);
		addChild(curLabel);
		addChild(minLabel);
		addChild(avgLabel);
		
		drawAxis();
	}
	
	/**
	 * Redraws the axis of the graph.
	 */
	private function drawAxis():Void
	{
		var gfx = _axis.graphics;
		gfx.clear();
		gfx.beginFill(FlxColor.TRANSPARENT);
		gfx.lineStyle(1, AXIS_COLOR, AXIS_ALPHA); 
		
		// y-Axis
		gfx.moveTo(0, 0);
		gfx.lineTo(0, _height);
		
		// x-Axis
		gfx.moveTo(0, _height);
		gfx.lineTo(_width - _axis.x, _height);
		
		gfx.endFill();
	}
	
	/**
	 * Redraws the graph based on the values stored in the history.
	 */
	private function drawGraph():Void
	{
		var gfx:Graphics = graphics;
		gfx.clear();
		gfx.lineStyle(1, graphColor, 1);
		gfx.moveTo(_axis.x, _axis.y);
		
		var inc:Float = (_width - _axis.x) / (HISTORY_MAX - 1);
		var range:Float = maxValue - minValue;
		var value:Float;
		
		for (i in 0...history.length)
		{
			value = (history[i] - minValue) / range;
			gfx.lineTo(_axis.x + (i * inc), (- value * _height) + _height);
		}
	}
	
	public function update(Value:Float, ?Average:Null<Float>):Void
	{
		history.unshift(Value);
		
		if (history.length > HISTORY_MAX) {
			history.pop();
		}
		
		// Update range
		maxValue = Math.max(maxValue, Value);
		minValue = Math.min(minValue, Value);
		
		minLabel.text = FlxMath.roundDecimal(minValue, Stats.DECIMALS) + " " + _unit;
		curLabel.text = FlxMath.roundDecimal(Value, Stats.DECIMALS) + " " + _unit;
		maxLabel.text = FlxMath.roundDecimal(maxValue, Stats.DECIMALS) + " " + _unit;
		
		if (Average == null) {
			Average = average();
		}
		avgLabel.text = "Avg: " + FlxMath.roundDecimal(Average, Stats.DECIMALS) + " " + _unit;
		
		drawGraph();
	}
	
	public function average():Float
	{
		var sum:Float = 0;
		for (value in history) {
			sum += value;
		}
		return (sum / history.length);
	}
	
	public function destroy():Void
	{
		if (_axis != null)
		{
			removeChild(_axis);
			_axis = null;
		}
		
		if (minLabel != null)
		{
			removeChild(minLabel);
			minLabel = null;
		}
		if (curLabel != null)
		{
			removeChild(curLabel);
			curLabel = null;
		}
		if (maxLabel != null)
		{
			removeChild(maxLabel);
			maxLabel = null;
		}	
		if (avgLabel != null)
		{
			removeChild(avgLabel);
			avgLabel = null;
		}	
		
		history = null;
	}
}
#end