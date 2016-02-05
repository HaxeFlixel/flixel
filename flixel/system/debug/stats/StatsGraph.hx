package flixel.system.debug.stats;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormatAlign;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * This is a helper function for the stats window to draw a graph with given values.
 */
#if !FLX_NO_DEBUG
class StatsGraph extends Sprite
{
	private static inline var AXIS_COLOR:FlxColor = 0xffffff;
	private static inline var AXIS_ALPHA:Float = 0.5;
	private static inline var HISTORY_MAX:Int = 30;
	
	public var minLabel:TextField;
	public var curLabel:TextField;
	public var maxLabel:TextField;
	public var avgLabel:TextField;
	
	public var minValue:Float = FlxMath.MAX_VALUE_FLOAT;
	public var maxValue:Float = FlxMath.MIN_VALUE_FLOAT;
	
	public var graphColor:FlxColor;
	
	public var history:Array<Float>;
	
	private var _axis:Shape;
	private var _width:Int;
	private var _height:Int;
	private var _unit:String;
	private var _labelWidth:Int;
	private var _label:String;
	
	public function new(X:Int, Y:Int, Width:Int, Height:Int, GraphColor:FlxColor, Unit:String, LabelWidth:Int = 45, ?Label:String)
	{
		super();
		x = X;
		y = Y;
		_width = Width - LabelWidth;
		_height = Height;
		graphColor = GraphColor;
		_unit = Unit;
		_labelWidth = LabelWidth;
		_label = (Label == null) ? "" : Label;
		
		history = [];
		
		_axis = new Shape();
		_axis.x = _labelWidth + 10;
		
		maxLabel = DebuggerUtil.createTextField(0, 0, Stats.LABEL_COLOR, Stats.TEXT_SIZE);
		curLabel = DebuggerUtil.createTextField(0, (_height / 2) - (Stats.TEXT_SIZE / 2), graphColor, Stats.TEXT_SIZE);
		minLabel = DebuggerUtil.createTextField(0, _height - Stats.TEXT_SIZE, Stats.LABEL_COLOR, Stats.TEXT_SIZE);
		
		avgLabel = DebuggerUtil.createTextField(_labelWidth + 20, (_height / 2) - (Stats.TEXT_SIZE / 2) - 10, Stats.LABEL_COLOR, Stats.TEXT_SIZE);
		avgLabel.width = _width;
		avgLabel.defaultTextFormat.align = TextFormatAlign.CENTER;
		avgLabel.alpha = 0.5;
		
		addChild(_axis);
		addChild(maxLabel);
		addChild(curLabel);
		addChild(minLabel);
		addChild(avgLabel);
		
		drawAxis();
	}
	
	/**
	 * Redraws the axes of the graph.
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
		gfx.lineTo(_width, _height);
		
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
		
		var inc:Float = _width / (HISTORY_MAX - 1);
		var range:Float = Math.max(maxValue - minValue, maxValue * 0.1);
		
		for (i in 0...history.length)
		{
			var value = (history[i] - minValue) / range;
			gfx.lineTo(_axis.x + (i * inc), (-value * _height) + _height);
		}
	}
	
	public function update(Value:Float, ?Average:Null<Float>):Void
	{
		history.unshift(Value);
		
		if (history.length > HISTORY_MAX)
			history.pop();
		
		// Update range
		maxValue = Math.max(maxValue, Value);
		minValue = Math.min(minValue, Value);
		
		minLabel.text = formatValue(minValue);
		curLabel.text = formatValue(Value);
		maxLabel.text = formatValue(maxValue);
		
		if (Average == null)
			Average = average();
		
		avgLabel.text = _label + "\nAvg: " + formatValue(Average);
		
		drawGraph();
	}
	
	private function formatValue(value:Float):String
	{
		return FlxMath.roundDecimal(value, Stats.DECIMALS) + " " + _unit;
	}
	
	public function average():Float
	{
		var sum:Float = 0;
		for (value in history)
			sum += value;
		return sum / history.length;
	}
	
	public function destroy():Void
	{
		_axis = FlxDestroyUtil.removeChild(this, _axis);
		minLabel = FlxDestroyUtil.removeChild(this, minLabel);
		curLabel = FlxDestroyUtil.removeChild(this, curLabel);
		maxLabel = FlxDestroyUtil.removeChild(this, maxLabel);
		avgLabel = FlxDestroyUtil.removeChild(this, avgLabel);
		history = null;
	}
}
#end