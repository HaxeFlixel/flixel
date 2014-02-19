package flixel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.system.layer.DrawStackItem;
import flixel.system.layer.TileSheetExt;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.util.loaders.CachedGraphics;

/**
 * The camera class is used to display the game's visuals in the Flash player.
 * By default one camera is created automatically, that is the same size as the Flash player.
 * You can add more cameras or even replace the main camera using utilities in FlxG.
 */
class FlxCamera extends FlxBasic
{
	/**
	 * Camera "follow" style preset: camera has no deadzone, just tracks the focus object directly.
	 */
	public static inline var STYLE_LOCKON:Int = 0;
	/**
	 * Camera "follow" style preset: camera deadzone is narrow but tall.
	 */
	public static inline var STYLE_PLATFORMER:Int = 1;
	/**
	 * Camera "follow" style preset: camera deadzone is a medium-size square around the focus object.
	 */
	public static inline var STYLE_TOPDOWN:Int = 2;
	/**
	 * Camera "follow" style preset: camera deadzone is a small square around the focus object.
	 */
	public static inline var STYLE_TOPDOWN_TIGHT:Int = 3;
	/**
	 * Camera "follow" style preset: camera will move screenwise.
	 */
	public static inline var STYLE_SCREEN_BY_SCREEN:Int = 4;
	/**
	 * Camera "follow" style preset: camera has no deadzone, just tracks the focus object directly and centers it.
	 */
	public static inline var STYLE_NO_DEAD_ZONE:Int = 5;
	/**
	 * Camera "shake" effect preset: shake camera on both the X and Y axes.
	 */
	public static inline var SHAKE_BOTH_AXES:Int = 0;
	/**
	 * Camera "shake" effect preset: shake camera on the X axis only.
	 */
	public static inline var SHAKE_HORIZONTAL_ONLY:Int = 1;
	/**
	 * Camera "shake" effect preset: shake camera on the Y axis only.
	 */
	public static inline var SHAKE_VERTICAL_ONLY:Int = 2;
	/**
	 * While you can alter the zoom of each camera after the fact,
	 * this variable determines what value the camera will start at when created.
	 */
	public static var defaultZoom:Float;
	
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
	 * Tells the camera to use this following style.
	 */
	public var style:Int;
	/**
	 * Tells the camera to follow this FlxObject object around.
	 */
	public var target:FlxObject = null;
	/**
	 * Used to smoothly track the camera as it follows.
	 */
	public var followLerp:Float;
	/**
	 * You can assign a "dead zone" to the camera in order to better control its movement. The camera will always keep the focus object inside the dead zone, unless it is bumping up against 
	 * the bounds rectangle's edges. The deadzone's coordinates are measured from the camera's upper left corner in game pixels. For rapid prototyping, you can use the preset deadzones (e.g. STYLE_PLATFORMER) with follow().
	 */
	public var deadzone:FlxRect = null;
	/**
	 * The edges of the camera's range, i.e. where to stop scrolling.
	 * Measured in game pixels and world coordinates.
	 */
	public var bounds:FlxRect = null;
	/**
	 * Stores the basic parallax scrolling values.
	 */
	public var scroll:FlxPoint;
	
	#if flash
	/**
	 * The actual bitmap data of the camera display itself.
	 */
	public var buffer:BitmapData;
	/**
	 * Whether checkResize checks if the camera dimensions have changed to update the buffer dimensions.
	 */
	public var regen:Bool = false;
	#end
	
	/**
	 * The natural background color of the camera. Defaults to FlxG.cameras.bgColor.
	 * NOTE: can be transparent for crazy FX (only works on flash)!
	 */
	public var bgColor:Int;
	
	#if flash
	/**
	 * Sometimes it's easier to just work with a FlxSprite than it is to work directly with the BitmapData buffer.  
	 * This sprite reference will allow you to do exactly that.
	 */
	public var screen:FlxSprite;
	#end
	
	/**
	 * Whether to use alpha blending for camera's background fill or not. 
	 * Useful for flash target (and works only on this target). Default value is true.
	 */
	public var useBgAlphaBlending:Bool = true;
	
