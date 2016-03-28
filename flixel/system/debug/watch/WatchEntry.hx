package flixel.system.debug.watch;

import flash.display.Sprite;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.system.debug.FlxDebugger.GraphicCloseButton;
import flixel.system.debug.console.ConsoleUtil;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.text.TextField;
import openfl.text.TextFormat;
using flixel.util.FlxStringUtil;

class WatchEntry extends Sprite implements IFlxDestroyable
{
	private static inline var GUTTER = 4;
	
	public var data:WatchEntryData;
	public var displayName(default, null):String;

	private var nameText:TextField;
	private var valueText:EditableTextField;
	private var removeButton:FlxSystemButton;
	private var defaultFormat:TextFormat;

	public function new(displayName:String, data:WatchEntryData, removeEntry:WatchEntry->Void)
	{
		super();
		
		this.displayName = displayName;
		this.data = data;

		defaultFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, getTextColor());
		nameText = initTextField(DebuggerUtil.createTextField());
		valueText = initTextField(DebuggerUtil.initTextField(
			new EditableTextField(data.match(FIELD(_, _)), defaultFormat, submitValue)));
		
		updateName();
		
		addChild(removeButton = new FlxSystemButton(new GraphicCloseButton(0, 0), removeEntry.bind(this)));
		removeButton.y = (height - removeButton.height) / 2;
		removeButton.alpha = 0.3;
	}
	
	private function getTextColor():FlxColor
	{
		return switch (data)
		{
			case FIELD(_, _): 0xFFFFFF;
			case QUICK(_): 0xA5F1ED;
			case EXPRESSION(_): 0xC4FE83;
		}
	}
	
	private function initTextField<T:TextField>(textField:T):T
	{
		textField.selectable = true;
		textField.defaultTextFormat = defaultFormat;
		addChild(textField);
		return textField;
	}

	public function updateSize(nameWidth:Float, windowWidth:Float):Void
	{
		nameText.width = nameWidth;
		valueText.x = nameWidth + GUTTER;
		removeButton.x = windowWidth - removeButton.width - GUTTER;
	}
	
	private function updateName()
	{
		if (displayName != null)
		{
			nameText.text = displayName;
			return;
		}
		
		switch (data)
		{
			case FIELD(object, field):
				nameText.text = object.getClassName(true) + "." + field;
			case EXPRESSION(expression):
				nameText.text = expression;
			case QUICK(_):
		}
	}
	
	private function getValue():String
	{
		var value:Dynamic = switch (data)
		{
			case FIELD(object, field):
				Reflect.getProperty(object, field);
			case EXPRESSION(expression):
				#if hscript
				ConsoleUtil.runCommand(expression);
				#else
				"hscript is not installed";
				#end
			case QUICK(value):
				value;
		};
		
		if (Std.is(value, Float))
			value = FlxMath.roundDecimal(cast value, FlxG.debugger.precision);
		return Std.string(value);
	}
	
	private function submitValue(value:String):Void
	{
		switch (data)
		{
			case FIELD(object, field):
				Reflect.setProperty(object, field, value);
			case _:
		}
	}
	
	public function updateValue()
	{
		if (!valueText.isEditing)
			valueText.text = getValue();
	}
	
	public function getNameWidth():Float
	{
		return nameText.width;
	}
	
	public function getMinWidth():Float
	{
		return valueText.x + valueText.width + GUTTER * 2 + removeButton.width; 
	}
	
	public function destroy()
	{
		nameText = FlxDestroyUtil.removeChild(this, nameText);
		valueText = FlxDestroyUtil.removeChild(this, valueText);
	}
}