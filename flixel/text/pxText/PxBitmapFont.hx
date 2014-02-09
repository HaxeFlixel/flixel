package flixel.text.pxText;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.system.layer.TileSheetData;
import flixel.util.FlxColor;
import flixel.system.layer.Region;
import flixel.util.loaders.CachedGraphics;

/**
 * Holds information and bitmap glpyhs for a bitmap font.
 * @author Johan Peitz
 * @author Zaphod
 */
class PxBitmapFont 
{
	private static var _storedFonts:Map<String, PxBitmapFont> = new Map<String, PxBitmapFont>();
	
	private static var ZERO_POINT:Point = new Point();
	
	#if flash
	private var _glyphs:Array<BitmapData>;
	#else
	private var _glyphs:Map<Int, PxFontSymbol>;
	private var _num_letters:Int = 0;
	private var _bgTileID:Int = -1;
	#end
	
	private var _glyphString:String;
	private var _maxHeight:Int = 0;
	
	#if flash
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	#end
	
	private var _point:Point;
	
	// Helper for pixelizer format font
	private var _tileRects:Array<Rectangle>;
	// Helper for angel code format font
	private var _symbols:Array<HelperSymbol>;
	// Prepared bitmapData with font glyphsW	
	private var _region:Region;
	private var cachedGraphics:CachedGraphics;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 */
	public function new() 
	{
		_point = new Point();
		
		#if flash
		_matrix = new Matrix();
		_colorTransform = new ColorTransform();
		_glyphs = [];
		#else
		_glyphs = new Map<Int, PxFontSymbol>();
		#end
	}
	
	/**
	 * Loads font data in Pixelizer's format
	 * 
	 * @param	PxBitmapData	Font source image
	 * @param	PxLetters		All letters contained in this font
	 * @return	This PxBitmapFont
	 */
	public function loadPixelizer(PxBitmapData:BitmapData, PxLetters:String):PxBitmapFont
	{
		reset();
		
		_glyphString = PxLetters;
		
		#if flash
		// Fill array with nulls
		for (i in 0...256) 
		{
			_glyphs.push(null);
		}
		#end
		
		if (PxBitmapData != null)
		{
			_tileRects = [];
			var result:BitmapData = preparePixelizerBitmapData(PxBitmapData, _tileRects);
			var key:String = FlxG.bitmap.getUniqueKey("font");
			setCachedGraphics(FlxG.bitmap.add(result, false, key));
			_region = new Region();
			_region.width = cachedGraphics.bitmap.width;
			_region.height = cachedGraphics.bitmap.height;
			var currRect:Rectangle;
			
			#if flash
			updateGlyphData();
			#else
			updateGlyphData(cachedGraphics.tilesheet);
			#end
		}
		
		return this;
	}
	
	/**
	 * Loads font data in AngelCode's format
	 * 
	 * @param	PxBitmapData	Font image source
	 * @param	PxXMLData		Font data in XML format
	 * @return	This PxBitmapFont
	 */
	public function loadAngelCode(pBitmapData:BitmapData, pXMLData:Xml):PxBitmapFont
	{
		reset();
		
		if (pBitmapData != null && pXMLData != null) 
		{
			_symbols = new Array<HelperSymbol>();
			var result:BitmapData = prepareAngelCodeBitmapData(pBitmapData, pXMLData, _symbols);
			var key:String = FlxG.bitmap.getUniqueKey("font");
			setCachedGraphics(FlxG.bitmap.add(result, false, key));
			
			#if flash
			updateGlyphData();
			#else
			updateGlyphData(cachedGraphics.tilesheet);
			#end
		}
		
		return this;
	}
	
