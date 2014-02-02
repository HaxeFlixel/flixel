package flixel.system.debug;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import openfl.Assets;

/**
 * Helper class for the debugger overlay's Watch window.
 * Handles the display and modification of game variables on the fly.
 */
class WatchEntry
{
	/**
	 * The Object being watched.
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
	 * The Flash TextField object used to display this entry's name.
	 */
	public var nameDisplay:TextField;
	/**
	 * The Flash TextField object used to display and edit this entry's value.
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
	 * Whether this entry is a quickWatch or not.
	 */
	public var quickWatch:Bool = false;
	
	/**
	 * Creates a new watch entry in the watch window. 
	 * Will be a "quickWatch" when Obj and Field are null, but a Custom name is set.
	 * 
	 * @param Y				The initial height in the Watch window.
	 * @param NameWidth		The initial width of the name field.
	 * @param ValueWidth	The initial width of the value field.
	 * @param Obj			The Object containing the variable we want to watch.
	 * @param Field			The variable name we want to watch.
	 * @param Custom		A custom display name (optional).
	 */
	public function new(Y:Float, NameWidth:Float, ValueWidth:Float, Obj:Dynamic, Field:String, Custom:String = null)
	{
		editing = false;
		
		if (Obj == null && Field == null && Custom != null)
			quickWatch = true;
		
		custom = Custom;
		
		// No need to retrieve a variable if this is a quickWatch
		if (!quickWatch)
		{
			object = Obj;
			field = Field;
			
			var tempArr:Array<String> = field.split(".");
			var l:Int = tempArr.length;
			var tempObj:Dynamic = object;
			var tempVarName:String = "";
			for (i in 0...l)
			{
				tempVarName = tempArr[i];
				
				try 
				{
					Reflect.getProperty(tempObj, tempVarName);
				}
				catch (e:Dynamic)
				{
					FlxG.log.error("Watch: " + Std.string(tempObj) + " does not have a field '" + tempVarName + "'");
					tempVarName = null;
					break;
				}
				
				if (i < (l - 1))
				{
					tempObj = Reflect.getProperty(tempObj, tempVarName);
				}
			}
			
			object = tempObj;
			field = tempVarName;
		}
		
		var fontName:String = FlxAssets.FONT_DEBUGGER;
		// quickWatch is green, normal watch is white
		var color:Int = 0xffffff;
		if (quickWatch)
			color = 0xA5F1ED;
		
		_whiteText = new TextFormat(fontName, 12, color);
		_blackText = new TextFormat(fontName, 12, 0);
		
		nameDisplay = new TextField();
		nameDisplay.y = Y;
		nameDisplay.multiline = false;
		nameDisplay.selectable = true;
		nameDisplay.embedFonts = true;
		nameDisplay.defaultTextFormat = _whiteText;
		
		valueDisplay = new TextField();
		valueDisplay.y = Y;
		valueDisplay.height = 20;
		valueDisplay.multiline = false;
		valueDisplay.selectable = true;
		valueDisplay.doubleClickEnabled = true;
		// No editing for quickWatch
		if (!quickWatch) 
		{
			valueDisplay.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			valueDisplay.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		valueDisplay.background = false;
		valueDisplay.backgroundColor = 0xffffff;
		valueDisplay.embedFonts = true;
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
		if (valueDisplay != null)
		{
			valueDisplay.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			valueDisplay.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			valueDisplay = null;
		}
	}
	
	/**
	 * Set the watch window Y height of the Flash TextField objects.
	 */
	public function setY(Y:Float):Void
	{
		nameDisplay.y = Y;
		valueDisplay.y = Y;
	}
	
	/**
	 * Adjust the width of the Flash TextField objects.
	 */
	public function updateWidth(NameWidth:Float, ValueWidth:Float):Void
	{
		nameDisplay.width = NameWidth;
		valueDisplay.width = ValueWidth;
		if (custom != null)
		{
			nameDisplay.text = custom;
		}
		else if (field != null)
		{
			nameDisplay.text = "";
			if (NameWidth > 120)
				nameDisplay.appendText(FlxStringUtil.getClassName(object, (NameWidth < 240)) + ".");
			
			nameDisplay.appendText(field);
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Update the variable value on display with the current in-game value.
	 */
	public function updateValue():Bool
	{
		if (editing || quickWatch) {
			return false;
		}
		
		var property:Dynamic = Reflect.getProperty(object, field);
		valueDisplay.text = Std.string(property);
		
		return true;
	}
	#end
	
	/**
	 * A watch entry was clicked, so flip into edit mode for that entry.
	 * @param	FlashEvent	Flash mouse event.
	 */
	public function onMouseUp(FlashEvent:MouseEvent):Void
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
	
	/**
	 * Check to see if Enter, Tab or Escape were just released.
	 * Enter or Tab submit the change, and Escape cancels it.
	 * @param	FlashEvent	Flash keyboard event.
	 */
	public function onKeyUp(FlashEvent:KeyboardEvent):Void
	{
		if ((FlashEvent.keyCode == 13) || (FlashEvent.keyCode == 9) || (FlashEvent.keyCode == 27)) //enter or tab or escape
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
		var property:Dynamic = Reflect.getProperty(object, field);
		
		// Workaround to be able to edit FlxPoints
		if (Std.is(property, FlxPoint)) {
			var xString:String = valueDisplay.text.split(" |")[0];
			xString = xString.substring(3, xString.length);
			var xValue:Float = Std.parseFloat(xString);
			
			var yString:String = valueDisplay.text.split("| ")[1];
			yString = yString.substring(3, yString.length);
			var yValue:Float = Std.parseFloat(yString);
			
			if (!Math.isNaN(xValue)) 
				Reflect.setField(property, "x", xValue);
			if (!Math.isNaN(yValue)) 
				Reflect.setField(property, "y", yValue);
		}
		else
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
		#if !FLX_NO_KEYBOARD
			FlxG.keys.enabled = true;
		#end
	}
}