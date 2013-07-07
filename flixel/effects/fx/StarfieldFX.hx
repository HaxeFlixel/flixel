package flixel.effects.fx;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxMisc;
import flixel.system.layer.DrawStackItem;
import flixel.FlxBasic;


/**
 * Creates a 2D or 3D Star Field effect on an FlxSprite for use in your game.
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class StarfieldFX extends BaseFX
{
	inline static public var STARFIELD_TYPE_2D:Int = 1;
	inline static public var STARFIELD_TYPE_3D:Int = 2;
	
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
	public var starXOffset:Float = -1;
	/**
	 * How much to shift on the Y axis every update. Negative values move up, positiive values move down. 2D Starfield only. Can also be set via setStarSpeed()
	 */
	public var starYOffset:Float = 0;
	
	private var _stars:Array<StarObject>;
	private var _starfieldType:Int;
	
	private var _backgroundColor:Int;
	
	private var _updateSpeed:Int;
	private var _tick:Int;
	
	private var _depthColours:Array<Int>;
	
	public function new() 
	{
		super();
		
		_backgroundColor = FlxColor.BLACK;
	}
	
	/**
	 * Create a new StarField
	 * 
	 * @param	X				X coordinate of the starfield sprite
	 * @param	Y				Y coordinate of the starfield sprite
	 * @param	Width			The width of the starfield
	 * @param	Height			The height of the starfield
	 * @param	Quantity		The number of stars in the starfield (default 200)
	 * @param	FieldType		Type of starfield. Either STARFIELD_TYPE_2D (default, stars move horizontally) or STARFIELD_TYPE_3D (stars flow out from the center)
	 * @param	UpdateInterval	How many ms should pass before the next starfield update (default 20)
	 */
	public function create(X:Int, Y:Int, Width:Int, Height:Int, Quantity:Int = 200, FieldType:Int = 1, UpdateInterval:Int = 20):FlxSprite
	{
		#if flash
		sprite = new FlxSprite(X, Y).makeGraphic(Width, Height, _backgroundColor);
		canvas = new BitmapData(Std.int(sprite.width), Std.int(sprite.height), true, _backgroundColor);
		#else
		sprite = new StarSprite(X, Y, Width, Height, _backgroundColor);
		var starDefs:Array<StarDef> = cast(sprite, StarSprite).starData;
		#end
		_starfieldType = FieldType;
		_updateSpeed = speed;
		
		//	Stars come from the middle of the starfield in 3D mode
		centerX = Width >> 1;
		centerY = Height >> 1;
		
		_clsRect = new Rectangle(0, 0, Width, Height);
		_clsPoint = new Point();
		_clsColor = _backgroundColor;
		
		_stars = new Array<StarObject>();
		
		for (i in 0...(Quantity))
		{
			var star:StarObject = new StarObject();
			
			star.index = i;
			star.x = Std.int(Math.random() * Width);
			star.y = Std.int(Math.random() * Height);
			star.d = 1;
			
			if (FieldType == STARFIELD_TYPE_2D)
			{
				star.speed = 1 + Std.int(Math.random() * 5);
			}
			else
			{
				star.speed = Math.random();
			}
			
			star.r = Math.random() * Math.PI * 2;
			star.alpha = 0;
			
			_stars.push(star);
			
			#if !flash
			starDefs.push( { x: 0, y: 0, red: 0, green: 0, blue: 0, alpha: 0 } );
			#end
		}
		
		// Colours array
		if (FieldType == STARFIELD_TYPE_2D)
		{
			_depthColours = FlxGradient.createGradientArray(1, 5, [0xff585858, 0xffF4F4F4]);
		}
		else
		{
			_depthColours = FlxGradient.createGradientArray(1, 300, [0xff292929, 0xffffffff]);
		}
		
		active = true;
		
		return sprite;
	}
	
	/**
	 * Change the background color in the format 0xAARRGGBB of the starfield.
	 * Supports alpha, so if you want a transparent background just pass 0x00 as the color.
	 */
	public function setBackgroundColor(BackgroundColor:Int):Void
	{
		_clsColor = BackgroundColor;
		
		#if !flash
		if (sprite != null)
		{
			cast(sprite, StarSprite).setBackgroundColor(BackgroundColor);
		}
		#end
	}
	
	/**
	 * Change the number of layers (depth) and colors used for each layer of the starfield. Change happens immediately.
	 * 
	 * @param	Depth			Number of depths (for a 2D starfield the default is 5)
	 * @param	LowestColor		The color given to the stars furthest away from the camera (i.e. the slowest stars), typically the darker colour
	 * @param	HighestColor	The color given to the stars cloest to the camera (i.e. the fastest stars), typically the brighter colour
	 */
	public function setStarDepthColors(Depth:Int, LowestColor:Int = 0xff585858, HighestColor:Int = 0xffF4F4F4):Void
	{
		// Depth is the same, we just need to update the gradient then
		_depthColours = FlxGradient.createGradientArray(1, Depth, [LowestColor, HighestColor]);
		
		// Run through the stars array, making sure the depths are all within range
		for (star in _stars)
		{
			star.speed = 1 + Std.int(Math.random() * Depth);
		}
	}
	
	/**
	 * Sets the direction and speed of the 2D starfield (doesn't apply to 3D)
	 * You can combine both X and Y together to make the stars move on a diagnol
	 * 
	 * @param	ShiftX	How much to shift on the X axis every update. Negative values move towards the left, positiive to the right
	 * @param	ShiftY	How much to shift on the Y axis every update. Negative values move up, positiive values move down
	 */
	public function setStarSpeed(ShiftX:Float, ShiftY:Float):Void
	{
		starXOffset = ShiftX;
		starYOffset = ShiftY;
	}
	
	public var speed(get, set):Int;
	
	/**
	 * The current update speed
	 */
	private function get_speed():Int
	{
		return _updateSpeed;
	}
	
	/**
	 * Change the tick interval on which the update runs. By default the starfield updates once every 20ms. Set to zero to disable totally.
	 */
	private function set_speed(NewSpeed:Int):Int
	{
		_updateSpeed = NewSpeed;
		
		return NewSpeed;
	}
	
	private function update2DStarfield():Void
	{
		#if !flash
		var starSprite:StarSprite = cast(sprite, StarSprite);
		var starArray:Array<StarDef> = starSprite.starData;
		#end
		
		var star:StarObject;
		
		for (i in 0...(_stars.length))
		{
			star = _stars[i];
			star.x += Math.floor(starXOffset * star.speed);
			star.y += Math.floor(starYOffset * star.speed);
			
			#if flash
			canvas.setPixel32(star.x, star.y, _depthColours[Std.int(star.speed - 1)]);
			#else
			var starColor:Int = _depthColours[Std.int(star.speed - 1)];
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
		
		for (i in 0...(_stars.length))
		{
			star = _stars[i];
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
			var rgba:RGBA = FlxColor.getRGB(FlxColor.WHITE);
			#end
			
			#if !flash
			var starDef:StarDef = starArray[i];
			starDef.red = rgba.red / 255;
			starDef.green = rgba.green / 255;
			starDef.blue = rgba.blue / 255;
			starDef.alpha = rgba.alpha / 255;
			#end
			// canvas.setPixel32(star.x, star.y, FlxColor.getColor32(255, star.alpha, star.alpha, star.alpha));
			
			if (star.x < 0 || star.x > sprite.width || star.y < 0 || star.y > sprite.height)
			{
				star.d = 1;
				star.r = Math.random() * Math.PI * 2;
				star.x = 0;
				star.y = 0;
				star.speed = Math.random();
				star.alpha = 0;
				
				_stars[star.index] = star;
				
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
		if (FlxMisc.getTicks() > _tick)
		{
			#if flash
			canvas.lock();
			canvas.fillRect(_clsRect, _clsColor);
			#end
			
			if (_starfieldType == STARFIELD_TYPE_2D)
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
			
			if (_updateSpeed > 0)
			{
				_tick = FlxMisc.getTicks() + _updateSpeed;
			}
		}
	}
}

#if !flash
private class StarSprite extends FlxSprite
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
	
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 1, Height:Int = 1, ?bgColor:Int)
	{
		super(X, Y);
		
		makeGraphic(1, 1, FlxColor.WHITE);
		
		setBackgroundColor(bgColor);
		
		width = Width;
		height = Height;
		
		halfWidth = 0.5 * Width;
		halfHeight = 0.5 * Height;
		
		starData = new Array<StarDef>();
	}
	
	public function setBackgroundColor(bgColor:Int):Void
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
			cameras = FlxG.cameras.list;
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
			drawItem = camera.getDrawStackItem(_atlas, true, _blendInt, antialiasing);
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
			
			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
			// yes, 0.5
			var x1 : Float = 0.5; 
			var y1 : Float = 0.5; 
			
			if (!simpleRenderSprite ())
			{
				radians = angle * FlxAngle.TO_RAD;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				csx = cos * scale.x;
				ssy = sin * scale.y;
				ssx = sin * scale.x;
				csy = cos * scale.y;
				// yes, zero
				x1 = 0; 
				y1 = 0;
			}

			_point.x += halfWidth;
			_point.y += halfHeight;
			
			// draw background
			currDrawData[currIndex++] = _point.x;
			currDrawData[currIndex++] = _point.y;
			
			currDrawData[currIndex++] = _flxFrame.tileID;
			
			currDrawData[currIndex++] = csx * width;
			currDrawData[currIndex++] = ssx * width;
			currDrawData[currIndex++] = -ssy * height;
			currDrawData[currIndex++] = csy * height;
			
			#if !js
			currDrawData[currIndex++] = bgRed;
			currDrawData[currIndex++] = bgGreen;
			currDrawData[currIndex++] = bgBlue;
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
				
				currDrawData[currIndex++] = _point.x + relativeX + x1;
				currDrawData[currIndex++] = _point.y + relativeY + y1;
				
				currDrawData[currIndex++] = _flxFrame.tileID;
				
				currDrawData[currIndex++] = csx;
				currDrawData[currIndex++] = ssx;
				currDrawData[currIndex++] = -ssy;
				currDrawData[currIndex++] = csy;
			
				starRed = starDef.red;
				starGreen = starDef.green;
				starBlue = starDef.blue;
				
			#if !js
				if (_color < 0xffffff)
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

			FlxBasic._VISIBLECOUNT++;
		}
	}
	
	override public function updateFrameData():Void
	{
		if (_node != null && frameWidth >= 1 && frameHeight >= 1)
		{
			_framesData = _node.getSpriteSheetFrames(Std.int(frameWidth), Std.int(frameHeight));
			_flxFrame = _framesData.frames[0];
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

private class StarObject 
{
	public var index:Int;
	public var x:Int;
	public var y:Int;
	public var d:Float;
	public var speed:Float;
	public var r:Float;
	public var alpha:Float;
	
	public function new() {}
}