package flixel.tile;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;

/**
 * A helper object to keep tilemap drawing performance decent across the new multi-camera system.
 * Pretty much don't even have to think about this class unless you are doing some crazy hacking.
 */
class FlxTilemapBuffer implements IFlxDestroyable
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
	public var pixelPerfectRender:Null<Bool>;

	/**
	 * The actual buffer BitmapData. (Only used if FlxG.renderBlit == true)
	 */
	public var pixels(default, null):BitmapData;

	public var blend:BlendMode;
	public var antialiasing:Bool = false;

	var _flashRect:Rectangle;
	var _matrix:FlxMatrix;

	/**
	 * Variables related to calculation of dirty value
	 */
	var _prevTilemapX:Float;

	var _prevTilemapY:Float;
	var _prevTilemapScaleX:Float;
	var _prevTilemapScaleY:Float;
	var _prevTilemapScrollX:Float;
	var _prevTilemapScrollY:Float;
	var _prevCameraScrollX:Float;
	var _prevCameraScrollY:Float;
	var _prevCameraScaleX:Float;
	var _prevCameraScaleY:Float;
	var _prevCameraWidth:Int;
	var _prevCameraHeight:Int;

	/**
	 * Instantiates a new camera-specific buffer for storing the visual tilemap data.
	 *
	 * @param   TileWidth       The width of the tiles in this tilemap.
	 * @param   TileHeight      The height of the tiles in this tilemap.
	 * @param   WidthInTiles    How many tiles wide the tilemap is.
	 * @param   HeightInTiles   How many tiles tall the tilemap is.
	 * @param   Camera          Which camera this buffer relates to.
	 */
	public function new(TileWidth:Int, TileHeight:Int, WidthInTiles:Int, HeightInTiles:Int, ?Camera:FlxCamera, ScaleX:Float = 1.0, ScaleY:Float = 1.0)
	{
		resize(TileWidth, TileHeight, WidthInTiles, HeightInTiles, Camera, ScaleX, ScaleY);
	}

	public function resize(TileWidth:Int, TileHeight:Int, WidthInTiles:Int, HeightInTiles:Int, ?Camera:FlxCamera, ScaleX:Float = 1.0, ScaleY:Float = 1.0):Void
	{
		updateColumns(TileWidth, WidthInTiles, ScaleX, Camera);
		updateRows(TileHeight, HeightInTiles, ScaleY, Camera);

		if (FlxG.renderBlit)
		{
			var newWidth:Int = Std.int(columns * TileWidth);
			var newHeight:Int = Std.int(rows * TileHeight);

			if (pixels == null)
			{
				pixels = new BitmapData(newWidth, newHeight, true, 0);
				_flashRect = new Rectangle(0, 0, newWidth, newHeight);
				_matrix = new FlxMatrix();
				dirty = true;
			}
			else if (pixels.width != newWidth || pixels.height != newHeight)
			{
				FlxDestroyUtil.dispose(pixels);
				pixels = new BitmapData(newWidth, newHeight, true, 0);
				_flashRect.setTo(0, 0, newWidth, newHeight);
				dirty = true;
			}
		}
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		if (FlxG.renderBlit)
		{
			pixels = FlxDestroyUtil.dispose(pixels);
			blend = null;
			_matrix = null;
			_flashRect = null;
		}
	}

	/**
	 * Fill the buffer with the specified color.
	 * Default value is transparent.
	 *
	 * @param	Color	What color to fill with, in 0xAARRGGBB hex format.
	 */
	public function fill(Color:FlxColor = FlxColor.TRANSPARENT):Void
	{
		if (FlxG.renderBlit)
		{
			pixels.fillRect(_flashRect, Color);
		}
	}

	/**
	 * Just stamps this buffer onto the specified camera at the specified location.
	 *
	 * @param	Camera		Which camera to draw the buffer onto.
	 * @param	FlashPoint	Where to draw the buffer at in camera coordinates.
	 */
	public function draw(Camera:FlxCamera, FlashPoint:Point, ScaleX:Float = 1.0, ScaleY:Float = 1.0):Void
	{
		if (isPixelPerfectRender(Camera))
		{
			FlashPoint.x = Math.floor(FlashPoint.x);
			FlashPoint.y = Math.floor(FlashPoint.y);
		}

		if (isPixelPerfectRender(Camera) && (ScaleX == 1.0 && ScaleY == 1.0) && blend == null)
		{
			Camera.copyPixels(pixels, _flashRect, FlashPoint, null, null, true);
		}
		else
		{
			_matrix.identity();
			_matrix.scale(ScaleX, ScaleY);
			_matrix.translate(FlashPoint.x, FlashPoint.y);
			Camera.drawPixels(pixels, _matrix, null, blend, antialiasing);
		}
	}

	public function colorTransform(Transform:ColorTransform):Void
	{
		pixels.colorTransform(_flashRect, Transform);
	}

	@:access(flixel.FlxCamera.viewWidth)
	public function updateColumns(TileWidth:Int, WidthInTiles:Int, ScaleX:Float = 1.0, ?Camera:FlxCamera):Void
	{
		if (WidthInTiles < 0)
			WidthInTiles = 0;

		if (Camera == null)
			Camera = FlxG.camera;

		columns = Math.ceil(Camera.viewWidth / (TileWidth * ScaleX)) + 1;

		if (columns > WidthInTiles)
			columns = WidthInTiles;

		width = Std.int(columns * TileWidth * ScaleX);

		dirty = true;
	}

	@:access(flixel.FlxCamera.viewHeight)
	public function updateRows(TileHeight:Int, HeightInTiles:Int, ScaleY:Float = 1.0, ?Camera:FlxCamera):Void
	{
		if (HeightInTiles < 0)
			HeightInTiles = 0;

		if (Camera == null)
			Camera = FlxG.camera;

		rows = Math.ceil(Camera.viewHeight / (TileHeight * ScaleY)) + 1;

		if (rows > HeightInTiles)
			rows = HeightInTiles;

		height = Std.int(rows * TileHeight * ScaleY);

		dirty = true;
	}

	/**
	 * Check if object is rendered pixel perfect on a specific camera.
	 */
	public function isPixelPerfectRender(?Camera:FlxCamera):Bool
	{
		if (Camera == null)
			Camera = FlxG.camera;

		return pixelPerfectRender == null ? Camera.pixelPerfectRender : pixelPerfectRender;
	}

	/**
	 * Check if tilemap or camera has changed (scrolled, moved, resized or scaled) since the previous frame.
	 * If so, then it means that we need to redraw this buffer.
	 * @param	Tilemap	Tilemap to check against. It's a tilemap this buffer belongs to.
	 * @param	Camera	Camera to check against. It's a camera this buffer is used for drawing on.
	 * @return	The value of dirty flag.
	 */
	public function isDirty(Tilemap:FlxTilemap, Camera:FlxCamera):Bool
	{
		dirty = dirty
			|| (Tilemap.x != _prevTilemapX)
			|| (Tilemap.y != _prevTilemapY)
			|| (Tilemap.scale.x != _prevTilemapScaleX)
			|| (Tilemap.scale.y != _prevTilemapScaleY)
			|| (Tilemap.scrollFactor.x != _prevTilemapScrollX)
			|| (Tilemap.scrollFactor.y != _prevTilemapScrollY)
			|| (Camera.scroll.x != _prevCameraScrollX)
			|| (Camera.scroll.y != _prevCameraScrollY)
			|| (Camera.scaleX != _prevCameraScaleX)
			|| (Camera.scaleY != _prevCameraScaleY)
			|| (Camera.width != _prevCameraWidth)
			|| (Camera.height != _prevCameraHeight);

		if (dirty)
		{
			_prevTilemapX = Tilemap.x;
			_prevTilemapY = Tilemap.y;
			_prevTilemapScaleX = Tilemap.scale.x;
			_prevTilemapScaleY = Tilemap.scale.y;
			_prevTilemapScrollX = Tilemap.scrollFactor.x;
			_prevTilemapScrollY = Tilemap.scrollFactor.y;
			_prevCameraScrollX = Camera.scroll.x;
			_prevCameraScrollY = Camera.scroll.y;
			_prevCameraScaleX = Camera.scaleX;
			_prevCameraScaleY = Camera.scaleY;
			_prevCameraWidth = Camera.width;
			_prevCameraHeight = Camera.height;
		}

		return dirty;
	}
}
