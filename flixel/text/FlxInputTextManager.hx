package flixel.text;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import openfl.events.Event;
import openfl.events.TextEvent;

/**
 * A manager for tracking and dispatching events for input text objects.
 * Normally accessed via the static `FlxInputText.globalManager` rather than being created separately.
 */
class FlxInputTextManager extends FlxBasic
{
	/**
	 * The input text object that's currently in focus, or `null` if there isn't any.
	 */
	public var focus(default, set):IFlxInputText;
	
	/**
	 * Returns whether or not there's currently an editable input text in focus.
	 */
	public var isTyping(get, never):Bool;
	
	/**
	 * Contains all of the currently registered input text objects.
	 */
	var _registeredInputTexts:Array<IFlxInputText>;
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		focus = null;
		unregisterAll();
		super.destroy();
	}

	/**
	 * Registers an input text object, and initiates the event listeners if it's
	 * the first one to be added.
	 */
	public function registerInputText(input:IFlxInputText):Void
	{
		if (_registeredInputTexts == null)
			_registeredInputTexts = [];

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

	/**
	 * Unregisters all the input texts from the manager.
	 */
	public function unregisterAll():Void
	{
		if (_registeredInputTexts == null)
			return;
			
		for (input in _registeredInputTexts)
			unregisterInputText(input);
	}
	
	/**
	 * Unregisters an input text object, and removes the event listeners if there
	 * aren't any more left.
	 */
	public function unregisterInputText(input:IFlxInputText):Void
	{
		if (_registeredInputTexts == null)
			return;
		
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
				_registeredInputTexts = null;
			}
		}
	}
	
	/**
	 * Called when a `TEXT_INPUT` event is received.
	 */
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
	
	/**
	 * Called when an `onKeyDown` event is recieved.
	 */
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
					focus.dispatchTypingAction(MOVE_CURSOR(WORD_LEFT, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(LEFT, modifier.shiftKey));
				}
			case RIGHT:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(WORD_RIGHT, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(RIGHT, modifier.shiftKey));
				}
			case UP:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(LINE_LEFT, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(UP, modifier.shiftKey));
				}
			case DOWN:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(LINE_RIGHT, modifier.shiftKey));
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
					focus.dispatchTypingAction(MOVE_CURSOR(LINE_LEFT, modifier.shiftKey));
				}
			case END:
				if (modifierPressed)
				{
					focus.dispatchTypingAction(MOVE_CURSOR(END, modifier.shiftKey));
				}
				else
				{
					focus.dispatchTypingAction(MOVE_CURSOR(LINE_RIGHT, modifier.shiftKey));
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

		#if (html5 && FLX_KEYBOARD)
		// On HTML5, the SPACE key gets added to `FlxG.keys.preventDefaultKeys` by default, which also
		// stops it from dispatching a text input event. We need to call `onTextInput()` manually
		if (key == SPACE && FlxG.keys.preventDefaultKeys != null && FlxG.keys.preventDefaultKeys.contains(SPACE))
		{
			onTextInput(new TextEvent(TextEvent.TEXT_INPUT, false, false, " "));
		}
		#end
	}

	#if flash
	/**
	 * Called when an `onKeyUp` event is recieved. This is used to reset the stage's focus
	 * back to null.
	 */
	function onKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		if (FlxG.stage.focus == FlxG.stage)
		{
			FlxG.stage.focus = null;
		}
	}
	
	/**
	 * Called when a `COPY` event is received.
	 */
	function onCopy(e:Event):Void
	{
		if (focus != null)
		{
			focus.dispatchTypingAction(COMMAND(COPY));
		}
	}
	
	/**
	 * Called when a `CUT` event is received.
	 */
	function onCut(e:Event):Void
	{
		if (focus != null)
		{
			focus.dispatchTypingAction(COMMAND(CUT));
		}
	}
	
	/**
	 * Called when a `PASTE` event is received.
	 */
	function onPaste(e:Event):Void
	{
		if (focus != null)
		{
			focus.dispatchTypingAction(COMMAND(PASTE));
		}
	}
	
	/**
	 * Called when a `SELECT_ALL` event is received.
	 */
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
	/**
	 * Moves the cursor one character to the left.
	 */
	LEFT;

	/**
	 * Moves the cursor one character to the right.
	 */
	RIGHT;

	/**
	 * Moves the cursor up to the previous line.
	 */
	UP;

	/**
	 * Moves the cursor down to the next line.
	 */
	DOWN;

	/**
	 * Moves the cursor to the beginning of the text.
	 */
	HOME;

	/**
	 * Moves the cursor to the end of the text.
	 */
	END;

	/**
	 * Moves the cursor to the beginning of the current line.
	 */
	LINE_LEFT;

	/**
	 * Moves the cursor to the end of the current line.
	 */
	LINE_RIGHT;

	/**
	 * Moves the cursor to the beginning of the previous word, or the
	 * start of the text if there aren't any more words.
	 */
	WORD_LEFT;

	/**
	 * Moves the cursor to the beginning of the next word, or the end
	 * of the text if there aren't any more words.
	 */
	WORD_RIGHT;
}

enum TypingCommand
{
	/**
	 * Enters a new line into the text.
	 */
	NEW_LINE;

	/**
	 * Deletes the character to the left of the cursor, or the selection if
	 * there's already one.
	 */
	DELETE_LEFT;

	/**
	 * Deletes the character to the right of the cursor, or the selection if
	 * there's already one.
	 */
	DELETE_RIGHT;

	/**
	 * Copies the current selection into the clipboard.
	 */
	COPY;

	/**
	 * Copies the current selection into the clipboard and then removes it
	 * from the text field.
	 */
	CUT;

	/**
	 * Pastes the clipboard's text into the field.
	 */
	PASTE;

	/**
	 * Selects all of the text in the field.
	 */
	SELECT_ALL;
}