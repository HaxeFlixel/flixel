package flixel.system.render.common;

import flash.display.Graphics;
import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxTrianglesData;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.DrawItem.FlxDrawQuadsCommand;
import flixel.system.render.common.DrawItem.FlxDrawTrianglesCommand;
import flixel.system.render.hardware.FlxHardwareView;
import flixel.system.render.hardware.gl.FlxDrawHardwareCommand;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using flixel.util.FlxColorTransformUtil;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawStack implements IFlxDestroyable
{
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
	
	public function new(view:FlxHardwareView) 
	{
		this.view = view;
	}
	
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
	public function getTexturedTilesCommand(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
	{
		var itemToReturn:FlxDrawQuadsCommand = null;
		
		if (_currentCommand != null
			&& _currentCommand.equals(FlxDrawItemType.QUADS, graphic, colored, hasColorOffsets, blend, smooth, true, shader) 
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
		
		itemToReturn.set(graphic, colored, hasColorOffsets, blend, smooth, true, shader);
		
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
	public function getColoredTilesCommand(?blend:BlendMode, ?shader:FlxShader)
	{
		var itemToReturn:FlxDrawQuadsCommand = null;
		
		if (_currentCommand != null
			&& _currentCommand.equals(FlxDrawItemType.QUADS, null, true, false, blend, false, false, shader) 
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
		
		itemToReturn.set(null, true, false, blend, false, false, shader);
		
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
	public function getNewTrianglesCommand(graphic:FlxGraphic, smooth:Bool = false,
		colored:Bool = false, repeat:Bool = true, ?blend:BlendMode, ?shader:FlxShader):FlxDrawTrianglesCommand
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
		
		itemToReturn.set(graphic, colored, false, blend, smooth, repeat, shader);
		
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
	public function getTrianglesCommand(graphic:FlxGraphic, smooth:Bool = false,
		colored:Bool = false, repeat:Bool = true, ?blend:BlendMode, ?shader:FlxShader, numTriangles:Int):FlxDrawTrianglesCommand
	{
		if (!FlxCameraView.BATCH_TRIANGLES)
		{
			return getNewTrianglesCommand(graphic, smooth, colored, repeat, blend, shader);
		}
		else if (_currentCommand != null
			&& _currentCommand.equals(FlxDrawItemType.TRIANGLES, graphic, colored, false, blend, smooth, repeat, shader)
			&& _lastTriangles.canAddTriangles(numTriangles))
		{	
			return _lastTriangles;
		}
		
		return getNewTrianglesCommand(graphic, smooth, colored, repeat, blend, shader);
	}
	
	public function fillRect(rect:FlxRect, color:FlxColor, alpha:Float = 1.0):Void
	{
		#if FLX_RENDER_GL
		_helperMatrix.identity();
		var drawItem = getColoredTilesCommand(null, null);
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
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		var drawItem = getTexturedTilesCommand(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		
		drawItem.addQuad(frame, matrix, transform, blend, smoothing);
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		_helperMatrix.identity();
		_helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		var drawItem = getTexturedTilesCommand(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		drawItem.addQuad(frame, _helperMatrix, transform, blend, smoothing);
	}
	
	public function drawTriangles(graphic:FlxGraphic, data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, 
		repeat:Bool = true, smoothing:Bool = false, ?shader:FlxShader):Void
	{
		var isColored:Bool = data.colored;
		
	#if FLX_RENDER_GL
		var drawItem = getNewTrianglesCommand(graphic, smoothing, isColored, repeat, blend, shader);
		drawItem.data = data;
		drawItem.matrix = matrix;
		drawItem.color = transform;
		
		#if FLX_DEBUG
		drawItem.drawDebug(view.camera);
		#end
	#else
		isColored = isColored || (transform != null && transform.hasRGBMultipliers());
		
		var drawItem = getTrianglesCommand(graphic, smoothing, isColored, repeat, blend, shader, data.numTriangles);
		drawItem.addTriangles(data, matrix, transform);
		data.dirty = false;
	#end
	}
	
	public function drawUVQuad(graphic:FlxGraphic, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		#if (openfl >= "4.0.0")
		var drawItem = getTexturedTilesCommand(graphic, isColored, hasColorOffsets, blend, smoothing, shader);
		#else
		var drawItem = getTrianglesCommand(graphic, smoothing, isColored, true, blend, shader, FlxCameraView.TRIANGLES_PER_QUAD);
		#end
		drawItem.addUVQuad(graphic, rect, uv, matrix, transform, blend, smoothing);
	}
	
	public function drawColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		#if (openfl >= "4.0.0")
		var drawItem = getColoredTilesCommand(blend, shader);
		#else
		var drawItem = getTrianglesCommand(null, smoothing, true, true, blend, shader, FlxCameraView.TRIANGLES_PER_QUAD);
		#end
		drawItem.addColorQuad(rect, matrix, color, alpha, blend, smoothing, shader);
	}
}