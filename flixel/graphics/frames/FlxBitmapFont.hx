package flixel.graphics.frames;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import haxe.xml.Access;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using flixel.util.FlxUnicodeUtil;

/**
 * Holds information and bitmap characters for a bitmap font.
 */
@:allow(flixel.text.FlxBitmapText)
class FlxBitmapFont extends FlxFramesCollection
{
	static inline var SPACE_CODE:Int = 32;
	static inline var TAB_CODE:Int = 9;
	static inline var NEW_LINE_CODE:Int = 10;

	static inline var DEFAULT_FONT_KEY:String = "DEFAULT_FONT_KEY";

	static inline var DEFAULT_FONT_DATA:String = " 36000000000000000000!26101010001000\"46101010100000000000000000#66010100111110010100111110010100000000$56001000111011000001101110000100%66100100000100001000010000010010000000&66011000100000011010100100011010000000'26101000000000(36010100100100010000)36100010010010100000*46000010100100101000000000+46000001001110010000000000,36000000000000010100-46000000001110000000000000.26000000001000/66000010000100001000010000100000000000056011001001010010100100110000000156011000010000100001000010000000256111000001001100100001111000000356111000001001100000101110000000456100101001010010011100001000000556111101000011100000101110000000656011001000011100100100110000000756111000001000010001100001000000856011001001001100100100110000000956011001001010010011100001000000:26001000100000;26001000101000<46001001001000010000100000=46000011100000111000000000>46100001000010010010000000?56111000001001100000000100000000@66011100100010101110101010011100000000A56011001001010010111101001000000B56111001001011100100101110000000C56011001001010000100100110000000D56111001001010010100101110000000E56111101000011000100001111000000F56111101000010000110001000000000G56011001000010110100100111000000H56100101001011110100101001000000I26101010101000J56000100001000010100100110000000K56100101001010010111001001000000L46100010001000100011100000M66100010100010110110101010100010000000N56100101001011010101101001000000O56011001001010010100100110000000P56111001001010010111001000000000Q56011001001010010100100110000010R56111001001010010111001001000000S56011101000001100000101110000000T46111001000100010001000000U56100101001010010100100110000000V56100101001010010101000100000000W66100010100010101010110110100010000000X56100101001001100100101001000000Y56100101001010010011100001001100Z56111100001001100100001111000000[36110100100100110000}46110001000010010011000000]36110010010010110000^46010010100000000000000000_46000000000000000011110000'26101000000000a56000000111010010100100111000000b56100001110010010100101110000000c46000001101000100001100000d56000100111010010100100111000000e56000000110010110110000110000000f46011010001000110010000000g5700000011001001010010011100001001100h56100001110010010100101001000000i26100010101000j37010000010010010010100k56100001001010010111001001000000l26101010101000m66000000111100101010101010101010000000n56000001110010010100101001000000o56000000110010010100100110000000p5700000111001001010010111001000010000q5700000011101001010010011100001000010r46000010101100100010000000s56000000111011000001101110000000t46100011001000100001100000u56000001001010010100100111000000v56000001001010010101000100000000w66000000101010101010101010011110000000x56000001001010010011001001000000y5700000100101001010010011100001001100z56000001111000100010001111000000{46011001001000010001100000|26101010101000}46110001000010010011000000~56010101010000000000000000000000\\46111010101010101011100000";

	/**
	 * Default letters for XNA font.
	 */
	public static inline var DEFAULT_CHARS:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

	static var point:Point = new Point();
	static var flashRect:Rectangle = new Rectangle();

	/**
	 * The size of the font. Can be useful for AngelCode fonts.
	 */
	public var size(default, null):Int = 0;

	public var lineHeight(default, null):Int = 0;

	public var bold:Bool = false;

	public var italic:Bool = false;

	public var fontName:String;

	public var numLetters(default, null):Int = 0;

	/**
	 * Minimum x offset in this font.
	 * This is a helper variable for rendering purposes.
	 */
	public var minOffsetX:Int = 0;

	/**
	 * The width of space character.
	 */
	public var spaceWidth:Int = 0;

