package flixel.system.debug.watch;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

class EditableTextField extends TextField implements IFlxDestroyable
{
	public var isEditing(default, null):Bool;

	private var allowEditing:Bool;
	private var submitValue:String->Void;
	
	private var defaultFormat:TextFormat;
	private var editFormat:TextFormat;
	
	public function new(allowEditing:Bool, defaultFormat:TextFormat, submitValue:Dynamic->Void) 
	{
		super();
		this.allowEditing = allowEditing;
		this.submitValue = submitValue;
		this.defaultFormat = defaultFormat;
		
		if (allowEditing)
		{
			editFormat = new TextFormat(defaultFormat.font, defaultFormat.size, 0x000000);
			
			addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		}
	}

	public function destroy():Void 
	{
		if (allowEditing)
		{
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			removeEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		}
	}
	
	private function onMouseUp(_):Void
	{
		setIsEditing(true);
	}
	
	private function onKeyUp(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.ENTER)
			submit();
		else if (e.keyCode == Keyboard.ESCAPE)
			setIsEditing(false);
	}
	
	private function onFocusLost(_)
	{
		setIsEditing(false);
	}

	private function submit():Void
	{
		try
		{
			submitValue(text);
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