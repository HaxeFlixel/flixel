package org.flixel.system.preloaderHelpers;

import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.display.Graphics;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

#if !flash
import nme.display.Tilesheet;
#end

/**
 * Holds information and bitmap glpyhs for a bitmap font.
 * @author Johan Peitz
 */
class PxBitmapFont 
{
	private static var _storedFonts:Hash<PxBitmapFont> = new Hash<PxBitmapFont>();
	
	private static var ZERO_POINT:Point = new Point();
	
	#if flash
	private var _glyphs:Array<BitmapData>;
	#else
	private var _glyphs:IntHash<Int>;
	private var _num_letters:Int;
	private var _tileSheet:Tilesheet;
	private static var _flags = Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA | Tilesheet.TILE_RGB;
	private var _glyphWidthData:Array<Int>;
	#end
	private var _glyphString:String;
	private var _maxHeight:Int;
	
	#if flash
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	#end
	
	private var _point:Point;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 * @param	pBitmapData	The bitmap data to copy letters from.
	 * @param	pLetters	String of letters available in the bitmap data.
	 */
	public function new(pBitmapData:BitmapData, pLetters:String) 
	{
		_maxHeight = 0;
		_point = new Point();
		#if flash
		_matrix = new Matrix();
		_colorTransform = new ColorTransform();
		_glyphs = [];
		#else
		_glyphWidthData = [];
		_glyphs = new IntHash<Int>();
		_num_letters = 0;
		#end
		
		_glyphString = pLetters;
		
		#if flash
		// fill array with nulls
		for (i in 0...(256)) 
		{
			_glyphs.push(null);
		}
		#end
		
		if (pBitmapData != null) 
		{
			var tileRects:Array<Rectangle> = [];
			var result:BitmapData = prepareBitmapData(pBitmapData, tileRects);
			var currRect:Rectangle;
			
			#if !flash
			_tileSheet = new Tilesheet(result);
			#end
			
			for (letterID in 0...(tileRects.length))
			{
				currRect = tileRects[letterID];
				
				// create glyph
				#if flash
				var bd:BitmapData = new BitmapData(Std.int(currRect.width), Std.int(currRect.height), true, 0x0);
				bd.copyPixels(pBitmapData, currRect, ZERO_POINT, null, null, true);
				
				// store glyph
				setGlyph(_glyphString.charCodeAt(letterID), bd);
				#else
				setGlyph(_glyphString.charCodeAt(letterID), currRect, letterID);
				#end
			}
		}
	}
	
	public function prepareBitmapData(pBitmapData:BitmapData, pRects:Array<Rectangle>):BitmapData
	{
		var bgColor:Int = pBitmapData.getPixel(0, 0);
		var cy:Int = 0;
		var cx:Int;
		
		while (cy < pBitmapData.height)
		{
			var rowHeight:Int = 0;
			cx = 0;
			
			while (cx < pBitmapData.width)
			{
				if (Std.int(pBitmapData.getPixel(cx, cy)) != bgColor) 
				{
					// found non bg pixel
					var gx:Int = cx;
					var gy:Int = cy;
					// find width and height of glyph
					while (Std.int(pBitmapData.getPixel(gx, cy)) != bgColor)
					{
						gx++;
					}
					while (Std.int(pBitmapData.getPixel(cx, gy)) != bgColor)
					{
						gy++;
					}
					var gw:Int = gx - cx;
					var gh:Int = gy - cy;
					
					pRects.push(new Rectangle(cx, cy, gw, gh));
					
					// store max size
					if (gh > rowHeight) 
					{
						rowHeight = gh;
					}
					if (gh > _maxHeight) 
					{
						_maxHeight = gh;
					}
					
					// go to next glyph
					cx += gw;
				}
				
				cx++;
			}
			// next row
			cy += (rowHeight + 1);
		}
		
		var resultBitmapData:BitmapData = pBitmapData.clone();
		
		#if flash
		var pixelColor:UInt;
		var bgColor32:UInt = pBitmapData.getPixel(0, 0);
		#elseif js
		var pixelColor:Int;
		var bgColor32:Int = pBitmapData.getPixel(0, 0);
		#else
		var pixelColor:BitmapInt32;
		var bgColor32:BitmapInt32 = pBitmapData.getPixel32(0, 0);
		#end
		
		cy = 0;
		while (cy < pBitmapData.height)
		{
			cx = 0;
			while (cx < pBitmapData.width)
			{
				pixelColor = pBitmapData.getPixel32(cx, cy);
				#if neko
				if (pixelColor.rgb == bgColor32.rgb && pixelColor.a == bgColor32.a)
				{
					resultBitmapData.setPixel32(cx, cy, {rgb: 0x000000, a: 0x00});
				}
				#else
				if (pixelColor == bgColor32)
				{
					resultBitmapData.setPixel32(cx, cy, 0x00000000);
				}
				#end
				cx++;
			}
			cy++;
		}
		
		return resultBitmapData;
	}
	
