package flixel.system.debug.watch;

import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.system.debug.FlxDebugger.GraphicCloseButton;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

using flixel.util.FlxStringUtil;

#if hscript
import flixel.system.debug.console.ConsoleUtil;
#end

class WatchEntry extends Sprite implements IFlxDestroyable
{
	static inline var GUTTER = 4;
	static inline var TEXT_HEIGHT = 20;
	static inline var MAX_NAME_WIDTH = 125;

	public var data:WatchEntryData;
	public var displayName(default, null):String;

	var nameText:TextField;
	var valueText:EditableTextField;
	var removeButton:FlxSystemButton;
	var defaultFormat:TextFormat;

	public function new(displayName:String, data:WatchEntryData, removeEntry:WatchEntry->Void)
	{
		super();

		this.displayName = displayName;
		this.data = data;

		defaultFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, getTextColor());
		nameText = initTextField(DebuggerUtil.createTextField());
		var expectedType = Type.typeof(getValue());
		valueText = initTextField(DebuggerUtil.initTextField(new EditableTextField(data.match(FIELD(_, _)), defaultFormat, submitValue, expectedType)));

		updateName();

		addChild(removeButton = new FlxSystemButton(new GraphicCloseButton(0, 0), removeEntry.bind(this)));
		removeButton.y = (TEXT_HEIGHT - removeButton.height) / 2;
		removeButton.alpha = 0.3;
	}

	function getTextColor():FlxColor
	{
		return switch (data)
		{
			case FIELD(_, _): 0xFFFFFF;
			case QUICK(_): 0xA5F1ED;
			case EXPRESSION(_, _): 0xC4FE83;
			case FUNCTION(_): 0xF1A5A5;
		}
	}

	function initTextField<T:TextField>(textField:T):T
	{
		textField.selectable = true;
		textField.defaultTextFormat = defaultFormat;
		textField.autoSize = TextFieldAutoSize.NONE;
		textField.height = TEXT_HEIGHT;
		addChild(textField);
		return textField;
	}

	public function updateSize(nameWidth:Float, windowWidth:Float):Void
	{
		var textWidth = windowWidth - removeButton.width - GUTTER;

		nameText.width = nameWidth;
		valueText.x = nameWidth + GUTTER;
		valueText.width = textWidth - nameWidth - GUTTER;
		removeButton.x = textWidth;
	}

	function updateName()
	{
		if (displayName != null)
		{
			setNameText(displayName);
			return;
		}

		switch (data)
		{
			case FIELD(object, field):
				setNameText(object.getClassName(true) + "." + field);
			case EXPRESSION(expression, _):
				setNameText(expression);
			case QUICK(_):
			case FUNCTION(_):
		}
	}

	function setNameText(name:String)
	{
		nameText.text = name;
		var currentWidth = nameText.textWidth + 4;
		nameText.width = Math.min(currentWidth, MAX_NAME_WIDTH);
	}

	function getValue():Dynamic
	{
		return switch (data)
		{
			case FIELD(object, field):
				Reflect.getProperty(object, field);
			case EXPRESSION(_, parsedExpr):
				#if hscript
				ConsoleUtil.runExpr(parsedExpr);
				#else
				"hscript is not installed";
				#end
			case QUICK(value):
				value;
			case FUNCTION(func):
				func();
		}
	}

	function getFormattedValue():String
	{
		var value:Dynamic = getValue();
		if ((value is Float))
			value = FlxMath.roundDecimal(cast value, FlxG.debugger.precision);
		return Std.string(value);
	}

	function submitValue(value:Dynamic):Void
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
			valueText.text = getFormattedValue();
	}

	public function getNameWidth():Float
	{
		return nameText.width;
	}

	public function getMinWidth():Float
	{
		return valueText.x + GUTTER * 2 + removeButton.width;
	}

	public function destroy()
	{
		nameText = FlxDestroyUtil.removeChild(this, nameText);
		FlxDestroyUtil.destroy(valueText);
		valueText = FlxDestroyUtil.removeChild(this, valueText);
	}
}
