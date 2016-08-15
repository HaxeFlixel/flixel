package flixel;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.blit.FlxBlitView;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;

typedef HardwareView = #if (openfl >= "4.0.0") flixel.system.render.gl.FlxGlView #else flixel.system.render.tile.FlxTilesheetView #end;

/**
 * The camera class is used to display the game's visuals.
 * By default one camera is created automatically, that is the same size as window.
 * You can add more cameras or even replace the main camera using utilities in FlxG.cameras.
 * 
 * Every camera has following display list:
 * flashSprite:Sprite (which is a container for everything else in the camera, it's added to FlxG.game sprite)
 * 		|->_scrollRect:Sprite (which is used for cropping camera's graphic, mostly in tile render mode)
 * 				|->	_flashBitmap:Bitmap	(its bitmapData property is buffer BitmapData, this var is used in blit render mode. Everything is rendered on buffer in blit render mode)
 * 				|->	canvas:Sprite		(its graphics is used for rendering objects in tile render mode)
 * 				|-> debugLayer:Sprite	(this sprite is used in tile render mode for rendering debug info, like bounding boxes)
 */
class FlxCamera extends FlxBasic
{
	/**
	 * While you can alter the zoom of each camera after the fact,
	 * this variable determines what value the camera will start at when created.
	 */
	public static var defaultZoom:Float;
	/**
	 * Which cameras a FlxBasic uses to be drawn on when nothing else has been specified. 
	 * By default, this is just a reference to FlxG.cameras.list / all cameras, but it can be very useful to change.
	 */
	public static var defaultCameras:Array<FlxCamera>;
	
	/**
	 * The X position of this camera's display (used for positioning flashSprite of this camera). Zoom does NOT affect this number.
	 * Measured in pixels from the left side of the flash window.
	 * You might be interested in using camera's scroll.x instead.
	 */
	public var x(default, set):Float = 0;
	/**
	 * The Y position of this camera's display (used for positioning flashSprite of this camera). Zoom does NOT affect this number.
	 * Measured in pixels from the top of the flash window.
	 * You might be interested in using camera's scroll.y instead.
	 */
	public var y(default, set):Float = 0;
	
	/**
	 * The scaling on horizontal axis for this camera.
	 * Setting scaleX changes scaleX and x coordinate of camera's internal display objects (_flashBitmap, canvas and debugSprite).
	 */
	public var scaleX(default, null):Float;
	/**
	 * The scaling on vertical axis for this camera.
	 * Setting scaleY changes scaleY and y coordinate of camera's internal display objects (_flashBitmap, canvas and debugSprite).
	 */
	public var scaleY(default, null):Float;
	/**
	 * Product of camera's scaleX and game's scalemode scale.x multiplication.
	 * Added this var for less calculations at rendering time (in tile render mode).
	 */
	public var totalScaleX(default, null):Float;
	/**
	 * Product of camera's scaleY and game's scalemode scale.y multiplication.
	 * Added this var for less calculations at rendering time (in tile render mode).
	 */
	public var totalScaleY(default, null):Float;
	
	/**
	 * Tells the camera to use this following style.
	 */
	public var style:FlxCameraFollowStyle;
	/**
	 * Tells the camera to follow this FlxObject object around.
	 */
	public var target:FlxObject;
	/**
	 * Offset the camera target
	 */
	public var targetOffset(default, null):FlxPoint = FlxPoint.get();
	/**
	 * Used to smoothly track the camera as it follows: The percent of the distance to the follow target the camera moves per 1/60 sec.
	 * Values are bounded between 0.0 and FlxG.updateFrameRate / 60 for consistency across framerates.
	 * The maximum value means no camera easing. A value of 0 means the camera does not move.
	 */
	public var followLerp(default, set):Float = 60 / FlxG.updateFramerate;
	/**
	 * You can assign a "dead zone" to the camera in order to better control its movement.
	 * The camera will always keep the focus object inside the dead zone, unless it is bumping up against 
	 * the camera bounds. The deadzone's coordinates are measured from the camera's upper left corner in game pixels.
	 * For rapid prototyping, you can use the preset deadzones (e.g. PLATFORMER) with follow().
	 */
	public var deadzone:FlxRect;
	/**
	 * Lower bound of the cameras scroll on the x axis
	 */
	public var minScrollX:Null<Float>;
	/**
	 * Upper bound of the cameras scroll on the x axis
	 */
	public var maxScrollX:Null<Float>;
	/**
	 * Lower bound of the cameras scroll on the y axis
	 */
	public var minScrollY:Null<Float>;
	/**
	 * Upper bound of the cameras scroll on the y axis
	 */
	public var maxScrollY:Null<Float>;
	/**
	 * Stores the basic parallax scrolling values.
	 * This is basically camera's top-left corner position in world coordinates.
	 * There is also useful method `focusOn(point:FlxPoint)` which you can use to make camera look at specified point in world coordinates.
	 */
	public var scroll:FlxPoint = FlxPoint.get();
	
