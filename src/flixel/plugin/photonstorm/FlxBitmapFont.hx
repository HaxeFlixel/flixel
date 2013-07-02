package flixel.plugin.photonstorm;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.layer.DrawStackItem;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;

/**
 * FlxBitmapFont
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 * @see Requires FlxMath
*/

class FlxBitmapFont extends FlxSprite
{
	/**
	 * Align each line of multi-line text to the left.
	 */
	inline static public var ALIGN_LEFT:String = "left";
	/**
	 * Align each line of multi-line text to the right.
	 */
	inline static public var ALIGN_RIGHT:String = "right";
	/**
	 * Align each line of multi-line text in the center.
	 */
	inline static public var ALIGN_CENTER:String = "center";
	
	/**
	 * Text Set 1 = !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
	 */
	inline static public var TEXT_SET1:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
	/**
	 * Text Set 2 =  !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	inline static public var TEXT_SET2:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	/**
	 * Text Set 3 = ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 
	 */
	inline static public var TEXT_SET3:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
	/**
	 * Text Set 4 = ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
	 */
	inline static public var TEXT_SET4:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";
	/**
	 * Text Set 5 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789
	 */
	inline static public var TEXT_SET5:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789";
	/**
	 * Text Set 6 = ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' 
	 */
	inline static public var TEXT_SET6:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' ";
	/**
	 * Text Set 7 = AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39
	 */
	inline static public var TEXT_SET7:String = "AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39";
	/**
	 * Text Set 8 = 0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	inline static public var TEXT_SET8:String = "0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	/**
	 * Text Set 9 = ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!
	 */
	inline static public var TEXT_SET9:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!";
	/**
	 * Text Set 10 = ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	inline static public var TEXT_SET10:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	/**
	 * Text Set 11 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789
	 */
	inline static public var TEXT_SET11:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789";
	
	/**
	 * Alignment of the text when multiLine = true or a fixedWidth is set. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 */
	public var align:String = "left";
	/**
	 * If set to true all carriage-returns in text will form new lines (see align). If false the font will only contain one single line of text (the default)
	 */
	public var multiLine:Bool = false;
	/**
	 * Automatically convert any text to upper case. Lots of old bitmap fonts only contain upper-case characters, so the default is true.
	 */
	public var autoUpperCase:Bool = true;
	/**
	 * Adds horizontal spacing between each character of the font, in pixels. Default is 0.
	 */
	public var customSpacingX:Int = 0;
	/**
	 * Adds vertical spacing between each line of multi-line text, set in pixels. Default is 0.
	 */
	public var customSpacingY:Int = 0;
	
	public var characterWidth:Int;
	public var characterHeight:Int;
	
	#if !flash
	/**
	 * Offsets for each letter in the sprite (not affected by scale and rotation)
	 */
	private var _points:Array<Float>;
	/**
	 * Frame IDs for each letter in the font set bitmapData
	 */
	private var _charFrameIDs:Array<Int>;
	#end
	
	/**
	 * Internval values. All set in the constructor. They should not be changed after that point.
	 */
	private var _fontSet:BitmapData;
	private var _grabData:Array<Rectangle>;
	private var _offsetX:Int;
	private var _offsetY:Int;
	private var _characterSpacingX:Int;
	private var _characterSpacingY:Int;
	private var _characterPerRow:Int;
	private var _fixedWidth:Int = 0;
	private var _text:String = "";
	private var _charsInFont:String;
	private var _textWidth:Int;
	private var _textHeight:Int;
	
