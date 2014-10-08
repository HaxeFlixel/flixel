package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.xml.Fast;

/**
 * Holds information and bitmap glyphs for a bitmap font.
 */
class FlxBitmapFont extends FlxFramesCollection
{
	public static inline var defaultFontKey:String = "defaultFontKey";
	
	private static inline var defaultFontData:String = " 36000000000000000000!26101010001000\"46101010100000000000000000#66010100111110010100111110010100000000$56001000111011000001101110000100%66100100000100001000010000010010000000&66011000100000011010100100011010000000'26101000000000(36010100100100010000)36100010010010100000*46000010100100101000000000+46000001001110010000000000,36000000000000010100-46000000001110000000000000.26000000001000/66000010000100001000010000100000000000056011001001010010100100110000000156011000010000100001000010000000256111000001001100100001111000000356111000001001100000101110000000456100101001010010011100001000000556111101000011100000101110000000656011001000011100100100110000000756111000001000010001100001000000856011001001001100100100110000000956011001001010010011100001000000:26001000100000;26001000101000<46001001001000010000100000=46000011100000111000000000>46100001000010010010000000?56111000001001100000000100000000@66011100100010101110101010011100000000A56011001001010010111101001000000B56111001001011100100101110000000C56011001001010000100100110000000D56111001001010010100101110000000E56111101000011000100001111000000F56111101000010000110001000000000G56011001000010110100100111000000H56100101001011110100101001000000I26101010101000J56000100001000010100100110000000K56100101001010010111001001000000L46100010001000100011100000M66100010100010110110101010100010000000N56100101001011010101101001000000O56011001001010010100100110000000P56111001001010010111001000000000Q56011001001010010100100110000010R56111001001010010111001001000000S56011101000001100000101110000000T46111001000100010001000000U56100101001010010100100110000000V56100101001010010101000100000000W66100010100010101010110110100010000000X56100101001001100100101001000000Y56100101001010010011100001001100Z56111100001001100100001111000000[36110100100100110000}46110001000010010011000000]36110010010010110000^46010010100000000000000000_46000000000000000011110000'26101000000000a56000000111010010100100111000000b56100001110010010100101110000000c46000001101000100001100000d56000100111010010100100111000000e56000000110010110110000110000000f46011010001000110010000000g5700000011001001010010011100001001100h56100001110010010100101001000000i26100010101000j37010000010010010010100k56100001001010010111001001000000l26101010101000m66000000111100101010101010101010000000n56000001110010010100101001000000o56000000110010010100100110000000p5700000111001001010010111001000010000q5700000011101001010010011100001000010r46000010101100100010000000s56000000111011000001101110000000t46100011001000100001100000u56000001001010010100100111000000v56000001001010010101000100000000w66000000101010101010101010011110000000x56000001001010010011001001000000y5700000100101001010010011100001001100z56000001111000100010001111000000{46011001001000010001100000|26101010101000}46110001000010010011000000~56010101010000000000000000000000\\46111010101010101011100000";
	
	/**
	 * Default letters for XNA font.
	 */
	public static inline var DEFAULT_GLYPHS:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
	
	private static var COLOR_TRANSFORM:ColorTransform = new ColorTransform();
	
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
	 * This is a helper varible for rendering purposes.
	 */
	public var minOffsetX:Int = 0;
	
	/**
	 * The width of space character.
	 */
	public var spaceWidth:Int = 0;
	
	public var glyphs:Map<String, FlxGlyphFrame>;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 */
	private function new(parent:FlxGraphic)
	{
		super(parent, FlxFrameCollectionType.FONT);
		parent.persist = true;
		parent.destroyOnNoUse = false;
		glyphs = new Map<String, FlxGlyphFrame>();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		glyphs = null;
		fontName = null;
	}
	
	/**
	 * Retrieves default BitmapFont.
	 */
	public static function getDefaultFont():FlxBitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.get(defaultFontKey);
		if (graphic != null)
		{
			var font:FlxBitmapFont = FlxBitmapFont.findFont(graphic);
			if (font != null)
			{
				return font;
			}
		}		
		
