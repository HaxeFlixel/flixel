package flixel.text;

import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import lime.system.Clipboard;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.TextEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
 * An extension of `FlxText` that allows the text to be selected and modified by the user.
 * This does not react to pointer input on its own; it should be extended with your own code, or simply use `FlxTextInput`.
 * 
 * @author Starmapo
 */
@:access(openfl.text.TextField)
class FlxBaseInputText extends FlxText
{
	/**
	 * Checks whether the control key is pressed.
	 * @param modifier The modifier to check.
	 * @return Whether or not the control key is pressed.
	 */
	static inline function isModifierPressed(modifier:KeyModifier):Bool
	{
		#if mac
		return modifier.metaKey;
		#elseif js
		return modifier.metaKey || modifier.ctrlKey;
		#else
		return modifier.ctrlKey && !modifier.altKey;
		#end
	}

	/**
	 * An integer (1-based index) that indicates the bottommost line that is currently visible in the text object.
	 * 
	 * All the text between the lines indicated by `scrollV` and `bottomScrollV` is currently visible in the text object.
	 */
	public var bottomScrollV(get, never):Int;

	/**
	 * The index of the insertion point (caret) position. If no insertion point is displayed, the value is the position the insertion point
	 * would be if you restored focus to the text (typically where the insertion point last was, or 0 if the text has not had focus).
	 */
	public var caretIndex(get, set):Int;

	/**
	 * Specifies whether the text object is a password text field, which hides the input characters using asterisks instead of the actual
	 * characters. When password mode is enabled, the Cut and Copy commands and their respective keyboard shortcuts will not function.
	 */
	public var displayAsPassword(get, set):Bool;

	/**
	 * Specifies whether the text object currently has focus and is able to receive text input.
	 */
	public var focus(get, set):Bool;

	/**
	 * The maximum number of characters that the text object can contain, as entered by a user. A script can insert more text than `maxChars`
	 * allows; the `maxChars` property indicates only how much text a user can enter.
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
	 * Indicates whether the object is a multiline text field. In a field of type `TextFieldType.INPUT`, the `multiline` value determines
	 * whether the `Enter` key creates a new line (a value of `false`, and the `Enter` key is ignored).
	 * 
	 * **Note:** If `wordWrap` is set to `true`, the text will still be split into lines if it is longer than `fieldWidth`.
	 */
	public var multiline(get, set):Bool;

	/**
	 * This signal is dispatched when the `Backspace` key is pressed while this object is receiving text input.
	 */
	public var onBackspace:FlxSignal = new FlxSignal();

	/**
	 * This signal is dispatched when the text is changed by the user.
	 */
	public var onChange:FlxSignal = new FlxSignal();

	/**
	 * This signal is dispatched when the `Delete` key is pressed while this object is receiving text input.
	 */
	public var onDelete:FlxSignal = new FlxSignal();

	/**
	 * This signal is dispatched when the `Enter` key is pressed by the user while this object is receiving text input.
	 */
	public var onEnter:FlxSignal = new FlxSignal();

	/**
	 * This signal is dispatched when this text object gains focus.
	 */
	public var onFocusGained:FlxSignal = new FlxSignal();

	/**
	 * This signal is dispatched when this text object loses focus.
	 */
	public var onFocusLost:FlxSignal = new FlxSignal();

	/**
	 * This signal is dispatched when text is added by the user to this object.
	 */
	public var onInput:FlxSignal = new FlxSignal();

	/**
	 * This signal is dispatched when the text is scrolled horizontally or vertically.
	 */
	public var onScroll:FlxSignal = new FlxSignal();

	/**
	 * Indicates the set of characters that a user can enter into the text object. If the value of the `restrict` property is an empty string
	 * you cannot enter any character. If the value of the `restrict` property is a string of characters, you can enter only characters in
	 * the string into the text object. The string is scanned from left to right. You can specify a range by using the hyphen (-) character.
	 * Only user interaction is restricted; a script can put any text into the text object.
	 * 
	 * If the string begins with a caret(^) character, all characters are initially accepted and succeeding characters in the string are
	 * excluded from the set of accepted characters.
	 * 
	 * The following example allows only uppercase characters, spaces, and numbers to be entered into a text object:
	 * `my_txt.restrict = "A-Z 0-9";`
	 * 
	 * The following example includes all characters, but excludes lowercase letters: `my_txt.restrict = "^a-z";`
	 * 
	 * You can use a backslash to enter a ^ or - verbatim. The accepted backslash sequences are \\-, \\^ or \\\. The backslash must be an
	 * actual character in the string, so when specified in Haxe, a double backslash must be used. For example, the following code includes
	 * only the dash(-) and caret(^): `my_txt.restrict = "\\-\\^";`
	 * 
	 * The ^ can be used anywhere in the string to toggle between including characters and excluding characters. The following code includes
	 * only uppercase letters, but excludes the uppercase letter Q: `my_txt.restrict = "A-Z^Q";`
	 * 
	 * You can use the `\u` escape sequence to construct `restrict` strings. The following code includes only the characters from ASCII 3
	 * (space) to ASCII 126 (tilde). `my_txt.restrict = "\u0020-\u007E";`
	 */
	public var restrict(get, set):String;