	/**
	 * Used to render buffer to screen space. NOTE: We don't recommend modifying this directly unless you are fairly experienced. 
	 * Uses include 3D projection, advanced display list modification, and more.
	 */
	public var flashSprite:Sprite;
	
	/**
	 * How wide the camera display is, in game pixels.
	 */
	public var width(default, set):Int;
	/**
	 * How tall the camera display is, in game pixels.
	 */
	public var height(default, set):Int;
	/**
	 * The zoom level of this camera. 1 = 1:1, 2 = 2x zoom, etc.
	 * Indicates how far the camera is zoomed in.
	 */
	public var zoom(default, set):Float;
	/**
	 * The alpha value of this camera display (a Number between 0.0 and 1.0).
	 */
	public var alpha(default, set):Float = 1;
	/**
	 * The angle of the camera display (in degrees). Currently yields weird display results,
	 * since cameras aren't nested in an extra display object yet.
	 */
	public var angle(default, set):Float = 0;
	/**
	 * The color tint of the camera display.
	 * (Internal, help with color transforming the flash bitmap.)
	 */
	public var color(default, set):Int = FlxColor.WHITE;
	/**
	 * Whether the camera display is smooth and filtered, or chunky and pixelated.
	 * Default behavior is chunky-style.
	 */
	public var antialiasing(default, set):Bool = false;
	/**
	 * Used to force the camera to look ahead of the target.
	 */
	public var followLead(default, null):FlxPoint;
	
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashRect:Rectangle;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashPoint:Point;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private var _flashOffset:FlxPoint;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashColor:Int = FlxColor.TRANSPARENT;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashDuration:Float = 0;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashComplete:Void->Void = null;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashAlpha:Float = 0;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeColor:Int = FlxColor.TRANSPARENT;
	/**
	 * Used to calculate the following target current velocity.
	 */
	private var _lastTargetPosition:FlxPoint;
	/**
	 * Helper to calculate follow target current scroll.
	 */
	private var _scrollTarget:FlxPoint;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeDuration:Float = 0;
	/**
     * Internal, used to control the "fade" special effect.
     */
    private var _fxFadeIn:Bool = false;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeComplete:Void->Void = null;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeAlpha:Float = 0;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeIntensity:Float = 0;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeDuration:Float = 0;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeComplete:Void->Void = null;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeOffset:FlxPoint;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeDirection:Int = 0;
	/**
	 * Internal, to help avoid costly allocations.
	 */
	private var _point:FlxPoint;
	
	#if flash
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 */
	private var _fill:BitmapData;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashBitmap:Bitmap;
	#end
	
#if !flash
	/**
	 * Sprite for drawing (instead of _flashBitmap in flash)
	 */
	public var canvas:Sprite = null;
	
	#if !FLX_NO_DEBUG
	/**
	 * Sprite for visual effects (flash and fade) and visual debug information (bounding boxes are drawn on it) for non-flash targets
	 */
	public var debugLayer:Sprite;
	#end
	
	/**
	 * Currently used draw stack item
	 */
	private var _currentStackItem:DrawStackItem;
	/**
	 * Pointer to head of stack with draw items
	 */
	private var _headOfDrawStack:DrawStackItem;
	/**
	 * Draw stack items that can be reused
	 */
	private static var _storageHead:DrawStackItem;
	
