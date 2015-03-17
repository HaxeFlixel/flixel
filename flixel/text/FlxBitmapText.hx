package flixel.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxGlyphFrame;
import flixel.graphics.tile.FlxDrawTilesItem;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.text.FlxText.FlxTextAlign;
import flixel.math.FlxAngle;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.Utf8;
import openfl.geom.ColorTransform;

// TODO: use Utf8 util for converting text to upper/lower case

/**
 * Extends FlxSprite to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 */
class FlxBitmapText extends FlxSprite
{
	private static var COLOR_TRANSFORM:ColorTransform = new ColorTransform();
	
	/**
	 * Font for text rendering.
	 */
	public var font(default, set):FlxBitmapFont;
	
	/**
	 * Text to display.
	 */
	public var text(default, set):String = "";
	
	/**
	 * Helper array which contains actual strings for rendering.
	 */
	// TODO: switch it to Array<Array<Int>> (for optimizations - i.e. less Utf8 usage)
	private var _lines:Array<String> = [];
	/**
	 * Helper array which contains width of each displayed lines.
	 */
	private var _linesWidth:Array<Int> = [];
	
	/**
	 * Specifies how the text field should align text.
	 * JUSTIFY alignment isn't supported.
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
	public var textWidth(get, null):Int;
	
	/**
	 * Height of the text in this text field.
	 */
	public var textHeight(get, null):Int;
	
	/**
	 * Height of the single line of text (without lineSpacing).
	 */
	public var lineHeight(get, null):Int;
	
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
	public var numLines(get, null):Int = 0;
	
	/**
	 * The width of the TextField object used for bitmap generation for this FlxText object.
	 * Use it when you want to change the visible width of text. Enables autoSize if <= 0.
	 */
	public var fieldWidth(get, set):Int;
	
	private var _fieldWidth:Int;
	
	private var pendingTextChange:Bool = true;
	private var pendingTextBitmapChange:Bool = true;
	private var pendingPixelsChange:Bool = true;
	
	#if FLX_RENDER_TILE
	private var textData:Array<Float>;
	private var textDrawData:Array<Float>;
	private var borderDrawData:Array<Float>;
	#end
	
	/**
	 * Helper bitmap buffer for text pixels but without any color transformations
	 */
	private var textBitmap:BitmapData;
	
	/**
	 * Constructs a new text field component.
	 * @param 	font	Optional parameter for component's font prop
	 */
	public function new(?font:FlxBitmapFont) 
	{
		super();
		
		width = fieldWidth = 2;
		alpha = 1;
		
		this.font = (font == null) ? FlxBitmapFont.getDefaultFont() : font;
		
		shadowOffset = FlxPoint.get(1, 1);
		
		#if FLX_RENDER_BLIT
		pixels = new BitmapData(1, 1, true, FlxColor.TRANSPARENT);
		#else
		textData = [];
		
		textDrawData = [];
		borderDrawData = [];
		#end
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
		
		#if FLX_RENDER_TILE
		textData = null;
		textDrawData = null;
		borderDrawData = null;
		#end
		super.destroy();
	}
	
	/**
	 * Forces graphic regeneration for this text field.
	 */
	override public function drawFrame(Force:Bool = false):Void 
	{
		#if FLX_RENDER_TILE
		Force = true;
		#end
		pendingTextBitmapChange = pendingTextBitmapChange || Force;
		checkPendingChanges(false);
		#if FLX_RENDER_BLIT
		super.drawFrame(Force);
		#end
	}
	
	inline private function checkPendingChanges(useTiles:Bool = false):Void
	{
		#if FLX_RENDER_BLIT
		useTiles = false;
		#end
		
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
	
	#if FLX_RENDER_BLIT
	override public function draw():Void 
	{
		checkPendingChanges(false);
		super.draw();
	}
	#else
	override public function draw():Void 
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
				_matrix.scale(0.1 * frameWidth, 0.1 * frameHeight);
				_matrix.translate(-ox, -oy);
				_matrix.scale(sx, sy);
				
				if (angle != 0)
				{
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}
				
				_matrix.translate(_point.x + ox, _point.y + oy);
				camera.drawPixels(currFrame, null, _matrix, bgRed, bgGreen, bgBlue, bgAlpha, blend, antialiasing);
			}
			
