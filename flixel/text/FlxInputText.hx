package flixel.text;

import flixel.input.touch.FlxTouch;
import flixel.input.FlxPointer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.frontEnds.InputTextFrontEnd;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.system.Clipboard;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.text.TextFormat;
import openfl.utils.QName;

/**
 * An `FlxText` object that can be selected and edited by the user.
 */
class FlxInputText extends FlxText implements IFlxInputText
{
	/**
	 * The gaps at the sides of the text field (2px).
	 */
	static inline var GUTTER:Int = 2;
	
	/**
	 * Characters that break up the words to select when double-pressing.
	 */
	static final DELIMITERS:Array<String> = ['\n', '.', '!', '?', ',', ' ', ';', ':', '(', ')', '-', '_', '/'];
	
	/**
	 * Whether or not the text field has a background.
	 */
	public var background(default, set):Bool = false;
	
	/**
	 * The color of the background of the text field, if it's enabled.
	 */
	public var backgroundColor(default, set):FlxColor = FlxColor.WHITE;
	
	/**
	 * Indicates the bottommost line (1-based index) that is currently
	 * visible in the text field.
	 */
	public var bottomScrollV(get, never):Int;
	
	/**
	 * A function called when an action occurs in the text field. The first parameter
	 * is the current text, and the second parameter indicates what kind of action
	 * it was.
	 */
	public var callback:String->FlxInputTextAction->Void;
	
	/**
	 * The selection cursor's color. Has the same color as the text field by default, and 
	 * it's automatically set whenever it changes.
	 */
	public var caretColor(default, set):FlxColor;
	
	/**
	 * The position of the selection cursor. An index of 0 means the caret is before the
	 * character at position 0.
	 * 
	 * Modifying this will reset the current selection (no text will be selected).
	 */
	public var caretIndex(get, set):Int;
	
	/**
	 * The selection cursor's width.
	 */
	public var caretWidth(default, set):Int = 1;
	
	/**
	 * This regular expression will filter out (remove) everything that matches.
	 * 
	 * Changing this will automatically set `filterMode` to `CUSTOM_FILTER`.
	 */
	public var customFilterPattern(default, set):EReg;

	/**
	 * Whether or not the text field can be edited by the user.
	 */
	public var editable:Bool = true;
	
	/**
	 * The color of the border for the text field, if it has a background.
	 */
	public var fieldBorderColor(default, set):FlxColor = FlxColor.BLACK;
	
	/**
	 * The thickness of the border for the text field, if it has a background.
	 * 
	 * Setting this to 0 will remove the border entirely.
	 */
	public var fieldBorderThickness(default, set):Int = 1;
	
	/**
	 * Defines how to filter the text (no filter, only letters, only numbers, 
	 * only letters & numbers, or a custom filter).
	 */
	public var filterMode(default, set):FlxInputTextFilterMode = NO_FILTER;
	
	/**
	 * Callback that is triggered when this text field gains focus.
	 */
	public var focusGained:Void->Void;
	
	/**
	 * Callback that is triggered when this text field loses focus.
	 */
	public var focusLost:Void->Void;
	
	/**
	 * Defines whether a letter case is enforced on the text.
	 */
	public var forceCase(default, set):FlxInputTextCase = ALL_CASES;
	
	/**
	 * Whether or not the text field is the current active one on the screen.
	 */
	public var hasFocus(default, set):Bool = false;
	
	/**
	 * Set the maximum length for the text field. 0 means unlimited.
	 */
	public var maxLength(default, set):Int = 0;

	/**
	 * The maximum value of `scrollH`.
	 */
	public var maxScrollH(get, never):Int;
	
	/**
	 * The maximum value of `scrollV`.
	 */
	public var maxScrollV(get, never):Int;
	
	/**
	 * Whether or not the user can create a new line in the text field
	 * with the enter key.
	 */
	public var multiline(get, set):Bool;
	
	/**
	 * Whether or not the text field is a password text field. This will
	 * hide all characters behind asterisks (*), and prevent any text
	 * from being copied.
	 */
	public var passwordMode(get, set):Bool;

	/**
	 * The current horizontal scrolling position, in pixels. Defaults to
	 * 0, which means the text is not horizontally scrolled.
	 */
	public var scrollH(get, set):Int;
	
	/**
	 * The current vertical scrolling position, by line number. If the first
	 * line displayed is the first line in the text field, `scrollV`
	 * is set to 1 (not 0).
	 */
	public var scrollV(get, set):Int;

	/**
	 * Whether or not the text can be selected by the user. If set to false,
	 * the text field will technically also become uneditable, since the user
	 * can't select it first.
	 */
	public var selectable:Bool = true;

	/**
	 * The color that the text inside the selection will change into, if
	 * `useSelectedTextFormat` is enabled.
	 */
	public var selectedTextColor(default, set):FlxColor = FlxColor.WHITE;
	
	/**
	 * The beginning index of the current selection.
	 * 
	 * **Warning:** Will be -1 if the text hasn't been selected yet!
	 */
	public var selectionBeginIndex(get, never):Int;

	/**
	 * The color of the selection, shown behind the currently selected text.
	 */
	public var selectionColor(default, set):FlxColor = FlxColor.BLACK;
	
	/**
	 * The ending index of the current selection.
	 * 
	 * **Warning:** Will be -1 if the text hasn't been selected yet!
	 */
	public var selectionEndIndex(get, never):Int;

	/**
	 * If `false`, no extra format will be applied for selected text.
	 * 
	 * Useful if you are using `addFormat()`, as the selected text format might
	 * overwrite some of their properties.
	 */
	public var useSelectedTextFormat(default, set):Bool = true;
	
	/**
	 * An FlxSprite representing the background of the text field.
	 */
	var _backgroundSprite:FlxSprite;
	/**
	 * An FlxSprite representing the selection cursor.
	 */
	var _caret:FlxSprite;
	/**
	 * This variable is used for the caret flash timer to indicate whether it
	 * is currently visible or not.
	 */
	var _caretFlash:Bool = false;
	/**
	 * Internal variable for the current index of the selection cursor.
	 */
	var _caretIndex:Int = -1;
	/**
	 * The timer used to flash the caret while the text field has focus.
	 */
	var _caretTimer:FlxTimer = new FlxTimer();
	/**
	 * An FlxSprite representing the border of the text field.
	 */
	var _fieldBorderSprite:FlxSprite;
	/**
	 * Internal variable that holds the camera that the text field is being pressed on.
	 */
	var _pointerCamera:FlxCamera;
	/**
	 * Indicates whether or not the background sprites need to be regenerated due to a
	 * change.
	 */
	var _regenBackground:Bool = false;
	/**
	 * An array holding the selection box sprites for the text field. It will only be as
	 * long as the amount of lines that are currently visible. Some items may be null if
	 * the respective line hasn't been selected yet.
	 */
	var _selectionBoxes:Array<FlxSprite> = [];
	/**
	 * The format that will be used for text inside the current selection.
	 */
	var _selectionFormat:TextFormat = new TextFormat();
	/**
	 * The current index of the selection from the caret.
	 */
	var _selectionIndex:Int = -1;
	#if FLX_POINTER_INPUT
	/**
	 * Stores the last time that this text field was pressed on, which helps to check for double-presses.
	 */
	var _lastPressTime:Int = 0;
	
