package org.flixel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * The camera class is used to display the game's visuals in the Flash player.
 * By default one camera is created automatically, that is the same size as the Flash player.
 * You can add more cameras or even replace the main camera using utilities in <code>FlxG</code>.
 */
class FlxCamera extends FlxBasic
{
	/**
	 * Camera "follow" style preset: camera has no deadzone, just tracks the focus object directly.
	 */
	#if flash
	static public var STYLE_LOCKON:UInt = 0;
	#else
	static public var STYLE_LOCKON:Int = 0;
	#end
	/**
	 * Camera "follow" style preset: camera deadzone is narrow but tall.
	 */
	#if flash
	static public var STYLE_PLATFORMER:UInt = 1;
	#else
	static public var STYLE_PLATFORMER:Int = 1;
	#end
	/**
	 * Camera "follow" style preset: camera deadzone is a medium-size square around the focus object.
	 */
	#if flash
	static public var STYLE_TOPDOWN:UInt = 2;
	#else
	static public var STYLE_TOPDOWN:Int = 2;
	#end
	/**
	 * Camera "follow" style preset: camera deadzone is a small square around the focus object.
	 */
	#if flash
	static public var STYLE_TOPDOWN_TIGHT:UInt = 3;
	#else
	static public var STYLE_TOPDOWN_TIGHT:Int = 3;
	#end
	/**
	 * Camera "shake" effect preset: shake camera on both the X and Y axes.
	 */
	#if flash
	static public var SHAKE_BOTH_AXES:UInt = 0;
	#else
	static public var SHAKE_BOTH_AXES:Int = 0;
	#end
	/**
	 * Camera "shake" effect preset: shake camera on the X axis only.
	 */
	#if flash
	static public var SHAKE_HORIZONTAL_ONLY:UInt = 1;
	#else
	static public var SHAKE_HORIZONTAL_ONLY:Int = 1;
	#end
	/**
	 * Camera "shake" effect preset: shake camera on the Y axis only.
	 */
	#if flash
	static public var SHAKE_VERTICAL_ONLY:UInt = 2;
	#else
	static public var SHAKE_VERTICAL_ONLY:Int = 2;
	#end
	/**
	 * While you can alter the zoom of each camera after the fact,
	 * this variable determines what value the camera will start at when created.
	 */
	static public var defaultZoom:Float;
	
	/**
	 * The X position of this camera's display.  Zoom does NOT affect this number.
	 * Measured in pixels from the left side of the flash window.
	 */
	public var x:Float;
	/**
	 * The Y position of this camera's display.  Zoom does NOT affect this number.
	 * Measured in pixels from the top of the flash window.
	 */
	public var y:Float;
	/**
	 * How wide the camera display is, in game pixels.
	 */
	#if flash
	public var width:UInt;
	#else
	public var width:Int;
	#end
	/**
	 * How tall the camera display is, in game pixels.
	 */
	#if flash
	public var height:UInt;
	#else
	public var height:Int;
	#end
	/**
	 * Tells the camera to follow this <code>FlxObject</code> object around.
	 */
	public var target:FlxObject;
	/**
	 * You can assign a "dead zone" to the camera in order to better control its movement.
	 * The camera will always keep the focus object inside the dead zone,
	 * unless it is bumping up against the bounds rectangle's edges.
	 * The deadzone's coordinates are measured from the camera's upper left corner in game pixels.
	 * For rapid prototyping, you can use the preset deadzones (e.g. <code>STYLE_PLATFORMER</code>) with <code>follow()</code>.
	 */
	public var deadzone:FlxRect;
	/**
	 * The edges of the camera's range, i.e. where to stop scrolling.
	 * Measured in game pixels and world coordinates.
	 */
	public var bounds:FlxRect;
	
	/**
	 * Stores the basic parallax scrolling values.
	 */
	public var scroll:FlxPoint;
	/**
	 * The actual bitmap data of the camera display itself.
	 */
	public var buffer:BitmapData;
	/**
	 * The natural background color of the camera. Defaults to FlxG.bgColor.
	 * NOTE: can be transparent for crazy FX!
	 */
	#if flash
	public var bgColor:UInt;
	#else
	public var bgColor:Int;
	#end
	/**
	 * Sometimes it's easier to just work with a <code>FlxSprite</code> than it is to work
	 * directly with the <code>BitmapData</code> buffer.  This sprite reference will
	 * allow you to do exactly that.
	 */
	public var screen:FlxSprite;
	
