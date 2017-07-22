package flixel.graphics.tile; #if (openfl < "4.0.0")

import openfl.display.Shader;
import openfl.display.Sprite;
import openfl.display.Tilesheet;

class FlxTilesheet extends Tilesheet
{
	/**
	 * Tracks total number of `drawTiles()` calls made each frame.
	 */
	public static var _DRAWCALLS:Int = 0;
	
	public static inline var TILE_SCALE = Tilesheet.TILE_SCALE;
	public static inline var TILE_ROTATION = Tilesheet.TILE_ROTATION;
	public static inline var TILE_RGB = Tilesheet.TILE_RGB;
	public static inline var TILE_ALPHA = Tilesheet.TILE_ALPHA;
	public static inline var TILE_TRANS_2x2 = Tilesheet.TILE_TRANS_2x2;
	public static inline var TILE_RECT = Tilesheet.TILE_RECT;
	public static inline var TILE_ORIGIN = Tilesheet.TILE_ORIGIN;
	public static inline var TILE_BLEND_NORMAL = Tilesheet.TILE_BLEND_NORMAL;
	public static inline var TILE_BLEND_ADD = Tilesheet.TILE_BLEND_ADD;
	public static inline var TILE_BLEND_MULTIPLY = Tilesheet.TILE_BLEND_MULTIPLY;
	public static inline var TILE_BLEND_SCREEN = Tilesheet.TILE_BLEND_SCREEN;
	public static inline var TILE_BLEND_SUBTRACT = Tilesheet.TILE_BLEND_SUBTRACT;
	
	#if !openfl_legacy
	public static inline var TILE_TRANS_COLOR = Tilesheet.TILE_TRANS_COLOR;
	public static inline var TILE_BLEND_DARKEN = Tilesheet.TILE_BLEND_DARKEN;
	public static inline var TILE_BLEND_LIGHTEN = Tilesheet.TILE_BLEND_LIGHTEN;
	public static inline var TILE_BLEND_OVERLAY = Tilesheet.TILE_BLEND_OVERLAY;
	public static inline var TILE_BLEND_HARDLIGHT = Tilesheet.TILE_BLEND_HARDLIGHT;
	public static inline var TILE_BLEND_DIFFERENCE = Tilesheet.TILE_BLEND_DIFFERENCE;
	public static inline var TILE_BLEND_INVERT = Tilesheet.TILE_BLEND_INVERT;
	#end
	
