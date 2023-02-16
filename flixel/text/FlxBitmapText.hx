package flixel.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.geom.ColorTransform;

using flixel.util.FlxColorTransformUtil;
using flixel.util.FlxUnicodeUtil;

/**
 * Extends FlxSprite to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 */
class FlxBitmapText extends FlxSprite
{
	/**
	 * Font for text rendering.
	 */
	public var font(default, set):FlxBitmapFont;

	/**
	 * Text to display.
	 */
	public var text(default, set):String = "";

	/**
	 * Helper object to avoid many ColorTransform allocations
	 */
	var _colorParams:ColorTransform = new ColorTransform();

	/**
	 * Helper array which contains actual strings for rendering.
	 */
	// TODO: switch it to Array<Array<Int>> (for optimizations - i.e. less Utf8 usage)
	var _lines:Array<String> = [];

	/**
	 * Helper array which contains width of each displayed lines.
	 */
	var _linesWidth:Array<Int> = [];

	/**
	 * Specifies how the text field should align text.
	 * JUSTIFY alignment isn't supported.
	 * Note: 'autoSize' must be set to false or alignment won't show any visual differences.
	 */
	public var alignment(default, set):FlxTextAlign = FlxTextAlign.LEFT;

	/**
	 * The distance to add between lines.
	 */
	public var lineSpacing(default, set):Int = 0;

	/**
	 * The distance to add between letters.
	 */
	public var letterSpacing(default, set):Int = 0;

	/**
	 * Whether to convert text to upper case or not.
	 */
	public var autoUpperCase(default, set):Bool = false;

	/**
	 * A Boolean value that indicates whether the text field has word wrap.
	 */
	public var wordWrap(default, set):Bool = true;

	/**
	 * Whether word wrapping algorithm should wrap lines by words or by single character.
	 * Default value is true.
	 */
	public var wrapByWord(default, set):Bool = true;

	/**
	 * Whether this text field have fixed width or not.
	 * Default value if true.
	 */
	public var autoSize(default, set):Bool = true;

	/**
	 * Number of pixels between text and text field border
	 */
	public var padding(default, set):Int = 0;

	/**
	 * Width of the text in this text field.
	 */
	public var textWidth(get, never):Int;

	/**
	 * Height of the text in this text field.
	 */
	public var textHeight(get, never):Int;

	/**
	 * Height of the single line of text (without lineSpacing).
	 */
	public var lineHeight(get, never):Int;

	/**
	 * Number of space characters in one tab.
	 */
	public var numSpacesInTab(default, set):Int = 4;

	/**
	 * The color of the text in 0xAARRGGBB format.
	 * Result color of text will be multiplication of textColor and color.
	 */
	public var textColor(default, set):FlxColor = FlxColor.WHITE;

	/**
	 * Whether to use textColor while rendering or not.
	 */
	public var useTextColor(default, set):Bool = false;

	/**
	 * Use a border style
	 */
	public var borderStyle(default, set):FlxTextBorderStyle = NONE;

	/**
	 * The color of the border in 0xAARRGGBB format
	 */
	public var borderColor(default, set):FlxColor = FlxColor.BLACK;

	/**
	 * The size of the border, in pixels.
	 */
	public var borderSize(default, set):Float = 1;

	/**
	 * How many iterations do use when drawing the border. 0: only 1 iteration, 1: one iteration for every pixel in borderSize
	 * A value of 1 will have the best quality for large border sizes, but might reduce performance when changing text.
	 * NOTE: If the borderSize is 1, borderQuality of 0 or 1 will have the exact same effect (and performance).
	 */
	public var borderQuality(default, set):Float = 0;

	/**
	 * Offset that is applied to the shadow border style, if active.
	 * x and y are multiplied by borderSize. Default is (1, 1), or lower-right corner.
	 */
	public var shadowOffset(default, null):FlxPoint;

	/**
	 * Specifies whether the text should have background
	 */
	public var background(default, set):Bool = false;

	/**
	 * Specifies the color of background
	 */
	public var backgroundColor(default, set):FlxColor = FlxColor.TRANSPARENT;

	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	public var multiLine(default, set):Bool = true;

	/**
	 * Reflects how many lines have this text field.
	 */
	public var numLines(get, never):Int;

	/**
	 * The width of the TextField object used for bitmap generation for this FlxText object.
	 * Use it when you want to change the visible width of text. Enables autoSize if <= 0.
	 */
	public var fieldWidth(get, set):Int;

	var _fieldWidth:Int;

	var pendingTextChange:Bool = true;
	var pendingTextBitmapChange:Bool = true;
	var pendingPixelsChange:Bool = true;

	var textData:Array<Float>;
	var textDrawData:Array<Float>;
	var borderDrawData:Array<Float>;

	/**
	 * Helper bitmap buffer for text pixels but without any color transformations
	 */
	var textBitmap:BitmapData;

	/**
	 * Constructs a new text field component.
	 * Warning: The default font may work incorrectly on HTML5
	 * and is utterly unreliable on Brave Browser with shields up.
	 * 
	 * @param 	font	Optional parameter for component's font prop
	 */
	public function new(?font:FlxBitmapFont)
	{
		super();

		width = fieldWidth = 2;
		alpha = 1;

		this.font = (font == null) ? FlxBitmapFont.getDefaultFont() : font;

		shadowOffset = FlxPoint.get(1, 1);

		if (FlxG.renderBlit)
		{
			pixels = new BitmapData(1, 1, true, FlxColor.TRANSPARENT);
		}
		else
		{
			textData = [];

			textDrawData = [];
			borderDrawData = [];
		}
	}

