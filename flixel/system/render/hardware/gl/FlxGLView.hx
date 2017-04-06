package flixel.system.render.hardware.gl;

import flixel.graphics.FlxMaterial;
import flixel.graphics.FlxTrianglesData;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawBaseCommand;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

class FlxGLView extends FlxCameraView
{
	/**
	 * Used to render buffer to screen space.
	 * NOTE: We don't recommend modifying this directly unless you are fairly experienced.
	 * Uses include 3D projection, advanced display list modification, and more.
	 * This is container for everything else that is used by camera and rendered to the camera.
	 * 
	 * Its position is modified by `updateFlashSpritePosition()` which is called every frame.
	 */
	public var flashSprite:Sprite = new Sprite();
	
	/**
	 * Internal sprite, used for correct trimming of camera viewport.
	 * It is a child of `flashSprite`.
	 * Its position is modified by `updateScrollRect()` method, which is called on camera's resize and scale events.
	 */
	private var _scrollRect:Sprite = new Sprite();
	
	/**
	 * Sprite used for actual rendering in tile render mode (instead of `_flashBitmap` for blitting).
	 * Its graphics is used as a drawing surface for `drawTriangles()` and `drawTiles()` methods.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	private var _canvas:HardwareRenderer; // TODO: implement canvas version of this class for js target...
	
	#if FLX_DEBUG
	/**
	 * Sprite for visual effects (flash and fade) and drawDebug information 
	 * (bounding boxes are drawn on it) for tile render mode.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	public var debugLayer:Sprite;
	#end
	
	public var drawStack:FlxDrawStack;
	
	private static var _fillRect:FlxRect = FlxRect.get();
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		_canvas = new HardwareRenderer(camera.width, camera.height);
		_scrollRect.addChild(_canvas);
		
		#if FLX_DEBUG
		debugLayer = new Sprite();
		_scrollRect.addChild(debugLayer);
		#end
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		FlxDestroyUtil.removeChild(flashSprite, _scrollRect);
		
		#if FLX_DEBUG
		FlxDestroyUtil.removeChild(_scrollRect, debugLayer);
		debugLayer = null;
		#end
		
		FlxDestroyUtil.removeChild(_scrollRect, _canvas);
		_canvas = FlxDestroyUtil.destroy(_canvas);
		
		flashSprite = null;
		_scrollRect = null;
	}
	
	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		drawStack.drawPixels(frame, pixels, material, matrix, transform);
	}
	
	override public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform):Void
	{
		drawStack.copyPixels(frame, pixels, material, sourceRect, destPoint, transform);
	}
	
	override public function drawTriangles(bitmap:BitmapData, material:FlxMaterial, data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		drawStack.drawTriangles(bitmap, material, data, matrix, transform);
	}
	
	override public function drawUVQuad(bitmap:BitmapData, material:FlxMaterial, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		drawStack.drawUVQuad(bitmap, material, rect, uv, matrix, transform);
	}
	
	override public function drawColorQuad(material:FlxMaterial, rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		drawStack.drawColorQuad(material, rect, matrix, color, alpha);
	}
	
	override public function updateOffset():Void 
	{
		super.updateOffset();
		_canvas.resize(camera.width, camera.height);
	}
	
	override public function updatePosition():Void 
	{
		if (flashSprite != null)
		{
			flashSprite.x = camera.x * FlxG.scaleMode.scale.x + _flashOffset.x;
			flashSprite.y = camera.y * FlxG.scaleMode.scale.y + _flashOffset.y;
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
		if (_canvas != null)
		{
			_canvas.x = -0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x;
			_canvas.y = -0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y;
			
			_canvas.scaleX = camera.totalScaleX;
			_canvas.scaleY = camera.totalScaleY;
			
			#if FLX_DEBUG
			if (debugLayer != null)
			{
				debugLayer.x = _canvas.x;
				debugLayer.y = _canvas.y;
				
				debugLayer.scaleX = _canvas.scaleX;
				debugLayer.scaleY = _canvas.scaleY;
			}
			#end
		}
	}
	
	override public function updateFilters():Void 
	{
		_canvas.filters = camera.filtersEnabled ? _filters : null;
	}
	
	override public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0):Void 
	{
		// i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
		// which could appear while cameras fading
		_fillRect.set(viewOffsetX - 1, viewOffsetY - 1, viewWidth + 2, viewHeight + 2);
		
		drawStack.fillRect(_fillRect, Color, FxAlpha);
	}
	
	override public function drawFX(FxColor:FlxColor, FxAlpha:Float = 1.0):Void 
	{
		var alphaComponent:Float = FxColor.alpha;
		fill(FxColor.to24Bit(), true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * FxAlpha / 255);
	}
	
	override public function lock(useBufferLocking:Bool):Void 
	{
		drawStack.clearDrawStack();
		
		_canvas.clear();
		
		// Clearing camera's debug sprite
		#if FLX_DEBUG
		debugLayer.graphics.clear();
		#end
		fill(camera.bgColor.to24Bit(), camera.useBgAlphaBlending, camera.bgColor.alphaFloat);
	}
	
	override public function unlock(useBufferLocking:Bool):Void 
	{
		drawStack.render();
	}
	
	override public function offsetView(X:Float, Y:Float):Void 
	{
		flashSprite.x += X;
		flashSprite.y += Y;
	}
	
	override public function beginDrawDebug():Graphics 
	{
		#if FLX_DEBUG
		return debugLayer.graphics;
		#else
		return null;
		#end
	}
	
	override private function set_color(Color:FlxColor):FlxColor 
	{
		var colorTransform:ColorTransform = _canvas.transform.colorTransform;
		colorTransform.redMultiplier = Color.redFloat;
		colorTransform.greenMultiplier = Color.greenFloat;
		colorTransform.blueMultiplier = Color.blueFloat;
		_canvas.transform.colorTransform = colorTransform;
		return Color;
	}
	
	override private function set_alpha(Alpha:Float):Float 
	{
		return _canvas.alpha = Alpha;
	}
	
	override private function set_angle(Angle:Float):Float 
	{
		if (flashSprite != null)
			flashSprite.rotation = Angle;
		
		return Angle;
	}
	
	override private function set_visible(visible:Bool):Bool 
	{
		if (flashSprite != null)
			flashSprite.visible = visible;
		
		return visible;
	}
	
	override function get_display():DisplayObjectContainer 
	{
		return flashSprite;
	}
	
	override function get_canvas():DisplayObjectContainer 
	{
		return _canvas;
	}
	
	// Draw stack related code...
	
	private static var DefaultColorMaterial:FlxMaterial = new FlxMaterial();
	
	/**
	 * Currently used draw stack item
	 */
	private var _currentCommand:FlxDrawBaseCommand<Dynamic>;
	
