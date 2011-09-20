/**
* RainbowLineFX - A Special FX Plugin
* -- Part of the Flixel Power Tools set
* 
* v1.0 Built into the new FlxSpecialFX system
* 
* @version 1.0 - May 9th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
* @see Requires FlxGradient, FlxMath
*/

package org.flixel.plugin.photonstorm.fx;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxColor;
import org.flixel.plugin.photonstorm.FlxGradient;
import org.flixel.plugin.photonstorm.FlxMath;


/**
 * Creates a Rainbow Line Effect - typically a rainbow sequence of color values passing through a 1px high line
 */
class RainbowLineFX extends BaseFX
{
	#if flash
	private var lineColors:Array<UInt>;
	private var maxColor:UInt;
	private var currentColor:UInt;
	private var speed:UInt;
	private var chunk:UInt;
	private var direction:UInt;
	#else
	private var lineColors:Array<Int>;
	private var maxColor:Int;
	private var currentColor:Int;
	private var speed:Int;
	private var chunk:Int;
	private var direction:Int;
	#end
	private var fillRect:Rectangle;
	private var setPixel:Bool;
	
	public function new() 
	{
		super();
	}
	
	/**
	 * Creates a Color Line FlxSprite.
	 * 
	 * @param	x			The x coordinate of the FlxSprite in game world pixels
	 * @param	y			The y coordinate of the FlxSprite in game world pixels
	 * @param	width		The width of the FlxSprite in pixels
	 * @param	height		The height of the FlxSprite in pixels
	 * @param	colors		An Array of color values used to create the line. If null (default) the HSV Color Wheel is used, giving a full spectrum rainbow effect
	 * @param	colorWidth	The width of the color range controls how much interpolation occurs between each color in the colors array (default 360)
	 * @param	colorSpeed	The speed at which the Rainbow Line cycles through its colors (default 1)
	 * @param	stepSize	The size of each "chunk" of the Rainbow Line - use a higher value for a more retro look (default 1)
	 * @param	fadeWidth	If you want the Line to fade from fadeColor to the first color in the colors array, and then out again, set this value to the amount of transition you want (128 looks good)
	 * @param	fadeColor	The default fade color is black, but if you need to alpha it, or change for a different color, set it here
	 * 
	 * @return	An FlxSprite which automatically updates each draw() to cycle the colors through it
	 */
	#if flash
	public function create(x:Int, y:Int, width:UInt, ?height:UInt = 1, ?colors:Array<UInt> = null, ?colorWidth:UInt = 360, ?colorSpeed:UInt = 1, ?stepSize:UInt = 1, ?fadeWidth:UInt = 128, ?fadeColor:UInt = 0xff000000):FlxSprite
	#else
	public function create(x:Int, y:Int, width:UInt, ?height:UInt = 1, ?colors:Array<UInt> = null, ?colorWidth:UInt = 360, ?colorSpeed:UInt = 1, ?stepSize:UInt = 1, ?fadeWidth:UInt = 128, ?fadeColor:UInt = 0xff000000):FlxSprite
	#end
	{
		sprite = new FlxSprite(x, y).makeGraphic(width, height, 0x0);
		
		canvas = new BitmapData(width, height, true, 0x0);
		
		if (colors != null)
		{
			lineColors = FlxGradient.createGradientArray(1, colorWidth, colors);
		}
		else
		{
			lineColors = FlxColor.getHSVColorWheel();
		}
		
		currentColor = 0;
		maxColor = lineColors.length - 1;
		
		if (fadeWidth != 0)
		{
			#if flash
			var blackToFirst:Array<UInt> = FlxGradient.createGradientArray(1, fadeWidth, [ fadeColor, fadeColor, fadeColor, lineColors[0] ]);
			var lastToBlack:Array<UInt> = FlxGradient.createGradientArray(1, fadeWidth, [ lineColors[maxColor], fadeColor, fadeColor, fadeColor, fadeColor ]);
			
			var fadingColours:Array<UInt> = blackToFirst.concat(lineColors);
			#else
			var blackToFirst:Array<Int> = FlxGradient.createGradientArray(1, fadeWidth, [ fadeColor, fadeColor, fadeColor, lineColors[0] ]);
			var lastToBlack:Array<Int> = FlxGradient.createGradientArray(1, fadeWidth, [ lineColors[maxColor], fadeColor, fadeColor, fadeColor, fadeColor ]);
			
			var fadingColours:Array<Int> = blackToFirst.concat(lineColors);
			#end
			
			fadingColours = fadingColours.concat(lastToBlack);
			
			lineColors = fadingColours;
		
			maxColor = lineColors.length - 1;
		}
		
		direction = 0;
		setPixel = false;
		speed = colorSpeed;
		chunk = stepSize;
		fillRect = new Rectangle(0, 0, chunk, height);
		
		if (height == 1 && chunk == 1)
		{
			setPixel = true;
		}
		
		active = true;
		
		return sprite;
	}
	
