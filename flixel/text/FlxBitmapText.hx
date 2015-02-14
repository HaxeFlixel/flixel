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

// TODO: make pixels accessible in tile render mode also...
// TODO: use Utf8 util for converting text to upper/lower case

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
	 * Helper array which contains actual strings for rendering.
	 */
	// TODO: switch it to Array<Array<Int>> (for optimizations - i.e. less Utf8 usage)
	private var _lines:Array<String> = [];
	/**
	 * Helper array which contains width of each displayed lines.
	 */
	private var _linesWidth:Array<Float> = [];
	
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
	public var textWidth(get, null):Float;
	
	/**
	 * Height of the text in this text field.
	 */
	public var textHeight(get, null):Float;
	
	/**
	 * Height of the single line of text (without lineSpacing).
	 */
	public var lineHeight(get, null):Float;
	
	/**
	 * Number of space characters in one tab.
	 */
	public var numSpacesInTab(default, set):Int = 4;
	
	/**
	 * The color of the text in 0xAARRGGBB format.
	 * Result color of text will be multiplication of textColor and color.
	 */
	public var textColor(default, set):FlxColor = 0xFFFFFFFF;
	
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
	public var fieldWidth(get, set):Float;
	
	private var _fieldWidth:Float;
	
	private var pendingTextChange:Bool = true;
	private var pendingGraphicChange:Bool = true;
	private var pendingColorChange:Bool = true;
	#if FLX_RENDER_TILE
	private var textData:Array<Float>;
	
	private var textDrawData:Array<Float>;
	private var borderDrawData:Array<Float>;
	private var tilePoint:FlxPoint;
	private var tileMatrix:FlxMatrix;
	private var bgMatrix:FlxMatrix;
	#else
	private var textBitmap:BitmapData;
	#end
	
	/**
	 * Constructs a new text field component.
	 * @param 	font	Optional parameter for component's font prop
	 */
	public function new(?font:FlxBitmapFont) 
	{
		super();
		
		fieldWidth = width = 2;
		alpha = 1;
		
		this.font = (font == null) ? FlxBitmapFont.getDefaultFont() : font;
		
		shadowOffset = FlxPoint.get(1, 1);
		
		#if FLX_RENDER_BLIT
		pixels = new BitmapData(1, 1, true, FlxColor.TRANSPARENT);
		#else
		textData = [];
		
		textDrawData = [];
		borderDrawData = [];
		tilePoint = new FlxPoint();
		tileMatrix = new FlxMatrix();
		bgMatrix = new FlxMatrix();
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
		
		#if FLX_RENDER_TILE
		textData = null;
		
		textDrawData = null;
		borderDrawData = null;
		tilePoint = null;
		tileMatrix = null;
		bgMatrix = null;
		#else
		textBitmap = FlxDestroyUtil.dispose(textBitmap);
		#end
		super.destroy();
	}
	
	/**
	 * Forces graphic regeneration for this text field.
	 */
	override public function drawFrame(Force:Bool = false):Void 
	{
		pendingGraphicChange = pendingGraphicChange || Force;
		checkPendingChanges();
		#if FLX_RENDER_BLIT
		super.drawFrame(Force);
		#end
	}
	
	inline private function checkPendingChanges():Void
	{
		if (pendingTextChange)
		{
			updateText();
			pendingGraphicChange = true;
		}
		
		// TODO: continue from here...
		
		if (pendingGraphicChange)
		{
			updateTextBitmap();
			pendingColorChange = true;
		}
		
		if (pendingColorChange)
		{
			updateTextGraphic();
		}
	}
	
	#if FLX_RENDER_BLIT
	override public function draw():Void 
	{
		checkPendingChanges();
		super.draw();
	}
	#else
	override public function draw():Void 
	{
		checkPendingChanges();
		
		var textLength:Int = Std.int(textDrawData.length / 3);
		var borderLength:Int = Std.int(borderDrawData.length / 3);
		
		var dataPos:Int;
		
		var borderRed:Float = borderColor.redFloat * color.redFloat;
		var borderGreen:Float = borderColor.greenFloat * color.greenFloat;
		var borderBlue:Float = borderColor.blueFloat * color.blueFloat;
		var bAlpha:Float = borderColor.alphaFloat * alpha;
		var bColor:FlxColor = FlxColor.fromRGBFloat(borderRed, borderGreen, borderBlue);
		
		var textRed:Float = color.redFloat;
		var textGreen:Float = color.greenFloat;
		var textBlue:Float = color.blueFloat;
		var tAlpha:Float = alpha;
		
		if (useTextColor)
		{
			textRed *= textColor.redFloat;
			textGreen *= textColor.greenFloat;
			textBlue *= textColor.blueFloat;
			tAlpha *= textColor.alpha;		
		}
		
		var tColor:FlxColor = FlxColor.fromRGBFloat(textRed, textGreen, textBlue); 
		
		var alphaToUse:Float = 0;
		
		var drawItem:FlxDrawTilesItem;
		var currFrame:FlxFrame = null;
		var currTileX:Float = 0;
		var currTileY:Float = 0;
		var sx:Float = scale.x * _facingHorizontalMult;
		var sy:Float = scale.y * _facingVerticalMult;
		
		var bgAlpha:Float = backgroundColor.alphaFloat * alpha;
		
		var totalScaleX:Float, totalScaleY:Float;
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
			{
				continue;
			}
			
			updateTrig();
			
			totalScaleX = sx;
			totalScaleY = sy;
			
			// matrix for calculation tile position
			_matrix.identity();
			_matrix.scale(totalScaleX, totalScaleY);
			
			if (angle != 0)
			{
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}
			
			// matrix for calculation tile transformations
			tileMatrix.identity();
			tileMatrix.scale(totalScaleX, totalScaleY);
			if (angle != 0)
			{
				tileMatrix.rotateWithTrig(_cosAngle, _sinAngle);
			}
			
			if (background)
			{
				// backround tile transformations
				bgMatrix.identity();
				bgMatrix.scale(0.1 * frameWidth * totalScaleX, 0.1 * frameHeight * totalScaleY);
				
				if (angle != 0)
				{
					bgMatrix.rotateWithTrig(_cosAngle, _sinAngle);
				}
			}
			
			getScreenPosition(_point, camera).subtractPoint(offset).addPoint(origin);
			
			_point.x *= camera.totalScaleX;
			_point.y *= camera.totalScaleY;
			
			if (isPixelPerfectRender(camera))
			{
				_point.floor();
			}
			
			if (background)
			{
				drawItem = camera.getDrawTilesItem(FlxG.bitmap.whitePixel.parent, true, blend, antialiasing);
				currFrame = FlxG.bitmap.whitePixel;
				
				bgMatrix.translate(_point.x, _point.y);
				
				drawItem.setData(currFrame.frame, currFrame.origin, bgMatrix, true, backgroundColor.to24Bit(), bgAlpha * camera.alpha);
			}
			
			drawItem = camera.getDrawTilesItem(font.parent, true, blend, antialiasing);
			
			alphaToUse = bAlpha * camera.alpha;
			
			for (j in 0...borderLength)
			{
				dataPos = j * 3;
				
				currFrame = font.glyphs.get(Std.int(borderDrawData[dataPos]));
				
				currTileX = borderDrawData[dataPos + 1];
				currTileY = borderDrawData[dataPos + 2];
				
				tilePoint.set(currTileX, currTileY);
				tilePoint.transform(_matrix);
				tilePoint.addPoint(_point);
				
				tileMatrix.tx = tilePoint.x;
				tileMatrix.ty = tilePoint.y;
				
				drawItem.setData(currFrame.frame, currFrame.origin, tileMatrix, true, bColor, alphaToUse);
			}
			
			alphaToUse = tAlpha * camera.alpha;
			
			for (j in 0...textLength)
			{
				dataPos = j * 3;
				
				currFrame = font.glyphs.get(Std.int(textDrawData[dataPos]));
				
				currTileX = textDrawData[dataPos + 1];
				currTileY = textDrawData[dataPos + 2];
				
				tilePoint.set(currTileX, currTileY);
				tilePoint.transform(_matrix);
				tilePoint.addPoint(_point);
				
				tileMatrix.tx = tilePoint.x;
				tileMatrix.ty = tilePoint.y;
				
				drawItem.setDrawData(currFrame.frame, currFrame.origin, tileMatrix, true, tColor, alphaToUse);
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
		pendingGraphicChange = true;
		return color;
	}
	
	override private function set_alpha(value:Float):Float
	{
		alpha = value;
		pendingGraphicChange = true;
		return value;
	}
	#end
	
	private function set_textColor(value:FlxColor):FlxColor 
	{
		if (textColor != value)
		{
			textColor = value;
			pendingColorChange = true;
		}
		
		return value;
	}
	
	private function set_useTextColor(value:Bool):Bool 
	{
		if (useTextColor != value)
		{
			useTextColor = value;
			pendingColorChange = true;
		}
		
		return value;
	}
	
	// TODO: override calcFrame (maybe)
	
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
		pendingGraphicChange = true;
	}
	
	/**
	 * Calculates the size of text field.
	 */
	private function computeTextSize():Void 
	{
		var txtWidth:Int = Math.ceil(textWidth);
		var txtHeight:Int = Math.ceil(textHeight) + 2 * padding;
		
		if (autoSize)
		{
			txtWidth += 2 * padding;
		}
		else
		{
			txtWidth = Math.ceil(fieldWidth);
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
	public function getLineWidth(lineIndex:Int):Float
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
	public function getStringWidth(str:String):Float
	{
		var spaceWidth:Float = font.spaceWidth;
		var tabWidth:Float = spaceWidth * numSpacesInTab;
		
		var lineLength:Int = Utf8.length(str);	// lenght of the current line
		var lineWidth:Float = Math.abs(font.minOffsetX);
		
		var charCode:Int;						// current character in word
		var charWidth:Float = 0;				// the width of current character
		
		var widthPlusOffset:Int = 0;
		var glyphFrame:FlxGlyphFrame;
		
		for (c in 0...lineLength)
		{
			charCode = Utf8.charCodeAt(str, c);
			
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
				if (font.glyphs.exists(charCode))
				{
					glyphFrame = font.glyphs.get(charCode);
					charWidth = glyphFrame.xAdvance;
					
					if (c == (lineLength - 1))
					{
						widthPlusOffset = Math.ceil(glyphFrame.offset.x + glyphFrame.frame.width);
						if (widthPlusOffset > charWidth)
						{
							charWidth = widthPlusOffset;
						}
					}
				}
				else
				{
					charWidth = 0;
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
		var charWidth:Float = 0;	// the width of current character
		
		var subLine:Utf8;			// current subline to assemble
		var subLineWidth:Float;		// the width of current subline
		
		var spaceWidth:Float = font.spaceWidth;
		var tabWidth:Float = spaceWidth * numSpacesInTab;
		
		var startX:Float = Math.abs(font.minOffsetX);
		
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
		var wordWidth:Float;				// total width of current word
		var wordLength:Int;					// number of letters in current word
		
		var isSpaceWord:Bool = false; 		// whether current word consists of spaces or not
		
		var charCode:Int;
		var charWidth:Float = 0;			// the width of current character
		
		var subLines:Array<String> = [];	// helper array for subdividing lines
		
		var subLine:String;					// current subline to assemble
		var subLineWidth:Float;				// the width of current subline
		
		var spaceWidth:Float = font.spaceWidth;
		var tabWidth:Float = spaceWidth * numSpacesInTab;
		
		var startX:Float = Math.abs(font.minOffsetX);
		
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
						charWidth = (font.glyphs.exists(charCode)) ? font.glyphs.get(charCode).xAdvance : 0;
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
		var charWidth:Float = 0;			// the width of current character
		
		var subLines:Array<String> = [];	// helper array for subdividing lines
		
		var subLine:String;					// current subline to assemble
		var subLineUtf8:Utf8;
		var subLineWidth:Float;				// the width of current subline
		
		var spaceWidth:Float = font.spaceWidth;
		var tabWidth:Float = spaceWidth * numSpacesInTab;
		
		var startX:Float = Math.abs(font.minOffsetX);
		
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
	private function updateTextBitmap():Void 
	{
		computeTextSize();
		updateBuffer();
		pendingGraphicChange = false;
	}
	
	/**
	 * Internal method for updating the view of the text component (actual data used for text rendering)
	 */
	private function updateTextGraphic():Void
	{
		if (textBitmap != null && (frameWidth != textBitmap.width || frameHeight != textBitmap.height))
		{
			textBitmap.dispose();
			textBitmap = null;
		}
		
		if (textBitmap == null)
		{
			textBitmap = new BitmapData(frameWidth, frameHeight, true, FlxColor.TRANSPARENT);
		}
		else
		{
			textBitmap.fillRect(textBitmap.rect, colorForFill);
		}
		
		#if FLX_RENDER_BLIT
		textBitmap.lock();
		#end
		
		textData.splice(0, textData.length);
		
		_fieldWidth = frameWidth;
		
		var numLines:Int = _lines.length;
		var line:String;
		var lineWidth:Float;
		
		var ox:Int, oy:Int;
		
		for (i in 0...numLines)
		{
			line = _lines[i];
			lineWidth = _linesWidth[i];
			
			// LEFT
			ox = Std.int(Math.abs(font.minOffsetX));
			oy = Std.int(i * (font.lineHeight + lineSpacing)) + padding;
			
			if (alignment == FlxTextAlign.CENTER) 
			{
				ox += Std.int((frameWidth - lineWidth) / 2) - padding;
			}
			else if (alignment == FlxTextAlign.RIGHT) 
			{
				ox += (frameWidth - Std.int(lineWidth)) - padding;
			}
			else	// LEFT
			{
				ox += padding;
			}
			
			#if FLX_RENDER_BLIT
			blitLine(line, ox, oy);
			#else
			tileLine(line, ox, oy);
			#end
		}
		
		#if FLX_RENDER_BLIT
		textBitmap.unlock();
		#end
		
		pendingColorChange = false;
	}
	
	private function updateBuffer():Void
	{
		var colorForFill:Int = background ? backgroundColor : FlxColor.TRANSPARENT;
		
		#if FLX_RENDER_BLIT
		if (pixels == null || (frameWidth != pixels.width || frameHeight != pixels.height))
		{
			pixels = new BitmapData(frameWidth, frameHeight, true, colorForFill);
		}
		else
		{
			pixels.fillRect(graphic.bitmap.rect, colorForFill);
		}
		#else
		width = frameWidth;
		height = frameHeight;
		
		origin.x = frameWidth * 0.5;
		origin.y = frameHeight * 0.5;
		
		textDrawData.splice(0, textDrawData.length);
		borderDrawData.splice(0, borderDrawData.length);
		#end
		
		#if FLX_RENDER_BLIT
		pixels.lock();
		#end
		
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
		
		// TODO: continue from here...
		
		// render border
		switch (borderStyle)
		{
			case SHADOW:
				for (iterY in 0...iterationsY)
				{
					for (iterX in 0...iterationsX)
					{
						blitLine(line, borderGlyphs, deltaX * (iterX + 1), deltaY * (iterY + 1));
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
					blitLine(line, borderGlyphs, -itd, -itd);
					//upper-middle
					blitLine(line, borderGlyphs, 0, -itd);
					//upper-right
					blitLine(line, borderGlyphs, itd, -itd);
					//middle-left
					blitLine(line, borderGlyphs, -itd, 0);
					//middle-right
					blitLine(line, borderGlyphs, itd, 0);
					//lower-left
					blitLine(line, borderGlyphs, -itd, itd);
					//lower-middle
					blitLine(line, borderGlyphs, 0, itd);
					//lower-right
					blitLine(line, borderGlyphs, itd, itd);
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
					blitLine(line, borderGlyphs, -itd, -itd);
					//upper-right
					blitLine(line, borderGlyphs, itd, -itd);
					//lower-left
					blitLine(line, borderGlyphs, -itd, itd);
					//lower-right
					blitLine(line, borderGlyphs, itd, itd);
				}	
			case NONE:
		}
		
		blitLine(line, textGlyphs, 0, 0);
		
		#if FLX_RENDER_BLIT
		pixels.unlock();
		dirty = true;
		#end
	}
	
	private function blitLine(line:String, startX:Int, startY:Int):Void
	{
		var glyph:FlxGlyphFrame;
		var charCode:Int;
		var curX:Int = startX;
		var curY:Int = startY;
		
		var spaceWidth:Int = font.spaceWidth);
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
					glyph.paint(textBitmap, _flashPoint);
					curX += glyph.xAdvance;
				}
			}
			
			curX += letterSpacing;
		}
	}
	
	private function tileLine(line:String, startX:Int, startY:Int):Void
	{
		var glyph:FlxGlyphFrame;
		var isFrontText:Bool = glyphs;
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
		pendingGraphicChange = true;
	}
	
	private function get_fieldWidth():Float
	{
		return (autoSize) ? textWidth : _fieldWidth;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	private function set_fieldWidth(value:Float):Float
	{
		value = Std.int(value);
		value = Math.max(1, value);
		
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
			pendingGraphicChange = true;
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
			pendingColorChange = true;
		}
		
		return value;
	}
	
	private function set_lineSpacing(value:Int):Int
	{
		if (lineSpacing != value)
		{
			lineSpacing = Std.int(Math.abs(value));
			pendingGraphicChange = true;
		}
		
		return lineSpacing;
	}
	
	private function set_letterSpacing(value:Int):Int
	{
		var tmp:Int = Std.int(Math.abs(value));
		
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
			pendingGraphicChange = true;
		}
		
		return value;
	}
	
	private function set_backgroundColor(value:Int):Int 
	{
		if (backgroundColor != value)
		{
			backgroundColor = value;
			pendingGraphicChange = true;
		}
		
		return value;
	}
	
	private function set_borderStyle(style:FlxTextBorderStyle):FlxTextBorderStyle
	{		
		if (style != borderStyle)
		{
			borderStyle = style;
			pendingColorChange = true;
		}
		
		return borderStyle;
	}
	
	private function set_borderColor(value:Int):Int 
	{
		if (borderColor != value)
		{
			borderColor = value;
			pendingColorChange = true;
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
				pendingGraphicChange = true;
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
				pendingGraphicChange = true;
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
	private function get_textWidth():Float
	{
		var max:Float = 0;
		var numLines:Int = _lines.length;
		var lineWidth:Float;
		_linesWidth = [];
		
		for (i in 0...numLines)
		{
			lineWidth = getLineWidth(i);
			_linesWidth[i] = lineWidth;
			max = Math.max(max, lineWidth);
		}
		
		return max;
	}
	
	private function get_textHeight():Float
	{
		return (lineHeight + lineSpacing) * _lines.length - lineSpacing;
	}
	
	private function get_lineHeight():Float
	{
		return font.lineHeight;
	}
	
	override private function get_width():Float 
	{
		checkPendingChanges();
		return super.get_width();
	}
	
	override private function get_height():Float 
	{
		checkPendingChanges();
		return super.get_height();
	}
}