	/**
	 * Loads 'font' and prepares it for use by future calls to .text
	 * 
	 * @param	Font			The font set graphic class (as defined by your embed)
	 * @param	CharacterWidth	The width of each character in the font set.
	 * @param	CharacterHeight	The height of each character in the font set.
	 * @param	Chars			The characters used in the font set, in display order. You can use the TEXT_SET consts for common font set arrangements.
	 * @param	CharsPerRow		The number of characters per row in the font set.
	 * @param	SpacingX		If the characters in the font set have horizontal spacing between them set the required amount here.
	 * @param	SpacingY		If the characters in the font set have vertical spacing between them set the required amount here
	 * @param	OffsetX			If the font set doesn't start at the top left of the given image, specify the X coordinate offset here.
	 * @param	OffsetY			If the font set doesn't start at the top left of the given image, specify the Y coordinate offset here.
	 */
	public function new(Font:Dynamic, CharacterWidth:Int, CharacterHeight:Int, Chars:String, CharsPerRow:Int, SpacingX:Int = 0, SpacingY:Int = 0, OffsetX:Int = 0, OffsetY:Int = 0)
	{
		super();
		
		characterWidth = CharacterWidth;
		characterHeight = CharacterHeight;
		_characterSpacingX = SpacingX;
		_characterSpacingY = SpacingY;
		_characterPerRow = CharsPerRow;
		_offsetX = OffsetX;
		_offsetY = OffsetY;
		
		_charsInFont = Chars;
		
		// Take a copy of the font for internal use
		#if flash
		_fontSet = FlxG.bitmap.add(Font);
		#else
		_fontSet = FlxG.bitmap.add(Font, false, false, null, (_characterSpacingX == 0) ? CharacterWidth : 0, (_characterSpacingY == 0) ? CharacterHeight : 0);
		pixels = _fontSet;
		#end
		
		#if flash
		updateCharFrameIDs();
		#end
	}
	
	override public function updateFrameData():Void 
	{
		#if !flash
		if (_node != null && _charsInFont != null)
		{
			updateCharFrameIDs();
		}
		#end
	}
	
	override public function destroy():Void 
	{
		_fontSet = null;
		_grabData = null;
		
		#if !flash
		_points = null;
		_charFrameIDs = null;
		#end
		
		super.destroy();
	}
	
	private function updateCharFrameIDs():Void
	{
		_grabData = new Array();
		
		//	Now generate our rects for faster copyPixels later on
		var currentX:Int = _offsetX;
		var currentY:Int = _offsetY;
		var r:Int = 0;
		
		#if !flash
		var spacingX:Int = (_characterSpacingX == 0) ? 1 : _characterSpacingX;
		var spacingY:Int = (_characterSpacingY == 0) ? 1 : _characterSpacingY;
		#else
		var spacingX:Int = _characterSpacingX;
		var spacingY:Int = _characterSpacingY;
		#end
		
		#if !flash
		_charFrameIDs = new Array<Int>();
		var frameID:Int = 0;
		var rowNumber:Int = 0;
		var maxPossibleCharsPerRow:Int = Std.int((_fontSet.width - _offsetX) / (characterWidth + spacingX));
		#end
		
		for (c in 0..._charsInFont.length)
		{
			// The rect is hooked to the ASCII value of the character
			_grabData[_charsInFont.charCodeAt(c)] = new Rectangle(currentX, currentY, characterWidth, characterHeight);
			
			#if !flash
			_charFrameIDs[_charsInFont.charCodeAt(c)] = _node.addTileRect(_grabData[_charsInFont.charCodeAt(c)]);
			#end
			
			r++;
			
			if (r == Std.int(_characterPerRow))
			{
				r = 0;
				currentX = _offsetX;
				currentY += characterHeight + spacingY;
				#if !flash
				rowNumber++;
				frameID = maxPossibleCharsPerRow * rowNumber;
				#end
			}
			else
			{
				currentX += characterWidth + spacingX;
				#if !flash
				frameID++;
				#end
			}
		}
		
		#if !flash
		updateTextString(text);
		#end
	}
	