	/**
	 * Indicates how far the camera is zoomed in.
	 */
	private var _zoom:Float;
	/**
	 * Internal, to help avoid costly allocations.
	 */
	private var _point:FlxPoint;
	/**
	 * Internal, help with color transforming the flash bitmap.
	 */
	#if flash
	private var _color:UInt;
	#else
	private var _color:Int;
	#end
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashBitmap:Bitmap;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	public var _flashSprite:Sprite;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	public var _flashOffsetX:Float;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	public var _flashOffsetY:Float;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashRect:Rectangle;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashPoint:Point;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	#if flash
	private var _fxFlashColor:UInt;
	#else
	private var _fxFlashColor:Int;
	#end
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashDuration:Float;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashComplete:Dynamic;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashAlpha:Float;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	#if flash
	private var _fxFadeColor:UInt;
	#else
	private var _fxFadeColor:Int;
	#end
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeDuration:Float;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeComplete:Dynamic;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeAlpha:Float;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeIntensity:Float;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeDuration:Float;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeComplete:Dynamic;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeOffset:FlxPoint;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	#if flash
	private var _fxShakeDirection:UInt;
	#else
	private var _fxShakeDirection:Int;
	#end
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 */
	private var _fill:BitmapData;
	
	/**
	 * Instantiates a new camera at the specified location, with the specified size and zoom level.
	 * @param X			X location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param Y			Y location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param Width		The width of the camera display in pixels.
	 * @param Height	The height of the camera display in pixels.
	 * @param Zoom		The initial zoom level of the camera.  A zoom level of 2 will make all pixels display at 2x resolution.
	 */
	public function new(X:Int, Y:Int, Width:Int, Height:Int, ?Zoom:Float = 0)
	{
		super();
		
		x = X;
		y = Y;
		width = Width;
		height = Height;
		target = null;
		deadzone = null;
		scroll = new FlxPoint();
		_point = new FlxPoint();
		bounds = null;
		screen = new FlxSprite();
		screen.makeGraphic(width,height,0,true);
		screen.setOriginToCorner();
		buffer = screen.pixels;
		bgColor = FlxG.bgColor;
		_color = 0xffffff;
		
		_flashBitmap = new Bitmap(buffer);
		_flashBitmap.x = -width*0.5;
		_flashBitmap.y = -height*0.5;
		_flashSprite = new Sprite();
		zoom = Zoom; //sets the scale of flash sprite, which in turn loads flashoffset values
		_flashOffsetX = width*0.5*zoom;
		_flashOffsetY = height*0.5*zoom;
		_flashSprite.x = x + _flashOffsetX;
		_flashSprite.y = y + _flashOffsetY;
		_flashSprite.addChild(_flashBitmap);
		_flashRect = new Rectangle(0,0,width,height);
		_flashPoint = new Point();
		
		_fxFlashColor = 0;
		_fxFlashDuration = 0.0;
		_fxFlashComplete = null;
		_fxFlashAlpha = 0.0;
		
		_fxFadeColor = 0;
		_fxFadeDuration = 0.0;
		_fxFadeComplete = null;
		_fxFadeAlpha = 0.0;
		
		_fxShakeIntensity = 0.0;
		_fxShakeDuration = 0.0;
		_fxShakeComplete = null;
		_fxShakeOffset = new FlxPoint();
		_fxShakeDirection = 0;
		
		_fill = new BitmapData(width, height, true, 0);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		screen.destroy();
		screen = null;
		target = null;
		scroll = null;
		deadzone = null;
		bounds = null;
		buffer = null;
		_flashBitmap = null;
		_flashRect = null;
		_flashPoint = null;
		_fxFlashComplete = null;
		_fxFadeComplete = null;
		_fxShakeComplete = null;
		_fxShakeOffset = null;
		_fill = null;
	}
	