	/**
	 * Pointer to head of stack with draw items
	 */
	private var _firstCommand:FlxDrawBaseCommand<Dynamic>;
	/**
	 * Last draw tiles item
	 */
	private var _lastTexturedQuads:FlxDrawQuadsCommand;
	/**
	 * Last draw tiles item
	 */
	private var _lastColoredQuads:FlxDrawQuadsCommand;
	/**
	 * Last draw triangles item
	 */
	private var _lastTriangles:FlxDrawTrianglesCommand;
	
	public var view:FlxHardwareView;
	
	/**
	 * Draw tiles stack items that can be reused
	 */
	private static var _texturedTilesStorage:FlxDrawQuadsCommand;
	
	/**
	 * Draw tiles stack items that can be reused
	 */
	private static var _coloredTilesStorage:FlxDrawQuadsCommand;
	
	/**
	 * Draw triangles stack items that can be reused
	 */
	private static var _trianglesStorage:FlxDrawTrianglesCommand;
	
	private var _helperMatrix:FlxMatrix = new FlxMatrix();
	
	public function destroy():Void
	{
		clearDrawStack();
		_helperMatrix = null;
		view = null;
	}
	
	private function destroyDrawItemsChain(item:FlxDrawBaseCommand<Dynamic>):Void
	{
		var next:FlxDrawBaseCommand<Dynamic>;
		while (item != null)
		{
			next = item.next;
			item = FlxDestroyUtil.destroy(item);
			item = next;
		}
	}
	