		var letters:String = "";
		var bd:BitmapData = new BitmapData(700, 9, true, 0xFF888888);
		graphic = FlxG.bitmap.add(bd, false, defaultFontKey);
		
		var letterPos:Int = 0;
		var i:Int = 0;
		
		while (i < defaultFontData.length) 
		{
			letters += defaultFontData.substr(i, 1);
			
			var gw:Int = Std.parseInt(defaultFontData.substr(++i, 1));
			var gh:Int = Std.parseInt(defaultFontData.substr(++i, 1));
			
			for (py in 0...gh) 
			{
				for (px in 0...gw) 
				{
					i++;
					
					if (defaultFontData.substr(i, 1) == "1") 
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
	 * @param	Source		Font image source.
	 * @param	Data		XML font data.
	 * @return	Generated bitmap font object.
	 */
	public static function fromAngelCode(Source:FlxGraphicAsset, Data:Xml):FlxBitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)	return null;
		
		var font:FlxBitmapFont = FlxBitmapFont.findFont(graphic);
		if (font != null)
			return font;
		
		if ((graphic == null) || (Data == null)) return null;
		
		font = new FlxBitmapFont(graphic);
		
		var fast:Fast = new Fast(Data.firstElement());
		
		font.lineHeight = Std.parseInt(fast.node.common.att.lineHeight);
		font.size = Std.parseInt(fast.node.info.att.size);
		font.fontName = Std.string(fast.node.info.att.face);
		font.bold = (Std.parseInt(fast.node.info.att.bold) != 0);
		font.italic = (Std.parseInt(fast.node.info.att.italic) != 0);
		
		var glyphFrame:FlxGlyphFrame;
		var frame:FlxRect;
		var offset:FlxPoint;
		var glyph:String;
		var xOffset:Int, yOffset:Int, xAdvance:Int;
		var glyphWidth:Int, glyphHeight:Int;
		
		var chars = fast.node.chars;
		
		for (char in chars.nodes.char)
		{
			frame = new FlxRect();
			frame.x = Std.parseInt(char.att.x);
			frame.y = Std.parseInt(char.att.y);
			frame.width = Std.parseInt(char.att.width);
			frame.height = Std.parseInt(char.att.height);
			
			xOffset = char.has.xoffset ? Std.parseInt(char.att.xoffset) : 0;
			yOffset = char.has.yoffset ? Std.parseInt(char.att.yoffset) : 0;
			xAdvance = char.has.xadvance ? Std.parseInt(char.att.xadvance) : 0;
			
			offset = FlxPoint.get(xOffset, yOffset);
			
			font.minOffsetX = (font.minOffsetX > xOffset) ? xOffset : font.minOffsetX;
			
			glyph = null;
			
			if (char.has.letter)
			{
				glyph = char.att.letter;
			}
			else if (char.has.id)
			{
				glyph = String.fromCharCode(Std.parseInt(char.att.id));
			}
			
			if (glyph == null) 
			{
				throw 'Invalid font xml data!';
			}
			
			glyph = switch(glyph) 
			{
				case "space": ' ';
				case "&quot;": '"';
				case "&amp;": '&';
				case "&gt;": '>';
				case "&lt;": '<';
				default: glyph;
			}
			
			font.addGlyphFrame(glyph, frame, offset, xAdvance);
			
			if (glyph == ' ')
			{
				font.spaceWidth = xAdvance;
			}
		}
		
		return font;
	}
	
	/**
	 * Load bitmap font in XNA/Pixelizer format.
	 * May work incorrectly on html5 target.
	 * 
	 * @param	source			Source image for this font.
	 * @param	letters			String of glyphs contained in the source image, in order (ex. " abcdefghijklmnopqrstuvwxyz"). Defaults to DEFAULT_GLYPHS.
	 * @param	glyphBGColor	An additional background color to remove. Defaults to 0xFF202020, often used for glyphs background.
	 * @return	Generated bitmap font object.
	 */
	public static function fromXNA(source:FlxGraphicAsset, letters:String = null, glyphBGColor:Int = FlxColor.TRANSPARENT):FlxBitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)	return null;
		
