package flixel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawTilesItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;
import openfl.Vector;

/**
 * The camera class is used to display the game's visuals.
 * By default one camera is created automatically, that is the same size as window.
 * You can add more cameras or even replace the main camera using utilities in FlxG.cameras.
 */
@:allow(flixel.FlxGame)
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
	 * The X position of this camera's display. Zoom does NOT affect this number.
	 * Measured in pixels from the left side of the flash window.
	 */
	public var x(default, set):Float = 0;
	/**
	 * The Y position of this camera's display. Zoom does NOT affect this number.
	 * Measured in pixels from the top of the flash window.
	 */
	public var y(default, set):Float = 0;
	
	/**
	 * The scaling on horizontal axis for this camera.
	 */
	public var scaleX(default, null):Float;
	/**
	 * The scaling on vertical axis for this camera.
	 */
	public var scaleY(default, null):Float;
	/**
	 * Product of camera's scaleX and game's scalemode scale.x multiplication.
	 * Added this var for less calculations at rendering time.
	 */
	public var totalScaleX(default, null):Float;
	/**
	 * Product of camera's scaleY and game's scalemode scale.y multiplication.
	 * Added this var for less calculations at rendering time.
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
	public var targetOffset(default, null):FlxPoint;
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
	 */
	public var scroll:FlxPoint;
	
	#if FLX_RENDER_BLIT
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
	 * The natural background color of the camera, in AARRGGBB format. Defaults to FlxG.cameras.bgColor.
	 * On flash, transparent backgrounds can be used in conjunction with useBgAlphaBlending.
	 */ 
	public var bgColor:FlxColor;
	
	#if FLX_RENDER_BLIT
	/**
	 * Sometimes it's easier to just work with a FlxSprite than it is to work directly with the BitmapData buffer.  
	 * This sprite reference will allow you to do exactly that.
	 */
	public var screen:FlxSprite;
	#end
	
	/**
	 * Whether to use alpha blending for camera's background fill or not. 
	 * Useful for flash target (and works only on this target). Default value is false.
	 */
	public var useBgAlphaBlending:Bool = false;
	
	/**
	 * Used to render buffer to screen space. NOTE: We don't recommend modifying this directly unless you are fairly experienced. 
	 * Uses include 3D projection, advanced display list modification, and more.
	 */
	public var flashSprite:Sprite;

	/**
	 * Whether the positions of the objects rendered on this camera are rounded.
	 * If set on individual objects, they ignore the global camera setting.
	 * Defaults to false with FLX_RENDER_TILE and to true with FLX_RENDER_BLIT.
	 * WARNING: setting this to false on blitting targets is very expensive.
	 */
	public var pixelPerfectRender:Bool = #if FLX_RENDER_TILE false #else true #end;
	
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
	public var followLead(default, null):FlxPoint;
	/**
	 * Enables or disables the filters set via setFilters()
	 */
	public var enableFilters:Bool = true;
	
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
	private var _flashOffset:FlxPoint;
	/**
	 * Internal, used to control the "flash" special effect.
	 */
	private var _fxFlashColor:FlxColor = FlxColor.TRANSPARENT;
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
	private var _fxFadeColor:FlxColor = FlxColor.TRANSPARENT;
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
	private var _fxShakeComplete:Void->Void;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeOffset:FlxPoint;
	/**
	 * Internal, used to control the "shake" special effect.
	 */
	private var _fxShakeAxes:FlxAxes = XY;
	/**
	 * Internal, to help avoid costly allocations.
	 */
	private var _point:FlxPoint;
	/**
	 * Internal, the filters array to be applied to the camera.
	 */
	private var _filters:Array<BitmapFilter>;
	
	/**
	 * Camera's initial zoom value. Used for camera's scale handling.
	 */
	public var initialZoom(default, null):Float = 1;
	
	#if FLX_RENDER_BLIT
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 */
	private var _fill:BitmapData;
	/**
	 * Internal, used to render buffer to screen space.
	 */
	private var _flashBitmap:Bitmap;
	#end
	
	/**
	 * Internal sprite, used for correct trimming of camera viewport.
	 */
	private var _scrollRect:Sprite;
	
	/**
	 * Helper rect for drawTriangles visibility checks
	 */
	private var _bounds:FlxRect = FlxRect.get();
	