	/**
	 * Timer for the text field to scroll vertically when dragging over it.
	 */
	var _scrollVCounter:Float = 0;
	#if FLX_MOUSE
	/**
	 * Indicates whether the mouse is pressing down on this text field.
	 */
	var _mouseDown:Bool = false;
	#end
	#if FLX_TOUCH
	/**
	 * Stores the FlxTouch that is pressing down on this text field, if there is one.
	 */
	var _currentTouch:FlxTouch;
	/**
	 * Used for checking if the current touch has just moved on the X axis.
	 */
	var _lastTouchX:Null<Float>;
	/**
	 * Used for checking if the current touch has just moved on the Y axis.
	 */
	var _lastTouchY:Null<Float>;
	#end
	#end
	
	/**
	 * Creates a new `FlxInputText` object at the specified position.
	 * @param x               The X position of the text.
	 * @param y               The Y position of the text.
	 * @param fieldWidth      The `width` of the text object. Enables `autoSize` if `<= 0`.
	 *                         (`height` is determined automatically).
	 * @param text            The actual text you would like to display initially.
	 * @param size            The font size for this text object.
	 * @param textColor       The color of the text
	 * @param backgroundColor The color of the background (`FlxColor.TRANSPARENT` for no background color)
	 * @param embeddedFont    Whether this text field uses embedded fonts or not.
	 */
	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, textColor:FlxColor = FlxColor.BLACK,
			backgroundColor:FlxColor = FlxColor.WHITE, embeddedFont:Bool = true)
	{
		super(x, y, fieldWidth, text, size, embeddedFont);
		if (text == null || text == "")
		{
			textField.text = "";
			_regen = true;
		}
		this.backgroundColor = backgroundColor;
		
		// Default to a single-line text field
		wordWrap = multiline = false;
		// If the text field's type isn't INPUT and there's a new line at the end
		// of the text, it won't be counted for in `numLines`
		textField.type = INPUT;
		
		_selectionFormat.color = selectedTextColor;
		
		_caret = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		_caret.visible = false;
		updateCaretSize();
		updateCaretPosition();
		
		color = textColor;
		
		if (backgroundColor != FlxColor.TRANSPARENT)
		{
			background = true;
		}
		
		FlxG.inputText.registerInputText(this);
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		#if FLX_POINTER_INPUT
		if (visible)
		{
			if (!updateMouseInput(elapsed))
				updateTouchInput(elapsed);
		}
		#end
	}
	
	override function draw():Void
	{
		regenGraphic();

		drawSprite(_fieldBorderSprite);
		drawSprite(_backgroundSprite);

		for (box in _selectionBoxes)
			drawSprite(box);

		super.draw();
		
		drawSprite(_caret);
	}
	
	/**
	 * Clean up memory.
	 */
	override function destroy():Void
	{
		FlxG.inputText.unregisterInputText(this);

		_backgroundSprite = FlxDestroyUtil.destroy(_backgroundSprite);
		_caret = FlxDestroyUtil.destroy(_caret);
		if (_caretTimer != null)
		{
			_caretTimer.cancel();
			_caretTimer = FlxDestroyUtil.destroy(_caretTimer);
		}
		_fieldBorderSprite = FlxDestroyUtil.destroy(_fieldBorderSprite);
		_pointerCamera = null;
		while (_selectionBoxes.length > 0)
			FlxDestroyUtil.destroy(_selectionBoxes.pop());
		_selectionBoxes = null;
		_selectionFormat = null;
		#if FLX_TOUCH
		_currentTouch = null;
		#end
		
		super.destroy();
	}

	override function applyFormats(formatAdjusted:TextFormat, useBorderColor:Bool = false):Void
	{
		// scroll variables will be reset when `textField.setTextFormat()` is called,
		// cache the current ones first
		var cacheScrollH = scrollH;
		var cacheScrollV = scrollV;
		
		super.applyFormats(formatAdjusted, useBorderColor);
		
		if (!useBorderColor && useSelectedTextFormat && selectionEndIndex > selectionBeginIndex)
			textField.setTextFormat(_selectionFormat, selectionBeginIndex, selectionEndIndex);

		// set the scroll back to how it was
		scrollH = cacheScrollH;
		scrollV = cacheScrollV;
	}
	
	override function regenGraphic():Void
	{
		var regenSelection = _regen;
		
		super.regenGraphic();
		
		if (_caret != null && regenSelection)
			updateSelectionSprites();
		if (_regenBackground)
			regenBackground();
	}
	
	public function dispatchTypingAction(action:TypingAction):Void
	{
		switch (action)
		{
			case ADD_TEXT(newText):
				if (editable)
				{
					addText(newText);
				}
			case MOVE_CURSOR(type, shiftKey):
				moveCursor(type, shiftKey);
			case COMMAND(cmd):
				runCommand(cmd);
		}
	}

	/**
	 * Replaces the currently selected text with `newText`, or just inserts it at
	 * the selection cursor if there isn't any text selected.
	 */
	public function replaceSelectedText(newText:String):Void
	{
		if (newText == null)
			newText = "";
		if (newText == "" && _selectionIndex == _caretIndex)
			return;
			
		var beginIndex = selectionBeginIndex;
		var endIndex = selectionEndIndex;
		
		if (beginIndex == endIndex && maxLength > 0 && text.length == maxLength)
			return;
			
		if (beginIndex < 0)
		{
			beginIndex = 0;
		}
		
		replaceText(beginIndex, endIndex, newText);
	}

	/**
	 * Sets the selection to span from `beginIndex` to `endIndex`. The selection cursor
	 * will end up at `endIndex`.
	 */
	public function setSelection(beginIndex:Int, endIndex:Int):Void
	{
		_selectionIndex = beginIndex;
		_caretIndex = endIndex;
		
		if (textField == null)
			return;

		updateSelection();
	}

	/**
	 * Filters the specified text and adds it to the field at the current selection.
	 */
	function addText(newText:String):Void
	{
		newText = filterText(newText, true);
		if (newText.length > 0)
		{
			replaceSelectedText(newText);
			onChange(INPUT_ACTION);
		}
	}
	
	/**
	 * Helper function to draw sprites with the correct cameras and scroll factor.
	 */
	function drawSprite(sprite:FlxSprite):Void
	{
		if (sprite != null && sprite.visible)
		{
			sprite.scrollFactor.copyFrom(scrollFactor);
			sprite._cameras = _cameras;
			sprite.draw();
		}
	}

	/**
	 * Returns the specified text filtered using `maxLength`, `forceCase` and `filterMode`.
	 * @param newText   The string to filter.
	 * @param selection Whether or not this string is meant to be added at the selection or if we're
	 *                  replacing the entire text. This is used for cutting the string appropiately
	 *                  when `maxLength` is set.
	 */
	function filterText(newText:String, selection:Bool = false):String
	{
		if (maxLength > 0)
		{
			var removeLength = selection ? (selectionEndIndex - selectionBeginIndex) : text.length;
			var newMaxLength = maxLength - text.length + removeLength;
			
			if (newMaxLength <= 0)
			{
				newText = "";
			}
			else if (newMaxLength < newText.length)
			{
				newText = newText.substr(0, newMaxLength);
			}
		}
		
		if (forceCase == UPPER_CASE)
		{
			newText = newText.toUpperCase();
		}
		else if (forceCase == LOWER_CASE)
		{
			newText = newText.toLowerCase();
		}
		
		if (filterMode != NO_FILTER)
		{
			var pattern = switch (filterMode)
			{
				case ONLY_ALPHA:
					~/[^a-zA-Z]*/g;
				case ONLY_NUMERIC:
					~/[^0-9]*/g;
				case ONLY_ALPHANUMERIC:
					~/[^a-zA-Z0-9]*/g;
				case CUSTOM_FILTER:
					customFilterPattern;
				default:
					throw "Unknown filterMode (" + filterMode + ")";
			}
			if (pattern != null)
				newText = pattern.replace(newText, "");
		}
		
		return newText;
	}

	/**
	 * Returns the X offset of the selection cursor based on the current alignment.
	 * 
	 * Used for positioning the cursor when there isn't any text at the current line.
	 */
	function getCaretOffsetX():Float
	{
		return switch (alignment)
		{
			case CENTER: (width / 2);
			case RIGHT: width - GUTTER;
			default: GUTTER;
		}
	}

	/**
	 * Gets the character index at a specific point on the text field.
	 * 
	 * If the point is over a line but not over a character inside it, it will return
	 * the last character in the line. If no line is found at the point, the length
	 * of the text is returned.
	 */
	function getCharAtPosition(x:Float, y:Float):Int
	{
		if (x < GUTTER)
			x = GUTTER;

		if (y > textField.textHeight)
			y = textField.textHeight;
		if (y < GUTTER)
			y = GUTTER;

		for (line in 0...textField.numLines)
		{
			var lineY = GUTTER + getLineY(line);
			var lineOffset = textField.getLineOffset(line);
			var lineHeight = textField.getLineMetrics(line).height;
			if (y >= lineY && y <= lineY + lineHeight)
			{
				// check for every character in the line
				var lineLength = textField.getLineLength(line);
				var lineEndIndex = lineOffset + lineLength;
				for (char in 0...lineLength)
				{
					var boundaries = getCharBoundaries(lineOffset + char);
					// reached end of line, return this character
					if (boundaries == null)
						return lineOffset + char;
					if (x <= boundaries.right)
					{
						if (x <= boundaries.x + (boundaries.width / 2))
						{
							return lineOffset + char;
						}
						else
						{
							return (lineOffset + char < lineEndIndex) ? lineOffset + char + 1 : lineEndIndex;
						}
					}
				}

				// a character wasn't found, return the last character of the line
				return lineEndIndex;
			}
		}
		
		return text.length;
	}

	/**
	 * Gets the boundaries of the character at the specified index in the text field.
	 * 
	 * This handles `textField.getCharBoundaries()` not being able to return boundaries
	 * of a character that isn't currently visible on Flash.
	 */
	function getCharBoundaries(char:Int):Rectangle
	{
		#if flash
		// On Flash, `getCharBoundaries()` always returns null if the character is before
		// the current vertical scroll. Let's just set the scroll directly at the line
		// and change it back later
		var cacheScrollV = scrollV;
		var lineIndex = getLineIndexOfChar(char);
		// Change the internal text field's property instead to not cause a loop due to `_regen`
		// always being set back to true
		textField.scrollV = lineIndex + 1;
		var prevRegen = _regen;
		#end
		
		var boundaries = textField.getCharBoundaries(char);
		if (boundaries == null)
		{
			#if flash
			textField.scrollV = cacheScrollV;
			_regen = prevRegen;
			#end
			return null;
		}
		
		#if flash
		textField.scrollV = cacheScrollV;
		_regen = prevRegen;
		// Set the Y to the correct position
		boundaries.y = GUTTER + getLineY(lineIndex);
		#end
		
		return boundaries;
	}
	
	/**
	 * Gets the index of the character horizontally closest to `charIndex` at the
	 * specified line.
	 */
	function getCharIndexOnDifferentLine(charIndex:Int, lineIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > text.length)
			return -1;
		if (lineIndex < 0 || lineIndex > textField.numLines - 1)
			return -1;
			
		var x = 0.0;
		var charBoundaries = getCharBoundaries(charIndex - 1);
		if (charBoundaries != null)
		{
			x = charBoundaries.right;
		}
		else
		{
			x = GUTTER;
		}
		
		var y = GUTTER + getLineY(lineIndex) + textField.getLineMetrics(lineIndex).height / 2;
		
		return getCharAtPosition(x, y);
	}
	
	/**
	 * Gets the line index of the specified character.
	 * 
	 * This handles `textField.getLineIndexOfChar()` not returning a valid index for the
	 * text's length on Flash.
	 */
	function getLineIndexOfChar(char:Int):Int
	{
		// On Flash, if the character is equal to the end of the text, it returns -1 as the line.
		// We have to fix it manually.
		return (char == text.length) ? textField.numLines - 1 : textField.getLineIndexOfChar(char);
	}
	
	/**
	 * Gets the Y position of the specified line in the text field.
	 * 
	 * **NOTE:** This does not include the vertical gutter on top of the text field.
	 */
	function getLineY(line:Int):Float
	{
		var scrollY = 0.0;
		for (i in 0...line)
		{
			scrollY += textField.getLineMetrics(i).height;
		}
		return scrollY;
	}

	/**
	 * Calculates the bounds of the text field on the stage, which is used for setting the
	 * text input rect for the Lime window.
	 * @param camera The camera to use to get the bounds of the text field.
	 */
	function getLimeBounds(camera:FlxCamera):lime.math.Rectangle
	{
		if (camera == null)
			camera = FlxG.camera;
			
		var rect = getScreenBounds(camera);
		
		// transform bounds inside camera & stage
		rect.x = (rect.x * camera.totalScaleX) - (0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x) + FlxG.game.x;
		rect.y = (rect.y * camera.totalScaleY) - (0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y) + FlxG.game.y;
		rect.width *= camera.totalScaleX;
		rect.height *= camera.totalScaleY;
		
		#if openfl_dpi_aware
		var scale = FlxG.stage.window.scale;
		if (scale != 1.0)
		{
			rect.x /= scale;
			rect.y /= scale;
			rect.width /= scale;
			rect.height /= scale;
		}
		#end
		
		return new lime.math.Rectangle(rect.x, rect.y, rect.width, rect.height);
	}

	/**
	 * Gets the Y offset of the current vertical scroll based on `scrollV`.
	 */
	function getScrollVOffset():Float
	{
		return getLineY(scrollV - 1);
	}

	/**
	 * Checks if the line the selection cursor is at is currently visible.
	 */
	function isCaretLineVisible():Bool
	{
		// `getLineIndexOfChar()` will return -1 if text is empty, but we still want the caret to show up
		if (text.length == 0)
			return true;

		var line = getLineIndexOfChar(_caretIndex);
		return line >= scrollV - 1 && line <= bottomScrollV - 1;
	}
	
	/**
	 * Dispatches an action to move the selection cursor.
	 * @param type     The type of action to dispatch.
	 * @param shiftKey Whether or not the shift key is currently pressed.
	 */
	function moveCursor(type:MoveCursorAction, shiftKey:Bool):Void
	{
		switch (type)
		{
			case LEFT:
				if (_caretIndex > 0)
				{
					_caretIndex--;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case RIGHT:
				if (_caretIndex < text.length)
				{
					_caretIndex++;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case UP:
				var lineIndex = getLineIndexOfChar(_caretIndex);
				if (lineIndex > 0)
				{
					_caretIndex = getCharIndexOnDifferentLine(_caretIndex, lineIndex - 1);
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case DOWN:
				var lineIndex = getLineIndexOfChar(_caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					_caretIndex = getCharIndexOnDifferentLine(_caretIndex, lineIndex + 1);
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case HOME:
				_caretIndex = 0;
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case END:
				_caretIndex = text.length;
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case LINE_BEGINNING:
				_caretIndex = textField.getLineOffset(getLineIndexOfChar(_caretIndex));
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case LINE_END:
				var lineIndex = getLineIndexOfChar(_caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					_caretIndex = textField.getLineOffset(lineIndex + 1) - 1;
				}
				else
				{
					_caretIndex = text.length;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case PREVIOUS_LINE:
				var lineIndex = getLineIndexOfChar(_caretIndex);
				if (lineIndex > 0)
				{
					var index = textField.getLineOffset(lineIndex);
					if (_caretIndex == index)
					{
						_caretIndex = textField.getLineOffset(lineIndex - 1);
					}
					else
					{
						_caretIndex = index;
					}
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case NEXT_LINE:
				var lineIndex = getLineIndexOfChar(_caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					_caretIndex = textField.getLineOffset(lineIndex + 1);
				}
				else
				{
					_caretIndex = text.length;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
		}
	}

	/**
	 * Dispatches `callback` with the appropiate text action, if there is one set.
	 */
	function onChange(action:FlxInputTextAction):Void
	{
		if (callback != null)
		{
			callback(text, action);
			if (action == INPUT_ACTION || action == BACKSPACE_ACTION || action == DELETE_ACTION)
			{
				callback(text, CHANGE_ACTION);
			}
		}
	}

	/**
	 * Regenerates the background sprites if they're enabled.
	 */
	function regenBackground():Void
	{
		if (!background)
			return;
			
		if (fieldBorderThickness > 0)
		{
			_fieldBorderSprite.makeGraphic(Std.int(fieldWidth) + (fieldBorderThickness * 2), Std.int(fieldHeight) + (fieldBorderThickness * 2),
				fieldBorderColor);
			_fieldBorderSprite.visible = true;
		}
		else
		{
			_fieldBorderSprite.visible = false;
		}
		
		if (backgroundColor.alpha > 0)
		{
			_backgroundSprite.makeGraphic(Std.int(fieldWidth), Std.int(fieldHeight), backgroundColor);
			_backgroundSprite.visible = true;
		}
		else
		{
			_backgroundSprite.visible = false;
		}
		
		updateBackgroundPosition();
		_regenBackground = false;
	}

	/**
	 * Replaces the text at the specified range with `newText`, or just inserts it if
	 * `beginIndex` and `endIndex` are the same.
	 */
	function replaceText(beginIndex:Int, endIndex:Int, newText:String):Void
	{
		if (endIndex < beginIndex || beginIndex < 0 || endIndex > text.length || newText == null)
			return;

		text = text.substring(0, beginIndex) + newText + text.substring(endIndex);
		
		_selectionIndex = _caretIndex = beginIndex + newText.length;
		setSelection(_selectionIndex, _caretIndex);
	}
	
	/**
	 * Runs the specified typing command.
	 */
	function runCommand(cmd:TypingCommand):Void
	{
		switch (cmd)
		{
			case NEW_LINE:
				if (editable && multiline)
				{
					addText("\n");
				}
				else
				{
					stopCaretTimer();
					startCaretTimer();
				}
				onChange(ENTER_ACTION);
			case DELETE_LEFT:
				if (!editable)
					return;

				if (_selectionIndex == _caretIndex && _caretIndex > 0)
				{
					_selectionIndex = _caretIndex - 1;
				}
				
				if (_selectionIndex != _caretIndex)
				{
					replaceSelectedText("");
					_selectionIndex = _caretIndex;
					onChange(BACKSPACE_ACTION);
				}
				else
				{
					stopCaretTimer();
					startCaretTimer();
				}
			case DELETE_RIGHT:
				if (!editable)
					return;

				if (_selectionIndex == _caretIndex && _caretIndex < text.length)
				{
					_selectionIndex = _caretIndex + 1;
				}
				
				if (_selectionIndex != _caretIndex)
				{
					replaceSelectedText("");
					_selectionIndex = _caretIndex;
					onChange(DELETE_ACTION);
				}
				else
				{
					stopCaretTimer();
					startCaretTimer();
				}
			case COPY:
				if (_caretIndex != _selectionIndex && !passwordMode)
				{
					Clipboard.text = text.substring(_caretIndex, _selectionIndex);
				}
			case CUT:
				if (editable && _caretIndex != _selectionIndex && !passwordMode)
				{
					Clipboard.text = text.substring(_caretIndex, _selectionIndex);
					
					replaceSelectedText("");
				}
			case PASTE:
				if (editable && Clipboard.text != null)
				{
					addText(Clipboard.text);
				}
			case SELECT_ALL:
				_selectionIndex = 0;
				_caretIndex = text.length;
				setSelection(_selectionIndex, _caretIndex);
		}
	}

	/**
	 * Starts the timer for the caret to flash.
	 * 
	 * Call this right after `stopCaretTimer()` to show the caret immediately.
	 */
	function startCaretTimer():Void
	{
		_caretTimer.cancel();
		
		_caretFlash = !_caretFlash;
		updateCaretVisibility();
		_caretTimer.start(0.6, function(tmr)
		{
			startCaretTimer();
		});
	}
	
	/**
	 * Stops the timer for the caret to flash and hides it.
	 */
	function stopCaretTimer():Void
	{
		_caretTimer.cancel();
		
		if (_caretFlash)
		{
			_caretFlash = false;
			updateCaretVisibility();
		}
	}

	/**
	 * Updates the position of the background sprites, if they're enabled.
	 */
	function updateBackgroundPosition():Void
	{
		if (!background)
			return;
			
		_fieldBorderSprite.setPosition(x - fieldBorderThickness, y - fieldBorderThickness);
		_backgroundSprite.setPosition(x, y);
	}
	
	/**
	 * Updates the position of the selection cursor.
	 */
	function updateCaretPosition():Void
	{
		if (textField == null)
			return;
			
		if (text.length == 0)
		{
			_caret.setPosition(x + getCaretOffsetX(), y + GUTTER);
		}
		else
		{
			var boundaries = getCharBoundaries(_caretIndex - 1);
			if (boundaries != null)
			{
				_caret.setPosition(x + boundaries.right - scrollH, y + boundaries.y - getScrollVOffset());
			}
			else
			{
				boundaries = getCharBoundaries(_caretIndex);
				if (boundaries != null)
				{
					_caret.setPosition(x + boundaries.x - scrollH, y + boundaries.y - getScrollVOffset());
				}
				else // end of line
				{
					_caret.setPosition(x + getCaretOffsetX(), y + GUTTER + getLineY(getLineIndexOfChar(_caretIndex)) - getScrollVOffset());
				}
			}
		}
		
		_caret.clipRect = _caret.getHitbox(_caret.clipRect).clipTo(FlxRect.weak(x, y, width, height)).offset(-_caret.x, -_caret.y);
	}
	
	/**
	 * Updates the size of the selection cursor.
	 */
	function updateCaretSize():Void
	{
		if (_caret == null)
			return;
		var lineHeight = height - (GUTTER * 2);
		if (text.length > 0)
		{
			lineHeight = textField.getLineMetrics(0).height;
		}
			
		_caret.setGraphicSize(caretWidth, lineHeight);
		_caret.updateHitbox();
	}
	
	/**
	 * Updates the visibility of the selection cursor.
	 */
	function updateCaretVisibility():Void
	{
		_caret.visible = (_caretFlash && _selectionIndex == _caretIndex && isCaretLineVisible());
	}
	
	#if flash
	/**
	 * Used in Flash to automatically update the horizontal scroll after setting the selection.
	 */
	function updateScrollH():Void
	{
		if (textField.textWidth <= width - (GUTTER * 2))
		{
			scrollH = 0;
			return;
		}
		
		var tempScrollH = scrollH;
		if (_caretIndex == 0 || textField.getLineOffset(getLineIndexOfChar(_caretIndex)) == _caretIndex)
		{
			tempScrollH = 0;
		}
		else
		{
			var caret:Rectangle = null;
			if (_caretIndex < text.length)
			{
				caret = getCharBoundaries(_caretIndex);
			}
			if (caret == null)
			{
				caret = getCharBoundaries(_caretIndex - 1);
				caret.x += caret.width;
			}
			
			while (caret.x < tempScrollH && tempScrollH > 0)
			{
				tempScrollH -= 24;
			}
			while (caret.x > tempScrollH + width - (GUTTER * 2))
			{
				tempScrollH += 24;
			}
		}
		
		if (tempScrollH < 0)
		{
			scrollH = 0;
		}
		else if (tempScrollH > maxScrollH)
		{
			scrollH = maxScrollH;
		}
		else
		{
			scrollH = tempScrollH;
		}
	}
	#end
	
	/**
	 * Updates the selection with the current `_selectionIndex` and `_caretIndex`.
	 * @param keepScroll Whether or not to keep the current horizontal and vertical scroll.
	 */
	function updateSelection(keepScroll:Bool = false):Void
	{
		var cacheScrollH = scrollH;
		var cacheScrollV = scrollV;

		textField.setSelection(_selectionIndex, _caretIndex);
		stopCaretTimer();
		startCaretTimer();
		_regen = true;

		if (keepScroll)
		{
			scrollH = cacheScrollH;
			scrollV = cacheScrollV;
		}
		else
		{
			#if flash
			// Horizontal scroll is not automatically set on Flash
			updateScrollH();
			#end
			
			if (scrollH != cacheScrollH || scrollV != cacheScrollV)
			{
				onChange(SCROLL_ACTION);
			}
		}
	}
	
	/**
	 * Updates the selection boxes according to the current selection.
	 */
	function updateSelectionBoxes():Void
	{
		if (textField == null)
			return;

		var visibleLines = bottomScrollV - scrollV + 1;
		while (_selectionBoxes.length > visibleLines)
		{
			var box = _selectionBoxes.pop();
			if (box != null)
				box.destroy();
		}
		
		if (_caretIndex == _selectionIndex)
		{
			for (box in _selectionBoxes)
			{
				if (box != null)
					box.visible = false;
			}
			
			return;
		}
		
		var beginLine = getLineIndexOfChar(selectionBeginIndex);
		var endLine = getLineIndexOfChar(selectionEndIndex);
		
		var beginV = scrollV - 1;
		var scrollVOffset = getScrollVOffset();

		for (line in beginV...bottomScrollV)
		{
			var i = line - beginV;
			var box = _selectionBoxes[i];
			if (line >= beginLine && line <= endLine)
			{
				var lineStartIndex = textField.getLineOffset(line);
				var lineEndIndex = lineStartIndex + textField.getLineLength(line);
				
				var startIndex = FlxMath.maxInt(lineStartIndex, selectionBeginIndex);
				var endIndex = FlxMath.minInt(lineEndIndex, selectionEndIndex);
				
				var startBoundaries = getCharBoundaries(startIndex);
				var endBoundaries = getCharBoundaries(endIndex - 1);
				if (endBoundaries == null && endIndex > startIndex) // end of line, try getting the previous character
				{
					endBoundaries = getCharBoundaries(endIndex - 2);
				}
				
				// If word wrapping is enabled, the start boundary might actually be at the end of
				// the previous line, which causes some visual bugs. Let's check to make sure the
				// boundaries are in the same line
				if (startBoundaries != null && endBoundaries != null && FlxMath.equal(startBoundaries.y, endBoundaries.y))
				{
					if (box == null)
					{
						box = _selectionBoxes[i] = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
						box.color = selectionColor;
					}

					var boxRect = FlxRect.get(startBoundaries.x - scrollH, startBoundaries.y - scrollVOffset,
						endBoundaries.right - startBoundaries.x,
						startBoundaries.height);
					boxRect.clipTo(FlxRect.weak(0, 0, width, height)); // clip the selection box inside the text sprite
					
					box.setPosition(x + boxRect.x, y + boxRect.y);
					if (boxRect.width > 0 && boxRect.height > 0)
						box.setGraphicSize(boxRect.width, boxRect.height);
					else
						box.scale.set();
					box.updateHitbox();
					box.visible = true;

					boxRect.put();
				}
				else if (box != null)
				{
					box.visible = false;
				}
			}
			else if (box != null)
			{
				box.visible = false;
			}
		}
	}
	
	/**
	 * Updates both the selection cursor and the selection boxes.
	 */
	function updateSelectionSprites():Void
	{
		updateCaretVisibility();
		updateCaretPosition();
		updateSelectionBoxes();
	}

	/**
	 * Updates all of the sprites' positions.
	 */
	function updateSpritePositions():Void
	{
		updateBackgroundPosition();
		updateCaretPosition();
		updateSelectionBoxes();
	}
	
	#if FLX_POINTER_INPUT
	/**
	 * Checks for mouse input on the text field.
	 * @return Whether or not mouse overlap was detected.
	 */
	function updateMouseInput(elapsed:Float):Bool
	{
		var overlap = false;
		#if FLX_MOUSE
		if (_mouseDown)
		{
			updatePointerDrag(FlxG.mouse, elapsed);

			if (FlxG.mouse.justMoved)
			{
				updatePointerMove(FlxG.mouse);
			}
			
			if (FlxG.mouse.released)
			{
				updatePointerRelease(FlxG.mouse);
				_mouseDown = false;
			}
		}
		else if (FlxG.mouse.justReleased)
		{
			_lastPressTime = 0;
		}

		if (checkPointerOverlap(FlxG.mouse))
		{
			overlap = true;
			if (FlxG.mouse.justPressed && selectable)
			{
				_mouseDown = true;
				updatePointerPress(FlxG.mouse);
			}
			if (FlxG.mouse.wheel != 0)
			{
				var cacheScrollV = scrollV;
				scrollV = FlxMath.minInt(scrollV - FlxG.mouse.wheel, maxScrollV);
				if (scrollV != cacheScrollV)
				{
					onChange(SCROLL_ACTION);
				}
			}
		}
		else if (FlxG.mouse.justPressed)
		{
			hasFocus = false;
		}
		#end
		return overlap;
	}
	
	/**
	 * Checks for touch input on the text field.
	 * @return Whether or not touch overlap was detected.
	 */
	function updateTouchInput(elapsed:Float):Bool
	{
		var overlap = false;
		#if FLX_TOUCH
		if (_currentTouch != null)
		{
			updatePointerDrag(_currentTouch, elapsed);
			
			if (_lastTouchX != _currentTouch.x || _lastTouchY != _currentTouch.y)
			{
				updatePointerMove(_currentTouch);
				_lastTouchX = _currentTouch.x;
				_lastTouchY = _currentTouch.y;
			}
			
			if (_currentTouch.released)
			{
				updatePointerRelease(_currentTouch);
				_currentTouch = null;
				_lastTouchY = _lastTouchX = null;
			}
		}
		
		var pressedElsewhere = false;
		for (touch in FlxG.touches.list)
		{
			if (checkPointerOverlap(touch))
			{
				overlap = true;
				if (touch.justPressed && selectable)
				{
					_currentTouch = touch;
					_lastTouchX = touch.x;
					_lastTouchY = touch.y;
					updatePointerPress(touch);
				}
				break;
			}
			else if (touch.justPressed)
			{
				pressedElsewhere = true;
				_lastPressTime = 0;
			}
		}
		if (pressedElsewhere && _currentTouch == null)
		{
			hasFocus = false;
		}
		#end
		return overlap;
	}
	
	/**
	 * Checks if the pointer is overlapping the text field. This will also set
	 * `_pointerCamera` accordingly if it detects overlap.
	 */
	function checkPointerOverlap(pointer:FlxPointer):Bool
	{
		var overlap = false;
		var pointerPos = FlxPoint.get();
		for (camera in getCameras())
		{
			pointer.getWorldPosition(camera, pointerPos);
			if (overlapsPoint(pointerPos, true, camera))
			{
				if (_pointerCamera == null)
					_pointerCamera = camera;
				overlap = true;
				break;
			}
		}

		pointerPos.put();
		return overlap;
	}
	
	/**
	 * Called when a pointer presses on this text field.
	 */
	function updatePointerPress(pointer:FlxPointer):Void
	{
		hasFocus = true;
		
		var relativePos = getRelativePosition(pointer);
		_caretIndex = getCharAtPosition(relativePos.x + scrollH, relativePos.y + getScrollVOffset());
		_selectionIndex = _caretIndex;
		updateSelection(true);
		
		relativePos.put();
	}

	/**
	 * Updates the text field's dragging while a pointer has pressed down on it.
	 */
	function updatePointerDrag(pointer:FlxPointer, elapsed:Float):Void
	{
		var relativePos = getRelativePosition(pointer);
		var cacheScrollH = scrollH;
		var cacheScrollV = scrollV;
		
		if (relativePos.x > width - 1)
		{
			scrollH += Std.int(Math.max(Math.min((relativePos.x - width) * .1, 10), 1));
		}
		else if (relativePos.x < 1)
		{
			scrollH -= Std.int(Math.max(Math.min(relativePos.x * -.1, 10), 1));
		}
		
		_scrollVCounter += elapsed;
		
		if (_scrollVCounter > 0.1)
		{
			if (relativePos.y > height - 2)
			{
				scrollV = Std.int(Math.min(scrollV + Math.max(Math.min((relativePos.y - height) * .03, 5), 1), maxScrollV));
			}
			else if (relativePos.y < 2)
			{
				scrollV -= Std.int(Math.max(Math.min(relativePos.y * -.03, 5), 1));
			}
			_scrollVCounter = 0;
		}

		if (scrollH != cacheScrollH || scrollV != cacheScrollV)
		{
			onChange(SCROLL_ACTION);
		}
	}
	
	/**
	 * Called when a pointer moves while its pressed down on the text field.
	 */
	function updatePointerMove(pointer:FlxPointer):Void
	{
		if (_selectionIndex < 0)
			return;
			
		var relativePos = getRelativePosition(pointer);
		
		var char = getCharAtPosition(relativePos.x + scrollH, relativePos.y + getScrollVOffset());
		if (char != _caretIndex)
		{
			_caretIndex = char;
			updateSelection(true);
		}

		relativePos.put();
	}
	
	/**
	 * Called when a pointer is released after pressing down on the text field.
	 */
	function updatePointerRelease(pointer:FlxPointer):Void
	{
		if (!hasFocus)
			return;
			
		var relativePos = getRelativePosition(pointer);
		
		var upPos = getCharAtPosition(relativePos.x + scrollH, relativePos.y + getScrollVOffset());
		var leftPos = FlxMath.minInt(_selectionIndex, upPos);
		var rightPos = FlxMath.maxInt(_selectionIndex, upPos);
		
		_selectionIndex = leftPos;
		_caretIndex = rightPos;
		updateSelection(true);

		if (hasFocus)
		{
			stopCaretTimer();
			startCaretTimer();
		}

		relativePos.put();
		_pointerCamera = null;
		var currentTime = FlxG.game.ticks;
		if (currentTime - _lastPressTime < 500)
		{
			updatePointerDoublePress(pointer);
			_lastPressTime = 0;
		}
		else
		{
			_lastPressTime = currentTime;
		}
	}
	
	/**
	 * Called when a pointer double-presses the text field.
	 */
	function updatePointerDoublePress(pointer:FlxPointer):Void
	{
		var rightPos = text.length;
		if (text.length > 0 && _caretIndex >= 0 && rightPos >= _caretIndex)
		{
			var leftPos = -1;
			var pos = 0;
			var startPos = FlxMath.maxInt(_caretIndex, 1);
			
			for (c in DELIMITERS)
			{
				pos = text.lastIndexOf(c, startPos - 1);
				if (pos > leftPos)
					leftPos = pos + 1;
					
				pos = text.indexOf(c, startPos);
				if (pos < rightPos && pos != -1)
					rightPos = pos;
			}
			
			if (leftPos != rightPos)
			{
				setSelection(leftPos, rightPos);
			}
		}
	}
	
	/**
	 * Returns the position of the pointer relative to the text field.
	 */
	function getRelativePosition(pointer:FlxPointer):FlxPoint
	{
		var pointerPos = pointer.getWorldPosition(_pointerCamera);
		getScreenPosition(_point, _pointerCamera);
		var result = FlxPoint.get((pointerPos.x - _pointerCamera.scroll.x) - _point.x, (pointerPos.y - _pointerCamera.scroll.y) - _point.y);
		pointerPos.put();
		return result;
	}
	#end
	
	override function set_bold(value:Bool):Bool
	{
		if (bold != value)
		{
			super.set_bold(value);
			updateCaretSize();
		}
		
		return value;
	}
	
	override function set_color(value:FlxColor):FlxColor
	{
		if (color != value)
		{
			super.set_color(value);
			caretColor = value;
		}
		
		return value;
	}
	override function set_fieldHeight(value:Float):Float
	{
		if (fieldHeight != value)
		{
			super.set_fieldHeight(value);
			_regenBackground = true;
		}
		
		return value;
	}
	
	override function set_fieldWidth(value:Float):Float
	{
		if (fieldWidth != value)
		{
			super.set_fieldWidth(value);
			_regenBackground = true;
		}
		
		return value;
	}
	
	override function set_font(value:String):String
	{
		if (font != value)
		{
			super.set_font(value);
			updateCaretSize();
		}
		
		return value;
	}
	
	override function set_italic(value:Bool):Bool
	{
		if (italic != value)
		{
			super.set_italic(value);
			updateCaretSize();
		}
		
		return value;
	}
	
	override function set_size(value:Int):Int
	{
		if (size != value)
		{
			super.set_size(value);
			updateCaretSize();
		}
		
		return value;
	}
	
	override function set_systemFont(value:String):String
	{
		if (systemFont != value)
		{
			super.set_systemFont(value);
			updateCaretSize();
		}
		
		return value;
	}
	
	override function set_text(value:String):String
	{
		if (text != value)
		{
			super.set_text(value);
			
			if (textField != null)
			{
				if (hasFocus)
				{
					if (text.length < _selectionIndex)
					{
						_selectionIndex = text.length;
					}
					if (text.length < _caretIndex)
					{
						_caretIndex = text.length;
					}
				}
				else
				{
					_selectionIndex = 0;
					_caretIndex = 0;
				}

				setSelection(_selectionIndex, _caretIndex);
			}
			if (autoSize || _autoHeight)
			{
				_regenBackground = true;
			}
		}
		
		return value;
	}

	override function set_x(value:Float)
	{
		if (x != value)
		{
			super.set_x(value);
			updateSpritePositions();
		}
		
		return value;
	}
	
	override function set_y(value:Float)
	{
		if (y != value)
		{
			super.set_y(value);
			updateSpritePositions();
		}
		
		return value;
	}
	
	function set_background(value:Bool):Bool
	{
		if (background != value)
		{
			background = value;
			
			if (background)
			{
				if (_backgroundSprite == null)
					_backgroundSprite = new FlxSprite();
				if (_fieldBorderSprite == null)
					_fieldBorderSprite = new FlxSprite();
					
				_regenBackground = true;
			}
			else
			{
				_backgroundSprite = FlxDestroyUtil.destroy(_backgroundSprite);
				_fieldBorderSprite = FlxDestroyUtil.destroy(_fieldBorderSprite);
			}
		}
		
		return value;
	}
	
	function set_backgroundColor(value:FlxColor):FlxColor
	{
		if (backgroundColor != value)
		{
			backgroundColor = value;
			_regenBackground = true;
		}
		
		return value;
	}

	function get_bottomScrollV():Int
	{
		return textField.bottomScrollV;
	}
	
	function set_caretColor(value:FlxColor):FlxColor
	{
		if (caretColor != value)
		{
			caretColor = value;
			_caret.color = caretColor;
		}

		return value;
	}
	
	function get_caretIndex():Int
	{
		return _caretIndex;
	}

	function set_caretIndex(value:Int):Int
	{
		if (value < 0)
			value = 0;
		if (value > text.length)
			value = text.length;
		if (_caretIndex != value)
		{
			_caretIndex = value;
			setSelection(_caretIndex, _caretIndex);
		}

		return value;
	}
	
	function set_caretWidth(value:Int):Int
	{
		if (value < 1)
			value = 1;
		if (caretWidth != value)
		{
			caretWidth = value;
			updateCaretSize();
		}

		return value;
	}
	
	function set_customFilterPattern(value:EReg):EReg
	{
		if (customFilterPattern != value)
		{
			customFilterPattern = value;
			if (filterMode != CUSTOM_FILTER)
			{
				filterMode = CUSTOM_FILTER;
			}
			else
			{
				text = filterText(text);
			}
		}
		
		return value;
	}

	function set_fieldBorderColor(value:FlxColor):FlxColor
	{
		if (fieldBorderColor != value)
		{
			fieldBorderColor = value;
			_regenBackground = true;
		}
		
		return value;
	}
	
	function set_fieldBorderThickness(value:Int):Int
	{
		if (value < 0)
			value = 0;
		if (fieldBorderThickness != value)
		{
			fieldBorderThickness = value;
			_regenBackground = true;
		}
		
		return value;
	}
	
	function set_filterMode(value:FlxInputTextFilterMode):FlxInputTextFilterMode
	{
		if (filterMode != value)
		{
			filterMode = value;
			text = filterText(text);
		}
		
		return value;
	}
	
	function set_forceCase(value:FlxInputTextCase):FlxInputTextCase
	{
		if (forceCase != value)
		{
			forceCase = value;
			text = filterText(text);
		}
		
		return value;
	}
	
	function set_hasFocus(value:Bool):Bool
	{
		if (hasFocus != value)
		{
			hasFocus = value;
			if (hasFocus)
			{
				// Ensure that the text field isn't hidden by a keyboard overlay
				var bounds = getLimeBounds(_pointerCamera);
				FlxG.stage.window.setTextInputRect(bounds);

				FlxG.inputText.focus = this;
				
				if (_caretIndex < 0)
				{
					_caretIndex = text.length;
					_selectionIndex = _caretIndex;
					updateSelection(true);
				}
				
				stopCaretTimer();
				startCaretTimer();

				if (focusGained != null)
					focusGained();
			}
			else if (FlxG.inputText.focus == this)
			{
				FlxG.inputText.focus = null;
				
				if (_selectionIndex != _caretIndex)
				{
					_selectionIndex = _caretIndex;
					updateSelection(true);
				}
				
				stopCaretTimer();
				
				if (focusLost != null)
					focusLost();
			}
		}

		return value;
	}
	
	function set_maxLength(value:Int):Int
	{
		if (value < 0)
			value = 0;
		if (maxLength != value)
		{
			maxLength = value;
			text = filterText(text);
		}
		
		return value;
	}

	function get_maxScrollH():Int
	{
		return textField.maxScrollH;
	}
	
	function get_maxScrollV():Int
	{
		return textField.maxScrollV;
	}
	
	function get_multiline():Bool
	{
		return textField.multiline;
	}
	
	function set_multiline(value:Bool):Bool
	{
		if (textField.multiline != value)
		{
			textField.multiline = value;
		}

		return value;
	}
	
	function get_passwordMode():Bool
	{
		return textField.displayAsPassword;
	}
	
	function set_passwordMode(value:Bool):Bool
	{
		if (textField.displayAsPassword != value)
		{
			textField.displayAsPassword = value;
			_regen = true;
		}
		return value;
	}

	function get_scrollH():Int
	{
		return textField.scrollH;
	}
	
	function set_scrollH(value:Int):Int
	{
		if (value > maxScrollH)
			value = maxScrollH;
		if (value < 0)
			value = 0;
		if (textField.scrollH != value)
		{
			textField.scrollH = value;
			_regen = true;
		}
		return value;
	}
	
	function get_scrollV():Int
	{
		return textField.scrollV;
	}
	
	function set_scrollV(value:Int):Int
	{
		if (value > maxScrollV)
			value = maxScrollV;
		if (value < 1)
			value = 1;
		if (textField.scrollV != value || textField.scrollV == 0)
		{
			textField.scrollV = value;
			_regen = true;
		}
		return value;
	}
	
	function set_selectedTextColor(value:FlxColor):FlxColor
	{
		if (selectedTextColor != value)
		{
			selectedTextColor = value;
			_selectionFormat.color = selectedTextColor;
			_regen = true;
		}
		
		return value;
	}
	
	function get_selectionBeginIndex():Int
	{
		return FlxMath.minInt(_caretIndex, _selectionIndex);
	}
	
	function set_selectionColor(value:FlxColor):FlxColor
	{
		if (selectionColor != value)
		{
			selectionColor = value;
			for (box in _selectionBoxes)
			{
				if (box != null)
					box.color = selectionColor;
			}
		}
		
		return value;
	}
	
	function get_selectionEndIndex():Int
	{
		return FlxMath.maxInt(_caretIndex, _selectionIndex);
	}

	function set_useSelectedTextFormat(value:Bool):Bool
	{
		if (useSelectedTextFormat != value)
		{
			useSelectedTextFormat = value;
			_regen = true;
		}
		
		return value;
	}
}

enum abstract FlxInputTextAction(String) from String to String
{
	/**
	 * Dispatched whenever the text is changed by the user. It's always
	 * dispatched after `INPUT_ACTION`, `BACKSPACE_ACTION`, and
	 * `DELETE_ACTION`.
	 */
	var CHANGE_ACTION = "change";
	/**
	 * Dispatched whenever new text is added by the user.
	 */
	var INPUT_ACTION = "input";
	/**
	 * Dispatched whenever text to the left is removed by the user (pressing
	 * backspace).
	 */
	var BACKSPACE_ACTION = "backspace";
	/**
	 * Dispatched whenever text to the right is removed by the user (pressing
	 * delete).
	 */
	var DELETE_ACTION = "delete";
	/**
	 * Dispatched whenever enter is pressed by the user while the text field
	 * is focused.
	 */
	var ENTER_ACTION = "enter";
	/**
	 * Dispatched whenever the text field is scrolled in some way.
	 */
	var SCROLL_ACTION = "scroll";
}

enum abstract FlxInputTextCase(Int) from Int to Int
{
	/**
	 * Allows both lowercase and uppercase letters.
	 */
	var ALL_CASES = 0;
	/**
	 * Changes all text to be uppercase.
	 */
	var UPPER_CASE = 1;
	/**
	 * Changes all text to be lowercase.
	 */
	var LOWER_CASE = 2;
}

enum abstract FlxInputTextFilterMode(Int) from Int to Int
{
	/**
	 * Does not filter the text at all.
	 */
	var NO_FILTER = 0;
	/**
	 * Only allows letters (a-z & A-Z) to be added to the text.
	 */
	var ONLY_ALPHA = 1;
	/**
	 * Only allows numbers (0-9) to be added to the text.
	 */
	var ONLY_NUMERIC = 2;
	/**
	 * Only allows letters (a-z & A-Z) and numbers (0-9) to be added to the text.
	 */
	var ONLY_ALPHANUMERIC = 3;
	/**
	 * Lets you use a custom filter with `customFilterPattern`.
	 */
	var CUSTOM_FILTER = 4;
}