		var font:FlxBitmapFont = FlxBitmapFont.findFont(graphic);
		if (font != null)
			return font;
		
		letters = (letters == null) ? DEFAULT_GLYPHS : letters;
		
		if (graphic == null) return null;
		
		font = new FlxBitmapFont(graphic);
		font.fontName = graphic.key;
		
		var bmd:BitmapData = graphic.bitmap;
		var globalBGColor:Int = bmd.getPixel(0, 0);
		var cy:Int = 0;
		var cx:Int;
		var letterIdx:Int = 0;
		var glyph:String;
		var numLetters:Int = letters.length;
		var rect:FlxRect;
		var offset:FlxPoint;
		var xAdvance:Int;
		
		while (cy < bmd.height && letterIdx < numLetters)
		{
			var rowHeight:Int = 0;
			cx = 0;
			
			while (cx < bmd.width && letterIdx < numLetters)
			{
				if (Std.int(bmd.getPixel(cx, cy)) != globalBGColor) 
				{
					// found non bg pixel
					var gx:Int = cx;
					var gy:Int = cy;
					
					// find width and height of glyph
					while (Std.int(bmd.getPixel(gx, cy)) != globalBGColor) gx++;
					while (Std.int(bmd.getPixel(cx, gy)) != globalBGColor) gy++;
					
					var gw:Int = gx - cx;
					var gh:Int = gy - cy;
					
					glyph = letters.charAt(letterIdx);
					
					rect = new FlxRect(cx, cy, gw, gh);
					
					offset = FlxPoint.get(0, 0);
					
					xAdvance = gw;
					
					font.addGlyphFrame(glyph, rect, offset, xAdvance);
					
					if (glyph == ' ')
					{
						font.spaceWidth = xAdvance;
					}
					
					// store max size
					if (gh > rowHeight) rowHeight = gh;
					if (gh > font.size) font.size = gh;
					
					// go to next glyph
					cx += gw;
					letterIdx++;
				}
				
				cx++;
			}
			
			// next row
			cy += (rowHeight + 1);
		}
		
		font.lineHeight = font.size;
		
		// remove background color
		var point:Point = FlxPoint.point;
		point.x = point.y = 0;
		var bgColor32:Int = bmd.getPixel32(0, 0);
		#if !bitfive
		bmd.threshold(bmd, bmd.rect, point, "==", bgColor32, FlxColor.TRANSPARENT, FlxColor.WHITE, true);
		
		if (glyphBGColor != FlxColor.TRANSPARENT)
		{
			bmd.threshold(bmd, bmd.rect, point, "==", glyphBGColor, FlxColor.TRANSPARENT, FlxColor.WHITE, true);
		}
		#else
		FlxBitmapDataUtil.replaceColor(bmd, bgColor32, FlxColor.TRANSPARENT);
		FlxBitmapDataUtil.replaceColor(bmd, glyphBGColor, FlxColor.TRANSPARENT);
		#end
		
