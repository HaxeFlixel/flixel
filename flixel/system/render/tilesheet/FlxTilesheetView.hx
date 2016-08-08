package flixel.system.render.tilesheet;
import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawTilesItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMatrix;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.FlxCameraView;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Zaphod
 */
class FlxTilesheetView extends FlxCameraView
{
	/**
	 * Used to render buffer to screen space. NOTE: We don't recommend modifying this directly unless you are fairly experienced. 
	 * Uses include 3D projection, advanced display list modification, and more.
	 * This is container for everything else that is used by camera and rendered to the camera.
	 * 
	 * Its position is modified by updateFlashSpritePosition() method which is called every frame.
	 */
	public var flashSprite:Sprite = new Sprite();
	
	/**
	 * Internal sprite, used for correct trimming of camera viewport.
	 * It is a child of flashSprite.
	 * Its position is modified by updateScrollRect() method, which is called on camera's resize and scale events.
	 */
	private var _scrollRect:Sprite = new Sprite();
	
	/**
	 * Sprite used for actual rendering in tile render mode (instead of _flashBitmap for blitting).
	 * Its graphics is used as a drawing surface for drawTriangles() and drawTiles() methods.
	 * It is a child of _scrollRect Sprite (which trims graphics that should be unvisible).
	 * Its position is modified by updateInternalSpritePositions() method, which is called on camera's resize and scale events.
	 */
	public var canvas:Sprite;
	
	#if FLX_DEBUG
	/**
	 * Sprite for visual effects (flash and fade) and drawDebug information 
	 * (bounding boxes are drawn on it) for tile render mode.
	 * It is a child of _scrollRect Sprite (which trims graphics that should be unvisible).
	 * Its position is modified by updateInternalSpritePositions() method, which is called on camera's resize and scale events.
	 */
	public var debugLayer:Sprite;
	#end
	
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
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		canvas = new Sprite();
		_scrollRect.addChild(canvas);
		_transform = new Matrix();
		
		#if FLX_DEBUG
		debugLayer = new Sprite();
		_scrollRect.addChild(debugLayer);
		#end
	}
	
	override public function init():Void 
	{
		super.init();
		
		
	}
	
	@:noCompletion
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
	{
		#if FLX_RENDER_TRIANGLE
		return startTrianglesBatch(graphic, smooth, colored, blend);
		#else
		var itemToReturn:FlxDrawTilesItem = null;
		var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);
		
		if (_currentDrawItem != null && _currentDrawItem.type == FlxDrawItemType.TILES 
			&& _headTiles.graphics == graphic 
			&& _headTiles.colored == colored
			&& _headTiles.hasColorOffsets == hasColorOffsets
			&& _headTiles.blending == blendInt
			&& _headTiles.antialiasing == smooth
			&& _headTiles.shader == shader)
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
		itemToReturn.hasColorOffsets = hasColorOffsets;
		itemToReturn.blending = blendInt;
		itemToReturn.shader = shader;
		
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
		#end
	}
	
	@:noCompletion
	public function startTrianglesBatch(graphic:FlxGraphic, smoothing:Bool = false,
		isColored:Bool = false, ?blend:BlendMode):FlxDrawTrianglesItem
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
	public function getNewDrawTrianglesItem(graphic:FlxGraphic, smoothing:Bool = false,
		isColored:Bool = false, ?blend:BlendMode):FlxDrawTrianglesItem
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
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		#if FLX_RENDER_TRIANGLE
		var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(frame.parent, smoothing, isColored, blend);
		#else
		var drawItem:FlxDrawTilesItem = startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		#end
		drawItem.addQuad(frame, matrix, transform);
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		_helperMatrix.identity();
		_helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		#if !FLX_RENDER_TRIANGLE
		var drawItem:FlxDrawTilesItem = startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		#else
		var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(frame.parent, smoothing, isColored, blend);
		#end
		drawItem.addQuad(frame, _helperMatrix, transform);
	}
	
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>,
		uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint, ?blend:BlendMode,
		repeat:Bool = false, smoothing:Bool = false):Void
	{
		_bounds.set(0, 0, width, height);
		var isColored:Bool = (colors != null && colors.length != 0);
		var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(graphic, smoothing, isColored, blend);
		drawItem.addTriangles(vertices, indices, uvtData, colors, position, _bounds);
	}
	
	override public function updatePosition():Void 
	{
		if (flashSprite != null)
		{
			flashSprite.x = x * FlxG.scaleMode.scale.x + _flashOffset.x;
			flashSprite.y = y * FlxG.scaleMode.scale.y + _flashOffset.y;
		}
	}
	
	override public function updateScrollRect():Void 
	{
		var rect:Rectangle = (_scrollRect != null) ? _scrollRect.scrollRect : null;
		
		if (rect != null)
		{
			rect.x = rect.y = 0;
			rect.width = camera.width * camera.initialZoom * FlxG.scaleMode.scale.x;
			rect.height = camera.height * camera.initialZoom * FlxG.scaleMode.scale.y;
			_scrollRect.scrollRect = rect;
			_scrollRect.x = -0.5 * rect.width;
			_scrollRect.y = -0.5 * rect.height;
		}
	}
	
	override public function updateInternals():Void 
	{
		if (canvas != null)
		{
			canvas.x = -0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x;
			canvas.y = -0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y;
			
			canvas.scaleX = camera.totalScaleX;
			canvas.scaleY = camera.totalScaleY;
			
			#if FLX_DEBUG
			if (debugLayer != null)
			{
				debugLayer.x = canvas.x;
				debugLayer.y = canvas.y;
				
				debugLayer.scaleX = canvas.scaleX;
				debugLayer.scaleY = canvas.scaleY;
			}
			#end
		}
	}
	
	override public function setColor(Color:FlxColor):FlxColor 
	{
		
	}
	
	override function get_display():DisplayObject 
	{
		return flashSprite;
	}
	
}