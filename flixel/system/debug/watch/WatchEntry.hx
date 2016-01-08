package flixel.system.debug.watch;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxStringUtil;
import openfl.events.FocusEvent;
import openfl.ui.Keyboard;

/**
 * Helper class for the debugger overlay's Watch window.
 * Handles the display and modification of game variables on the fly.
 */
class WatchEntry implements IFlxDestroyable
{
	/**
	 * The Object being watched.
	 */
	public var object(default, null):Dynamic;
	/**
	 * The member variable of that object.
	 */
	public var field(default, null):String;	
	/**
	 * A custom display name for this object, if there is any.
	 */
	public var custom(default, null):String;
	/**
	 * The Flash TextField object used to display this entry's name.
	 */
	public var nameDisplay(default, null):TextField;
	/**
	 * The Flash TextField object used to display and edit this entry's value.
	 */
	public var valueDisplay(default, null):TextField;
	/**
	 * Whether the entry is currently being edited or not.
	 */
	public var editing(default, null):Bool;
	/**
	 * The value of the field before it was edited.
	 */
	public var oldValue(default, null):Dynamic;
	
	private var _whiteText:TextFormat;
	private var _blackText:TextFormat;
	private var _isQuickWatch:Bool = false;
	
	/**
	 * Creates a new watch entry in the watch window. 
	 * Will be a "quickWatch" when Obj and Field are null, but a Custom name is set.
	 * 
	 * @param 	y			The initial height in the Watch window.
	 * @param 	nameWidth	The initial width of the name field.
	 * @param 	valueWidth	The initial width of the value field.
	 * @param 	object		The Object containing the variable we want to watch.
	 * @param 	field		The variable name we want to watch.
	 * @param 	custom		A custom display name (optional).
	 */
	public function new(y:Float, nameWidth:Float, valueWidth:Float, object:Dynamic, field:String, ?custom:String)
	{
		editing = false;
		
		if (object == null && field == null && custom != null)
		{
			_isQuickWatch = true;
		}
		else
		{
			this.object = object;
			this.field = field;
		}
		
		this.custom = custom;
		
		var fontName:String = FlxAssets.FONT_DEBUGGER;
		
		// quickWatch is green, normal watch is white
		var color = _isQuickWatch ? 0xA5F1ED : 0xffffff;
		_whiteText = new TextFormat(fontName, 12, color);
		_blackText = new TextFormat(fontName, 12, 0);
		
		nameDisplay = new TextField();
		nameDisplay.y = y;
		nameDisplay.multiline = false;
		nameDisplay.selectable = true;
		nameDisplay.embedFonts = true;
		nameDisplay.defaultTextFormat = _whiteText;
		
		valueDisplay = new TextField();
		valueDisplay.y = y;
		valueDisplay.height = 20;
		valueDisplay.multiline = false;
		valueDisplay.selectable = true;
		valueDisplay.doubleClickEnabled = true;
		if (!_isQuickWatch) // No editing for quickWatch
		{
			valueDisplay.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			valueDisplay.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			valueDisplay.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		}
		valueDisplay.background = false;
		valueDisplay.backgroundColor = 0xffffff;
		valueDisplay.embedFonts = true;
		valueDisplay.defaultTextFormat = _whiteText;
		
		updateWidth(nameWidth, valueWidth);
	}
	
	public function destroy():Void
	{
		object = null;
		oldValue = null;
		nameDisplay = null;
		field = null;
		custom = null;
		if (valueDisplay != null)
		{
			valueDisplay.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			valueDisplay.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			valueDisplay.removeEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
			valueDisplay = null;
		}
	}
	
	public function setY(y:Float):Void
	{
		nameDisplay.y = y;
		valueDisplay.y = y;
	}
	
	/**
	 * Adjust the width of the Flash TextField objects.
	 */
	public function updateWidth(nameWidth:Float, valueWidth:Float):Void
	{
		nameDisplay.width = nameWidth;
		valueDisplay.width = valueWidth;
		if (custom != null)
		{
			nameDisplay.text = custom;
		}
		else if (field != null)
		{
			nameDisplay.text = "";
			if (nameWidth > 120)
			{
				nameDisplay.appendText(FlxStringUtil.getClassName(object, true) + ".");
			}
			
			nameDisplay.appendText(field);
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Update the variable value on display with the current in-game value.
	 */
	public function updateValue():Void
	{
		if (editing || _isQuickWatch)
			return;
		
		var property:Dynamic = Reflect.getProperty(object, field);
		valueDisplay.text = Std.string(property);
	}
	#end
	
	/**
	 * A watch entry was clicked, so flip into edit mode for that entry.
	 */
	private function onMouseUp(_):Void
	{
		editing = true;
		#if !FLX_NO_KEYBOARD
		FlxG.keys.enabled = false;
		#end
		oldValue = Reflect.getProperty(object, field);
		valueDisplay.type = TextFieldType.INPUT;
		valueDisplay.setTextFormat(_blackText);
		valueDisplay.background = true;
	}
	
	private function onKeyUp(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.ENTER)
			submit();
		else if (e.keyCode == Keyboard.ESCAPE)
			cancel();
	}
	
	private function onFocusLost(_)
	{
		cancel();
	}
	
	/**
	 * Cancel the current edits and stop editing.
	 */
	private function cancel():Void
	{
		valueDisplay.text = Std.string(oldValue);
		doneEditing();
	}
	
	/**
	 * Submit the current edits and stop editing.
	 */
	private function submit():Void
	{
		try
		{
			Reflect.setProperty(object, field, valueDisplay.text);
			doneEditing();
		}
		catch (e:Dynamic)
		{
			cancel();
		}
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("object", FlxStringUtil.getClassName(object, true)),
			LabelValuePair.weak("field", field)]);
	}
	
	/**
	 * Helper function, switches the text field back to display mode.
	 */
	private function doneEditing():Void
	{
		valueDisplay.type = TextFieldType.DYNAMIC;
		valueDisplay.setTextFormat(_whiteText);
		valueDisplay.defaultTextFormat = _whiteText;
		valueDisplay.background = false;
		editing = false;
		#if !FLX_NO_KEYBOARD
		FlxG.keys.enabled = true;
		#end
	}
}