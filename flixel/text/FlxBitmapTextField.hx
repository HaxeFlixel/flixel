package flixel.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.BitmapFont;
import flixel.graphics.frames.GlyphFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.system.layer.DrawStackItem;
import flixel.text.FlxText.FlxTextAlign;
import flixel.math.FlxAngle;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

// TODO: make pixels accessible in tile render mode also...

/**
 * Extends FlxSprite to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 */
class FlxBitmapTextField extends FlxSprite
{
	/**
	 * Font for text rendering.
	 */
	@:isVar
	public var font(default, set):BitmapFont;
	
	/**
	 * Text to display.
	 */
	@:isVar
	public var text(default, set):String = "";
	
	/**
	 * Helper array which contains actual strings for rendering.
	 */
	private var _lines:Array<String> = [];
	/**
	 * Helper array which contains width of each displayed lines.
	 */
	private var _linesWidth:Array<Float> = [];
	
	/**
	 * Specifies how the text field should align text.
	 * JUSTIFY alignment isn't supported.
	 */
	@:isVar
	public var alignment(default, set):FlxTextAlign = FlxTextAlign.LEFT;
	
	/**
	 * The distance to add between lines.
	 */
	@:isVar
	public var lineSpacing(default, set):Int = 0;
	
	/**
	 * The distance to add between letters.
	 */
	@:isVar
	public var letterSpacing(default, set):Int = 0;
	
	/**
	 * Whether to convert text to upper case or not.
	 */
	@:isVar
	public var autoUpperCase(default, set):Bool = false;
	
	/**
	 * A Boolean value that indicates whether the text field has word wrap.
	 */
	@:isVar
	public var wordWrap(default, set):Bool = true;
	
	/**
	 * Whether word wrapping algorithm should wrap lines by words or by single character.
	 * Default value is true.
	 */
	@:isVar 
	public var wrapByWord(default, set):Bool = true;
	
	/**
	 * Whether this text field have fixed width or not.
	 * Default value if true.
	 */
	@:isVar
	public var autoSize(default, set):Bool = true;
	
	/**
	 * Number of pixels between text and text field border
	 */
	@:isVar
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
	@:isVar
	public var numSpacesInTab(default, set):Int = 4;
	private var _tabSpaces:String = "    ";
	
	/**
	 * The color of the text in 0xAARRGGBB format.
	 * Result color of text will be multiplication of textColor and color.
	 */
	@:isVar
	public var textColor(default, set):FlxColor = 0xFFFFFFFF;
	
	/**
	 * Whether to use textColor while rendering or not.
	 */
	@:isVar
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
	@:isVar
	public var background(default, set):Bool = false;
	
	/**
	 * Specifies the color of background
	 */
	@:isVar
	public var backgroundColor(default, set):FlxColor = FlxColor.TRANSPARENT;
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	@:isVar
	public var multiLine(default, set):Bool = true;
	
	/**
	 * Reflects how many lines have this text field.
	 */
	@:isVar
	public var numLines(get, null):Int = 0;
	
	/**
	 * The "size" of the font.
	 */
	@:isVar
	public var size(default, set):Float = 1;
	
	private var _pendingTextChange:Bool = true;
	private var _pendingGraphicChange:Bool = true;
	
	private var _pendingTextGlyphsChange:Bool = true;
	private var _pendingBorderGlyphsChange:Bool = false;
	
	#if FLX_RENDER_TILE
	private var _textDrawData:Array<Float>;
	private var _borderDrawData:Array<Float>;
	private var _tilePoint:FlxPoint;
	private var _tileMatrix:FlxMatrix;
	private var _bgMatrix:FlxMatrix;
	#else
	private var textGlyphs:BitmapGlyphCollection;
	private var borderGlyphs:BitmapGlyphCollection;
	#end
	
