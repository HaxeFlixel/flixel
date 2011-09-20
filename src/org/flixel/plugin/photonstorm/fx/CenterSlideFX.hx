/**
* CenterSlideFX - Special FX Plugin
* -- Part of the Flixel Power Tools set
* 
* v1.1 Refactored main loop a little and added reverse function
* v1.0 First release
* 
* @version 1.1 - June 13th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.fx;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.flixel.FlxSprite;

/**
 * Makes an image expand or collapse from its center
 */
class CenterSlideFX extends BaseFX
{
	/**
	 * True when the effect has completed. False while the effect is running.
	 */
	public var complete:Bool;
	
	/**
	 * A function that is called once the effect is has finished running and is complete
	 */
	public var completeCallback:Dynamic;
	
	#if flash
	private var pixels:UInt;
	private var direction:UInt;
	#else
	private var pixels:Int;
	private var direction:Int;
	#end
	
	private var sideA:Rectangle;
	private var sideB:Rectangle;
	private var pointA:Point;
	private var pointB:Point;
	
	#if flash
	public static inline var REVEAL_VERTICAL:UInt = 0;
	public static inline var REVEAL_HORIZONTAL:UInt = 1;
	public static inline var HIDE_VERTICAL:UInt = 2;
	public static inline var HIDE_HORIZONTAL:UInt = 3;
	#else
	public static inline var REVEAL_VERTICAL:Int = 0;
	public static inline var REVEAL_HORIZONTAL:Int = 1;
	public static inline var HIDE_VERTICAL:Int = 2;
	public static inline var HIDE_HORIZONTAL:Int = 3;
	#end
	
	public function new() 
	{
		super();
	}
	
