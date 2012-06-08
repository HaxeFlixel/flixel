/**
 * FlxBitmapFont
 * -- Part of the Flixel Power Tools set
 * 
 * v1.4 Changed width/height to characterWidth/Height to avoid confusion and added setFixedWidth
 * v1.3 Exposed character width / height values
 * v1.2 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.4 - June 21st 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 * @see Requires FlxMath
*/

package org.flixel.plugin.photonstorm;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.flixel.FlxBasic;
import org.flixel.FlxG;
import org.flixel.FlxSprite;

#if (cpp || neko)
import org.flixel.tileSheetManager.TileSheetManager;
#end

class FlxBitmapFont extends FlxSprite
{
	/**
	 * Alignment of the text when multiLine = true or a fixedWidth is set. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 */
	public var align:String;
	
	/**
	 * If set to true all carriage-returns in text will form new lines (see align). If false the font will only contain one single line of text (the default)
	 */
	public var multiLine:Bool;
	
	/**
	 * Automatically convert any text to upper case. Lots of old bitmap fonts only contain upper-case characters, so the default is true.
	 */
	public var autoUpperCase:Bool;
	
	/**
	 * Adds horizontal spacing between each character of the font, in pixels. Default is 0.
	 */
	#if flash
	public var customSpacingX:UInt;
	#else
	public var customSpacingX:Int;
	#end
	
	/**
	 * Adds vertical spacing between each line of multi-line text, set in pixels. Default is 0.
	 */
	#if flash
	public var customSpacingY:UInt;
	#else
	public var customSpacingY:Int;
	#end
	
	private var _text:String;
	
	/**
	 * Align each line of multi-line text to the left.
	 */
	public static inline var ALIGN_LEFT:String = "left";
	
	/**
	 * Align each line of multi-line text to the right.
	 */
	public static inline var ALIGN_RIGHT:String = "right";
	
	/**
	 * Align each line of multi-line text in the center.
	 */
	public static inline var ALIGN_CENTER:String = "center";
	
	/**
	 * Text Set 1 = !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
	 */
	public static inline var TEXT_SET1:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
	
	/**
	 * Text Set 2 =  !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static inline var TEXT_SET2:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 3 = ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 
	 */
	public static inline var TEXT_SET3:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
	
	/**
	 * Text Set 4 = ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
	 */
	public static inline var TEXT_SET4:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";
	
	/**
	 * Text Set 5 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789
	 */
	public static inline var TEXT_SET5:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789";
	
	/**
	 * Text Set 6 = ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' 
	 */
	public static inline var TEXT_SET6:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' ";
	
	/**
	 * Text Set 7 = AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39
	 */
	public static inline var TEXT_SET7:String = "AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39";
	
	/**
	 * Text Set 8 = 0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static inline var TEXT_SET8:String = "0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 9 = ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!
	 */
	public static inline var TEXT_SET9:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!";
	
	/**
	 * Text Set 10 = ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static inline var TEXT_SET10:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 11 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789
	 */
	public static inline var TEXT_SET11:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789";
	
	/**
	 * Internval values. All set in the constructor. They should not be changed after that point.
	 */
	private var fontSet:BitmapData;
	private var grabData:Array<Rectangle>;
	#if flash
	private var offsetX:UInt;
	private var offsetY:UInt;
	public var characterWidth:UInt;
	public var characterHeight:UInt;
	private var characterSpacingX:UInt;
	private var characterSpacingY:UInt;
	private var characterPerRow:UInt;
	private var fixedWidth:UInt;
	#else
	private var offsetX:Int;
	private var offsetY:Int;
	public var characterWidth:Int;
	public var characterHeight:Int;
	private var characterSpacingX:Int;
	private var characterSpacingY:Int;
	private var characterPerRow:Int;
	private var fixedWidth:Int;
	#end
	
	#if (cpp || neko)
	/**
	 * offsets for each letter in the sprite (not affected by scale and rotation)
	 */
	private var points:Array<Float>;
	/**
	 * frame IDs for each letter in the font set bitmapData
	 */
	private var charFrameIDs:Array<Int>;
	#end
	
