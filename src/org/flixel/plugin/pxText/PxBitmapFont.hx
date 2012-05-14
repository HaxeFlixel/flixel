package org.flixel.plugin.pxText;

import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.display.Graphics;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

#if (cpp || neko)
import nme.display.Tilesheet;
import org.flixel.tileSheetManager.TileSheetData;
import org.flixel.tileSheetManager.TileSheetManager;
#end

/**
 * Holds information and bitmap glpyhs for a bitmap font.
 * @author Johan Peitz
 */
class PxBitmapFont 
{
	private static var _storedFonts:Hash<PxBitmapFont> = new Hash<PxBitmapFont>();
	
	private static var ZERO_POINT:Point = new Point();
	
	#if (flash || js)
	private var _glyphs:Array<BitmapData>;
	#else
	private var _glyphs:Array<Int>;
	private var _tileSheetData:TileSheetData;
	private var _glyphWidthData:Array<Int>;
	private var _antialiasing:Bool;
	#end
	private var _glyphString:String;
	private var _maxHeight:Int;
	
	#if (flash || js)
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
		#if (flash || js)
		_matrix = new Matrix();
		_colorTransform = new ColorTransform();
		#else
		_glyphWidthData = [];
		_antialiasing = false;
		#end
		
		_glyphs = [];
		_glyphString = pLetters;
		
		// fill array with nulls
		for (i in 0...(256)) 
		{
			_glyphs.push(null);
		}
		
		if (pBitmapData != null) 
		{
			var tileRects:Array<Rectangle> = [];
			var result:BitmapData = prepareBitmapData(pBitmapData, tileRects);
			var currRect:Rectangle;
			
			#if (cpp || neko)
			_tileSheetData = TileSheetManager.addTileSheet(result);
			#end
			
			for (letterID in 0...(tileRects.length))
			{
				currRect = tileRects[letterID];
				
				// create glyph
				#if (flash || js)
				var bd:BitmapData = new BitmapData(Math.floor(currRect.width), Math.floor(currRect.height), true, 0x0);
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
		
		#if neko
		var resultBitmapData:BitmapData = pBitmapData.clone();
		#else
		var resultBitmapData:BitmapData = pBitmapData.clone();
		#end
		
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
	
	#if (flash || js)
	public function getPreparedGlyphs(pScale:Float, pColor:Int):Array<BitmapData>
	{
		var result:Array<BitmapData> = [];
		
		_matrix.identity();
		_matrix.scale(pScale, pScale);
		_colorTransform.color = pColor;
		
		var glyph:BitmapData;
		var preparedGlyph:BitmapData;
		for (i in 0...(_glyphs.length))
		{
			glyph = _glyphs[i];
			if (glyph != null)
			{
				preparedGlyph = new BitmapData(Math.floor(glyph.width * pScale), Math.floor(glyph.height * pScale), true, 0x00000000);
				preparedGlyph.draw(glyph,  _matrix, _colorTransform);
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
		#if (flash || js)
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
		_tileSheetData = null;
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
	
	#if (flash || js)
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
		_glyphs[pCharID] = _tileSheetData.addTileRect(pRect, ZERO_POINT);
		_glyphWidthData[pCharID] = Math.floor(pRect.width);
		
		if (Math.floor(pRect.height) > _maxHeight) 
		{
			_maxHeight = Math.floor(pRect.height);
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
	public function render(pBitmapData:BitmapData, pFontData:Array<BitmapData>, pText:String, pColor:UInt, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int):Void 
	#elseif js
	public function render(pBitmapData:BitmapData, pFontData:Array<BitmapData>, pText:String, pColor:Int, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int):Void 
	#else
	public function render(drawData:Array<Float>, pText:String, pColor:Int, pSecondColor:BitmapInt32, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int, pScale:Float):Void 
	#end
	{
		#if (cpp || neko)
		var colorMultiplier:Float = 0.00392 * 0.00392;
		
		var red:Float = (pColor >> 16) * colorMultiplier;
		var green:Float = (pColor >> 8 & 0xff) * colorMultiplier;
		var blue:Float = (pColor & 0xff) * colorMultiplier;
		#end
		
		#if cpp
		red *= (pSecondColor >> 16);
		green *= (pSecondColor >> 8 & 0xff);
		blue *= (pSecondColor & 0xff);
		#elseif neko
		red *= (pSecondColor.rgb >> 16);
		green *= (pSecondColor.rgb >> 8 & 0xff);
		blue *= (pSecondColor.rgb & 0xff);
		#end
		
		_point.x = pOffsetX;
		_point.y = pOffsetY;
		#if (flash || js)
		var glyph:BitmapData;
		#else
		var glyph:Int;
		var glyphWidth:Int;
		#end
		
		for (i in 0...(pText.length)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			#if (flash || js)
			glyph = pFontData[charCode];
			#else
			glyph = _glyphs[charCode];
			#end
			if (glyph != null) 
			{
				#if (flash || js)
				pBitmapData.copyPixels(glyph, glyph.rect, _point, null, null, true);
				_point.x += glyph.width + pLetterSpacing;
				#else
				glyphWidth = _glyphWidthData[charCode];
				
				drawData.push(glyph);		// tile_ID
				drawData.push(_point.x);	// x
				drawData.push(_point.y);	// y
				drawData.push(red);
				drawData.push(green);
				drawData.push(blue);
				
				_point.x += glyphWidth * pScale + pLetterSpacing;
				#end
			}
		}
	}
	
	/**
	 * Returns the width of a certain test string.
	 * @param	pText	String to measure.
	 * @param	pLetterSpacing	distance between letters
	 * @param	pFontScale	"size" of the font
	 * @return	Width in pixels.
	 */
	public function getTextWidth(pText:String, ?pLetterSpacing:Int = 0, ?pFontScale:Float = 1.0):Int 
	{
		var w:Int = 0;
		
		var textLength:Int = pText.length;
		for (i in 0...(textLength)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			#if (flash || js)
			var glyph:BitmapData = _glyphs[charCode];
			if (glyph != null) 
			{
				
				w += glyph.width;
			}
			#else
			var glyphWidth:Int = _glyphWidthData[charCode];
			if (glyphWidth != null) 
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
	
	#if (cpp || neko)
	public var tileSheetData(get_tileSheetData, null):TileSheetData;
	
	private function get_tileSheetData():TileSheetData 
	{
		return _tileSheetData;
	}
	
	public function getTileSheetIndex():Int
	{
		if (_tileSheetData != null)
		{
			return TileSheetManager.getTileSheetIndex(_tileSheetData);
		}
		
		return -1;
	}
	
	public var antialiasing(getAntialiasing, setAntialiasing):Bool;
	
	public function getAntialiasing():Bool
	{
		return _antialiasing;
	}
	
	public function setAntialiasing(val:Bool):Bool
	{
		_antialiasing = val;
		if (_tileSheetData != null)
		{
			_tileSheetData.antialiasing = val;
		}
		return val;
	}
	#end
	
	public function get_numLetters():Int 
	{
		return _glyphs.length;
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