		return font;
	}
	
	/**
	 * Loads monospace bitmap font.
	 * 
	 * @param	source		Source image for this font.
	 * @param	letters		The characters used in the font set, in display order. You can use the TEXT_SET consts for common font set arrangements.
	 * @param	charSize	The size of each character in the font set.
	 * @param	region		The region of image to use for the font. Default is null which means that the whole image will be used.
	 * @param	spacing		Spaces between characters in the font set. Default is null which means no spaces.
	 * @return	Generated bitmap font object.
	 */
	public static function fromMonospace(source:FlxGraphicAsset, letters:String = null, charSize:FlxPoint, region:FlxRect = null, spacing:Point = null):FlxBitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)	return null;
		
		var font:FlxBitmapFont = FlxBitmapFont.findFont(graphic);
		if (font != null)
			return font;
		
		letters = (letters == null) ? DEFAULT_GLYPHS : letters;
		
		if (graphic == null) return null;
		
		region = (region == null) ? FlxRect.flxRect.copyFromFlash(graphic.bitmap.rect) : region;
		
		if (region.width == 0 || region.right > graphic.bitmap.width)
		{
			region.width = graphic.bitmap.width - region.x;
		}
		
		if (region.height == 0 || region.bottom > graphic.bitmap.height)
		{
			region.height = graphic.bitmap.height - region.y;
		}
		
		spacing = (spacing == null) ? new Point(0, 0) : spacing;
		
		var bitmapWidth:Int = Std.int(region.width);
		var bitmapHeight:Int = Std.int(region.height);
		
		var startX:Int = Std.int(region.x);
		var startY:Int = Std.int(region.y);
		
		var xSpacing:Int = Std.int(spacing.x);
		var ySpacing:Int = Std.int(spacing.y);
		
		var charWidth:Int = Std.int(charSize.x);
		var charHeight:Int = Std.int(charSize.y);
		
		var spacedWidth:Int = charWidth + xSpacing;
		var spacedHeight:Int = charHeight + ySpacing;
		
		var numRows:Int = (charHeight == 0) ? 1 : Std.int((bitmapHeight + ySpacing) / spacedHeight);
		var numCols:Int = (charWidth == 0) ? 1 : Std.int((bitmapWidth + xSpacing) / spacedWidth);
		
		font = new FlxBitmapFont(graphic);
		font.fontName = graphic.key;
		font.lineHeight = font.size = charHeight;
		
		var charRect:FlxRect;
		var offset:FlxPoint;
		var xAdvance:Int = charWidth;
		font.spaceWidth = xAdvance;
		var letterIndex:Int = 0;
		var numLetters:Int = letters.length;
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))
			{
				charRect = new FlxRect(startX + i * spacedWidth, startY + j * spacedHeight, charWidth, charHeight);
				offset = FlxPoint.get(0, 0);
				font.addGlyphFrame(letters.charAt(letterIndex), charRect, offset, xAdvance);
				
				letterIndex++;
				
				if (letterIndex >= numLetters)
				{
					return font;
				}
			}
		}
		
		return font;
	}
	
	/**
	 * Internal method which creates and add glyph frames into this font.
	 * 
	 * @param	glyph			Letter for glyph frame.
	 * @param	frame			Glyph area from source image.	
	 * @param	offset			Offset before rendering this glyph.
	 * @param	xAdvance		How much cursor will jump after this glyph.
	 */
	private function addGlyphFrame(glyph:String, frame:FlxRect, offset:FlxPoint, xAdvance:Int):Void
	{
		if (frame.width == 0 || frame.height == 0)	return;
		
		var glyphFrame:FlxGlyphFrame = new FlxGlyphFrame(parent);
		glyphFrame.name = glyph;
		glyphFrame.sourceSize.set(frame.width, frame.height);
		glyphFrame.offset.copyFrom(offset);
		glyphFrame.xAdvance = xAdvance;
		glyphFrame.frame = frame;
		glyphFrame.center.set(0.5 * frame.width, 0.5 * frame.height);
		
		offset.put();
		
		#if FLX_RENDER_TILE
		var flashRect:Rectangle = frame.copyToFlash(new Rectangle());
		glyphFrame.tileID = parent.tilesheet.addTileRect(flashRect, new Point(0.5 * frame.width, 0.5 * frame.height));
		#end
		
		frames.push(glyphFrame);
		framesHash.set(glyph, glyphFrame);
		glyphs.set(glyph, glyphFrame);
	}
	
	public static inline function findFont(graphic:FlxGraphic):FlxBitmapFont
	{
		var bitmapFonts:Array<FlxBitmapFont> = cast graphic.getFramesCollections(FlxFrameCollectionType.FONT);
		if (bitmapFonts.length > 0 && bitmapFonts[0] != null)
		{
			return bitmapFonts[0];
		}
		
		return null;
	}
	
	#if FLX_RENDER_BLIT
	public inline function prepareGlyphs(scale:Float, color:FlxColor, useColor:Bool = true):BitmapGlyphCollection
	{
		return new BitmapGlyphCollection(this, scale, color, useColor);
	}
	#end
}