	#if !flash
	override public function draw():Void 
	{
		if (_atlas == null)
		{
			return;
		}
		
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			
			if (_flicker)
			{
				return;
			}
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var j:Int = 0;
		var textLength:Int = Std.int(_points.length / 3);
		var currPosInArr:Int;
		var currTileID:Float;
		var currTileX:Float;
		var currTileY:Float;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		var relativeX:Float;
		var relativeY:Float;
		
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		
		#if !js
		var isColored:Bool = isColored();
		#else
		var useAlpha:Bool = (alpha < 1);
		#end
		
		while (i < l)
		{
			camera = cameras[i++];
			#if !js
			drawItem = camera.getDrawStackItem(_atlas, isColored, _blendInt, antialiasing);
			#else
			drawItem = camera.getDrawStackItem(_atlas, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x) + origin.x;
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end

			var x1:Float = 0;
			var y1:Float = 0;
			
			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;

			if (!simpleRenderSprite ())
			{
				radians = angle * FlxAngle.TO_RAD;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				x1 = (origin.x - _halfWidth);
				y1 = (origin.y - _halfHeight);
				
				csx = cos * scale.x;
				ssy = sin * scale.y;
				ssx = sin * scale.x;
				csy = cos * scale.y;
			}

			while (j < textLength)
			{
				currPosInArr = j * 3;
				currTileID = _points[currPosInArr];
				currTileX = _points[currPosInArr + 1] - x1;
				currTileY = _points[currPosInArr + 2] - y1;

				relativeX = (currTileX * csx - currTileY * ssy);
				relativeY = (currTileX * ssx + currTileY * csy);
				
				currDrawData[currIndex++] = (_point.x) + relativeX;
				currDrawData[currIndex++] = (_point.y) + relativeY;
				
				currDrawData[currIndex++] = currTileID;
				
				currDrawData[currIndex++] = csx;
				currDrawData[currIndex++] = ssx;
				currDrawData[currIndex++] = -ssy;
				currDrawData[currIndex++] = csy;

				#if !js
				if (isColored)
				{
					currDrawData[currIndex++] = _red;
					currDrawData[currIndex++] = _green;
					currDrawData[currIndex++] = _blue;
				}
				currDrawData[currIndex++] = alpha;
				#else
				if (useAlpha)
				{
					currDrawData[currIndex++] = alpha;
				}
				#end
				
				j++;
			}
			
			drawItem.position = currIndex;
		}
	}
	#end
	
	/**
	 * Set this value to update the text in this sprite. Carriage returns are automatically stripped 
	 * out if multiLine is false. Text is converted to upper case if autoUpperCase is true.
	 */ 
	public var text(get, set):String;
	
	private function get_text():String
	{
		return _text;
	}
	
	private function set_text(NewText:String):String
	{
		var newText:String;
		
		if (autoUpperCase)
		{
			newText = NewText.toUpperCase();
		}
		else
		{
			newText = NewText;
		}
		
		// Smart update: Only change the bitmap data if the string has changed
		if (newText != _text)
		{
			updateTextString(newText);
		}
		
		return _text;
	}
	
	private function updateTextString(NewText:String):Void
	{
		_text = NewText;
		removeUnsupportedCharacters(multiLine);
		buildBitmapFontText();
	}
	
	/**
	 * If you need this FlxSprite to have a fixed width and custom alignment you can set the width here.<br>
	 * If text is wider than the width specified it will be cropped off.
	 * 
	 * @param	Width			Width in pixels of this FlxBitmapFont. Set to zero to disable and re-enable automatic resizing.
	 * @param	LineAlignment	Align the text within this width. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 */
	public function setFixedWidth(Width:Int, LineAlignment:String = "left"):Void
	{
		_fixedWidth = Width;
		align = LineAlignment;
	}
	
	/**
	 * A helper function that quickly sets lots of variables at once, and then updates the text.
	 * 
	 * @param	Text				The text of this sprite
	 * @param	MultiLines			Set to true if you want to support carriage-returns in the text and create a multi-line sprite instead of a single line (default is false).
	 * @param	CharacterSpacing	To add horizontal spacing between each character specify the amount in pixels (default 0).
	 * @param	LineSpacing			To add vertical spacing between each line of text, set the amount in pixels (default 0).
	 * @param	LineAlignment		Align each line of multi-line text. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 * @param	AllowLowerCase		Lots of bitmap font sets only include upper-case characters, if yours needs to support lower case then set this to true.
	 */
	public function setText(Text:String, MultiLines:Bool = false, CharacterSpacing:Int = 0, LineSpacing:Int = 0, LineAlignment:String = "left", AllowLowerCase:Bool = false):Void
	{
		customSpacingX = CharacterSpacing;
		customSpacingY = LineSpacing;
		align = LineAlignment;
		multiLine = MultiLines;
		
		if (AllowLowerCase)
		{
			autoUpperCase = false;
		}
		else
		{
			autoUpperCase = true;
		}
		
		if (Text.length > 0)
		{
			text = Text;
		}
	}
	