	#if !js
	@:noCompletion public function getDrawStackItem(ObjGraphics:CachedGraphics, ObjColored:Bool, ObjBlending:Int, ObjAntialiasing:Bool = false):DrawStackItem
	#else
	@:noCompletion public function getDrawStackItem(ObjGraphics:CachedGraphics, UseAlpha:Bool, ObjAntialiasing:Bool = false):DrawStackItem
	#end
	{
		var itemToReturn:DrawStackItem = null;
		if (_currentStackItem.initialized == false)
		{
			_headOfDrawStack = _currentStackItem;
			_currentStackItem.graphics = ObjGraphics;
			_currentStackItem.antialiasing = ObjAntialiasing;
			#if !js
			_currentStackItem.colored = ObjColored;
			_currentStackItem.blending = ObjBlending;
			#else
			_currentStackItem.useAlpha = UseAlpha;
			#end
			itemToReturn = _currentStackItem;
		}
	#if !js
		else if (_currentStackItem.graphics == ObjGraphics 
			&& _currentStackItem.colored == ObjColored 
			&& _currentStackItem.blending == ObjBlending 
			&& _currentStackItem.antialiasing == ObjAntialiasing 
		)
	#else
		else if (_currentStackItem.graphics == ObjGraphics && _currentStackItem.useAlpha == UseAlpha)
	#end
		{
			itemToReturn = _currentStackItem;
		}
		
		if (itemToReturn == null)
		{
			var newItem:DrawStackItem = null;
			if (_storageHead != null)
			{
				newItem = _storageHead;
				var newHead:DrawStackItem = FlxCamera._storageHead.next;
				newItem.next = null;
				FlxCamera._storageHead = newHead;
			}
			else
			{
				newItem = new DrawStackItem();
			}
			
			newItem.graphics = ObjGraphics;
			newItem.antialiasing = ObjAntialiasing;
			#if !js
			newItem.colored = ObjColored;
			newItem.blending = ObjBlending;
			#else
			newItem.useAlpha = UseAlpha;
			#end
			_currentStackItem.next = newItem;
			_currentStackItem = newItem;
			itemToReturn = _currentStackItem;
		}
		
		itemToReturn.initialized = true;
		return itemToReturn;
	}
	
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private function clearDrawStack():Void
	{	
		var currItem:DrawStackItem = _headOfDrawStack.next;
		while (currItem != null)
		{
			currItem.reset();
			var newStorageHead:DrawStackItem = currItem;
			currItem = currItem.next;
			if (_storageHead == null)
			{
				FlxCamera._storageHead = newStorageHead;
				newStorageHead.next = null;
			}
			else
			{
				newStorageHead.next = FlxCamera._storageHead;
				FlxCamera._storageHead = newStorageHead;
			}
		}
		
		_headOfDrawStack.reset();
		_headOfDrawStack.next = null;
		_currentStackItem = _headOfDrawStack;
	}
	
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private function render():Void
	{
		var currItem:DrawStackItem = _headOfDrawStack;
		while (currItem != null)
		{
			var data:Array<Float> = currItem.drawData;
			var dataLen:Int = data.length;
			var position:Int = currItem.position;
			if (position > 0)
			{
				if (dataLen != position)
				{
					untyped data.length = position; // optimized way of resizing an array
				}
				var tempFlags:Int = Graphics.TILE_TRANS_2x2;
				#if !js
				tempFlags |= Graphics.TILE_ALPHA;
				if (currItem.colored)
				{
					tempFlags |= Graphics.TILE_RGB;
				}
				tempFlags |= currItem.blending;
				#else
				if (currItem.useAlpha)
				{
					tempFlags |= Graphics.TILE_ALPHA;
				}
				#end
				currItem.graphics.tilesheet.tileSheet.drawTiles(canvas.graphics, data, (antialiasing || currItem.antialiasing), tempFlags);
				TileSheetExt._DRAWCALLS++;
			}
			currItem = currItem.next;
		}
	}
#end
	