/**
 * Helper class for blit render mode to reduce BitmapData draw() method calls.
 * It stores info about transformed bitmap font glyphs. 
 */
class BitmapGlyphCollection implements IFlxDestroyable
{
	public var minOffsetX:Float = 0;
	
	public var glyphMap:Map<String, BitmapGlyph>;
	
	public var glyphs:Array<BitmapGlyph>;
	
	public var color:FlxColor;
	
	public var scale:Float;
	
	public var spaceWidth:Float = 0;
	
	public var font:FlxBitmapFont;
	
	public function new(font:FlxBitmapFont, scale:Float, color:FlxColor, useColor:Bool = true)
	{
		glyphMap = new Map<String, BitmapGlyph>();
		glyphs = new Array<BitmapGlyph>();
		this.font = font;
		this.scale = scale;
		this.color = (useColor) ? color : FlxColor.WHITE;
		this.minOffsetX = font.minOffsetX * scale;
		prepareGlyphs();
	}
	
	private function prepareGlyphs():Void
	{
		var matrix:Matrix = FlxMatrix.matrix;
		matrix.identity();
		matrix.scale(scale, scale);
		
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.redMultiplier = color.redFloat;
		colorTransform.greenMultiplier = color.greenFloat;
		colorTransform.blueMultiplier = color.blueFloat;
		colorTransform.alphaMultiplier = color.alphaFloat;
		
		var glyphBD:BitmapData;
		var preparedBD:BitmapData;
		var frame:FlxFrame;
		var glyph:FlxGlyphFrame;
		var preparedGlyph:BitmapGlyph;
		var bdWidth:Int, bdHeight:Int;
		var offsetX:Int, offsetY:Int, xAdvance:Int;
		
		spaceWidth = font.spaceWidth * scale;
		
		for (frame in font.frames)
		{
			glyph = cast(frame, FlxGlyphFrame);
			glyphBD = glyph.getBitmap();
			
			bdWidth = Math.ceil(glyphBD.width * scale);
			bdHeight = Math.ceil(glyphBD.height * scale);
			
			bdWidth = (bdWidth > 0) ? bdWidth : 1;
			bdHeight = (bdHeight > 0) ? bdHeight : 1;
			
			preparedBD = new BitmapData(bdWidth, bdHeight, true, FlxColor.TRANSPARENT);
			preparedBD.draw(glyphBD, matrix, colorTransform);
			
			offsetX = Math.ceil(glyph.offset.x * scale);
			offsetY = Math.ceil(glyph.offset.y * scale);
			xAdvance = Math.ceil(glyph.xAdvance * scale);
			
			preparedGlyph = new BitmapGlyph(glyph.name, preparedBD, offsetX, offsetY, xAdvance);
			
			glyphs.push(preparedGlyph);
			glyphMap.set(preparedGlyph.glyph, preparedGlyph);
		}
	}
	
	public function destroy():Void
	{
		glyphs = FlxDestroyUtil.destroyArray(glyphs);
		glyphMap = null;
		font = null;
	}
}

/**
 * Helper class for blit render mode. 
 * Stores info about single transformed bitmap glyph.
 */
class BitmapGlyph implements IFlxDestroyable
{
	public var glyph:String;
	
	public var bitmap:BitmapData;
	
	public var offsetX:Int = 0;
	
	public var offsetY:Int = 0;
	
	public var xAdvance:Int = 0;
	
	public var rect:Rectangle;
	
	public function new(glyph:String, bmd:BitmapData, offsetX:Int = 0, offsetY:Int = 0, xAdvance:Int = 0)
	{
		this.glyph = glyph;
		this.bitmap = bmd;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.xAdvance = xAdvance;
		this.rect = bmd.rect;
	}
	
	public function destroy():Void
	{
		bitmap = FlxDestroyUtil.dispose(bitmap);
		glyph = null;
	}
}