	/**
	 * Clears all resources used.
	 */
	override public function destroy():Void
	{
		font = null;
		text = null;
		_lines = null;
		_linesWidth = null;

		shadowOffset = FlxDestroyUtil.put(shadowOffset);
		textBitmap = FlxDestroyUtil.dispose(textBitmap);

		_colorParams = null;

		if (FlxG.renderTile)
		{
			textData = null;
			textDrawData = null;
			borderDrawData = null;
		}
		super.destroy();
	}

	/**
	 * Forces graphic regeneration for this text field.
	 */
	override public function drawFrame(Force:Bool = false):Void
	{
		if (FlxG.renderTile)
		{
			Force = true;
		}
		pendingTextBitmapChange = pendingTextBitmapChange || Force;
		checkPendingChanges(false);
		if (FlxG.renderBlit)
		{
			super.drawFrame(Force);
		}
	}
	
	override function updateHitbox()
	{
		checkPendingChanges(true);
		super.updateHitbox();
	}

	inline function checkPendingChanges(useTiles:Bool = false):Void
	{
		if (FlxG.renderBlit)
		{
			useTiles = false;
		}

		if (pendingTextChange)
		{
			updateText();
			pendingTextBitmapChange = true;
		}

		if (pendingTextBitmapChange)
		{
			updateTextBitmap(useTiles);
			pendingPixelsChange = true;
		}

		if (pendingPixelsChange)
		{
			updatePixels(useTiles);
		}
	}