	/**
	 * Instantiates a new camera at the specified location, with the specified size and zoom level.
	 * 
	 * @param 	X			X location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param 	Y			Y location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param 	Width		The width of the camera display in pixels.
	 * @param 	Height	The height of the camera display in pixels.
	 * @param 	Zoom		The initial zoom level of the camera.  A zoom level of 2 will make all pixels display at 2x resolution.
	 */
	public function new(X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0)
	{
		super();
		
		_scrollTarget = new FlxPoint();
		
		x = X;
		y = Y;
		// Use the game dimensions if width / height are <= 0
		width = (Width <= 0) ? FlxG.width : Width;
		height = (Height <= 0) ? FlxG.height : Height;
		
		scroll = new FlxPoint();
		followLead = new FlxPoint();
		_point = new FlxPoint();
		_flashOffset = new FlxPoint();
		
		#if flash
		screen = new FlxSprite();
		buffer = new BitmapData(width, height, true, 0);
		screen.pixels = buffer;
		screen.origin.set();
		#end
		
		#if flash
		_flashBitmap = new Bitmap(buffer);
		_flashBitmap.x = -width * 0.5;
		_flashBitmap.y = -height * 0.5;
		#else
		canvas = new Sprite();
		canvas.x = -width * 0.5;
		canvas.y = -height * 0.5;
		#end
		
		#if flash
		color = 0xffffff;
		#end
		
		flashSprite = new Sprite();
		zoom = Zoom; //sets the scale of flash sprite, which in turn loads flashoffset values
		
		_flashOffset.set((width * 0.5 * zoom), (height * 0.5 * zoom));
		
		flashSprite.x = x + _flashOffset.x;
		flashSprite.y = y + _flashOffset.y;
		
		#if flash
		flashSprite.addChild(_flashBitmap);
		#else
		flashSprite.addChild(canvas);
		#end
		_flashRect = new Rectangle(0, 0, width, height);
		_flashPoint = new Point();
		
		_fxShakeOffset = new FlxPoint();
		
		#if flash
		_fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		#else
		
		#if !js
		canvas.scrollRect = new Rectangle(0, 0, width, height);
		#else
		canvas.scrollRect = new Rectangle(0, 0, width * zoom, height * zoom);
		#end
		
		#if !FLX_NO_DEBUG
		debugLayer = new Sprite();
		debugLayer.x = -width * 0.5;
		debugLayer.y = -height * 0.5;
		debugLayer.scaleX = 1;
		flashSprite.addChild(debugLayer);
		#end
		
		_currentStackItem = new DrawStackItem();
		_headOfDrawStack = _currentStackItem;
		#end
		
		bgColor = FlxG.cameras.bgColor;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		#if flash
		screen = FlxG.safeDestroy(screen);
		#end
		target = null;
		scroll = null;
		deadzone = null;
		bounds = null;
		#if flash
		buffer = null;
		_flashBitmap = null;
		#end
		_flashRect = null;
		_flashPoint = null;
		_fxFlashComplete = null;
		_fxFadeComplete = null;
		_fxShakeComplete = null;
		_fxShakeOffset = null;
		#if flash
		if (_fill != null)
		{
			_fill.dispose();
		}
		_fill = null;
		#else
		
		#if !FLX_NO_DEBUG
		flashSprite.removeChild(debugLayer);
		debugLayer = null;
		#end
		flashSprite.removeChild(canvas);
		var canvasNumChildren:Int = canvas.numChildren;
		for (i in 0...(canvasNumChildren))
		{
			canvas.removeChildAt(0);
		}
		canvas = null;
		
		clearDrawStack();
		
		_headOfDrawStack.dispose();
		_headOfDrawStack = null;
		_currentStackItem = null;
		#end
		flashSprite = null;
		
		super.destroy();
	}
	
	/**
	 * Updates the camera scroll as well as special effects like screen-shake or fades.
	 */
	override public function update():Void
	{
		// follow the target, if there is one
		if (target != null)
		{
			updateFollow();
		}
		
		//Make sure we didn't go outside the camera's bounds
		if (bounds != null)
		{
			scroll.x = FlxMath.bound(scroll.x, bounds.left, (bounds.right - width));
			scroll.y = FlxMath.bound(scroll.y, bounds.top, (bounds.bottom - height));
		}
		
		updateFlash();
		updateFade();
		updateShake();
	}
	
