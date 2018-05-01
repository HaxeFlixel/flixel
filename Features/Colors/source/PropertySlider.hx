package;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

/**
 * @author Joe Williamson
 */
class PropertySlider extends FlxSpriteGroup
{
	public var upSmallButton:FlxButton;
	public var upBigButton:FlxButton;
	public var downSmallButton:FlxButton;
	public var downBigButton:FlxButton;
	public var labelText:FlxText;
	public var valueText:FlxText;
	
	public var smallDelta:Float;
	public var bigDelta:Float;
	
	public var label(get, set):String;
	public var value(default, set):Float;
	public var minValue:Float;
	public var maxValue:Float;
	
	public var buttonWidth = 14;
	public var buttonHeight = 14;
	public var buttonSpacing = 1;
	public var valueWidth = 28;
	public var labelHeight = 14;
	
	public var decimalPlaces = 2;
	
	public var onChange:PropertySlider->Void;
	public var updateValue:PropertySlider->Void;
	
	public function new(label:String, smallDelta:Float, bigDelta:Float, minValue:Float, maxValue:Float)
	{
		super();
		
		labelText = new FlxText(0, 0, 0, label, 12);
		labelText.font = "fairfax";
		add(labelText);
		valueText = new FlxText((buttonWidth + buttonSpacing) * 2, labelHeight + 2, valueWidth, "0", 12);
		valueText.font = "fairfax";
		valueText.wordWrap = false;
		valueText.alignment = CENTER;
		add(valueText);
		
		onChange = function(slider:PropertySlider):Void {};
		updateValue = function(slider:PropertySlider):Void {};
		
		this.label = label;
		this.smallDelta = smallDelta;
		this.bigDelta = bigDelta;
		this.minValue = minValue;
		this.maxValue = maxValue;
		value = 0;
		
		upSmallButton = new Button(buttonWidth * 2 + buttonSpacing * 3 + valueWidth, labelHeight, ">", function()
		{
			value += smallDelta;
			onChange(this);
		});
		upBigButton = new Button(buttonWidth * 3 + buttonSpacing * 4 + valueWidth, labelHeight, ">>", function()
		{
			value += bigDelta;
			onChange(this);
		});
		downSmallButton = new Button(buttonWidth + buttonSpacing, labelHeight, "<", function()
		{
			value -= smallDelta;
			onChange(this);
		});
		downBigButton = new Button(0, labelHeight, "<<", function()
		{
			value -= bigDelta;
			onChange(this);
		});
		add(downBigButton);
		add(downSmallButton);
		add(upSmallButton);
		add(upBigButton);
	}
	
	function set_value(value:Float):Float
	{
		this.value = FlxMath.bound(value, minValue, maxValue);
		valueText.text = Std.string(decimalPlaces > 0 ? FlxMath.roundDecimal(this.value, decimalPlaces) : Math.round(this.value));
		return value;
	}
	
	function set_label(name:String):String
	{
		labelText.text = name;
		return name;
	}
	
	function get_label():String
	{
		return labelText.text;
	}
}

private class Button extends FlxButton
{
	public function new(x:Float, y:Float, txt:String, onClick:Void->Void)
	{
		super(x, y, txt, onClick);
		makeGraphic(14, 14, 0xffcccccc, true);
	}
}