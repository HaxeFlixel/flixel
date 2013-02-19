package org.flixel;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Tilesheet;
import nme.geom.ColorTransform;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.DrawStackItem;
import org.flixel.system.layer.TileSheetData;

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
	#end
	
	/**
	 * The natural background color of the camera. Defaults to FlxG.bgColor.
	 * NOTE: can be transparent for crazy FX!
	 */
	#if flash
	public var bgColor:UInt;
	#else
	public var bgColor:BitmapInt32;
	#end
	
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
	 * Internal, used to control the "flash" special effect.
	 */
	#if flash
	private var _fxFlashColor:UInt;
	#else
	private var _fxFlashColor:BitmapInt32;
	#end
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
	#if flash
	private var _fxFadeColor:UInt;
	#else
	private var _fxFadeColor:BitmapInt32;
	#end
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
	public var _effectsLayer:Sprite;
	
	public var red:Float;
	public var green:Float;
	public var blue:Float;
	
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
	inline public function getDrawStackItem(ObjAtlas:Atlas, ObjColored:Bool, ObjBlending:Int):DrawStackItem
	#else
	inline public function getDrawStackItem(ObjAtlas:Atlas, UseAlpha:Bool):DrawStackItem
	#end
	{
		var itemToReturn:DrawStackItem = null;
		if (_currentStackItem.initialized == false)
		{
			_headOfDrawStack = _currentStackItem;
			_currentStackItem.atlas = ObjAtlas;
			#if !js
			_currentStackItem.colored = ObjColored;
			_currentStackItem.blending = ObjBlending;
			#else
			_currentStackItem.useAlpha = UseAlpha;
			#end
			itemToReturn = _currentStackItem;
		}
		#if !js
		else if (_currentStackItem.atlas == ObjAtlas && _currentStackItem.colored == ObjColored && _currentStackItem.blending == ObjBlending)
		#else
		else if (_currentStackItem.atlas == ObjAtlas && _currentStackItem.useAlpha == UseAlpha)
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
			
			newItem.atlas = ObjAtlas;
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
	
	inline public function clearDrawStack():Void
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
		#if !js
		var useColor:Bool = this.isColored();
		#end
		while (currItem != null)
		{
			var data:Array<Float> = currItem.drawData;
			var dataLen:Int = data.length;
			var position:Int = currItem.position;
			if (position > 0)
			{
				if (dataLen != position)
				{
					data.splice(position, (dataLen - position));
				}
				var tempFlags:Int = Graphics.TILE_TRANS_2x2;
				#if !js
				tempFlags |= Graphics.TILE_ALPHA;
				if (currItem.colored || useColor)
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
				// TODO: currItem.antialiasing
				currItem.atlas._tileSheetData.tileSheet.drawTiles(this._canvas.graphics, data, (this.antialiasing/* || currItem.antialiasing*/), tempFlags);
				TileSheetData._DRAWCALLS++;
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
		screen.makeGraphic(width, height, 0, true);
		screen.setOriginToCorner();
		buffer = screen.pixels;
		#end
		bgColor = FlxG.bgColor;
		
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
		color = FlxG.WHITE;
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
		
		_fxFlashColor = FlxG.TRANSPARENT;
		_fxFlashDuration = 0.0;
		_fxFlashComplete = null;
		_fxFlashAlpha = 0.0;
		
		_fxFadeColor = FlxG.TRANSPARENT;
		_fxFadeDuration = 0.0;
		_fxFadeComplete = null;
		_fxFadeAlpha = 0.0;
		
		_fxShakeIntensity = 0.0;
		_fxShakeDuration = 0.0;
		_fxShakeComplete = null;
		_fxShakeOffset = new FlxPoint();
		_fxShakeDirection = 0;
		
		#if flash
		_fill = new BitmapData(width, height, true, FlxG.TRANSPARENT);
		#else
		_canvas.scrollRect = new Rectangle(0, 0, width, height);
		
		_effectsLayer = new Sprite();
		_effectsLayer.x = -width * 0.5;
		_effectsLayer.y = -height * 0.5;
		_flashSprite.addChild(_effectsLayer);
		
		red = 1.0;
		green = 1.0;
		blue = 1.0;
		
		fog = 0.0;
		
		_currentStackItem = new DrawStackItem();
		_headOfDrawStack = _currentStackItem;
		#end
		
		_fxFadeIn = false;
		
		alpha = 1.0;
		angle = 0.0;
		antialiasing = false;

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
		#if flash
		if (_fill != null)
		{
			_fill.dispose();
		}
		_fill = null;
		#else
		_flashSprite.removeChild(_effectsLayer);
		_flashSprite.removeChild(_canvas);
		var canvasNumChildren:Int = _canvas.numChildren;
		for (i in 0...(canvasNumChildren))
		{
			_canvas.removeChildAt(0);
		}
		_effectsLayer = null;
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
		
		#if !(flash || js)
		scroll.x = Math.floor(scroll.x * 100) / 100;
		scroll.y = Math.floor(scroll.y * 100) / 100;
		#end		
		
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
					_fxShakeOffset.x = (FlxG.random() * _fxShakeIntensity * width * 2 - _fxShakeIntensity * width) * zoom;
				}
				if ((_fxShakeDirection == SHAKE_BOTH_AXES) || (_fxShakeDirection == SHAKE_VERTICAL_ONLY))
				{
					_fxShakeOffset.y = (FlxG.random() * _fxShakeIntensity * height * 2 - _fxShakeIntensity * height) * zoom;
				}
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
				helper = FlxU.max(width, height) / 4;
				deadzone = new FlxRect((width - helper) / 2, (height - helper) / 2, helper, helper);
			case STYLE_TOPDOWN_TIGHT:
				helper = FlxU.max(width, height) / 8;
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
		scroll.make(point.x - width * 0.5, point.y - height * 0.5);
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
		bounds.make(X, Y, Width, Height);
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
	#if flash
	public function flash(?Color:UInt = 0xffffffff, Duration:Float = 1, OnComplete:Void->Void = null, Force:Bool = false):Void
	#else
	public function flash(?Color:BitmapInt32, Duration:Float = 1, OnComplete:Void->Void = null, Force:Bool = false):Void
	#end
	{
		#if !flash
		if (Color == null)
		{
			Color = FlxG.WHITE;
		}
		#end
		
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
	 * @param   FadeIn      True fades from a color, false fades to it.
	 * @param	OnComplete	A function you want to run when the fade finishes.
	 * @param	Force		Force the effect to reset.
	 */
	#if flash
	public function fade(?Color:UInt = 0xff000000, Duration:Float = 1, FadeIn:Bool = false, OnComplete:Void->Void = null, Force:Bool = false):Void
	#else
	public function fade(?Color:BitmapInt32, Duration:Float = 1, FadeIn:Bool = false, OnComplete:Void->Void = null, Force:Bool = false):Void
	#end
	{
		#if !flash
		if (Color == null)
		{
			Color = FlxG.BLACK;
		}
		#end
		
		if (!Force && (_fxFadeAlpha > 0.0))
		{
			return;
		}
		_fxFadeColor = Color;
		if (Duration <= 0)
		{
			Duration = FlxU.MIN_VALUE;
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
			_fxFadeAlpha = FlxU.MIN_VALUE;
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
		alpha = FlxU.bound(Alpha, 0, 1);
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
	#if flash
	public var color(default, set_color):UInt;
	#else
	public var color(default, set_color):BitmapInt32;
	#end
	
	/**
	 * @private
	 */
	#if flash
	private function set_color(Color:UInt):UInt
	#else
	private function set_color(Color:BitmapInt32):BitmapInt32
	#end
	{
		color = Color;
		#if flash
		if (_flashBitmap != null)
		{
			var colorTransform:ColorTransform = _flashBitmap.transform.colorTransform;
			colorTransform.redMultiplier = (color >> 16) / 255;
			colorTransform.greenMultiplier = (color >> 8 & 0xff) / 255;
			colorTransform.blueMultiplier = (color & 0xff) / 255;
			_flashBitmap.transform.colorTransform = colorTransform;
		}
		#elseif (cpp || js)
		//var colorTransform:ColorTransform = _canvas.transform.colorTransform;
		//_canvas.transform.colorTransform = colorTransform;
		red = (color >> 16) / 255;
		green = (color >> 8 & 0xff) / 255;
		blue = (color & 0xff) / 255;
		#elseif neko
		red = (color.rgb >> 16) / 255;
		green = (color.rgb >> 8 & 0xff) / 255;
		blue = (color.rgb & 0xff) / 255;
		#end
		
		return Color;
	}
	
	/**
	 * Whether the camera display is smooth and filtered, or chunky and pixelated.
	 * Default behavior is chunky-style.
	 */
	public var antialiasing(default, set_antialiasing):Bool;
	
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
		return _point.make(_flashSprite.scaleX, _flashSprite.scaleY);
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
	#if flash
	public function fill(Color:UInt, BlendAlpha:Bool = true):Void
	#else
	public function fill(Color:BitmapInt32, BlendAlpha:Bool = true, FxAlpha:Float = 1.0, graphics:Graphics = null):Void
	#end
	{
	#if flash
		_fill.fillRect(_flashRect, Color);
		buffer.copyPixels(_fill, _flashRect, _flashPoint, null, null, BlendAlpha);
	#else
		
		// This is temporal fix for camera's color
		var targetGraphics:Graphics = (graphics == null) ? _canvas.graphics : graphics;
		
		#if !neko
		Color = Color & 0x00ffffff;
		if (red != 1.0 || green != 1.0 || blue != 1.0)
		{
			var redComponent:Int = Std.int((Color >> 16) * red);
			var greenComponent:Int = Std.int((Color >> 8 & 0xff) * green);
			var blueComponent:Int = Std.int((Color & 0xff) * blue);
			Color = redComponent << 16 | greenComponent << 8 | blueComponent;
		}
		// end of fix
		
		targetGraphics.beginFill(Color, FxAlpha);
		#else
		if (red != 1.0 || green != 1.0 || blue != 1.0)
		{
			var redComponent:Int = Std.int((Color.rgb >> 16) * red);
			var greenComponent:Int = Std.int((Color.rgb >> 8 & 0xff) * green);
			var blueComponent:Int = Std.int((Color.rgb & 0xff) * blue);
			Color.rgb = redComponent << 16 | greenComponent << 8 | blueComponent;
		}
		
		targetGraphics.beginFill(Color.rgb, FxAlpha);
		#end
		
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
		if(_fxFlashAlpha > 0.0)
		{
			#if neko
			alphaComponent = _fxFlashColor.a;
			#else
			alphaComponent = (_fxFlashColor >> 24) & 255;
			#end
			
			#if flash
			fill((Std.int(((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha) << 24) + (_fxFlashColor & 0x00ffffff));
			#elseif !neko
			fill((_fxFlashColor & 0x00ffffff), true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha / 255, _effectsLayer.graphics);
			#else
			fill(_fxFlashColor, true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha / 255, _effectsLayer.graphics);
			#end
		}
		
		//Draw the "fade" special effect onto the buffer
		if(_fxFadeAlpha > 0.0)
		{
			#if neko
			alphaComponent = _fxFadeColor.a;
			#else
			alphaComponent = (_fxFadeColor >> 24) & 255;
			#end
			
			#if flash
			fill((Std.int(((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha) << 24) + (_fxFadeColor & 0x00ffffff));
			#elseif !neko
			fill((_fxFadeColor & 0x00ffffff), true, ((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha / 255, _effectsLayer.graphics);
			#else
			fill(_fxFadeColor, true, ((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha / 255, _effectsLayer.graphics);
			#end
		}
		
		if((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0))
		{
			_flashSprite.x += _fxShakeOffset.x;
			_flashSprite.y += _fxShakeOffset.y;
		}
		
		#if !flash
		if (fog > 0)
		{
			_effectsLayer.graphics.beginFill(0xffffff, fog);
			_effectsLayer.graphics.drawRect(0, 0, width, height);
			_effectsLayer.graphics.endFill();
		}
		#end
	}
	
	#if !flash
	public var fog(default, default):Float;
	#end
	
	#if !(flash || js)
	inline public function isColored():Bool
	{
		#if neko
		return (color.rgb < 0xffffff);
		#else
		return (color < 0xffffff);
		#end
	}
	#end
	
	private function set_width(val:Int):Int
	{
		if (val > 0)
		{
			width = val;
			#if flash
			if ( _flashBitmap != null )
			{
				_flashOffsetX = width * 0.5 * zoom;
				_flashBitmap.x = -width * 0.5;
			}
			#else
			if (_canvas != null)
			{
				var rect:Rectangle = _canvas.scrollRect;
				rect.width = val;
				_canvas.scrollRect = rect;
				
				_flashOffsetX = width * 0.5 * zoom;
				_effectsLayer.x = _canvas.x = -width * 0.5;
			}
			#end
		}
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
				_flashOffsetY = height * 0.5 * zoom;
				_flashBitmap.y = -height * 0.5;
			}
			#else
			if (_canvas != null)
			{
				var rect:Rectangle = _canvas.scrollRect;
				rect.height = val;
				_canvas.scrollRect = rect;
				
				_flashOffsetY = height * 0.5 * zoom;
				_effectsLayer.y = _canvas.y = -height * 0.5;
			}
			#end
		}
		return val;
	}
}