	/**
	 * Constructs a new text field component.
	 * @param 	font	Optional parameter for component's font prop
	 */
	public function new(?font:BitmapFont) 
	{
		super();
		
		width = 2;
		alpha = 1;
		
		if (font == null)
		{
			font = BitmapFont.getDefault();
		}
		
		this.font = font;
		
		shadowOffset = FlxPoint.get(1, 1);
		
		#if FLX_RENDER_BLIT
		pixels = new BitmapData(1, 1, true, FlxColor.TRANSPARENT);
		#else
		_textDrawData = [];
		_borderDrawData = [];
		_tilePoint = new FlxPoint();
		_tileMatrix = new FlxMatrix();
		_bgMatrix = new FlxMatrix();
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
		_textDrawData = null;
		_borderDrawData = null;
		_tilePoint = null;
		_tileMatrix = null;
		_bgMatrix = null;
		#else
		textGlyphs = FlxDestroyUtil.destroy(textGlyphs);
		borderGlyphs = FlxDestroyUtil.destroy(borderGlyphs);
		#end
		
		super.destroy();
	}
	
	/**
	 * Forces graphic regeneration for this text field.
	 */
	public function forceGraphicUpdate():Void
	{
		_pendingGraphicChange = true;
	}
	
	inline private function checkPendingChanges():Void
	{
		#if FLX_RENDER_BLIT
		if (_pendingTextGlyphsChange)
		{
			updateTextGlyphs();
		}
		
		if (_pendingBorderGlyphsChange)
		{
			updateBorderGlyphs();
		}
		#end
		
		if (_pendingTextChange)
		{
			updateText();
			_pendingGraphicChange = true;
		}
		
		if (_pendingGraphicChange)
		{
			updateGraphic();
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		checkPendingChanges();
		super.update(elapsed);
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
		
		var textLength:Int = Std.int(_textDrawData.length / 3);
		var borderLength:Int = Std.int(_borderDrawData.length / 3);
		
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
		
		var drawItem:DrawStackItem;
		var tileID:Float = -1;
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
			
			if (_angleChanged)
			{
				var radians:Float = angle * FlxAngle.TO_RAD;
				_sinAngle = Math.sin(radians);
				_cosAngle = Math.cos(radians);
				_angleChanged = false;
			}
			
			totalScaleX = sx * camera.totalScaleX;
			totalScaleY = sy * camera.totalScaleY;
			
			// matrix for calculation tile position
			_matrix.identity();
			_matrix.scale(totalScaleX, totalScaleY);
			
			if (angle != 0)
			{
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}
			
			// matrix for calculation tile transformations
			_tileMatrix.identity();
			_tileMatrix.scale(size * totalScaleX, size * totalScaleY);
			if (angle != 0)
			{
				_tileMatrix.rotateWithTrig(_cosAngle, _sinAngle);
			}
			
			if (background)
			{
				// backround tile transformations
				_bgMatrix.identity();
				_bgMatrix.scale(0.1 * frameWidth * totalScaleX, 0.1 * frameHeight * totalScaleY);
				
				if (angle != 0)
				{
					_bgMatrix.rotateWithTrig(_cosAngle, _sinAngle);
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
				drawItem = camera.getDrawStackItem(FlxG.bitmap.whitePixel.parent, true, _blendInt, antialiasing);
				tileID = FlxG.bitmap.whitePixel.tileID;
				drawItem.setMatrixDrawData(_point, tileID, _bgMatrix, true, backgroundColor.to24Bit(), bgAlpha * camera.alpha);
			}
			
			drawItem = camera.getDrawStackItem(font.parent, true, _blendInt, antialiasing);
			
			alphaToUse = bAlpha * camera.alpha;
			
			for (j in 0...borderLength)
			{
				dataPos = j * 3;
				
				tileID = _borderDrawData[dataPos];
				
				currTileX = _borderDrawData[dataPos + 1];
				currTileY = _borderDrawData[dataPos + 2];
				
				_tilePoint.set(currTileX, currTileY);
				_matrix.transformFlxPoint(_tilePoint);
				_tilePoint.addPoint(_point);
				
				drawItem.setMatrixDrawData(_tilePoint, tileID, _tileMatrix, true, bColor, alphaToUse);
			}
			
			alphaToUse = tAlpha * camera.alpha;
			
			for (j in 0...textLength)
			{
				dataPos = j * 3;
				
				tileID = _textDrawData[dataPos];
				
				currTileX = _textDrawData[dataPos + 1];
				currTileY = _textDrawData[dataPos + 2];
				
				_tilePoint.set(currTileX, currTileY);
				_matrix.transformFlxPoint(_tilePoint);
				_tilePoint.addPoint(_point);
				
				drawItem.setMatrixDrawData(_tilePoint, tileID, _tileMatrix, true, tColor, alphaToUse);
			}
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
	
	override private function set_color(Color:FlxColor):FlxColor
	{
		super.set_color(Color);
		_pendingGraphicChange = true;
		return color;
	}
	
	override private function set_alpha(value:Float):Float
	{
		alpha = value;
		_pendingGraphicChange = true;
		return value;
	}
	#end
	
	private function set_textColor(value:FlxColor):FlxColor 
	{
		if (textColor != value)
		{
			textColor = value;
			_pendingTextGlyphsChange = true;
		}
		
		return value;
	}
	
	private function set_useTextColor(value:Bool):Bool 
	{
		if (useTextColor != value)
		{
			useTextColor = value;
			_pendingTextGlyphsChange = true;
		}
		
		return value;
	}
	
	// TODO: override calcFrame (maybe)
	
	private function set_text(value:String):String 
	{
		if (value != text)
		{
			text = value;
			_pendingTextChange = true;
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
		
		_pendingTextChange = false;
		_pendingGraphicChange = true;
	}
	
	/**
	 * Calculates the size of text field.
	 */
	private function computeTextSize():Void 
	{
		var txtWidth:Int = Math.ceil(width);
		var txtHeight:Int = Math.ceil(textHeight) + 2 * padding;
		// need to calculate it here
		var maxWidth:Int = Math.ceil(textWidth);
		
		if (autoSize)
		{
			maxWidth = maxWidth + 2 * padding;
			txtWidth = (maxWidth > frameWidth) ? maxWidth : frameWidth;
		}
		
		frameWidth = txtWidth;
		frameHeight = (txtHeight == 0) ? 1 : txtHeight;
		
		_halfSize.set(0.5 * frameWidth, 0.5 * frameHeight);
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
		var spaceWidth:Float = Math.ceil(font.spaceWidth * size);
		var tabWidth:Float = Math.ceil(spaceWidth * numSpacesInTab);
		
		var lineLength:Int = str.length;	// lenght of the current line
		var lineWidth:Float = Math.ceil(Math.abs(font.minOffsetX) * size);
		
		var char:String; 					// current character in word
		var charWidth:Float = 0;			// the width of current character
		
		var widthPlusOffset:Int = 0;
		var glyphFrame:GlyphFrame;
		
		for (c in 0...lineLength)
		{
			char = str.charAt(c);
			
			if (char == ' ')
			{
				charWidth = spaceWidth;
			}
			else if (char == '\t')
			{
				charWidth = tabWidth;
			}
			else
			{
				if (font.glyphs.exists(char))
				{
					glyphFrame = font.glyphs.get(char);
					charWidth = Math.ceil(glyphFrame.xAdvance * size);
					
					if (c == (lineLength - 1))
					{
						widthPlusOffset = Math.ceil((glyphFrame.offset.x + glyphFrame.frame.width) * size);
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
		var char:String; 			// current character in word
		var charWidth:Float = 0;	// the width of current character
		
		var subLine:String;			// current subline to assemble
		var subLineWidth:Float;		// the width of current subline
		
		var spaceWidth:Float = font.spaceWidth * size;
		var tabWidth:Float = spaceWidth * numSpacesInTab;
		
		var startX:Float = Math.abs(font.minOffsetX) * size;
		
		for (line in _lines)
		{
			lineLength = line.length;
			subLine = "";
			subLineWidth = startX;
			
			c = 0;
			while (c < lineLength)
			{
				char = line.charAt(c);
				
				if (char == ' ')
				{
					charWidth = spaceWidth;
				}
				else if (char == '\t')
				{
					charWidth = tabWidth;
				}
				else
				{
					charWidth = (font.glyphs.exists(char)) ? font.glyphs.get(char).xAdvance * size : 0;
				}
				charWidth += letterSpacing;
				
				if (subLineWidth + charWidth > width - 2 * padding)
				{
					subLine += char;
					newLines.push(subLine);
					subLine = "";
					subLineWidth = startX;
					c = lineLength;
				}
				else
				{
					subLine += char;
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
		var isSpaceWord:Bool = false; 		// whether current word consists of spaces or not
		var lineLength:Int = line.length;	// lenght of the current line
		
		var c:Int = 0;						// char index on the line
		var char:String; 					// current character in word
		
		while (c < lineLength)
		{
			char = line.charAt(c);
			switch(char)
			{
				case ' ', '\t': {
					if (!isSpaceWord)
					{
						isSpaceWord = true;
						
						if (word != "")
						{
							words.push(word);
							word = "";
						}
					}
					
					word += char;
				}
				case '-': {
					if (isSpaceWord && word != "")
					{
						isSpaceWord = false;
						words.push(word);
						words.push(char);
					}
					else if (isSpaceWord == false)
					{
						words.push(word + char);
					}
					
					word = "";
				}
				default: {
					if (isSpaceWord && word != "")
					{
						isSpaceWord = false;
						words.push(word);
						word = "";
					}
					
					word += char;
				}
			}
			
			c++;
		}
		
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
		
		var char:String; 					// current character in word
		var charWidth:Float = 0;			// the width of current character
		
		var subLines:Array<String> = [];	// helper array for subdividing lines
		
		var subLine:String;					// current subline to assemble
		var subLineWidth:Float;				// the width of current subline
		
		var spaceWidth:Float = font.spaceWidth * size;
		var tabWidth:Float = spaceWidth * numSpacesInTab;
		
		var startX:Float = Math.abs(font.minOffsetX) * size;
		
		if (numWords > 0)
		{
			w = 0;
			subLineWidth = startX;
			subLine = "";
			
			while (w < numWords)
			{
				wordWidth = 0;
				word = words[w];
				wordLength = word.length;
				
				isSpaceWord = (word.charAt(0) == ' ' || word.charAt(0) == '\t');
				
				for (c in 0...wordLength)
				{
					char = word.charAt(c);
					
					if (char == ' ')
					{
						charWidth = spaceWidth;
					}
					else if (char == '\t')
					{
						charWidth = tabWidth;
					}
					else
					{
						charWidth = (font.glyphs.exists(char)) ? font.glyphs.get(char).xAdvance * size : 0;
					}
					
					wordWidth += charWidth;
				}
				
				wordWidth += ((wordLength - 1) * letterSpacing);
				
				if (subLineWidth + wordWidth > width - 2 * padding)
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
		
		var char:String; 					// current character in word
		var c:Int;							// char index
		var charWidth:Float = 0;			// the width of current character
		
		var subLines:Array<String> = [];	// helper array for subdividing lines
		
		var subLine:String;					// current subline to assemble
		var subLineWidth:Float;				// the width of current subline
		
		var spaceWidth:Float = font.spaceWidth * size;
		var tabWidth:Float = spaceWidth * numSpacesInTab;
		
		var startX:Float = Math.abs(font.minOffsetX) * size;
		
		if (numWords > 0)
		{
			w = 0;
			subLineWidth = startX;
			subLine = "";
			
			while (w < numWords)
			{
				word = words[w];
				wordLength = word.length;
				
				isSpaceWord = (word.charAt(0) == ' ' || word.charAt(0) == '\t');
				
				c = 0;
				
				while (c < wordLength)
				{
					char = word.charAt(c);
					
					if (char == ' ')
					{
						charWidth = spaceWidth;
					}
					else if (char == '\t')
					{
						charWidth = tabWidth;
					}
					else
					{
						charWidth = (font.glyphs.exists(char)) ? font.glyphs.get(char).xAdvance * size : 0;
					}
					
					if (subLineWidth + charWidth > width - 2 * padding)
					{
						if (isSpaceWord) // new line ends with space / tab char, so we push it to sublines array, skip all the rest spaces and start another line
						{
							subLines.push(subLine);
							c = wordLength;
							subLine = "";
							subLineWidth = startX;
						}
						else if (subLine != "") // new line isn't empty so we should add it to sublines array and start another one
						{
							subLines.push(subLine);
							subLine = char;
							subLineWidth = startX + charWidth + letterSpacing;
						}
						else	// the line is too tight to hold even one glyph
						{
							subLine = char;
							subLineWidth = startX + charWidth + letterSpacing;
						}
					}
					else
					{
						subLine += char;
						subLineWidth += (charWidth + letterSpacing);
					}
					
					c++;
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
	 * Internal method for updating the view of the text component
	 */
	private function updateGraphic():Void 
	{
		computeTextSize();
		updateBuffer();
		_pendingGraphicChange = false;
	}
	
	private function updateBuffer():Void
	{
		var colorForFill:Int = (background) ? backgroundColor : FlxColor.TRANSPARENT;
		
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
		
		_textDrawData.splice(0, _textDrawData.length);
		_borderDrawData.splice(0, _borderDrawData.length);
		
		var borderGlyphs:Bool = false;
		var textGlyphs:Bool = true;
		#end
		
		if (size > 0)
		{
			#if FLX_RENDER_BLIT
			pixels.lock();
			#end
			
			var numLines:Int = _lines.length;
			var line:String;
			var lineWidth:Float;
			
			var ox:Int, oy:Int;
			
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
			for (i in 0...numLines)
			{
				line = _lines[i];
				lineWidth = _linesWidth[i];
				
				// LEFT
				ox = Std.int(Math.abs(font.minOffsetX) * size);
				oy = Std.int(i * (font.lineHeight * size + lineSpacing)) + padding;
				
				if (alignment == FlxTextAlign.CENTER) 
				{
					ox += Std.int((frameWidth - lineWidth) / 2) - padding;
				}
				if (alignment == FlxTextAlign.RIGHT) 
				{
					ox += (frameWidth - Std.int(lineWidth)) - padding;
				}
				else	// LEFT
				{
					ox += padding;
				}
				
				switch (borderStyle)
				{
					case SHADOW:
						for (iterY in 0...iterationsY)
						{
							for (iterX in 0...iterationsX)
							{
								blitLine(line, borderGlyphs, ox + deltaX * (iterX + 1), oy + deltaY * (iterY + 1));
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
							blitLine(line, borderGlyphs, ox - itd, oy - itd);
							//upper-middle
							blitLine(line, borderGlyphs, ox, oy - itd);
							//upper-right
							blitLine(line, borderGlyphs, ox + itd, oy - itd);
							//middle-left
							blitLine(line, borderGlyphs, ox - itd, oy);
							//middle-right
							blitLine(line, borderGlyphs, ox + itd, oy);
							//lower-left
							blitLine(line, borderGlyphs, ox - itd, oy + itd);
							//lower-middle
							blitLine(line, borderGlyphs, ox, oy + itd);
							//lower-right
							blitLine(line, borderGlyphs, ox + itd, oy + itd);
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
							blitLine(line, borderGlyphs, ox - itd, oy - itd);
							//upper-right
							blitLine(line, borderGlyphs, ox + itd, oy - itd);
							//lower-left
							blitLine(line, borderGlyphs, ox - itd, oy + itd);
							//lower-right
							blitLine(line, borderGlyphs, ox + itd, oy + itd);
						}	
					case NONE:
				}
			}
			
			// render text
			for (i in 0...numLines)
			{
				line = _lines[i];
				lineWidth = _linesWidth[i];
				
				// LEFT
				ox = Std.int(Math.abs(font.minOffsetX) * size);
				oy = Std.int(i * (font.lineHeight * size + lineSpacing)) + padding;
				
				if (alignment == FlxTextAlign.CENTER) 
				{
					ox += Std.int((frameWidth - lineWidth) / 2) - padding;
				}
				if (alignment == FlxTextAlign.RIGHT) 
				{
					ox += (frameWidth - Std.int(lineWidth)) - padding;
				}
				else	// LEFT
				{
					ox += padding;
				}
				
				blitLine(line, textGlyphs, ox, oy);
			}
			
			#if FLX_RENDER_BLIT
			pixels.unlock();
			frame.destroyBitmaps();
			dirty = true;
			#end
		}
	}
	
	#if FLX_RENDER_BLIT
	private function blitLine(line:String, glyphs:BitmapGlyphCollection, startX:Int, startY:Int):Void
	#else
	private function blitLine(line:String, glyphs:Bool, startX:Int, startY:Int):Void
	#end
	{
		#if FLX_RENDER_BLIT
		var glyph:BitmapGlyph;
		#else
		var glyph:GlyphFrame;
		
		var isFrontText:Bool = glyphs;
		var drawData:Array<Float> = (isFrontText) ? _textDrawData : _borderDrawData;
		var pos:Int = drawData.length;
		#end
		var char:String;
		var curX:Int = startX;
		var curY:Int = startY;
		
		var spaceWidth:Int = Std.int(font.spaceWidth * size);
		var tabWidth:Int = Std.int(spaceWidth * numSpacesInTab);
		
		var lineLength:Int = line.length;
		
		for (i in 0...lineLength)
		{
			char = line.charAt(i);
			
			if (char == ' ')
			{
				curX += spaceWidth;
			}
			else if (char == '\t')
			{
				curX += tabWidth;
			}
			else
			{
				#if FLX_RENDER_BLIT
				glyph = glyphs.glyphMap.get(char);
				if (glyph != null)
				{
					_flashPoint.x = curX + glyph.offsetX;
					_flashPoint.y = curY + glyph.offsetY;
					pixels.copyPixels(glyph.bitmap, glyph.rect, _flashPoint, null, null, true);
					curX += glyph.xAdvance;
				}
				#else
				glyph = font.glyphs.get(char);
				if (glyph != null)
				{
					_flashPoint.x = curX + (glyph.offset.x + 0.5 * glyph.frame.width) * size - origin.x;
					_flashPoint.y = curY + (glyph.offset.y + 0.5 * glyph.frame.height) * size - origin.y;
					
					drawData[pos++] = glyph.tileID;
					drawData[pos++] = _flashPoint.x;
					drawData[pos++] = _flashPoint.y;
					curX += Math.ceil(glyph.xAdvance * size);
				}
				#end
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
		_pendingGraphicChange = true;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	override private function set_width(value:Float):Float
	{
		value = Std.int(value);
		value = Math.max(1, value);
		
		if (value != width)
		{
			_pendingTextChange = true;
		}
		
		return super.set_width(value);
	}
	
	private function set_alignment(value:FlxTextAlign):FlxTextAlign 
	{
		if (alignment != value && alignment != FlxTextAlign.JUSTIFY)
		{
			alignment = value;
			_pendingGraphicChange = true;
		}
		
		return value;
	}
	
	private function set_multiLine(value:Bool):Bool 
	{
		if (multiLine != value)
		{
			multiLine = value;
			_pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_font(value:BitmapFont):BitmapFont 
	{
		if (font != value)
		{
			font = value;
			_pendingTextChange = true;
			_pendingBorderGlyphsChange = true;
		}
		
		return value;
	}
	
	private function set_lineSpacing(value:Int):Int
	{
		if (lineSpacing != value)
		{
			lineSpacing = Std.int(Math.abs(value));
			_pendingGraphicChange = true;
		}
		
		return lineSpacing;
	}
	
	private function set_letterSpacing(value:Int):Int
	{
		var tmp:Int = Std.int(Math.abs(value));
		
		if (tmp != letterSpacing)
		{
			letterSpacing = tmp;
			_pendingTextChange = true;
		}
		
		return letterSpacing;
	}
	
	private function set_autoUpperCase(value:Bool):Bool 
	{
		if (autoUpperCase != value)
		{
			autoUpperCase = value;
			_pendingTextChange = true;
		}
		
		return autoUpperCase;
	}
	
	private function set_wordWrap(value:Bool):Bool 
	{
		if (wordWrap != value)
		{
			wordWrap = value;
			_pendingTextChange = true;
		}
		
		return wordWrap;
	}
	
	private function set_wrapByWord(value:Bool):Bool
	{
		if (wrapByWord != value)
		{
			wrapByWord = value;
			_pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_autoSize(value:Bool):Bool 
	{
		if (autoSize != value)
		{
			autoSize = value;
			_pendingTextChange = true;
		}
		
		return autoSize;
	}
	
	private function set_size(value:Float):Float
	{
		var tmp:Float = Math.abs(value);
		
		if (tmp != size)
		{
			size = tmp;
			_pendingTextGlyphsChange = true;
			_pendingBorderGlyphsChange = true;
			_pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_padding(value:Int):Int
	{
		if (value != padding)
		{
			padding = value;
			_pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_numSpacesInTab(value:Int):Int 
	{
		if (numSpacesInTab != value && value > 0)
		{
			numSpacesInTab = value;
			_tabSpaces = "";
			
			for (i in 0...value)
			{
				_tabSpaces += " ";
			}
			
			_pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_background(value:Bool):Bool
	{
		if (background != value)
		{
			background = value;
			_pendingGraphicChange = true;
		}
		
		return value;
	}
	
	private function set_backgroundColor(value:Int):Int 
	{
		if (backgroundColor != value)
		{
			backgroundColor = value;
			_pendingGraphicChange = true;
		}
		
		return value;
	}
	
	private function set_borderStyle(style:FlxTextBorderStyle):FlxTextBorderStyle
	{		
		if (style != borderStyle)
		{
			borderStyle = style;
			_pendingBorderGlyphsChange = true;
		}
		
		return borderStyle;
	}
	
	private function set_borderColor(value:Int):Int 
	{
		if (borderColor != value)
		{
			borderColor = value;
			_pendingBorderGlyphsChange = true;
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
				_pendingGraphicChange = true;
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
				_pendingGraphicChange = true;
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
		return font.lineHeight * size;
	}
	
	private function updateTextGlyphs():Void
	{
		#if FLX_RENDER_BLIT
		if (font == null)	return;
		textGlyphs = FlxDestroyUtil.destroy(textGlyphs);
		textGlyphs = font.prepareGlyphs(size, textColor, useTextColor);
		_pendingGraphicChange = true;
		#end
		_pendingTextGlyphsChange = false;
	}
	
	private function updateBorderGlyphs():Void
	{
		#if FLX_RENDER_BLIT
		if (font != null && (borderGlyphs == null || borderColor != borderGlyphs.color || size != borderGlyphs.scale || font != borderGlyphs.font))
		{
			borderGlyphs = FlxDestroyUtil.destroy(borderGlyphs);
			borderGlyphs = font.prepareGlyphs(size, borderColor);
			_pendingGraphicChange = true;
		}
		#end
		_pendingBorderGlyphsChange = false;
	}
}