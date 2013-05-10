package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.parallelogramRendering;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxU;

/**
 * A modified version of FlxTilemapBugger, to render parallelograms
 * 
 * @author	Adam Atomic(original) Miguel Ángel Piedras Carrillo(modified), Jimmy Delas (Haxe port)
 */
class ParallelTilemapBuffer
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
	public var rows:UInt;
	/**
	 * How many columns of tiles fit in this buffer.
	 */
	public var columns:UInt;

	private var _pixels:BitmapData;	
	private var _flashRect:Rectangle;

	/**
	 * Instantiates a new camera-specific buffer for storing the visual tilemap data.
	 *  
	 * @param TileWidth		The width of the tiles in this tilemap.
	 * @param TileHeight	The height of the tiles in this tilemap.
	 * @param WidthInTiles	How many tiles wide the tilemap is.
	 * @param HeightInTiles	How many tiles tall the tilemap is.
	 * @param Camera		Which camera this buffer relates to.
	 */
	public function new(TileWidth:Float,TileHeight:Float,WidthInTiles:UInt,HeightInTiles:UInt,Camera:FlxCamera=null,maxWidth:Float=0,maxHeight:Float=0)
	{						
		
		if(Camera == null)
			Camera = FlxG.camera;
		columns = FlxU.ceil(Camera.width/TileWidth)+1;
		if(columns > WidthInTiles)
			columns = WidthInTiles ;
		rows = FlxU.ceil(Camera.height/TileHeight)+1;
		if(rows > HeightInTiles)
			rows = HeightInTiles;
		
		_pixels = new BitmapData(
			Math.floor(maxWidth  >0 ?maxWidth : columns * TileWidth),
			Math.floor(maxHeight >0 ?maxHeight: rows    * TileHeight),true,0);
											
		width  = columns * TileWidth;
		height = rows    * TileHeight;
		
		_flashRect = new Rectangle(0,0,_pixels.width,_pixels.height);
		dirty = true;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_pixels = null;
	}
	
	/**
	 * Fill the buffer with the specified color.
	 * Default value is transparent.
	 * 
	 * @param	Color	What color to fill with, in 0xAARRGGBB hex format.
	 */
	public function fill(Color:UInt=0):Void
	{
		_pixels.fillRect(_flashRect,Color);
	}

	/**
	 * Read-only, nab the actual buffer <code>BitmapData</code> object.
	 * 
	 * @return	The buffer bitmap data.
	 */
	public var pixels(get_pixels, never) : BitmapData;
	public function get_pixels():BitmapData
	{
		return _pixels;
	}

	/**
	 * Just stamps this buffer onto the specified camera at the specified location.
	 * 
	 * @param	Camera		Which camera to draw the buffer onto.
	 * @param	FlashPoint	Where to draw the buffer at in camera coordinates.
	 */
	public function draw(Camera:FlxCamera,FlashPoint:Point):Void
	{
		Camera.buffer.copyPixels(_pixels,_flashRect,FlashPoint,null,null,true);
	}
}