	/**
	 * Helper map where character's frames are stored by char codes.
	 */
	var charMap:Map<Int, FlxFrame>;

	/**
	 * Helper map where character's xAdvance are stored by char codes.
	 */
	var charAdvance:Map<Int, Int>;

	/**
	 * Atlas frame from which this font has been parsed.
	 */
	var frame:FlxFrame;

	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 */
	function new(frame:FlxFrame, ?border:FlxPoint)
	{
		super(frame.parent, FlxFrameCollectionType.FONT, border);
		this.frame = frame;
		parent.persist = true;
		parent.destroyOnNoUse = false;
		charMap = new Map<Int, FlxFrame>();
		charAdvance = new Map<Int, Int>();
	}

	override public function destroy():Void
	{
		super.destroy();
		frame = null;
		fontName = null;
		charMap = null;
		charAdvance = null;
	}

	/**
	 * Retrieves the default `FlxBitmapFont`.
	 * May work incorrectly on HTML5.
	 * Utterly unreliable on Brave Browser with shields up.
	 */
	public static function getDefaultFont():FlxBitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.get(DEFAULT_FONT_KEY);
		if (graphic != null)
		{
			var font:FlxBitmapFont = FlxBitmapFont.findFont(graphic.imageFrame.frame);
			if (font != null)
				return font;
		}

		var letters:String = "";
		var bd:BitmapData = new BitmapData(700, 9, true, 0xFF888888);
		graphic = FlxG.bitmap.add(bd, false, DEFAULT_FONT_KEY);

		var letterPos:Int = 0;
		var i:Int = 0;

		while (i < DEFAULT_FONT_DATA.length)
		{
			letters += DEFAULT_FONT_DATA.substr(i, 1);

			var gw:Int = Std.parseInt(DEFAULT_FONT_DATA.substr(++i, 1));
			var gh:Int = Std.parseInt(DEFAULT_FONT_DATA.substr(++i, 1));

			for (py in 0...gh)
			{
				for (px in 0...gw)
				{
					i++;

					if (DEFAULT_FONT_DATA.substr(i, 1) == "1")
					{
						bd.setPixel32(1 + letterPos * 7 + px, 1 + py, FlxColor.WHITE);
					}
					else
					{
						bd.setPixel32(1 + letterPos * 7 + px, 1 + py, FlxColor.TRANSPARENT);
					}
				}
			}

			i++;
			letterPos++;
		}