	/**
	 * Updates the camera scroll as well as special effects like screen-shake or fades.
	 */
	override public function update():Void
	{
		//Either follow the object closely, 
		//or doublecheck our deadzone and update accordingly.
		if(target != null)
		{
			if (deadzone == null)
			{
				focusOn(target.getMidpoint(_point));
			}
			else
			{
				var edge:Float;
				var targetX:Float = target.x + ((target.x > 0)?0.0000001:-0.0000001);
				var targetY:Float = target.y + ((target.y > 0)?0.0000001:-0.0000001);
				
				edge = targetX - deadzone.x;
				if (scroll.x > edge)
				{
					scroll.x = edge;
				}
				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (scroll.x < edge)
				{
					scroll.x = edge;
				}
				
				edge = targetY - deadzone.y;
				if (scroll.y > edge)
				{
					scroll.y = edge;
				}
				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (scroll.y < edge)
				{
					scroll.y = edge;
				}
			}
		}
		
		//Make sure we didn't go outside the camera's bounds
		if(bounds != null)
		{
			if (scroll.x < bounds.left)
			{
				scroll.x = bounds.left;
			}
			if (scroll.x > bounds.right - width)
			{
				scroll.x = bounds.right - width;
			}
			if (scroll.y < bounds.top)
			{
				scroll.y = bounds.top;
			}
			if (scroll.y > bounds.bottom - height)
			{
				scroll.y = bounds.bottom - height;
			}
		}
		
		//Update the "flash" special effect
		if(_fxFlashAlpha > 0.0)
		{
			_fxFlashAlpha -= FlxG.elapsed/_fxFlashDuration;
			if ((_fxFlashAlpha <= 0) && (_fxFlashComplete != null))
			{
				_fxFlashComplete();
			}
		}
		
		//Update the "fade" special effect
		if((_fxFadeAlpha > 0.0) && (_fxFadeAlpha < 1.0))
		{
			_fxFadeAlpha += FlxG.elapsed/_fxFadeDuration;
			if(_fxFadeAlpha >= 1.0)
			{
				_fxFadeAlpha = 1.0;
				if (_fxFadeComplete != null)
				{
					_fxFadeComplete();
				}
			}
		}
		
		//Update the "shake" special effect
		if(_fxShakeDuration > 0)
		{
			_fxShakeDuration -= FlxG.elapsed;
			if(_fxShakeDuration <= 0)
			{
				_fxShakeOffset.make();
				if (_fxShakeComplete != null)
				{
					_fxShakeComplete();
				}
			}
			else
			{
				if ((_fxShakeDirection == SHAKE_BOTH_AXES) || (_fxShakeDirection == SHAKE_HORIZONTAL_ONLY))
				{
					_fxShakeOffset.x = (FlxG.random()*_fxShakeIntensity*width*2-_fxShakeIntensity*width)*_zoom;
				}
				if ((_fxShakeDirection == SHAKE_BOTH_AXES) || (_fxShakeDirection == SHAKE_VERTICAL_ONLY))
				{
					_fxShakeOffset.y = (FlxG.random()*_fxShakeIntensity*height*2-_fxShakeIntensity*height)*_zoom;
				}
			}
		}
	}
	
