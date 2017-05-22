package flixel.system.render.tile;

import flixel.graphics.FlxMaterial;
import flixel.graphics.FlxTrianglesData;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawCommand.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawBaseCommand;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using flixel.util.FlxColorTransformUtil;

class FlxTileView extends FlxCameraView
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
	private var _canvas:Sprite;
	
	/**
	 * Sprite for visual effects (flash and fade) and drawDebug information 
	 * (bounding boxes are drawn on it) for tile render mode.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	public var debugLayer:Sprite;
	
	private var targetGraphics:Graphics;
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		_canvas = new Sprite();
		_scrollRect.addChild(_canvas);
		
		debugLayer = new Sprite();
		_scrollRect.addChild(debugLayer);
		
		targetGraphics = _canvas.graphics;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		FlxDestroyUtil.removeChild(flashSprite, _scrollRect);
		
		FlxDestroyUtil.removeChild(_scrollRect, debugLayer);
		debugLayer = null;
		
		FlxDestroyUtil.removeChild(_scrollRect, _canvas);
		
		if (_canvas != null)
		{
			for (i in 0..._canvas.numChildren)
				_canvas.removeChildAt(0);
			
			_canvas = null;
		}
		
		clearDrawStack();
		_helperMatrix = null;
		
		flashSprite = null;
		_scrollRect = null;
	}
	
	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		var drawItem = getTexturedTilesCommand(frame.parent.bitmap, isColored, hasColorOffsets, material);
		
		drawItem.addQuad(frame, matrix, transform, material);
	}
	
	override public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform):Void
	{
		_helperMatrix.identity();
		_helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		var drawItem = getTexturedTilesCommand(frame.parent.bitmap, isColored, hasColorOffsets, material);
		drawItem.addQuad(frame, _helperMatrix, transform, material);
	}
	
	override public function drawTriangles(bitmap:BitmapData, material:FlxMaterial, data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		var drawItem = getTrianglesCommand(bitmap, material, true, data.numTriangles);
		drawItem.addTriangles(data, matrix, transform);
		data.dirty = false;
	}
	
	override public function drawUVQuad(bitmap:BitmapData, material:FlxMaterial, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		var drawItem = getTrianglesCommand(bitmap, material, isColored, FlxCameraView.TRIANGLES_PER_QUAD);
		drawItem.addUVQuad(bitmap, rect, uv, matrix, transform, material);
	}
	
	override public function drawColorQuad(material:FlxMaterial, rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		var drawItem = getTrianglesCommand(null, material, true, FlxCameraView.TRIANGLES_PER_QUAD);
		drawItem.addColorQuad(rect, matrix, color, alpha, material);
	}
	
	override public function updateOffset():Void 
	{
		super.updateOffset();
		
		#if FLX_RENDER_GL
		_canvas.resize(camera.width, camera.height);
		#end
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
			
			if (debugLayer != null)
			{
				debugLayer.x = _canvas.x;
				debugLayer.y = _canvas.y;
				
				debugLayer.scaleX = _canvas.scaleX;
				debugLayer.scaleY = _canvas.scaleY;
			}
		}
	}
	
	override public function updateFilters():Void 
	{
		flashSprite.filters = camera.filtersEnabled ? _filters : null;
	}
	
	override public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0):Void 
	{
		#if openfl_legacy // can't skip this on next, see #1793
		if (FxAlpha == 0)
			return;
		#end
		
		targetGraphics.beginFill(Color, alpha);
		// i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
		// which could appear while cameras fading
		targetGraphics.drawRect(viewOffsetX - 1, viewOffsetY - 1, viewWidth + 2, viewHeight + 2);
		targetGraphics.endFill();
	}
	
	override public function drawFX(FxColor:FlxColor, FxAlpha:Float = 1.0):Void 
	{
		var alphaComponent:Float = FxColor.alpha;
		targetGraphics = debugLayer.graphics;
		fill(FxColor.to24Bit(), true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * FxAlpha / 255);
		targetGraphics = _canvas.graphics;
	}
	
	override public function lock(useBufferLocking:Bool):Void 
	{
		clearDrawStack();
		
		_canvas.graphics.clear();
		
		// Clearing camera's debug sprite
		debugLayer.graphics.clear();
		
		if (camera.useBgColorFill)
		{
			targetGraphics = _canvas.graphics;
			fill(camera.bgColor.to24Bit(), camera.useBgAlphaBlending, camera.bgColor.alphaFloat);
		}
	}
	
	override public function unlock(useBufferLocking:Bool):Void 
	{
		var currItem:FlxDrawBaseCommand<Dynamic> = _firstCommand;
		while (currItem != null)
		{
			currItem.render(this);
			currItem = currItem.next;
		}
	}
	
	override public function offsetView(X:Float, Y:Float):Void 
	{
		flashSprite.x += X;
		flashSprite.y += Y;
	}
	
	override public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:Int, thickness:Float = 1.0, alpha:Float = 1.0):Void 
	{
		var gfx:Graphics = debugLayer.graphics;
		gfx.lineStyle(thickness, color, alpha);
		gfx.drawRect(x, y, width, height);
	}
	
	override public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:Int, alpha:Float = 1.0):Void 
	{
		var gfx:Graphics = debugLayer.graphics;
		gfx.beginFill(color, alpha);
		gfx.lineStyle();
		gfx.drawRect(x, y, width, height);
		gfx.endFill();
	}
	
	override public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:Int, thickness:Float = 1.0, alpha:Float = 1.0):Void 
	{
		var gfx:Graphics = debugLayer.graphics;
		gfx.lineStyle(thickness, color, alpha);
		gfx.moveTo(x1, y1);
		gfx.lineTo(x2, y2);
	}
	
	override public function drawDebugTriangles(matrix:FlxMatrix, data:FlxTrianglesData, color:Int, thickness:Float = 1, alpha:Float = 1.0):Void
	{
		var gfx:Graphics = debugLayer.graphics;
		gfx.lineStyle(thickness, color, alpha);
		
		var numTriangles = Std.int(data.indices.length / 3);
		var vertices = data.vertices;
		var indices = data.indices;
		
		var x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float;
		var xt1:Float, yt1:Float, xt2:Float, yt2:Float, xt3:Float, yt3:Float;
		var index1:Int, index2:Int, index3:Int;
		
		for (i in 0...numTriangles)
		{
			index1 = indices[3 * i];
			index2 = index1 + 1;
			index3 = index2 + 1;
			
			x1 = vertices[index1 * 2];
			y1 = vertices[index1 * 2 + 1];
			
			x2 = vertices[index2 * 2];
			y2 = vertices[index2 * 2 + 1];
			
			x3 = vertices[index3 * 2];
			y3 = vertices[index3 * 2 + 1];
			
			xt1 = matrix.transformX(x1, y1);
			yt1 = matrix.transformY(x1, y1);
			
			xt2 = matrix.transformX(x2, y2);
			yt2 = matrix.transformY(x2, y2);
			
			xt3 = matrix.transformX(x3, y3);
			yt3 = matrix.transformY(x3, y3);
			
			gfx.moveTo(x1, y1);
			gfx.lineTo(x2, y2);
			gfx.lineTo(x3, y3);
			gfx.lineTo(x1, y1);
		}
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
	 * Last draw triangles item
	 */
	private var _lastTriangles:FlxDrawTrianglesCommand;
	
	/**
	 * Draw tiles stack items that can be reused
	 */
	private static var _texturedTilesStorage:FlxDrawQuadsCommand;
	
	/**
	 * Draw triangles stack items that can be reused
	 */
	private static var _trianglesStorage:FlxDrawTrianglesCommand;
	
	private var _helperMatrix:FlxMatrix = new FlxMatrix();
	
	private function getTexturedTilesCommand(bitmap:BitmapData, colored:Bool, hasColorOffsets:Bool = false, material:FlxMaterial)
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
	
	private function getNewTrianglesCommand(bitmap:BitmapData, material:FlxMaterial, colored:Bool = false):FlxDrawTrianglesCommand
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
	
	private function getTrianglesCommand(bitmap:BitmapData, material:FlxMaterial, colored:Bool = false, numTriangles:Int):FlxDrawTrianglesCommand
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
	
	private function clearDrawStack():Void
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
		_lastTriangles = null;
	}
}