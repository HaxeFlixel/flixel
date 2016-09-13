package flixel.system.render.common;

import flash.display.Graphics;
import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.FlxDrawBaseItem;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.DrawItem.FlxDrawQuadsItem;
import flixel.system.render.common.DrawItem.FlxDrawTrianglesItem;
import flixel.system.render.hardware.FlxHardwareView;
import flixel.system.render.hardware.gl.HardwareRenderer;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using flixel.util.FlxColorTransformUtil;

// TODO: add method for drawing color triangles...

/**
 * ...
 * @author Zaphod
 */
class FlxDrawStack implements IFlxDestroyable
{
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
	private var _headTiles:FlxDrawQuadsItem;
	/**
	 * Last draw triangles item
	 */
	private var _headTriangles:FlxDrawTrianglesItem;
	
	public var view:FlxHardwareView;
	
	/**
	 * Draw tiles stack items that can be reused
	 */
	private static var _storageTilesHead:FlxDrawQuadsItem;
	
	/**
	 * Draw triangles stack items that can be reused
	 */
	private static var _storageTrianglesHead:FlxDrawTrianglesItem;
	
	private var _helperMatrix:FlxMatrix = new FlxMatrix();
	
	public function new(view:FlxHardwareView) 
	{
		this.view = view;
	}
	
	public function destroy():Void
	{
		destroyDrawStackItems();
		_helperMatrix = null;
		view = null;
	}
	
	private function destroyDrawStackItems():Void
	{
		destroyDrawItemsChain(_headOfDrawStack);
		destroyDrawItemsChain(_storageTilesHead);
		destroyDrawItemsChain(_storageTrianglesHead);
	}
	
	private function destroyDrawItemsChain(item:FlxDrawBaseItem<Dynamic>):Void
	{
		var next:FlxDrawBaseItem<Dynamic>;
		while (item != null)
		{
			next = item.next;
			item = FlxDestroyUtil.destroy(item);
			item = next;
		}
	}
	
	@:noCompletion
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
	{
		#if FLX_RENDER_GL_ARRAYS
		return startTrianglesBatch(graphic, smooth, colored, blend, shader, FlxCameraView.VERTICES_PER_TILE, 0);
		#else
		var itemToReturn:FlxDrawQuadsItem = null;
		
		if (_currentDrawItem != null /* && _currentDrawItem.type == FlxDrawItemType.TILES*/ 
			&& _currentDrawItem.equals(FlxDrawItemType.TILES, graphic, colored, hasColorOffsets, blend, smooth, shader)
			&& FlxDrawBaseItem.canAddQuadToQuadsItem(_headTiles))
		{	
			return _headTiles;
		}
		
		if (_storageTilesHead != null)
		{
			itemToReturn = _storageTilesHead;
			var newHead:FlxDrawQuadsItem = _storageTilesHead.nextTyped;
			itemToReturn.reset();
			_storageTilesHead = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawQuadsItem();
		}
		
		itemToReturn.set(graphic, colored, hasColorOffsets, blend, smooth, shader);
		
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
	public function startTrianglesBatch(graphic:FlxGraphic, smooth:Bool = false,
		colored:Bool = false, ?blend:BlendMode, ?shader:FlxShader, numVertices:Int, numIndices:Int):FlxDrawTrianglesItem
	{
		if (FlxCameraView.BATCH_TRIANGLES == false)
		{
			return getNewDrawTrianglesItem(graphic, smooth, colored, blend, shader);
		}
		else if (_currentDrawItem != null /*&& _currentDrawItem.type == FlxDrawItemType.TRIANGLES*/ 
			&& _currentDrawItem.equals(FlxDrawItemType.TRIANGLES, graphic, colored, false, blend, smooth, shader)
			&& FlxDrawBaseItem.canAddTrianglesToTrianglesItem(_headTriangles, numVertices, numIndices))
		{	
			return _headTriangles;
		}
		
		return getNewDrawTrianglesItem(graphic, smooth, colored, blend, shader);
	}
	
	@:noCompletion
	public function getNewDrawTrianglesItem(graphic:FlxGraphic, smooth:Bool = false,
		colored:Bool = false, ?blend:BlendMode, ?shader:FlxShader):FlxDrawTrianglesItem
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
		
		itemToReturn.set(graphic, colored, false, blend, smooth, shader);
		
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
	
	public function fillRect(rect:FlxRect, color:FlxColor, alpha:Float = 1.0):Void
	{
		#if ((openfl >= "4.0.0") && !flash)
		_helperMatrix.identity();
		var drawItem = startQuadBatch(null, true, false);
		drawItem.addColorQuad(rect, _helperMatrix, color, alpha);
		#else
		var graphic:Graphics = view.canvas.graphics;
		var camera:FlxCamera = view.camera;
		graphic.beginFill(color, alpha);
		graphic.drawRect(rect.x, rect.y, rect.width, rect.height);
		graphic.endFill();
		#end
	}
	
	@:noCompletion
	public function clearDrawStack():Void
	{	
		var currTiles:FlxDrawQuadsItem = _headTiles;
		var newTilesHead:FlxDrawQuadsItem;
		
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
	
	public function render():Void
	{
		var currItem:FlxDrawBaseItem<Dynamic> = _headOfDrawStack;
		while (currItem != null)
		{
			currItem.render(view);
			currItem = currItem.next;
		}
	}
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		var drawItem = startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		drawItem.addQuad(frame, matrix, transform);
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		_helperMatrix.identity();
		_helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		var drawItem = startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		drawItem.addQuad(frame, _helperMatrix, transform);
	}
	
	// TODO: add support for repeat (it's true by default)
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>,
		uvtData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, 
		repeat:Bool = true, smoothing:Bool = false, ?shader:FlxShader):Void
	{
		var isColored:Bool = (transform != null && transform.hasRGBMultipliers());
		var drawItem = startTrianglesBatch(graphic, smoothing, isColored, blend, shader, Std.int(vertices.length / 2), indices.length);
		
		drawItem.addTriangles(vertices, indices, uvtData, matrix, transform);
	}
	
	public function drawUVQuad(graphic:FlxGraphic, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		#if (openfl >= "4.0.0")
		var drawItem = startQuadBatch(graphic, isColored, hasColorOffsets, blend, smoothing, shader);
		#else
		var drawItem = startTrianglesBatch(graphic, smoothing, isColored, blend, shader, FlxCameraView.VERTICES_PER_TILE, FlxCameraView.INDICES_PER_TILE);
		#end
		drawItem.addUVQuad(rect, uv, matrix, transform);
	}
	
	public function drawColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		#if (openfl >= "4.0.0")
		var drawItem = startQuadBatch(null, true, false, blend, smoothing, shader);
		#else
		var drawItem = getNewDrawTrianglesItem(null, smoothing, true, blend, shader);
		#end
		drawItem.addColorQuad(rect, matrix, color, alpha);
		
	}
}