	/**
	 * The natural background color of the camera, in AARRGGBB format. Defaults to FlxG.cameras.bgColor.
	 * On flash, transparent backgrounds can be used in conjunction with useBgAlphaBlending.
	 */ 
	public var bgColor:FlxColor;
	
	/**
	 * Whether to use alpha blending for camera's background fill or not.
	 * If true then previosly drawn graphics won't be erased,
	 * and if camera's bgColor is transparent/semitransparent then you will be able to see graphics of the previous frame.
	 * Useful for blit render mode (and works only in this mode). Default value is false.
	 * 
	 * Usage example can be seen in FlxBloom demo:
	 * @see http://haxeflixel.com/demos/FlxBloom/
	 */
	public var useBgAlphaBlending:Bool = false;
	
	// TODO: use this and document this...
	/**
	 * 
	 */
	public var view:FlxCameraView;

	/**
	 * Whether the positions of the objects rendered on this camera are rounded.
	 * If set on individual objects, they ignore the global camera setting.
	 * Defaults to false with FlxG.renderTile and to true with FlxG.renderBlit.
	 * WARNING: setting this to false on blitting targets is very expensive.
	 */
	public var pixelPerfectRender:Bool;
	
	/**
	 * How wide the camera display is, in game pixels.
	 */
	public var width(default, set):Int = 0;
	/**
	 * How tall the camera display is, in game pixels.
	 */
	public var height(default, set):Int = 0;
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
	public var color(default, set):FlxColor = FlxColor.WHITE;
	/**
	 * Whether the camera display is smooth and filtered, or chunky and pixelated.
	 * Default behavior is chunky-style.
	 */
	public var antialiasing(default, set):Bool = false;
	/**
	 * Used to force the camera to look ahead of the target.
	 */
	public var followLead(default, null):FlxPoint = FlxPoint.get();
	/**
	 * Enables or disables the filters set via setFilters()
	 */
	public var filtersEnabled:Bool = true;
	
