package flixel.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxMaterial;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxBitmapFont.FlxCharacter;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.shaders.FlxShader;
import flixel.graphics.shaders.quads.FlxDistanceFieldShader;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.common.FlxCameraView;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.Utf8;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
using flixel.util.FlxColorTransformUtil;

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
	 * Helper object to avoid many ColorTransform allocations
	 */
	private var _colorParams:ColorTransform = new ColorTransform();
	
	private var _charCodes:Array<Int> = [];
	
	/**
	 * Helper array which contains actual represenations of text for rendering.
	 */
	private var _lines:Array<Array<Int>> = [];
	/**
	 * Helper array which contains width of each displayed lines.
	 */
	private var _linesWidth:Array<Float> = [];
	
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
	
	public var useKerning(default, set):Bool = false;
	
	/**
	 * The width of the TextField object used for bitmap generation for this FlxText object.
	 * Use it when you want to change the visible width of text. Enables autoSize if <= 0.
	 */
	public var fieldWidth(get, set):Int;
	
	public var backgroundMaterial:FlxMaterial;
	
	private var _backgroundRect:FlxRect;
	
	private var _fieldWidth:Int;
	
	private var pendingTextChange:Bool = true;
	private var pendingTextBitmapChange:Bool = true;
	private var pendingPixelsChange:Bool = true;
	
	private var textData:Array<Float>;
	private var textDrawData:Array<Float>;
	private var borderDrawData:Array<Float>;
	
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
		
		_backgroundRect = FlxRect.get();
	}
	
	/**
	 * Clears all resources used.
	 */
	override public function destroy():Void 
	{
		font = null;
		text = null;
		_lines = null;
		_charCodes = null;
		_linesWidth = null;
		
		_backgroundRect.put();
		_backgroundRect = null;
		
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
			Force = true;
		
		pendingTextBitmapChange = pendingTextBitmapChange || Force;
		checkPendingChanges(false);
		
		if (FlxG.renderBlit)
			super.drawFrame(Force);
	}
	
	private inline function checkPendingChanges(useTiles:Bool = false):Void
	{
		if (FlxG.renderBlit)
			useTiles = false;
		
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
			updatePixels(useTiles);
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
				tAlpha *= textColor.alphaFloat;
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
			
			var view:FlxCameraView;
			var currFrame:FlxFrame = null;
			var currTileX:Float = 0;
			var currTileY:Float = 0;
			var sx:Float = scale.x * _facingHorizontalMult;
			var sy:Float = scale.y * _facingVerticalMult;
			
			var ox:Float = origin.x;
			var oy:Float = origin.y;
			
			if (_facingHorizontalMult != 1)
				ox = frameWidth - ox;
			
			if (_facingVerticalMult != 1)
				oy = frameHeight - oy;
			
			for (camera in cameras)
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
					continue;
				
				getScreenPosition(_point, camera).subtractPoint(offset);
				
				if (isPixelPerfectRender(camera))
					_point.floor();
				
				updateTrig();
				view = camera.view;
				
				if (background)
				{
					// backround tile transformations
					_matrix.identity();
					_matrix.translate(-ox, -oy);
					_matrix.scale(sx, sy);
					
					if (angle != 0)
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
					
					_matrix.translate(_point.x + ox, _point.y + oy);
					
					_backgroundRect.set(0, 0, frameWidth, frameHeight);
					view.drawColorQuad(backgroundMaterial, _backgroundRect, _matrix, backgroundColor, backgroundColor.alphaFloat * alpha);
				}
				
				for (j in 0...borderLength)
				{
					dataPos = j * 3;
					
					currFrame = font.getCharacter(Std.int(borderDrawData[dataPos])).frame;
					
					currTileX = borderDrawData[dataPos + 1];
					currTileY = borderDrawData[dataPos + 2];
					
					currFrame.prepareMatrix(_matrix);
					_matrix.translate(currTileX - ox, currTileY - oy);
					_matrix.scale(sx, sy);
					
					if (angle != 0)
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
					
					_matrix.translate(_point.x + ox, _point.y + oy);
					_colorParams.setMultipliers(borderRed, borderGreen, borderBlue, bAlpha);
					view.drawPixels(currFrame, material, _matrix, _colorParams);
				}
				
				for (j in 0...textLength)
				{
					dataPos = j * 3;
					
					currFrame = font.getCharacter(Std.int(textDrawData[dataPos])).frame;
					
					currTileX = textDrawData[dataPos + 1];
					currTileY = textDrawData[dataPos + 2];
					
					currFrame.prepareMatrix(_matrix);
					_matrix.translate(currTileX - ox, currTileY - oy);
					_matrix.scale(sx, sy);
					
					if (angle != 0)
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
					
					_matrix.translate(_point.x + ox, _point.y + oy);
					_colorParams.setMultipliers(textRed, textGreen, textBlue, tAlpha);
					
					view.drawPixels(currFrame, material, _matrix, _colorParams);
				}
				
				#if FLX_DEBUG
				FlxBasic.visibleCount++;
				#end
			}
			
			#if FLX_DEBUG
			if (FlxG.debugger.drawDebug)
				drawDebug();
			#end
		}
	}
	
	override private function set_color(Color:FlxColor):FlxColor
	{
		super.set_color(Color);
		
		if (FlxG.renderBlit)
			pendingTextBitmapChange = true;
		
		return color;
	}
	
	override private function set_alpha(value:Float):Float
	{
		super.set_alpha(value);
		
		if (FlxG.renderBlit)
			pendingTextBitmapChange = true;
		
		return value;
	}
	
	private function set_textColor(value:FlxColor):FlxColor 
	{
		if (textColor != value)
		{
			textColor = value;
			
			if (FlxG.renderBlit)
				pendingPixelsChange = true;
		}
		
		return value;
	}
	
	private function set_useTextColor(value:Bool):Bool 
	{
		if (useTextColor != value)
		{
			useTextColor = value;
			
			if (FlxG.renderBlit)
				pendingPixelsChange = true;
		}
		
		return value;
	}
	
	override private function calcFrame(RunOnCpp:Bool = false):Void 
	{
		if (FlxG.renderTile)
			drawFrame(RunOnCpp);
		else
			super.calcFrame(RunOnCpp);
	}
	
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
		
		_lines.splice(0, _lines.length);
		var currLine:Array<Int> = [];
		_lines.push(currLine);
		
		var len:Int = Utf8.length(tmp);
		for (i in 0...len)
		{
			var charCode:Int = Utf8.charCodeAt(tmp, i);
			
			if (charCode == FlxBitmapFont.NEW_LINE_CODE || charCode == FlxBitmapFont.CARRIAGE_RETURN_CODE)
			{
				currLine = [];
				_lines.push(currLine);
			}
			else
			{
				currLine.push(charCode);
			}
		}
		
		if (!autoSize)
		{
			if (wordWrap)
				wrap();
			else
				cutLines();
		}
		
		if (!multiLine)
			_lines = [_lines[0]];
		
		var numLines:Int = _lines.length;
		for (i in 0...numLines)
			_lines[i] = rtrim(_lines[i]);
		
		pendingTextChange = false;
		pendingTextBitmapChange = true;
	}
	
	private function rtrim(line:Array<Int>):Array<Int>
	{
		var i:Int = line.length - 1;
		
		while (i >= 0)
		{
			var charCode:Int = line[i];
			
			if (charCode == FlxBitmapFont.SPACE_CODE || charCode == FlxBitmapFont.TAB_CODE)
				line.splice(i, 1);
			else
				return line;
			
			i--;
		}
		
		return line;
	}
	
	/**
	 * Calculates the size of text field.
	 */
	private function computeTextSize():Void 
	{
		var txtWidth:Int = textWidth;
		var txtHeight:Int = textHeight + 2 * padding;
		
		if (autoSize)
			txtWidth += 2 * padding;
		else
			txtWidth = fieldWidth;
		
		frameWidth = (txtWidth == 0) ? 1 : txtWidth;
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
			return 0;
		
		return getArrayIntWidth(_lines[lineIndex]);
	}
	
	/**
	 * Calculates width of provided string (for current font).
	 * 
	 * @param	str	String to calculate width for
	 * @return	The width of result bitmap text.
	 */
	public function getStringWidth(str:String):Float
	{
		var ints:Array<Int> = [];
		var length:Int = Utf8.length(str);
		
		for (i in 0...length)
			ints.push(Utf8.charCodeAt(str, i));
		
		return getArrayIntWidth(ints);
	}
	
	private function getArrayIntWidth(str:Array<Int>):Float
	{
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var lineLength:Int = str.length;		// lenght of the current line
		var lineWidth:Float = font.minOffsetX;
		
		var charCode:Int;						// current character in word
		var prevCharCode:Int = -1;
		var charWidth:Float;					// the width of current character
		var character:FlxCharacter;
		
		for (c in 0...lineLength)
		{
			charCode = str[c];
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
				character = font.getCharacter(charCode);
				charWidth = character.xAdvance;
				
				if (c == (lineLength - 1))
					charWidth = character.width;
					
				if (useKerning)
					charWidth += font.getCharKerning(charCode, prevCharCode);
			}
			
			lineWidth += (charWidth + letterSpacing);
			prevCharCode = charCode;
		}
		
		if (lineLength > 0)
			lineWidth -= letterSpacing;
		
		return lineWidth;
	}
	
	/**
	 * Just cuts the lines which are too long to fit in the field.
	 */
	private function cutLines():Void 
	{
		var c:Int;					// char index
		var charCode:Int;			// code for the current character in word
		var charWidth:Float;		// the width of current character
		
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var startX:Int = font.minOffsetX;
		
		for (line in _lines)
		{
			var lineLength:Int = line.length;
			var subLineWidth:Float = startX;	// the width of current subline
			var prevCharCode:Int = -1;
			
			c = 0;
			while (c < lineLength)
			{
				charCode = line[c];
				
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
					
					if (useKerning)
						charWidth += font.getCharKerning(charCode, prevCharCode);
				}
				
				charWidth += letterSpacing;
				
				if (subLineWidth + charWidth > _fieldWidth - 2 * padding)
				{
					subLineWidth = startX;
					line.splice(c + 1, lineLength - (c + 1));
					c = lineLength;
					prevCharCode = -1;
				}
				else
				{
					subLineWidth += charWidth;
					prevCharCode = charCode;
				}
				
				c++;
			}
		}
	}
	
	/**
	 * Automatically wraps text by figuring out how many characters can fit on a
	 * single line, and splitting the remainder onto a new line.
	 */
	private function wrap():Void
	{
		if (wrapByWord)
			_lines = wrapByWords(_lines);
		else
			_lines = wrapByCharacters(_lines);
	}
	
	/**
	 * Wraps lines by characters. 
	 */
	private function wrapByCharacters(lines:Array<Array<Int>>):Array<Array<Int>>
	{
		var newLines:Array<Array<Int>> = [];
		var newLine:Array<Int> = null;
		
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		for (line in _lines)
		{
			var lineLength:Int = line.length;
			newLine = [];
			var lineWidth:Float = font.minOffsetX;
			var prevCharCode:Int = -1;
			var lastSpaceIndex:Int = -1;
			var charWidth:Float = 0.0;
			var lineFull:Bool = false;
			
			var i:Int = 0;
			
			while (i < lineLength)
			{
				lineFull = false;
				var charCode:Int = line[i];
				charWidth = 0;
				
				if (charCode == FlxBitmapFont.SPACE_CODE)
				{
					charWidth = spaceWidth;
					lastSpaceIndex = i;
				}
				else if (charCode == FlxBitmapFont.TAB_CODE)
				{
					charWidth = tabWidth;
					lastSpaceIndex = i;
				}
				else
				{
					charWidth = font.getCharWidth(charCode);
				}
				
				if (useKerning)
					charWidth += font.getCharKerning(charCode, prevCharCode);
				
				if (lineWidth + charWidth > _fieldWidth - 2 * padding)
					lineFull = true;
				
				if (lineFull)
				{
					newLines.push(newLine);
					newLine = [];
					lineWidth = font.minOffsetX;
					prevCharCode = -1;
					
					if (lastSpaceIndex != i)
					{
						newLine.push(charCode);
						lineWidth += charWidth;
					}
				}
				else if (!(i > 0 && newLine.length == 0 && lastSpaceIndex == i)) // don't add spaces left from previous subline.
				{
					newLine.push(charCode);
					lineWidth += charWidth;
					prevCharCode = charCode;
				}
				
				i++;
			}
			
			if (newLine != null && newLine.length > 0)
				newLines.push(newLine);
		}
		
		return newLines;
	}
	
	/**
	 * Wraps lines by words. 
	 */
	private function wrapByWords(lines:Array<Array<Int>>):Array<Array<Int>>
	{
		var newLines:Array<Array<Int>> = [];
		var newLine:Array<Int> = null;
		
		var spaceWidth:Int = font.spaceWidth;
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		var maxWidth:Float = _fieldWidth - 2 * padding;
		
		for (line in _lines)
		{
			var lineLength:Int = line.length;
			newLine = [];
			var lineWidth:Float = font.minOffsetX;
			var wordWidth:Float = 0;
			var prevCharCode:Int = -1;
			var lastSpaceIndex:Int = -1;
			var wordStartIndex:Int = 0;
			var wordLength:Int = 0;
			var charWidth:Float = 0.0;
			var wordFinished:Bool = false;
			var sublineIndex:Int = 0;
			
			var i:Int = 0;
			
			while (i < lineLength)
			{
				wordFinished = false;
				var charCode:Int = line[i];
				var breakWord:Bool = false;
				charWidth = 0;
				
				if (charCode == FlxBitmapFont.SPACE_CODE)
				{
					charWidth = spaceWidth;
					lastSpaceIndex = i;
				}
				else if (charCode == FlxBitmapFont.TAB_CODE)
				{
					charWidth = tabWidth;
					lastSpaceIndex = i;
				}
				else
				{
					charWidth = font.getCharWidth(charCode);
				}
				
				if (useKerning)
					charWidth += font.getCharKerning(charCode, prevCharCode);
				
				var nextChar:Int = (i + 1 >= lineLength) ? -1 : line[i + 1];
				var isNextSpace:Bool = (nextChar == FlxBitmapFont.SPACE_CODE) || (nextChar == FlxBitmapFont.TAB_CODE);
				
				// word is finished if current character is hyphen,
				// or character switches from space to any other symbol or vice versa, 
				// or it is the end of the line text
				wordFinished = (charCode == FlxBitmapFont.HYPHEN_CODE) || (isNextSpace != (lastSpaceIndex == i) || nextChar == -1);
				
				// find out if the word isn't too long to fit in one line
				breakWord = (wordWidth + charWidth > maxWidth); // && (sublineIndex == 0 && lastSpaceIndex == i);
				
				// don't break "space word" if it's not on the first sub line of current line.
				if (breakWord && lastSpaceIndex == i)
					breakWord = (sublineIndex == 0);
				
				if (!breakWord)
				{
					wordWidth += charWidth;
					wordLength++;
				}
				else
				{
					charWidth -= font.getCharKerning(charCode, prevCharCode);
				}
				
				if (breakWord)
				{
					// break current word
					if (newLine.length > 0)
						newLines.push(newLine);
					
					newLine = [];
					
					for (j in 0...wordLength)
						newLine.push(line[wordStartIndex + j]);
					
					newLines.push(newLine);
					newLine = [];
					
					lineWidth = font.minOffsetX;
					wordStartIndex = i;
					wordLength = 1;
					wordWidth = charWidth;
					
					prevCharCode = -1;
					
					sublineIndex++;
				}
				else if (wordFinished)
				{
					if (lineWidth + wordWidth > maxWidth)
					{
						// start new line
						if (newLine.length > 0)
							newLines.push(newLine);
							
						newLine = [];
						
						if (lastSpaceIndex != i)
						{
							lineWidth = font.minOffsetX + wordWidth;
							
							for (j in 0...wordLength)
								newLine.push(line[wordStartIndex + j]);
						}
						
						sublineIndex++;
					}
					else
					{
						// continue current line
						for (j in 0...wordLength)
							newLine.push(line[wordStartIndex + j]);
							
						lineWidth += wordWidth;
					}
					
					wordStartIndex = i + 1;
					wordLength = 0;
					wordWidth = 0;
					
					prevCharCode = charCode;
				}
				
				i++;
			}
			
			if (newLine != null)
			{
				if (wordLength > 0)
				{
					for (j in 0...wordLength)
						newLine.push(line[wordStartIndex + j]);
				}
				
				if (newLine.length > 0)
					newLines.push(newLine);
			}
		}
		
		return newLines;
	}
	
	/**
	 * Internal method for updating helper data for text rendering
	 */
	private function updateTextBitmap(useTiles:Bool = false):Void 
	{
		computeTextSize();
		
		if (FlxG.renderBlit)
			useTiles = false;
		
		if (!useTiles)
		{
			textBitmap = FlxDestroyUtil.disposeIfNotEqual(textBitmap, frameWidth, frameHeight);
			
			if (textBitmap == null)
				textBitmap = new BitmapData(frameWidth, frameHeight, true, FlxColor.TRANSPARENT);
			else
				textBitmap.fillRect(textBitmap.rect, FlxColor.TRANSPARENT);
			
			textBitmap.lock();
		}
		else if (FlxG.renderTile)
		{
			textData.splice(0, textData.length);
		}
		
		_fieldWidth = frameWidth;
		
		var numLines:Int = _lines.length;
		var line:Array<Int>;
		var lineWidth:Int;
		
		var ox:Int, oy:Int;
		
		for (i in 0...numLines)
		{
			line = _lines[i];
			lineWidth = Math.ceil(_linesWidth[i]);
			
			// LEFT
			ox = font.minOffsetX;
			oy = i * (font.lineHeight + lineSpacing) + padding;
			
			if (alignment == FlxTextAlign.CENTER)
				ox += Std.int((frameWidth - lineWidth) / 2);
			else if (alignment == FlxTextAlign.RIGHT)
				ox += (frameWidth - lineWidth) - padding;
			else	// LEFT OR JUSTIFY
				ox += padding;
			
			drawLine(i, ox, oy, useTiles);
		}
		
		if (!useTiles)
			textBitmap.unlock();
		
		pendingTextBitmapChange = false;
	}
	
	private function drawLine(lineIndex:Int, posX:Int, posY:Int, useTiles:Bool = false):Void
	{
		if (FlxG.renderBlit)
			useTiles = false;
		
		if (useTiles)
			tileLine(lineIndex, posX, posY);
		else
			blitLine(lineIndex, posX, posY);
	}
	
	private function blitLine(lineIndex:Int, startX:Int, startY:Int):Void
	{
		var character:FlxCharacter;
		var charCode:Int;
		var prevCharCode:Int = -1;
		var curX:Float = startX;
		var curY:Int = startY;
		
		var line:Array<Int> = _lines[lineIndex];
		var spaceWidth:Int = font.spaceWidth;
		var lineLength:Int = line.length;
		var textWidth:Int = this.textWidth;
		
		if (alignment == FlxTextAlign.JUSTIFY)
		{
			var numSpaces:Int = 0;
			
			for (i in 0...lineLength)
			{
				charCode = line[i];
				
				if (charCode == FlxBitmapFont.SPACE_CODE)
					numSpaces++;
				else if (charCode == FlxBitmapFont.TAB_CODE)
					numSpaces += numSpacesInTab;
			}
			
			var lineWidth:Float = getArrayIntWidth(line);
			var totalSpacesWidth:Int = numSpaces * font.spaceWidth;
			spaceWidth = Std.int((textWidth - lineWidth + totalSpacesWidth) / numSpaces);
		}
		
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		for (i in 0...lineLength)
		{
			charCode = line[i];
			
			if (charCode == FlxBitmapFont.SPACE_CODE)
			{
				curX += spaceWidth;
			}
			else if (charCode == FlxBitmapFont.TAB_CODE)
			{
				curX += tabWidth;
			}
			else
			{
				character = font.getCharacter(charCode);
				
				if (useKerning)
					curX += font.getCharKerning(charCode, prevCharCode);
				
				if (character != null)
				{
					_flashPoint.setTo(curX, curY);
					character.frame.paint(textBitmap, _flashPoint, true);
					var charUt8 = new Utf8();
					charUt8.addChar(charCode);
					curX += character.xAdvance;
				}
			}
			
			curX += letterSpacing;
			prevCharCode = charCode;
		}
	}
	
	private function tileLine(lineIndex:Int, startX:Int, startY:Int):Void
	{
		if (!FlxG.renderTile) return;
		
		var character:FlxCharacter;
		var pos:Int = textData.length;
		
		var charCode:Int;
		var prevCharCode:Int = -1;
		var curX:Float = startX;
		var curY:Int = startY;
		
		var line:Array<Int> = _lines[lineIndex];
		var spaceWidth:Int = font.spaceWidth;
		var lineLength:Int = line.length;
		var textWidth:Int = this.textWidth;
		
		if (alignment == FlxTextAlign.JUSTIFY)
		{
			var numSpaces:Int = 0;
			
			for (i in 0...lineLength)
			{
				charCode = line[i];
				
				if (charCode == FlxBitmapFont.SPACE_CODE)
					numSpaces++;
				else if (charCode == FlxBitmapFont.TAB_CODE)
					numSpaces += numSpacesInTab;
			}
			
			var lineWidth:Float = getArrayIntWidth(line);
			var totalSpacesWidth:Int = numSpaces * font.spaceWidth;
			spaceWidth = Std.int((textWidth - lineWidth + totalSpacesWidth) / numSpaces);
		}
		
		var tabWidth:Int = spaceWidth * numSpacesInTab;
		
		for (i in 0...lineLength)
		{
			charCode = line[i];
			
			if (charCode == FlxBitmapFont.SPACE_CODE)
			{
				curX += spaceWidth;
			}
			else if (charCode == FlxBitmapFont.TAB_CODE)
			{
				curX += tabWidth;
			}
			else
			{
				character = font.getCharacter(charCode);
				
				if (useKerning)
					curX += font.getCharKerning(charCode, prevCharCode);
				
				if (character != null)
				{
					textData[pos++] = charCode;
					textData[pos++] = curX;
					textData[pos++] = curY;
					curX += character.xAdvance;
				}
			}
			
			curX += letterSpacing;
			prevCharCode = charCode;
		}
	}
	
	private function updatePixels(useTiles:Bool = false):Void
	{
		var colorForFill:Int = background ? backgroundColor : FlxColor.TRANSPARENT;
		var bitmap:BitmapData = null;
		
		if (FlxG.renderBlit)
		{
			if (pixels == null || (frameWidth != pixels.width || frameHeight != pixels.height))
				pixels = new BitmapData(frameWidth, frameHeight, true, colorForFill);
			else
				pixels.fillRect(graphic.bitmap.rect, colorForFill);
			
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
			bitmap.lock();
		
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
			bitmap.unlock();
		
		if (FlxG.renderBlit)
			dirty = true;
		
		pendingPixelsChange = false;
	}
	
	private function drawText(posX:Int, posY:Int, isFront:Bool = true, ?bitmap:BitmapData, useTiles:Bool = false):Void
	{
		if (FlxG.renderBlit)
			useTiles = false;
		
		if (useTiles)
			tileText(posX, posY, isFront);
		else
			blitText(posX, posY, isFront, bitmap);
	}
	
	private function blitText(posX:Int, posY:Int, isFront:Bool = true, ?bitmap:BitmapData):Void
	{
		_matrix.identity();
		_matrix.translate(posX, posY);
		
		var colorToApply = FlxColor.WHITE;
		
		if (isFront && useTextColor)
			colorToApply = textColor;
		else if (!isFront)
			colorToApply = borderColor;
		
		_colorParams.setMultipliers(
			colorToApply.redFloat, colorToApply.greenFloat,
			colorToApply.blueFloat, colorToApply.alphaFloat);
		
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
	
	private function tileText(posX:Int, posY:Int, isFront:Bool = true):Void
	{
		if (!FlxG.renderTile) return;
		
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
			shadowOffset.set(borderSize, borderSize);
		
		pendingTextBitmapChange = true;
	}
	
	private function checkBackgroundMaterial():Void
	{
		if (background)
		{
			if (backgroundMaterial == null)
				backgroundMaterial = new FlxMaterial();
			
			backgroundMaterial.smoothing = smoothing;
			backgroundMaterial.blendMode = blend;
		}
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
			smoothing = smoothing || font.distanceField;
			
			#if FLX_RENDER_GL
			if (shader == null && font.distanceField)
			{
				shader = FlxBitmapFont.DistanceFieldShader;
				shader.data.smoothing.value = [FlxDistanceFieldShader.DEFAULT_FONT_SMOOTHING];
			}
			#end
			
			pendingTextChange = true;
		}
		
		return value;
	}
	
	private function set_lineSpacing(value:Int):Int
	{
		if (lineSpacing != value)
		{
			lineSpacing = value;
			pendingTextBitmapChange = true;
		}
		
		return lineSpacing;
	}
	
	private function set_letterSpacing(value:Int):Int
	{
		if (value != letterSpacing)
		{
			letterSpacing = value;
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
	
	private function set_useKerning(value:Bool):Bool
	{
		if (useKerning != value)
		{
			useKerning = value;
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
			
			if (FlxG.renderBlit)
				pendingPixelsChange = true;
			
			checkBackgroundMaterial();
		}
		
		return value;
	}
	
	private function set_backgroundColor(value:Int):Int 
	{
		if (backgroundColor != value)
		{
			backgroundColor = value;
			
			if (FlxG.renderBlit)
				pendingPixelsChange = true;
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
			
			if (FlxG.renderBlit)
				pendingPixelsChange = true;
		}
		
		return value;
	}
	
	private function set_borderSize(value:Float):Float
	{
		if (value != borderSize)
		{			
			borderSize = value;
			
			if (borderStyle != FlxTextBorderStyle.NONE)
				pendingTextBitmapChange = true;
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
				pendingTextBitmapChange = true;
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
		var max:Float = 0;
		var numLines:Int = _lines.length;
		var lineWidth:Float;
		_linesWidth = [];
		
		for (i in 0...numLines)
		{
			lineWidth = getLineWidth(i);
			_linesWidth[i] = lineWidth;
			max = (max > lineWidth) ? max : lineWidth;
		}
		
		return Math.ceil(max);
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
	
	override function set_blend(Value:BlendMode):BlendMode 
	{
		super.set_blend(Value);
		checkBackgroundMaterial();
		return Value;
	}
	
	
}