			drawItem = camera.startQuadBatch(font.parent, true, blend, antialiasing);
			
			for (j in 0...borderLength)
			{
				dataPos = j * 3;
				
				currFrame = font.glyphs.get(Std.int(borderDrawData[dataPos]));
				
				currTileX = borderDrawData[dataPos + 1];
				currTileY = borderDrawData[dataPos + 2];
				
				currFrame.prepareMatrix(_matrix);
				_matrix.translate(currTileX - ox, currTileY - oy);
				_matrix.scale(sx, sy);
				if (angle != 0)
				{
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}
				
				_matrix.translate(_point.x + ox, _point.y + oy);
				
				drawItem.setData(currFrame, _matrix, borderRed, borderGreen, borderBlue, bAlpha);
			}
			
			for (j in 0...textLength)
			{
				dataPos = j * 3;
				
				currFrame = font.glyphs.get(Std.int(textDrawData[dataPos]));
				
				currTileX = textDrawData[dataPos + 1];
				currTileY = textDrawData[dataPos + 2];
				
				currFrame.prepareMatrix(_matrix);
				_matrix.translate(currTileX - ox, currTileY - oy);
				_matrix.scale(sx, sy);
				if (angle != 0)
				{
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}
				
				_matrix.translate(_point.x + ox, _point.y + oy);
				
				drawItem.setData(currFrame, _matrix, textRed, textGreen, textBlue, tAlpha);
			}
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			drawDebug();
		}
		#end
	}
	
	override private function set_color(Color:FlxColor):FlxColor
	{
		super.set_color(Color);
		#if FLX_RENDER_BLIT
		pendingTextBitmapChange = true;
		#end
		return color;
	}
	
	override private function set_alpha(value:Float):Float
	{
		alpha = value;
		#if FLX_RENDER_BLIT
		pendingTextBitmapChange = true;
		#end
		return value;
	}
	#end
	
	private function set_textColor(value:FlxColor):FlxColor 
	{
		if (textColor != value)
		{
			textColor = value;
			#if FLX_RENDER_BLIT
			pendingPixelsChange = true;
			#end
		}
		
		return value;
	}
	
	private function set_useTextColor(value:Bool):Bool 
	{
		if (useTextColor != value)
		{
			useTextColor = value;
			#if FLX_RENDER_BLIT
			pendingPixelsChange = true;
			#end
		}
		
		return value;
	}
	
	#if FLX_RENDER_TILE
	override private function calcFrame(RunOnCpp:Bool = false):Void 
	{
		drawFrame(RunOnCpp);
	}
	#end
	
	private function set_text(value:String):String 
	{
		if (value != text)
		{
			text = value;
			pendingTextChange = true;
		}
		
		return value;
	}
	
	private function updateText():Void 
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
		
		pendingTextChange = false;
		pendingTextBitmapChange = true;
	}
	
	/**
	 * Calculates the size of text field.
	 */
	private function computeTextSize():Void 
	{
		var txtWidth:Int = textWidth;
		var txtHeight:Int = textHeight + 2 * padding;
		
		if (autoSize)
		{
			txtWidth += 2 * padding;
		}
		else
		{
			txtWidth = fieldWidth;
		}
		
		frameWidth = txtWidth;
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
	 * Calculates width of provided string (for current font with fontScale).
	 * 
	 * @param	str	String to calculate width for
	 * @return	The width of result bitmap text.
	 */
	public function getStringWidth(str:String):Int
	{
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var lineLength:Int = Utf8.length(str);	// lenght of the current line
		var lineWidth:Int = font.minOffsetX;
		
		var charCode:Int;						// current character in word
		var charWidth:Int;						// the width of current character
		
		var widthPlusOffset:Int;
		var glyphFrame:FlxGlyphFrame;
		
		for (c in 0...lineLength)
		{
			charCode = Utf8.charCodeAt(str, c);
			charWidth = 0;
			
			if (charCode == FlxBitmapFont.spaceCode)
			{
				charWidth = spaceWidth;
			}
			else if (charCode == FlxBitmapFont.tabCode)
			{
				charWidth = tabWidth;
			}
			else if (font.glyphs.exists(charCode))
			{
				glyphFrame = font.glyphs.get(charCode);
				charWidth = glyphFrame.xAdvance;
				
				if (c == (lineLength - 1))
				{
					widthPlusOffset = Std.int(glyphFrame.offset.x + glyphFrame.frame.width);
					if (widthPlusOffset > charWidth)
					{
						charWidth = widthPlusOffset;
					}
				}
			}
			
			lineWidth += (charWidth + letterSpacing);
		}
		
		if (lineLength > 0)
		{
			lineWidth -= letterSpacing;
		}
		
		return lineWidth;
	}
	
	/**
	 * Just cuts the lines which are too long to fit in the field.
	 */
	private function cutLines():Void 
	{
		var newLines:Array<String> = [];
		
		var lineLength:Int;			// lenght of the current line
		
		var c:Int;					// char index
		var charCode:Int;			// code for the current character in word
		var charWidth:Int;			// the width of current character
		
		var subLine:Utf8;			// current subline to assemble
		var subLineWidth:Int;		// the width of current subline
		
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var startX:Int = font.minOffsetX;
		
		for (line in _lines)
		{
			lineLength = Utf8.length(line);
			subLine = new Utf8();
			subLineWidth = startX;
			
			c = 0;
			while (c < lineLength)
			{
				charCode = Utf8.charCodeAt(line, c);
				
				if (charCode == FlxBitmapFont.spaceCode)
				{
					charWidth = spaceWidth;
				}
				else if (charCode == FlxBitmapFont.tabCode)
				{
					charWidth = tabWidth;
				}
				else
				{
					charWidth = font.glyphs.exists(charCode) ? font.glyphs.get(charCode).xAdvance : 0;
				}
				charWidth += letterSpacing;
				
				if (subLineWidth + charWidth > _fieldWidth - 2 * padding)
				{
					subLine.addChar(charCode);
					newLines.push(subLine.toString());
					subLine = new Utf8();
					subLineWidth = startX;
					c = lineLength;
				}
				else
				{
					subLine.addChar(charCode);
					subLineWidth += charWidth;
				}
				
				c++;
			}
		}
		
		_lines = newLines;
	}
	
	/**
	 * Automatically wraps text by figuring out how many characters can fit on a
	 * single line, and splitting the remainder onto a new line.
	 */
	private function wrap():Void
	{
		// subdivide lines
		var newLines:Array<String> = [];
		var words:Array<String>;			// the array of words in the current line
		
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
	private function splitLineIntoWords(line:String, words:Array<String>):Void
	{
		var word:String = "";				// current word to process
		var wordUtf8:Utf8 = new Utf8();
		var isSpaceWord:Bool = false; 		// whether current word consists of spaces or not
		var lineLength:Int = Utf8.length(line);	// lenght of the current line
		
		var hyphenCode:Int = Utf8.charCodeAt('-', 0);
		
		var c:Int = 0;						// char index on the line
		var charCode:Int; 					// code for the current character in word
		var charUtf8:Utf8;
		
		while (c < lineLength)
		{
			charCode = Utf8.charCodeAt(line, c);
			word = wordUtf8.toString();
			
			if (charCode == FlxBitmapFont.spaceCode || charCode == FlxBitmapFont.tabCode)
			{
				if (!isSpaceWord)
				{
					isSpaceWord = true;
					
					if (word != "")
					{
						words.push(word);
						wordUtf8 = new Utf8();
					}
				}
				
				wordUtf8.addChar(charCode);
			}
			else if (charCode == hyphenCode)
			{
				if (isSpaceWord && word != "")
				{
					isSpaceWord = false;
					words.push(word);
					words.push('-');
				}
				else if (isSpaceWord == false)
				{
					charUtf8 = new Utf8();
					charUtf8.addChar(charCode);
					words.push(word + charUtf8.toString());
				}
				
				wordUtf8 = new Utf8();
			}
			else
			{
				if (isSpaceWord && word != "")
				{
					isSpaceWord = false;
					words.push(word);
					wordUtf8 = new Utf8();
				}
				
				wordUtf8.addChar(charCode);
			}
			
			c++;
		}
		
		word = wordUtf8.toString();
		if (word != "") words.push(word);
	}
	
	/**
	 * Wraps provided line by words.
	 * 
	 * @param	words		The array of words in the line to process.
	 * @param	newLines	Array to fill with result lines.
	 */
	private function wrapLineByWord(words:Array<String>, newLines:Array<String>):Void
	{
		var numWords:Int = words.length;	// number of words in the current line
		var w:Int;							// word index in the current line
		var word:String;					// current word to process
		var wordWidth:Int;					// total width of current word
		var wordLength:Int;					// number of letters in current word
		
		var isSpaceWord:Bool = false; 		// whether current word consists of spaces or not
		
		var charCode:Int;
		var charWidth:Int = 0;				// the width of current character
		
		var subLines:Array<String> = [];	// helper array for subdividing lines
		
		var subLine:String;					// current subline to assemble
		var subLineWidth:Int;				// the width of current subline
		
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
				wordLength = Utf8.length(word);
				
				charCode = Utf8.charCodeAt(word, 0);
				isSpaceWord = (charCode == FlxBitmapFont.spaceCode || charCode == FlxBitmapFont.tabCode);
				
				for (c in 0...wordLength)
				{
					charCode = Utf8.charCodeAt(word, c);
					
					if (charCode == FlxBitmapFont.spaceCode)
					{
						charWidth = spaceWidth;
					}
					else if (charCode == FlxBitmapFont.tabCode)
					{
						charWidth = tabWidth;
					}
					else
					{
						charWidth = font.glyphs.exists(charCode) ? font.glyphs.get(charCode).xAdvance : 0;
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
					else					// the line is too tight to hold even one word
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
	private function wrapLineByCharacter(words:Array<String>, newLines:Array<String>):Void
	{
		var numWords:Int = words.length;	// number of words in the current line
		var w:Int;							// word index in the current line
		var word:String;					// current word to process
		var wordLength:Int;					// number of letters in current word
		
		var isSpaceWord:Bool = false; 		// whether current word consists of spaces or not
		
		var charCode:Int;
		var c:Int;							// char index
		var charWidth:Int = 0;				// the width of current character
		
		var subLines:Array<String> = [];	// helper array for subdividing lines
		
		var subLine:String;					// current subline to assemble
		var subLineUtf8:Utf8;
		var subLineWidth:Int;				// the width of current subline
		
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var startX:Int = font.minOffsetX;
		
		if (numWords > 0)
		{
			w = 0;
			subLineWidth = startX;
			subLineUtf8 = new Utf8();
			
			while (w < numWords)
			{
				word = words[w];
				wordLength = Utf8.length(word);
				
				charCode = Utf8.charCodeAt(word, 0);
				isSpaceWord = (charCode == FlxBitmapFont.spaceCode || charCode == FlxBitmapFont.tabCode);
				
				c = 0;
				
				while (c < wordLength)
				{
					charCode = Utf8.charCodeAt(word, c);
					
					if (charCode == FlxBitmapFont.spaceCode)
					{
						charWidth = spaceWidth;
					}
					else if (charCode == FlxBitmapFont.tabCode)
					{
						charWidth = tabWidth;
					}
					else
					{
						charWidth = font.glyphs.exists(charCode) ? font.glyphs.get(charCode).xAdvance : 0;
					}
					
					if (subLineWidth + charWidth > _fieldWidth - 2 * padding)
					{
						subLine = subLineUtf8.toString();
						
						if (isSpaceWord) // new line ends with space / tab char, so we push it to sublines array, skip all the rest spaces and start another line
						{
							subLines.push(subLine);
							c = wordLength;
							subLineUtf8 = new Utf8();
							subLineWidth = startX;
						}
						else if (subLine != "") // new line isn't empty so we should add it to sublines array and start another one
						{
							subLines.push(subLine);
							subLineUtf8 = new Utf8();
							subLineUtf8.addChar(charCode);
							subLineWidth = startX + charWidth + letterSpacing;
						}
						else	// the line is too tight to hold even one glyph
						{
							subLineUtf8 = new Utf8();
							subLineUtf8.addChar(charCode);
							subLineWidth = startX + charWidth + letterSpacing;
						}
					}
					else
					{
						subLineUtf8.addChar(charCode);
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
	private function updateTextBitmap(useTiles:Bool = false):Void 
	{
		computeTextSize();
		
		#if FLX_RENDER_BLIT
		useTiles = false;
		#end
		
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
		#if FLX_RENDER_TILE
		else
		{
			textData.splice(0, textData.length);
		}
		#end
		
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
				ox += Std.int((frameWidth - lineWidth) / 2) - padding;
			}
			else if (alignment == FlxTextAlign.RIGHT) 
			{
				ox += (frameWidth - lineWidth) - padding;
			}
			else	// LEFT
			{
				ox += padding;
			}
			
			drawLine(line, ox, oy, useTiles);
		}
		
		if (!useTiles)
		{
			textBitmap.unlock();
		}
		
		pendingTextBitmapChange = false;
	}
	
	private function drawLine(line:String, posX:Int, posY:Int, useTiles:Bool = false):Void
	{
		#if FLX_RENDER_BLIT
		useTiles = false;
		#end
		
		if (useTiles)
		{
			tileLine(line, posX, posY);
		}
		else
		{
			blitLine(line, posX, posY);
		}
	}
	
	private function blitLine(line:String, startX:Int, startY:Int):Void
	{
		var glyph:FlxGlyphFrame;
		var charCode:Int;
		var curX:Int = startX;
		var curY:Int = startY;
		
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var lineLength:Int = Utf8.length(line);
		
		for (i in 0...lineLength)
		{
			charCode = Utf8.charCodeAt(line, i);
			
			if (charCode == FlxBitmapFont.spaceCode)
			{
				curX += spaceWidth;
			}
			else if (charCode == FlxBitmapFont.tabCode)
			{
				curX += tabWidth;
			}
			else
			{
				glyph = font.glyphs.get(charCode);
				if (glyph != null)
				{
					_flashPoint.setTo(curX, curY);
					glyph.paint(textBitmap, _flashPoint, true);
					curX += glyph.xAdvance;
				}
			}
			
			curX += letterSpacing;
		}
	}
	
	private function tileLine(line:String, startX:Int, startY:Int):Void
	{
		#if FLX_RENDER_TILE
		var glyph:FlxGlyphFrame;
		var pos:Int = textData.length;
		
		var charCode:Int;
		var curX:Int = startX;
		var curY:Int = startY;
		
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var lineLength:Int = Utf8.length(line);
		
		for (i in 0...lineLength)
		{
			charCode = Utf8.charCodeAt(line, i);
			
			if (charCode == FlxBitmapFont.spaceCode)
			{
				curX += spaceWidth;
			}
			else if (charCode == FlxBitmapFont.tabCode)
			{
				curX += tabWidth;
			}
			else
			{
				glyph = font.glyphs.get(charCode);
				if (glyph != null)
				{
					textData[pos++] = charCode;
					textData[pos++] = curX;
					textData[pos++] = curY;
					curX += glyph.xAdvance;
				}
			}
			
			curX += letterSpacing;
		}
		#end
	}
	
	private function updatePixels(useTiles:Bool = false):Void
	{
		var colorForFill:Int = background ? backgroundColor : FlxColor.TRANSPARENT;
		var bitmap:BitmapData = null;
		
		#if FLX_RENDER_BLIT
		if (pixels == null || (frameWidth != pixels.width || frameHeight != pixels.height))
		{
			pixels = new BitmapData(frameWidth, frameHeight, true, colorForFill);
		}
		else
		{
			pixels.fillRect(graphic.bitmap.rect, colorForFill);
		}
		
		bitmap = pixels;
		#else
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
		#end
		
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
				//Render an outline around the text
				//(do 8 offset draw calls)
				var itd:Int = 0;
				for (iter in 0...iterations)
				{
					itd = delta * (iter + 1);
					//upper-left
					drawText( -itd, -itd, isFront, bitmap, useTiles);
					//upper-middle
					drawText(0, -itd, isFront, bitmap, useTiles);
					//upper-right
					drawText(itd, -itd, isFront, bitmap, useTiles);
					//middle-left
					drawText( -itd, 0, isFront, bitmap, useTiles);
					//middle-right
					drawText(itd, 0, isFront, bitmap, useTiles);
					//lower-left
					drawText( -itd, itd, isFront, bitmap, useTiles);
					//lower-middle
					drawText(0, itd, isFront, bitmap, useTiles);
					//lower-right
					drawText(itd, itd, isFront, bitmap, useTiles);
				}
			case OUTLINE_FAST:
				//Render an outline around the text
				//(do 4 diagonal offset draw calls)
				//(this method might not work with certain narrow fonts)
				var itd:Int = 0;
				for (iter in 0...iterations)
				{
					itd = delta * (iter + 1);
					//upper-left
					drawText( -itd, -itd, isFront, bitmap, useTiles);
					//upper-right
					drawText(itd, -itd, isFront, bitmap, useTiles);
					//lower-left
					drawText( -itd, itd, isFront, bitmap, useTiles);
					//lower-right
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
		
		#if FLX_RENDER_BLIT
		dirty = true;
		#end
		
		pendingPixelsChange = false;
	}
	
	private function drawText(posX:Int, posY:Int, isFront:Bool = true, bitmap:BitmapData = null, useTiles:Bool = false):Void
	{
		#if FLX_RENDER_BLIT
		useTiles = false;
		#end
		
		if (useTiles)
		{
			tileText(posX, posY, isFront);
		}
		else
		{
			blitText(posX, posY, isFront, bitmap);
		}
	}
	
	private function blitText(posX:Int, posY:Int, isFront:Bool = true, bitmap:BitmapData = null):Void
	{
		_matrix.identity();
		_matrix.translate(posX, posY);
		
		var colorToApply:FlxColor = FlxColor.WHITE;
		
		if (isFront && useTextColor)
		{
			colorToApply = textColor;
		}
		else if (!isFront)
		{
			colorToApply = borderColor;
		}
		
		var cTrans:ColorTransform = COLOR_TRANSFORM;
		cTrans.redMultiplier = colorToApply.redFloat;
		cTrans.greenMultiplier = colorToApply.greenFloat;
		cTrans.blueMultiplier = colorToApply.blueFloat;
		cTrans.alphaMultiplier = colorToApply.alphaFloat;
		
		if (isFront && !useTextColor)
		{
			_flashRect.setTo(0, 0, textBitmap.width, textBitmap.height);
			bitmap.copyPixels(textBitmap, _flashRect, _flashPointZero, null, null, true);
		}
		else
		{
			bitmap.draw(textBitmap, _matrix, cTrans);
		}
	}
	
	private function tileText(posX:Int, posY:Int, isFront:Bool = true):Void
	{
		#if FLX_RENDER_TILE
		var data:Array<Float> = isFront ? textDrawData : borderDrawData;
		
		var pos:Int = data.length;
		var textPos:Int;
		var textLen:Int = Std.int(textData.length / 3);
		
		for (i in 0...textLen)
		{
			textPos = 3 * i;
			data[pos++] = textData[textPos];
			data[pos++] = textData[textPos + 1] + posX;
			data[pos++] = textData[textPos + 2] + posY;
		}
		#end
	}
	
	/**
	 * Set border's style (shadow, outline, etc), color, and size all in one go!
	 * 
	 * @param	Style outline style
	 * @param	Color outline color in flash 0xRRGGBB format
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
	
	private function get_fieldWidth():Int
	{
		return (autoSize) ? textWidth : _fieldWidth;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	private function set_fieldWidth(value:Int):Int
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
	
	private function set_alignment(value:FlxTextAlign):FlxTextAlign 
	{
		if (alignment != value && alignment != FlxTextAlign.JUSTIFY)
		{
			alignment = value;
			pendingTextBitmapChange = true;
		}
		
		return value;
	}
	
	private function set_multiLine(value:Bool):Bool 
	{
		if (multiLine != value)
		{
			multiLine = value;
			pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_font(value:FlxBitmapFont):FlxBitmapFont 
	{
		if (font != value)
		{
			font = value;
			pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_lineSpacing(value:Int):Int
	{
		if (lineSpacing != value)
		{
			lineSpacing = (value >= 0) ? value : -value;
			pendingTextBitmapChange = true;
		}
		
		return lineSpacing;
	}
	
	private function set_letterSpacing(value:Int):Int
	{
		var tmp:Int = (value >= 0) ? value : -value;
		
		if (tmp != letterSpacing)
		{
			letterSpacing = tmp;
			pendingTextChange = true;
		}
		
		return letterSpacing;
	}
	
	private function set_autoUpperCase(value:Bool):Bool 
	{
		if (autoUpperCase != value)
		{
			autoUpperCase = value;
			pendingTextChange = true;
		}
		
		return autoUpperCase;
	}
	
	private function set_wordWrap(value:Bool):Bool 
	{
		if (wordWrap != value)
		{
			wordWrap = value;
			pendingTextChange = true;
		}
		
		return wordWrap;
	}
	
	private function set_wrapByWord(value:Bool):Bool
	{
		if (wrapByWord != value)
		{
			wrapByWord = value;
			pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_autoSize(value:Bool):Bool 
	{
		if (autoSize != value)
		{
			autoSize = value;
			pendingTextChange = true;
		}
		
		return autoSize;
	}
	
	private function set_padding(value:Int):Int
	{
		if (value != padding)
		{
			padding = value;
			pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_numSpacesInTab(value:Int):Int 
	{
		if (numSpacesInTab != value && value > 0)
		{
			numSpacesInTab = value;
			pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_background(value:Bool):Bool
	{
		if (background != value)
		{
			background = value;
			#if FLX_RENDER_BLIT
			pendingPixelsChange = true;
			#end
		}
		
		return value;
	}
	
	private function set_backgroundColor(value:Int):Int 
	{
		if (backgroundColor != value)
		{
			backgroundColor = value;
			#if FLX_RENDER_BLIT
			pendingPixelsChange = true;
			#end
		}
		
		return value;
	}
	
	private function set_borderStyle(style:FlxTextBorderStyle):FlxTextBorderStyle
	{		
		if (style != borderStyle)
		{
			borderStyle = style;
			pendingTextBitmapChange = true;
		}
		
		return borderStyle;
	}
	
	private function set_borderColor(value:Int):Int 
	{
		if (borderColor != value)
		{
			borderColor = value;
			#if FLX_RENDER_BLIT
			pendingPixelsChange = true;
			#end
		}
		
		return value;
	}
	
	private function set_borderSize(value:Float):Float
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
	
	private function set_borderQuality(value:Float):Float
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
	
	private function get_numLines():Int
	{
		return _lines.length;
	}
	
	/**
	 * Calculates maximum width of the text.
	 * 
	 * @return	text width.
	 */
	private function get_textWidth():Int
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
	
	private function get_textHeight():Int
	{
		return (lineHeight + lineSpacing) * _lines.length - lineSpacing;
	}
	
	private function get_lineHeight():Int
	{
		return font.lineHeight;
	}
	
	override private function get_width():Float 
	{
		checkPendingChanges(true);
		return super.get_width();
	}
	
	override private function get_height():Float 
	{
		checkPendingChanges(true);
		return super.get_height();
	}
}