	private var _textWidth:Int;
	private var _textHeight:Int;
	
	/**
	 * Loads 'font' and prepares it for use by future calls to .text
	 * 
	 * @param	font			The font set graphic class (as defined by your embed)
	 * @param	characterWidth	The width of each character in the font set.
	 * @param	characterHeight	The height of each character in the font set.
	 * @param	chars			The characters used in the font set, in display order. You can use the TEXT_SET consts for common font set arrangements.
	 * @param	charsPerRow		The number of characters per row in the font set.
	 * @param	xSpacing		If the characters in the font set have horizontal spacing between them set the required amount here.
	 * @param	ySpacing		If the characters in the font set have vertical spacing between them set the required amount here
	 * @param	xOffset			If the font set doesn't start at the top left of the given image, specify the X coordinate offset here.
	 * @param	yOffset			If the font set doesn't start at the top left of the given image, specify the Y coordinate offset here.
	 */
	#if flash
	public function new(font:Dynamic, characterWidth:UInt, characterHeight:UInt, chars:String, charsPerRow:UInt, ?xSpacing:UInt = 0, ?ySpacing:UInt = 0, ?xOffset:UInt = 0, ?yOffset:UInt = 0)
	#else
	public function new(font:Dynamic, characterWidth:Int, characterHeight:Int, chars:String, charsPerRow:Int, ?xSpacing:Int = 0, ?ySpacing:Int = 0, ?xOffset:Int = 0, ?yOffset:Int = 0)
	#end
	{
		super();
		
		align = "left";
		multiLine = false;
		autoUpperCase = true;
		customSpacingX = 0;
		customSpacingY = 0;
		fixedWidth = 0;
		
		this.characterWidth = characterWidth;
		this.characterHeight = characterHeight;
		characterSpacingX = xSpacing;
		characterSpacingY = ySpacing;
		characterPerRow = charsPerRow;
		offsetX = xOffset;
		offsetY = yOffset;
		
		//	Take a copy of the font for internal use
		#if flash
		fontSet = FlxG.addBitmap(font);
		#else
		fontSet = FlxG.addBitmap(font, false, false, null, (characterSpacingX == 0) ? characterWidth : (characterWidth * charsPerRow), (characterSpacingY == 0) ? characterHeight : Math.floor((chars.length / charsPerRow) * characterHeight));
		#end
		
		grabData = new Array();
		
		//	Now generate our rects for faster copyPixels later on
		#if flash
		var currentX:UInt = offsetX;
		var currentY:UInt = offsetY;
		var r:UInt = 0;
		#else
		var currentX:Int = offsetX;
		var currentY:Int = offsetY;
		var r:Int = 0;
		
		updateTileSheet();
		charFrameIDs = new Array<Int>();
		var frameID:Int = 0;
		var rowNumber:Int = 0;
		var maxPossibleCharsPerRow:Int = Math.floor((fontSet.width - offsetX) / (characterWidth + characterSpacingX));
		#end
		
		for (c in 0...(chars.length))
		{
			//	The rect is hooked to the ASCII value of the character
			grabData[chars.charCodeAt(c)] = new Rectangle(currentX, currentY, characterWidth, characterHeight);
			
		#if (cpp || neko)
			charFrameIDs[chars.charCodeAt(c)] = _framesData.frameIDs[frameID];
		#end
			
			r++;
			
			if (r == characterPerRow)
			{
				r = 0;
				currentX = offsetX;
				currentY += characterHeight + characterSpacingY;
				
				#if (cpp || neko)
				rowNumber++;
				frameID = maxPossibleCharsPerRow * rowNumber;
				#end
			}
			else
			{
				currentX += characterWidth + characterSpacingX;
				
				#if (cpp || neko)
				frameID++;
				#end
			}
		}
	}
	
