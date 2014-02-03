package flixel.tile;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;

/**
 * A helper object to keep tilemap drawing performance decent across the new multi-camera system.
 * Pretty much don't even have to think about this class unless you are doing some crazy hacking.
 */
class FlxTilemapBuffer
{
	/**
	 * The current X position of the buffer.
	 */
	public var x:Float;
	/**
	 * The current Y position of the buffer.
	 */
	public var y:Float;
	/**
	 * The width of the buffer (usually just a few tiles wider than the camera).
	 */
	public var width:Float;
	/**
	 * The height of the buffer (usually just a few tiles taller than the camera).
	 */
	public var height:Float;
	/**
	 * Whether the buffer needs to be redrawn.
	 */
	public var dirty:Bool;
	/**
	 * How many rows of tiles fit in this buffer.
	 */
	public var rows:Int;
	/**
	 * How many columns of tiles fit in this buffer.
	 */
	public var columns:Int;
	
	public var forceComplexRender:Bool = false;
	
	#if flash
	private var _pixels:BitmapData;	
	private var _flashRect:Rectangle;
	private var _matrix:Matrix;
	#end

	/**
	 * Instantiates a new camera-specific buffer for storing the visual tilemap data.
	 * 
	 * @param TileWidth		The width of the tiles in this tilemap.
	 * @param TileHeight	The height of the tiles in this tilemap.
	 * @param WidthInTiles	How many tiles wide the tilemap is.
	 * @param HeightInTiles	How many tiles tall the tilemap is.
	 * @param Camera		Which camera this buffer relates to.
	 */
	public function new(TileWidth:Int, TileHeight:Int, WidthInTiles:Int, HeightInTiles:Int, Camera:FlxCamera = null, ScaleX:Float = 1.0, ScaleY:Float = 1.0)
	{
		updateColumns(TileWidth, WidthInTiles, ScaleX, Camera);
		updateRows(TileHeight, HeightInTiles, ScaleY, Camera);
		
		#if flash
		_pixels = new BitmapData(Std.int(columns * TileWidth), Std.int(rows * TileHeight), true, 0);
		_flashRect = new Rectangle(0, 0, _pixels.width, _pixels.height);
		_matrix = new Matrix();
		#end
		
		dirty = true;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		#if flash
		_pixels = null;
		_matrix = null;
		#end
	}
	
	/**
	 * Fill the buffer with the specified color.
	 * Default value is transparent.
	 * 
	 * @param	Color	What color to fill with, in 0xAARRGGBB hex format.
	 */
	#if flash
	public function fill(Color:Int = 0):Void
	{
		_pixels.fillRect(_flashRect, Color);
	}
	
	public var pixels(get, never):BitmapData;
	
	/**
	 * Read-only, nab the actual buffer BitmapData object.
	 * 
	 * @return	The buffer bitmap data.
	 */
	private function get_pixels():BitmapData
	{
		return _pixels;
	}
	
	/**
	 * Just stamps this buffer onto the specified camera at the specified location.
	 * 
	 * @param	Camera		Which camera to draw the buffer onto.
	 * @param	FlashPoint	Where to draw the buffer at in camera coordinates.
	 */
	public function draw(Camera:FlxCamera, FlashPoint:Point, ScaleX:Float = 1.0, ScaleY:Float = 1.0):Void
	{
		if (!forceComplexRender && (ScaleX == 1.0 && ScaleY == 1.0))
		{
			Camera.buffer.copyPixels(_pixels, _flashRect, FlashPoint, null, null, true);
		}
		else
		{
			_matrix.identity();
			_matrix.scale(ScaleX, ScaleY);
			_matrix.translate(FlashPoint.x, FlashPoint.y);
			Camera.buffer.draw(_pixels, _matrix);
		}
	}
	#end
	
	public function updateColumns(TileWidth:Int, WidthInTiles:Int, ScaleX:Float = 1.0, Camera:FlxCamera = null):Void
	{
		if (WidthInTiles < 0) 
		{
			WidthInTiles = 0;
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}

		columns = Math.ceil(Camera.width / (TileWidth * ScaleX)) + 1;
		
		if (columns > WidthInTiles)
		{
			columns = WidthInTiles;
		}
		
		width = Std.int(columns * TileWidth * ScaleX);
	}
	
	public function updateRows(TileHeight:Int, HeightInTiles:Int, ScaleY:Float = 1.0, Camera:FlxCamera = null):Void
	{
		if (HeightInTiles < 0) 
		{
			HeightInTiles = 0;
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		rows = Math.ceil(Camera.height / (TileHeight * ScaleY)) + 1;
		
		if (rows > HeightInTiles)
		{
			rows = HeightInTiles;
		}
		
		height = Std.int(rows * TileHeight * ScaleY);
	}
}