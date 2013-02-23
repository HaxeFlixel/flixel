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
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.plugin.photonstorm.FlxColor;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxGradient;
import org.flixel.system.layer.DrawStackItem;

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
		super();
		
		starXOffset = -1;
		starYOffset = 0;
		backgroundColor = FlxG.BLACK;
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
	public function create(x:Int, y:Int, width:Int, height:Int, quantity:Int = 200, type:Int = 1, updateInterval:Int = 20):FlxSprite
	{
		#if flash
		sprite = new FlxSprite(x, y).makeGraphic(width, height, backgroundColor);
		canvas = new BitmapData(Std.int(sprite.width), Std.int(sprite.height), true, backgroundColor);
		#else
		sprite = new StarSprite(x, y, width, height, backgroundColor);
		var starDefs:Array<StarDef> = cast(sprite, StarSprite).starData;
		#end
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
			
			#if !flash
			starDefs.push( { x: 0, y: 0, red: 0, green: 0, blue: 0, alpha: 0 } );
			#end
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
		
		#if !flash
		if (sprite != null)
		{
			cast(sprite, StarSprite).setBackgroundColor(backgroundColor);
		}
		#end
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
	public function setStarDepthColors(depth:Int, ?lowestColor:BitmapInt32, ?highestColor:BitmapInt32):Void
	#end
	{
		#if !flash
		if (lowestColor == null)
		{
			#if !neko
			lowestColor = 0xff585858;
			#else
			lowestColor = {rgb: 0x585858, a: 0xff};
			#end
		}
		
		if (highestColor == null)
		{
			#if !neko
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
	
	public var speed(get_speed, set_speed):Int;
	
	/**
	 * The current update speed
	 */
	private function get_speed():Int
	{
		return updateSpeed;
	}
	
	/**
	 * Change the tick interval on which the update runs. By default the starfield updates once every 20ms. Set to zero to disable totally.
	 */
	private function set_speed(newSpeed:Int):Int
	{
		updateSpeed = newSpeed;
		return newSpeed;
	}
	
	private function update2DStarfield():Void
	{
		#if !flash
		var starSprite:StarSprite = cast(sprite, StarSprite);
		var starArray:Array<StarDef> = starSprite.starData;
		#end
		
		var star:StarObject;
		
		for (i in 0...(stars.length))
		{
			star = stars[i];
			star.x += Math.floor(starXOffset * star.speed);
			star.y += Math.floor(starYOffset * star.speed);
			
			#if flash
			canvas.setPixel32(star.x, star.y, depthColours[Std.int(star.speed - 1)]);
			#else
			var starColor:BitmapInt32 = depthColours[Std.int(star.speed - 1)];
			var rgba:RGBA = FlxColor.getRGB(starColor);
			
			var starDef:StarDef = starArray[i];
			starDef.red = rgba.red / 255;
			starDef.green = rgba.green / 255;
			starDef.blue = rgba.blue / 255;
			starDef.alpha = rgba.alpha / 255;
			#end
			
			if (star.x > sprite.width)
			{
				star.x = 0;
			}
			else if (star.x < 0)
			{
				star.x = Std.int(sprite.width);
			}
			
			if (star.y > sprite.height)
			{
				star.y = 0;
			}
			else if (star.y < 0)
			{
				star.y = Std.int(sprite.height);
			}
			
			#if !flash
			starDef.x = star.x - starSprite.halfWidth;
			starDef.y = star.y - starSprite.halfHeight;
			#end
		}
	}
	
	private function update3DStarfield():Void
	{
		#if !flash
		var starSprite:StarSprite = cast(sprite, StarSprite);
		var starArray:Array<StarDef> = starSprite.starData;
		#end
		
		var star:StarObject;
		
		for (i in 0...(stars.length))
		{
			star = stars[i];
			star.d *= 1.1;
			star.x = Math.floor(centerX + ((Math.cos(star.r) * star.d) * star.speed));
			star.y = Math.floor(centerY + ((Math.sin(star.r) * star.d) * star.speed));
			
			star.alpha = star.d * 2;
			
			if (star.alpha > 255)
			{
				star.alpha = 255;
			}
			
			#if flash
			canvas.setPixel32(star.x, star.y, 0xffffffff);
			#else
			var rgba:RGBA = FlxColor.getRGB(FlxG.WHITE);
			#end
			
			#if !flash
			var starDef:StarDef = starArray[i];
			starDef.red = rgba.red / 255;
			starDef.green = rgba.green / 255;
			starDef.blue = rgba.blue / 255;
			starDef.alpha = rgba.alpha / 255;
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
				
				#if !flash
				starDef.alpha = 0;
				#end
			}
			
			#if !flash
			starDef.x = star.x - starSprite.halfWidth;
			starDef.y = star.y - starSprite.halfHeight;
			#end
		}
	}
	
	override public function draw():Void
	{
		if (FlxU.getTicks() > tick)
		{
			#if flash
			canvas.lock();
			canvas.fillRect(clsRect, clsColor);
			#end
			
			if (starfieldType == STARFIELD_TYPE_2D)
			{
				update2DStarfield();
			}
			else
			{
				update3DStarfield();
			}
			
			#if flash
			canvas.unlock();
			sprite.pixels = canvas;
			#end
			
			if (updateSpeed > 0)
			{
				tick = FlxU.getTicks() + updateSpeed;
			}
		}
	}
	
}

#if !flash
class StarSprite extends FlxSprite
{
	
	/**
	 * Information about stars positions and colors
	 */
	public var starData:Array<StarDef>;
	
	/**
	 * Starfield's background
	 */
	public var bgRed:Float;
	public var bgGreen:Float;
	public var bgBlue:Float;
	public var bgAlpha:Float;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 1, Height:Int = 1, ?bgColor:BitmapInt32)
	{
		super(X, Y);
		
		makeGraphic(1, 1, FlxG.WHITE);
		
		setBackgroundColor(bgColor);
		
		width = Width;
		height = Height;
		
		halfWidth = 0.5 * Width;
		halfHeight = 0.5 * Height;
		
		starData = new Array<StarDef>();
	}
	
	public function setBackgroundColor(bgColor:BitmapInt32):Void
	{
		var rgba:RGBA = FlxColor.getRGB(bgColor);
		bgRed = rgba.red / 255;
		bgGreen = rgba.green / 255;
		bgBlue = rgba.blue / 255;
		bgAlpha = rgba.alpha / 255;
	}
	
	override public function destroy():Void 
	{
		starData = null;
		super.destroy();
	}
	
	override public function draw():Void 
	{
		if (_atlas == null)
		{
			return;
		}
		
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var drawItem:DrawStackItem;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		
		var starRed:Float;
		var starGreen:Float;
		var starBlue:Float;
		
		var starDef:StarDef;
		
		while (i < l)
		{
			camera = cameras[i++];
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			
			#if !js
			var isColoredCamera:Bool = camera.isColored();
			drawItem = camera.getDrawStackItem(_atlas, true, _blendInt);
			#else
			drawItem = camera.getDrawStackItem(_atlas, true);
			#end
			
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = (x - (camera.scroll.x * scrollFactor.x) - (offset.x));
			_point.y = (y - (camera.scroll.y * scrollFactor.y) - (offset.y));
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end
			
			if (simpleRenderSprite())
			{	//Simple render
				
				_point.x += halfWidth;
				_point.y += halfHeight;
				
				// draw background
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _frameID;
				
				currDrawData[currIndex++] = width;
				currDrawData[currIndex++] = 0;
				currDrawData[currIndex++] = 0;
				currDrawData[currIndex++] = height;
				
				#if !js
				if (isColoredCamera)
				{
					currDrawData[currIndex++] = bgRed * camera.red; 
					currDrawData[currIndex++] = bgGreen * camera.green;
					currDrawData[currIndex++] = bgBlue * camera.blue;
				}
				else
				{
					currDrawData[currIndex++] = bgRed; 
					currDrawData[currIndex++] = bgGreen;
					currDrawData[currIndex++] = bgBlue;
				}
				#end
				
				currDrawData[currIndex++] = bgAlpha * alpha;
				
				// draw stars
				for (j in 0...(starData.length))
				{
					starDef = starData[j];
					
					currDrawData[currIndex++] = _point.x + starDef.x + 0.5;
					currDrawData[currIndex++] = _point.y + starDef.y + 0.5;
					
					currDrawData[currIndex++] = _frameID;
					
					currDrawData[currIndex++] = 1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
					
					starRed = starDef.red;
					starGreen = starDef.green;
					starBlue = starDef.blue;
					
				#if !js
					if (isColoredCamera)
					{
						starRed *= camera.red;
						starGreen *= camera.green;
						starBlue *= camera.blue;
					}
					
					#if !neko
					if (_color < 0xffffff)
					#else
					if (_color.rgb < 0xffffff)
					#end
					{
						starRed *= _red;
						starGreen *= _green;
						starBlue *= _blue;
					}
					
					currDrawData[currIndex++] = starRed; 
					currDrawData[currIndex++] = starGreen;
					currDrawData[currIndex++] = starBlue;
				#end	
					
					currDrawData[currIndex++] = alpha * starDef.alpha;
				}
				
				drawItem.position = currIndex;
			}
			else
			{	//Advanced render
				radians = angle * FlxG.RAD;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				var csx:Float = cos * scale.x;
				var ssy:Float = sin * scale.y;
				var ssx:Float = sin * scale.x;
				var csy:Float = cos * scale.y;
				
				_point.x += halfWidth;
				_point.y += halfHeight;
				
				// draw background
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _frameID;
				
				currDrawData[currIndex++] = csx * width;
				currDrawData[currIndex++] = -ssy * height;
				currDrawData[currIndex++] = ssx * width;
				currDrawData[currIndex++] = csy * height;
				
				#if !js
				if (isColoredCamera)
				{
					currDrawData[currIndex++] = bgRed * camera.red; 
					currDrawData[currIndex++] = bgGreen * camera.green;
					currDrawData[currIndex++] = bgBlue * camera.blue;
				}
				else
				{
					currDrawData[currIndex++] = bgRed; 
					currDrawData[currIndex++] = bgGreen;
					currDrawData[currIndex++] = bgBlue;
				}
				#end
				
				currDrawData[currIndex++] = bgAlpha * alpha;
				
				// draw stars
				for (j in 0...(starData.length))
				{
					starDef = starData[j];
					
					var localX:Float = starDef.x;
					var localY:Float = starDef.y;
					
					var relativeX:Float = (localX * csx - localY * ssy);
					var relativeY:Float = (localX * ssx + localY * csy);
					
					currDrawData[currIndex++] = _point.x + relativeX;
					currDrawData[currIndex++] = _point.y + relativeY;
					
					currDrawData[currIndex++] = _frameID;
					
					currDrawData[currIndex++] = csx;
					currDrawData[currIndex++] = -ssy;
					currDrawData[currIndex++] = ssx;
					currDrawData[currIndex++] = csy;
				
				#if !js
					starRed = starDef.red;
					starGreen = starDef.green;
					starBlue = starDef.blue;
					
					if (isColoredCamera)
					{
						starRed *= camera.red;
						starGreen *= camera.green;
						starBlue *= camera.blue;
					}
					
					#if !neko
					if (_color < 0xffffff)
					#else
					if (_color.rgb < 0xffffff)
					#end
					{
						starRed *= _red;
						starGreen *= _green;
						starBlue *= _blue;
					}
					
					currDrawData[currIndex++] = starRed; 
					currDrawData[currIndex++] = starGreen;
					currDrawData[currIndex++] = starBlue;
				#end
					
					currDrawData[currIndex++] = alpha * starDef.alpha;
				}
				
				drawItem.position = currIndex;
			}
			FlxBasic._VISIBLECOUNT++;
			
			#if !FLX_NO_DEBUG
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
			#end
		}
	}
	
	override public function updateFrameData():Void
	{
		if (_node != null && frameWidth >= 1 && frameHeight >= 1)
		{
			_framesData = _node.addSpriteFramesData(Std.int(frameWidth), Std.int(frameHeight));
			_frameID = _framesData.frameIDs[0];
		}
	}
}

typedef StarDef = {
	var x:Float;
	var y:Float;
	var red:Float;
	var green:Float;
	var blue:Float;
	var alpha:Float;
}
#end

class StarObject 
{
	public var index:Int;
	public var x:Int;
	public var y:Int;
	public var d:Float;
	public var speed:Float;
	public var r:Float;
	public var alpha:Float;
	
	public function new() {  }
}