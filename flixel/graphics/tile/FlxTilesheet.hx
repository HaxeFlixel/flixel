package flixel.graphics.tile; #if (openfl < "4.0.0")

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
	
	public function draw (canvas:Sprite, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, #if !openfl_legacy shader:Dynamic, #end, count:Int = -1):Void
	{
		drawTiles (canvas.graphics, tileData, smooth, flags, #if !openfl_legacy shader:Dynamic, #end count);
	}
}

#else

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Tileset;
import openfl.geom.Rectangle;
import openfl.geom.Point;

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
	
	private var _centerPoints = new Array<Point>();
	
	public function new(image:BitmapData)
	{	
		super(image);
	}
	
	public function addTileRect(rectangle:Rectangle, centerPoint:Point = null):Int
	{
		var id = addRect (rectangle);
		_centerPoints.push (centerPoint);
		return id;
	}
	
	public function draw (canvas:Sprite, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, #if !openfl_legacy shader:Dynamic, #end count:Int = -1):Void
	{
		//drawTiles (canvas.graphics, tileData, smooth, flags, count);
	}
	
	//public function getTileCenter (index:Int):Point;
	//public function getTileRect (index:Int):Rectangle;
	//public function getTileUVs (index:Int):Rectangle;
}

#end