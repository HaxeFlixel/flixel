/**
* StarfieldFX - Special FX Plugin
* -- Part of the Flixel Power Tools set
* 
* v1.1 StarField moved to the FX Plugin system
* v1.0 First release
* 
* @version 1.1 - May 21st 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.fx;

import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;

import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxGradient;

/**
 * Creates a 2D or 3D Star Field effect on an FlxSprite for use in your game.
 */
class StarfieldFX extends BaseFX
{
	/**
	 * In a 3D starfield this controls the X coordinate the stars emit from, can be updated in real-time!
	 */
	public var centerX:Int;
	
	/**
	 * In a 3D starfield this controls the Y coordinate the stars emit from, can be updated in real-time!
	 */
	public var centerY:Int;
	
	/**
	 * How much to shift on the X axis every update. Negative values move towards the left, positiive to the right. 2D Starfield only. Can also be set via setStarSpeed()
	 */
	public var starXOffset:Float;
	
	/**
	 * How much to shift on the Y axis every update. Negative values move up, positiive values move down. 2D Starfield only. Can also be set via setStarSpeed()
	 */
	public var starYOffset:Float;
	
	private var stars:Array<StarObject>;
	private var starfieldType:Int;
	
	#if flash
	private var backgroundColor:UInt;
	#else
	private var backgroundColor:BitmapInt32;
	#end
	
	private var updateSpeed:Int;
	private var tick:Int;
	
	#if flash
	private var depthColours:Array<UInt>;
	#else
	private var depthColours:Array<BitmapInt32>;
	#end
	
	public static inline var STARFIELD_TYPE_2D:Int = 1;
	public static inline var STARFIELD_TYPE_3D:Int = 2;
	
	public function new() 
	{
		starXOffset = -1;
		starYOffset = 0;
		#if !neko
		backgroundColor = 0xff000000;
		#else
		backgroundColor = {rgd: 0x000000, a: 0xff};
		#end
		
		super();
	}
	
	/**
	 * Create a new StarField
	 * 
	 * @param	x				X coordinate of the starfield sprite
	 * @param	y				Y coordinate of the starfield sprite
	 * @param	width			The width of the starfield
	 * @param	height			The height of the starfield
	 * @param	quantity		The number of stars in the starfield (default 200)
	 * @param	type			Type of starfield. Either STARFIELD_TYPE_2D (default, stars move horizontally) or STARFIELD_TYPE_3D (stars flow out from the center)
	 * @param	updateInterval	How many ms should pass before the next starfield update (default 20)
	 */
	public function create(x:Int, y:Int, width:Int, height:Int, ?quantity:Int = 200, ?type:Int = 1, ?updateInterval:Int = 20):FlxSprite
	{
		sprite = new FlxSprite(x, y).makeGraphic(width, height, backgroundColor);
		canvas = new BitmapData(Math.floor(sprite.width), Math.floor(sprite.height), true, backgroundColor);
		starfieldType = type;
		updateSpeed = speed;
		
		//	Stars come from the middle of the starfield in 3D mode
		centerX = width >> 1;
		centerY = height >> 1;
		
		clsRect = new Rectangle(0, 0, width, height);
		clsPoint = new Point();
		clsColor = backgroundColor;
		
		stars = new Array<StarObject>();
		
		for (i in 0...(quantity))
		{
			var star:StarObject = new StarObject();
			
			star.index = i;
			star.x = Std.int(Math.random() * width);
			star.y = Std.int(Math.random() * height);
			star.d = 1;
			
			if (type == STARFIELD_TYPE_2D)
			{
				star.speed = 1 + Std.int(Math.random() * 5);
			}
			else
			{
				star.speed = Math.random();
			}
			
			star.r = Math.random() * Math.PI * 2;
			star.alpha = 0;
			
			stars.push(star);
		}
		
		//	Colours array
		if (type == STARFIELD_TYPE_2D)
		{
			#if !neko
			depthColours = FlxGradient.createGradientArray(1, 5, [0xff585858, 0xffF4F4F4]);
			#else
			depthColours = FlxGradient.createGradientArray(1, 5, [{rgb: 0x585858, a: 0xff}, {rgb: 0xF4F4F4, a: 0xff}]);
			#end
		}
		else
		{
			#if !neko
			depthColours = FlxGradient.createGradientArray(1, 300, [0xff292929, 0xffffffff]);
			#else
			depthColours = FlxGradient.createGradientArray(1, 300, [{rgb: 0x292929, a: 0xff}, {rgb: 0xffffff, a: 0xff}]);
			#end
		}
		
		active = true;
		return sprite;
	}
	
	/**
	 * Change the background color in the format 0xAARRGGBB of the starfield.<br />
	 * Supports alpha, so if you want a transparent background just pass 0x00 as the color.
	 * 
	 * @param	backgroundColor
	 */
	#if flash
	public function setBackgroundColor(backgroundColor:UInt):Void
	#else
	public function setBackgroundColor(backgroundColor:BitmapInt32):Void
	#end
	{
		clsColor = backgroundColor;
	}
	