	public function draw (canvas:Sprite, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, #if !openfl_legacy shader:Shader, #end count:Int = -1):Void
	{
		canvas.graphics.drawTiles (this, tileData, smooth, flags, #if !openfl_legacy shader, #end count);
	}
}

#else

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.display.Shader;
import openfl.display.Sprite;
import openfl.display.Tile;
import openfl.display.TileArray;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.Lib;

class FlxTilesheet extends Tileset
{
	/**
	 * Tracks total number of `drawTiles()` calls made each frame.
	 */
	public static var _DRAWCALLS:Int = 0;
	
	public static inline var TILE_SCALE = 0x0001;
	public static inline var TILE_ROTATION = 0x0002;
	public static inline var TILE_RGB = 0x0004;
	public static inline var TILE_ALPHA = 0x0008;
	public static inline var TILE_TRANS_2x2 = 0x0010;
	public static inline var TILE_RECT = 0x0020;
	public static inline var TILE_ORIGIN = 0x0040;
	public static inline var TILE_TRANS_COLOR = 0x0080;
	public static inline var TILE_BLEND_NORMAL = 0x00000000;
	public static inline var TILE_BLEND_ADD = 0x00010000;
	public static inline var TILE_BLEND_MULTIPLY = 0x00020000;
	public static inline var TILE_BLEND_SCREEN = 0x00040000;
	public static inline var TILE_BLEND_SUBTRACT = 0x00080000;
	public static inline var TILE_BLEND_DARKEN = 0x00100000;
	public static inline var TILE_BLEND_LIGHTEN = 0x00200000;
	public static inline var TILE_BLEND_OVERLAY = 0x00400000;
	public static inline var TILE_BLEND_HARDLIGHT = 0x00800000;
	public static inline var TILE_BLEND_DIFFERENCE = 0x01000000;
	public static inline var TILE_BLEND_INVERT = 0x02000000;
	
	private var _tilemap = new Map<Sprite, Tilemap>();
	
	public function new(image:BitmapData)
	{	
		super(image);
		// TODO: Better solution, cleanup removed tilemaps
		Lib.current.addEventListener(Event.ENTER_FRAME, function(_)
		{
			var tilemap:Tilemap;
			for (canvas in _tilemap.keys())
			{
				tilemap = _tilemap[canvas];
				if (tilemap.parent == null)
				{
					_tilemap.remove(canvas);
				}
			}
		});
	}
	
	public function draw (canvas:Sprite, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, shader:Shader, count:Int = -1):Void
	{
		var tilemap = _tilemap[canvas];
		if (tilemap == null)
		{
			tilemap = new Tilemap(0, 0, this);
			_tilemap[canvas] = tilemap;
			canvas.addChild(tilemap);
		}
		tilemap.shader = shader;
		tilemap.visible = true;
		tilemap.width = Lib.current.stage.stageWidth;
		tilemap.height = Lib.current.stage.stageHeight;
		tilemap.smoothing = smooth;
		_updateTileData(tilemap, tileData, flags, count);
	}
	
	private function _updateTileData(tilemap:Tilemap, tileData:Array<Float>, flags:Int, count:Int):Void
	{
		var useScale = (flags & TILE_SCALE) > 0;
		var useRotation = (flags & TILE_ROTATION) > 0;
		var useTransform = (flags & TILE_TRANS_2x2) > 0;
		var useRGB = (flags & TILE_RGB) > 0;
		var useAlpha = (flags & TILE_ALPHA) > 0;
		var useRect = (flags & TILE_RECT) > 0;
		var useOrigin = (flags & TILE_ORIGIN) > 0;
		var useRGBOffset = ((flags & TILE_TRANS_COLOR) > 0);
		
		var blendMode:BlendMode = switch(flags & 0xF0000) {
			case TILE_BLEND_ADD:                ADD;
			case TILE_BLEND_MULTIPLY:           MULTIPLY;
			case TILE_BLEND_SCREEN:             SCREEN;
			case TILE_BLEND_SUBTRACT:           SUBTRACT;
			case _: switch(flags & 0xF00000) {
				case TILE_BLEND_DARKEN:         DARKEN;
				case TILE_BLEND_LIGHTEN:        LIGHTEN;
				case TILE_BLEND_OVERLAY:        OVERLAY;
				case TILE_BLEND_HARDLIGHT:      HARDLIGHT;
				case _: switch(flags & 0xF000000) {
					case TILE_BLEND_DIFFERENCE: DIFFERENCE;
					case TILE_BLEND_INVERT:     INVERT;
					case _:                               NORMAL;
				}
			}
		};
		
		if (useTransform) { useScale = false; useRotation = false; }
		
		var scaleIndex = 0;
		var rotationIndex = 0;
		var rgbIndex = 0;
		var rgbOffsetIndex = 0;
		var alphaIndex = 0;
		var transformIndex = 0;
		
		var numValues = 3;
		
		if (useRect) { numValues = useOrigin ? 8 : 6; }
		if (useScale) { scaleIndex = numValues; numValues ++; }
		if (useRotation) { rotationIndex = numValues; numValues ++; }
		if (useTransform) { transformIndex = numValues; numValues += 4; }
		if (useRGB) { rgbIndex = numValues; numValues += 3; }
		if (useAlpha) { alphaIndex = numValues; numValues ++; }
		if (useRGBOffset) { rgbOffsetIndex = numValues; numValues += 4; }
		
		var totalCount = tileData.length;
		if (count >= 0 && totalCount > count) totalCount = count;
		var itemCount = Math.ceil (totalCount / numValues);
		var iIndex = 0;
		var tint = 0xFFFFFF;
		
		var a, b, c, d, tx, ty, x, y, width, height;
		var rM = 1.0, gM = 1.0, bM = 1.0, aM = 1.0, rO = 0.0, gO = 0.0, bO = 0.0, aO = 0.0;
		
		var tileArray = tilemap.getTiles();
		tileArray.length = itemCount;
		tileArray.position = 0;
		
		while (iIndex < totalCount) {
			
			// useRect is always true
			
			x = tileData[iIndex + 2];
			y = tileData[iIndex + 3];
			width = tileData[iIndex + 4];
			height = tileData[iIndex + 5];
			
			tileArray.setRect(x, y, width, height);
			
			// useTransform is always true
			
			a = tileData[iIndex + transformIndex + 0];
			b = tileData[iIndex + transformIndex + 1];
			c = tileData[iIndex + transformIndex + 2];
			d = tileData[iIndex + transformIndex + 3];
			tx = tileData[iIndex + 0];
			ty = tileData[iIndex + 1];
			
			tileArray.setMatrix(a, b, c, d, tx, ty);
			
			// useAlpha is always true
			
			tileArray.alpha = tileData[iIndex + alphaIndex];
			
			if (useRGB)
			{
				rM = tileData[iIndex + rgbIndex];
				gM = tileData[iIndex + rgbIndex + 1];
				bM = tileData[iIndex + rgbIndex + 2];
				aM = tileData[iIndex + rgbIndex + 3];
			}
			
			if (useRGBOffset)
			{
				rO = tileData[iIndex + rgbOffsetIndex];
				gO = tileData[iIndex + rgbOffsetIndex];
				bO = tileData[iIndex + rgbOffsetIndex];
				aO = tileData[iIndex + rgbOffsetIndex];
			}
			
			if (useRGB || useRGBOffset)
			{
				tileArray.setColorTransform(rM, gM, bM, aM, rO, gO, bO, aO);
			}
			
			tileArray.position++;
			iIndex += numValues;
			
		}
		
		tilemap.setTiles(tileArray);
	}
	
	//public function getTileCenter (index:Int):Point;
	//public function getTileRect (index:Int):Rectangle;
	//public function getTileUVs (index:Int):Rectangle;
}

#end