	/**
	 * Updates the BitmapData of the Sprite with the text
	 */
	private function buildBitmapFontText():Void
	{
		var temp:BitmapData;
		var cx:Int = 0;
		var cy:Int = 0;
		
		#if !flash
		if (_points == null)
		{
			_points = new Array<Float>();
		}
		else
		{
			_points.splice(0, _points.length);
		}
		#end
		
		if (multiLine)
		{
			var lines:Array<String> = _text.split("\n");
			_textHeight = (lines.length * (characterHeight + customSpacingY)) - customSpacingY;
			
			if (_fixedWidth > 0)
			{
				_textWidth = _fixedWidth;
				
				#if flash
				temp = new BitmapData(_fixedWidth, _textHeight, true, 0xf);
				#end
			}
			else
			{
				_textWidth = getLongestLine() * (characterWidth + customSpacingX);
				
				#if flash
				temp = new BitmapData(_textWidth, _textHeight, true, 0xf);
				#end
			}
			
			// Loop through each line of text
			for (i in 0...lines.length)
			{
				// This line of text is held in lines[i] - need to work out the alignment
				switch (align)
				{
					case ALIGN_LEFT:
						cx = 0;
					case ALIGN_RIGHT:
						cx = _textWidth - (lines[i].length * (characterWidth + customSpacingX));
					case ALIGN_CENTER:
						cx = Math.floor((_textWidth / 2) - ((lines[i].length * (characterWidth + customSpacingX)) / 2));
						cx += Math.floor(customSpacingX / 2);
				}
				
				// Sanity checks
				if (cx < 0)
				{
					cx = 0;
				}
				
				#if flash
				pasteLine(temp, lines[i], cx, cy, customSpacingX);
				#else
				origin.make(_textWidth * 0.5, _textHeight * 0.5);
				pasteLine(lines[i], cx, cy, customSpacingX);
				#end
				
				cy += characterHeight + customSpacingY;
			}
		}
		else
		{
			_textHeight = characterHeight;
			
			if (_fixedWidth > 0)
			{
				_textWidth = _fixedWidth;
				
				#if flash
				temp = new BitmapData(_textWidth, _textHeight, true, 0xf);
				#end
			}
			else
			{
				_textWidth = _text.length * (characterWidth + customSpacingX);
				
				#if flash
				temp = new BitmapData(_textWidth, _textHeight, true, 0xf);
				#end
			}
			
			switch (align)
			{
				case ALIGN_LEFT:
					cx = 0;
				case ALIGN_RIGHT:
					cx = _textWidth - (_text.length * (characterWidth + customSpacingX));
				case ALIGN_CENTER:
					cx = Math.floor((_textWidth / 2) - ((_text.length * (characterWidth + customSpacingX)) / 2));
					cx += Math.floor(customSpacingX / 2);
			}
			
			#if flash
			pasteLine(temp, _text, cx, 0, customSpacingX);
			#else
			origin.make(_textWidth * 0.5, _textHeight * 0.5);
			pasteLine(_text, cx, 0, customSpacingX);
			#end
		}
		
		#if flash
		pixels = temp;
		#else
		width = frameWidth = _textWidth;
		height = frameHeight = _textHeight;
		_halfWidth = 0.5 * width;
		_halfHeight = 0.5 * height;
		frames = 1;
		centerOffsets();
		#end
	}
	