#if FLX_RENDER_TILE
	/**
	 * Sprite for drawing (instead of _flashBitmap for blitting)
	 */
	public var canvas:Sprite;
	
	#if !FLX_NO_DEBUG
	/**
	 * Sprite for visual effects (flash and fade) and drawDebug information 
	 * (bounding boxes are drawn on it) for non-flash targets
	 */
	public var debugLayer:Sprite;
	#end
	
	// TODO: use this transform matrix later in hardware accelerated mode...
	private var _transform:Matrix;
	
	private var _helperMatrix:FlxMatrix = new FlxMatrix();
	
	/**
	 * Currently used draw stack item
	 */
	private var _currentDrawItem:FlxDrawBaseItem<Dynamic>;
	/**
	 * Pointer to head of stack with draw items
	 */
	private var _headOfDrawStack:FlxDrawBaseItem<Dynamic>;
	/**
	 * Last draw tiles item
	 */
	private var _headTiles:FlxDrawTilesItem;
	/**
	 * Last draw triangles item
	 */
	private var _headTriangles:FlxDrawTrianglesItem;
	
	/**
	 * Draw tiles stack items that can be reused
	 */
	private static var _storageTilesHead:FlxDrawTilesItem;
	
	/**
	 * Draw triangles stack items that can be reused
	 */
	private static var _storageTrianglesHead:FlxDrawTrianglesItem;
	
	#if !FLX_RENDER_TRIANGLE
	@:noCompletion
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, blend:BlendMode = null, smooth:Bool = false):FlxDrawTilesItem
	{
		var itemToReturn:FlxDrawTilesItem = null;
		var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);
		
		if (_currentDrawItem != null && _currentDrawItem.type == FlxDrawItemType.TILES 
			&& _headTiles.graphics == graphic 
			&& _headTiles.colored == colored
			&& _headTiles.blending == blendInt
			&& _headTiles.antialiasing == smooth)
		{	
			return _headTiles;
		}
		
		if (_storageTilesHead != null)
		{
			itemToReturn = _storageTilesHead;
			var newHead:FlxDrawTilesItem = _storageTilesHead.nextTyped;
			itemToReturn.reset();
			_storageTilesHead = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawTilesItem();
		}
		
		itemToReturn.graphics = graphic;
		itemToReturn.antialiasing = smooth;
		itemToReturn.colored = colored;
		itemToReturn.blending = blendInt;
		
		itemToReturn.nextTyped = _headTiles;
		_headTiles = itemToReturn;
		
		if (_headOfDrawStack == null)
		{
			_headOfDrawStack = itemToReturn;
		}
		
		if (_currentDrawItem != null)
		{
			_currentDrawItem.next = itemToReturn;
		}
		
		_currentDrawItem = itemToReturn;
		
		return itemToReturn;
	}
	#else
	@:noCompletion
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, blend:BlendMode = null, smooth:Bool = false):FlxDrawTrianglesItem
	{
		return startTrianglesBatch(graphic, smooth, colored, blend);
	}
	#end
	
	@:noCompletion
	public function startTrianglesBatch(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, blend:BlendMode = null):FlxDrawTrianglesItem
	{
		var itemToReturn:FlxDrawTrianglesItem = null;
		var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);
		
		if (_currentDrawItem != null && _currentDrawItem.type == FlxDrawItemType.TRIANGLES 
			&& _headTriangles.graphics == graphic 
			&& _headTriangles.antialiasing == smoothing
			&& _headTriangles.colored == isColored
			&& _headTriangles.blending == blendInt)
		{	
			return _headTriangles;
		}
		
		return getNewDrawTrianglesItem(graphic, smoothing, isColored, blend);
	}
	
	@:noCompletion
	public function getNewDrawTrianglesItem(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, blend:BlendMode = null):FlxDrawTrianglesItem
	{
		var itemToReturn:FlxDrawTrianglesItem = null;
		var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);
		
		if (_storageTrianglesHead != null)
		{
			itemToReturn = _storageTrianglesHead;
			var newHead:FlxDrawTrianglesItem = _storageTrianglesHead.nextTyped;
			itemToReturn.reset();
			_storageTrianglesHead = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawTrianglesItem();
		}
		
		itemToReturn.graphics = graphic;
		itemToReturn.antialiasing = smoothing;
		itemToReturn.colored = isColored;
		itemToReturn.blending = blendInt;
		
		itemToReturn.nextTyped = _headTriangles;
		_headTriangles = itemToReturn;
		
		if (_headOfDrawStack == null)
		{
			_headOfDrawStack = itemToReturn;
		}
		
		if (_currentDrawItem != null)
		{
			_currentDrawItem.next = itemToReturn;
		}
		
		_currentDrawItem = itemToReturn;
		
		return itemToReturn;
	}
	
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private function clearDrawStack():Void
	{	
		var currTiles:FlxDrawTilesItem = _headTiles;
		var newTilesHead:FlxDrawTilesItem;
		
		while (currTiles != null)
		{
			newTilesHead = currTiles.nextTyped;
			currTiles.reset();
			currTiles.nextTyped = _storageTilesHead;
			_storageTilesHead = currTiles;
			currTiles = newTilesHead;
		}
		
		var currTriangles:FlxDrawTrianglesItem = _headTriangles;
		var newTrianglesHead:FlxDrawTrianglesItem;
		
		while (currTriangles != null)
		{
			newTrianglesHead = currTriangles.nextTyped;
			currTriangles.reset();
			currTriangles.nextTyped = _storageTrianglesHead;
			_storageTrianglesHead = currTriangles;
			currTriangles = newTrianglesHead;
		}
		
		_currentDrawItem = null;
		_headOfDrawStack = null;
		_headTiles = null;
		_headTriangles = null;
	}
	
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private function render():Void
	{
		var currItem:FlxDrawBaseItem<Dynamic> = _headOfDrawStack;
		while (currItem != null)
		{
			currItem.render(this);
			currItem = currItem.next;
		}
	}
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, cr:Float = 1.0, cg:Float = 1.0, cb:Float = 1.0, ca:Float = 1.0, blend:BlendMode = null, smoothing:Bool = false):Void
	{
		if (pixels != null)
		{
			frame = frame.copyTo();
			frame.parent.bitmap = pixels.clone();
		}
		var isColored:Bool = (cr != 1.0) || (cg != 1.0) || (cb != 1.0) || (ca != 1.0);
		#if !FLX_RENDER_TRIANGLE
		var drawItem:FlxDrawTilesItem = startQuadBatch(frame.parent, isColored, blend, smoothing);
		#else
		var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(frame.parent, smoothing, isColored, blend);
		#end
		drawItem.addQuad(frame, matrix, cr, cg, cb, ca);
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, cr:Float = 1.0, cg:Float = 1.0, cb:Float = 1.0, ca:Float = 1.0, blend:BlendMode = null, smoothing:Bool = false):Void
	{
		if (pixels != null)
		{
			frame = frame.copyTo();
			frame.parent.bitmap = pixels.clone();
		}
		_helperMatrix.identity();
		_helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		var isColored:Bool = (cr != 1.0) || (cg != 1.0) || (cb != 1.0) || (ca != 1.0);
		#if !FLX_RENDER_TRIANGLE
		var drawItem:FlxDrawTilesItem = startQuadBatch(frame.parent, isColored, blend, smoothing);
		#else
		var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(frame.parent, smoothing, isColored, blend);
		#end
		drawItem.addQuad(frame, _helperMatrix, cr, cg, cb, ca);
	}
	
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, colors:DrawData<Int> = null, position:FlxPoint = null, blend:BlendMode = null, smoothing:Bool = false):Void
	{
		_bounds.set(0, 0, width, height);
		var isColored:Bool = (colors != null && colors.length != 0);
		var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(graphic, smoothing, isColored, blend);
		drawItem.addTriangles(vertices, indices, uvtData, colors, position, _bounds);
	}