	#if flash
	public function getPreparedGlyphs(pScale:Float, pColor:Int, pUseColorTransform:Bool = true):Array<BitmapData>
	{
		var result:Array<BitmapData> = [];
		
		_matrix.identity();
		_matrix.scale(pScale, pScale);
		
		var colorMultiplier:Float = 1 / 255;
		_colorTransform.redOffset = 0;
		_colorTransform.greenOffset = 0;
		_colorTransform.blueOffset = 0;
		_colorTransform.redMultiplier = (pColor >> 16) * colorMultiplier;
		_colorTransform.greenMultiplier = (pColor >> 8 & 0xff) * colorMultiplier;
		_colorTransform.blueMultiplier = (pColor & 0xff) * colorMultiplier;
		
		var glyph:BitmapData;
		var preparedGlyph:BitmapData;
		for (i in 0...(_glyphs.length))
		{
			glyph = _glyphs[i];
			if (glyph != null)
			{
				preparedGlyph = new BitmapData(Std.int(glyph.width * pScale), Std.int(glyph.height * pScale), true, 0x00000000);
				if (pUseColorTransform)
				{
					preparedGlyph.draw(glyph,  _matrix, _colorTransform);
				}
				else
				{
					preparedGlyph.draw(glyph,  _matrix);
				}
				result[i] = preparedGlyph;
			}
		}
		
		return result;
	}
	#end
	
	/**
	 * Clears all resources used by the font.
	 */
	public function dispose():Void 
	{
		#if flash
		var bd:BitmapData;
		for (i in 0...(_glyphs.length)) 
		{
			bd = _glyphs[i];
			if (bd != null) 
			{
				_glyphs[i].dispose();
			}
		}
		#else
		if (_tileSheet != null)
		{
			_tileSheet = null;
		}
		#end
		_glyphs = null;
	}
	
	#if flash
	/**
	 * Serializes font data to cryptic bit string.
	 * @return	Cryptic string with font as bits.
	 */
	public function getFontData():String 
	{
		var output:String = "";
		for (i in 0...(_glyphString.length)) 
		{
			var charCode:Int = _glyphString.charCodeAt(i);
			var glyph:BitmapData = _glyphs[charCode];
			output += _glyphString.substr(i, 1);
			output += glyph.width;
			output += glyph.height;
			for (py in 0...(glyph.height)) 
			{
				for (px in 0...(glyph.width)) 
				{
					output += (glyph.getPixel32(px, py) != 0 ? "1":"0");
				}
			}
		}
		return output;
	}
	#end
	
	#if flash
	private function setGlyph(pCharID:Int, pBitmapData:BitmapData):Void 
	{
		if (_glyphs[pCharID] != null) 
		{
			_glyphs[pCharID].dispose();
		}
		
		_glyphs[pCharID] = pBitmapData;
		
		if (pBitmapData.height > _maxHeight) 
		{
			_maxHeight = pBitmapData.height;
		}
	}
	#else
	private function setGlyph(pCharID:Int, pRect:Rectangle, pGlyphID:Int):Void 
	{
		_tileSheet.addTileRect(pRect);
		_glyphs.set(pCharID, pGlyphID);
		_num_letters++;
		_glyphWidthData[pCharID] = Std.int(pRect.width);
		
		if (Std.int(pRect.height) > _maxHeight) 
		{
			_maxHeight = Std.int(pRect.height);
		}
	}
	#end
	