	/**
	 * Change the colors cycling through the line by passing in a new array of color values
	 * 
	 * @param	colors				An Array of color values used to create the line. If null (default) the HSV Color Wheel is used, giving a full spectrum rainbow effect
	 * @param	colorWidth			The width of the color range controls how much interpolation occurs between each color in the colors array (default 360)
	 * @param	resetCurrentColor	If true the color pointer is returned to the start of the new color array, otherwise remains where it is
	 * @param	fadeWidth			If you want the Rainbow Line to fade from black to the first color in the colors array, and then out again, set this value to the amount of transition you want (128 looks good)
	 * @param	fadeColor			The default fade color is black, but if you need to alpha it, or change for a different color, set it here
	 */
	#if flash
	public function updateColors(colors:Array<UInt>, ?colorWidth:UInt = 360, ?resetCurrentColor:Bool = false, ?fadeWidth:UInt = 128, ?fadeColor:UInt = 0xff000000):Void
	#else
	public function updateColors(colors:Array<Int>, ?colorWidth:Int = 360, ?resetCurrentColor:Bool = false, ?fadeWidth:Int = 128, ?fadeColor:Int = 0xff000000):Void
	#end
	{
		if (colors != null)
		{
			lineColors = FlxGradient.createGradientArray(1, colorWidth, colors);
		}
		else
		{
			lineColors = FlxColor.getHSVColorWheel();
		}
		
		maxColor = lineColors.length - 1;
		
		if (fadeWidth != 0)
		{
			#if flash
			var blackToFirst:Array<UInt> = FlxGradient.createGradientArray(1, fadeWidth, [ 0xff000000, 0xff000000, 0xff000000, lineColors[0] ]);
			var lastToBlack:Array<UInt> = FlxGradient.createGradientArray(1, fadeWidth, [ lineColors[maxColor], 0xff000000, 0xff000000, 0xff000000, 0xff000000 ]);
			
			var fadingColours:Array<UInt> = blackToFirst.concat(lineColors);
			#else
			var blackToFirst:Array<Int> = FlxGradient.createGradientArray(1, fadeWidth, [ 0xff000000, 0xff000000, 0xff000000, lineColors[0] ]);
			var lastToBlack:Array<Int> = FlxGradient.createGradientArray(1, fadeWidth, [ lineColors[maxColor], 0xff000000, 0xff000000, 0xff000000, 0xff000000 ]);
			
			var fadingColours:Array<Int> = blackToFirst.concat(lineColors);
			#end
			
			fadingColours = fadingColours.concat(lastToBlack);
			
			lineColors = fadingColours;
		
			maxColor = lineColors.length - 1;
		}
		
		if (currentColor > maxColor || resetCurrentColor)
		{
			currentColor = 0;
		}
	}
	
	/**
	 * Doesn't need to be called directly as it's called by the FlxSpecialFX Plugin.<br>
	 * Set active to false if you wish to disable the effect.<br>
	 * Pass the effect to FlxSpecialFX.erase() if you wish to destroy this effect.
	 */
	public function draw():Void
	{
		canvas.lock();
	
		fillRect.x = 0;
		
		var x:Int = 0;
		while (x < canvas.width)
		{
			var c:Int = FlxMath.wrapValue(currentColor + x, 1, maxColor);
			
			if (setPixel)
			{
				canvas.setPixel32(x, 0, lineColors[c]);
			}
			else
			{
				canvas.fillRect(fillRect, lineColors[c]);
				fillRect.x += chunk;
			}
			x = x + chunk;
		}
		
		canvas.unlock();
		
		if (direction == 0)
		{
			currentColor += speed;
			
			if (currentColor >= maxColor)
			{
				currentColor = 0;
			}
		}
		else
		{
			currentColor -= speed;
			
			if (currentColor < 0)
			{
				currentColor = maxColor;
			}
		}
		
		sprite.pixels = canvas;
		sprite.dirty = true;
	}
	
	#if flash
	public var colorSpeed(getColorSpeed, setColorSpeed):UInt;
	#else
	public var colorSpeed(getColorSpeed, setColorSpeed):Int;
	#end
	
	/**
	 * Set the speed at which the Line cycles through its colors
	 */
	#if flash
	public function setColorSpeed(value:UInt):UInt 
	#else
	public function setColorSpeed(value:Int):Int 
	#end
	{
		if (value < maxColor)
		{
			speed = value;
		}
		return value;
	}
	
	/**
	 * The speed at which the Line cycles through its colors
	 */
	#if flash
	public function getColorSpeed():UInt
	#else
	public function getColorSpeed():Int
	#end
	{
		return speed;
	}
	
	#if flash
	public var stepSize(getStepSize, setStepSize):UInt;
	#else
	public var stepSize(getStepSize, setStepSize):Int;
	#end
	
	/**
	 * Set the size of each "chunk" of the Line. Use a higher value for a more retro look
	 */
	#if flash
	public function setStepSize(value:UInt):UInt 
	#else
	public function setStepSize(value:Int):Int 
	#end
	{
		if (Std.int(value) < canvas.width && value > 0)
		{
			canvas.fillRect(new Rectangle(0, 0, canvas.width, canvas.height), 0x0);
			chunk = value;
			
			fillRect.x = 0;
			fillRect.width = chunk;
			
			if (value > 1)
			{
				setPixel = false;
			}
			else
			{
				setPixel = true;
			}
		}
		return value;
	}
	
	/**
	 * The size of each "chunk" of the Line
	 */
	#if flash
	public function getStepSize():UInt
	#else
	public function getStepSize():Int
	#end
	{
		return chunk;
	}
	
	/**
	 * Changes the color cycle direction.
	 * 
	 * @param	newDirection	0 = Colors cycle incrementally (line looks like it is moving to the left), 1 = Colors decrement (line moves to the right)
	 */
	#if flash
	public function setDirection(newDirection:UInt):Void
	#else
	public function setDirection(newDirection:Int):Void
	#end
	{
		if (newDirection == 0 || newDirection == 1)
		{
			direction = newDirection;
		}
	}
	
}