#else
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:Matrix, cr:Float = 1.0, cg:Float = 1.0, cb:Float = 1.0, ca:Float = 1.0, blend:BlendMode = null, smoothing:Bool = false):Void
	{
		buffer.draw(pixels, matrix, null, blend, null, (smoothing || antialiasing));
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, cr:Float = 1.0, cg:Float = 1.0, cb:Float = 1.0, ca:Float = 1.0, blend:BlendMode = null, smoothing:Bool = false):Void
	{
		if (pixels != null)
		{
			buffer.copyPixels(pixels, sourceRect, destPoint, null, null, true);
		}
		else if (frame != null)
		{
			frame.paint(buffer, destPoint, true);
		}
	}
	
	private static var drawVertices:Vector<Float> = new Vector<Float>();
	private static var trianglesSprite:Sprite = new Sprite();
	
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, colors:DrawData<Int> = null, position:FlxPoint = null, blend:BlendMode = null, smoothing:Bool = false):Void
	{
		if (position == null)
		{
			position = FlxPoint.flxPoint1.set(0, 0);
		}
		
		_bounds.set(0, 0, width, height);
		
		var verticesLength:Int = vertices.length;
		var currentVertexPosition:Int = 0;
		
		var tempX:Float, tempY:Float;
		var i:Int = 0;
		var bounds:FlxRect = FlxRect.flxRect;
		drawVertices.splice(0, drawVertices.length);
		
		while (i < verticesLength)
		{
			tempX = position.x + vertices[i]; 
			tempY = position.y + vertices[i + 1];
			
			drawVertices[currentVertexPosition++] = tempX;
			drawVertices[currentVertexPosition++] = tempY;
			
			if (i == 0)
			{
				bounds.set(tempX, tempY, 0, 0);
			}
			else
			{
				FlxDrawTrianglesItem.inflateBounds(bounds, tempX, tempY);
			}
			
			i += 2;
		}
		
		var vis:Bool = _bounds.overlaps(bounds);
		
		if (!vis)
		{
			drawVertices.splice(drawVertices.length - verticesLength, verticesLength);
		}
		else
		{
			trianglesSprite.graphics.clear();
			trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, false, smoothing);
			trianglesSprite.graphics.drawTriangles(drawVertices, indices, uvtData);
			trianglesSprite.graphics.endFill();
			buffer.draw(trianglesSprite);
			#if !FLX_NO_DEBUG
			if (FlxG.debugger.drawDebug)
			{
				var gfx:Graphics = FlxSpriteUtil.flashGfx;
				gfx.clear();
				gfx.lineStyle(1, FlxColor.BLUE, 0.5);
				gfx.drawTriangles(drawVertices, indices);
				camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
			}
			#end
		}	
	}