	/**
	 * Returns a single character from the font set as an FlxSprite.
	 * 
	 * @param	Char	The character you wish to have returned.
	 * @return	A <code>FlxSprite</code> containing a single character from the font set.
	 */
	public function getCharacter(Char:String):FlxSprite
	{
		var output:FlxSprite = new FlxSprite();
		var temp:BitmapData = new BitmapData(characterWidth, characterHeight, true, FlxColor.TRANSPARENT);

		if (_grabData[Char.charCodeAt(0)] != null && Char.charCodeAt(0) != 32)
		{
			temp.copyPixels(_fontSet, _grabData[Char.charCodeAt(0)], new Point(0, 0));
		}
		
		output.pixels = temp;
		
		return output;
	}
	
	/**
	 * Returns a single character from the font set as bitmapData
	 * 
	 * @param	Char	The character you wish to have returned.
	 * @return	<code>bitmapData</code> containing a single character from the font set.
	 */
	public function getCharacterAsBitmapData(Char:String):BitmapData
	{
		var temp:BitmapData = new BitmapData(characterWidth, characterHeight, true, FlxColor.TRANSPARENT);
		
		if (_grabData[Char.charCodeAt(0)] != null)
		{
			temp.copyPixels(_fontSet, _grabData[Char.charCodeAt(0)], new Point(0, 0));
		}
		
		return temp;
	}
	
	/**
	 * Internal function that takes a single line of text (2nd parameter) and pastes it into the BitmapData at the given coordinates.
	 * Used by getLine and getMultiLine
	 * 
	 * @param	Output			The BitmapData that the text will be drawn onto
	 * @param	Line			The single line of text to paste
	 * @param	X				The x coordinate
	 * @param	Y
	 * @param	CustomSpacingX
	 */
	#if flash
	private function pasteLine(Output:BitmapData, Line:String, X:UInt = 0, Y:UInt = 0, CustomSpacingX:UInt = 0):Void
	#else
	private function pasteLine(Line:String, X:Int = 0, Y:Int = 0, CustomSpacingX:Int = 0):Void
	#end
	{
		for (c in 0...Line.length)
		{
			//	If it's a space then there is no point copying, so leave a blank space
			if (Line.charAt(c) == " ")
			{
				X += characterWidth + CustomSpacingX;
			}
			else
			{
				//	If the character doesn't exist in the font then we don't want a blank space, we just want to skip it
				if (_grabData[Line.charCodeAt(c)] != null)
				{
					#if flash
					Output.copyPixels(_fontSet, _grabData[Line.charCodeAt(c)], new Point(X, Y));
					#else
					_points.push(_charFrameIDs[Line.charCodeAt(c)]);
					_points.push(x - origin.x);
					_points.push(y - origin.y);
					#end
					
					X += characterWidth + CustomSpacingX;
					
					#if flash
					if (Math.floor(x) > Output.width)
					#else
					if (Math.floor(x) > _textWidth)
					#end
					{
						break;
					}
				}
			}
		}
	}
	
	/**
	 * Works out the longest line of text in _text and returns its length
	 * 
	 * @return	A value
	 */
	private function getLongestLine():Int
	{
		var longestLine:Int = 0;
		
		if (_text.length > 0)
		{
			var lines:Array<String> = _text.split("\n");
			
			for (i in 0...lines.length)
			{
				if (lines[i].length > Math.floor(longestLine))
				{
					longestLine = lines[i].length;
				}
			}
		}
		
		return longestLine;
	}
	
	/**
	 * Internal helper function that removes all unsupported characters from the _text String, leaving only characters contained in the font set.
	 * 
	 * @param	StripCR		Should it strip carriage returns as well? (default = true)
	 * @return	A clean version of the string
	 */
	private function removeUnsupportedCharacters(StripCR:Bool = true):String
	{
		var newString:String = "";
		
		for (c in 0...(_text.length))
		{
			if (_grabData[_text.charCodeAt(c)] != null || _text.charCodeAt(c) == 32 || (StripCR == false && _text.charAt(c) == "\n"))
			{
				newString = newString + _text.charAt(c);
			}
		}
		
		return newString;
	}
}