package org.flixel.system.debug;

import nme.Assets;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.text.TextField;
import nme.text.TextFieldType;
import nme.text.TextFormat;
import org.flixel.FlxAssets;

import org.flixel.FlxU;

/**
 * Helper class for the debugger overlay's Watch window.
 * Handles the display and modification of game variables on the fly.
 */
class WatchEntry
{
	/**
	 * The <code>Object</code> being watched.
	 */
	public var object:Dynamic;
	/**
	 * The member variable of that object.
	 */
	public var field:String;
	/**
	 * A custom display name for this object, if there is any.
	 */
	public var custom:String;
	/**
	 * The Flash <code>TextField</code> object used to display this entry's name.
	 */
	public var nameDisplay:TextField;
	/**
	 * The Flash <code>TextField</code> object used to display and edit this entry's value.
	 */
	public var valueDisplay:TextField;
	/**
	 * Whether the entry is currently being edited or not.
	 */
	public var editing:Bool;
	/**
	 * The value of the field before it was edited.
	 */
	public var oldValue:Dynamic;
	
	private var _whiteText:TextFormat;
	private var _blackText:TextFormat;
	
	/**
	 * Creates a new watch entry in the watch window.
	 * @param Y				The initial height in the Watch window.
	 * @param NameWidth		The initial width of the name field.
	 * @param ValueWidth	The initial width of the value field.
	 * @param Obj			The <code>Object</code> containing the variable we want to watch.
	 * @param Field			The variable name we want to watch.
	 * @param Custom		A custom display name (optional).
	 */
	public function new(Y:Float, NameWidth:Float, ValueWidth:Float, Obj:Dynamic, Field:String, Custom:String = null)
	{
		editing = false;
		
		object = Obj;
		field = Field;
		custom = Custom;
		
		var fontName:String = Assets.getFont(FlxAssets.debuggerFont).fontName;
		_whiteText = new TextFormat(fontName, 12, 0xffffff);
		_blackText = new TextFormat(fontName, 12, 0);
		
		nameDisplay = new TextField();
		nameDisplay.y = Y;
		nameDisplay.multiline = false;
		nameDisplay.selectable = true;
		nameDisplay.defaultTextFormat = _whiteText;
		
		valueDisplay = new TextField();
		valueDisplay.y = Y;
		valueDisplay.height = 15;
		valueDisplay.multiline = false;
		valueDisplay.selectable = true;
		valueDisplay.doubleClickEnabled = true;
		valueDisplay.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
		valueDisplay.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		valueDisplay.background = false;
		valueDisplay.backgroundColor = 0xffffff;
		valueDisplay.defaultTextFormat = _whiteText;
		
		updateWidth(NameWidth, ValueWidth);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		object = null;
		oldValue = null;
		nameDisplay = null;
		field = null;
		custom = null;
		valueDisplay.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		valueDisplay.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
		valueDisplay = null;
	}
	
	/**
	 * Set the watch window Y height of the Flash <code>TextField</code> objects.
	 */
	public function setY(Y:Float):Void
	{
		nameDisplay.y = Y;
		valueDisplay.y = Y;
	}
	
	/**
	 * Adjust the width of the Flash <code>TextField</code> objects.
	 */
	public function updateWidth(NameWidth:Float, ValueWidth:Float):Void
	{
		nameDisplay.width = NameWidth;
		valueDisplay.width = ValueWidth;
		if (custom != null)
		{
			nameDisplay.text = custom;
		}
		else
		{
			nameDisplay.text = "";
			if (NameWidth > 120)
			{
				nameDisplay.appendText(FlxU.getClassName(object, (NameWidth < 240)) + ".");
			}
			nameDisplay.appendText(field);
		}
	}
	
	/**
	 * Update the variable value on display with the current in-game value.
	 */
	public function updateValue():Bool
	{
		if (editing)
		{
			return false;
		}
		valueDisplay.text = Std.string(Reflect.getProperty(object, field));
		return true;
	}
	
	/**
	 * A watch entry was clicked, so flip into edit mode for that entry.
	 * @param	FlashEvent	Flash mouse event.
	 */
	public function onMouseUp(FlashEvent:MouseEvent):Void
	{
		editing = true;
		oldValue = Reflect.getProperty(object, field);
		valueDisplay.type = TextFieldType.INPUT;
		valueDisplay.setTextFormat(_blackText);
		valueDisplay.background = true;
		
	}
	
	/**
	 * Check to see if Enter, Tab or Escape were just released.
	 * Enter or Tab submit the change, and Escape cancels it.
	 * @param	FlashEvent	Flash keyboard event.
	 */
	public function onKeyUp(FlashEvent:KeyboardEvent):Void
	{
		if((FlashEvent.keyCode == 13) || (FlashEvent.keyCode == 9) || (FlashEvent.keyCode == 27)) //enter or tab or escape
		{
			if (FlashEvent.keyCode == 27)
			{
				cancel();
			}
			else
			{
				submit();
			}
		}
	}
	
	/**
	 * Cancel the current edits and stop editing.
	 */
	public function cancel():Void
	{
		valueDisplay.text = oldValue.toString();
		doneEditing();
	}
	
	/**
	 * Submit the current edits and stop editing.
	 */
	public function submit():Void
	{
		Reflect.setProperty(object, field, valueDisplay.text);
		doneEditing();
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
	}
}