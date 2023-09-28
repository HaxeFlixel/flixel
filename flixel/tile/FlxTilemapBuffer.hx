package flixel.tile;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
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
	 * @param   tileWidth      The width of the tiles in this tilemap.
	 * @param   tileHeight     The height of the tiles in this tilemap.
	 * @param   widthInTiles   How many tiles wide the tilemap is.
	 * @param   heightInTiles  How many tiles tall the tilemap is.
	 * @param   camera         Which camera this buffer relates to.
	 */
	public function new(tileWidth, tileHeight, widthInTiles, heightInTiles, ?camera, scaleX = 1.0, scaleY = 1.0)
	{
		resize(tileWidth, tileHeight, widthInTiles, heightInTiles, camera, scaleX, scaleY);
	}
	
	/**
	 * Creates a bitmapData buffer from the tilemap's info.
	 *
	 * @param   tileWidth      The width of the tiles in this tilemap.
	 * @param   tileHeight     The height of the tiles in this tilemap.
	 * @param   widthInTiles   How many tiles wide the tilemap is.
	 * @param   heightInTiles  How many tiles tall the tilemap is.
	 * @param   camera         Which camera this buffer relates to.
	 */
	public function resize(tileWidth:Int, tileHeight:Int, widthInTiles:Int, heightInTiles:Int, ?camera:FlxCamera,
			scaleX = 1.0, scaleY = 1.0):Void
	{
		updateColumns(tileWidth, widthInTiles, scaleX, camera);
		updateRows(tileHeight, heightInTiles, scaleY, camera);

		if (FlxG.renderBlit)
		{
			final newWidth = Std.int(columns * tileWidth);
			final newHeight = Std.int(rows * tileHeight);
			
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
	 * @param   color  What color to fill with, in 0xAARRGGBB hex format.
	 */
	public function fill(color = FlxColor.TRANSPARENT):Void
	{
		if (FlxG.renderBlit)
		{
			pixels.fillRect(_flashRect, color);
		}
	}
	
	/**
	 * Just stamps this buffer onto the specified camera at the specified location.
	 *
	 * @param   camera      Which camera to draw the buffer onto.
	 * @param   flashPoint  Where to draw the buffer at in camera coordinates.
	 */
	public function draw(camera:FlxCamera, flashPoint:Point, scaleX = 1.0, scaleY = 1.0):Void
	{
		if (isPixelPerfectRender(camera))
		{
			flashPoint.x = Math.floor(flashPoint.x);
			flashPoint.y = Math.floor(flashPoint.y);
		}
		
		if (isPixelPerfectRender(camera) && (scaleX == 1.0 && scaleY == 1.0) && blend == null)
		{
			camera.copyPixels(pixels, _flashRect, flashPoint, null, null, true);
		}
		else
		{
			_matrix.identity();
			_matrix.scale(scaleX, scaleY);
			_matrix.translate(flashPoint.x, flashPoint.y);
			camera.drawPixels(pixels, _matrix, null, blend, antialiasing);
		}
	}
	
	public function colorTransform(transform:ColorTransform):Void
	{
		pixels.colorTransform(_flashRect, transform);
	}
	
	@:access(flixel.FlxCamera.viewWidth)
	public function updateColumns(tileWidth:Int, widthInTiles:Int, scaleX = 1.0, ?camera:FlxCamera):Void
	{
		if (widthInTiles < 0)
			widthInTiles = 0;
		
		if (camera == null)
			camera = FlxG.camera;
		
		columns = Math.ceil(camera.viewWidth / (tileWidth * scaleX)) + 1;
		
		if (columns > widthInTiles)
			columns = widthInTiles;
		
		width = Std.int(columns * tileWidth * scaleX);
		
		dirty = true;
	}
	
	@:access(flixel.FlxCamera.viewHeight)
	public function updateRows(tileHeight:Int, heightInTiles:Int, scaleY = 1.0, ?camera:FlxCamera):Void
	{
		if (heightInTiles < 0)
			heightInTiles = 0;
		
		if (camera == null)
			camera = FlxG.camera;
		
		rows = Math.ceil(camera.viewHeight / (tileHeight * scaleY)) + 1;
		
		if (rows > heightInTiles)
			rows = heightInTiles;
		
		height = Std.int(rows * tileHeight * scaleY);
		
		dirty = true;
	}
	
	/**
	 * Check if object is rendered pixel perfect on a specific camera.
	 */
	public function isPixelPerfectRender(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = FlxG.camera;
		
		return pixelPerfectRender == null ? camera.pixelPerfectRender : pixelPerfectRender;
	}
	
	/**
	 * Check if tilemap or camera has changed (scrolled, moved, resized or scaled) since the previous frame.
	 * If so, then it means that we need to redraw this buffer.
	 * @param   tilemap  Tilemap to check against. It's a tilemap this buffer belongs to.
	 * @param   camera   Camera to check against. It's a camera this buffer is used for drawing on.
	 * @return  The value of dirty flag.
	 */
	public function isDirty<Tile:FlxTile>(tilemap:FlxTypedTilemap<Tile>, camera:FlxCamera):Bool
	{
		dirty = dirty
			|| (tilemap.x != _prevTilemapX)
			|| (tilemap.y != _prevTilemapY)
			|| (tilemap.scale.x != _prevTilemapScaleX)
			|| (tilemap.scale.y != _prevTilemapScaleY)
			|| (tilemap.scrollFactor.x != _prevTilemapScrollX)
			|| (tilemap.scrollFactor.y != _prevTilemapScrollY)
			|| (camera.scroll.x != _prevCameraScrollX)
			|| (camera.scroll.y != _prevCameraScrollY)
			|| (camera.scaleX != _prevCameraScaleX)
			|| (camera.scaleY != _prevCameraScaleY)
			|| (camera.width != _prevCameraWidth)
			|| (camera.height != _prevCameraHeight);
		
		if (dirty)
		{
			_prevTilemapX = tilemap.x;
			_prevTilemapY = tilemap.y;
			_prevTilemapScaleX = tilemap.scale.x;
			_prevTilemapScaleY = tilemap.scale.y;
			_prevTilemapScrollX = tilemap.scrollFactor.x;
			_prevTilemapScrollY = tilemap.scrollFactor.y;
			_prevCameraScrollX = camera.scroll.x;
			_prevCameraScrollY = camera.scroll.y;
			_prevCameraScaleX = camera.scaleX;
			_prevCameraScaleY = camera.scaleY;
			_prevCameraWidth = camera.width;
			_prevCameraHeight = camera.height;
		}
		
		return dirty;
	}
}