	/**
	 * The current horizontal scrolling position. If the `scrollH` property is 0, the text is not horizontally scrolled. This property value
	 * is an integer that represents the horizontal position in pixels.
	 * 
	 * The units of horizontal scrolling are pixels, whereas the units of vertical scrolling are lines. Horizontal scrolling is measured in
	 * pixels because most fonts you typically use are proportionally spaced; that is, the characters can have different widths. Vertical
	 * scrolling is performed by line because users usually want to see a complete line of text rather than a partial line. Even if a line
	 * uses multiple fonts, the height of the line adjusts to fit the largest font in use.
	 * 
	 * **Note:** The `scrollH` property is zero-based, not 1-based like the `scrollV` vertical scrolling property.
	 */
	public var scrollH(get, set):Int;

	/**
	 * The vertical position of text in a text object. The `scrollV` property is useful for directing users to a specific paragraph in a long
	 * passage, or creating scrolling text objects.
	 * 
	 * The units of vertical scrolling are lines, whereas the units of horizontal scrolling are pixels. If the first line displayed is the
	 * first line in the text object, `scrollV` is set to 1 (not 0). Horizontal scrolling is measured in pixels because most fonts you
	 * typically use are proportionally spaced; that is, the characters can have different widths. Vertical scrolling is performed by line
	 * because users usually want to see a complete line of text rather than a partial line. Even if a line uses multiple fonts, the height
	 * of the line adjusts to fit the largest font in use.
	 */
	public var scrollV(get, set):Int;

	/**
	 * A Boolean value that indicates whether the text object is selectable. The `selectable` property controls whether a text object is
	 * selectable, not whether a text object is editable. A dynamic text field can be selectable even if it is not editable.
	 * 
	 * If `selectable` is set to `false`, the text in the text object does not respond to selection commands from the mouse or keyboard, and
	 * the text cannot be copied with the Copy command.
	 */
	public var selectable(get, set):Bool;

	/**
	 * The zero-based character index value of the first character in the current selection. If no text is selected, this property is the
	 * value of `caretIndex`.
	 */
	public var selectionBeginIndex(get, set):Int;

	/**
	 * The zero-based character index value of the last character in the current selection. If no text is selected, this property is the
	 * value of `caretIndex`.
	 */
	public var selectionEndIndex(get, set):Int;

	/**
	 * The type of the text field. Either one of the following `TextFieldType` constants: `TextFieldType.DYNAMIC`, which specifies a dynamic
	 * text field, which a user cannot edit, or `TextFieldType.INPUT`, which specifies an input text field, which a user can edit.
	 */
	public var type(get, set):TextFieldType;

	/**
	 * The last camera that pointer input was detected on this text object.
	 */
	var currentCamera(get, set):FlxCamera;

	#if FLX_KEYBOARD
	/**
	 * The previous state of the key bindings that are disabled when this starts receiving text input.
	 */
	var _cachedKeys:
		{
			#if FLX_SOUND_SYSTEM
			volUp:Array<FlxKey>, volDown:Array<FlxKey>, mute:Array<FlxKey>,
			#end
			#if FLX_DEBUG
			debug:Array<FlxKey>,
			#end
			#if FLX_RECORD
			vcrCancel:Array<FlxKey>
			#end
		};
	#end

	/**
	 * Internal pointer for the last camera that pointer input was detected on this text object.
	 */
	var _currentCamera:FlxCamera;

	/**
	 * Helper variable which indicates if the text object is currently being pressed on.
	 */
	var _down:Bool = false;

	/**
	 * Helper variable for detecting double-presses.
	 */
	var _lastPressTime:Int = 0;

	/**
	 * Helper variable for knowing when the cursor's visibility has changed.
	 */
	var _lastShowCursor:Bool;

	/**
	 * Helper boolean which tells whether to update the text formats of this text object or not.
	 */
	var _regenFormats:Bool = false;

	/**
	 * Helper variable for updating dragging.
	 */
	var _scrollVCounter:Float = 0;