	/**
	 * Internal, represents the color of "flash" special effect.
	 * Set by flash() method.
	 */
	private var _fxFlashColor:FlxColor = FlxColor.TRANSPARENT;
	/**
	 * Internal, stores "flash" special effect duration.
	 * Set by flash() method.
	 */
	private var _fxFlashDuration:Float = 0;
	/**
	 * Internal, camera's "flash" complete callback.
	 * Set by flash() method.
	 */
	private var _fxFlashComplete:Void->Void = null;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashAlpha:Float = 0;
	/**
	 * Internal, color of fading special effect.
	 */
	private var _fxFadeColor:FlxColor = FlxColor.TRANSPARENT;
	/**
	 * Used to calculate the following target current velocity.
	 */
	private var _lastTargetPosition:FlxPoint;
	/**
	 * Helper to calculate follow target current scroll.
	 */
	private var _scrollTarget:FlxPoint = FlxPoint.get();
	/**
	 * Internal, "fade" special effect duration.
	 * Set by fade() method.
	 */
	private var _fxFadeDuration:Float = 0;
	/**
	 * Internal, "direction" of fade special effect.
	 * True means that camera fades from a color, false - camera fades to it.
	 * Set by fade() method.
	 */
	private var _fxFadeIn:Bool = false;
	/**
	 * Internal, used to control the "fade" special effect complete callback.
	 * Set by fade() method.
	 */
	private var _fxFadeComplete:Void->Void = null;
	/**
	 * Internal, tracks whether fade effect is running or not.
	 */
	private var _fxFadeCompleted:Bool = true;
	/**
	 * Internal, alpha component of fade color.
	 * Changes from 0 to 1 or from 1 to 0 as the effect continues.
	 */
	private var _fxFadeAlpha:Float = 0;
	/**
	 * Internal, percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * Set by shake() method.
	 */
	private var _fxShakeIntensity:Float = 0;
	/**
	 * Internal, duration of "shake" special effect.
	 * Set by shake() method.
	 */
	private var _fxShakeDuration:Float = 0;
	/**
	 * Internal, "shake" effect complete callback.
	 * Set by shake() method.
	 */
	private var _fxShakeComplete:Void->Void;
	/**
	 * Internal, used to store current value of camera's shake offset (for current frame),
	 * which affects flashSprite positioning.
	 */
	private var _fxShakeOffset:FlxPoint = FlxPoint.get();
	/**
	 * Internal, defines on what axes to shake. Default value is XY / both.
	 */
	private var _fxShakeAxes:FlxAxes = XY;
	/**
	 * Internal, used for repetitive calculations and added to help avoid costly allocations.
	 */
	private var _point:FlxPoint = FlxPoint.get();
	
	/**
	 * Camera's initial zoom value. Used for camera's scale handling.
	 */
	public var initialZoom(default, null):Float = 1;
	
