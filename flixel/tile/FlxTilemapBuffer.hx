package flixel.tile;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;

/**
 * A helper object to keep tilemap drawing performance decent across the new multi-camera system.
 * Pretty much don't even have to think about this class unless you are doing some crazy hacking.
 */
class FlxTilemapBuffer
{
	/**
	 * The current X position of the buffer.
	 */
	public var x:Float = 0;
	/**
	 * The current Y position of the buffer.
	 */
	public var y:Float = 0;
	/**
	 * The width of the buffer (usually just a few tiles wider than the camera).
	 */
	public var width:Float = 0;
	/**
	 * The height of the buffer (usually just a few tiles taller than the camera).
	 */
	public var height:Float = 0;
	/**
	 * Whether the buffer needs to be redrawn.
	 */
	public var dirty:Bool = false;
	/**
	 * How many rows of tiles fit in this buffer.
	 */
	public var rows:Int = 0;
	/**
	 * How many columns of tiles fit in this buffer.
	 */
	public var columns:Int = 0;
	/**
	 * Whether or not the coordinates should be rounded during draw(), true by default (recommended for pixel art). 
	 * Only affects tilesheet rendering and rendering using BitmapData.draw() in blitting.
	 * (copyPixels() only renders on whole pixels by nature). Causes draw() to be used if false, which is more expensive.
	 */
	public var pixelPerfectRender:Bool = true;
	
	#if FLX_RENDER_BLIT
	/**
	 * The actual buffer BitmapData.
	 */ 
	public var pixels(default, null):BitmapData;
	
	private var _flashRect:Rectangle;
	private var _matrix:Matrix;
	#end

	/**
	 * Instantiates a new camera-specific buffer for storing the visual tilemap data.
	 * 
	 * @param	TileWidth		The width of the tiles in this tilemap.
	 * @param	TileHeight	The height of the tiles in this tilemap.
	 * @param	WidthInTiles	How many tiles wide the tilemap is.
	 * @param	HeightInTiles	How many tiles tall the tilemap is.
	 * @param	Camera		Which camera this buffer relates to.
	 */
	public function new(TileWidth:Int, TileHeight:Int, WidthInTiles:Int, HeightInTiles:Int, Camera:FlxCamera = null, ScaleX:Float = 1.0, ScaleY:Float = 1.0)
	{
		updateColumns(TileWidth, WidthInTiles, ScaleX, Camera);
		updateRows(TileHeight, HeightInTiles, ScaleY, Camera);
		
		#if FLX_RENDER_BLIT
		pixels = new BitmapData(Std.int(columns * TileWidth), Std.int(rows * TileHeight), true, 0);
		_flashRect = new Rectangle(0, 0, pixels.width, pixels.height);
		_matrix = new Matrix();
		#end
		
		dirty = true;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		#if FLX_RENDER_BLIT
		pixels = null;
		_matrix = null;
		#end
	}
	
	/**
	 * Fill the buffer with the specified color.
	 * Default value is transparent.
	 * 
	 * @param	Color	What color to fill with, in 0xAARRGGBB hex format.
	 */
	#if FLX_RENDER_BLIT
	public function fill(Color:Int = FlxColor.TRANSPARENT):Void
	{
		pixels.fillRect(_flashRect, Color);
	}
	
	/**
	 * Just stamps this buffer onto the specified camera at the specified location.
	 * 
	 * @param	Camera		Which camera to draw the buffer onto.
	 * @param	FlashPoint	Where to draw the buffer at in camera coordinates.
	 */
	public function draw(Camera:FlxCamera, FlashPoint:Point, ScaleX:Float = 1.0, ScaleY:Float = 1.0):Void
	{
		if (pixelPerfectRender)
		{
			FlashPoint.x = Math.floor(FlashPoint.x);
			FlashPoint.y = Math.floor(FlashPoint.y);
		}
		
		if (pixelPerfectRender && (ScaleX == 1.0 && ScaleY == 1.0))
		{
			Camera.buffer.copyPixels(pixels, _flashRect, FlashPoint, null, null, true);
		}
		else
		{
			_matrix.identity();
			_matrix.scale(ScaleX, ScaleY);
			_matrix.translate(FlashPoint.x, FlashPoint.y);
			Camera.buffer.draw(pixels, _matrix);
		}
	}
	#end
	
	public function updateColumns(TileWidth:Int, WidthInTiles:Int, ScaleX:Float = 1.0, ?Camera:FlxCamera):Void
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
	
	public function updateRows(TileHeight:Int, HeightInTiles:Int, ScaleY:Float = 1.0, ?Camera:FlxCamera):Void
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