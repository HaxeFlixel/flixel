package flixel.text;

import flixel.input.FlxPointer;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxInputTextManager;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.system.Clipboard;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.text.TextFormat;
import openfl.utils.QName;

using StringTools;

/**
 * An `FlxText` object that can be selected and edited by the user.
 */
class FlxInputText extends FlxText implements IFlxInputText
{
	/**
	 * The global manager that handles input text objects.
	 */
	public static var globalManager:FlxInputTextManager;

	/**
	 * The gaps at the sides of the text field (2px).
	 */
	static inline var GUTTER:Int = 2;
	
	/**
	 * Characters that break up the words to select.
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
	 * Defines how to filter the text (remove unwanted characters).
	 */
	public var filterMode(default, set):FlxInputTextFilterMode = NONE;

	/**
	 * Defines whether a letter case is enforced on the text.
	 */
	public var forceCase(default, set):FlxInputTextCase = ALL_CASES;
	
	/**
	 * Whether or not the text field is the current active one on the screen.
	 */
	public var hasFocus(default, null):Bool = false;
	
	/**
	 * Set the maximum length for the text field. 0 means unlimited.
	 */
	public var maxChars(get, set):Int;

	/**
	 * The maximum value of `scrollH`.
	 */
	public var maxScrollH(get, never):Int;
	
	/**
	 * The maximum value of `scrollV`.
	 */
	public var maxScrollV(get, never):Int;

	/**
	 * Whether or not the text field will automatically be scrolled
	 * when the user rolls the mouse wheel on the text field.
	 */
	public var mouseWheelEnabled:Bool = true;
	
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
	 * Gets dispatched whenever the enter key is pressed on the text field
	 * 
	 * @param   text  The current text
	 */
	public final onEnter = new FlxTypedSignal<(text:String)->Void>();

	/**
	 * Gets dispatched whenever this text field gains/loses focus
	 * 
	 * @param   focused  Whether the text is focused
	 */
	public final onFocusChange = new FlxTypedSignal<(focused:Bool)->Void>();
	
	/**
	 * Gets dispatched whenever the horizontal and/or vertical scroll is changed
	 * 
	 * @param   scrollH  The current horizontal scroll
	 * @param   scrollV  The current vertical scroll
	 */
	public final onScrollChange = new FlxTypedSignal<(scrollH:Int, scrollV:Int)->Void>();
	
	/**
	 * Gets dispatched whenever the text is changed by the user
	 * 
	 * @param   text  The current text
	 * @param   text  What type of change occurred
	 */
	public final onTextChange = new FlxTypedSignal<(text:String, change:FlxInputTextChange)->Void>();

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
	 * Whether or not the text can be selected by the user.
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
	 * The input text manager powering this instance
	 */
	public var manager(default, null):FlxInputTextManager;
	