	public inline function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		if (view != null)
			view.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
	}
	
	public inline function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		if (view != null)
			view.copyPixels(frame, pixels, sourceRect, destPoint, transform, blend, smoothing, shader);
	}
	
	public inline function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>,
		uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint, ?blend:BlendMode,
		repeat:Bool = false, smoothing:Bool = false):Void
	{
		if (view != null)
			view.drawTriangles(graphic, vertices, indices, uvtData, colors, position, blend, repeat, smoothing);
	}
	
	/**
	 * Instantiates a new camera at the specified location, with the specified size and zoom level.
	 * 
	 * @param 	X			X location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param 	Y			Y location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param 	Width		The width of the camera display in pixels.
	 * @param 	Height		The height of the camera display in pixels.
	 * @param 	Zoom		The initial zoom level of the camera.  A zoom level of 2 will make all pixels display at 2x resolution.
	 */
	public function new(X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0)
	{
		super();
		
		x = X;
		y = Y;
		
		// Use the game dimensions if width / height are <= 0
		width = (Width <= 0) ? FlxG.width : Width;
		height = (Height <= 0) ? FlxG.height : Height;
		
		if (FlxG.renderBlit)
		{
			view = new FlxBlitView(this);
		}
		else
		{
			view = new HardwareView(this);
		}
		
		pixelPerfectRender = FlxG.renderBlit;
		
		set_color(FlxColor.WHITE);
		
		zoom = Zoom; //sets the scale of flash sprite, which in turn loads flashoffset values
		initialZoom = zoom;
		
		updateScrollRect();
		updateFlashOffset();
		updateViewPosition();
		updateInternalPositions();
		
		bgColor = FlxG.cameras.bgColor;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		FlxDestroyUtil.destroy(view);
		
		scroll = FlxDestroyUtil.put(scroll);
		targetOffset = FlxDestroyUtil.put(targetOffset);
		deadzone = FlxDestroyUtil.put(deadzone);
		
		target = null;
		_fxFlashComplete = null;
		_fxFadeComplete = null;
		_fxShakeComplete = null;
		_fxShakeOffset = null;
		
		super.destroy();
	}
	
	/**
	 * Updates the camera scroll as well as special effects like screen-shake or fades.
	 */
	override public function update(elapsed:Float):Void
	{
		// follow the target, if there is one
		if (target != null)
		{
			updateFollow();
		}
		
		updateScroll();	
		updateFlash(elapsed);
		updateFade(elapsed);
		updateShake(elapsed);
		updateFilters();
		updateViewPosition();
	}
	
	function updateFilters():Void
	{
		if (view != null)
			view.updateFilters();
	}
	
	/**
	 * Updates (bounds) the camera scroll.
	 * Called every frame by camera's update() method.
	 */
	public function updateScroll():Void
	{
		//Make sure we didn't go outside the camera's bounds
		scroll.x = FlxMath.bound(scroll.x, minScrollX, (maxScrollX != null) ? maxScrollX - width : null);
		scroll.y = FlxMath.bound(scroll.y, minScrollY, (maxScrollY != null) ? maxScrollY - height : null);
	}
	
	/**
	 * Updates camera's scroll.
	 * Called every frame by camera's update() method (if camera's target isn't null).
	 */
	public function updateFollow():Void
	{
		//Either follow the object closely, 
		//or doublecheck our deadzone and update accordingly.
		if (deadzone == null)
		{
			target.getMidpoint(_point);
			_point.addPoint(targetOffset);
			focusOn(_point);
		}
		else
		{
			var edge:Float;
			var targetX:Float = target.x + targetOffset.x;
			var targetY:Float = target.y + targetOffset.y;
			
			if (style == SCREEN_BY_SCREEN) 
			{
				if (targetX >= (scroll.x + width))
				{
					_scrollTarget.x += width;
				}
				else if (targetX < scroll.x)
				{
					_scrollTarget.x -= width;
				}

				if (targetY >= (scroll.y + height))
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
					_lastTargetPosition = FlxPoint.get(target.x, target.y); // Creates this point.
				} 
				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;
				
				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}
			
			if (followLerp >= 60 / FlxG.updateFramerate)
			{
				scroll.copyFrom(_scrollTarget); // no easing
			}
			else
			{
				scroll.x += (_scrollTarget.x - scroll.x) * followLerp * FlxG.updateFramerate / 60;
				scroll.y += (_scrollTarget.y - scroll.y) * followLerp * FlxG.updateFramerate / 60;
			}
		}
	}
	
	private function updateFlash(elapsed:Float):Void
	{
		//Update the "flash" special effect
		if (_fxFlashAlpha > 0.0)
		{
			_fxFlashAlpha -= elapsed / _fxFlashDuration;
			if ((_fxFlashAlpha <= 0) && (_fxFlashComplete != null))
			{
				_fxFlashComplete();
			}
		}
	}
	
	private function updateFade(elapsed:Float):Void
	{
		if (_fxFadeCompleted)
			return;
		
		if (_fxFadeIn)
		{
			_fxFadeAlpha -= elapsed / _fxFadeDuration;
			if (_fxFadeAlpha <= 0.0)
			{
				_fxFadeAlpha = 0.0;
				completeFade();
			}
		}
		else
		{
			_fxFadeAlpha += elapsed / _fxFadeDuration;
			if (_fxFadeAlpha >= 1.0)
			{
				_fxFadeAlpha = 1.0;
				completeFade();
			}
		}
	}
	
	private function completeFade()
	{
		_fxFadeCompleted = true;
		if (_fxFadeComplete != null)
			_fxFadeComplete();
	}
	
	private function updateShake(elapsed:Float):Void
	{
		if (_fxShakeDuration > 0)
		{
			_fxShakeDuration -= elapsed;
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
				if (_fxShakeAxes != FlxAxes.Y)
				{
					_fxShakeOffset.x = FlxG.random.float( -_fxShakeIntensity * width, _fxShakeIntensity * width) * zoom;
				}
				if (_fxShakeAxes != FlxAxes.X)
				{
					_fxShakeOffset.y = FlxG.random.float( -_fxShakeIntensity * height, _fxShakeIntensity * height) * zoom;
				}
			}
		}
	}
	
	/**
	 * Recalculates flashSprite position.
	 * Called every frame by camera's update() method and every time you change camera's position.
	 */
	private function updateViewPosition():Void
	{
		if (view != null)
			view.updatePosition();
	}
	
	/**
	 * Recalculates _flashOffset point, which is used for positioning flashSprite in the game.
	 * It's called every time you resize the camera or the game.
	 */
	private function updateFlashOffset():Void
	{
		if (view != null)
			view.updateOffset();
	}
	
	/**
	 * Updates _scrollRect sprite to crop graphics of the camera:
	 * 1) scrollRect property of this sprite
	 * 2) position of this sprite insude flashSprite
	 * 
	 * It takes camera's size and game's scale into account.
	 * It's called every time you resize the camera or the game.
	 */
	private function updateScrollRect():Void
	{
		if (view != null)
			view.updateScrollRect();
	}
	
	/**
	 * Modifies position of _flashBitmap in blit render mode and canvas and debugSprite in tile render mode (these objects are children of _scrollRect sprite).
	 * It takes camera's size and game's scale into account.
	 * It's called every time you resize the camera or the game.
	 */
	private function updateInternalPositions():Void
	{
		if (view != null)
			view.updateInternals();
	}
	
	private function updateScale():Void
	{
		if (view != null)
			view.updateScale();
	}
	
	/**
	 * Tells this camera object what FlxObject to track.
	 * 
	 * @param	Target	The object you want the camera to track. Set to null to not follow anything.
	 * @param	Style	Leverage one of the existing "deadzone" presets. Default is LOCKON. 
	 * 			If you use a custom deadzone, ignore this parameter and manually specify the deadzone after calling follow().
	 * @param	Lerp	How much lag the camera should have (can help smooth out the camera movement).
	 */
	public function follow(Target:FlxObject, ?Style:FlxCameraFollowStyle, ?Lerp:Float):Void
	{
		if (Style == null)
			Style = LOCKON;

		if (Lerp == null)
			Lerp = 60 / FlxG.updateFramerate;
		
		style = Style;
		target = Target;
		followLerp = Lerp;
		var helper:Float;
		var w:Float = 0;
		var h:Float = 0;
		_lastTargetPosition = null;
		
		switch (Style)
		{
			case LOCKON:
				if (target != null) 
				{	
					w = target.width;
					h = target.height;
				}
				deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);
			
			case PLATFORMER:
				var w:Float = (width / 8);
				var h:Float = (height / 3);
				deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);
				
			case TOPDOWN:
				helper = Math.max(width, height) / 4;
				deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);
				
			case TOPDOWN_TIGHT:
				helper = Math.max(width, height) / 8;
				deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);
				
			case SCREEN_BY_SCREEN:
				deadzone = FlxRect.get(0, 0, width, height);
				
			case NO_DEAD_ZONE:
				deadzone = null;
		}
	}
	
	/**
	 * Snaps the camera to the current target. Useful to move the camera without
	 * any easing when the target position changes and there is a followLerp.
	 */
	public function snapToTarget():Void
	{
		updateFollow();
		scroll.copyFrom(_scrollTarget);
	}
	
	/**
	 * Move the camera focus to this location instantly.
	 * 
	 * @param	Point		Where you want the camera to focus.
	 */
	public inline function focusOn(point:FlxPoint):Void
	{
		scroll.set(point.x - width * 0.5, point.y - height * 0.5);
		point.putWeak();
	}
	
	/**
	 * The screen is filled with this color and gradually returns to normal.
	 * 
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function flash(Color:FlxColor = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		if (!Force && (_fxFlashAlpha > 0.0))
		{
			return;
		}
		_fxFlashColor = Color;
		if (Duration <= 0)
		{
			Duration = 0.000001;
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
	 * @param   FadeIn		True fades from a color, false fades to it.
	 * @param	OnComplete	A function you want to run when the fade finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function fade(Color:FlxColor = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		if (!_fxFadeCompleted && !Force)
			return;
		
		_fxFadeColor = Color;
		if (Duration <= 0)
			Duration = 0.000001;
		
		_fxFadeIn = FadeIn;
		_fxFadeDuration = Duration;
		_fxFadeComplete = OnComplete;
		
		_fxFadeAlpha = _fxFadeIn ? 0.999999 : 0.000001;
		_fxFadeCompleted = false;
	}
	
	/**
	 * A simple screen-shake effect.
	 * 
	 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * @param	Duration	The length in seconds that the shaking effect should last.
	 * @param	OnComplete	A function you want to run when the shake effect finishes.
	 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
	 * @param	Axes		On what axes to shake. Default value is XY / both.
	 */
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, ?Axes:FlxAxes):Void
	{
		if (Axes == null)
			Axes = XY;
		
		if (!Force && ((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0)))
		{
			return;
		}
		_fxShakeIntensity = Intensity;
		_fxShakeDuration = Duration;
		_fxShakeComplete = OnComplete;
		_fxShakeAxes = Axes;
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
		updateViewPosition();
	}
	
	/**
	 * Sets the filter array to be applied to the camera.
	 */
	public function setFilters(filters:Array<BitmapFilter>):Void
	{
		if (view != null)
			view.setFilters(filters);
	}
	
	public inline function lock(useBufferLocking:Bool):Void
	{
		if (view != null)
			view.lock(useBufferLocking);
	}
	
	public inline function unlock(useBufferLocking:Bool):Void
	{
		if (view != null)
			view.unlock(useBufferLocking);
	}
	
	public inline function render():Void
	{
		if (view != null)
			view.render();
	}
	
	public inline function beginDrawDebug():Graphics
	{
		return (view != null) ? view.beginDrawDebug() : null;
	}
	
	public inline function endDrawDebug():Void
	{
		if (view != null)
			view.endDrawDebug();
	}
	
	/**
	 * Copy the bounds, focus object, and deadzone info from an existing camera.
	 * 
	 * @param	Camera	The camera you want to copy from.
	 * @return	A reference to this FlxCamera object.
	 */
	public function copyFrom(Camera:FlxCamera):FlxCamera
	{
		setScrollBounds(Camera.minScrollX, Camera.maxScrollX, Camera.minScrollY, Camera.maxScrollY);
		
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
					deadzone = FlxRect.get();
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
	public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0):Void
	{
		if (view != null)
			view.fill(Color, BlendAlpha, FxAlpha);
	}
	
	/**
	 * Internal helper function, handles the actual drawing of all the special effects.
	 */
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private function drawFX():Void
	{
		//Draw the "flash" special effect onto the buffer
		if (_fxFlashAlpha > 0.0)
		{
			view.drawFX(_fxFlashColor, _fxFlashAlpha);
		}
		
		//Draw the "fade" special effect onto the buffer
		if (_fxFadeAlpha > 0.0)
		{
			view.drawFX(_fxFadeColor, _fxFadeAlpha);
		}
		
		//Shake the camera view
		if ((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0))
		{
			view.offsetView(_fxShakeOffset.x * FlxG.scaleMode.scale.x, _fxShakeOffset.y * FlxG.scaleMode.scale.y);
		}
	}
	
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private function checkResize():Void
	{
		if (view != null)
			view.checkResize();
	}
	
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
	 * Specify the bounding rectangle of where the camera is allowed to move.
	 * 
	 * @param	X				The smallest X value of your level (usually 0).
	 * @param	Y				The smallest Y value of your level (usually 0).
	 * @param	Width			The largest X value of your level (usually the level width).
	 * @param	Height			The largest Y value of your level (usually the level height).
	 * @param	UpdateWorld		Whether the global quad-tree's dimensions should be updated to match (default: false).
	 */
	public function setScrollBoundsRect(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0, UpdateWorld:Bool = false):Void
	{
		if (UpdateWorld)
		{
			FlxG.worldBounds.set(X, Y, Width, Height);
		}
		
		setScrollBounds(X, X + Width, Y, Y + Height);
	}
	
	/**
	 * Specify the bounds of where the camera is allowed to move.
	 * Set the boundary of a side to null to leave that side unbounded.
	 * 
	 * @param	MinX	The minimum X value the camera can scroll to
	 * @param	MaxX	The maximum X value the camera can scroll to
	 * @param	MinY	The minimum Y value the camera can scroll to
	 * @param	MaxY	The maximum Y value the camera can scroll to
	 */
	public function setScrollBounds(MinX:Null<Float>, MaxX:Null<Float>, MinY:Null<Float>, MaxY:Null<Float>):Void
	{
		minScrollX = MinX;
		maxScrollX = MaxX;
		minScrollY = MinY;
		maxScrollY = MaxY;
		updateScroll();
	}
	
	/**
	 * Helper function to set the scale of this camera.
	 * Handy since it only requires one line of code.
	 * 
	 * @param	X	The new scale on x axis
	 * @param	Y	The new scale of y axis
	 */
	public function setScale(X:Float, Y:Float):Void
	{
		scaleX = X;
		scaleY = Y;
		
		totalScaleX = scaleX * FlxG.scaleMode.scale.x;
		totalScaleY = scaleY * FlxG.scaleMode.scale.y;
		
		updateScale();
		
		updateViewPosition();
		updateScrollRect();
		updateInternalPositions();
	}
	
	/**
	 * Called by camera front end every time you resize the game.
	 * It triggers reposition of camera's internal display objects (flashSprite, _scrollRect, _flashBitmap, canvas, debugSprite).
	 */
	public function onResize():Void
	{
		updateFlashOffset();
		setScale(scaleX, scaleY);
	}
	
	private function set_followLerp(Value:Float):Float
	{
		return followLerp = FlxMath.bound(Value, 0, 60 / FlxG.updateFramerate);
	}
	
	private function set_width(Value:Int):Int
	{
		if (Value > 0)
		{
			width = Value; 
			
			updateFlashOffset();
			updateScrollRect();
			updateInternalPositions();
		}
		return Value;
	}
	
	private function set_height(Value:Int):Int
	{
		if (Value > 0)
		{
			height = Value;
			
			updateFlashOffset();
			updateScrollRect();
			updateInternalPositions();
		}
		return Value;
	}
	
	private function set_zoom(Zoom:Float):Float
	{
		zoom = (Zoom == 0) ? defaultZoom : Zoom;
		setScale(zoom, zoom);
		return zoom;
	}
	
	private function set_alpha(Alpha:Float):Float
	{
		alpha = FlxMath.bound(Alpha, 0, 1);
		
		if (view != null)
			view.alpha = alpha;
		
		return Alpha;
	}
	
	private function set_angle(Angle:Float):Float
	{
		angle = Angle;
		
		if (view != null)
			view.angle = Angle;
		
		return Angle;
	}
	
	private function set_color(Color:FlxColor):FlxColor
	{
		color = Color;
		
		if (view != null)
			view.color = color;
		
		return Color;
	}
	
	private function set_antialiasing(Antialiasing:Bool):Bool
	{
		antialiasing = Antialiasing;
		
		if (view != null)
			view.antialiasing = antialiasing;
		
		return Antialiasing;
	}
	
	private function set_x(x:Float):Float
	{
		this.x = x;
		updateViewPosition();
		return x;
	}
	
	private function set_y(y:Float):Float
	{
		this.y = y;
		updateViewPosition();
		return y;
	}
	
	override private function set_visible(visible:Bool):Bool
	{
		this.visible = visible;
		
		if (view != null)
			view.visible = visible;
		
		return visible;
	}
}

// TODO: convert this to class with camera behavior

enum FlxCameraFollowStyle
{
	/**
	 * Camera has no deadzone, just tracks the focus object directly.
	 */
	LOCKON;
	/**
	 * Camera's deadzone is narrow but tall.
	 */
	PLATFORMER;
	/**
	 * Camera's deadzone is a medium-size square around the focus object.
	 */
	TOPDOWN;
	/**
	 * Camera's deadzone is a small square around the focus object.
	 */
	TOPDOWN_TIGHT;
	/**
	 * Camera will move screenwise.
	 */
	SCREEN_BY_SCREEN;
	/**
	 * Camera has no deadzone, just tracks the focus object directly and centers it.
	 */
	NO_DEAD_ZONE;
}