package flixel.text;

import flash.errors.Error;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

/**
	Extends FlxText to support basic text input.
**/
class FlxInputText extends FlxText
{
	public static inline var NO_FILTER:Int = 0;
	public static inline var ONLY_ALPHA:Int = 1;
	public static inline var ONLY_NUMERIC:Int = 2;
	public static inline var ONLY_ALPHANUMERIC:Int = 3;
	public static inline var CUSTOM_FILTER:Int = 4;

	public static inline var ALL_CASES:Int = 0;
	public static inline var UPPER_CASE:Int = 1;
	public static inline var LOWER_CASE:Int = 2;

	public static inline var BACKSPACE_ACTION:String = "backspace"; // press backspace

	public static inline var DELETE_ACTION:String = "delete"; // press delete

	public static inline var ENTER_ACTION:String = "enter"; // press enter

	public static inline var INPUT_ACTION:String = "input"; // manually edit

	public static inline var HOME_ACTION:String = "home"; // press home

	public static inline var END_ACTION:String = "end"; // press end

	/**
	 * This regular expression will filter out (remove) everything that matches.
	 * Automatically sets filterMode = FlxInputText.CUSTOM_FILTER.
	 */
	public var customFilterPattern(default, set):EReg;

	function set_customFilterPattern(cfp:EReg)
	{
		customFilterPattern = cfp;
		filterMode = CUSTOM_FILTER;
		return customFilterPattern;
	}

	/**
	 * A function called whenever the value changes from user input, or enter is pressed
	 */
	public var callback:(String, String) -> Void;

	/**
	 * Whether or not the textbox has a background
	 */
	public var background:Bool = false;

	/**
	 * The caret's color. Has the same color as the text by default.
	 */
	public var caretColor(default, set):Int;

	function set_caretColor(i:Int):Int
	{
		caretColor = i;
		dirty = true;
		return caretColor;
	}

	public var caretWidth(default, set):Int = 1;

	function set_caretWidth(i:Int):Int
	{
		caretWidth = i;
		dirty = true;
		return caretWidth;
	}

	/**
	 * Whether or not the textfield is a password textfield
	 */
	public var passwordMode(get, set):Bool;

	/**
	 * Whether or not the text box is the active object on the screen.
	 */
	public var hasFocus(default, set):Bool = false;

	/**
	 * The position of the selection cursor. An index of 0 means the carat is before the character at index 0.
	 */
	public var caretIndex(default, set):Int = 0;

	/**
	 * callback that is triggered when this text field gets focus
	 */
	public var focusGained:Void -> Void = () -> return;

	/**
	 * callback that is triggered when this text field loses focus
	 */
	public var focusLost:Void -> Void = () -> return;

	/**
	 * The Case that's being enforced. Either ALL_CASES, UPPER_CASE or LOWER_CASE.
	 */
	public var forceCase(default, set):Int = ALL_CASES;

	/**
	 * Set the maximum length for the field (e.g. "3"
	 * for Arcade type hi-score initials). 0 means unlimited.
	 */
	public var maxLength(default, set):Int = 0;

	/**
	 * Change the amount of lines that are allowed.
	 */
	public var lines(default, set):Int;

	/**
	 * Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
	 * (Remember to append "FlxInputText." as a prefix to those constants)
	 */
	public var filterMode(default, set):Int = NO_FILTER;

	/**
	 * The color of the fieldBorders
	 */
	public var fieldBorderColor(default, set):Int = FlxColor.BLACK;

	/**
	 * The thickness of the fieldBorders
	 */
	public var fieldBorderThickness(default, set):Int = 1;

	/**
	 * The color of the background of the textbox.
	 */
	public var backgroundColor(default, set):Int = FlxColor.WHITE;

	/**
	 * A FlxSprite representing the background sprite
	 */
	var backgroundSprite:FlxSprite;

	/**
	 * A timer for the flashing caret effect.
	 */
	var _caretTimer:FlxTimer;

	/**
	 * A FlxSprite representing the flashing caret when editing text.
	 */
	var caret:FlxSprite;

	/**
	 * A FlxSprite representing the fieldBorders.
	 */
	var fieldBorderSprite:FlxSprite;

