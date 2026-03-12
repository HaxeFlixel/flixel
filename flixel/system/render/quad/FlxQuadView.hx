package flixel.system.render.quad;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.FlxCameraView;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

using flixel.util.FlxColorTransformUtil;

class FlxQuadView extends FlxCameraView
{
	/**
	 * Sprite used for actual rendering in tile render mode (instead of `_flashBitmap` for blitting).
	 * Its graphics is used as a drawing surface for `drawTriangles()` and `drawTiles()` methods.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	public var canvas:Sprite;
	
	#if FLX_DEBUG
	/**
	 * Sprite for visual effects (flash and fade) and drawDebug information
	 * (bounding boxes are drawn on it) for tile render mode.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	public var debugLayer:Sprite;
	#end
	
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
	var _scrollRect:Sprite = new Sprite();
	
	var _flashOffset:FlxPoint = FlxPoint.get();
	
	@:allow(flixel.system.render.FlxCameraView)
	function new(camera:FlxCamera)
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		canvas = new Sprite();
		_scrollRect.addChild(canvas);
		
		#if FLX_DEBUG
		debugLayer = new Sprite();
		_scrollRect.addChild(debugLayer);
		#end
	}
	
	override function destroy():Void
	{
		super.destroy();
		
		FlxDestroyUtil.removeChild(flashSprite, _scrollRect);
		#if FLX_DEBUG
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
		
		flashSprite = null;
		_scrollRect = null;
		_flashOffset = FlxDestroyUtil.put(_flashOffset);
	}
	
	// =============================================================================
	//{ region                            RENDERING
	// =============================================================================
	
	override function render()
	{
		// super.render();
		
		flashSprite.filters = camera.filtersEnabled ? camera.filters : null;
		
		var currItem:FlxDrawBaseItem<Dynamic> = _headOfDrawStack;
		while (currItem != null)
		{
			currItem.render(camera);
			currItem = currItem.next;
		}

		camera.drawFX();
	}
	
	override function clear()
	{
		// super.clear();
		
		clearDrawStack();
		
		canvas.graphics.clear();
		#if FLX_DEBUG
		// Clearing camera's debug sprite
		debugLayer.graphics.clear();
		#end
		
		fill(camera.bgColor, camera.useBgAlphaBlending);
	}
	
	function clearDrawStack():Void
	{
		var currTiles = _headTiles;
		var newTilesHead;
		
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
	
	override function fill(color:FlxColor, blendAlpha:Bool = true)
	{
		// super.fill(color, blendAlpha);
		
		canvas.graphics.overrideBlendMode(null);
		canvas.graphics.beginFill(color.rgb, color.alphaFloat);
		// i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
		// which could appear while cameras fading
		canvas.graphics.drawRect(camera.viewMarginLeft - 1, camera.viewMarginTop - 1, camera.viewWidth + 2, camera.viewHeight + 2);
		canvas.graphics.endFill();
	}
	
	// =============================================================================
	//} endregion                         RENDERING
	// =============================================================================
	
	// =============================================================================
	//{ region                            INTERNALS
	// =============================================================================
	
	function offsetView(x:Float, y:Float)
	{
		flashSprite.x += x;
		flashSprite.y += y;
	}
	
	function updatePosition()
	{
		if (flashSprite != null)
		{
			flashSprite.x = camera.x * FlxG.scaleMode.scale.x + _flashOffset.x;
			flashSprite.y = camera.y * FlxG.scaleMode.scale.y + _flashOffset.y;
		}
	}
	
	function updateOffset()
	{
		_flashOffset.x = camera.width * 0.5 * FlxG.scaleMode.scale.x * camera.initialZoom;
		_flashOffset.y = camera.height * 0.5 * FlxG.scaleMode.scale.y * camera.initialZoom;
	}
	
	function updateScrollRect()
	{
		final rect:Rectangle = (_scrollRect != null) ? _scrollRect.scrollRect : null;
		
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
	
	function updateScale() {}
	
	function updateInternals()
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
				
				debugLayer.scaleX = camera.totalScaleX;
				debugLayer.scaleY = camera.totalScaleY;
			}
			#end
		}
	}
	
	override function set_color(value:FlxColor):FlxColor
	{
		final colorTransform:ColorTransform = canvas.transform.colorTransform;
		
		colorTransform.redMultiplier = value.redFloat;
		colorTransform.greenMultiplier = value.greenFloat;
		colorTransform.blueMultiplier = value.blueFloat;
		
		canvas.transform.colorTransform = colorTransform;
		
		return super.set_color(value);
	}
	
	override function set_alpha(value:Float):Float
	{
		canvas.alpha = alpha;
		return super.set_alpha(value);
	}
	
	override function set_angle(value:Float):Float
	{
		flashSprite.rotation = value;
		return super.set_angle(value);
	}
	
	override function set_visible(value:Bool):Bool
	{
		flashSprite.visible = value;
		return super.set_visible(value);
	}
	
	function get_display():DisplayObjectContainer
	{
		return flashSprite;
	}
	
	/**
	 * Currently used draw stack item
	 */
	var _currentDrawItem:FlxDrawBaseItem<Dynamic>;
	
