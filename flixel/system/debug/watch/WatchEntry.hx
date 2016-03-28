package flixel.system.debug.watch;

import flixel.system.FlxAssets;
import flixel.system.debug.console.ConsoleUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.text.TextField;
import openfl.text.TextFormat;
using flixel.util.FlxStringUtil;

/**
 * Base class for the different watch entry types.
 */
class WatchEntry implements IFlxDestroyable
{
	public var data:WatchEntryData;
	public var displayName(default, null):String;

	public var nameText:TextField;
	public var valueText:TextField;
	private var defaultFormat:TextFormat;

	public function new(displayName:String, data:WatchEntryData)
	{
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
		return textField;
	}
	
	public function setY(y:Float):Void
	{
		nameText.y = y;
		valueText.y = y;
	}

	public function updateWidth(nameWidth:Float, valueWidth:Float):Void
	{
		nameText.width = nameWidth;
		valueText.width = valueWidth;
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
	
	public function destroy() {}
}