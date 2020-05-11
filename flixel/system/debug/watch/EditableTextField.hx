package flixel.system.debug.watch;

import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
import Type.ValueType;

class EditableTextField extends TextField implements IFlxDestroyable
{
	public var isEditing(default, null):Bool;

	var allowEditing:Bool;
	var submitValue:Dynamic->Void;
	var expectedType:ValueType;

	var defaultFormat:TextFormat;
	var editFormat:TextFormat;

	public function new(allowEditing:Bool, defaultFormat:TextFormat, submitValue:Dynamic->Void, expectedType:ValueType)
	{
		super();
		this.allowEditing = allowEditing;
		this.submitValue = submitValue;
		this.defaultFormat = defaultFormat;
		this.expectedType = expectedType;

		if (allowEditing)
		{
			editFormat = new TextFormat(defaultFormat.font, defaultFormat.size, 0x000000);

			addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		}
	}

	public function destroy():Void
	{
		if (allowEditing)
		{
			removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		}
	}

	function onMouseUp(_):Void
	{
		setIsEditing(true);
	}

	function onKeyUp(e:KeyboardEvent):Void
	{
		switch (e.keyCode)
		{
			case Keyboard.ENTER:
				submit();
			case Keyboard.ESCAPE:
				setIsEditing(false);
		}
	}

	function onKeyDown(e:KeyboardEvent):Void
	{
		var modifier = 1.0;
		if (e.altKey)
			modifier = 0.1;
		if (e.shiftKey)
			modifier = 10.0;

		switch (e.keyCode)
		{
			case Keyboard.UP:
				cycleValue(modifier, 0);
			case Keyboard.DOWN:
				cycleValue(-modifier, text.length);
		}
	}

	function cycleValue(modifier:Float, selection:Int):Void
	{
		switch (expectedType)
		{
			case TInt | TFloat:
				cycleNumericValue(modifier);
				selectEnd();
			case TBool:
				text = if (text == "true") "false" else "true";
				selectEnd();
			case TEnum(e):
				cycleEnumValue(e, FlxMath.signOf(modifier));
				selectEnd();
			case _:
				setSelection(selection, selection);
		}
	}

	function selectEnd():Void
	{
		setSelection(text.length, text.length);
	}

	function cycleNumericValue(modifier:Float):Void
	{
		var value:Float = Std.parseFloat(text);
		if (Math.isNaN(value))
			return;

		value += modifier;
		value = FlxMath.roundDecimal(value, FlxG.debugger.precision);
		text = Std.string(value);
	}

	function cycleEnumValue(e:Enum<Dynamic>, modifier:Int):Void
	{
		var values = e.getConstructors();
		var index = values.indexOf(text);
		if (index == -1)
			index = 0;
		else
		{
			index += modifier;
			index = Std.int(FlxMath.wrap(index, 0, values.length - 1));
		}
		text = Std.string(values[index]);
	}

	function onFocusLost(_)
	{
		setIsEditing(false);
	}

	public function submit():Void
	{
		var value:Dynamic = switch (expectedType)
		{
			#if neko
			case TInt: Std.parseInt(text);
			case TFloat: Std.parseFloat(text);
			#end
			case TBool if (text == "true"): true;
			case TBool if (text == "false"): false;
			case TEnum(e):
				try Type.createEnum(e, text)
				catch (_:Dynamic) null;
			case _: text;
		}

		try
		{
			submitValue(value);
		}
		catch (e:Dynamic) {}

		setIsEditing(false);
	}

	function setIsEditing(isEditing:Bool)
	{
		this.isEditing = isEditing;

		#if FLX_KEYBOARD
		FlxG.keys.enabled = !isEditing;
		#end

		type = isEditing ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		background = isEditing;
		defaultTextFormat = isEditing ? editFormat : defaultFormat;
		setTextFormat(defaultTextFormat);
	}
}