	@:noCompletion
	public function getTexturedTilesCommand(bitmap:BitmapData, colored:Bool, hasColorOffsets:Bool = false, material:FlxMaterial)
	{
		var itemToReturn:FlxDrawQuadsCommand = null;
		
		if (_currentCommand != null
			&& _currentCommand.equals(FlxDrawItemType.QUADS, bitmap, colored, hasColorOffsets, material) 
			&& _lastTexturedQuads.canAddQuad)
		{
			return _lastTexturedQuads;
		}
		
		if (_texturedTilesStorage != null)
		{
			itemToReturn = _texturedTilesStorage;
			var newHead:FlxDrawQuadsCommand = _texturedTilesStorage.nextTyped;
			itemToReturn.reset();
			_texturedTilesStorage = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawQuadsCommand(true);
		}
		
		itemToReturn.set(bitmap, colored, hasColorOffsets, material);
		
		itemToReturn.nextTyped = _lastTexturedQuads;
		_lastTexturedQuads = itemToReturn;
		
		if (_firstCommand == null)
			_firstCommand = itemToReturn;
		
		if (_currentCommand != null)
			_currentCommand.next = itemToReturn;
		
		_currentCommand = itemToReturn;
		
		return itemToReturn;
	}
	
	@:noCompletion
	public function getColoredTilesCommand(material:FlxMaterial)
	{
		var itemToReturn:FlxDrawQuadsCommand = null;
		
		if (_currentCommand != null
			&& _currentCommand.equals(FlxDrawItemType.QUADS, null, true, false, material) 
			&& _lastColoredQuads.canAddQuad)
		{
			return _lastColoredQuads;
		}
		
		if (_coloredTilesStorage != null)
		{
			itemToReturn = _coloredTilesStorage;
			var newHead:FlxDrawQuadsCommand = _coloredTilesStorage.nextTyped;
			itemToReturn.reset();
			_coloredTilesStorage = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawQuadsCommand(false);
		}
		
		itemToReturn.set(null, true, false, material);
		
		itemToReturn.nextTyped = _lastColoredQuads;
		_lastColoredQuads = itemToReturn;
		
		if (_firstCommand == null)
			_firstCommand = itemToReturn;
		
		if (_currentCommand != null)
			_currentCommand.next = itemToReturn;
		
		_currentCommand = itemToReturn;
		
		return itemToReturn;
	}
	
	@:noCompletion
	public function getNewTrianglesCommand(bitmap:BitmapData, material:FlxMaterial, colored:Bool = false):FlxDrawTrianglesCommand
	{
		var itemToReturn:FlxDrawTrianglesCommand = null;
		
		if (_trianglesStorage != null)
		{
			itemToReturn = _trianglesStorage;
			var newHead:FlxDrawTrianglesCommand = _trianglesStorage.nextTyped;
			itemToReturn.reset();
			_trianglesStorage = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawTrianglesCommand();
		}
		
		itemToReturn.set(bitmap, colored, false, material);
		
		itemToReturn.nextTyped = _lastTriangles;
		_lastTriangles = itemToReturn;
		
		if (_firstCommand == null)
			_firstCommand = itemToReturn;
		
		if (_currentCommand != null)
			_currentCommand.next = itemToReturn;
		
		_currentCommand = itemToReturn;
		
		return itemToReturn;
	}
	