	/**
	 * Tells this camera object what <code>FlxObject</code> to track.
	 * @param	Target		The object you want the camera to track.  Set to null to not follow anything.
	 * @param	Style		Leverage one of the existing "deadzone" presets.  If you use a custom deadzone, ignore this parameter and manually specify the deadzone after calling <code>follow()</code>.
	 */
	public function follow(	Target:FlxObject, 
							#if flash 
							Style:UInt = 0/*STYLE_LOCKON*/
							#else
							Style:Int = 0
							#end
							):Void
	{
		target = Target;
		var helper:Float;
		switch(Style)
		{
			case STYLE_PLATFORMER:
				var w:Float = width/8;
				var h:Float = height/3;
				deadzone = new FlxRect((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);
			case STYLE_TOPDOWN:
				helper = FlxU.max(width,height)/4;
				deadzone = new FlxRect((width - helper) / 2, (height - helper) / 2, helper, helper);
			case STYLE_TOPDOWN_TIGHT:
				helper = FlxU.max(width,height)/8;
				deadzone = new FlxRect((width - helper) / 2, (height - helper) / 2, helper, helper);
			case STYLE_LOCKON:
				deadzone = null;
			default:
				deadzone = null;
		}
	}
	
	/**
	 * Move the camera focus to this location instantly.
	 * @param	Point		Where you want the camera to focus.
	 */
	public function focusOn(Point:FlxPoint):Void
	{
		Point.x += (Point.x > 0)?0.0000001: -0.0000001;
		Point.y += (Point.y > 0)?0.0000001: -0.0000001;
		scroll.make(Point.x - width * 0.5, Point.y - height * 0.5);
	}
	
	/**
	 * Specify the boundaries of the level or where the camera is allowed to move.
	 * @param	X				The smallest X value of your level (usually 0).
	 * @param	Y				The smallest Y value of your level (usually 0).
	 * @param	Width			The largest X value of your level (usually the level width).
	 * @param	Height			The largest Y value of your level (usually the level height).
	 * @param	UpdateWorld		Whether the global quad-tree's dimensions should be updated to match (default: false).
	 */
	public function setBounds(?X:Float = 0, ?Y:Float = 0, ?Width:Float = 0, ?Height:Float = 0, ?UpdateWorld:Bool = false):Void
	{
		if (bounds == null)
		{
			bounds = new FlxRect();
		}
		bounds.make(X,Y,Width,Height);
		if (UpdateWorld)
		{
			FlxG.worldBounds.copyFrom(bounds);
		}
		update();
	}
	
	/**
	 * The screen is filled with this color and gradually returns to normal.
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function flash(	
							#if flash
							?Color:UInt = 0xffffffff,
							#else
							?Color:Int = 0xffffffff,
							#end
							?Duration:Float = 1, ?OnComplete:Dynamic = null, ?Force:Bool = false):Void
	{
		if (!Force && (_fxFlashAlpha > 0.0))
		{
			return;
		}
		_fxFlashColor = Color;
		if (Duration <= 0)
		{
			Duration = FlxU.MIN_VALUE;
		}
		_fxFlashDuration = Duration;
		_fxFlashComplete = OnComplete;
		_fxFlashAlpha = 1.0;
	}
	
	/**
	 * The screen is gradually filled with this color.
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the fade to finish.
	 * @param	OnComplete	A function you want to run when the fade finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function fade(
							#if flash
							?Color:UInt = 0xff000000,
							#else
							?Color:Int = 0xff000000,
							#end
							?Duration:Float = 1, ?OnComplete:Dynamic = null, ?Force:Bool = false):Void
	{
		if (!Force && (_fxFadeAlpha > 0.0))
		{
			return;
		}
		_fxFadeColor = Color;
		if (Duration <= 0)
		{
			Duration = FlxU.MIN_VALUE;
		}
		_fxFadeDuration = Duration;
		_fxFadeComplete = OnComplete;
		_fxFadeAlpha = FlxU.MIN_VALUE;
	}
	
	/**
	 * A simple screen-shake effect.
	 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * @param	Duration	The length in seconds that the shaking effect should last.
	 * @param	OnComplete	A function you want to run when the shake effect finishes.
	 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
	 * @param	Direction	Whether to shake on both axes, just up and down, or just side to side (use class constants SHAKE_BOTH_AXES, SHAKE_VERTICAL_ONLY, or SHAKE_HORIZONTAL_ONLY).
	 */
	public function shake(	?Intensity:Float = 0.05, ?Duration:Float = 0.5, ?OnComplete:Dynamic = null, ?Force:Bool = true, 
							#if flash
							?Direction:UInt = 0/*SHAKE_BOTH_AXES*/
							#else
							?Direction:Int = 0
							#end
							):Void
	{
		if (!Force && ((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0)))
		{
			return;
		}
		_fxShakeIntensity = Intensity;
		_fxShakeDuration = Duration;
		_fxShakeComplete = OnComplete;
		_fxShakeDirection = Direction;
		_fxShakeOffset.make();
	}
	
	/**
	 * Just turns off all the camera effects instantly.
	 */
	public function stopFX():Void
	{
		_fxFlashAlpha = 0.0;
		_fxFadeAlpha = 0.0;
		_fxShakeDuration = 0;
		_flashSprite.x = x + width * 0.5;
		_flashSprite.y = y + height * 0.5;
	}
	
	/**
	 * Copy the bounds, focus object, and deadzone info from an existing camera.
	 * @param	Camera	The camera you want to copy from.
	 * @return	A reference to this <code>FlxCamera</code> object.
	 */
	public function copyFrom(Camera:FlxCamera):FlxCamera
	{
		if (Camera.bounds == null)
		{
			bounds = null;
		}
		else
		{
			if (bounds == null)
			{
				bounds = new FlxRect();
			}
			bounds.copyFrom(Camera.bounds);
		}
		target = Camera.target;
		if(target != null)
		{
			if (Camera.deadzone == null)
			{
				deadzone = null;
			}
			else
			{
				if (deadzone == null)
				{
					deadzone = new FlxRect();
				}
				deadzone.copyFrom(Camera.deadzone);
			}
		}
		return this;
	}
	
	public var zoom(getZoom, setZoom):Float;
	
	/**
	 * The zoom level of this camera. 1 = 1:1, 2 = 2x zoom, etc.
	 */
	public function getZoom():Float
	{
		return _zoom;
	}
	
	/**
	 * @private
	 */
	public function setZoom(Zoom:Float):Float
	{
		if (Zoom == 0)
		{
			_zoom = defaultZoom;
		}
		else
		{
			_zoom = Zoom;
		}
		setScale(_zoom, _zoom);
		return _zoom;
	}
	
	public var alpha(getAlpha, setAlpha):Float;
	
	/**
	 * The alpha value of this camera display (a Number between 0.0 and 1.0).
	 */
	public function getAlpha():Float
	{
		return _flashBitmap.alpha;
	}
	
	/**
	 * @private
	 */
	public function setAlpha(Alpha:Float):Float
	{
		_flashBitmap.alpha = Alpha;
		return Alpha;
	}
	
	public var angle(getAngle, setAngle):Float;
	
	/**
	 * The angle of the camera display (in degrees).
	 * Currently yields weird display results,
	 * since cameras aren't nested in an extra display object yet.
	 */
	public function getAngle():Float
	{
		return _flashSprite.rotation;
	}
	
	/**
	 * @private
	 */
	public function setAngle(Angle:Float):Float
	{
		_flashSprite.rotation = Angle;
		return Angle;
	}
	
	#if flash
	public var color(getColor, setColor):UInt;
	#else
	public var color(getColor, setColor):Int;
	#end
	
	/**
	 * The color tint of the camera display.
	 */
	#if flash
	public function getColor():UInt
	#else
	public function getColor():Int
	#end
	{
		return _color;
	}
	
	/**
	 * @private
	 */
	#if flash
	public function setColor(Color:UInt):UInt
	#else
	public function setColor(Color:Int):Int
	#end
	{
		_color = Color;
		var colorTransform:ColorTransform = _flashBitmap.transform.colorTransform;
		colorTransform.redMultiplier = (_color>>16)*0.00392;
		colorTransform.greenMultiplier = (_color>>8&0xff)*0.00392;
		colorTransform.blueMultiplier = (_color&0xff)*0.00392;
		_flashBitmap.transform.colorTransform = colorTransform;
		return _color;
	}
	
	public var antialiasing(getAntialiasing, setAntialiasing):Bool;
	
	/**
	 * Whether the camera display is smooth and filtered, or chunky and pixelated.
	 * Default behavior is chunky-style.
	 */
	public function getAntialiasing():Bool
	{
		return _flashBitmap.smoothing;
	}
	
	/**
	 * @private
	 */
	public function setAntialiasing(Antialiasing:Bool):Bool
	{
		_flashBitmap.smoothing = Antialiasing;
		return Antialiasing;
	}
	
	
	/**
	 * The scale of the camera object, irrespective of zoom.
	 * Currently yields weird display results,
	 * since cameras aren't nested in an extra display object yet.
	 */
	public function getScale():FlxPoint
	{
		return _point.make(_flashSprite.scaleX, _flashSprite.scaleY);
	}
	
	/**
	 * @private
	 */
	public function setScale(X:Float, Y:Float):Void
	{
		_flashSprite.scaleX = X;
		_flashSprite.scaleY = Y;
	}
	
	/**
	 * Fetches a reference to the Flash <code>Sprite</code> object
	 * that contains the camera display in the Flash display list.
	 * Uses include 3D projection, advanced display list modification, and more.
	 * NOTE: We don't recommend modifying this directly unless you are
	 * fairly experienced.  For simple changes to the camera display,
	 * like scaling, rotation, and color tinting, we recommend
	 * using the existing <code>FlxCamera</code> variables.
	 * @return	A Flash <code>Sprite</code> object containing the camera display.
	 */
	public function getContainerSprite():Sprite
	{
		return _flashSprite;
	}
	
	/**
	 * Fill the camera with the specified color.
	 * @param	Color		The color to fill with in 0xAARRGGBB hex format.
	 * @param	BlendAlpha	Whether to blend the alpha value or just wipe the previous contents.  Default is true.
	 */
	public function fill(
							#if flash
							Color:UInt, 
							#else
							Color:Int, 
							#end
							?BlendAlpha:Bool = true):Void
	{
		_fill.fillRect(_flashRect, Color);
		buffer.copyPixels(_fill, _flashRect, _flashPoint, null, null, BlendAlpha);
	}
	
	/**
	 * Internal helper function, handles the actual drawing of all the special effects.
	 */
	public function drawFX():Void
	{
		var alphaComponent:Float;
		
		//Draw the "flash" special effect onto the buffer
		if(_fxFlashAlpha > 0.0)
		{
			alphaComponent = _fxFlashColor >> 24;
			fill((Std.int(((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha) << 24) + (_fxFlashColor & 0x00ffffff));
		}
		
		//Draw the "fade" special effect onto the buffer
		if(_fxFadeAlpha > 0.0)
		{
			alphaComponent = _fxFadeColor >> 24;
			fill((Std.int(((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha) << 24) + (_fxFadeColor & 0x00ffffff));
		}
		
		if((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0))
		{
			_flashSprite.x = x + _flashOffsetX + _fxShakeOffset.x;
			_flashSprite.y = y + _flashOffsetY + _fxShakeOffset.y;
		}
	}
}