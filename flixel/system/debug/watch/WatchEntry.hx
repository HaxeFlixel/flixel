package flixel.system.debug.watch;

import flash.display.Sprite;
import flixel.system.FlxAssets;
import flixel.system.debug.console.ConsoleUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.text.TextField;
import openfl.text.TextFormat;
using flixel.util.FlxStringUtil;

/**
 * Base class for the different watch entry types.
 */
class WatchEntry extends Sprite implements IFlxDestroyable
{
	private static inline var GUTTER = 4;
	
	public var data:WatchEntryData;
	public var displayName(default, null):String;

	private var nameText:TextField;
	private var valueText:TextField;
	private var defaultFormat:TextFormat;

	public function new(displayName:String, data:WatchEntryData)
	{
		super();
		
		this.displayName = displayName;
		this.data = data;

		defaultFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, getTextColor());
		nameText = createTextField();
		valueText = createTextField();
		
		updateName();
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
	
	private function createTextField():TextField
	{
		var textField = DebuggerUtil.createTextField();
		textField.selectable = true;
		textField.defaultTextFormat = defaultFormat;
		addChild(textField);
		return textField;
	}

	public function updateNameWidth(nameWidth:Float):Void
	{
		nameText.width = nameWidth;
		valueText.x = nameWidth + GUTTER;
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
	
	public function updateValue()
	{
		valueText.text = Std.string(switch (data)
		{
			case FIELD(object, field):
				Reflect.getProperty(object, field);
			case EXPRESSION(expression):
				#if hscript
				ConsoleUtil.runCommand(expression);
				#else
				"hscript not installed";
				#end
			case QUICK(value):
				value;
		});
	}
	
	public function getNameWidth():Float
	{
		return nameText.width;
	}
	
	public function destroy()
	{
		nameText = FlxDestroyUtil.removeChild(this, nameText);
		valueText = FlxDestroyUtil.removeChild(this, valueText);
	}
}