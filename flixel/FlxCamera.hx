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
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.util.loaders.CachedGraphics;
import Math;
import flash.utils.ByteArray;
import flash.Memory;

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
	static public inline var STYLE_LOCKON:Int = 0;
	/**
	 * Camera "follow" style preset: camera deadzone is narrow but tall.
	 */
	static public inline var STYLE_PLATFORMER:Int = 1;
	/**
	 * Camera "follow" style preset: camera deadzone is a medium-size square around the focus object.
	 */
	static public inline var STYLE_TOPDOWN:Int = 2;
	/**
	 * Camera "follow" style preset: camera deadzone is a small square around the focus object.
	 */
	static public inline var STYLE_TOPDOWN_TIGHT:Int = 3;
	/**
	 * Camera "follow" style preset: camera will move screenwise.
	 */
	static public inline var STYLE_SCREEN_BY_SCREEN:Int = 4;
	/**
	 * Camera "follow" style preset: camera has no deadzone, just tracks the focus object directly and centers it.
	 */
	static public inline var STYLE_NO_DEAD_ZONE:Int = 5;
	/**
	 * Camera "shake" effect preset: shake camera on both the X and Y axes.
	 */
	static public inline var SHAKE_BOTH_AXES:Int = 0;
	/**
	 * Camera "shake" effect preset: shake camera on the X axis only.
	 */
	static public inline var SHAKE_HORIZONTAL_ONLY:Int = 1;
	/**
	 * Camera "shake" effect preset: shake camera on the Y axis only.
	 */
	static public inline var SHAKE_VERTICAL_ONLY:Int = 2;
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
	public var width(default, set_width):Int;
	
	/**
	 * How tall the camera display is, in game pixels.
	 */
	public var height(default, set_height):Int;
	
	/**
	 * Tells the camera to use this following style.
	 */
	public var style:Int;
	
	/**
	 * Tells the camera to follow this <code>FlxObject</code> object around.
	 */
	public var target:FlxObject;
	
	/**
	 * Used to force the camera to look ahead of the <code>followTarget</code>.
	 */
	public var followLead:Point;
	
	/**
	 * Used to smoothly track the camera as it follows.
	 */
	public var followLerp:Float;
	
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
	
	#if flash
	/**
	 * The actual bitmap data of the camera display itself.
	 */
	public var buffer:BitmapData;
	
	public var regen:Bool = false;
	#end
	
	/**
	 * The natural background color of the camera. Defaults to FlxG.cameras.bgColor.
	 * NOTE: can be transparent for crazy FX!
	 */
	public var bgColor:Int;
	
	#if flash
	/**
	 * Sometimes it's easier to just work with a <code>FlxSprite</code> than it is to work
	 * directly with the <code>BitmapData</code> buffer.  This sprite reference will
	 * allow you to do exactly that.
	 */
	public var screen:FlxSprite;
	#end
	
	/**
	 * Internal, to help avoid costly allocations.
	 */
	private var _point:FlxPoint;
	
	#if flash
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashBitmap:Bitmap;
	#end
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
	 * Internal, for custom bitmap blending, ByteArray that stores the bytes of the blending bitmap.
	 */
	private var _fxCustomBmpBytes:ByteArray;
	/**
	 * Internal, for custom bitmap blending, ByteArray that stores:
		 * bytes of the current buffer  (0 -> _fxCustomBuffSize - 1)
		 * bytes of the blending bitmap (_fxCustomBuffSize -> _fxCustomBuffSize + _fxCustomBmpSize - 1)
	 */
	private var _fxCustomPixels:ByteArray;
	/**
	 * Internal, for custom bitmap blending, stores an integer corresponding to a predetermined blend mode, or zero for no blending.
	 */
	//TODO: change to read only
	public var fxCustomBlendMode:Int;
	/**
	 * Internal, for custom bitmap blending, stores size in bytes of custom bitmap pixel data.
	 */
	private var _fxCustomBmpSize:Int;
	/**
	 * Internal, for custom bitmap blending, dimensions of custom blending bitmap.
	 */
	private var _fxCustomBmpRect:Rectangle;
	/**
	 * Internal, for custom bitmap blending, stores size in bytes of camera display buffer pixel data.
	 */
	private var _fxCustomBuffSize:Int;
	
	private var _first:Bool = true;
	
	
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashColor:Int;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashDuration:Float;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashComplete:Void->Void;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashAlpha:Float;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeColor:Int;
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
	private var _fxFadeDuration:Float;
	/**
	 * Internal, used to control the "fade" special effect.
	 */
	private var _fxFadeComplete:Void->Void;
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
	private var _fxShakeComplete:Void->Void;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeOffset:FlxPoint;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeDirection:Int;
	
	#if flash
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 */
	private var _fill:BitmapData;
	#end
	
	#if !flash
	/**
	 * sprite for drawing (instead of _flashBitmap in flash)
	 */
	public var _canvas:Sprite;
	
	/**
	 * sprite for visual effects (flash and fade) and visual debug information (bounding boxes are drawn on it) for non-flash targets
	 */
	public var _debugLayer:Sprite;
	
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
	/*inline*/ public function getDrawStackItem(ObjGraphics:CachedGraphics, ObjColored:Bool, ObjBlending:Int, ObjAntialiasing:Bool = false):DrawStackItem
	#else
	/*inline*/ public function getDrawStackItem(ObjGraphics:CachedGraphics, UseAlpha:Bool, ObjAntialiasing:Bool = false):DrawStackItem
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
	
	/*inline*/ public function clearDrawStack():Void
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
	
	public function render():Void
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
				currItem.graphics.tilesheet.tileSheet.drawTiles(_canvas.graphics, data, (antialiasing || currItem.antialiasing), tempFlags);
				TileSheetExt._DRAWCALLS++;
			}
			currItem = currItem.next;
		}
	}
	#end
	
	/**
     * Internal, used to control the "fade" special effect.
     */
    private var _fxFadeIn:Bool;
	
	/**
	 * Instantiates a new camera at the specified location, with the specified size and zoom level.
	 * @param X			X location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param Y			Y location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param Width		The width of the camera display in pixels.
	 * @param Height	The height of the camera display in pixels.
	 * @param Zoom		The initial zoom level of the camera.  A zoom level of 2 will make all pixels display at 2x resolution.
	 */
	public function new(X:Int, Y:Int, Width:Int, Height:Int, Zoom:Float = 0)
	{
		super();
		
		_scrollTarget = new FlxPoint();
		
		x = X;
		y = Y;
		width = Width;
		height = Height;
		target = null;
		deadzone = null;
		scroll = new FlxPoint();
		_point = new FlxPoint();
		bounds = null;
		#if flash
		screen = new FlxSprite();
		buffer = new BitmapData(width, height, true, 0);
		screen.pixels = buffer;
		screen.setOriginToCorner();
		#end
		
		#if flash
		_flashBitmap = new Bitmap(buffer);
		_flashBitmap.x = -width * 0.5;
		_flashBitmap.y = -height * 0.5;
		#else
		_canvas = new Sprite();
		_canvas.x = -width * 0.5;
		_canvas.y = -height * 0.5;
		#end
		
		#if flash
		color = 0xffffff;
		#else
		color = FlxColor.WHITE;
		#end
		
		_flashSprite = new Sprite();
		zoom = Zoom; //sets the scale of flash sprite, which in turn loads flashoffset values
	
		_flashOffsetX = width * 0.5 * zoom;
		_flashOffsetY = height * 0.5 * zoom;
		
		_flashSprite.x = x + _flashOffsetX;
		_flashSprite.y = y + _flashOffsetY;
		
		#if flash
		_flashSprite.addChild(_flashBitmap);
		#else
		_flashSprite.addChild(_canvas);
		#end
		_flashRect = new Rectangle(0, 0, width, height);
		_flashPoint = new Point();
		
		// debug set to 1, live set to 0 ******************************************************
		// TODO: undo any debug changes
		fxCustomBlendMode = 0;
		_fxCustomBmpBytes = new ByteArray();
		_fxCustomPixels = new ByteArray();
		_fxCustomBmpSize = 0;
		rebuildBlendByteArrays();
			
		_fxFlashColor = FlxColor.TRANSPARENT;
		_fxFlashDuration = 0.0;
		_fxFlashComplete = null;
		_fxFlashAlpha = 0.0;
		
		_fxFadeColor = FlxColor.TRANSPARENT;
		_fxFadeDuration = 0.0;
		_fxFadeComplete = null;
		_fxFadeAlpha = 0.0;
		
		_fxShakeIntensity = 0.0;
		_fxShakeDuration = 0.0;
		_fxShakeComplete = null;
		_fxShakeOffset = new FlxPoint();
		_fxShakeDirection = 0;
		
		#if flash
		_fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		#else
		
		#if !js
		_canvas.scrollRect = new Rectangle(0, 0, width, height);
		#else
		_canvas.scrollRect = new Rectangle(0, 0, width * zoom, height * zoom);
		#end
		
		_debugLayer = new Sprite();
		_debugLayer.x = -width * 0.5;
		_debugLayer.y = -height * 0.5;
		_debugLayer.scaleX = 1;
		_flashSprite.addChild(_debugLayer);
		
		_currentStackItem = new DrawStackItem();
		_headOfDrawStack = _currentStackItem;
		#end
		
		bgColor = FlxG.cameras.bgColor;
		
		_fxFadeIn = false;
		
		alpha = 1.0;
		angle = 0.0;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		#if flash
		if (screen != null)
		{
			screen.destroy();
		}
		screen = null;
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
		_fxCustomBmpBytes.clear();
		_fxCustomBmpBytes = null;
		_fxCustomPixels.clear();
		_fxCustomPixels = null;
		_fxCustomBmpSize = 0;
		fxCustomBlendMode = 0;
		#if flash
		if (_fill != null)
		{
			_fill.dispose();
		}
		_fill = null;
		#else
		_flashSprite.removeChild(_debugLayer);
		_flashSprite.removeChild(_canvas);
		var canvasNumChildren:Int = _canvas.numChildren;
		for (i in 0...(canvasNumChildren))
		{
			_canvas.removeChildAt(0);
		}
		_debugLayer = null;
		_canvas = null;
		
		clearDrawStack();
		
		_headOfDrawStack.dispose();
		_headOfDrawStack = null;
		_currentStackItem = null;
		#end
		_flashSprite = null;
		
		super.destroy();
	}
	
	/**
	 * Updates the camera scroll as well as special effects like screen-shake or fades.
	 */
	override public function update():Void
	{
		if (FlxG.paused)	return;
		
		//Either follow the object closely, 
		//or doublecheck our deadzone and update accordingly.
		if(target != null)
		{
			if(deadzone == null)
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
					if (targetX > scroll.x + width)
					{
						_scrollTarget.x += width;
					}
					else if (targetX < scroll.x)
					{
						_scrollTarget.x -= width;
					}

					if (targetY > scroll.y + height)
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
					if(_scrollTarget.x > edge)
					{
						_scrollTarget.x = edge;
					} 
					edge = targetX + target.width - deadzone.x - deadzone.width;
					if(_scrollTarget.x < edge)
					{
						_scrollTarget.x = edge;
					}

					edge = targetY - deadzone.y;
					if(_scrollTarget.y > edge)
					{
						_scrollTarget.y = edge;
					}
					edge = targetY + target.height - deadzone.y - deadzone.height;
					if(_scrollTarget.y < edge)
					{
						_scrollTarget.y = edge;
					}
				}
				
				if((followLead != null) && (Std.is(target, FlxSprite)))
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
				} else 
				{
					scroll.x += (_scrollTarget.x - scroll.x) * FlxG.elapsed / (FlxG.elapsed + followLerp * FlxG.elapsed);
					scroll.y += (_scrollTarget.y - scroll.y) * FlxG.elapsed / (FlxG.elapsed + followLerp * FlxG.elapsed);	
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
			_fxFlashAlpha -= FlxG.elapsed / _fxFlashDuration;
			if ((_fxFlashAlpha <= 0) && (_fxFlashComplete != null))
			{
				_fxFlashComplete();
			}
		}
		
		//Update the "fade" special effect
		if((_fxFadeAlpha > 0.0) && (_fxFadeAlpha < 1.0))
		{
			if (_fxFadeIn)
			{
				_fxFadeAlpha -= FlxG.elapsed /_fxFadeDuration;
                if(_fxFadeAlpha <= 0.0)
                {
                    _fxFadeAlpha = 0.0;
                    if(_fxFadeComplete != null)
                    {
						_fxFadeComplete();
					}
                }
			}
			else
			{
				_fxFadeAlpha += FlxG.elapsed / _fxFadeDuration;
				if(_fxFadeAlpha >= 1.0)
				{
					_fxFadeAlpha = 1.0;
					if (_fxFadeComplete != null)
					{
						_fxFadeComplete();
					}
				}
			}
		}
		
		//Update the "shake" special effect
		if(_fxShakeDuration > 0)
		{
			_fxShakeDuration -= FlxG.elapsed;
			if(_fxShakeDuration <= 0)
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
				_flashSprite.x = x + _flashOffsetX;
				_flashSprite.y = y + _flashOffsetY;
			}
		}
	}
	
	/**
	 * Tells this camera object what <code>FlxObject</code> to track.
	 * @param	Target		The object you want the camera to track.  Set to null to not follow anything.
	 * @param	Style		Leverage one of the existing "deadzone" presets.  If you use a custom deadzone, ignore this parameter and manually specify the deadzone after calling <code>follow()</code>.
	 * @param  Offset    Offset the follow deadzone by a certain amount. Only applicable for STYLE_PLATFORMER and STYLE_LOCKON styles.
	 * @param	Lerp		How much lag the camera should have (can help smooth out the camera movement).
	 */
	public function follow(Target:FlxObject, Style:Int = 0/*STYLE_LOCKON*/, Offset:FlxPoint = null, Lerp:Float = 0):Void
	{
		style = Style;
		target = Target;
		followLerp = Lerp;
		var helper:Float;
		var w:Float = 0;
		var h:Float = 0;
		_lastTargetPosition = null;
		switch(Style)
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
	 * Specify an additional camera component - the velocity-based "lead",
	 * or amount the camera should track in front of a sprite.
	 * 
	 * @param	LeadX		Percentage of X velocity to add to the camera's motion.
	 * @param	LeadY		Percentage of Y velocity to add to the camera's motion.
	 */
    public function followAdjust(LeadX:Float = 0, LeadY:Float = 0):Void
    {
	   followLead = new Point(LeadX,LeadY);
    }
	
	/**
	 * Move the camera focus to this location instantly.
	 * @param	Point		Where you want the camera to focus.
	 */
	public function focusOn(point:FlxPoint):Void
	{
		scroll.set(point.x - width * 0.5, point.y - height * 0.5);
	}
	
	/**
	 * Specify the boundaries of the level or where the camera is allowed to move.
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
	
	/**
	 * Blend a bitmap image with the camera display.
	 * @param	bmp         The bitmap image to blend with the camera's buffer.
	 * @param	blendMode   Which of the available blending modes to use.
	 * @param	?targetRect	(To be implemented.) The region of the cameras FOV to apply the blend to (defaults to entire buffer).
	 */
	public function blend( bmp:BitmapData, blendMode:Int, ?targetRect:Rectangle ):Void
	{
		_fxCustomBmpSize = bmp.width * bmp.height * 4;
		_fxCustomBmpRect = bmp.rect;
		
		// write pizels to bytearray
		_fxCustomBmpBytes = bmp.getPixels(_fxCustomBmpRect);
		
		//FlxG.log.add(fxCustomBlendMode, _fxCustomBmpSize, _fxCustomBmpRect, _fxCustomBmpBytes.length );
		
		fxCustomBlendMode = blendMode;
		rebuildBlendByteArrays();
	}

	/**
	 * Stop any bitmap blending that may be active.
	 */
	public function stopBlend():Void
	{
		fxCustomBlendMode = _fxCustomBmpSize = 0;
		_fxCustomBmpBytes.clear();
	}
	
	/**
	 * Rebuild the byte array(s) used by custom bitmap bitmap blending.
	 */
	//TODO: making assumption that if I call this at the end of the set_width and set_height functions 
	//      the buffer will have been resized already by super cal or something. Need to verify.
	private function rebuildBlendByteArrays():Void
	{
		_fxCustomBuffSize = buffer.width * buffer.height * 4; // 32bits integer = 4 bytes
		//flixel.FlxG.log.add("size buff, bmp: ", _fxCustomBuffSize, _fxCustomBmpSize);
		// Set the virtual memory space we'll use
		// CPP does not support setting the length property directly
		var newlength:Int = _fxCustomBuffSize + _fxCustomBmpSize;
		#if (cpp) _fxCustomPixels.setLength(newlength);
		#else _fxCustomPixels.length = newlength; #end
		// if we are blending rewrite the pixel data into correct place
		if (fxCustomBlendMode > 0) {
			_fxCustomPixels.position = _fxCustomBuffSize;
			_fxCustomPixels.writeBytes(_fxCustomBmpBytes);
		}
		//flixel.FlxG.log.add("length buffer: ", _fxCustomPixels.length);
		// (re)Select the memory space
			Memory.select(_fxCustomPixels);
	}
	
	/**
	 * The screen is filled with this color and gradually returns to normal.
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function flash(Color:Int = 0xffffffff, Duration:Float = 1, OnComplete:Void->Void = null, Force:Bool = false):Void
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
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the fade to finish.
	 * @param   FadeIn      True fades from a color, false fades to it.
	 * @param	OnComplete	A function you want to run when the fade finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function fade(Color:Int = 0xff000000, Duration:Float = 1, FadeIn:Bool = false, OnComplete:Void->Void = null, Force:Bool = false):Void
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
	 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * @param	Duration	The length in seconds that the shaking effect should last.
	 * @param	OnComplete	A function you want to run when the shake effect finishes.
	 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
	 * @param	Direction	Whether to shake on both axes, just up and down, or just side to side (use class constants SHAKE_BOTH_AXES, SHAKE_VERTICAL_ONLY, or SHAKE_HORIZONTAL_ONLY).
	 */
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, OnComplete:Void->Void = null, Force:Bool = true, Direction:Int = 0/*SHAKE_BOTH_AXES*/):Void
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
		fxCustomBlendMode = 0;
		_flashSprite.x = x + _flashOffsetX;
		_flashSprite.y = y + _flashOffsetY;
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
	
	public var zoom(default, set_zoom):Float;
	
	/**
	 * The zoom level of this camera. 1 = 1:1, 2 = 2x zoom, etc.
	 * Indicates how far the camera is zoomed in.
	 */
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
	
	/**
	 * The alpha value of this camera display (a Number between 0.0 and 1.0).
	 */
	public var alpha(default, set_alpha):Float;
	
	/**
	 * @private
	 */
	private function set_alpha(Alpha:Float):Float
	{
		alpha = FlxMath.bound(Alpha, 0, 1);
		#if flash
		_flashBitmap.alpha = Alpha;
		#else
		_canvas.alpha = Alpha;
		#end
		return Alpha;
	}
	
	/**
	 * The angle of the camera display (in degrees).
	 * Currently yields weird display results,
	 * since cameras aren't nested in an extra display object yet.
	 */
	public var angle(default, set_angle):Float;
	
	private function set_angle(Angle:Float):Float
	{
		angle = Angle;
		_flashSprite.rotation = Angle;
		return Angle;
	}
	
	/**
	 * The color tint of the camera display.
	 * (Internal, help with color transforming the flash bitmap.)
	 */
	public var color(default, set_color):Int;
	
	/**
	 * @private
	 */
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
		var colorTransform:ColorTransform = _canvas.transform.colorTransform;
		colorTransform.redMultiplier = (color >> 16) / 255;
		colorTransform.greenMultiplier = (color >> 8 & 0xff) / 255;
		colorTransform.blueMultiplier = (color & 0xff) / 255;
		_canvas.transform.colorTransform = colorTransform;
		#end
		
		return Color;
	}
	
	/**
	 * Whether the camera display is smooth and filtered, or chunky and pixelated.
	 * Default behavior is chunky-style.
	 */
	public var antialiasing(default, set_antialiasing):Bool = false;
	
	/**
	 * @private
	 */
	private function set_antialiasing(Antialiasing:Bool):Bool
	{
		antialiasing = Antialiasing;
		#if flash
		_flashBitmap.smoothing = Antialiasing;
		#end
		return Antialiasing;
	}
	
	/**
	 * The scale of the camera object, irrespective of zoom.
	 * Currently yields weird display results,
	 * since cameras aren't nested in an extra display object yet.
	 */
	public function getScale():FlxPoint
	{
		return _point.set(_flashSprite.scaleX, _flashSprite.scaleY);
	}
	
	/**
	 * @private
	 */
	public function setScale(X:Float, Y:Float):Void
	{
		_flashSprite.scaleX = X;
		_flashSprite.scaleY = Y;
		
		//camera positioning fix from bomski (https://github.com/Beeblerox/HaxeFlixel/issues/66)
		_flashOffsetX = width * 0.5 * X;
		_flashOffsetY = height * 0.5 * Y;	
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
	public function fill(Color:Int, BlendAlpha:Bool = true, FxAlpha:Float = 1.0, graphics:Graphics = null):Void
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
		var targetGraphics:Graphics = (graphics == null) ? _canvas.graphics : graphics;
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
	//TODO: inline help perf at all?
	public function drawFX():Void
	{
		//For flash and fade fx
		var alphaComponent:Float;
		
		//For later restriction of blend effect: change source of rect (to be implemented)
		var bufferRect:Rectangle = buffer.rect;
		var bufferWidth:Int = buffer.width;
		var pixbuf:Int;
		var a:Int;
		var r:Int;
		var g:Int;
		var b:Int;
		var pixbmp:Int;
		var abmp:Int;
		var rbmp:Int;
		var gbmp:Int;
		var bbmp:Int;
		var rres:Int;
		var gres:Int;
		var bres:Int;
			
		//Process custom effect from bitmap onto the buffer
		//based in part on http://stackoverflow.com/questions/10157787/haxe-nme-fastest-method-for-per-pixel-bitmap-manipulation
			//TODO: allow multiple blend modes
			//not sure about the following:
			//TODO: allow for source and target rectangles, so we could modify to apply only part of source bitmap to only part of camera field - may not be all that useful, since you can use multiple cameras instead
			//TODO: then allow for multiple effects per camera, each with their own bmp, source rect, target rect, blend mode - may not be acceptable performance-wise
		if(fxCustomBlendMode > 0 )
		{
			var bufferZoneWidth:Int = Std.int(Math.min(buffer.width, _fxCustomBmpRect.width));
			var bufferZoneHeight:Int = Std.int(Math.min(buffer.height, _fxCustomBmpRect.height));
			var bmpWidth:Int = Std.int(_fxCustomBmpRect.width);
			
			// write buffer to bytearray -> this needs to happen in drawFX
			_fxCustomPixels.position = 0;
			_fxCustomPixels.writeBytes( buffer.getPixels(bufferRect) ); // changed from assign, not sure if that's going to work.
			
			// select blend operation and process buffer, needs to be outside loops for efficiency
			switch( fxCustomBlendMode )
			{
				// Multiply
				case 1:
					
					// for each pixel in bmp that has a corresponding pixel in buffer
					for ( y in 0...bufferZoneHeight)
					{
						for ( x in 0...bufferZoneWidth)
						{
							// Color is in BGRA mode, nme.Memory can only be used in little endian mode.
							// If testing with FlxColor or 0x.... will need to switch order of bytes pulled for color channels
							
							// get buffer vals
							pixbuf = Memory.getI32((y * bufferWidth + x) * 4);
							a = pixbuf & 0xFF; // keep buffer opacity
							
							// no point multiplying a transparent pixel, it will still be transparent
							if (a == 0) continue;
							
							r = pixbuf >>>  8 & 0xFF;
							g = pixbuf >>> 16 & 0xFF;
							b = pixbuf >>> 24 & 0xFF;
							
							// no point multiplying black, it can't get any darker
							// TODO: which is the more efficient?
							//if (r == 0 && g == 0 && b == 0) continue;
							if (r + g + b == 0) continue;
							
							// get bmp vals
							pixbmp = Memory.getI32((y * bmpWidth + x) * 4 + _fxCustomBuffSize);
							abmp = pixbmp & 0xFF; // keep buffer opacity
							
							// no point multiplying with a transparent pixel, it won't change anything
							if (abmp == 0) continue;
								
							rbmp = pixbmp >>>  8 & 0xFF;
							gbmp = pixbmp >>> 16 & 0xFF;
							bbmp = pixbmp >>> 24 & 0xFF;
							
							// no point multiplying with white, it won't change anything -> this is only useful if you might have white in your bmp
							// maybe have optimization flags you can set? That's getting pretty specific for core functionality though.
							// TODO: which is the more efficient?
							//if (rbmp == 255 && gbmp == 255 && bbmp == 255) continue;
							if (rbmp + gbmp + bbmp == 765) continue;
							
							// create full blend color, multiply, then divide (approximated, /256 not /255)
							rbmp *= r;
							rbmp >>= 8;
							gbmp *= g;
							gbmp >>= 8;
							bbmp *= b;
							bbmp >>= 8;
							
							// get original color component based on "1 - strength" of bmp alpha
							rres = (255 - abmp) * r;
							rres >>= 8;
							gres = (255 - abmp) * g;
							gres >>= 8;
							bres = (255 - abmp) * b;
							bres >>= 8;
							// get blend color component based on strength of bmp alpha
							rbmp = abmp * rbmp;
							rbmp >>= 8;
							gbmp = abmp * gbmp;
							gbmp >>= 8;
							bbmp = abmp * bbmp;
							bbmp >>= 8;
							// add together to get "true" result
							rres += rbmp + 1;
							gres += gbmp + 1;
							bres += bbmp + 1;
							
							// set combined result color using alpha of original source
							Memory.setI32((y * bufferWidth + x) * 4, a | rres << 8 | gres << 16 | (bres & 0xFF) << 24);
						}
					}
			}
			// output the blended pixels back into the buffer
			_fxCustomPixels.position = 0;
			buffer.setPixels(bufferRect, _fxCustomPixels);
		}
		
		//Draw the "flash" special effect onto the buffer
		if(_fxFlashAlpha > 0.0)
		{
			alphaComponent = (_fxFlashColor >> 24) & 255;
			
			#if flash
			fill((Std.int(((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha) << 24) + (_fxFlashColor & 0x00ffffff));
			#else
			fill((_fxFlashColor & 0x00ffffff), true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha / 255, _canvas.graphics);
			#end
		}
		
		//Draw the "fade" special effect onto the buffer
		if(_fxFadeAlpha > 0.0)
		{
			alphaComponent = (_fxFadeColor >> 24) & 255;
			
			#if flash
			fill((Std.int(((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha) << 24) + (_fxFadeColor & 0x00ffffff));
			#else
			fill((_fxFadeColor & 0x00ffffff), true, ((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha / 255, _canvas.graphics);
			#end
		}
		
		if((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0))
		{
			_flashSprite.x += _fxShakeOffset.x;
			_flashSprite.y += _fxShakeOffset.y;
		}
	}
	
	private function set_width(val:Int):Int
	{
		if (val > 0)
		{
			width = val; 
			#if flash
			if ( _flashBitmap != null )
			{
				regen = (val != buffer.width);
				_flashOffsetX = width * 0.5 * zoom;
				_flashBitmap.x = -width * 0.5;
			}
			#else
			if (_canvas != null)
			{
				var rect:Rectangle = _canvas.scrollRect;
				#if !js
				rect.width = val;
				#else
				rect.width = val * zoom;
				#end
				_canvas.scrollRect = rect;
				
				_flashOffsetX = width * 0.5 * zoom;
				_debugLayer.x = _canvas.x = -width * 0.5;
			}
			#end
		}
		if( fxCustomBlendMode > 0) rebuildBlendByteArrays();
		return val;
	}
	
	private function set_height(val:Int):Int
	{
		if (val > 0)
		{
			height = val;
			#if flash
			if (_flashBitmap != null)
			{
				regen = (val != buffer.height);
				_flashOffsetY = height * 0.5 * zoom;
				_flashBitmap.y = -height * 0.5;
			}
			#else
			if (_canvas != null)
			{
				var rect:Rectangle = _canvas.scrollRect;
				#if !js
				rect.height = val;
				#else
				rect.height = val * zoom;
				#end
				_canvas.scrollRect = rect;
				
				_flashOffsetY = height * 0.5 * zoom;
				_debugLayer.y = _canvas.y = -height * 0.5;
			}
			#end
		}
		if( fxCustomBlendMode > 0) rebuildBlendByteArrays();
		return val;
	}
	
	/**
	 * Whether to use alpha blending for camera's background fill or not. 
	 * Useful for flash target (and works only on this target). Default value is true.
	 */
	@:isVar public var useBgAlphaBlending(default, set_useBgAlphaBlending):Bool = true;
	
	private function set_useBgAlphaBlending(value:Bool):Bool
	{
		useBgAlphaBlending = value;
		return value;
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
				screen.setOriginToCorner();
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
	 * @param	Width	The new sprite width.
	 * @param	Height	The new sprite height.
	 */
	inline public function setSize(Width:Int, Height:Int)
	{
		width = Width;
		height = Height;
	}
}