	/**
	 * Updates and caches tile data for passed node object
	 */
	public function updateGlyphData(Tiles:TileSheetData = null):Void
	{
		#if !flash
		_glyphs = new Map<Int, PxFontSymbol>();
		#end
		
		var rect:Rectangle;
		
		if (_symbols != null)
		{
			_glyphString = "";
			var point:Point = new Point();
			var bd:BitmapData;
			var charString:String;
			
			for (symbol in _symbols)
			{
				rect = new Rectangle();
				rect.x = symbol.x;
				rect.y = symbol.y;
				rect.width = symbol.width;
				rect.height = symbol.height;
				
				point.x = symbol.xoffset;
				point.y = symbol.yoffset;
				
				charString = String.fromCharCode(symbol.charCode);
				_glyphString += charString;
				
				var xadvance:Int = symbol.xadvance;
				var charWidth:Int = xadvance;
				
				if (rect.width > xadvance)
				{
					charWidth = symbol.width;
					point.x = 0;
				}
				
				// Create glyph
				#if flash
				bd = null;
				
				if (charString != " " && charString != "")
				{
					bd = new BitmapData(charWidth, symbol.height + symbol.yoffset, true, 0x0);
				}
				else
				{
					bd = new BitmapData(charWidth, 1, true, 0x0);
				}
				
				bd.copyPixels(cachedGraphics.bitmap, rect, point, null, null, true);
				
				// Store glyph
				setGlyph(symbol.charCode, bd);
				
				#else
				if (charString != " " && charString != "")
				{
					setGlyph(Tiles, symbol.charCode, rect, Math.floor(point.x), Math.floor(point.y), charWidth);
				}
				else
				{
					setGlyph(Tiles, symbol.charCode, rect, Math.floor(point.x), 1, charWidth);
				}
				#end
			}
		}
		else if (_tileRects != null)
		{
			for (letterID in 0...(_tileRects.length))
			{
				rect = _tileRects[letterID];
				
				// Create glyph
				#if flash
				var bd:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0x0);
				bd.copyPixels(cachedGraphics.bitmap, rect, ZERO_POINT, null, null, true);
				
				// Store glyph
				setGlyph(_glyphString.charCodeAt(letterID), bd);
				#else
				setGlyph(Tiles, _glyphString.charCodeAt(letterID), rect, 0, 0, Std.int(rect.width));
				#end
			}
		}
	}
	
	/**
	 * Internal function. Resets current font.
	 */
	private function reset():Void
	{
		dispose();
		_maxHeight = 0;
		
		#if flash
		_glyphs = [];
		#else
		_glyphs = new Map<Int, PxFontSymbol>();
		_bgTileID = -1;
		#end
		
		_symbols = null;
		_tileRects = null;
		_glyphString = "";
	}
	
	public function preparePixelizerBitmapData(PxBitmapData:BitmapData, PxRects:Array<Rectangle>):BitmapData
	{
		var bgColor:Int = PxBitmapData.getPixel(0, 0);
		var cy:Int = 0;
		var cx:Int;
		
		while (cy < PxBitmapData.height)
		{
			var rowHeight:Int = 0;
			cx = 0;
			
			while (cx < PxBitmapData.width)
			{
				if (Std.int(PxBitmapData.getPixel(cx, cy)) != bgColor) 
				{
					// Found non bg pixel
					var gx:Int = cx;
					var gy:Int = cy;
					
					// Find width and height of glyph
					while (Std.int(PxBitmapData.getPixel(gx, cy)) != bgColor)
					{
						gx++;
					}
					
					while (Std.int(PxBitmapData.getPixel(cx, gy)) != bgColor)
					{
						gy++;
					}
					
					var gw:Int = gx - cx;
					var gh:Int = gy - cy;
					
					PxRects.push(new Rectangle(cx, cy, gw, gh));
					
					// Store max size
					if (gh > rowHeight) 
					{
						rowHeight = gh;
					}
					
					if (gh > _maxHeight) 
					{
						_maxHeight = gh;
					}
					
					// Go to next glyph
					cx += gw;
				}
				
				cx++;
			}
			// Next row
			cy += (rowHeight + 1);
		}
		
		// Fix for html5
		#if (js)
		PxBitmapData.floodFill(0, 0, FlxColor.TRANSPARENT);
		#end
		
		return PxBitmapData;
	}
	
	public function prepareAngelCodeBitmapData(PxBitmapData:BitmapData, PxXMLData:Xml, PxSymbols:Array<HelperSymbol>):BitmapData
	{
		var chars:Xml = null;
		
		for (node in PxXMLData.elements())
		{
			if (node.nodeName == "font")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "chars")
					{
						chars = nodeChild;
						break;
					}
				}
			}
		}
		
		var symbol:HelperSymbol;
		var maxX:Int = 0;
		var maxY:Int = 0;
		
		if (chars != null)
		{
			for (node in chars.elements())
			{
				if (node.nodeName == "char")
				{
					symbol = new HelperSymbol();
					symbol.x = Std.parseInt(node.get("x"));
					symbol.y = Std.parseInt(node.get("y"));
					symbol.width = Std.parseInt(node.get("width"));
					symbol.height = Std.parseInt(node.get("height"));
					symbol.xoffset = Std.parseInt(node.get("xoffset"));
					symbol.yoffset = Std.parseInt(node.get("yoffset"));
					symbol.xadvance = Std.parseInt(node.get("xadvance"));
					symbol.charCode = Std.parseInt(node.get("id"));
					
					PxSymbols.push(symbol);
					
					maxX = symbol.x + symbol.width;
					maxY = symbol.y + symbol.height;
				}
			}
		}
		
		return PxBitmapData;
	}
	
	#if flash
	public function getPreparedGlyphs(PxScale:Float, PxColor:Int, PxUseColorTransform:Bool = true):Array<BitmapData>
	{
		var result:Array<BitmapData> = [];
		
		_matrix.identity();
		_matrix.scale(PxScale, PxScale);
		
		var colorMultiplier:Float = 1 / 255;
		_colorTransform.redOffset = 0;
		_colorTransform.greenOffset = 0;
		_colorTransform.blueOffset = 0;
		_colorTransform.redMultiplier = (PxColor >> 16) * colorMultiplier;
		_colorTransform.greenMultiplier = (PxColor >> 8 & 0xff) * colorMultiplier;
		_colorTransform.blueMultiplier = (PxColor & 0xff) * colorMultiplier;
		
		var glyph:BitmapData;
		var preparedGlyph:BitmapData;
		
		for (i in 0...(_glyphs.length))
		{
			glyph = _glyphs[i];
			var bdWidth:Int;
			var bdHeight:Int;
			
			if (glyph != null)
			{
				if (PxScale > 0)
				{
					bdWidth = Math.ceil(glyph.width * PxScale);
					bdHeight = Math.ceil(glyph.height * PxScale);
				}
				else
				{
					bdWidth = 1;
					bdHeight = 1;
				}
				
				preparedGlyph = new BitmapData(bdWidth, bdHeight, true, 0x00000000);
				
				if (PxUseColorTransform)
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
		#end
		
		_symbols = null;
		_tileRects = null;
		setCachedGraphics(null);
		_region = null;
		_glyphs = null;
	}
	
	#if flash
	/**
	 * Serializes font data to cryptic bit string.
	 * 
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
	private function setGlyph(PxCharID:Int, PxBitmapData:BitmapData):Void 
	{
		if (_glyphs[PxCharID] != null) 
		{
			_glyphs[PxCharID].dispose();
		}
		
		_glyphs[PxCharID] = PxBitmapData;
		
		if (PxBitmapData.height > _maxHeight) 
		{
			_maxHeight = PxBitmapData.height;
		}
	}
	#else
	private function setGlyph(Tiles:TileSheetData, PxCharID:Int, PxRect:Rectangle, PxOffsetX:Int = 0, PxOffsetY:Int = 0, PxAdvanceX:Int = 0):Void
	{
		var tileID:Int = Tiles.addTileRect(PxRect, ZERO_POINT);
		var symbol:PxFontSymbol = new PxFontSymbol();
		symbol.tileID = tileID;
		symbol.xoffset = PxOffsetX;
		symbol.yoffset = PxOffsetY;
		symbol.xadvance = PxAdvanceX;
		
		_glyphs.set(PxCharID, symbol);
		_num_letters++;
		
		if ((Math.floor(PxRect.height) + PxOffsetY) > _maxHeight) 
		{
			_maxHeight = Math.floor(PxRect.height) + PxOffsetY;
		}
	}
	#end
	
	/**
	 * Renders a string of text onto bitmap data using the font.
	 * 
	 * @param	PxBitmapData	Where to render the text.
	 * @param	PxText			Test to render.
	 * @param	PxColor			Color of text to render.
	 * @param	PxOffsetX		X position of thext output.
	 * @param	PxOffsetY		Y position of thext output.
	 */
	#if flash 
	public function render(PxBitmapData:BitmapData, PxFontData:Array<BitmapData>, PxText:String, PxColor:Int, PxOffsetX:Int, PxOffsetY:Int, PxLetterSpacing:Int):Void 
	#else
	public function render(DrawData:Array<Float>, PxText:String, PxColor:Int, PxSecondColor:Int, PxAlpha:Float, PxOffsetX:Float, PxOffsetY:Float, PxLetterSpacing:Int, PxScale:Float, PxUseColor:Bool = true):Void 
	#end
	{
		#if !flash
		var colorMultiplier:Float = 1 / 255;
		var red:Float = colorMultiplier;
		var green:Float = colorMultiplier;
		var blue:Float = colorMultiplier;
		
		if (PxUseColor)
		{
			red = (PxColor >> 16) * colorMultiplier;
			green = (PxColor >> 8 & 0xff) * colorMultiplier;
			blue = (PxColor & 0xff) * colorMultiplier;
		}
		
		PxSecondColor &= 0x00ffffff;
		red *= (PxSecondColor >> 16);
		green *= (PxSecondColor >> 8 & 0xff);
		blue *= (PxSecondColor & 0xff);
		#end
		
		_point.x = PxOffsetX;
		_point.y = PxOffsetY;
		
		#if flash
		var glyph:BitmapData;
		#else
		var glyph:PxFontSymbol;
		var glyphWidth:Int;
		#end
		
		for (i in 0...PxText.length) 
		{
			var charCode:Int = PxText.charCodeAt(i);
			
			#if flash
			glyph = PxFontData[charCode];
			if (glyph != null) 
			#else
			glyph = _glyphs.get(charCode);
			if (_glyphs.exists(charCode))
			#end
			{
				#if flash
				PxBitmapData.copyPixels(glyph, glyph.rect, _point, null, null, true);
				_point.x += glyph.width + PxLetterSpacing;
				#else
				glyphWidth = glyph.xadvance;
				
				// Tile_ID
				DrawData.push(glyph.tileID);
				// X
				DrawData.push(_point.x + glyph.xoffset * PxScale);	
				// Y
				DrawData.push(_point.y + glyph.yoffset * PxScale);	
				DrawData.push(red);
				DrawData.push(green);
				DrawData.push(blue);
				
				_point.x += glyphWidth * PxScale + PxLetterSpacing;
				#end
			}
		}
	}
	
	/**
	 * Returns the width of a certain test string.
	 * 
	 * @param	PxText	String to measure.
	 * @param	PxLetterSpacing	distance between letters
	 * @param	PxFontScale	"size" of the font
	 * @return	Width in pixels.
	 */
	public function getTextWidth(PxText:String, PxLetterSpacing:Int = 0, PxFontScale:Float = 1):Int 
	{
		var w:Int = 0;
		
		var textLength:Int = PxText.length;
		
		for (i in 0...(textLength)) 
		{
			var charCode:Int = PxText.charCodeAt(i);
			
			#if flash
			var glyph:BitmapData = _glyphs[charCode];
			
			if (glyph != null) 
			{
				
				w += glyph.width;
			}
			#else
			if (_glyphs.exists(charCode)) 
			{
				
				w += _glyphs.get(charCode).xadvance;
			}
			#end
		}
		
		w = Math.round(w * PxFontScale);
		
		if (textLength > 1)
		{
			w += (textLength - 1) * PxLetterSpacing;
		}
		
		return w;
	}
	
	/**
	 * Returns height of font in pixels.
	 * 
	 * @return Height of font in pixels.
	 */
	public function getFontHeight():Int 
	{
		return _maxHeight;
	}
	
	/**
	 * Returns number of letters available in this font.
	 * 
	 * @return Number of letters available in this font.
	 */
	public var numLetters(get, never):Int;
	
	#if !flash
	public var pixels(get_pixels, null):BitmapData;
	
	private function get_pixels():BitmapData 
	{
		if (!cachedGraphics.isDumped)
		{
			return cachedGraphics.bitmap;
		}
		return null;
	}
	
	public var bgTileID(get_bgTileID, null):Int;
	
	function get_bgTileID():Int 
	{
		return _bgTileID;
	}
	#end
	
	public function get_numLetters():Int 
	{
		#if flash
		return _glyphs.length;
		#else
		return _num_letters;
		#end
	}
	
	private function setCachedGraphics(value:CachedGraphics):Void
	{
		if (cachedGraphics != null && cachedGraphics != value)
		{
			cachedGraphics.useCount--;
		}
		
		if (cachedGraphics != value && value != null)
		{
			value.useCount++;
		}
		cachedGraphics = value;
	}
	
	/**
	 * Stores a font for global use using an identifier.
	 * 
	 * @param	PxHandle	String identifer for the font.
	 * @param	PxFont		Font to store.
	 */
	public static function store(PxHandle:String, PxFont:PxBitmapFont):Void
	{
		_storedFonts.set(PxHandle, PxFont);
	}
	
	/**
	 * Retrieves a font previously stored.
	 * 
	 * @param	PxHandle	Identifier of font to fetch.
	 * @return	Stored font, or null if no font was found.
	 */
	public static function fetch(PxHandle:String):PxBitmapFont
	{
		var f:PxBitmapFont = _storedFonts.get(PxHandle);
		
		return f;
	}
	
	public static function clearStorage():Void
	{
		for (font in _storedFonts)
		{
			font.dispose();
		}
		
		_storedFonts = new Map<String, PxBitmapFont>();
	}
}

private class HelperSymbol
{
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var xoffset:Int;
	public var yoffset:Int;
	public var xadvance:Int;
	public var charCode:Int;

	public function new () {  }
}