	/**
	 * An FlxSprite representing the background of the text field.
	 */
	var _backgroundSprite:FlxSprite;
	/**
	 * An FlxSprite representing the selection cursor.
	 */
	var _caret:FlxSprite;
	/**
	 * Internal variable for the current index of the selection cursor.
	 */
	var _caretIndex:Int = -1;
	/**
	 * The timer used to flash the caret while the text field has focus.
	 */
	var _caretTimer:Float = 0;
	/**
	 * An FlxSprite representing the border of the text field.
	 */
	var _fieldBorderSprite:FlxSprite;
	/**
	 * Helper variable to prevent the text field from being unfocused from
	 * clicking outside of the fieldif the focus has just been granted
	 * through code (e.g. a separate focusing system).
	 */
	var _justGainedFocus:Bool = false;
	
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
	 * Indicates whether or not the selection cursor's size needs to be regenerated due
	 * to a change.
	 */
	var _regenCaretSize:Bool = false;
	
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
	 * @param manager         Optional input text manager that will power this input text.
	 *                        If `null`, `globalManager` is used
	 */
	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, textColor:FlxColor = FlxColor.BLACK,
			backgroundColor:FlxColor = FlxColor.WHITE, embeddedFont:Bool = true, ?manager:FlxInputTextManager)
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
		
		_caret = new FlxSprite().makeGraphic(1, 1);
		_caret.visible = false;
		updateCaretSize();
		updateCaretPosition();
		
		color = textColor;
		
		if (backgroundColor != FlxColor.TRANSPARENT)
		{
			background = true;
		}
		
		if (manager == null)
		{
			manager = FlxInputText.globalManager;
		}
		
		this.manager = manager;
		manager.registerInputText(this);
	}
	
	public function setManager(manager:FlxInputTextManager)
	{
		if (this.manager == null)
		{
			FlxG.log.error("Cannot set manager once destroyed");
			return;
		}
		
		if (manager == this.manager)
			return;
		
		final hasFocus = this.manager.focus == this;
		this.manager.unregisterInputText(this);
		
		manager.registerInputText(this);
		if (hasFocus)
		{
			manager.setFocus(this);
		}
		
		this.manager = manager;
	}
	
	public function startFocus()
	{
		if (!hasFocus)
		{
			// set first to avoid infinite loop
			hasFocus = true;
			
			// Ensure that the text field isn't hidden by a keyboard overlay
			final bounds = getLimeBounds(_pointerCamera);
			FlxG.stage.window.setTextInputRect(bounds);
			
			manager.setFocus(this);
			
			if (_caretIndex < 0)
			{
				_caretIndex = text.length;
				_selectionIndex = _caretIndex;
				updateSelection(true);
			}
			
			restartCaretTimer();
			
			_justGainedFocus = true;
			onFocusChange.dispatch(hasFocus);
		}
	}
	
	public function endFocus()
	{
		if (hasFocus)
		{
			// set first to avoid infinite loop
			hasFocus = false;
			
			// make sure we have not already switched to a new focus (probably not needed, but may in the future)
			if (manager.focus == this)
			{
				manager.setFocus(null);
			}
			
			if (_selectionIndex != _caretIndex)
			{
				_selectionIndex = _caretIndex;
				updateSelection(true);
			}
			
			onFocusChange.dispatch(hasFocus);
		}
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		_caretTimer += elapsed;
		final showCaret = (_caretTimer % 1.2) < 0.6;
		_caret.visible = showCaret && hasFocus && editable && _selectionIndex == _caretIndex && isCaretLineVisible();
		
		#if FLX_POINTER_INPUT
		if (visible)
		{
			if (!updateMouseInput(elapsed))
				updateTouchInput(elapsed);
		}
		#end
		if (_justGainedFocus)
		{
			_justGainedFocus = false;
		}
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
		endFocus();
		manager.unregisterInputText(this);

		FlxDestroyUtil.destroy(onEnter);
		FlxDestroyUtil.destroy(onFocusChange);
		FlxDestroyUtil.destroy(onScrollChange);
		FlxDestroyUtil.destroy(onTextChange);
		
		_backgroundSprite = FlxDestroyUtil.destroy(_backgroundSprite);
		_caret = FlxDestroyUtil.destroy(_caret);
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
		// Scroll variables will be reset when `textField.setTextFormat()` is called,
		// cache the current ones first.
		var cacheScrollH = scrollH;
		var cacheScrollV = scrollV;
		
		super.applyFormats(formatAdjusted, useBorderColor);
		
		if (!useBorderColor && useSelectedTextFormat && selectionEndIndex > selectionBeginIndex)
			textField.setTextFormat(_selectionFormat, selectionBeginIndex, selectionEndIndex);

		// Set the scroll back to how it was.
		// This changes the internal text field's scroll instead to make sure that
		// `__updateLayout()` gets called even if the scroll hasn't changed.
		// If it doesn't get called here, it will be called when the text field
		// is being drawn to this sprite's graphic, which will reset the scroll
		// to the current selection, effectively making scrolling with the mouse
		// wheel not work.
		textField.scrollH = cacheScrollH;
		textField.scrollV = cacheScrollV;
	}
	
	override function regenGraphic():Void
	{
		var regenSelection = _regen;
		
		super.regenGraphic();
		
		if (_regenCaretSize)
			updateCaretSize();
		if (regenSelection)
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
		
		if (beginIndex == endIndex && maxChars > 0 && text.length == maxChars)
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
			onTextChange.dispatch(text, INPUT_ACTION);
		}
	}

	/**
	 * Clips the sprite inside the bounds of the text field, taking
	 * `clipRect` into account.
	 */
	function clipSprite(sprite:FlxSprite, border:Bool = false)
	{
		if (sprite == null)
			return;
			
		var rect = sprite.clipRect;
		if (rect == null)
			rect = FlxRect.get();
		rect.set(0, 0, sprite.width, sprite.height);
		
		var bounds = border ? FlxRect.get(-fieldBorderThickness, -fieldBorderThickness, width + (fieldBorderThickness * 2),
			height + (fieldBorderThickness * 2)) : FlxRect.get(0, 0, width, height);
		if (clipRect != null)
		{
			bounds = bounds.clipTo(clipRect);
		}
		bounds.offset(x - sprite.x, y - sprite.y);
		
		sprite.clipRect = rect.clipTo(bounds);
		
		bounds.put();
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
	 * Returns the specified text filtered using `forceCase` and `filterMode`.
	 * @param newText   The string to filter.
	 * @param selection Whether or not this string is meant to be added at the selection or if we're
	 *                  replacing the entire text.
	 */
	function filterText(newText:String, selection:Bool = false):String
	{
		if (forceCase == UPPER_CASE)
		{
			newText = newText.toUpperCase();
		}
		else if (forceCase == LOWER_CASE)
		{
			newText = newText.toLowerCase();
		}
		
		if (filterMode != NONE)
		{
			var pattern = switch (filterMode)
			{
				case ALPHABET:
					~/[^a-zA-Z]*/g;
				case NUMERIC:
					~/[^0-9]*/g;
				case ALPHANUMERIC:
					~/[^a-zA-Z0-9]*/g;
				case REG(reg):
					reg;
				case CHARS(chars):
					// In a character set, only \, - and ] need to be escaped
					chars = chars.replace('\\', "\\\\").replace('-', "\\-").replace(']', "\\]");
					new EReg("[^" + chars + "]*", "g");
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
				restartCaretTimer();
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
				restartCaretTimer();
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
				restartCaretTimer();
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
				restartCaretTimer();
			case TOP:
				_caretIndex = 0;
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
				restartCaretTimer();
			case BOTTOM:
				_caretIndex = text.length;
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
				restartCaretTimer();
			case LINE_LEFT:
				_caretIndex = textField.getLineOffset(getLineIndexOfChar(_caretIndex));
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
				restartCaretTimer();
			case LINE_RIGHT:
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
				restartCaretTimer();
			case WORD_LEFT:
				if (_caretIndex > 0)
				{
					_caretIndex--;
					while (_caretIndex > 0 && DELIMITERS.contains(text.charAt(_caretIndex)))
					{
						_caretIndex--;
					}
					while (_caretIndex > 0 && !DELIMITERS.contains(text.charAt(_caretIndex - 1)))
					{
						_caretIndex--;
					}
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
				restartCaretTimer();
			case WORD_RIGHT:
				while (_caretIndex < text.length && !DELIMITERS.contains(text.charAt(_caretIndex)))
				{
					_caretIndex++;
				}
				while (_caretIndex < text.length && DELIMITERS.contains(text.charAt(_caretIndex)))
				{
					_caretIndex++;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
				restartCaretTimer();
		}
	}

	/**
	 * Regenerates the background sprites if they're enabled.
	 */
	function regenBackground():Void
	{
		if (!background)
			return;

		_regenBackground = false;
			
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
		restartCaretTimer();
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
					restartCaretTimer();
				}
				onEnter.dispatch(text);
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
					onTextChange.dispatch(text, BACKSPACE_ACTION);
				}
				else
				{
					restartCaretTimer();
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
					onTextChange.dispatch(text, DELETE_ACTION);
				}
				else
				{
					restartCaretTimer();
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
	function restartCaretTimer():Void
	{
		_caretTimer = 0;
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
		clipSprite(_fieldBorderSprite, true);
		clipSprite(_backgroundSprite);
	}
	
	/**
	 * Updates the position of the selection cursor.
	 */
	function updateCaretPosition():Void
	{
		if (textField == null || _caret == null)
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
		
		clipSprite(_caret);
	}
	
	/**
	 * Updates the size of the selection cursor.
	 */
	function updateCaretSize():Void
	{
		if (_caret == null)
			return;
		_regenCaretSize = false;

		var lineHeight = height - (GUTTER * 2);
		if (text.length > 0)
		{
			lineHeight = textField.getLineMetrics(0).height;
		}
			
		_caret.makeGraphic(caretWidth, Std.int(lineHeight));
		clipSprite(_caret);
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
				onScrollChange.dispatch(scrollH, scrollV);
			}
		}
	}
	
	/**
	 * Updates the selection boxes according to the current selection.
	 */
	function updateSelectionBoxes():Void
	{
		if (textField == null || _selectionBoxes == null)
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
						box = _selectionBoxes[i] = new FlxSprite();
						box.color = selectionColor;
					}

					var boxRect = FlxRect.get(startBoundaries.x - scrollH, startBoundaries.y - scrollVOffset,
						endBoundaries.right - startBoundaries.x,
						startBoundaries.height);
					boxRect.clipTo(FlxRect.weak(0, 0, width, height)); // clip the selection box inside the text sprite
					
					box.setPosition(x + boxRect.x, y + boxRect.y);
					box.makeGraphic(Std.int(boxRect.width), Std.int(boxRect.height));
					clipSprite(box);
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
			if (FlxG.mouse.wheel != 0 && mouseWheelEnabled)
			{
				var cacheScrollV = scrollV;
				scrollV = FlxMath.minInt(scrollV - FlxG.mouse.wheel, maxScrollV);
				if (scrollV != cacheScrollV)
				{
					onScrollChange.dispatch(scrollH, scrollV);
				}
			}
		}
		else if (FlxG.mouse.justPressed && !_justGainedFocus)
		{
			endFocus();
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
		if (pressedElsewhere && _currentTouch == null && !_justGainedFocus)
		{
			endFocus();
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
		startFocus();
		
		var relativePos = getRelativePosition(pointer);
		_caretIndex = getCharAtPosition(relativePos.x + scrollH, relativePos.y + getScrollVOffset());
		_selectionIndex = _caretIndex;
		updateSelection(true);
		restartCaretTimer();
		
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
			onScrollChange.dispatch(scrollH, scrollV);
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
			restartCaretTimer();
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
		

		if (hasFocus)
		{
			restartCaretTimer();
		}

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
			var startPos = FlxMath.maxInt(_caretIndex, 1);
			
			for (c in DELIMITERS)
			{
				var pos = text.lastIndexOf(c, startPos - 1);
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
		var pointerPos = pointer.getWorldPosition(_pointerCamera, FlxPoint.get());
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
			_regenCaretSize = _regenBackground = true;
		}
		
		return value;
	}
	override function set_clipRect(value:FlxRect):FlxRect
	{
		super.set_clipRect(value);
		
		clipSprite(_backgroundSprite);
		clipSprite(_fieldBorderSprite, true);
		clipSprite(_caret);
		for (box in _selectionBoxes)
			clipSprite(box);
			
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
			_regenCaretSize = _regenBackground = true;
		}
		
		return value;
	}
	
	override function set_italic(value:Bool):Bool
	{
		if (italic != value)
		{
			super.set_italic(value);
			_regenCaretSize = _regenBackground = true;
		}
		
		return value;
	}
	
	override function set_size(value:Int):Int
	{
		if (size != value)
		{
			super.set_size(value);
			_regenCaretSize = _regenBackground = true;
		}
		
		return value;
	}
	
	override function set_systemFont(value:String):String
	{
		if (systemFont != value)
		{
			super.set_systemFont(value);
			_regenCaretSize = _regenBackground = true;
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
				if (hasFocus)
				{
					restartCaretTimer();
				}
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

	inline function get_bottomScrollV():Int
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
	
	inline function get_caretIndex():Int
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
			restartCaretTimer();
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
			_regenCaretSize = true;
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
	
	inline function get_maxChars():Int
	{
		return textField.maxChars;
	}
	
	function set_maxChars(value:Int):Int
	{
		if (textField.maxChars != value)
		{
			textField.maxChars = value;
			_regen = true;
		}
		
		return value;
	}
	
	inline function get_maxScrollH():Int
	{
		return textField.maxScrollH;
	}
	
	inline function get_maxScrollV():Int
	{
		return textField.maxScrollV;
	}
	
	inline function get_multiline():Bool
	{
		return textField.multiline;
	}
	
	inline function set_multiline(value:Bool):Bool
	{
		if (textField.multiline != value)
		{
			textField.multiline = value;
		}

		return value;
	}
	
	inline function get_passwordMode():Bool
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
	
	inline function get_scrollH():Int
	{
		return textField.scrollH;
	}
	
	function set_scrollH(value:Int):Int
	{
		if (textField.scrollH != value)
		{
			textField.scrollH = value;
			_regen = true;
		}
		return value;
	}
	
	inline function get_scrollV():Int
	{
		return textField.scrollV;
	}
	
	function set_scrollV(value:Int):Int
	{
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

enum abstract FlxInputTextChange(String) from String to String
{
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

enum FlxInputTextFilterMode
{
	/**
	 * Does not filter the text at all.
	 */
	NONE;
	/**
	 * Only allows letters (a-z & A-Z) to be added to the text.
	 */
	ALPHABET;
	/**
	 * Only allows numbers (0-9) to be added to the text.
	 */
	NUMERIC;
	/**
	 * Only allows letters (a-z & A-Z) and numbers (0-9) to be added to the text.
	 */
	ALPHANUMERIC;
	/**
	 * Uses a regular expression to filter the text. Characters that are matched
	 * will be removed.
	 */
	REG(reg:EReg);
	
	/**
	 * Only allows the characters present in the string to be added to the text.
	 */
	CHARS(chars:String);
}