	/**
	 * Creates a new CenterSlide effect from the given FlxSprite. The original sprite remains unmodified.<br>
	 * The resulting FlxSprite will take on the same width / height and x/y coordinates of the source FlxSprite.
	 * 
	 * @param	source				The FlxSprite providing the image data for this effect. The resulting FlxSprite takes on the source width, height and x/y position.
	 * @param	direction			REVEAL_VERTICAL, REVEAL_HORIZONTAL, HIDE_VERTICAL or HIDE_HORIZONTAL
	 * @param	pixels				How many pixels to slide update (default 1)
	 * @param	backgroundColor		The background colour of the FlxSprite the effect is drawn in to (default 0x0 = transparent)
	 * 
	 * @return	An FlxSprite with the effect running through it, which should be started with a call to CenterSlideFX.start()
	 */
	#if flash
	public function createFromFlxSprite(source:FlxSprite, ?direction:UInt = 0, ?pixels:UInt = 1, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	public function createFromFlxSprite(source:FlxSprite, ?direction:Int = 0, ?pixels:Int = 1, ?backgroundColor:Int = 0x0):FlxSprite
	#end
	{
		return create(source.pixels, Math.floor(source.x), Math.floor(source.y), direction, pixels, backgroundColor);
	}
	
	/**
	 * Creates a new CenterSlide effect from the given Class (which must contain a Bitmap) usually from an Embedded bitmap.
	 * 
	 * @param	source				The Class providing the bitmapData for this effect, usually from an Embedded bitmap.
	 * @param	x					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
	 * @param	y					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
	 * @param	direction			REVEAL_VERTICAL, REVEAL_HORIZONTAL, HIDE_VERTICAL or HIDE_HORIZONTAL
	 * @param	pixels				How many pixels to slide update (default 1)
	 * @param	backgroundColor		The background colour of the FlxSprite the effect is drawn in to (default 0x0 = transparent)
	 * 
	 * @return	An FlxSprite with the effect running through it, which should be started with a call to CenterSlideFX.start()
	 */
	#if flash
	public function createFromClass(source:Class<Bitmap>, x:Int, y:Int, ?direction:UInt = 0, ?pixels:UInt = 1, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	public function createFromClass(source:Class<Bitmap>, x:Int, y:Int, ?direction:Int = 0, ?pixels:Int = 1, ?backgroundColor:Int = 0x0):FlxSprite
	#end
	{
		return create((Type.createInstance(source, [])).bitmapData, x, y, direction, pixels, backgroundColor);
	}
	
	/**
	 * Creates a new CenterSlide effect from the given bitmapData.
	 * 
	 * @param	source				The bitmapData image to use for this effect.
	 * @param	x					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
	 * @param	y					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
	 * @param	direction			REVEAL_VERTICAL, REVEAL_HORIZONTAL, HIDE_VERTICAL or HIDE_HORIZONTAL
	 * @param	pixels				How many pixels to slide update (default 1)
	 * @param	backgroundColor		The background colour of the FlxSprite the effect is drawn in to (default 0x0 = transparent)
	 * 
	 * @return	An FlxSprite with the effect running through it, which should be started with a call to CenterSlideFX.start()
	 */
	#if flash
	public function createFromBitmapData(source:BitmapData, x:Int, y:Int, ?direction:UInt = 0, ?pixels:UInt = 1, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	public function createFromBitmapData(source:BitmapData, x:Int, y:Int, ?direction:Int = 0, ?pixels:Int = 1, ?backgroundColor:Int = 0x0):FlxSprite
	#end
	{
		return create(source, x, y, direction, pixels, backgroundColor);
	}
	
	#if flash
	private function create(source:BitmapData, x:Int, y:Int, ?direction:UInt = 0, ?pixels:UInt = 1, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	private function create(source:BitmapData, x:Int, y:Int, ?direction:Int = 0, ?pixels:Int = 1, ?backgroundColor:Int = 0x0):FlxSprite
	#end
	{
		sprite = new FlxSprite(x, y).makeGraphic(source.width, source.height, backgroundColor);
		
		canvas = new BitmapData(source.width, source.height, true, backgroundColor);
		
		image = source.clone();
		
		clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
		clsColor = backgroundColor;
		
		this.direction = direction;
		this.pixels = pixels;
		
		var midway:Int = Std.int(source.height / 2);
		
		switch (direction)
		{
			case REVEAL_VERTICAL:
				sideA = new Rectangle(0, 0, source.width, pixels);
				sideB = new Rectangle(0, source.height - pixels, source.width, pixels);
				pointA = new Point(0, midway);
				pointB = new Point(0, midway);
				
			case REVEAL_HORIZONTAL:
				midway = Std.int(source.width / 2);
				sideA = new Rectangle(0, 0, pixels, source.height);
				sideB = new Rectangle(source.width - pixels, 0, pixels, source.height);
				pointA = new Point(midway, 0);
				pointB = new Point(midway, 0);
				
			case HIDE_VERTICAL:
				canvas = image.clone();
				sprite.pixels = canvas;
				sprite.dirty = true;
				sideA = new Rectangle(0, 0, source.width, midway);
				sideB = new Rectangle(0, midway, source.width, source.height - midway);
				pointA = new Point(0, 0);
				pointB = new Point(0, midway);
				
			case HIDE_HORIZONTAL:
				canvas = image.clone();
				sprite.pixels = canvas;
				sprite.dirty = true;
				midway = Std.int(source.width / 2);
				sideA = new Rectangle(0, 0, midway, source.height);
				sideB = new Rectangle(midway, 0, source.width - midway, source.height);
				pointA = new Point(0, 0);
				pointB = new Point(midway, 0);
		}
		
		active = true;
		complete = false;
		
		return sprite;
	}
	
	public function reverse():Void
	{
		if (direction == REVEAL_VERTICAL)
		{
			direction = HIDE_VERTICAL;
			complete = false;
		}
		else if (direction == REVEAL_HORIZONTAL)
		{
			direction = HIDE_HORIZONTAL;
			complete = false;
		}
	}
	
	public function draw():Void
	{
		if (ready && complete == false)
		{
			if (lastUpdate != updateLimit)
			{
				lastUpdate++;
				
				return;
			}
			
			canvas.fillRect(clsRect, clsColor);
			canvas.copyPixels(image, sideA, pointA, null, null, true);
			canvas.copyPixels(image, sideB, pointB, null, null, true);
			
			switch (direction)
			{
				case REVEAL_VERTICAL:
					sideA.height += pixels;
					pointA.y -= pixels;
					sideB.height += pixels;
					sideB.y -= pixels;
					
				case REVEAL_HORIZONTAL:
					sideA.width += pixels;
					pointA.x -= pixels;
					sideB.width += pixels;
					sideB.x -= pixels;
					
				case HIDE_VERTICAL:
					sideA.height -= pixels;
					pointA.y += pixels;
					sideB.height -= pixels;
					sideB.y += pixels;
					
				case HIDE_HORIZONTAL:
					sideA.width -= pixels;
					pointA.x += pixels;
					sideB.width -= pixels;
					sideB.x += pixels;
			}
			
			//	Are we finished?
			if ((direction == REVEAL_VERTICAL && pointA.y < 0) || (direction == REVEAL_HORIZONTAL && pointA.x < 0))
			{
				canvas = image.clone();
				complete = true;
			}
			else if ((direction == HIDE_VERTICAL && sideA.height <= 0) || (direction == HIDE_HORIZONTAL && sideA.width <= 0))
			{
				canvas.fillRect(clsRect, clsColor);
				complete = true;
			}
			
			lastUpdate = 0;
			
			sprite.pixels = canvas;
			sprite.dirty = true;
			
			if (complete && completeCallback != null)
			{
				completeCallback.call();
			}
		}
	}
	
}