	@:noCompletion
	public function getTrianglesCommand(bitmap:BitmapData, material:FlxMaterial, colored:Bool = false, numTriangles:Int):FlxDrawTrianglesCommand
	{
		if (!FlxCameraView.BATCH_TRIANGLES)
		{
			return getNewTrianglesCommand(bitmap, material, colored);
		}
		else if (_currentCommand != null
			&& _currentCommand.equals(FlxDrawItemType.TRIANGLES, bitmap, colored, false, material)
			&& _lastTriangles.canAddTriangles(numTriangles))
		{	
			return _lastTriangles;
		}
		
		return getNewTrianglesCommand(bitmap, material, colored);
	}
	
	public function fillRect(rect:FlxRect, color:FlxColor, alpha:Float = 1.0):Void
	{
		_helperMatrix.identity();
		var drawItem = getColoredTilesCommand(DefaultColorMaterial);
		drawItem.addColorQuad(rect, _helperMatrix, color, alpha, DefaultColorMaterial);
	}
	
	@:noCompletion
	public function clearDrawStack():Void
	{	
		var currTiles:FlxDrawQuadsCommand = _lastTexturedQuads;
		var newTilesHead:FlxDrawQuadsCommand;
		
		while (currTiles != null)
		{
			newTilesHead = currTiles.nextTyped;
			currTiles.reset();
			currTiles.nextTyped = _texturedTilesStorage;
			_texturedTilesStorage = currTiles;
			currTiles = newTilesHead;
		}
		
		currTiles = _lastColoredQuads;
		
		while (currTiles != null)
		{
			newTilesHead = currTiles.nextTyped;
			currTiles.reset();
			currTiles.nextTyped = _coloredTilesStorage;
			_coloredTilesStorage = currTiles;
			currTiles = newTilesHead;
		}
		
		var currTriangles:FlxDrawTrianglesCommand = _lastTriangles;
		var newTrianglesHead:FlxDrawTrianglesCommand;
		
		while (currTriangles != null)
		{
			newTrianglesHead = currTriangles.nextTyped;
			currTriangles.reset();
			currTriangles.nextTyped = _trianglesStorage;
			_trianglesStorage = currTriangles;
			currTriangles = newTrianglesHead;
		}
		
		_currentCommand = null;
		_firstCommand = null;
		_lastTexturedQuads = null;
		_lastColoredQuads = null;
		_lastTriangles = null;
	}
	
	public function render():Void
	{
		FlxDrawHardwareCommand.currentShader = null;
		
		var currItem:FlxDrawBaseCommand<Dynamic> = _firstCommand;
		while (currItem != null)
		{
			currItem.render(view);
			currItem = currItem.next;
		}
	}
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		var drawItem = getTexturedTilesCommand(frame.parent.bitmap, isColored, hasColorOffsets, material);
		
		drawItem.addQuad(frame, matrix, transform, material);
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform):Void
	{
		_helperMatrix.identity();
		_helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		var drawItem = getTexturedTilesCommand(frame.parent.bitmap, isColored, hasColorOffsets, material);
		drawItem.addQuad(frame, _helperMatrix, transform, material);
	}
	
	public function drawTriangles(bitmap:BitmapData, material:FlxMaterial, data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var drawItem = getNewTrianglesCommand(bitmap, material, data.colored);
		drawItem.data = data;
		drawItem.matrix = matrix;
		drawItem.color = transform;
		
		#if FLX_DEBUG
		drawItem.drawDebug(view.camera);
		#end
	}
	
	public function drawUVQuad(bitmap:BitmapData, material:FlxMaterial, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		var drawItem = getTexturedTilesCommand(bitmap, isColored, hasColorOffsets, material);
		drawItem.addUVQuad(bitmap, rect, uv, matrix, transform, material);
	}
	
	public function drawColorQuad(material:FlxMaterial, rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		var drawItem = getColoredTilesCommand(material);
		drawItem.addColorQuad(rect, matrix, color, alpha, material);
	}
}