	/**
	 * Change the number of layers (depth) and colors used for each layer of the starfield. Change happens immediately.
	 * 
	 * @param	depth			Number of depths (for a 2D starfield the default is 5)
	 * @param	lowestColor		The color given to the stars furthest away from the camera (i.e. the slowest stars), typically the darker colour
	 * @param	highestColor	The color given to the stars cloest to the camera (i.e. the fastest stars), typically the brighter colour
	 */
	#if flash
	public function setStarDepthColors(depth:Int, ?lowestColor:UInt = 0xff585858, ?highestColor:UInt = 0xffF4F4F4):Void
	#else
	public function setStarDepthColors(depth:Int, ?lowestColor:BitmapInt32 = null, ?highestColor:BitmapInt32 = null):Void
	#end
	{
		#if (cpp || neko)
		if (lowestColor == null)
		{
			#if cpp
			lowestColor = 0xff585858;
			#else
			lowestColor = {rgb: 0x585858, a: 0xff};
			#end
		}
		
		if (highestColor == null)
		{
			#if cpp
			highestColor = 0xffF4F4F4;
			#else
			highestColor = {rgb: 0xF4F4F4, a: 0xff};
			#end
		}
		#end
		
		//	Depth is the same, we just need to update the gradient then
		depthColours = FlxGradient.createGradientArray(1, depth, [lowestColor, highestColor]);
		
		//	Run through the stars array, making sure the depths are all within range
		for (star in stars)
		{
			star.speed = 1 + Std.int(Math.random() * depth);
		}
	}
	
	/**
	 * Sets the direction and speed of the 2D starfield (doesn't apply to 3D)<br />
	 * You can combine both X and Y together to make the stars move on a diagnol
	 * 
	 * @param	xShift	How much to shift on the X axis every update. Negative values move towards the left, positiive to the right
	 * @param	yShift	How much to shift on the Y axis every update. Negative values move up, positiive values move down
	 */
	public function setStarSpeed(xShift:Float, yShift:Float):Void
	{
		starXOffset = xShift;
		starYOffset = yShift;
	}
	
	public var speed(getSpeed, setSpeed):Int;
	
	/**
	 * The current update speed
	 */
	public function getSpeed():Int
	{
		return updateSpeed;
	}
	
	/**
	 * Change the tick interval on which the update runs. By default the starfield updates once every 20ms. Set to zero to disable totally.
	 */
	public function setSpeed(newSpeed:Int):Int
	{
		updateSpeed = newSpeed;
		return newSpeed;
	}
	
	private function update2DStarfield():Void
	{
		for (star in stars)
		{
			star.x += (starXOffset * star.speed);
			star.y += (starYOffset * star.speed);
			
			canvas.setPixel32(star.x, star.y, depthColours[Math.floor(star.speed - 1)]);
			
			if (star.x > sprite.width)
			{
				star.x = 0;
			}
			else if (star.x < 0)
			{
				star.x = sprite.width;
			}
			
			if (star.y > sprite.height)
			{
				star.y = 0;
			}
			else if (star.y < 0)
			{
				star.y = sprite.height;
			}
		}
	}
	
	private function update3DStarfield():Void
	{
		for (star in stars)
		{
			star.d *= 1.1;
			star.x = centerX + ((Math.cos(star.r) * star.d) * star.speed);
			star.y = centerY + ((Math.sin(star.r) * star.d) * star.speed);
			
			star.alpha = star.d * 2;
			
			if (star.alpha > 255)
			{
				star.alpha = 255;
			}
			
			#if !neko
			canvas.setPixel32(star.x, star.y, 0xffffffff);
			#else
			canvas.setPixel32(star.x, star.y, {rgb: 0xffffff, a: 0xff});
			#end
			//canvas.setPixel32(star.x, star.y, FlxColor.getColor32(255, star.alpha, star.alpha, star.alpha));
			
			if (star.x < 0 || star.x > sprite.width || star.y < 0 || star.y > sprite.height)
			{
				star.d = 1;
				star.r = Math.random() * Math.PI * 2;
				star.x = 0;
				star.y = 0;
				star.speed = Math.random();
				star.alpha = 0;
				
				stars[star.index] = star;
			}
		}
	}
	
	override public function draw():Void
	{
		if (Lib.getTimer() > tick)
		{
			canvas.lock();
			canvas.fillRect(clsRect, clsColor);
			
			if (starfieldType == STARFIELD_TYPE_2D)
			{
				update2DStarfield();
			}
			else
			{
				update3DStarfield();
			}
			
			canvas.unlock();
			
			sprite.pixels = canvas;
			
			if (updateSpeed > 0)
			{
				tick = Lib.getTimer() + updateSpeed;
			}
		}
	}
	
}

class StarObject
{
	public var index:Int;
	public var x:Int;
	public var y:Int;
	public var d:Float;
	public var speed:Float;
	public var r:Float;
	public var alpha:Float;
	
	public function new()
	{
		
	}
}