	/**
	 * Renders a string of text onto bitmap data using the font.
	 * @param	pBitmapData	Where to render the text.
	 * @param	pText	Test to render.
	 * @param	pColor	Color of text to render.
	 * @param	pOffsetX	X position of thext output.
	 * @param	pOffsetY	Y position of thext output.
	 */
	#if flash 
	public function render(pBitmapData:BitmapData, pFontData:Array<BitmapData>, pText:String, pColor:UInt, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int, pAngle:Float = 0):Void 
	#else
	public function render(drawData:Array<Float>, pText:String, pColor:Int, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int, pScale:Float, pAngle:Float = 0, pUseColorTransform:Bool = true):Void 
	#end
	{
		_point.x = pOffsetX;
		_point.y = pOffsetY;
		#if flash
		var glyph:BitmapData;
		#else
		var glyph:Int;
		var glyphWidth:Int;
		#end
		
		for (i in 0...(pText.length)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			#if flash
			glyph = pFontData[charCode];
			if (glyph != null) 
			#else
			glyph = _glyphs.get(charCode);
			if (_glyphs.exists(charCode))
			#end
			{
				#if flash
				pBitmapData.copyPixels(glyph, glyph.rect, _point, null, null, true);
				_point.x += glyph.width + pLetterSpacing;
				#else
				glyphWidth = _glyphWidthData[charCode];
				var red:Float = (pColor >> 16 & 0xFF) / 255;
				var green:Float = (pColor >> 8 & 0xFF) / 255;
				var blue:Float = (pColor & 0xFF) / 255;
				// x, y, tile_ID, scale, rotation, red, green, blue, alpha
				drawData.push(_point.x);	// x
				drawData.push(_point.y);	// y
				drawData.push(glyph);		// tile_ID
				drawData.push(pScale);		// scale
				drawData.push(0);			// rotation
				if (pUseColorTransform)
				{
					drawData.push(red);			
					drawData.push(green);
					drawData.push(blue);
				}
				else
				{
					drawData.push(1);			
					drawData.push(1);
					drawData.push(1);
				}
				drawData.push(pAlpha);		// alpha
				_point.x += glyphWidth * pScale + pLetterSpacing;
				#end
			}
		}
	}
	
	#if !flash
	/**
	 * Internal method for actually drawing text on cpp and neko targets
	 * @param	graphics
	 * @param	drawData
	 */
	public function drawText(graphics:Graphics, drawData:Array<Float>):Void
	{
		_tileSheet.drawTiles(graphics, drawData, false, _flags);
	}
	#end
	
	/**
	 * Returns the width of a certain test string.
	 * @param	pText	String to measure.
	 * @param	pLetterSpacing	distance between letters
	 * @param	pFontScale	"size" of the font
	 * @return	Width in pixels.
	 */
	public function getTextWidth(pText:String, pLetterSpacing:Int = 0, pFontScale:Float = 1.0):Int 
	{
		var w:Int = 0;
		
		var textLength:Int = pText.length;
		for (i in 0...(textLength)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			#if flash
			var glyph:BitmapData = _glyphs[charCode];
			if (glyph != null) 
			{
				
				w += glyph.width;
			}
			#else
			var glyphWidth:Int = _glyphWidthData[charCode];
			if (_glyphs.exists(charCode)) 
			{
				
				w += glyphWidth;
			}
			#end
		}
		
		w = Math.round(w * pFontScale);
		
		if (textLength > 1)
		{
			w += (textLength - 1) * pLetterSpacing;
		}
		
		return w;
	}
	
	/**
	 * Returns height of font in pixels.
	 * @return Height of font in pixels.
	 */
	public function getFontHeight():Int 
	{
		return _maxHeight;
	}
	
	/**
	 * Returns number of letters available in this font.
	 * @return Number of letters available in this font.
	 */
	public var numLetters(get_numLetters, null):Int;
	
	private function get_numLetters():Int 
	{
		#if flash
		return _glyphs.length;
		#else
		return _num_letters;
		#end
	}
	
	/**
	 * Stores a font for global use using an identifier.
	 * @param	pHandle	String identifer for the font.
	 * @param	pFont	Font to store.
	 */
	public static function store(pHandle:String, pFont:PxBitmapFont):Void 
	{
		_storedFonts.set(pHandle, pFont);
	}
	
	/**
	 * Retrieves a font previously stored.
	 * @param	pHandle	Identifier of font to fetch.
	 * @return	Stored font, or null if no font was found.
	 */
	public static function fetch(pHandle:String):PxBitmapFont 
	{
		var f:PxBitmapFont = _storedFonts.get(pHandle);
		return f;
	}

}