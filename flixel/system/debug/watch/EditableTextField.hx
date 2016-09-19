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

	private var allowEditing:Bool;
	private var submitValue:Dynamic->Void;
	private var expectedType:ValueType;

	private var defaultFormat:TextFormat;
	private var editFormat:TextFormat;
	
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
	
	private function onMouseUp(_):Void
	{
		setIsEditing(true);
	}
	
	private function onKeyUp(e:KeyboardEvent):Void
	{
		switch (e.keyCode)
		{
			case Keyboard.ENTER:
				submit();
			case Keyboard.ESCAPE:
				setIsEditing(false);
		}
	}

	private function onKeyDown(e:KeyboardEvent):Void
	{
		var modifier = 1.0;
		if (e.altKey)
			modifier = 0.1;
		if (e.shiftKey)
			modifier = 10.0;
		
		switch (e.keyCode)
		{
			case Keyboard.UP:
				if (!modifyNumericValue(modifier))
					setSelection(0, 0);
			case Keyboard.DOWN:
				if (!modifyNumericValue(-modifier))
					setSelection(text.length, text.length);
		}
	}
	
	private function modifyNumericValue(modifier:Float):Bool
	{
		var value:Float = Std.parseFloat(text);
		if (Math.isNaN(value))
			return false;

		value += modifier;
		value = FlxMath.roundDecimal(value, FlxG.debugger.precision);
		text = Std.string(value);
		return true;
	}

	private function onFocusLost(_)
	{
		setIsEditing(false);
	}

	public function submit():Void
	{
		var value:Dynamic = switch (expectedType)
		{
			case TInt: Std.parseInt(text);
			case TFloat: Std.parseFloat(text);
			case TBool if (text == "true"): true;
			case TBool if (text == "false"): false;
			case _: text;
		}

		try
		{
			submitValue(value);
		}
		catch (e:Dynamic) {}
		
		setIsEditing(false);
	}
	
	private function setIsEditing(isEditing:Bool)
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