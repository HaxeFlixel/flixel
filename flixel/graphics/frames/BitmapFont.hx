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
import flixel.text.DefaultBitmapFont;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.xml.Fast;

/**
 * Holds information and bitmap glyphs for a bitmap font.
 */
class BitmapFont extends FlxFramesCollection
{
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
	
	public var glyphs:Map<String, GlyphFrame>;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 */
	private function new(parent:FlxGraphic)
	{
		super(parent, FrameCollectionType.FONT);
		parent.persist = true;
		parent.destroyOnNoUse = false;
		glyphs = new Map<String, GlyphFrame>();
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
	public static function getDefault():BitmapFont
	{
		return DefaultBitmapFont.getDefaultFont();
	}
	
	/**
	 * Loads font data in AngelCode's format.
	 * 
	 * @param	Source		Font image source.
	 * @param	Data		XML font data.
	 * @return	Generated bitmap font object.
	 */
	public static function fromAngelCode(Source:FlxGraphicAsset, Data:Xml):BitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)	return null;
		
		var font:BitmapFont = BitmapFont.findFont(graphic);
		if (font != null)
			return font;
		
		if ((graphic == null) || (Data == null)) return null;
		
		font = new BitmapFont(graphic);
		
		var fast:Fast = new Fast(Data.firstElement());
		
		font.lineHeight = Std.parseInt(fast.node.common.att.lineHeight);
		font.size = Std.parseInt(fast.node.info.att.size);
		font.fontName = Std.string(fast.node.info.att.face);
		font.bold = (Std.parseInt(fast.node.info.att.bold) != 0);
		font.italic = (Std.parseInt(fast.node.info.att.italic) != 0);
		
		var glyphFrame:GlyphFrame;
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
	 * 
	 * @param	source			Source image for this font.
	 * @param	letters			String of glyphs contained in the source image, in order (ex. " abcdefghijklmnopqrstuvwxyz"). Defaults to DEFAULT_GLYPHS.
	 * @param	glyphBGColor	An additional background color to remove. Defaults to 0xFF202020, often used for glyphs background.
	 * @return	Generated bitmap font object.
	 */
	public static function fromXNA(source:FlxGraphicAsset, letters:String = null, glyphBGColor:Int = FlxColor.TRANSPARENT):BitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)	return null;
		
		var font:BitmapFont = BitmapFont.findFont(graphic);
		if (font != null)
			return font;
		
		letters = (letters == null) ? DEFAULT_GLYPHS : letters;
		
		if (graphic == null) return null;
		
		font = new BitmapFont(graphic);
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
		var point:Point = FlxPoint.POINT;
		point.x = point.y = 0;
		var bgColor32:Int = bmd.getPixel32(0, 0);
		bmd.threshold(bmd, bmd.rect, point, "==", bgColor32, 0x00000000, 0xFFFFFFFF, true);
		
		if (glyphBGColor != FlxColor.TRANSPARENT)
		{
			bmd.threshold(bmd, bmd.rect, point, "==", glyphBGColor, FlxColor.TRANSPARENT, FlxColor.WHITE, true);
		}
		
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
	public static function fromMonospace(source:FlxGraphicAsset, letters:String = null, charSize:Point, region:Rectangle = null, spacing:Point = null):BitmapFont
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)	return null;
		
		var font:BitmapFont = BitmapFont.findFont(graphic);
		if (font != null)
			return font;
		
		letters = (letters == null) ? DEFAULT_GLYPHS : letters;
		
		if (graphic == null) return null;
		
		region = (region == null) ? graphic.bitmap.rect : region;
		
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
		
		font = new BitmapFont(graphic);
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
		
		var glyphFrame:GlyphFrame = new GlyphFrame(parent);
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
	
	public static inline function findFont(graphic:FlxGraphic):BitmapFont
	{
		var bitmapFonts:Array<BitmapFont> = cast graphic.getFramesCollections(FrameCollectionType.FONT);
		if (bitmapFonts.length > 0 && bitmapFonts[0] != null)
		{
			return bitmapFonts[0];
		}
		
		return null;
	}
	
	#if FLX_RENDER_BLIT
	public function prepareGlyphs(scale:Float, color:FlxColor, useColor:Bool = true):BitmapGlyphCollection
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
	
	public var font:BitmapFont;
	
	public function new(font:BitmapFont, scale:Float, color:FlxColor, useColor:Bool = true)
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
		var matrix:Matrix = FlxMatrix.MATRIX;
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
		var glyph:GlyphFrame;
		var preparedGlyph:BitmapGlyph;
		var bdWidth:Int, bdHeight:Int;
		var offsetX:Int, offsetY:Int, xAdvance:Int;
		
		spaceWidth = font.spaceWidth * scale;
		
		for (frame in font.frames)
		{
			glyph = cast(frame, GlyphFrame);
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