		return FlxBitmapFont.fromXNA(graphic, letters);
	}

	/**
	 * Loads font data in AngelCode's format.
	 *
	 * @param   source  Font image source.
	 * @param   data    Font data.
	 * @return  Generated bitmap font object.
	 */
	public static function fromAngelCode(source:FlxBitmapFontGraphicAsset, data:FlxAngelCodeAsset):FlxBitmapFont
	{
		var frame:FlxFrame = null;

		if ((source is FlxFrame))
		{
			frame = cast source;
		}
		else
		{
			final graphic = FlxG.bitmap.add(cast source);
			frame = graphic.imageFrame.frame;
		}

		var font:FlxBitmapFont = FlxBitmapFont.findFont(frame);
		if (font != null)
			return font;

		font = new FlxBitmapFont(frame);

		final fontInfo = data.parse();

		// how much to move the cursor when going to the next line.
		font.lineHeight = fontInfo.common.lineHeight;
		font.size = fontInfo.info.size;
		font.fontName = fontInfo.info.face;
		font.bold = fontInfo.info.bold;
		font.italic = fontInfo.info.italic;
		
		for (char in fontInfo.chars)
		{
			final frame = FlxRect.get();
			frame.x = char.x; // X position within the bitmap image file.
			frame.y = char.y; // Y position within the bitmap image file.
			frame.width = char.width; // Width of the character in the image file.
			frame.height = char.height; // Height of the character in the image file.
			
			font.minOffsetX = (font.minOffsetX < -char.xoffset) ? -char.xoffset : font.minOffsetX;
			
			if (char.id == -1)
			{
				throw 'Invalid font data!';
			}
			
			font.addCharFrame(char.id, frame, FlxPoint.get(char.xoffset, char.yoffset), char.xadvance);
			
			if (char.id == SPACE_CODE)
			{
				font.spaceWidth = char.xadvance;
			}
			else
			{
				font.lineHeight = (font.lineHeight > char.height + char.yoffset) ? font.lineHeight : char.height + char.yoffset;
			}
		}
		
		font.updateSourceHeight();
		return font;
	}

	/**
	 * Load bitmap font in XNA/Pixelizer format.
	 * May work incorrectly on HTML5.
	 * Utterly unreliable on Brave Browser with shields up.
	 *
	 * @param   source        Source image for this font.
	 * @param   letters       `String` of characters contained in the source image,
	 *                        in order (ex. `" abcdefghijklmnopqrstuvwxyz"`). Defaults to `DEFAULT_CHARS`.
	 * @param   charBGColor   An additional background color to remove. Defaults to `FlxColor.TRANSPARENT`.
	 * @return  Generated bitmap font object.
	 */
	public static function fromXNA(source:FlxBitmapFontGraphicAsset, ?letters:String, charBGColor:Int = FlxColor.TRANSPARENT):FlxBitmapFont
	{
		var graphic:FlxGraphic = null;
		var frame:FlxFrame = null;

		if ((source is FlxFrame))
		{
			frame = cast source;
			graphic = frame.parent;
		}
		else
		{
			graphic = FlxG.bitmap.add(cast source);
			frame = graphic.imageFrame.frame;
		}

		var font:FlxBitmapFont = FlxBitmapFont.findFont(frame);
		if (font != null)
			return font;

		letters = (letters == null) ? DEFAULT_CHARS : letters;
		font = new FlxBitmapFont(frame);
		font.fontName = graphic.key;

		var bmd:BitmapData = graphic.bitmap;

		var p:Point = new Point();
		p.setTo(0, 0);
		transformPoint(p, frame);
		var globalBGColor:FlxColor = bmd.getPixel(Std.int(p.x), Std.int(p.y));

		var frameWidth:Int = Std.int(frame.frame.width);
		var frameHeight:Int = Std.int(frame.frame.height);
		var letterIdx:Int = 0;
		var charCode:Int;
		var numLetters:Int = letters.uLength();
		var rect:FlxRect;
		var offset:FlxPoint;
		var xAdvance:Int;

		var cy:Int = 0;
		var cx:Int;

		var gx:Int;
		var gy:Int;
		var gw:Int;
		var gh:Int;

		while (cy < frameHeight && letterIdx < numLetters)
		{
			var rowHeight:Int = 0;
			cx = 0;

			while (cx < frameWidth && letterIdx < numLetters)
			{
				p.setTo(cx, cy);
				transformPoint(p, frame);

				if (bmd.getPixel(Std.int(p.x), Std.int(p.y)) != cast globalBGColor)
				{
					// found non bg pixel
					gx = cx;
					gy = cy;

					p.setTo(gx, gy);
					transformPoint(p, frame);

					// find width and height of char
					while (gx < frameWidth && bmd.getPixel(Std.int(p.x), Std.int(p.y)) != cast globalBGColor)
					{
						gx++;
						p.setTo(gx, cy);
						transformPoint(p, frame);
					}

					p.setTo(gx - 1, gy);
					transformPoint(p, frame);

					while (gy < frameHeight && bmd.getPixel(Std.int(p.x), Std.int(p.y)) != cast globalBGColor)
					{
						gy++;
						p.setTo(cx, gy);
						transformPoint(p, frame);
					}

					gw = gx - cx;
					gh = gy - cy;

					charCode = letters.uCharCodeAt(letterIdx);
					rect = FlxRect.get(cx, cy, gw, gh);
					offset = FlxPoint.get(0, 0);
					xAdvance = gw;

					font.addCharFrame(charCode, rect, offset, xAdvance);

					if (charCode == SPACE_CODE)
					{
						font.spaceWidth = xAdvance;
					}

					// store max size
					if (gh > rowHeight)
						rowHeight = gh;
					if (gh > font.size)
						font.size = gh;

					// go to next char
					cx += gw;
					letterIdx++;
				}

				cx++;
			}

			// next row
			cy += (rowHeight + 1);
		}

		font.lineHeight = font.size;
		font.updateSourceHeight();

		// remove background color
		point.setTo(Std.int(frame.frame.x), Std.int(frame.frame.y));

		var frameRect = flashRect;
		frame.frame.copyToFlash(frameRect);

		var bgColor32:Int = bmd.getPixel32(Std.int(frame.frame.x), Std.int(frame.frame.y));
		bmd.threshold(bmd, frameRect, point, "==", bgColor32, FlxColor.TRANSPARENT, FlxColor.WHITE, true);

		if (charBGColor != FlxColor.TRANSPARENT)
		{
			bmd.threshold(bmd, frameRect, point, "==", charBGColor, FlxColor.TRANSPARENT, FlxColor.WHITE, true);
		}

		return font;
	}

	static inline function transformPoint(point:Point, frame:FlxFrame):Point
	{
		var x:Float = point.x;
		var y:Float = point.y;

		if (frame.angle == FlxFrameAngle.ANGLE_NEG_90)
		{
			point.x = frame.frame.width - y;
			point.y = x;
		}
		else if (frame.angle == FlxFrameAngle.ANGLE_90)
		{
			point.x = y;
			point.y = frame.frame.height - x;
		}

		point.x += frame.frame.x;
		point.y += frame.frame.y;
		return point;
	}

	/**
	 * Loads a monospaced bitmap font.
	 *
	 * @param   source    Source image for this font.
	 *                    Use white pixels if you intend to change the color.
	 * @param   letters   The characters used in the font set, in display order.
	 *                    You can use the `TEXT_SET` constants for common font set arrangements.
	 * @param   charSiz   The size of each character in the font set.
	 * @param   region    The region of image to use for the font.
	 *                    Default is null which means that the whole image will be used.
	 * @param   spacing   Spaces between characters in the font set. Default is `null` which means no spaces.
	 * @return  Generated bitmap font object.
	 */
	public static function fromMonospace(source:FlxBitmapFontGraphicAsset, ?letters:String, charSize:FlxPoint, ?region:FlxRect,
			?spacing:FlxPoint):FlxBitmapFont
	{
		var graphic:FlxGraphic = null;
		var frame:FlxFrame = null;

		if ((source is FlxFrame))
		{
			frame = cast source;
			graphic = frame.parent;
		}
		else
		{
			graphic = FlxG.bitmap.add(cast source);
			frame = graphic.imageFrame.frame;
		}

		var font:FlxBitmapFont = FlxBitmapFont.findFont(frame);
		if (font != null)
			return font;

		letters = (letters == null) ? DEFAULT_CHARS : letters;
		region = (region == null) ? FlxRect.weak(0, 0, frame.sourceSize.x, frame.sourceSize.y) : region;
		spacing = (spacing == null) ? FlxPoint.get(0, 0) : spacing;

		var bitmapWidth:Int = Std.int(region.width);
		var bitmapHeight:Int = Std.int(region.height);

		var startX:Int = Std.int(region.x);
		var startY:Int = Std.int(region.y);

		region.putWeak();

		var xSpacing:Int = Std.int(spacing.x);
		var ySpacing:Int = Std.int(spacing.y);

		var charWidth:Int = Std.int(charSize.x);
		var charHeight:Int = Std.int(charSize.y);

		var spacedWidth:Int = charWidth + xSpacing;
		var spacedHeight:Int = charHeight + ySpacing;

		var numRows:Int = (charHeight == 0) ? 1 : Std.int((bitmapHeight + ySpacing) / spacedHeight);
		var numCols:Int = (charWidth == 0) ? 1 : Std.int((bitmapWidth + xSpacing) / spacedWidth);

		font = new FlxBitmapFont(frame);
		font.fontName = graphic.key;
		font.lineHeight = font.size = charHeight;

		var charRect:FlxRect;
		var offset:FlxPoint;
		var xAdvance:Int = charWidth;
		font.spaceWidth = xAdvance;
		var letterIndex:Int = 0;
		var numLetters:Int = letters.uLength();

		for (j in 0...numRows)
		{
			for (i in 0...numCols)
			{
				charRect = FlxRect.get(startX + i * spacedWidth, startY + j * spacedHeight, charWidth, charHeight);
				offset = FlxPoint.get(0, 0);
				font.addCharFrame(letters.uCharCodeAt(letterIndex), charRect, offset, xAdvance);
				letterIndex++;

				if (letterIndex >= numLetters)
				{
					return font;
				}
			}
		}

		font.updateSourceHeight();
		return font;
	}

	/**
	 * Internal method which creates and add char frames into this font.
	 *
	 * @param   charCode   Char code for char frame.
	 * @param   frame      Character region from source image.
	 * @param   offset     Offset before rendering this char.
	 * @param   xAdvance   How much cursor will jump after this char.
	 */
	function addCharFrame(charCode:Int, frame:FlxRect, offset:FlxPoint, xAdvance:Int):Void
	{
		var charName:String = new UnicodeBuffer().addChar(charCode).toString();
		if (frame.width == 0 || frame.height == 0 || getByName(charName) != null)
			return;
		var charFrame:FlxFrame = this.frame.subFrameTo(frame);

		var w:Float = charFrame.sourceSize.x;
		var h:Float = charFrame.sourceSize.y;
		w += (offset.x > 0) ? offset.x : 0;
		h += (offset.y > 0) ? offset.y : 0;
		charFrame.sourceSize.set(w, h);
		charFrame.offset.addPoint(offset);
		charFrame.name = charName;
		pushFrame(charFrame);
		charMap.set(charCode, charFrame);
		charAdvance.set(charCode, xAdvance);
		offset.put();
	}

	function updateSourceHeight():Void
	{
		for (frame in frames)
		{
			frame.sourceSize.y = lineHeight;
			frame.cacheFrameMatrix();
		}
	}

	public inline function charExists(charCode:Int):Bool
	{
		return charMap.exists(charCode);
	}

	public inline function getCharFrame(charCode:Int):FlxFrame
	{
		return charMap.get(charCode);
	}

	public inline function getCharAdvance(charCode:Int):Int
	{
		return charAdvance.exists(charCode) ? charAdvance.get(charCode) : 0;
	}

	public inline function getCharWidth(charCode:Int):Float
	{
		return charMap.exists(charCode) ? charMap.get(charCode).sourceSize.x : 0;
	}

	public static function findFont(frame:FlxFrame, ?border:FlxPoint):FlxBitmapFont
	{
		if (border == null)
			border = FlxPoint.weak();

		var bitmapFonts:Array<FlxBitmapFont> = cast frame.parent.getFramesCollections(FlxFrameCollectionType.FONT);
		for (font in bitmapFonts)
		{
			if (font.frame == frame && font.border.equals(border))
			{
				return font;
			}
		}
		return null;
	}

	override public function addBorder(border:FlxPoint):FlxBitmapFont
	{
		var resultBorder:FlxPoint = FlxPoint.weak().addPoint(this.border).addPoint(border);

		var font:FlxBitmapFont = FlxBitmapFont.findFont(frame, resultBorder);
		if (font != null)
		{
			return font;
		}

		font = new FlxBitmapFont(frame, border);
		font.spaceWidth = spaceWidth;
		font.fontName = fontName;
		font.numLetters = numLetters;
		font.minOffsetX = minOffsetX;
		font.size = size;
		font.lineHeight = lineHeight;
		font.italic = italic;
		font.bold = bold;

		var charWithBorder:FlxFrame;
		var code:Int;
		for (char in frames)
		{
			charWithBorder = char.setBorderTo(border);
			font.pushFrame(charWithBorder);
			code = char.name.uCharCodeAt(0);
			font.charMap.set(code, charWithBorder);
			font.charAdvance.set(code, charAdvance.get(code));
		}

		font.updateSourceHeight();
		return font;
	}
}