	override public function updateTileSheet():Void 
	{
	#if (cpp || neko)
		if (fontSet != null)
		{
			_tileSheetData = TileSheetManager.addTileSheet(fontSet);
			_tileSheetData.antialiasing = false;
			var reverse:Bool = (_flipped > 0);
			
			_framesData = _tileSheetData.addSpriteFramesData(characterWidth, characterHeight, new Point(0, 0), offsetX, offsetY, fontSet.width, fontSet.height, (characterSpacingX == 0) ? 1 : characterSpacingX, (characterSpacingY == 0) ? 1 : characterSpacingY);
		}
	#end
	}
	
	override public function destroy():Void 
	{
		fontSet = null;
		grabData = null;
		
	#if (cpp || neko)
		points = null;
		charFrameIDs = null;
	#end
		super.destroy();
	}
	
	#if (cpp || neko)
	override public function draw():Void 
	{
		if(_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var j:Int = 0;
		var textLength:Int = Math.floor(points.length / 3);
		var currPosInArr:Int;
		var currTileID:Float;
		var currTileX:Float;
		var currTileY:Float;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		var relativeX:Float;
		var relativeY:Float;
		
		var currDrawData:Array<Float>;
		var currIndex:Int;
		
		var isColored:Bool = _tileSheetData.isColored;
		
		while (i < l)
		{
			camera = cameras[i++];
			currDrawData = _tileSheetData.drawData[camera.ID];
			currIndex = _tileSheetData.positionData[camera.ID];
			
			if (!onScreen(camera))
			{
				continue;
			}
			
			_point.x = x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x);
			_point.y = y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y);
			
			var redMult:Float = 1;
			var greenMult:Float = 1;
			var blueMult:Float = 1;
			var isColoredCamera:Bool = camera.isColored;
			
			if (isColoredCamera)
			{
				redMult = _red * camera.red; 
				greenMult = _green * camera.green;
				blueMult = _blue * camera.blue;
			}
			else
			{
				redMult = _red; 
				greenMult = _green;
				blueMult = _blue;
			}
			
			if (simpleRender)
			{	//Simple render
				while (j < textLength)
				{
					if (_tileSheetData != null)
					{
						currPosInArr = j * 3;
						currTileID = points[currPosInArr];
						currTileX = points[currPosInArr + 1];
						currTileY = points[currPosInArr + 2];
						
						currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + currTileX;
						currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + currTileY;
						
						currDrawData[currIndex++] = currTileID;
						
						currDrawData[currIndex++] = 1;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = 1;
						
						if (isColored || isColoredCamera)
						{
							currDrawData[currIndex++] = redMult; 
							currDrawData[currIndex++] = greenMult;
							currDrawData[currIndex++] = blueMult;
						}
						
						currDrawData[currIndex++] = _alpha;
					}
					
					j++;
				}
			}
			else
			{	//Advanced render
				radians = angle * 0.017453293;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				while (j < textLength)
				{
					if (_tileSheetData != null)
					{
						currPosInArr = j * 3;
						currTileID = points[currPosInArr];
						currTileX = points[currPosInArr + 1];
						currTileY = points[currPosInArr + 2];
						
						relativeX = (currTileX * cos * scale.x - currTileY * sin * scale.y);
						relativeY = (currTileX * sin * scale.x + currTileY * cos * scale.y);
						
						currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + relativeX;
						currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + relativeY;
						
						currDrawData[currIndex++] = currTileID;
					
						currDrawData[currIndex++] = cos * scale.x;
						currDrawData[currIndex++] =  -sin * scale.y;
						currDrawData[currIndex++] = sin * scale.x;
						currDrawData[currIndex++] = cos * scale.y;
						
						if (isColored || isColoredCamera)
						{
							currDrawData[currIndex++] = redMult; 
							currDrawData[currIndex++] = greenMult;
							currDrawData[currIndex++] = blueMult;
						}
						
						currDrawData[currIndex++] = _alpha;
					}
					
					j++;
				}
			}
			
			_tileSheetData.positionData[camera.ID] = currIndex;
			
			FlxBasic._VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		}
	}
	#end
	
	public var text(getTextString, setTextString):String;
	
	/**
	 * Set this value to update the text in this sprite. Carriage returns are automatically stripped out if multiLine is false. Text is converted to upper case if autoUpperCase is true.
	 * 
	 * @return	void
	 */ 
	public function setTextString(content:String):String
	{
		var newText:String;
		
		if (autoUpperCase)
		{
			newText = content.toUpperCase();
		}
		else
		{
			newText = content;
		}
		
		// Smart update: Only change the bitmap data if the string has changed
		if (newText != _text)
		{
			_text = newText;
			
			removeUnsupportedCharacters(multiLine);
			
			buildBitmapFontText();
		}
		return _text;
	}
	
	/**
	 * If you need this FlxSprite to have a fixed width and custom alignment you can set the width here.<br>
	 * If text is wider than the width specified it will be cropped off.
	 * 
	 * @param	width			Width in pixels of this FlxBitmapFont. Set to zero to disable and re-enable automatic resizing.
	 * @param	lineAlignment	Align the text within this width. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 */
	public function setFixedWidth(width:Int, ?lineAlignment:String = "left"):Void
	{
		fixedWidth = width;
		align = lineAlignment;
	}
	
	public function getTextString():String
	{
		return _text;
	}
	
	/**
	 * A helper function that quickly sets lots of variables at once, and then updates the text.
	 * 
	 * @param	content				The text of this sprite
	 * @param	multiLines			Set to true if you want to support carriage-returns in the text and create a multi-line sprite instead of a single line (default is false).
	 * @param	characterSpacing	To add horizontal spacing between each character specify the amount in pixels (default 0).
	 * @param	lineSpacing			To add vertical spacing between each line of text, set the amount in pixels (default 0).
	 * @param	lineAlignment		Align each line of multi-line text. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 * @param	allowLowerCase		Lots of bitmap font sets only include upper-case characters, if yours needs to support lower case then set this to true.
	 */
	#if flash
	public function setText(content:String, ?multiLines:Bool = false, ?characterSpacing:UInt = 0, ?lineSpacing:UInt = 0, ?lineAlignment:String = "left", ?allowLowerCase:Bool = false):Void
	#else
	public function setText(content:String, ?multiLines:Bool = false, ?characterSpacing:Int = 0, ?lineSpacing:Int = 0, ?lineAlignment:String = "left", ?allowLowerCase:Bool = false):Void
	#end
	{
		customSpacingX = characterSpacing;
		customSpacingY = lineSpacing;
		align = lineAlignment;
		multiLine = multiLines;
		
		if (allowLowerCase)
		{
			autoUpperCase = false;
		}
		else
		{
			autoUpperCase = true;
		}
		
		if (content.length > 0)
		{
			text = content;
		}
	}
	
	/**
	 * Updates the BitmapData of the Sprite with the text
	 * 
	 * @return	void
	 */
	private function buildBitmapFontText():Void
	{
		var temp:BitmapData;
		var cx:Int = 0;
		var cy:Int = 0;
		
	#if (cpp || neko)
		if (points == null)
		{
			points = new Array<Float>();
		}
		else
		{
			points.splice(0, points.length);
		}
	#end
		
		if (multiLine)
		{
			var lines:Array<String> = _text.split("\n");
			_textHeight = (lines.length * (characterHeight + customSpacingY)) - customSpacingY;
			
			if (fixedWidth > 0)
			{
				_textWidth = fixedWidth;
			#if flash
				temp = new BitmapData(fixedWidth, _textHeight, true, 0xf);
			#end
			}
			else
			{
				_textWidth = getLongestLine() * (characterWidth + customSpacingX);
			#if flash
				temp = new BitmapData(_textWidth, _textHeight, true, 0xf);
			#end
			}
			
			//	Loop through each line of text
			for (i in 0...(lines.length))
			{
				//	This line of text is held in lines[i] - need to work out the alignment
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
				
				//	Sanity checks
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
			
			if (fixedWidth > 0)
			{
				_textWidth = fixedWidth;
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
		frames = 1;
		centerOffsets();
	#end
	}
	
	/**
	 * Returns a single character from the font set as an FlxSprite.
	 * 
	 * @param	char	The character you wish to have returned.
	 * 
	 * @return	An <code>FlxSprite</code> containing a single character from the font set.
	 */
	public function getCharacter(char:String):FlxSprite
	{
		var output:FlxSprite = new FlxSprite();
		#if !neko
		var temp:BitmapData = new BitmapData(characterWidth, characterHeight, true, 0xf);
		#else
		var temp:BitmapData = new BitmapData(characterWidth, characterHeight, true, {rgb: 0, a: 0});
		#end

		if (grabData[char.charCodeAt(0)] != null && char.charCodeAt(0) != 32)
		{
			temp.copyPixels(fontSet, grabData[char.charCodeAt(0)], new Point(0, 0));
		}
		
		output.pixels = temp;
		return output;
	}
	
	/**
	 * Returns a single character from the font set as bitmapData
	 * 
	 * @param	char	The character you wish to have returned.
	 * 
	 * @return	<code>bitmapData</code> containing a single character from the font set.
	 */
	public function getCharacterAsBitmapData(char:String):BitmapData
	{
		#if !neko
		var temp:BitmapData = new BitmapData(characterWidth, characterHeight, true, 0xf);
		#else
		var temp:BitmapData = new BitmapData(characterWidth, characterHeight, true, {rgb: 0, a: 0});
		#end

		//if (grabData[char.charCodeAt(0)] is Rectangle && char.charCodeAt(0) != 32)
		if (grabData[char.charCodeAt(0)] != null)
		{
			temp.copyPixels(fontSet, grabData[char.charCodeAt(0)], new Point(0, 0));
		}
		
		return temp;
	}
	
	/**
	 * Internal function that takes a single line of text (2nd parameter) and pastes it into the BitmapData at the given coordinates.
	 * Used by getLine and getMultiLine
	 * 
	 * @param	output			The BitmapData that the text will be drawn onto
	 * @param	line			The single line of text to paste
	 * @param	x				The x coordinate
	 * @param	y
	 * @param	customSpacingX
	 */
	#if flash
	private function pasteLine(output:BitmapData, line:String, ?x:UInt = 0, ?y:UInt = 0, ?customSpacingX:UInt = 0):Void
	#else
	private function pasteLine(line:String, ?x:Int = 0, ?y:Int = 0, ?customSpacingX:Int = 0):Void
	#end
	{
		for (c in 0...(line.length))
		{
			//	If it's a space then there is no point copying, so leave a blank space
			if (line.charAt(c) == " ")
			{
				x += characterWidth + customSpacingX;
			}
			else
			{
				//	If the character doesn't exist in the font then we don't want a blank space, we just want to skip it
				if (grabData[line.charCodeAt(c)] != null)
				{
				#if flash
					output.copyPixels(fontSet, grabData[line.charCodeAt(c)], new Point(x, y));
				#else
					points.push(charFrameIDs[line.charCodeAt(c)]);
					points.push(x - origin.x);
					points.push(y - origin.y);
				#end
					
					x += characterWidth + customSpacingX;
					
				#if flash
					if (Math.floor(x) > output.width)
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
	#if flash
	private function getLongestLine():UInt
	{
		var longestLine:UInt = 0;
	#else
	private function getLongestLine():Int
	{
		var longestLine:Int = 0;
	#end
		if (_text.length > 0)
		{
			var lines:Array<String> = _text.split("\n");
			
			for (i in 0...(lines.length))
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
	 * @param	stripCR		Should it strip carriage returns as well? (default = true)
	 * 
	 * @return	A clean version of the string
	 */
	private function removeUnsupportedCharacters(?stripCR:Bool = true):String
	{
		var newString:String = "";
		
		for (c in 0...(_text.length))
		{
			if (grabData[_text.charCodeAt(c)] != null || _text.charCodeAt(c) == 32 || (stripCR == false && _text.charAt(c) == "\n"))
			{
				newString = newString + _text.charAt(c);
			}
		}
		
		return newString;
	}
	
}