	private function updateFollow():Void
	{
		//Either follow the object closely, 
		//or doublecheck our deadzone and update accordingly.
		if (deadzone == null)
		{
			focusOn(target.getMidpoint(_point));
		}
		else
		{
			var edge:Float;
			var targetX:Float = target.x;
			var targetY:Float = target.y;
			
			if (style == STYLE_SCREEN_BY_SCREEN) 
			{
				if (targetX > (scroll.x + width))
				{
					_scrollTarget.x += width;
				}
				else if (targetX < scroll.x)
				{
					_scrollTarget.x -= width;
				}

				if (targetY > (scroll.y + height))
				{
					_scrollTarget.y += height;
				}
				else if (targetY < scroll.y)
				{
					_scrollTarget.y -= height;
				}
			}
			else
			{
				edge = targetX - deadzone.x;
				if (_scrollTarget.x > edge)
				{
					_scrollTarget.x = edge;
				} 
				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (_scrollTarget.x < edge)
				{
					_scrollTarget.x = edge;
				}

				edge = targetY - deadzone.y;
				if (_scrollTarget.y > edge)
				{
					_scrollTarget.y = edge;
				}
				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (_scrollTarget.y < edge)
				{
					_scrollTarget.y = edge;
				}
			}
			
			if (Std.is(target, FlxSprite))
			{
				if (_lastTargetPosition == null)  
				{
					_lastTargetPosition = new FlxPoint(target.x, target.y); // Creates this point.
				} 
				_scrollTarget.x += (target.x - _lastTargetPosition.x ) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y ) * followLead.y;
				
				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}
			
			if (followLerp == 0) 
			{
				scroll.x = _scrollTarget.x; // Prevents Camera Jittering with no lerp.
				scroll.y = _scrollTarget.y; // Prevents Camera Jittering with no lerp.
			} 
			else 
			{
				scroll.x += (_scrollTarget.x - scroll.x) * FlxG.elapsed / (FlxG.elapsed + followLerp * FlxG.elapsed);
				scroll.y += (_scrollTarget.y - scroll.y) * FlxG.elapsed / (FlxG.elapsed + followLerp * FlxG.elapsed);
			}	
		}
	}
	
	private function updateFlash():Void
	{
		//Update the "flash" special effect
		if (_fxFlashAlpha > 0.0)
		{
			_fxFlashAlpha -= FlxG.elapsed / _fxFlashDuration;
			if ((_fxFlashAlpha <= 0) && (_fxFlashComplete != null))
			{
				_fxFlashComplete();
			}
		}
	}
	
	private function updateFade():Void
	{
		if ((_fxFadeAlpha > 0.0) && (_fxFadeAlpha < 1.0))
		{
			if (_fxFadeIn)
			{
				_fxFadeAlpha -= FlxG.elapsed /_fxFadeDuration;
                if (_fxFadeAlpha <= 0.0)
                {
                    _fxFadeAlpha = 0.0;
                    if (_fxFadeComplete != null)
                    {
						_fxFadeComplete();
					}
                }
			}
			else
			{
				_fxFadeAlpha += FlxG.elapsed / _fxFadeDuration;
				if (_fxFadeAlpha >= 1.0)
				{
					_fxFadeAlpha = 1.0;
					if (_fxFadeComplete != null)
					{
						_fxFadeComplete();
					}
				}
			}
		}
	}
	
	private function updateShake():Void
	{
		if (_fxShakeDuration > 0)
		{
			_fxShakeDuration -= FlxG.elapsed;
			if (_fxShakeDuration <= 0)
			{
				_fxShakeOffset.set();
				if (_fxShakeComplete != null)
				{
					
					_fxShakeComplete();
				}
			}
			else
			{
				if ((_fxShakeDirection == SHAKE_BOTH_AXES) || (_fxShakeDirection == SHAKE_HORIZONTAL_ONLY))
				{
					_fxShakeOffset.x = (FlxRandom.float() * _fxShakeIntensity * width * 2 - _fxShakeIntensity * width) * zoom;
				}
				if ((_fxShakeDirection == SHAKE_BOTH_AXES) || (_fxShakeDirection == SHAKE_VERTICAL_ONLY))
				{
					_fxShakeOffset.y = (FlxRandom.float() * _fxShakeIntensity * height * 2 - _fxShakeIntensity * height) * zoom;
				}
			}
			
			// Camera shake fix for target follow.
			if (target != null)
			{
				flashSprite.x = x + _flashOffset.x;
				flashSprite.y = y + _flashOffset.y;
			}
		}
	}
	
	/**
	 * Tells this camera object what FlxObject to track.
	 * 
	 * @param	Target		The object you want the camera to track.  Set to null to not follow anything.
	 * @param	Style		Leverage one of the existing "deadzone" presets.  If you use a custom deadzone, ignore this parameter and manually specify the deadzone after calling follow().
	 * @param	Offset		Offset the follow deadzone by a certain amount. Only applicable for STYLE_PLATFORMER and STYLE_LOCKON styles.
	 * @param	Lerp		How much lag the camera should have (can help smooth out the camera movement).
	 */
	public function follow(Target:FlxObject, Style:Int = STYLE_LOCKON, ?Offset:FlxPoint, Lerp:Float = 0):Void
	{
		style = Style;
		target = Target;
		followLerp = Lerp;
		var helper:Float;
		var w:Float = 0;
		var h:Float = 0;
		_lastTargetPosition = null;
		
		switch (Style)
		{
			case STYLE_PLATFORMER:
				var w:Float = (width / 8) + (Offset != null ? Offset.x : 0);
				var h:Float = (height / 3) + (Offset != null ? Offset.y : 0);
				deadzone = new FlxRect((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);
				
			case STYLE_TOPDOWN:
				helper = Math.max(width, height) / 4;
				deadzone = new FlxRect((width - helper) / 2, (height - helper) / 2, helper, helper);
				
			case STYLE_TOPDOWN_TIGHT:
				helper = Math.max(width, height) / 8;
				deadzone = new FlxRect((width - helper) / 2, (height - helper) / 2, helper, helper);
				
			case STYLE_LOCKON:
				if (target != null) 
				{	
					w = target.width + (Offset != null ? Offset.x : 0);
					h = target.height + (Offset != null ? Offset.y : 0);
				}
				deadzone = new FlxRect((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);
				
			case STYLE_SCREEN_BY_SCREEN:
				deadzone = new FlxRect(0, 0, width, height);
				
			default:
				deadzone = null;
		}
		
	}
	
	/**
	 * Move the camera focus to this location instantly.
	 * 
	 * @param	Point		Where you want the camera to focus.
	 */
	public inline function focusOn(point:FlxPoint):Void
	{
		scroll.set(point.x - width * 0.5, point.y - height * 0.5);
	}
	
	/**
	 * The screen is filled with this color and gradually returns to normal.
	 * 
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function flash(Color:Int = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		if (!Force && (_fxFlashAlpha > 0.0))
		{
			return;
		}
		_fxFlashColor = Color;
		if (Duration <= 0)
		{
			Duration = FlxMath.MIN_VALUE;
		}
		_fxFlashDuration = Duration;
		_fxFlashComplete = OnComplete;
		_fxFlashAlpha = 1.0;
	}
	
	/**
	 * The screen is gradually filled with this color.
	 * 
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the fade to finish.
	 * @param   FadeIn      True fades from a color, false fades to it.
	 * @param	OnComplete	A function you want to run when the fade finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function fade(Color:Int = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		if (!Force && (_fxFadeAlpha > 0.0))
		{
			return;
		}
		_fxFadeColor = Color;
		if (Duration <= 0)
		{
			Duration = FlxMath.MIN_VALUE;
		}
		
		_fxFadeIn = FadeIn;
		_fxFadeDuration = Duration;
		_fxFadeComplete = OnComplete;
		
		if (_fxFadeIn)
		{
			_fxFadeAlpha = 0.999999;
		}
		else
		{
			_fxFadeAlpha = FlxMath.MIN_VALUE;
		}
	}
	
	/**
	 * A simple screen-shake effect.
	 * 
	 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * @param	Duration	The length in seconds that the shaking effect should last.
	 * @param	OnComplete	A function you want to run when the shake effect finishes.
	 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
	 * @param	Direction	Whether to shake on both axes, just up and down, or just side to side (use class constants SHAKE_BOTH_AXES, SHAKE_VERTICAL_ONLY, or SHAKE_HORIZONTAL_ONLY).
	 */
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, Direction:Int = SHAKE_BOTH_AXES):Void
	{
		if (!Force && ((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0)))
		{
			return;
		}
		_fxShakeIntensity = Intensity;
		_fxShakeDuration = Duration;
		_fxShakeComplete = OnComplete;
		_fxShakeDirection = Direction;
		_fxShakeOffset.set();
	}
	
	/**
	 * Just turns off all the camera effects instantly.
	 */
	public function stopFX():Void
	{
		_fxFlashAlpha = 0.0;
		_fxFadeAlpha = 0.0;
		_fxShakeDuration = 0;
		flashSprite.x = x + _flashOffset.x;
		flashSprite.y = y + _flashOffset.y;
	}
	
	/**
	 * Copy the bounds, focus object, and deadzone info from an existing camera.
	 * 
	 * @param	Camera	The camera you want to copy from.
	 * @return	A reference to this FlxCamera object.
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
		
		if (target != null)
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
	
	/**
	 * Fill the camera with the specified color.
	 * 
	 * @param	Color		The color to fill with in 0xAARRGGBB hex format.
	 * @param	BlendAlpha	Whether to blend the alpha value or just wipe the previous contents.  Default is true.
	 */
	public function fill(Color:Int, BlendAlpha:Bool = true, FxAlpha:Float = 1.0, ?graphics:Graphics):Void
	{
	#if flash
		if (BlendAlpha)
		{
			_fill.fillRect(_flashRect, Color);
			buffer.copyPixels(_fill, _flashRect, _flashPoint, null, null, BlendAlpha);
		}
		else
		{
			buffer.fillRect(_flashRect, Color);
		}
	#else
		
		if (FxAlpha == 0)
		{
			return;
		}
		// This is temporal fix for camera's color
		var targetGraphics:Graphics = (graphics == null) ? canvas.graphics : graphics;
		Color = Color & 0x00ffffff;
		// end of fix
		
		targetGraphics.beginFill(Color, FxAlpha);
		targetGraphics.drawRect(0, 0, width, height);
		targetGraphics.endFill();
	#end
	}
	
	/**
	 * Internal helper function, handles the actual drawing of all the special effects.
	 */
	public function drawFX():Void
	{
		var alphaComponent:Float;
		
		//Draw the "flash" special effect onto the buffer
		if (_fxFlashAlpha > 0.0)
		{
			alphaComponent = (_fxFlashColor >> 24) & 255;
			
			#if flash
			fill((Std.int(((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha) << 24) + (_fxFlashColor & 0x00ffffff));
			#else
			fill((_fxFlashColor & 0x00ffffff), true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha / 255, canvas.graphics);
			#end
		}
		
		//Draw the "fade" special effect onto the buffer
		if (_fxFadeAlpha > 0.0)
		{
			alphaComponent = (_fxFadeColor >> 24) & 255;
			
			#if flash
			fill((Std.int(((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha) << 24) + (_fxFadeColor & 0x00ffffff));
			#else
			fill((_fxFadeColor & 0x00ffffff), true, ((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha / 255, canvas.graphics);
			#end
		}
		
		if ((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0))
		{
			flashSprite.x += _fxShakeOffset.x;
			flashSprite.y += _fxShakeOffset.y;
		}
	}
	
	#if flash
	public function checkResize():Void
	{
		if (regen)
		{
			if (width != buffer.width || height != buffer.height)
			{
				FlxG.bitmap.remove(screen.cachedGraphics.key);
				buffer = new BitmapData(width, height, true, 0);
				screen.pixels = buffer;
				screen.origin.set();
				_flashBitmap.bitmapData = buffer;
				_flashRect.width = width;
				_flashRect.height = height;
				_fill.dispose();
				_fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
			}
			
			regen = false;
		}
	}
	#end
	
	/**
	 * Shortcut for setting both width and Height.
	 * 
	 * @param	Width	The new sprite width.
	 * @param	Height	The new sprite height.
	 */
	public inline function setSize(Width:Int, Height:Int)
	{
		width = Width;
		height = Height;
	}
	
	/**
	 * Helper function to set the coordinates of this camera.
	 * Handy since it only requires one line of code.
	 * 
	 * @param	X	The new x position
	 * @param	Y	The new y position
	 */
	public inline function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}
	
	/**
	 * Specify the boundaries of the level or where the camera is allowed to move.
	 * 
	 * @param	X				The smallest X value of your level (usually 0).
	 * @param	Y				The smallest Y value of your level (usually 0).
	 * @param	Width			The largest X value of your level (usually the level width).
	 * @param	Height			The largest Y value of your level (usually the level height).
	 * @param	UpdateWorld		Whether the global quad-tree's dimensions should be updated to match (default: false).
	 */
	public function setBounds(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0, UpdateWorld:Bool = false):Void
	{
		if (bounds == null)
		{
			bounds = new FlxRect();
		}
		bounds.set(X, Y, Width, Height);
		if (UpdateWorld)
		{
			FlxG.worldBounds.copyFrom(bounds);
		}
		update();
	}
	
	public function setScale(X:Float, Y:Float):Void
	{
		flashSprite.scaleX = X;
		flashSprite.scaleY = Y;
		
		//camera positioning fix from bomski (https://github.com/Beeblerox/HaxeFlixel/issues/66)
		_flashOffset.x = width * 0.5 * X;
		_flashOffset.y = height * 0.5 * Y;	
	}
	
	/**
	 * The scale of the camera object, irrespective of zoom.
	 * Currently yields weird display results, since cameras aren't nested in an extra display object yet.
	 */
	public inline function getScale():FlxPoint
	{
		return _point.set(flashSprite.scaleX, flashSprite.scaleY);
	}
	
	private function set_width(Value:Int):Int
	{
		if (Value > 0)
		{
			width = Value; 
			#if flash
			if (_flashBitmap != null)
			{
				regen = (Value != buffer.width);
				_flashOffset.x = width * 0.5 * zoom;
				_flashBitmap.x = -width * 0.5;
			}
			#else
			if (canvas != null)
			{
				var rect:Rectangle = canvas.scrollRect;
				#if !js
				rect.width = Value;
				#else
				rect.width = Value * zoom;
				#end
				canvas.scrollRect = rect;
				
				_flashOffset.x = width * 0.5 * zoom;
				canvas.x = -width * 0.5;
				#if !FLX_NO_DEBUG
				debugLayer.x = canvas.x;
				#end
			}
			#end
		}
		return Value;
	}
	
	private function set_height(Value:Int):Int
	{
		if (Value > 0)
		{
			height = Value;
			#if flash
			if (_flashBitmap != null)
			{
				regen = (Value != buffer.height);
				_flashOffset.y = height * 0.5 * zoom;
				_flashBitmap.y = -height * 0.5;
			}
			#else
			if (canvas != null)
			{
				var rect:Rectangle = canvas.scrollRect;
				#if !js
				rect.height = Value;
				#else
				rect.height = Value * zoom;
				#end
				canvas.scrollRect = rect;
				
				_flashOffset.y = height * 0.5 * zoom;
				canvas.y = -height * 0.5;
				#if !FLX_NO_DEBUG
				debugLayer.y = canvas.y;
				#end
			}
			#end
		}
		return Value;
	}
	
	private function set_zoom(Zoom:Float):Float
	{
		if (Zoom == 0)
		{
			zoom = defaultZoom;
		}
		else
		{
			zoom = Zoom;
		}
		setScale(zoom, zoom);
		return zoom;
	}
	
	private function set_alpha(Alpha:Float):Float
	{
		alpha = FlxMath.bound(Alpha, 0, 1);
		#if flash
		_flashBitmap.alpha = Alpha;
		#else
		canvas.alpha = Alpha;
		#end
		return Alpha;
	}
	
	private function set_angle(Angle:Float):Float
	{
		angle = Angle;
		flashSprite.rotation = Angle;
		return Angle;
	}
	
	private function set_color(Color:Int):Int
	{
		color = Color & 0x00ffffff;
		#if flash
		if (_flashBitmap != null)
		{
			var colorTransform:ColorTransform = _flashBitmap.transform.colorTransform;
			colorTransform.redMultiplier = (color >> 16) / 255;
			colorTransform.greenMultiplier = (color >> 8 & 0xff) / 255;
			colorTransform.blueMultiplier = (color & 0xff) / 255;
			_flashBitmap.transform.colorTransform = colorTransform;
		}
		#else
		var colorTransform:ColorTransform = canvas.transform.colorTransform;
		colorTransform.redMultiplier = (color >> 16) / 255;
		colorTransform.greenMultiplier = (color >> 8 & 0xff) / 255;
		colorTransform.blueMultiplier = (color & 0xff) / 255;
		canvas.transform.colorTransform = colorTransform;
		#end
		
		return Color;
	}
	
	private function set_antialiasing(Antialiasing:Bool):Bool
	{
		antialiasing = Antialiasing;
		#if flash
		_flashBitmap.smoothing = Antialiasing;
		#end
		return Antialiasing;
	}
}