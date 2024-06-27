package flixel.system.frontEnds;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import openfl.events.Event;
import openfl.events.TextEvent;

class InputTextFrontEnd
{
	public var focus(default, set):IFlxInputText;
	
	public var isTyping(get, never):Bool;
	
	var _registeredInputTexts:Array<IFlxInputText> = [];
	
	public function new() {}
	
	public function registerInputText(input:IFlxInputText):Void
	{
		if (!_registeredInputTexts.contains(input))
		{
			_registeredInputTexts.push(input);
			
			if (!FlxG.stage.window.onKeyDown.has(onKeyDown))
			{
				FlxG.stage.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
				// Higher priority is needed here because FlxKeyboard will cancel
				// the event for key codes in `preventDefaultKeys`.
				FlxG.stage.window.onKeyDown.add(onKeyDown, false, 1000);
				#if flash
				FlxG.stage.addEventListener(Event.COPY, onCopy);
				FlxG.stage.addEventListener(Event.CUT, onCut);
				FlxG.stage.addEventListener(Event.PASTE, onPaste);
				FlxG.stage.addEventListener(Event.SELECT_ALL, onSelectAll);
				FlxG.stage.window.onKeyUp.add(onKeyUp, false, 1000);
				#end
			}
		}
	}
	
	public function unregisterInputText(input:IFlxInputText):Void
	{
		if (_registeredInputTexts.contains(input))
		{
			_registeredInputTexts.remove(input);
			
			if (_registeredInputTexts.length == 0 && FlxG.stage.window.onKeyDown.has(onKeyDown))
			{
				FlxG.stage.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
				FlxG.stage.window.onKeyDown.remove(onKeyDown);
				#if flash
				FlxG.stage.removeEventListener(Event.COPY, onCopy);
				FlxG.stage.removeEventListener(Event.CUT, onCut);
				FlxG.stage.removeEventListener(Event.PASTE, onPaste);
				FlxG.stage.removeEventListener(Event.SELECT_ALL, onSelectAll);
				FlxG.stage.window.onKeyUp.remove(onKeyUp);
				#end
			}
		}
	}
	
	function onTextInput(event:TextEvent):Void
	{
		// Adding new lines is handled inside FlxInputText
		if (event.text.length == 1 && event.text.charCodeAt(0) == KeyCode.RETURN)
			return;

		if (focus != null)
		{
			focus.dispatchTypingAction(ADD_TEXT(event.text));
		}
	}
	
	function onKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		if (focus == null)
			return;

		#if flash
		// COPY, CUT, PASTE and SELECT_ALL events will only be dispatched if the stage has a focus.
		// Let's set one manually (just the stage itself)
		FlxG.stage.focus = FlxG.stage;
		#end

		// Taken from OpenFL's `TextField`
		var modifierPressed = #if mac modifier.metaKey #elseif js(modifier.metaKey || modifier.ctrlKey) #else (modifier.ctrlKey && !modifier.altKey) #end;
		
		switch (key)
		{
			case RETURN, NUMPAD_ENTER:
				focus.dispatchTypingAction(COMMAND(NEW_LINE));
			case BACKSPACE:
				focus.dispatchTypingAction(COMMAND(DELETE_LEFT));
			case DELETE:
				focus.dispatchTypingAction(COMMAND(DELETE_RIGHT));
			case LEFT:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(PREVIOUS_LINE, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(LEFT, modifier.shiftKey));
				}
			case RIGHT:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(NEXT_LINE, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(RIGHT, modifier.shiftKey));
				}
			case UP:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(HOME, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(UP, modifier.shiftKey));
				}
			case DOWN:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(END, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(DOWN, modifier.shiftKey));
				}
			case HOME:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(HOME, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(LINE_BEGINNING, modifier.shiftKey));
				}
			case END:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(END, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(LINE_END, modifier.shiftKey));
				}
			case C:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(COMMAND(COPY));
				}
			case X:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(COMMAND(CUT));
				}
			#if !js
			case V:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(COMMAND(PASTE));
				}
			#end
			case A:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(COMMAND(SELECT_ALL));
				}
			default:
		}

		#if html5
		// On HTML5, the SPACE key gets added to `FlxG.keys.preventDefaultKeys` by default, which also
		// stops it from dispatching a text input event. We need to call `onTextInput()` manually
		if (key == SPACE && FlxG.keys.preventDefaultKeys != null && FlxG.keys.preventDefaultKeys.contains(SPACE))
		{
			onTextInput(new TextEvent(TextEvent.TEXT_INPUT, false, false, " "));
		}
		#end
	}
	#if flash
	function onKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		if (FlxG.stage.focus == FlxG.stage)
		{
			FlxG.stage.focus = null;
		}
	}
	
	function onCopy(e:Event):Void
	{
		if (focus != null)
		{
			focus.dispatchTypingAction(COMMAND(COPY));
		}
	}
	
	function onCut(e:Event):Void
	{
		if (focus != null)
		{
			focus.dispatchTypingAction(COMMAND(CUT));
		}
	}
	
	function onPaste(e:Event):Void
	{
		if (focus != null)
		{
			focus.dispatchTypingAction(COMMAND(PASTE));
		}
	}
	
	function onSelectAll(e:Event):Void
	{
		if (focus != null)
		{
			focus.dispatchTypingAction(COMMAND(SELECT_ALL));
		}
	}
	#end
	
	function set_focus(value:IFlxInputText):IFlxInputText
	{
		if (focus != value)
		{
			if (focus != null)
			{
				focus.hasFocus = false;
			}
			
			focus = value;
			
			if (focus != null)
			{
				focus.hasFocus = true;
			}
			
			FlxG.stage.window.textInputEnabled = (focus != null);
		}
		
		return value;
	}

	function get_isTyping():Bool
	{
		return focus != null && focus.editable;
	}
}

interface IFlxInputText
{
	var editable:Bool;
	var hasFocus(default, set):Bool;
	function dispatchTypingAction(action:TypingAction):Void;
}

enum TypingAction
{
	ADD_TEXT(text:String);
	MOVE_CURSOR(type:MoveCursorAction, shiftKey:Bool);
	COMMAND(cmd:TypingCommand);
}

enum MoveCursorAction
{
	LEFT;
	RIGHT;
	UP;
	DOWN;
	HOME;
	END;
	LINE_BEGINNING;
	LINE_END;
	PREVIOUS_LINE;
	NEXT_LINE;
}

enum TypingCommand
{
	NEW_LINE;
	DELETE_LEFT;
	DELETE_RIGHT;
	COPY;
	CUT;
	PASTE;
	SELECT_ALL;
}