	override public function draw():Void
	{
		if (FlxG.renderBlit)
		{
			checkPendingChanges(false);
			super.draw();
		}
		else
		{
			checkPendingChanges(true);

			var textLength:Int = Std.int(textDrawData.length / 3);
			var borderLength:Int = Std.int(borderDrawData.length / 3);

			var dataPos:Int;

			var cr:Float = color.redFloat;
			var cg:Float = color.greenFloat;
			var cb:Float = color.blueFloat;

			var borderRed:Float = borderColor.redFloat * cr;
			var borderGreen:Float = borderColor.greenFloat * cg;
			var borderBlue:Float = borderColor.blueFloat * cb;
			var bAlpha:Float = borderColor.alphaFloat * alpha;

			var textRed:Float = cr;
			var textGreen:Float = cg;
			var textBlue:Float = cb;
			var tAlpha:Float = alpha;

			if (useTextColor)
			{
				textRed *= textColor.redFloat;
				textGreen *= textColor.greenFloat;
				textBlue *= textColor.blueFloat;
				tAlpha *= textColor.alpha;
			}

			var bgRed:Float = cr;
			var bgGreen:Float = cg;
			var bgBlue:Float = cb;
			var bgAlpha:Float = alpha;

			if (background)
			{
				bgRed *= backgroundColor.redFloat;
				bgGreen *= backgroundColor.greenFloat;
				bgBlue *= backgroundColor.blueFloat;
				bgAlpha *= backgroundColor.alphaFloat;
			}

			var drawItem;
			var currFrame:FlxFrame = null;
			var currTileX:Float = 0;
			var currTileY:Float = 0;
			var sx:Float = scale.x * _facingHorizontalMult;
			var sy:Float = scale.y * _facingVerticalMult;

			var ox:Float = origin.x;
			var oy:Float = origin.y;

			if (_facingHorizontalMult != 1)
			{
				ox = frameWidth - ox;
			}
			if (_facingVerticalMult != 1)
			{
				oy = frameHeight - oy;
			}

			var clippedFrameRect;

			if (clipRect != null)
			{
				clippedFrameRect = clipRect.intersection(FlxRect.weak(0, 0, frameWidth, frameHeight));

				if (clippedFrameRect.isEmpty)
					return;
			}
			else
			{
				clippedFrameRect = FlxRect.get(0, 0, frameWidth, frameHeight);
			}

			for (camera in cameras)
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
				{
					continue;
				}

				getScreenPosition(_point, camera).subtractPoint(offset);

				if (isPixelPerfectRender(camera))
				{
					_point.floor();
				}

				updateTrig();

				if (background)
				{
					// backround tile transformations
					currFrame = FlxG.bitmap.whitePixel;
					_matrix.identity();
					_matrix.scale(0.1 * clippedFrameRect.width, 0.1 * clippedFrameRect.height);
					_matrix.translate(clippedFrameRect.x - ox, clippedFrameRect.y - oy);
					_matrix.scale(sx, sy);

					if (angle != 0)
					{
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
					}

					_matrix.translate(_point.x + ox, _point.y + oy);
					_colorParams.setMultipliers(bgRed, bgGreen, bgBlue, bgAlpha);
					camera.drawPixels(currFrame, null, _matrix, _colorParams, blend, antialiasing);
				}

				var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

				drawItem = camera.startQuadBatch(font.parent, true, hasColorOffsets, blend, antialiasing, shader);

				for (j in 0...borderLength)
				{
					dataPos = j * 3;

					currFrame = font.getCharFrame(Std.int(borderDrawData[dataPos]));

					currTileX = borderDrawData[dataPos + 1];
					currTileY = borderDrawData[dataPos + 2];

					if (clipRect != null)
					{
						clippedFrameRect.copyFrom(clipRect).offset(-currTileX, -currTileY);
						currFrame = currFrame.clipTo(clippedFrameRect);
					}

					currFrame.prepareMatrix(_matrix);
					_matrix.translate(currTileX - ox, currTileY - oy);
					_matrix.scale(sx, sy);
					if (angle != 0)
					{
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
					}

					_matrix.translate(_point.x + ox, _point.y + oy);
					_colorParams.setMultipliers(borderRed, borderGreen, borderBlue, bAlpha);
					drawItem.addQuad(currFrame, _matrix, _colorParams);
				}

				for (j in 0...textLength)
				{
					dataPos = j * 3;

					currFrame = font.getCharFrame(Std.int(textDrawData[dataPos]));

					currTileX = textDrawData[dataPos + 1];
					currTileY = textDrawData[dataPos + 2];

					if (clipRect != null)
					{
						clippedFrameRect.copyFrom(clipRect).offset(-currTileX, -currTileY);
						currFrame = currFrame.clipTo(clippedFrameRect);
					}

					currFrame.prepareMatrix(_matrix);
					_matrix.translate(currTileX - ox, currTileY - oy);
					_matrix.scale(sx, sy);
					if (angle != 0)
					{
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
					}

					_matrix.translate(_point.x + ox, _point.y + oy);
					_colorParams.setMultipliers(textRed, textGreen, textBlue, tAlpha);
					drawItem.addQuad(currFrame, _matrix, _colorParams);
				}

				#if FLX_DEBUG
				FlxBasic.visibleCount++;
				#end
			}

			// dispose clipRect helpers
			clippedFrameRect.put();

			#if FLX_DEBUG
			if (FlxG.debugger.drawDebug)
			{
				drawDebug();
			}
			#end
		}
	}

	override function set_clipRect(Rect:FlxRect):FlxRect
	{
		super.set_clipRect(Rect);
		if (!FlxG.renderBlit)
		{
			pendingTextBitmapChange = true;
		}
		return clipRect;
	}

	override function set_color(Color:FlxColor):FlxColor
	{
		super.set_color(Color);
		if (FlxG.renderBlit)
		{
			pendingTextBitmapChange = true;
		}
		return color;
	}

	override function set_alpha(value:Float):Float
	{
		super.set_alpha(value);
		if (FlxG.renderBlit)
		{
			pendingTextBitmapChange = true;
		}
		return value;
	}

	function set_textColor(value:FlxColor):FlxColor
	{
		if (textColor != value)
		{
			textColor = value;
			if (FlxG.renderBlit)
			{
				pendingPixelsChange = true;
			}
		}

		return value;
	}

	function set_useTextColor(value:Bool):Bool
	{
		if (useTextColor != value)
		{
			useTextColor = value;
			if (FlxG.renderBlit)
			{
				pendingPixelsChange = true;
			}
		}

		return value;
	}

	override function calcFrame(RunOnCpp:Bool = false):Void
	{
		if (FlxG.renderTile)
		{
			drawFrame(RunOnCpp);
		}
		else
		{
			super.calcFrame(RunOnCpp);
		}
	}

	function set_text(value:String):String
	{
		if (value != text)
		{
			text = value;
			pendingTextChange = true;
		}

		return value;
	}

	function updateText():Void
	{
		var tmp:String = (autoUpperCase) ? text.toUpperCase() : text;

		_lines = tmp.split("\n");

		if (!autoSize)
		{
			if (wordWrap)
			{
				wrap();
			}
			else
			{
				cutLines();
			}
		}

		if (!multiLine)
		{
			_lines = [_lines[0]];
		}

		var numLines:Int = _lines.length;
		for (i in 0...numLines)
		{
			_lines[i] = StringTools.rtrim(_lines[i]);
		}

		pendingTextChange = false;
		pendingTextBitmapChange = true;
	}

	/**
	 * Calculates the size of text field.
	 */
	function computeTextSize():Void
	{
		var txtWidth:Int = textWidth + Std.int(borderSize) * 2;
		var txtHeight:Int = textHeight + 2 * padding + Std.int(borderSize) * 2;

		if (autoSize)
		{
			txtWidth += 2 * padding;
		}
		else
		{
			txtWidth = fieldWidth;
		}

		frameWidth = (txtWidth == 0) ? 1 : txtWidth;
		frameHeight = (txtHeight == 0) ? 1 : txtHeight;
	}

	/**
	 * Calculates width of the line with provided index
	 *
	 * @param	lineIndex	index of the line in _lines array
	 * @return	The width of the line
	 */
	public function getLineWidth(lineIndex:Int):Int
	{
		if (lineIndex < 0 || lineIndex >= _lines.length)
		{
			return 0;
		}

		return getStringWidth(_lines[lineIndex]);
	}

	/**
	 * Calculates width of provided string (for current font).
	 *
	 * @param	str	String to calculate width for
	 * @return	The width of result bitmap text.
	 */
	public function getStringWidth(str:String):Int
	{
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;

		var lineLength:Int = str.uLength();
		var lineWidth:Float = font.minOffsetX;

		var charCode:Int; // current character in word
		var charWidth:Float; // the width of current character
		var charFrame:FlxFrame;

		for (c in 0...lineLength)
		{
			charCode = str.uCharCodeAt(c);
			charWidth = 0;

			if (charCode == FlxBitmapFont.SPACE_CODE)
			{
				charWidth = spaceWidth;
			}
			else if (charCode == FlxBitmapFont.TAB_CODE)
			{
				charWidth = tabWidth;
			}
			else if (font.charExists(charCode))
			{
				charWidth = font.getCharAdvance(charCode);

				if (c == (lineLength - 1))
				{
					charFrame = font.getCharFrame(charCode);
					charWidth = Std.int(charFrame.sourceSize.x);
				}
			}

			lineWidth += (charWidth + letterSpacing);
		}

		if (lineLength > 0)
		{
			lineWidth -= letterSpacing;
		}

		return Std.int(lineWidth);
	}

	/**
	 * Just cuts the lines which are too long to fit in the field.
	 */
	function cutLines():Void
	{
		for (i in 0..._lines.length)
		{
			var lineWidth = font.minOffsetX;

			for (c in 0..._lines[i].uLength())
			{
				switch (_lines[i].uCharCodeAt(c))
				{
					case FlxBitmapFont.SPACE_CODE:
						lineWidth += font.spaceWidth;
					case FlxBitmapFont.TAB_CODE:
						lineWidth += font.spaceWidth * numSpacesInTab;
					case charCode:
						lineWidth += font.getCharAdvance(charCode);
				}

				lineWidth += letterSpacing;
				if (lineWidth > _fieldWidth - 2 * padding)
				{
					// cut every character after this
					_lines[i] = _lines[i].uSub(0, c);
					break;
				}
			}
		}
	}

	/**
	 * Automatically wraps text by figuring out how many characters can fit on a
	 * single line, and splitting the remainder onto a new line.
	 */
	function wrap():Void
	{
		// subdivide lines
		var newLines:Array<String> = [];
		var words:Array<String>; // the array of words in the current line

		for (line in _lines)
		{
			words = [];
			// split this line into words
			splitLineIntoWords(line, words);

			if (wrapByWord)
			{
				wrapLineByWord(words, newLines);
			}
			else
			{
				wrapLineByCharacter(words, newLines);
			}
		}

		_lines = newLines;
	}

	/**
	 * Helper function for splitting line of text into separate words.
	 *
	 * @param	line	line to split.
	 * @param	words	result array to fill with words.
	 */
	function splitLineIntoWords(line:String, words:Array<String>):Void
	{
		var word:String = ""; // current word to process
		var wordUtf8 = new UnicodeBuffer();
		var isSpaceWord:Bool = false; // whether current word consists of spaces or not
		var lineLength:Int = line.uLength(); // lenght of the current line

		var c:Int = 0; // char index on the line
		var charCode:Int; // code for the current character in word

		while (c < lineLength)
		{
			charCode = line.uCharCodeAt(c);
			word = wordUtf8.toString();

			if (charCode == FlxBitmapFont.SPACE_CODE || charCode == FlxBitmapFont.TAB_CODE)
			{
				if (!isSpaceWord)
				{
					isSpaceWord = true;

					if (word != "")
					{
						words.push(word);
						wordUtf8 = new UnicodeBuffer();
					}
				}

				wordUtf8 = wordUtf8.addChar(charCode);
			}
			else if (charCode == '-'.code)
			{
				if (isSpaceWord && word != "")
				{
					isSpaceWord = false;
					words.push(word);
					words.push('-');
				}
				else if (!isSpaceWord)
				{
					var charUtf8 = new UnicodeBuffer();
					charUtf8 = charUtf8.addChar(charCode);
					words.push(word + charUtf8.toString());
				}

				wordUtf8 = new UnicodeBuffer();
			}
			else
			{
				if (isSpaceWord && word != "")
				{
					isSpaceWord = false;
					words.push(word);
					wordUtf8 = new UnicodeBuffer();
				}

				wordUtf8 = wordUtf8.addChar(charCode);
			}

			c++;
		}

		word = wordUtf8.toString();
		if (word != "")
			words.push(word);
	}

	/**
	 * Wraps provided line by words.
	 *
	 * @param	words		The array of words in the line to process.
	 * @param	newLines	Array to fill with result lines.
	 */
	function wrapLineByWord(words:Array<String>, newLines:Array<String>):Void
	{
		var numWords:Int = words.length; // number of words in the current line
		var w:Int; // word index in the current line
		var word:String; // current word to process
		var wordWidth:Float; // total width of current word
		var wordLength:Int; // number of letters in current word

		var isSpaceWord:Bool = false; // whether current word consists of spaces or not

		var charCode:Int;
		var charWidth:Float = 0; // the width of current character

		var subLines:Array<String> = []; // helper array for subdividing lines

		var subLine:String; // current subline to assemble
		var subLineWidth:Float; // the width of current subline

		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;

		var startX:Int = font.minOffsetX;

		if (numWords > 0)
		{
			w = 0;
			subLineWidth = startX;
			subLine = "";

			while (w < numWords)
			{
				wordWidth = 0;
				word = words[w];
				wordLength = word.uLength();

				charCode = word.charCodeAt(0);
				isSpaceWord = (charCode == FlxBitmapFont.SPACE_CODE || charCode == FlxBitmapFont.TAB_CODE);

				for (c in 0...wordLength)
				{
					charCode = word.charCodeAt(c);

					if (charCode == FlxBitmapFont.SPACE_CODE)
					{
						charWidth = spaceWidth;
					}
					else if (charCode == FlxBitmapFont.TAB_CODE)
					{
						charWidth = tabWidth;
					}
					else
					{
						charWidth = font.getCharAdvance(charCode);
					}

					wordWidth += charWidth;
				}

				wordWidth += (wordLength - 1) * letterSpacing;

				if (subLineWidth + wordWidth > _fieldWidth - 2 * padding)
				{
					if (isSpaceWord)
					{
						subLines.push(subLine);
						subLine = "";
						subLineWidth = startX;
					}
					else if (subLine != "") // new line isn't empty so we should add it to sublines array and start another one
					{
						subLines.push(subLine);
						subLine = word;
						subLineWidth = startX + wordWidth + letterSpacing;
					}
					else // the line is too tight to hold even one word
					{
						subLine = word;
						subLineWidth = startX + wordWidth + letterSpacing;
					}
				}
				else
				{
					subLine += word;
					subLineWidth += wordWidth + letterSpacing;
				}

				w++;
			}

			if (subLine != "")
			{
				subLines.push(subLine);
			}
		}

		for (subline in subLines)
		{
			newLines.push(subline);
		}
	}

	/**
	 * Wraps provided line by characters (as in standart flash text fields).
	 *
	 * @param	words		The array of words in the line to process.
	 * @param	newLines	Array to fill with result lines.
	 */
	function wrapLineByCharacter(words:Array<String>, newLines:Array<String>):Void
	{
		var numWords:Int = words.length; // number of words in the current line
		var w:Int; // word index in the current line
		var word:String; // current word to process
		var wordLength:Int; // number of letters in current word

		var isSpaceWord:Bool = false; // whether current word consists of spaces or not

		var charCode:Int;
		var c:Int; // char index
		var charWidth:Float = 0; // the width of current character

		var subLines:Array<String> = []; // helper array for subdividing lines

		var subLine:String; // current subline to assemble
		var subLineUtf8:UnicodeBuffer;
		var subLineWidth:Float; // the width of current subline

		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;

		var startX:Int = font.minOffsetX;

		if (numWords > 0)
		{
			w = 0;
			subLineWidth = startX;
			subLineUtf8 = new UnicodeBuffer();

			while (w < numWords)
			{
				word = words[w];
				wordLength = word.uLength();

				charCode = word.uCharCodeAt(0);
				isSpaceWord = (charCode == FlxBitmapFont.SPACE_CODE || charCode == FlxBitmapFont.TAB_CODE);

				c = 0;

				while (c < wordLength)
				{
					charCode = word.uCharCodeAt(c);

					if (charCode == FlxBitmapFont.SPACE_CODE)
					{
						charWidth = spaceWidth;
					}
					else if (charCode == FlxBitmapFont.TAB_CODE)
					{
						charWidth = tabWidth;
					}
					else
					{
						charWidth = font.getCharAdvance(charCode);
					}

					if (subLineWidth + charWidth > _fieldWidth - 2 * padding)
					{
						subLine = subLineUtf8.toString();

						if (isSpaceWord) // new line ends with space / tab char, so we push it to sublines array, skip all the rest spaces and start another line
						{
							subLines.push(subLine);
							c = wordLength;
							subLineUtf8 = new UnicodeBuffer();
							subLineWidth = startX;
						}
						else if (subLine != "") // new line isn't empty so we should add it to sublines array and start another one
						{
							subLines.push(subLine);
							subLineUtf8 = new UnicodeBuffer();
							subLineUtf8 = subLineUtf8.addChar(charCode);
							subLineWidth = startX + charWidth + letterSpacing;
						}
						else // the line is too tight to hold even one character
						{
							subLineUtf8 = new UnicodeBuffer();
							subLineUtf8 = subLineUtf8.addChar(charCode);
							subLineWidth = startX + charWidth + letterSpacing;
						}
					}
					else
					{
						subLineUtf8 = subLineUtf8.addChar(charCode);
						subLineWidth += (charWidth + letterSpacing);
					}

					c++;
				}

				w++;
			}

			subLine = subLineUtf8.toString();

			if (subLine != "")
			{
				subLines.push(subLine);
			}
		}

		for (subline in subLines)
		{
			newLines.push(subline);
		}
	}

	/**
	 * Internal method for updating helper data for text rendering
	 */
	function updateTextBitmap(useTiles:Bool = false):Void
	{
		computeTextSize();

		if (FlxG.renderBlit)
		{
			useTiles = false;
		}

		if (!useTiles)
		{
			textBitmap = FlxDestroyUtil.disposeIfNotEqual(textBitmap, frameWidth, frameHeight);

			if (textBitmap == null)
			{
				textBitmap = new BitmapData(frameWidth, frameHeight, true, FlxColor.TRANSPARENT);
			}
			else
			{
				textBitmap.fillRect(textBitmap.rect, FlxColor.TRANSPARENT);
			}

			textBitmap.lock();
		}
		else if (FlxG.renderTile)
		{
			textData.splice(0, textData.length);
		}

		_fieldWidth = frameWidth;

		var numLines:Int = _lines.length;
		var line:String;
		var lineWidth:Int;

		var ox:Int, oy:Int;

		for (i in 0...numLines)
		{
			line = _lines[i];
			lineWidth = _linesWidth[i];

			// LEFT
			ox = font.minOffsetX;
			oy = i * (font.lineHeight + lineSpacing) + padding;

			if (alignment == FlxTextAlign.CENTER)
			{
				ox += Std.int((frameWidth - lineWidth) / 2);
			}
			else if (alignment == FlxTextAlign.RIGHT)
			{
				ox += (frameWidth - lineWidth) - padding;
			}
			else // LEFT OR JUSTIFY
			{
				ox += padding;
			}

			drawLine(i, ox, oy, useTiles);
		}

		if (!useTiles)
		{
			textBitmap.unlock();
		}

		pendingTextBitmapChange = false;
	}

	function drawLine(lineIndex:Int, posX:Int, posY:Int, useTiles:Bool = false):Void
	{
		if (FlxG.renderBlit)
		{
			useTiles = false;
		}

		if (useTiles)
		{
			tileLine(lineIndex, posX, posY);
		}
		else
		{
			blitLine(lineIndex, posX, posY);
		}
	}

	function blitLine(lineIndex:Int, startX:Int, startY:Int):Void
	{
		var charFrame:FlxFrame;
		var charCode:Int;
		var curX:Float = startX;
		var curY:Int = startY;

		var line:String = _lines[lineIndex];
		var spaceWidth:Int = font.spaceWidth;
		var lineLength:Int = line.uLength();
		var textWidth:Int = this.textWidth;

		if (alignment == FlxTextAlign.JUSTIFY)
		{
			var numSpaces:Int = 0;

			for (i in 0...lineLength)
			{
				charCode = line.uCharCodeAt(i);

				if (charCode == FlxBitmapFont.SPACE_CODE)
				{
					numSpaces++;
				}
				else if (charCode == FlxBitmapFont.TAB_CODE)
				{
					numSpaces += numSpacesInTab;
				}
			}

			var lineWidth:Int = getStringWidth(line);
			var totalSpacesWidth:Int = numSpaces * font.spaceWidth;
			spaceWidth = Std.int((textWidth - lineWidth + totalSpacesWidth) / numSpaces);
		}

		var tabWidth:Int = spaceWidth * numSpacesInTab;

		var charUt8:UnicodeBuffer;

		for (i in 0...lineLength)
		{
			charCode = line.uCharCodeAt(i);

			if (charCode == FlxBitmapFont.SPACE_CODE)
			{
				curX += spaceWidth + letterSpacing;
			}
			else if (charCode == FlxBitmapFont.TAB_CODE)
			{
				curX += tabWidth + letterSpacing;
			}
			else
			{
				charFrame = font.getCharFrame(charCode);
				if (charFrame != null)
				{
					if (isUnicodeComboMark(charCode))
					{
						_flashPoint.setTo(curX - font.getCharAdvance(charCode) - letterSpacing, curY);
					}
					else
					{
						_flashPoint.setTo(curX, curY);
						curX += font.getCharAdvance(charCode) + letterSpacing;
					}
					charFrame.paint(textBitmap, _flashPoint, true);
					charUt8 = new UnicodeBuffer();
					charUt8 = charUt8.addChar(charCode);
				}
			}
		}
	}

	function tileLine(lineIndex:Int, startX:Int, startY:Int):Void
	{
		if (!FlxG.renderTile)
			return;

		var charFrame:FlxFrame;
		var pos:Int = textData.length;

		var charCode:Int;
		var curX:Float = startX;
		var curY:Int = startY;

		var line:String = _lines[lineIndex];
		var spaceWidth:Int = font.spaceWidth;
		var lineLength:Int = line.uLength();
		var textWidth:Int = this.textWidth;

		if (alignment == FlxTextAlign.JUSTIFY)
		{
			var numSpaces:Int = 0;

			for (i in 0...lineLength)
			{
				charCode = line.uCharCodeAt(i);

				if (charCode == FlxBitmapFont.SPACE_CODE)
				{
					numSpaces++;
				}
				else if (charCode == FlxBitmapFont.TAB_CODE)
				{
					numSpaces += numSpacesInTab;
				}
			}

			var lineWidth:Int = getStringWidth(line);
			var totalSpacesWidth:Int = numSpaces * font.spaceWidth;
			spaceWidth = Std.int((textWidth - lineWidth + totalSpacesWidth) / numSpaces);
		}

		var tabWidth:Int = spaceWidth * numSpacesInTab;

		for (i in 0...lineLength)
		{
			charCode = line.uCharCodeAt(i);

			if (charCode == FlxBitmapFont.SPACE_CODE)
			{
				curX += spaceWidth + letterSpacing;
			}
			else if (charCode == FlxBitmapFont.TAB_CODE)
			{
				curX += tabWidth + letterSpacing;
			}
			else
			{
				charFrame = font.getCharFrame(charCode);
				if (charFrame != null)
				{
					textData[pos++] = charCode;
					if (isUnicodeComboMark(charCode))
					{
						textData[pos++] = curX - font.getCharAdvance(charCode) - letterSpacing;
					}
					else
					{
						textData[pos++] = curX;
						curX += font.getCharAdvance(charCode) + letterSpacing;
					}
					textData[pos++] = curY;
				}
			}
		}
	}

	function updatePixels(useTiles:Bool = false):Void
	{
		var colorForFill:Int = background ? backgroundColor : FlxColor.TRANSPARENT;
		var bitmap:BitmapData = null;

		if (FlxG.renderBlit)
		{
			if (pixels == null || (frameWidth != pixels.width || frameHeight != pixels.height))
			{
				pixels = new BitmapData(frameWidth, frameHeight, true, colorForFill);
			}
			else
			{
				pixels.fillRect(graphic.bitmap.rect, colorForFill);
			}

			bitmap = pixels;
		}
		else
		{
			if (!useTiles)
			{
				if (framePixels == null || (frameWidth != framePixels.width || frameHeight != framePixels.height))
				{
					framePixels = FlxDestroyUtil.dispose(framePixels);
					framePixels = new BitmapData(frameWidth, frameHeight, true, colorForFill);
				}
				else
				{
					framePixels.fillRect(framePixels.rect, colorForFill);
				}

				bitmap = framePixels;
			}
			else
			{
				textDrawData.splice(0, textDrawData.length);
				borderDrawData.splice(0, borderDrawData.length);
			}

			width = frameWidth;
			height = frameHeight;

			origin.x = frameWidth * 0.5;
			origin.y = frameHeight * 0.5;
		}

		if (!useTiles)
		{
			bitmap.lock();
		}

		var isFront:Bool = false;

		var iterations:Int = Std.int(borderSize * borderQuality);
		iterations = (iterations <= 0) ? 1 : iterations;

		var delta:Int = Std.int(borderSize / iterations);

		var iterationsX:Int = 1;
		var iterationsY:Int = 1;
		var deltaX:Int = 1;
		var deltaY:Int = 1;

		if (borderStyle == FlxTextBorderStyle.SHADOW)
		{
			iterationsX = Math.round(Math.abs(shadowOffset.x) * borderQuality);
			iterationsX = (iterationsX <= 0) ? 1 : iterationsX;

			iterationsY = Math.round(Math.abs(shadowOffset.y) * borderQuality);
			iterationsY = (iterationsY <= 0) ? 1 : iterationsY;

			deltaX = Math.round(shadowOffset.x / iterationsX);
			deltaY = Math.round(shadowOffset.y / iterationsY);
		}

		// render border
		switch (borderStyle)
		{
			case SHADOW:
				for (iterY in 0...iterationsY)
				{
					for (iterX in 0...iterationsX)
					{
						drawText(deltaX * (iterX + 1), deltaY * (iterY + 1), isFront, bitmap, useTiles);
					}
				}
			case OUTLINE:
				// Render an outline around the text
				// (do 8 offset draw calls)
				var itd:Int = 0;
				for (iter in 0...iterations)
				{
					itd = delta * (iter + 1);
					// upper-left
					drawText(-itd, -itd, isFront, bitmap, useTiles);
					// upper-middle
					drawText(0, -itd, isFront, bitmap, useTiles);
					// upper-right
					drawText(itd, -itd, isFront, bitmap, useTiles);
					// middle-left
					drawText(-itd, 0, isFront, bitmap, useTiles);
					// middle-right
					drawText(itd, 0, isFront, bitmap, useTiles);
					// lower-left
					drawText(-itd, itd, isFront, bitmap, useTiles);
					// lower-middle
					drawText(0, itd, isFront, bitmap, useTiles);
					// lower-right
					drawText(itd, itd, isFront, bitmap, useTiles);
				}
			case OUTLINE_FAST:
				// Render an outline around the text
				// (do 4 diagonal offset draw calls)
				// (this method might not work with certain narrow fonts)
				var itd:Int = 0;
				for (iter in 0...iterations)
				{
					itd = delta * (iter + 1);
					// upper-left
					drawText(-itd, -itd, isFront, bitmap, useTiles);
					// upper-right
					drawText(itd, -itd, isFront, bitmap, useTiles);
					// lower-left
					drawText(-itd, itd, isFront, bitmap, useTiles);
					// lower-right
					drawText(itd, itd, isFront, bitmap, useTiles);
				}
			case NONE:
		}

		isFront = true;
		drawText(0, 0, isFront, bitmap, useTiles);

		if (!useTiles)
		{
			bitmap.unlock();
		}

		if (FlxG.renderBlit)
		{
			dirty = true;
		}

		pendingPixelsChange = false;
	}

	function drawText(posX:Int, posY:Int, isFront:Bool = true, ?bitmap:BitmapData, useTiles:Bool = false):Void
	{
		if (FlxG.renderBlit)
		{
			useTiles = false;
		}

		if (useTiles)
		{
			tileText(posX, posY, isFront);
		}
		else
		{
			blitText(posX, posY, isFront, bitmap);
		}
	}

	function blitText(posX:Int, posY:Int, isFront:Bool = true, ?bitmap:BitmapData):Void
	{
		_matrix.identity();
		_matrix.translate(posX, posY);

		var colorToApply = FlxColor.WHITE;

		if (isFront && useTextColor)
		{
			colorToApply = textColor;
		}
		else if (!isFront)
		{
			colorToApply = borderColor;
		}

		_colorParams.setMultipliers(colorToApply.redFloat, colorToApply.greenFloat, colorToApply.blueFloat, colorToApply.alphaFloat);

		if (isFront && !useTextColor)
		{
			_flashRect.setTo(0, 0, textBitmap.width, textBitmap.height);
			bitmap.copyPixels(textBitmap, _flashRect, _flashPointZero, null, null, true);
		}
		else
		{
			bitmap.draw(textBitmap, _matrix, _colorParams);
		}
	}

	function tileText(posX:Int, posY:Int, isFront:Bool = true):Void
	{
		if (!FlxG.renderTile)
			return;

		var data:Array<Float> = isFront ? textDrawData : borderDrawData;

		var pos:Int = data.length;
		var textPos:Int;
		var textLen:Int = Std.int(textData.length / 3);
		var rect = FlxRect.get();
		var frameVisible;

		for (i in 0...textLen)
		{
			textPos = 3 * i;

			frameVisible = true;

			if (clipRect != null)
			{
				rect.copyFrom(clipRect).offset(-textData[textPos + 1] - posX, -textData[textPos + 2] - posY);
				frameVisible = font.getCharFrame(Std.int(textData[textPos])).clipTo(rect).type != FlxFrameType.EMPTY;
			}

			if (frameVisible)
			{
				data[pos++] = textData[textPos];
				data[pos++] = textData[textPos + 1] + posX;
				data[pos++] = textData[textPos + 2] + posY;
			}
		}

		rect.put();
	}

	/**
	 * Set border's style (shadow, outline, etc), color, and size all in one go!
	 *
	 * @param	Style outline style
	 * @param	Color outline color in flash 0xAARRGGBB format
	 * @param	Size outline size in pixels
	 * @param	Quality outline quality - # of iterations to use when drawing. 0:just 1, 1:equal number to BorderSize
	 */
	public inline function setBorderStyle(Style:FlxTextBorderStyle, Color:FlxColor = 0, Size:Float = 1, Quality:Float = 1):Void
	{
		borderStyle = Style;
		borderColor = Color;
		borderSize = Size;
		borderQuality = Quality;
		if (borderStyle == FlxTextBorderStyle.SHADOW)
		{
			shadowOffset.set(borderSize, borderSize);
		}
		pendingTextBitmapChange = true;
	}

	function get_fieldWidth():Int
	{
		return (autoSize) ? textWidth : _fieldWidth;
	}

	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	function set_fieldWidth(value:Int):Int
	{
		value = (value > 1) ? value : 1;

		if (value != _fieldWidth)
		{
			if (value <= 0)
			{
				autoSize = true;
				wordWrap = false;
			}

			pendingTextChange = true;
		}

		return _fieldWidth = value;
	}

	function set_alignment(value:FlxTextAlign):FlxTextAlign
	{
		if (alignment != value && alignment != FlxTextAlign.JUSTIFY)
		{
			alignment = value;
			pendingTextBitmapChange = true;
		}

		return value;
	}

	function set_multiLine(value:Bool):Bool
	{
		if (multiLine != value)
		{
			multiLine = value;
			pendingTextChange = true;
		}

		return value;
	}

	function set_font(value:FlxBitmapFont):FlxBitmapFont
	{
		if (font != value)
		{
			font = value;
			pendingTextChange = true;
		}

		return value;
	}

	function set_lineSpacing(value:Int):Int
	{
		if (lineSpacing != value)
		{
			lineSpacing = value;
			pendingTextBitmapChange = true;
		}

		return lineSpacing;
	}

	function set_letterSpacing(value:Int):Int
	{
		if (value != letterSpacing)
		{
			letterSpacing = value;
			pendingTextChange = true;
		}

		return letterSpacing;
	}

	function set_autoUpperCase(value:Bool):Bool
	{
		if (autoUpperCase != value)
		{
			autoUpperCase = value;
			pendingTextChange = true;
		}

		return autoUpperCase;
	}

	function set_wordWrap(value:Bool):Bool
	{
		if (wordWrap != value)
		{
			wordWrap = value;
			pendingTextChange = true;
		}

		return wordWrap;
	}

	function set_wrapByWord(value:Bool):Bool
	{
		if (wrapByWord != value)
		{
			wrapByWord = value;
			pendingTextChange = true;
		}

		return value;
	}

	function set_autoSize(value:Bool):Bool
	{
		if (autoSize != value)
		{
			autoSize = value;
			pendingTextChange = true;
		}

		return autoSize;
	}

	function set_padding(value:Int):Int
	{
		if (value != padding)
		{
			padding = value;
			pendingTextChange = true;
		}

		return value;
	}

	function set_numSpacesInTab(value:Int):Int
	{
		if (numSpacesInTab != value && value > 0)
		{
			numSpacesInTab = value;
			pendingTextChange = true;
		}

		return value;
	}

	function set_background(value:Bool):Bool
	{
		if (background != value)
		{
			background = value;
			if (FlxG.renderBlit)
			{
				pendingPixelsChange = true;
			}
		}

		return value;
	}

	function set_backgroundColor(value:Int):Int
	{
		if (backgroundColor != value)
		{
			backgroundColor = value;
			if (FlxG.renderBlit)
			{
				pendingPixelsChange = true;
			}
		}

		return value;
	}

	function set_borderStyle(style:FlxTextBorderStyle):FlxTextBorderStyle
	{
		if (style != borderStyle)
		{
			borderStyle = style;
			pendingTextBitmapChange = true;
		}

		return borderStyle;
	}

	function set_borderColor(value:Int):Int
	{
		if (borderColor != value)
		{
			borderColor = value;
			if (FlxG.renderBlit)
			{
				pendingPixelsChange = true;
			}
		}

		return value;
	}

	function set_borderSize(value:Float):Float
	{
		if (value != borderSize)
		{
			borderSize = value;

			if (borderStyle != FlxTextBorderStyle.NONE)
			{
				pendingTextBitmapChange = true;
			}
		}

		return value;
	}

	function set_borderQuality(value:Float):Float
	{
		value = Math.min(1, Math.max(0, value));

		if (value != borderQuality)
		{
			borderQuality = value;

			if (borderStyle != FlxTextBorderStyle.NONE)
			{
				pendingTextBitmapChange = true;
			}
		}

		return value;
	}

	function get_numLines():Int
	{
		return _lines.length;
	}

	function get_textWidth():Int
	{
		var max:Int = 0;
		var numLines:Int = _lines.length;
		var lineWidth:Int;
		_linesWidth = [];

		for (i in 0...numLines)
		{
			lineWidth = getLineWidth(i);
			_linesWidth[i] = lineWidth;
			max = (max > lineWidth) ? max : lineWidth;
		}

		return max;
	}

	function get_textHeight():Int
	{
		return (lineHeight + lineSpacing) * _lines.length - lineSpacing;
	}

	function get_lineHeight():Int
	{
		return font.lineHeight;
	}

	override function get_width():Float
	{
		checkPendingChanges(true);
		return super.get_width();
	}

	override function get_height():Float
	{
		checkPendingChanges(true);
		return super.get_height();
	}

	/**
	 * Checks if the specified code is one of the Unicode Combining Diacritical Marks
	 * @param	Code	The charactercode we want to check
	 * @return 	Bool	Returns true if the code is a Unicode Combining Diacritical Mark
	 */
	function isUnicodeComboMark(Code:Int):Bool
	{
		return ((Code >= 768 && Code <= 879) || (Code >= 6832 && Code <= 6911) || (Code >= 7616 && Code <= 7679) || (Code >= 8400 && Code <= 8447)
			|| (Code >= 65056 && Code <= 65071));
	}
}