	/**
	 * Pointer to head of stack with draw items
	 */
	var _headOfDrawStack:FlxDrawBaseItem<Dynamic>;
	
	/**
	 * Last draw tiles item
	 */
	var _headTiles:FlxDrawQuadsItem;
	
	/**
	 * Last draw triangles item
	 */
	var _headTriangles:FlxDrawTrianglesItem;
	
	/**
	 * Draw tiles stack items that can be reused
	 */
	static var _storageTilesHead:FlxDrawQuadsItem;
	
	/**
	 * Draw triangles stack items that can be reused
	 */
	static var _storageTrianglesHead:FlxDrawTrianglesItem;
	
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets = false, ?blend:BlendMode, smooth = false, ?shader:FlxShader)
	{
		#if FLX_RENDER_TRIANGLE
		return startTrianglesBatch(graphic, smooth, colored, blend);
		#else
		var itemToReturn = null;
		
		if (_currentDrawItem != null
			&& _currentDrawItem.type == FlxDrawItemType.TILES
			&& _headTiles.graphics == graphic
			&& _headTiles.colored == colored
			&& _headTiles.hasColorOffsets == hasColorOffsets
			&& _headTiles.blend == blend
			&& _headTiles.antialiasing == smooth
			&& _headTiles.shader == shader)
		{
			return _headTiles;
		}
		
		if (_storageTilesHead != null)
		{
			itemToReturn = _storageTilesHead;
			var newHead = _storageTilesHead.nextTyped;
			itemToReturn.reset();
			_storageTilesHead = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawQuadsItem();
		}
		
		// TODO: catch this error when the dev actually messes up, not in the draw phase
		if (graphic.isDestroyed)
			throw 'Cannot queue ${graphic.key}. This sprite was destroyed.';
			
		itemToReturn.graphics = graphic;
		itemToReturn.antialiasing = smooth;
		itemToReturn.colored = colored;
		itemToReturn.hasColorOffsets = hasColorOffsets;
		itemToReturn.blend = blend;
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
	
	public function startTrianglesBatch(graphic:FlxGraphic, smoothing = false, isColored = false, ?blend:BlendMode, ?hasColorOffsets:Bool,
			?shader:FlxShader):FlxDrawTrianglesItem
	{
		if (_currentDrawItem != null
			&& _currentDrawItem.type == FlxDrawItemType.TRIANGLES
			&& _headTriangles.graphics == graphic
			&& _headTriangles.antialiasing == smoothing
			&& _headTriangles.colored == isColored
			&& _headTriangles.blend == blend
			&& _headTriangles.hasColorOffsets == hasColorOffsets
			&& _headTriangles.shader == shader)
		{
			return _headTriangles;
		}
		
		return getNewDrawTrianglesItem(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
	}
	
	public function getNewDrawTrianglesItem(graphic:FlxGraphic, smoothing = false, isColored = false, ?blend:BlendMode, ?hasColorOffsets:Bool,
			?shader:FlxShader):FlxDrawTrianglesItem
	{
		var itemToReturn:FlxDrawTrianglesItem = null;
		
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
		itemToReturn.blend = blend;
		itemToReturn.hasColorOffsets = hasColorOffsets;
		itemToReturn.shader = shader;
		
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
	
	//} endregion                         INTERNALS
	// =============================================================================
	
	// =============================================================================
	//{ region                            DEBUG DRAW
	// =============================================================================
	
	public function beginDrawDebug() {}
	
	public function endDrawDebug() {}
	
	#if FLX_DEBUG
	
	public function getDebugBuffer():FlxVertexBuffer
	{
		return debugLayer.graphics;
	}
	
	static final toDebugHelper = new openfl.geom.Point();
	function worldToDebugX(worldX:Float)//TODO: rename?
	{
		toDebugHelper.setTo(worldX, 0);
		return canvas.localToGlobal(toDebugHelper).x;
	}
	
	function worldToDebugY(worldY:Float)//TODO: rename?
	{
		toDebugHelper.setTo(worldY, 0);
		return canvas.localToGlobal(toDebugHelper).y;
	}
	#end
	
	//} endregion                         DEBUG DRAW
	// =============================================================================
}