#end
	
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
		
		_scrollTarget = FlxPoint.get();
		scroll = FlxPoint.get();
		followLead = FlxPoint.get();
		targetOffset = FlxPoint.get();
		_point = FlxPoint.get();
		_flashOffset = FlxPoint.get();
		
		x = X;
		y = Y;
		
		// Use the game dimensions if width / height are <= 0
		width = (Width <= 0) ? FlxG.width : Width;
		height = (Height <= 0) ? FlxG.height : Height;
		
		#if FLX_RENDER_BLIT
		screen = new FlxSprite();
		buffer = new BitmapData(width, height, true, 0);
		screen.pixels = buffer;
		screen.origin.set();
		#end
		
		#if FLX_RENDER_BLIT
		_flashBitmap = new Bitmap(buffer);
		#else
		canvas = new Sprite();
		#end
		
		set_color(FlxColor.WHITE);
		
		flashSprite = new Sprite();
		
		_scrollRect = new Sprite();
		flashSprite.addChild(_scrollRect);
		
		#if FLX_RENDER_BLIT
		_scrollRect.addChild(_flashBitmap);
		#else
		_scrollRect.addChild(canvas);
		#end
		_flashRect = new Rectangle(0, 0, width, height);
		_flashPoint = new Point();
		
		_fxShakeOffset = FlxPoint.get();
		
	#if FLX_RENDER_BLIT
		_fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
	#else
		
		#if !FLX_NO_DEBUG
		debugLayer = new Sprite();
		_scrollRect.addChild(debugLayer);
		#end
		
		_transform = new Matrix();
	#end
		
		zoom = Zoom; //sets the scale of flash sprite, which in turn loads flashoffset values
		
		initialZoom = zoom;
		
		_scrollRect.scrollRect = new Rectangle();
		
		updateScrollRect();
		updateFlashOffset();	
		updateFlashSpritePosition();
		updateInternalSpritePositions();
		
		bgColor = FlxG.cameras.bgColor;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		FlxDestroyUtil.removeChild(flashSprite, _scrollRect);
		
	#if FLX_RENDER_BLIT
		FlxDestroyUtil.removeChild(_scrollRect, _flashBitmap);
		screen = FlxDestroyUtil.destroy(screen);
		buffer = null;
		_flashBitmap = null;
		_fill = FlxDestroyUtil.dispose(_fill);
	#else
		#if !FLX_NO_DEBUG
		FlxDestroyUtil.removeChild(_scrollRect, debugLayer);
		debugLayer = null;
		#end
		
		FlxDestroyUtil.removeChild(_scrollRect, canvas);
		if (canvas != null)
		{
			for (i in 0...canvas.numChildren)
			{
				canvas.removeChildAt(0);
			}
			canvas = null;
		}
		
		if (_headOfDrawStack != null)
		{
			clearDrawStack();
		}
		
		_transform = null;
		_helperMatrix = null;
	#end
		
		_bounds = null;
		scroll = FlxDestroyUtil.put(scroll);
		targetOffset = FlxDestroyUtil.put(targetOffset);
		deadzone = FlxDestroyUtil.put(deadzone);
		
		target = null;
		flashSprite = null;
		_scrollRect = null;
		_flashRect = null;
		_flashPoint = null;
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
		
		flashSprite.filters = enableFilters ? _filters : null;
		
		updateFlashSpritePosition();
	}
	
	/**
	 * Updates the camera scroll.
	 */
	public function updateScroll():Void
	{
		//Make sure we didn't go outside the camera's bounds
		scroll.x = FlxMath.bound(scroll.x, minScrollX, (maxScrollX != null) ? maxScrollX - width : null);
		scroll.y = FlxMath.bound(scroll.y, minScrollY, (maxScrollY != null) ? maxScrollY - height : null);
	}
	
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
		if ((_fxFadeAlpha > 0.0) && (_fxFadeAlpha < 1.0))
		{
			if (_fxFadeIn)
			{
				_fxFadeAlpha -= elapsed /_fxFadeDuration;
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
				_fxFadeAlpha += elapsed / _fxFadeDuration;
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
	
	private function updateFlashSpritePosition():Void
	{
		if (flashSprite != null)
		{
			flashSprite.x = x * FlxG.scaleMode.scale.x + _flashOffset.x;
			flashSprite.y = y * FlxG.scaleMode.scale.y + _flashOffset.y;
		}
	}
	
	private function updateFlashOffset():Void
	{
		_flashOffset.x = width * 0.5 * FlxG.scaleMode.scale.x * initialZoom;
		_flashOffset.y = height * 0.5 * FlxG.scaleMode.scale.y * initialZoom;
	}
	
	private function updateScrollRect():Void
	{
		var rect:Rectangle = (_scrollRect != null) ? _scrollRect.scrollRect : null;
		
		if (rect != null)
		{
			rect.x = rect.y = 0;
			rect.width = width * initialZoom * FlxG.scaleMode.scale.x;
			rect.height = height * initialZoom * FlxG.scaleMode.scale.y;
			_scrollRect.scrollRect = rect;
			_scrollRect.x = -0.5 * rect.width;
			_scrollRect.y = -0.5 * rect.height;
		}
	}
	
	function updateInternalSpritePositions():Void
	{
		#if FLX_RENDER_BLIT
		if (_flashBitmap != null)
		{
			regen = regen || (width != buffer.width) || (height != buffer.height);
			
			_flashBitmap.x = -0.5 * width * (scaleX - initialZoom) * FlxG.scaleMode.scale.x;
			_flashBitmap.y = -0.5 * height * (scaleY - initialZoom) * FlxG.scaleMode.scale.y;
		}
		#else
		if (canvas != null)
		{
			canvas.x = -0.5 * width * (scaleX - initialZoom) * FlxG.scaleMode.scale.x;
			canvas.y = -0.5 * height * (scaleY - initialZoom) * FlxG.scaleMode.scale.y;
			
			canvas.scaleX = totalScaleX;
			canvas.scaleY = totalScaleY;
			
			#if !FLX_NO_DEBUG
			if (debugLayer != null)
			{
				debugLayer.x = canvas.x;
				debugLayer.y = canvas.y;
				
				debugLayer.scaleX = totalScaleX;
				debugLayer.scaleY = totalScaleY;
			}
			#end
		}
		#end
	}
	
	/**
	 * Tells this camera object what FlxObject to track.
	 * 
	 * @param	Target	The object you want the camera to track.  Set to null to not follow anything.
	 * @param	Style	Leverage one of the existing "deadzone" presets. Default is LOCKON. 
	 * 			If you use a custom deadzone, ignore this parameter and manually specify the deadzone after calling follow().
	 * @param	Offset	Offset the follow deadzone by a certain amount. Only applicable for PLATFORMER and LOCKON styles.
	 * @param	Lerp	How much lag the camera should have (can help smooth out the camera movement).
	 */
	public function follow(Target:FlxObject, ?Style:FlxCameraFollowStyle, ?Offset:FlxPoint, ?Lerp:Float):Void
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
			case PLATFORMER:
				var w:Float = (width / 8) + (Offset != null ? Offset.x : 0);
				var h:Float = (height / 3) + (Offset != null ? Offset.y : 0);
				deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);
				
			case TOPDOWN:
				helper = Math.max(width, height) / 4;
				deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);
				
			case TOPDOWN_TIGHT:
				helper = Math.max(width, height) / 8;
				deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);
				
			case LOCKON:
				if (target != null) 
				{	
					w = target.width + (Offset != null ? Offset.x : 0);
					h = target.height + (Offset != null ? Offset.y : 0);
				}
				deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);
				
			case SCREEN_BY_SCREEN:
				deadzone = FlxRect.get(0, 0, width, height);
				
			default:
				deadzone = null;
		}
		
		if (Offset != null)
		{
			Offset.putWeak();
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
		if (!Force && (_fxFadeAlpha > 0.0))
		{
			return;
		}
		_fxFadeColor = Color;
		if (Duration <= 0)
		{
			Duration = 0.000001;
		}
		
		_fxFadeIn = FadeIn;
		_fxFadeDuration = Duration;
		_fxFadeComplete = OnComplete;
		
		_fxFadeAlpha = _fxFadeIn ? 0.999999 : 0.000001;
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
		updateFlashSpritePosition();
	}
	
	/**
	 * Sets the filter array to be applied to the camera.
	 * 
	 * @param	filters
	 */
	public function setFilters(filters:Array<BitmapFilter>):Void
	{
		_filters = filters;
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
	public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0, ?graphics:Graphics):Void
	{
	#if FLX_RENDER_BLIT
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
		Color = Color.to24Bit();
		// end of fix
		
		targetGraphics.beginFill(Color, FxAlpha);
		// i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
		// which could appear while cameras fading
		targetGraphics.drawRect(-1, -1, width * totalScaleX + 2, height * totalScaleY + 2);
		targetGraphics.endFill();
	#end
	}
	
	/**
	 * Internal helper function, handles the actual drawing of all the special effects.
	 */
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private function drawFX():Void
	{
		var alphaComponent:Float;
		
		//Draw the "flash" special effect onto the buffer
		if (_fxFlashAlpha > 0.0)
		{
			alphaComponent = _fxFlashColor.alpha;
			
			#if FLX_RENDER_BLIT
			fill((Std.int(((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha) << 24) + (_fxFlashColor & 0x00ffffff));
			#else
			fill((_fxFlashColor & 0x00ffffff), true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * _fxFlashAlpha / 255, canvas.graphics);
			#end
		}
		
		//Draw the "fade" special effect onto the buffer
		if (_fxFadeAlpha > 0.0)
		{
			alphaComponent = _fxFadeColor.alpha;
			
			#if FLX_RENDER_BLIT
			fill((Std.int(((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha) << 24) + (_fxFadeColor & 0x00ffffff));
			#else
			fill((_fxFadeColor & 0x00ffffff), true, ((alphaComponent <= 0) ?0xff : alphaComponent) * _fxFadeAlpha / 255, canvas.graphics);
			#end
		}
		
		if ((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0))
		{
			flashSprite.x += _fxShakeOffset.x * FlxG.scaleMode.scale.x;
			flashSprite.y += _fxShakeOffset.y * FlxG.scaleMode.scale.y;
		}
	}
	
	#if FLX_RENDER_BLIT
	public function checkResize():Void
	{
		if (regen)
		{
			if (width != buffer.width || height != buffer.height)
			{
				var oldBuffer:FlxGraphic = screen.graphic;
				buffer = new BitmapData(width, height, true, 0);
				screen.pixels = buffer;
				screen.origin.set();
				_flashBitmap.bitmapData = buffer;
				_flashRect.width = width;
				_flashRect.height = height;
				_fill = FlxDestroyUtil.dispose(_fill);
				_fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
				FlxG.bitmap.removeIfNoUse(oldBuffer);
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
	
	public function setScale(X:Float, Y:Float):Void
	{
		scaleX = X;
		scaleY = Y;
		
		totalScaleX = scaleX * FlxG.scaleMode.scale.x;
		totalScaleY = scaleY * FlxG.scaleMode.scale.y;
		
		#if FLX_RENDER_BLIT
		_flashBitmap.scaleX = totalScaleX;
		_flashBitmap.scaleY = totalScaleY;
		#else
		_transform.identity();
		_transform.scale(totalScaleX, totalScaleY);
		#end
		
		updateFlashSpritePosition();
		updateScrollRect();
		updateInternalSpritePositions();
	}
	
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
			updateInternalSpritePositions();
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
			updateInternalSpritePositions();
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
		#if FLX_RENDER_BLIT
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
	
	private function set_color(Color:FlxColor):FlxColor
	{
		color = Color;
		var colorTransform:ColorTransform;
		
		#if FLX_RENDER_BLIT
		if (_flashBitmap == null)
		{
			return Color;
		}
		colorTransform = _flashBitmap.transform.colorTransform;
		#else
		colorTransform = canvas.transform.colorTransform;
		#end
		
		colorTransform.redMultiplier = color.redFloat;
		colorTransform.greenMultiplier = color.greenFloat;
		colorTransform.blueMultiplier = color.blueFloat;
		
		#if FLX_RENDER_BLIT
		_flashBitmap.transform.colorTransform = colorTransform;
		#else
		canvas.transform.colorTransform = colorTransform;
		#end
		
		return Color;
	}
	
	private function set_antialiasing(Antialiasing:Bool):Bool
	{
		antialiasing = Antialiasing;
		#if FLX_RENDER_BLIT
		_flashBitmap.smoothing = Antialiasing;
		#end
		return Antialiasing;
	}
	
	private function set_x(x:Float):Float
	{
		this.x = x;
		updateFlashSpritePosition();
		return x;
	}
	
	private function set_y(y:Float):Float
	{
		this.y = y;
		updateFlashSpritePosition();
		return y;
	}
	
	override private function set_visible(visible:Bool):Bool
	{
		if (flashSprite != null)
		{
			flashSprite.visible = visible;
		}
		return this.visible = visible;
	}
}

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