	/**
	 * Creates a new `FlxBaseInputText` object.
	 * @param x The x position of the text.
	 * @param y The y position of the text.
	 * @param fieldWidth The `width` of the text object. Enables `autoSize` if `<= 0`. (`height` is determined automatically).
	 * @param text The actual text you would like to display initially.
	 * @param size The font size for this text object.
	 * @param embeddedFont Whether this text field uses embedded fonts or not.
	 */
	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, embeddedFont:Bool = true)
	{
		super(x, y, fieldWidth, text, size, embeddedFont);

		final textIsEmpty = (text == null || text == "");
		if (textIsEmpty)
		{
			this.text = "";
			text = " ";
		}
		else
		{
			this.text = text;
		}

		textField = new CustomTextField(this);
		textField.selectable = true;
		textField.multiline = true;
		textField.wordWrap = true;
		textField.type = INPUT;
		font = FlxAssets.FONT_DEFAULT;
		textField.defaultTextFormat = _defaultFormat;
		textField.text = text;
		this.fieldWidth = fieldWidth;
		textField.embedFonts = embeddedFont;
		textField.sharpness = 100;
		textField.height = (text.length <= 0) ? 1 : 10;

		graphic = null;
		drawFrame();
		if (textIsEmpty)
		{
			textField.text = "";
			_regen = true;
		}

		initEvents();
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (textField != null)
		{
			textField.removeEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
			textField.removeEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);

			#if FLX_KEYBOARD
			textField.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			#end

			textField.removeEventListener(Event.SCROLL, _onScroll);

			if (textField.__inputEnabled)
			{
				onStopTextInput();
			}
		}

		onBackspace = cast FlxDestroyUtil.destroy(onBackspace);
		onChange = cast FlxDestroyUtil.destroy(onChange);
		onDelete = cast FlxDestroyUtil.destroy(onDelete);
		onEnter = cast FlxDestroyUtil.destroy(onEnter);
		onFocusGained = cast FlxDestroyUtil.destroy(onFocusGained);
		onFocusLost = cast FlxDestroyUtil.destroy(onFocusLost);
		onInput = cast FlxDestroyUtil.destroy(onInput);
		onScroll = cast FlxDestroyUtil.destroy(onScroll);

		currentCamera = null;

		#if FLX_KEYBOARD
		_cachedKeys = null;
		#end

		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (visible)
		{
			updateInput(elapsed);
		}

		if (_lastShowCursor != textField.__showCursor)
		{
			_regen = true;
			_lastShowCursor = textField.__showCursor;
		}
	}

	/**
	 * Adds another format to this `FlxBaseInputText`.
	 * @param format The format to be added.
	 * @param start The start index of the string where the format will be applied.
	 * @param end The end index of the string where the format will be applied.
	 * @return This `FlxText` object.
	 */
	override public function addFormat(format:FlxTextFormat, start:Int = -1, end:Int = -1):FlxText
	{
		// Edited to flag text formats for regeneration.
		super.addFormat(format, start, end);
		_regenFormats = true;
		return this;
	}

	/**
	 * Removes a specific `FlxTextFormat` from this text. If a range is specified, this only removes the format when it touches that range.
	 */
	override public function removeFormat(format:FlxTextFormat, ?start:Int, ?end:Int):FlxText
	{
		// Edited to flag text formats for regeneration.
		super.removeFormat(format, start, end);
		_regenFormats = true;
		return this;
	}

	#if (lime >= "8.0.0")
	/**
	 * Calculates the `textInputRect` for this object, which is used to indicate where the text input is on-screen, to avoid blocking it
	 * with device elements.
	 * @param camera Specify which camera you want. If `null`, the last camera where input was detected for this text object is used.
	 * @param rect The optional output `FlxRect` to be returned, if `null`, a new one is created.
	 * @return A `FlxRect` that fully contains the text object in global coordinates.
	 */
	public function getTextInputRect(?camera:FlxCamera, ?rect:FlxRect):FlxRect
	{
		if (camera == null)
		{
			camera = currentCamera != null ? currentCamera : this.camera;
		}
		if (rect == null)
		{
			rect = FlxRect.get();
		}

		getScreenBounds(rect, camera);

		if (camera.totalScaleX != 1 || camera.totalScaleY != 1)
		{
			rect.width *= camera.totalScaleX;
			rect.height *= camera.totalScaleY;

			rect.x -= (camera.scroll.x * camera.totalScaleX) - camera.scroll.x;
			rect.y -= (camera.scroll.y * camera.totalScaleY) - camera.scroll.y;

			rect.x -= 0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x;
			rect.y -= 0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y;
		}

		rect.x += (camera.x * FlxG.scaleMode.scale.x) + FlxG.game.x;
		rect.y += (camera.y * FlxG.scaleMode.scale.y) + FlxG.game.y;

		return rect;
	}
	#end

	/**
	 * Replaces the current selection with the contents of the `value` parameter. The text is inserted at the position of the current
	 * selection, using the current default character format and default paragraph format. You can use the `replaceSelectedText()` method to
	 * insert and delete text without disrupting the character and paragraph formatting of the rest of the text.
	 * @param value The string to replace the currently selected text.
	 */
	public function replaceSelectedText(value:String):Void
	{
		if (value == null)
		{
			value = "";
		}

		if (value == "" && textField.__selectionIndex == caretIndex)
		{
			return;
		}

		textField.replaceSelectedText(value);
		updateText();
	}

	/**
	 * Sets as selected the text designated by the index values of the first and last characters, which are specified with the `beginIndex`
	 * and `endIndex` parameters. If the two parameter values are the same, this method sets the insertion point, as if you set the
	 * `caretIndex` property.
	 * @param beginIndex The index value of the first character in the selection.
	 * @param endIndex The index value of the last character in the selection.
	 */
	public function setSelection(beginIndex:Int, endIndex:Int):Void
	{
		textField.setSelection(beginIndex, endIndex);
		_regen = true;
	}

	override function applyFormats(formatAdjusted:TextFormat, useBorderColor:Bool = false):Void
	{
		// Edited to only re-apply formats if it's needed.
		if (_regenFormats)
		{
			super.applyFormats(formatAdjusted, useBorderColor);
			_regenFormats = false;
		}
	}

	/**
	 * Checks for a double-press.
	 */
	function checkDoublePress():Void
	{
		final currentTime = FlxG.game.ticks;
		if (currentTime - _lastPressTime < 500)
		{
			onDoublePressHandler();
			_lastPressTime = 0;
		}
		else
		{
			_lastPressTime = currentTime;
		}
	}

	/**
	 * Called internally to check if text input or caret needs to be applied.
	 */
	function checkForFocus():Void
	{
		if (type == INPUT && focus)
		{
			textField.__startTextInput();
			onStartTextInput();
		}
		else if (type != INPUT && selectable && focus)
		{
			textField.__startCursorTimer();
			_regen = true;
		}
	}

	/**
	 * Initializes the event listeners.
	 */
	function initEvents():Void
	{
		textField.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
		textField.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);

		#if FLX_KEYBOARD
		textField.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		#end

		textField.addEventListener(Event.SCROLL, _onScroll);
	}

	/**
	 * This function is called after the text is modified.
	 */
	function onChangeHandler(?_):Void
	{
		updateText();

		onChange.dispatch();
	}

	/**
	 * This function handles when the text object is double-pressed.
	 */
	function onDoublePressHandler():Void
	{
		if (!selectable)
		{
			return;
		}

		textField.__updateLayout();

		var delimiters:Array<String> = ['\n', '.', '!', '?', ',', ' ', ';', ':', '(', ')', '-', '_', '/'];

		var txtStr:String = text;
		var leftPos:Int = -1;
		var rightPos:Int = txtStr.length;
		var pos:Int = 0;
		var startPos:Int = Std.int(Math.max(caretIndex, 1));
		if (txtStr.length > 0 && caretIndex >= 0 && rightPos >= caretIndex)
		{
			for (c in delimiters)
			{
				pos = txtStr.lastIndexOf(c, startPos - 1);
				if (pos > leftPos)
					leftPos = pos + 1;

				pos = txtStr.indexOf(c, startPos);
				if (pos < rightPos && pos != -1)
					rightPos = pos;
			}

			if (leftPos != rightPos)
			{
				setSelection(leftPos, rightPos);

				textField.__dirty = true;
				textField.__setRenderDirty();
			}
		}
	}

	/**
	 * This function handles when the text object receives focus.
	 */
	function onFocusInHandler():Void
	{
		checkForFocus();

		onFocusGained.dispatch();
	}

	/**
	 * This function handles when the text object loses focus.
	 */
	function onFocusOutHandler():Void
	{
		textField.__stopCursorTimer();

		textField.__stopTextInput();
		onStopTextInput();

		if (textField.__selectionIndex != caretIndex)
		{
			textField.__selectionIndex = caretIndex;
			textField.__dirty = true;
			textField.__setRenderDirty();
		}

		onFocusLost.dispatch();
	}

	/**
	 * This function handles when this text object has just been pressed.
	 * @param pointerX The relative x position of the pointer that pressed this text object.
	 * @param pointerY The relative y position of the pointer that pressed this text object.
	 */
	function onDownHandler(pointerX:Float, pointerY:Float):Void
	{
		_down = true;

		textField.__updateLayout();

		textField.__selectionIndex = caretIndex = textField.__getPosition(pointerX + scrollH, pointerY);

		textField.__dirty = true;
		textField.__setRenderDirty();

		focus = true;
	}

	/**
	 * This function handles when the pointer has moved while this text object is being pressed on.
	 * @param pointerX The relative x position of the pointer that pressed this text object.
	 * @param pointerY The relative y position of the pointer that pressed this text object.
	 */
	function onMoveHandler(pointerX:Float, pointerY:Float):Void
	{
		if (selectable && textField.__selectionIndex >= 0)
		{
			textField.__updateLayout();

			final position = textField.__getPosition(pointerX + scrollH, pointerY);

			if (position != caretIndex)
			{
				textField.__caretIndex = position;

				textField.__dirty = true;
				textField.__setRenderDirty();

				_regen = true;
			}
		}
	}

	/**
	 * This function is called after text is pasted.
	 * @param text The text that was just pasted.
	 */
	function onPasteHandler(text:String)
	{
		textField.__replaceSelectedText(text, true);

		onInput.dispatch();
		onChangeHandler();
	}

	/**
	 * This function is called after text input is started on this text object.
	 */
	function onStartTextInput():Void
	{
		if (!FlxG.stage.window.onTextInput.has(_onWindowTextInput))
		{
			FlxG.stage.window.onTextInput.add(_onWindowTextInput);
			FlxG.stage.window.onKeyDown.add(_onWindowKeyDown, false, 1);
		}

		#if FLX_KEYBOARD
		if (_cachedKeys == null)
		{
			_cachedKeys = {
				#if FLX_SOUND_SYSTEM
				volUp: FlxG.sound.volumeUpKeys, volDown: FlxG.sound.volumeDownKeys, mute: FlxG.sound.muteKeys,
				#end
				#if FLX_DEBUG
				debug: FlxG.debugger.toggleKeys,
				#end
				#if FLX_RECORD
				vcrCancel: FlxG.vcr.cancelKeys
				#end
			}
			#if FLX_SOUND_SYSTEM
			FlxG.sound.volumeUpKeys = null;
			FlxG.sound.volumeDownKeys = null;
			FlxG.sound.muteKeys = null;
			#end
			#if FLX_DEBUG
			FlxG.debugger.toggleKeys = null;
			#end
			#if FLX_RECORD
			FlxG.vcr.cancelKeys = null;
			#end
		}
		#end

		_regen = true;
	}

	/**
	 * This function is called after text input is stopped on this text object.
	 */
	function onStopTextInput():Void
	{
		FlxG.stage.window.onTextInput.remove(_onWindowTextInput);
		FlxG.stage.window.onKeyDown.remove(_onWindowKeyDown);

		#if FLX_KEYBOARD
		if (_cachedKeys != null)
		{
			#if FLX_SOUND_SYSTEM
			FlxG.sound.volumeUpKeys = _cachedKeys.volUp;
			FlxG.sound.volumeDownKeys = _cachedKeys.volDown;
			FlxG.sound.muteKeys = _cachedKeys.mute;
			#end
			#if FLX_DEBUG
			FlxG.debugger.toggleKeys = _cachedKeys.debug;
			#end
			#if FLX_RECORD
			FlxG.vcr.cancelKeys = _cachedKeys.vcrCancel;
			#end

			_cachedKeys = null;
		}
		#end

		_regen = true;
	}

	/**
	 * This function handles when the pointer that pressed this text object is released.
	 */
	function onUpHandler(pointerX:Float, pointerY:Float):Void
	{
		_down = false;

		if (focus)
		{
			textField.__getWorldTransform();
			textField.__updateLayout();

			final upPos:Int = textField.__getPosition(pointerX + scrollH, pointerY);

			final leftPos:Int = Std.int(Math.min(textField.__selectionIndex, upPos));
			final rightPos:Int = Std.int(Math.max(textField.__selectionIndex, upPos));

			textField.__selectionIndex = leftPos;
			textField.__caretIndex = rightPos;

			if (textField.__inputEnabled)
			{
				checkForFocus();

				textField.__stopCursorTimer();
				textField.__startCursorTimer();
			}

			_regen = true;
		}
	}

	/**
	 * This function handles when a key is pressed while this text object is listening for text input.
	 * @param key The code for the key that was pressed.
	 * @param modifier Information for what modifier keys were enabled.
	 */
	function onWindowKeyDownHandler(key:KeyCode, modifier:KeyModifier):Void
	{
		switch (key)
		{
			case RETURN, NUMPAD_ENTER:
				if (multiline)
				{
					textField.__replaceSelectedText("\n", true);

					onEnter.dispatch();
					onInput.dispatch();
					onChangeHandler();
				}
				else
				{
					textField.__stopCursorTimer();
					textField.__startCursorTimer();

					onEnter.dispatch();
				}

				_regen = true;
			case BACKSPACE:
				if (textField.__selectionIndex == caretIndex && caretIndex > 0)
				{
					textField.__selectionIndex = caretIndex - 1;
				}

				if (textField.__selectionIndex != caretIndex)
				{
					replaceSelectedText("");
					textField.__selectionIndex = caretIndex;

					onBackspace.dispatch();
					onChangeHandler();
				}
				else
				{
					textField.__stopCursorTimer();
					textField.__startCursorTimer();

					_regen = true;
				}
			case DELETE:
				if (textField.__selectionIndex == caretIndex && caretIndex < text.length)
				{
					textField.__selectionIndex = caretIndex + 1;
				}

				if (textField.__selectionIndex != caretIndex)
				{
					replaceSelectedText("");
					textField.__selectionIndex = caretIndex;

					onDelete.dispatch();
					onChangeHandler();
				}
				else
				{
					textField.__stopCursorTimer();
					textField.__startCursorTimer();

					_regen = true;
				}
			case LEFT if (selectable):
				if (isModifierPressed(modifier))
				{
					textField.__caretBeginningOfPreviousLine();
				}
				else
				{
					textField.__caretPreviousCharacter();
				}

				if (!modifier.shiftKey)
				{
					textField.__selectionIndex = caretIndex;
				}

				setSelection(textField.__selectionIndex, caretIndex);
			case RIGHT if (selectable):
				if (isModifierPressed(modifier))
				{
					textField.__caretBeginningOfNextLine();
				}
				else
				{
					textField.__caretNextCharacter();
				}

				if (!modifier.shiftKey)
				{
					textField.__selectionIndex = caretIndex;
				}

				setSelection(textField.__selectionIndex, caretIndex);
			case DOWN if (selectable):
				if (isModifierPressed(modifier))
				{
					textField.__caretIndex = text.length;
				}
				else
				{
					textField.__caretNextLine();
				}

				if (!modifier.shiftKey)
				{
					textField.__selectionIndex = caretIndex;
				}

				setSelection(textField.__selectionIndex, caretIndex);
			case UP if (selectable):
				if (isModifierPressed(modifier))
				{
					textField.__caretIndex = 0;
				}
				else
				{
					textField.__caretPreviousLine();
				}

				if (!modifier.shiftKey)
				{
					textField.__selectionIndex = caretIndex;
				}

				setSelection(textField.__selectionIndex, caretIndex);
			case HOME if (selectable):
				if (isModifierPressed(modifier))
				{
					textField.__caretIndex = 0;
				}
				else
				{
					textField.__caretBeginningOfLine();
				}

				if (!modifier.shiftKey)
				{
					textField.__selectionIndex = caretIndex;
				}

				setSelection(textField.__selectionIndex, caretIndex);
			case END if (selectable):
				if (isModifierPressed(modifier))
				{
					textField.__caretIndex = text.length;
				}
				else
				{
					textField.__caretEndOfLine();
				}

				if (!modifier.shiftKey)
				{
					textField.__selectionIndex = caretIndex;
				}

				setSelection(textField.__selectionIndex, caretIndex);
			case C:
				if (isModifierPressed(modifier))
				{
					if (caretIndex != textField.__selectionIndex && !displayAsPassword)
					{
						Clipboard.text = text.substring(caretIndex, textField.__selectionIndex);
					}
				}
			case X:
				if (isModifierPressed(modifier))
				{
					if (caretIndex != textField.__selectionIndex && !displayAsPassword)
					{
						Clipboard.text = text.substring(caretIndex, textField.__selectionIndex);

						replaceSelectedText("");
						onChangeHandler();
					}
				}
			#if !js
			case V:
				if (#if mac modifier.metaKey #else modifier.ctrlKey && !modifier.altKey #end)
				{
					if (Clipboard.text != null)
					{
						onPasteHandler(Clipboard.text);
					}
				}
				else
				{
					textField.__textEngine.textFormatRanges[textField.__textEngine.textFormatRanges.length - 1].end = text.length;

					_regenFormats = _regen = true;
				}
			#end
			case A if (selectable):
				if (isModifierPressed(modifier))
				{
					setSelection(0, text.length);
				}
			default:
		}
	}

	/**
	 * This function handles when text is inputted while this object is listening for text input.
	 * @param value The text that was just inputted.
	 */
	function onWindowTextInputHandler(value:String):Void
	{
		textField.__replaceSelectedText(value, true);

		onInput.dispatch();
		onChangeHandler();
	}

	/**
	 * Updates dragging through the text field.
	 * @param pointerX The relative x position of the pointer that pressed this text object.
	 * @param pointerY The relative y position of the pointer that pressed this text object.
	 */
	function updateDrag(elapsed:Float, pointerX:Float, pointerY:Float)
	{
		if (pointerX > width - 1)
		{
			scrollH += Std.int(Math.max(Math.min((pointerX - width) * .1, 10), 1));
		}
		else if (pointerX < 1)
		{
			scrollH -= Std.int(Math.max(Math.min(pointerX * -.1, 10), 1));
		}

		_scrollVCounter += elapsed;

		if (_scrollVCounter > 0.1)
		{
			if (pointerY > height - 2)
			{
				scrollV = Std.int(Math.min(scrollV + Math.max(Math.min((pointerY - height) * .03, 5), 1), maxScrollV));
			}
			else if (pointerY < 2)
			{
				scrollV -= Std.int(Math.max(Math.min(pointerY * -.03, 5), 1));
			}
			_scrollVCounter = 0;
		}

		onMoveHandler(pointerX, pointerY);
	}

	/**
	 * Updates all input for this text object.
	 */
	function updateInput(elapsed:Float):Void {}

	/**
	 * Updates the current text and marks the graphic to be regenerated.
	 */
	function updateText():Void
	{
		text = textField.text;
		_regen = true;
	}

	#if FLX_KEYBOARD
	/**
	 * This function handles when a key is pressed.
	 */
	function onKeyDownHandler(event:KeyboardEvent):Void
	{
		if (focus && selectable && type != INPUT && event.keyCode == FlxKey.C && (event.commandKey || event.ctrlKey))
		{
			if (caretIndex != textField.__selectionIndex && !displayAsPassword)
			{
				Clipboard.text = text.substring(caretIndex, textField.__selectionIndex);
			}
		}
	}

	/**
	 * Event listener for a key being pressed while this text object has focus.
	 */
	function _onKeyDown(event:KeyboardEvent):Void
	{
		onKeyDownHandler(event);
	}
	#end

	/**
	 * Event listener for the text object receiving focus.
	 */
	function _onFocusIn(event:FocusEvent):Void
	{
		onFocusInHandler();
	}

	/**
	 * Event listener for the text object losing focus.
	 */
	function _onFocusOut(event:FocusEvent):Void
	{
		onFocusOutHandler();
	}

	/**
	 * Event listener for the text object being scrolled.
	 */
	function _onScroll(_):Void
	{
		_regen = true;

		onScroll.dispatch();
	}

	/**
	 * Event listener for a key being pressed while this text object is listening for text input.
	 * @param key The code for the key that was pressed.
	 * @param modifier Information for what modifier keys were enabled.
	 */
	function _onWindowKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		onWindowKeyDownHandler(key, modifier);
		#if (html5 && FlX_KEYBOARD)
		if (key == SPACE && FlxG.keys.preventDefaultKeys.contains(SPACE))
		{
			onWindowTextInputHandler(" ");
		}
		#end
	}

	/**
	 * Event listener for text being inputted while this object is listening for text input.
	 * @param value The text that was just inputted.
	 */
	function _onWindowTextInput(value:String):Void
	{
		onWindowTextInputHandler(value);
	}

	override function set_alignment(value:FlxTextAlign):FlxTextAlign
	{
		// Edited to flag text formats for regeneration.
		_regenFormats = true;
		return super.set_alignment(value);
	}

	override function set_bold(value:Bool):Bool
	{
		// Edited to flag text formats for regeneration.
		if (bold != value)
		{
			_regenFormats = true;
		}
		return super.set_bold(value);
	}

	override function set_borderColor(value:FlxColor):FlxColor
	{
		// This feature is not supported in `FlxBaseInputText`.
		return value;
	}

	override function set_borderQuality(value:Float):Float
	{
		// This feature is not supported in `FlxBaseInputText`.
		return value;
	}

	override function set_borderSize(value:Float):Float
	{
		// This feature is not supported in `FlxBaseInputText`.
		return value;
	}

	override function set_borderStyle(value:FlxTextBorderStyle):FlxTextBorderStyle
	{
		// This feature is not supported in `FlxBaseInputText`.
		return value;
	}

	override function set_color(value:FlxColor):FlxColor
	{
		// Edited to flag text formats for regeneration.
		if (_defaultFormat.color != value.to24Bit())
		{
			_regenFormats = true;
		}
		return super.set_color(value);
	}

	override function set_font(value:String):String
	{
		// Edited to flag text formats for regeneration.
		_regenFormats = true;
		return super.set_font(value);
	}

	override function set_italic(value:Bool):Bool
	{
		// Edited to flag text formats for regeneration.
		if (italic != value)
		{
			_regenFormats = true;
		}
		return super.set_italic(value);
	}

	override function set_size(value:Int):Int
	{
		// Edited to flag text formats for regeneration.
		_regenFormats = true;
		return super.set_size(value);
	}

	override function set_systemFont(value:String):String
	{
		// Edited to flag text formats for regeneration.
		_regenFormats = true;
		return super.set_systemFont(value);
	}

	override function set_text(value:String):String
	{
		// Edited to better detect if the text has actually changed.
		if (text != value)
		{
			text = value;
			if (textField != null)
			{
				textField.text = value;
				_regen = true;
			}
		}

		return value;
	}

	function get_bottomScrollV():Int
	{
		return textField.bottomScrollV;
	}

	function get_caretIndex():Int
	{
		return textField.caretIndex;
	}

	function set_caretIndex(value:Int):Int
	{
		setSelection(value, value);
		return value;
	}

	function get_currentCamera():FlxCamera
	{
		if (_currentCamera != null && !_currentCamera.exists)
		{
			_currentCamera = null;
		}

		return _currentCamera;
	}

	function set_currentCamera(value:FlxCamera):FlxCamera
	{
		return _currentCamera = value;
	}

	function get_displayAsPassword():Bool
	{
		return textField.displayAsPassword;
	}

	function set_displayAsPassword(value:Bool):Bool
	{
		if (textField.displayAsPassword != value)
		{
			textField.displayAsPassword = value;
			_regen = true;
		}
		return value;
	}

	function get_focus():Bool
	{
		return FlxG.stage.focus == textField;
	}

	function set_focus(value:Bool):Bool
	{
		if (focus != value)
		{
			if (value)
			{
				FlxG.stage.focus = textField;
			}
			else if (focus)
			{
				FlxG.stage.focus = null;
			}
		}
		return value;
	}

	function get_maxChars():Int
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
			wordWrap = value;
		}
		return value;
	}

	function get_restrict():String
	{
		return textField.restrict;
	}

	function set_restrict(value:String):String
	{
		if (textField.restrict != value)
		{
			textField.restrict = value;
			updateText();
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
		}
		return value;
	}

	function get_scrollV():Int
	{
		return textField.scrollV;
	}

	function set_scrollV(value:Int):Int
	{
		if (textField.scrollV != value || textField.scrollV == 0)
		{
			textField.scrollV = value;
		}
		return value;
	}

	function get_selectable():Bool
	{
		return textField.selectable;
	}

	function set_selectable(value:Bool):Bool
	{
		if (textField.selectable != value)
		{
			textField.selectable = value;
			if (type == INPUT)
			{
				if (focus)
				{
					onStartTextInput();
				}
				else if (!value)
				{
					onStopTextInput();
				}
			}
		}
		return value;
	}

	function get_selectionBeginIndex():Int
	{
		return Std.int(Math.min(caretIndex, textField.__selectionIndex));
	}

	function set_selectionBeginIndex(value:Int):Int
	{
		setSelection(value, selectionEndIndex);
		return value;
	}

	function get_selectionEndIndex():Int
	{
		return Std.int(Math.max(caretIndex, textField.__selectionIndex));
	}

	function set_selectionEndIndex(value:Int):Int
	{
		setSelection(selectionBeginIndex, value);
		return value;
	}

	function get_type():TextFieldType
	{
		return textField.type;
	}

	function set_type(value:TextFieldType):TextFieldType
	{
		if (textField.type != value)
		{
			textField.type = value;
			if (value == INPUT)
			{
				checkForFocus();
			}
			else
			{
				onStopTextInput();
			}
			_regen = true;
		}
		return value;
	}
}