	/**
	 * The left- and right- most fully visible character indeces
	 */
	var _scrollBoundIndeces:{left:Int, right:Int} = {left: 0, right: 0};

	/**
	 * Stores last input text scroll.
	 */
	var lastScroll:Int;

	/**
	 * Creates a new text input field.
	 * 
	 * @param  X        The X position of the text.
	 * @param  Y        The Y position of the text.
	 * @param  Width      The width of the text object (height is determined automatically).
	 * @param  Text      The actual text you would like to display initially.
	 * @param   size      Initial size of the font
	 * @param  TextColor    The color of the text
	 * @param  BackgroundColor  The color of the background (FlxColor.TRANSPARENT for no background color)
	 * @param  EmbeddedFont  Whether this text field uses embedded fonts or not
	 */
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 150, ?Text:String, size:Int = 8, TextColor:Int = FlxColor.BLACK, BackgroundColor:Int = FlxColor.WHITE, EmbeddedFont:Bool = true)
	{
		super(X, Y, Width, Text, size, EmbeddedFont);
		backgroundColor = BackgroundColor;

		if (BackgroundColor != FlxColor.TRANSPARENT) background = true;

		caretColor = color = TextColor;

		caret = new FlxSprite();
		caret.makeGraphic(caretWidth, Std.int(size + 2));
		_caretTimer = new FlxTimer();

		caretIndex = 0;
		hasFocus = false;
		fieldBorderSprite = new FlxSprite(X, Y);
		backgroundSprite = new FlxSprite(X, Y);
		if (!background) fieldBorderSprite.visible = backgroundSprite.visible = false;

		lines = 1;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		if (Text == null) Text = "";
		text = Text;

		calcFrame();
	}

	/**
	 * Clean up memory
	 */
	override public function destroy():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		backgroundSprite = FlxDestroyUtil.destroy(backgroundSprite);
		fieldBorderSprite = FlxDestroyUtil.destroy(fieldBorderSprite);
		callback = null;

		super.destroy();
	}

	/**
	 * Draw the caret in addition to the text.
	 */
	override public function draw():Void
	{
		drawSprite(fieldBorderSprite);
		drawSprite(backgroundSprite);

		super.draw();

		// In case caretColor was changed

		if (caretColor != caret.color || caret.height != size + 2)
		{
			caret.color = caretColor;
		}

		drawSprite(caret);
	}

	/**
	 * Helper function that makes sure sprites are drawn up even though they haven't been added.
	 * @param  Sprite    The Sprite to be drawn.
	 */
	function drawSprite(Sprite:FlxSprite):Void
	{
		if (Sprite != null && Sprite.visible)
		{
			Sprite.scrollFactor = scrollFactor;
			Sprite.cameras = cameras;
			Sprite.draw();
		}
	}

	/**
	 * Check for mouse input every tick.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if FLX_MOUSE
		// Set focus and caretIndex as a response to mouse press

		if (FlxG.mouse.justPressed)
		{
			var hadFocus:Bool = hasFocus;
			if (FlxG.mouse.overlaps(this))
			{
				caretIndex = getCaretIndex();
				hasFocus = true;
				if (!hadFocus && focusGained != null)
					focusGained();
			}
			else
			{
				hasFocus = false;
				if (hadFocus && focusLost != null)
					focusLost();
			}
		}
		#end
	}

	/**
	 * Handles keypresses generated on the stage.
	 */
	function onKeyDown(e:KeyboardEvent):Void
	{
		var key:Int = e.keyCode;

		if (hasFocus)
		{
			// Do nothing for Shift, Ctrl, Esc, and flixel console hotkey

			if (key == 16 || key == 17 || key == 220 || key == 27)
			{
				return;
			}
			// Left arrow
			else if (key == 37)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text; // forces scroll update
				}
			}
			// Right arrow
			else if (key == 39)
			{
				if (caretIndex < text.length)
				{
					caretIndex++;
					text = text; // forces scroll update
				}
			}
			// End key
			else if (key == 35)
			{
				caretIndex = text.length;
				text = text; // forces scroll update
			}
			// Home key
			else if (key == 36)
			{
				caretIndex = 0;
				text = text;
			}
			// Backspace
			else if (key == 8)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(BACKSPACE_ACTION);
				}
			}
			// Delete
			else if (key == 46)
			{
				if (text.length > 0 && caretIndex < text.length)
				{
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(DELETE_ACTION);
				}
			}
			// Enter
			else if (key == 13)
			{
				onChange(ENTER_ACTION);
			}
			// Actually add some text
			else
			{
				if (e.charCode == 0) // non-printable characters crash String.fromCharCode

				{
					return;
				}
				var newText:String = filter(String.fromCharCode(e.charCode));

				if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength))
				{
					text = insertSubstring(text, newText, caretIndex);
					caretIndex++;
					onChange(INPUT_ACTION);
				}
			}
		}
	}

	function onChange(action:String):Void
	{
		if (callback != null)
		{
			callback(text, action);
		}
	}

	/**
	 * Inserts a substring into a string at a specific index
	 *
	 * @param  Original    The string to have something inserted into
	 * @param  Insert      The string to insert
	 * @param  Index      The index to insert at
	 * @return          Returns the joined string for chaining.
	 */
	function insertSubstring(Original:String, Insert:String, Index:Int):String
	{
		if (Index != Original.length)
		{
			Original = Original.substring(0, Index) + (Insert) + (Original.substring(Index));
		}
		else
		{
			Original = Original + (Insert);
		}
		return Original;
	}

	/**
	 * Gets the index of the character in this box under the mouse cursor
	 * @return The index of the character.
	 *         between 0 and the length of the text
	 */
	function getCaretIndex():Int
	{
		#if FLX_MOUSE
		var hit = FlxPoint.get(FlxG.mouse.x - x, FlxG.mouse.y - y);
		return getCharIndexAtPoint(hit.x, hit.y);
		#else
		return 0;
		#end
	}

	/**
	 * Gets the bounding box of the character at the specified index.
	 * 
	 * This includes its `x` & `y` position, its `width`, and its `height`.
	 * 
	 * If the boundary is not found, or the charIndex is out of bounds, a default rectangle will be returned.
	 * The default rectangle will have its `x` and `y` values set to `2` and its `width` and `height` values set to 0.
	 * @param charIndex The character index to get the bounding box of.
	 * @return an **openfl** rectangle instance, containing the bounding box of the character.
	 */
	public function getCharBoundaries(charIndex:Int):Rectangle
	{
		if (charIndex < 0 || charIndex >= text.length)
			return new Rectangle(2,2);

		var charBoundaries:Rectangle = new Rectangle(),
			actualIndex = charIndex;

		if (textField.getCharBoundaries(charIndex) != null)
		{
			charBoundaries = textField.getCharBoundaries(charIndex);
		}
		else if (text.charAt(charIndex) == "\n")
		{
			var diff = 1; // this is going to be used when a user presses enter twice to display the caret at the correct height

			while (text.charAt(charIndex - 1) == "\n")
			{
				charIndex--;
				diff++;
			}
			// if this is a spacebar, we cant use textField.getCharBoundaries() since itll return null

			charBoundaries = getCharBoundaries(charIndex - 1);
			charBoundaries.height = textField.getLineMetrics(textField.getLineIndexOfChar(charIndex - 1)).height;
			charBoundaries.y += diff * charBoundaries.height;
			if (alignment == RIGHT)
				charBoundaries.x = x + width - 2
			else
				charBoundaries.x = 2;
			charBoundaries.width = 0;
		}
		else if (text.charAt(charIndex) == " ")
		{
			// we know that it doesnt matter how many spacebars are pressed,

			// the first one after a char/at the start of the text

			// is always defined and has the correct boundaries

			var widthDiff = 0, originalIndex = charIndex;
			while (text.charAt(charIndex - 1) == " " && charIndex != 0)
			{
				charIndex--;
				widthDiff++;
			}
			charBoundaries = textField.getCharBoundaries(charIndex);
			// removing this makes pressing between word-wrapped lines crash

			if (charBoundaries == null)
				charBoundaries = textField.getCharBoundaries(charIndex - 1);
			charBoundaries.x += widthDiff * charBoundaries.width
				- (width - 4) * (textField.getLineIndexOfChar(originalIndex) - textField.getLineIndexOfChar(charIndex));
			// guessing line height differences when lots of spacebars are pressed and are being wordwrapped

			charBoundaries.y = textField.getLineIndexOfChar(originalIndex) * charBoundaries.height;
		}
		return charBoundaries;
	}

	override function set_text(Text:String):String
	{
		if (Text == "") Text = "​";
		var rText:String = super.set_text(Text);

		if (textField == null)
		{
			return rText;
		}

		textField.text = Text;

		return rText;
	}

	/**
	 * Gets the index of the character present under the point `(X, Y)`.
	 * 
	 * It also counts pressing between lines, before and after the end of the text (as long as the point is in the same line as the character).
	 * 
	 * @param X The X position of the point. **Make sure its relative to the the textbox**.
	 * you can get the relative X coordinate buy subtracting that value from the textbox's `x` value -  `xValue - textbox.x`
	 * @param Y The X position of the point. **Make sure its relative to the the textbox**. 
	 * you can get the relative Y coordinate buy subtracting that value from the textbox's `y` value -  `xValue - textbox.x`
	 * @return The index of the character under the `(X, Y)` point. will return `0` if theres no character under that point
	 */
	public function getCharIndexAtPoint(X:Float, Y:Float):Int
	{
		var i:Int = 0;

		// place caret at matching char position

		if (text.length > 0)
		{
			for (i in 0...text.length)
			{
				var r = getCharBoundaries(i);
				if ((X >= r.x && X <= r.right && Y >= r.y && Y <= r.bottom))

				{
					return i;
				}
			}
			// the mouse might have been pressed between the lines
			// the code allows correct caret positioning when pressing between the lines
			var i = 0;
			while (i < text.length)
			{
				var r = getCharBoundaries(i),
					line = textField.getLineIndexOfChar(i + 1);
				if (r == null)
					return 0;
				if (Y >= r.y && Y <= r.bottom)
				{
					if (i == 0)
						i--;
					if (i != -1 && !StringTools.contains(text, "\n"))
						i -= 2;
					if (i + 1 + StringTools.replace(textField.getLineText(line), "\n", "").length == text.length - 1)
						i++;
					return i + 1 + StringTools.replace(textField.getLineText(line), "\n", "").length;
				}
				i++;
			}
			return text.length;
		}
		// place caret at leftmost position

		return 0;
	}

	/**
	 * Draws the frame of animation for the input text.
	 *
	 * @param  RunOnCpp  Whether the frame should also be recalculated if we're on a non-flash target
	 */
	override function calcFrame(RunOnCpp:Bool = false):Void
	{
		super.calcFrame(RunOnCpp);

		var h = if (text.length > 0) getCharBoundaries(text.length).height else height;var h = if (text.length > 0) getCharBoundaries(text.length).height else height;
		#if js if (caret != null && text == "") text = "​"; #end 
		if (fieldBorderSprite != null)
		{
			if (fieldBorderThickness > 0)
			{
				fieldBorderSprite.makeGraphic(Std.int(width + fieldBorderThickness * 2), Std.int(h + fieldBorderThickness * 2), fieldBorderColor);
				fieldBorderSprite.x = x - fieldBorderThickness;
				fieldBorderSprite.y = y - fieldBorderThickness;
			}
			else if (fieldBorderThickness == 0)
			{
				fieldBorderSprite.visible = false;
			}
		}

		if (backgroundSprite != null)
		{
			if (background)
			{
				backgroundSprite.makeGraphic(Std.int(width), Std.int(height), backgroundColor);
				backgroundSprite.x = x;
				backgroundSprite.y = y;
			}
			else
			{
				backgroundSprite.visible = false;
			}
		}

		if (caret != null)
		{
			// Generate the properly sized caret and also draw a border that matches that of the textfield (if a border style is set)

			// borderQuality can be safely ignored since the caret is always a rectangle

			var cw:Int = caretWidth; // Basic size of the caret

			var ch:Int = Std.int(size + 2);

			// Make sure alpha channels are correctly set

			var borderC:Int = (0xff000000 | (borderColor & 0x00ffffff));
			var caretC:Int = (0xff000000 | (caretColor & 0x00ffffff));

			// Generate unique key for the caret so we don't cause weird bugs if someone makes some random flxsprite of this size and color

			var caretKey:String = "caret" + cw + "x" + ch + "c:" + caretC + "b:" + borderStyle + "," + borderSize + "," + borderC;
			switch (borderStyle)
			{
				case NONE:
					// No border, just make the caret

					caret.makeGraphic(cw, ch, caretC, false, caretKey);
					caret.offset.x = caret.offset.y = 0;

				case SHADOW:
					// Shadow offset to the lower-right

					cw += Std.int(borderSize);
					ch += Std.int(borderSize); // expand canvas on one side for shadow

					caret.makeGraphic(cw, ch, FlxColor.TRANSPARENT, false, caretKey); // start with transparent canvas

					var r:Rectangle = new Rectangle(borderSize, borderSize, caretWidth, Std.int(size + 2));
					caret.pixels.fillRect(r, borderC); // draw shadow

					r.x = r.y = 0;
					caret.pixels.fillRect(r, caretC); // draw caret

					caret.offset.x = caret.offset.y = 0;

				case OUTLINE_FAST, OUTLINE:
					// Border all around it

					cw += Std.int(borderSize * 2);
					ch += Std.int(borderSize * 2); // expand canvas on both sides

					caret.makeGraphic(cw, ch, borderC, false, caretKey); // start with borderColor canvas

					var r = new Rectangle(borderSize, borderSize, caretWidth, Std.int(size + 2));
					caret.pixels.fillRect(r, caretC); // draw caret

					// we need to offset caret's drawing position since the caret is now larger than normal

					caret.offset.x = caret.offset.y = borderSize;
			}
			// Update width/height so caret's dimensions match its pixels

			caret.width = cw;
			caret.height = ch;

			caretIndex = caretIndex; // force this to update
		}
	}

	/**
	 * Turns the caret on/off for the caret flashing animation.
	 */
	function toggleCaret(timer:FlxTimer):Void
	{
		caret.visible = !caret.visible;
	}

	/**
	 * Checks an input string against the current
	 * filter and returns a filtered string
	 */
	function filter(text:String):String
	{
		if (forceCase == UPPER_CASE)
		{
			text = text.toUpperCase();
		}
		else if (forceCase == LOWER_CASE)
		{
			text = text.toLowerCase();
		}

		if (filterMode != NO_FILTER)
		{
			var pattern:EReg;
			switch (filterMode)
			{
				case ONLY_ALPHA:
					pattern = ~/[^a-zA-Z]*/g;
				case ONLY_NUMERIC:
					pattern = ~/[^0-9]*/g;
				case ONLY_ALPHANUMERIC:
					pattern = ~/[^a-zA-Z0-9]*/g;
				case CUSTOM_FILTER:
					pattern = customFilterPattern;
				default:
					throw new Error("FlxInputText: Unknown filterMode (" + filterMode + ")");
			}
			text = pattern.replace(text, "");
		}
		return text;
	}

	override function set_x(X:Float):Float
	{
		if ((fieldBorderSprite != null) && fieldBorderThickness > 0)
		{
			fieldBorderSprite.x = X - fieldBorderThickness;
		}
		if ((backgroundSprite != null) && background)
		{
			backgroundSprite.x = X;
		}
		return super.set_x(X);
	}

	override function set_y(Y:Float):Float
	{
		if ((fieldBorderSprite != null) && fieldBorderThickness > 0)
		{
			fieldBorderSprite.y = Y - fieldBorderThickness;
		}
		if ((backgroundSprite != null) && background)
		{
			backgroundSprite.y = Y;
		}
		return super.set_y(Y);
	}

	function set_hasFocus(newFocus:Bool):Bool
	{
		if (newFocus)
		{
			if (hasFocus != newFocus)
			{
				_caretTimer = new FlxTimer().start(0.5, toggleCaret, 0);
				caret.visible = true;
				caretIndex = text.length;
			}
		}
		else
		{
			// Graphics

			caret.visible = false;
			if (_caretTimer != null)
			{
				_caretTimer.cancel();
			}
		}

		if (newFocus != hasFocus)
		{
			calcFrame();
		}
		return hasFocus = newFocus;
	}

	/**
	 * Gets the text's base alignment.
	 */
	public function getAlignment():FlxTextAlign
	{
		var alignStr:FlxTextAlign = LEFT;
		if (_defaultFormat != null && _defaultFormat.align != null)
		{
			alignStr = alignment;
		}
		return alignStr;
	}

	function set_caretIndex(newCaretIndex:Int):Int
	{
		var offx:Float = 0;

		var alignStr:FlxTextAlign = getAlignment();

		switch (alignStr)
		{
			case RIGHT:
				offx = textField.width - 2 - textField.textWidth - 2;
				if (offx < 0)
					offx = 0; // hack, fix negative offset.

			case CENTER:
				offx = (textField.width - 2 - textField.textWidth) / 2 + textField.scrollH / 2;
				if (offx <= 1)
					offx = 0; // hack, fix offset rounding alignment.

			default:
				offx = 0;
		}

		caretIndex = newCaretIndex;

		// If caret is too far to the right something is wrong

		if (caretIndex > (text.length + 1))
		{
			caretIndex = -1;
		}

		// Caret is OK, proceed to position

		if (caretIndex != -1)
		{
			var boundaries:Rectangle = null;

			// Caret is not to the right of text

			if (caretIndex < text.length)
			{
				boundaries = getCharBoundaries(caretIndex - 1);
				if (boundaries != null)
				{
					caret.x = boundaries.right + x ;
					caret.y = boundaries.top + y;
				}
			}
			// Caret is to the right of text
			else
			{
				boundaries = getCharBoundaries(caretIndex - 1);
				if (boundaries != null)
				{
					caret.x = boundaries.right + x;
					caret.y = boundaries.top + y;
				}
				else if (text.length == 0)
				{
					// 2 px gutters

					caret.x = x + 2;
					caret.y = y + 2;
				}
			}
		}

		// Make sure the caret doesn't leave the textfield on single-line input texts

		if ((lines == 1) && (caret.x + caret.width) > (x + width))
		{
			caret.x = x + width - 2;
		}
		textField.setSelection(caretIndex, caretIndex);
		return caretIndex;
	}

	function set_forceCase(Value:Int):Int
	{
		forceCase = Value;
		text = filter(text);
		return forceCase;
	}

	override function set_size(Value:Int):Int
	{
		super.size = Value;
		caret.makeGraphic(1, Std.int(size + 2));
		return Value;
	}

	function set_maxLength(Value:Int):Int
	{
		maxLength = Value;
		if (text.length > maxLength)
		{
			text = text.substring(0, maxLength);
		}
		return maxLength;
	}

	function set_lines(Value:Int):Int
	{
		if (Value == 0)
			return 0;

		if (Value > 1)
		{
			textField.wordWrap = true;
			textField.multiline = true;
		}
		else
		{
			textField.wordWrap = false;
			textField.multiline = false;
		}

		lines = Value;
		calcFrame();
		return lines;
	}

	function get_passwordMode():Bool
	{
		return textField.displayAsPassword;
	}

	function set_passwordMode(value:Bool):Bool
	{
		textField.displayAsPassword = value;
		calcFrame();
		return value;
	}

	function set_filterMode(Value:Int):Int
	{
		filterMode = Value;
		text = filter(text);
		return filterMode;
	}

	function set_fieldBorderColor(Value:Int):Int
	{
		fieldBorderColor = Value;
		calcFrame();
		return fieldBorderColor;
	}

	function set_fieldBorderThickness(Value:Int):Int
	{
		fieldBorderThickness = Value;
		calcFrame();
		return fieldBorderThickness;
	}

	function set_backgroundColor(Value:Int):Int
	{
		backgroundColor = Value;
		calcFrame();
		return backgroundColor;
	}
}