/**
 * A custom `TextField` object with some modifications, which is used in `FlxBaseInputText`.
 * 
 * @author Starmapo
 */
@SuppressWarnings("checkstyle:MethodName")
class CustomTextField extends TextField
{
	/**
	 * The `FlxBaseInputText` object that this text field belongs to.
	 */
	var textParent:FlxBaseInputText;

	/**
	 * Creates a new `CustomTextField` object.
	 * @param parent The `FlxBaseInputText` object that this text field belongs to.
	 */
	public function new(parent:FlxBaseInputText)
	{
		super();
		textParent = parent;
		stage = FlxG.stage;

		// Remove event listeners, as these are handled by `FlxBaseInputText`.
		__removeAllListeners();
	}

	#if (lime >= "8.0.0")
	override function getBounds(targetCoordinateSpace:DisplayObject):Rectangle
	{
		// Edited to return the bounds of the `FlxBaseInputText` object, used for setting the window's `textInputRect`.
		final rect = textParent.getTextInputRect();
		final bounds = new Rectangle(rect.x, rect.y, rect.width, rect.height);
		rect.put();
		return bounds;
	}
	#end
	
	@:noCompletion override function __enableInput():Void
	{
		super.__enableInput();

		// Edited to remove event listeners, as these are handled by `FlxBaseInputText`.
		stage.window.onTextInput.remove(window_onTextInput);
		stage.window.onKeyDown.remove(window_onKeyDown);
	}

	@:noCompletion override function __getInteractive(stack:Array<DisplayObject>):Bool
	{
		// Edited to add `FlxG.game` to the stack order, allowing events to be dispatched there.
		if (stack != null)
		{
			stack.push(this);

			if (FlxG.game != null)
			{
				FlxG.game.__getInteractive(stack);
			}
		}

		return true;
	}
}
