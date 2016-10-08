package flixel.tile;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxImageFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
using flixel.util.FlxColorTransformUtil;

@:keep @:bitmap("assets/images/tile/autotiles.png")
class GraphicAuto extends BitmapData {}

@:keep @:bitmap("assets/images/tile/autotiles_alt.png")
class GraphicAutoAlt extends BitmapData {}

// TODO: try to solve "tile tearing problem" (1px gap between tile at certain conditions) on native targets

/**
 * This is a traditional tilemap display and collision class. It takes a string of comma-separated numbers and then associates
 * those values with tiles from the sheet you pass in. It also includes some handy static parsers that can convert
 * arrays or images into strings that can be loaded.
 */
class FlxTilemap extends FlxBaseTilemap<FlxTile>
{
	/** 
	 * A helper buffer for calculating number of columns and rows when the game size changed
	 * We are only using its member functions that's why it is an empty instance
	 */
	private static var _helperBuffer:FlxTilemapBuffer = Type.createEmptyInstance(FlxTilemapBuffer);
	
	// TODO: remove this hack and add docs about how to avoid tearing problem by preparing assets and some code...
	/**
	 * Try to eliminate 1 px gap between tiles in tile render mode by increasing tile scale, 
	 * so the tile will look one pixel wider than it is.
	 */
	public var useScaleHack:Bool = true;
	
	/**
	 * Changes the size of this tilemap. Default is (1, 1). 
	 * Anything other than the default is very slow with blitting!
	 */
	public var scale(default, null):FlxPoint;

	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 * @since 4.1.0
	 */
	public var antialiasing(default, set):Bool = false;
	
	/**
	 * Use to offset the drawing position of the tilemap,
	 * just like FlxSprite.
	 */
	public var offset(default, null):FlxPoint = FlxPoint.get();
	
	/**
	 * Rendering variables.
	 */
	public var frames(default, set):FlxFramesCollection;
	public var graphic(default, set):FlxGraphic;
	
	/**
	 * Tints the whole sprite to a color (0xRRGGBB format) - similar to OpenGL vertex colors. You can use
	 * 0xAARRGGBB colors, but the alpha value will simply be ignored. To change the opacity use alpha. 
	 */
	public var color(default, set):FlxColor = 0xffffff;
	
	/**
	 * Set alpha to a number between 0 and 1 to change the opacity of the sprite.
	 */
	public var alpha(default, set):Float = 1.0;
	
	public var colorTransform(default, null):ColorTransform = new ColorTransform();
	
	/**
	 * Blending modes, just like Photoshop or whatever, e.g. "multiply", "screen", etc.
	 */
	public var blend(default, set):BlendMode = null;
	
	/**
	 * GLSL shader for this tilemap. Only works with OpenFL Next or WebGL.
	 * Avoid changing it frequently as this is a costly operation.
	 * @since 4.1.0
	 */
	#if openfl_legacy @:noCompletion #end
	public var shader:FlxShader;
	
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashPoint:Point = new Point();
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashRect:Rectangle = new Rectangle();
	/**
	 * Internal list of buffers, one for each camera, used for drawing the tilemaps.
	 */
	private var _buffers:Array<FlxTilemapBuffer> = [];
	/**
	 * Internal, the width of a single tile.
	 */
	private var _tileWidth:Int = 0;
	/**
	 * Internal, the height of a single tile.
	 */
	private var _tileHeight:Int = 0;
	
	private var _scaledTileWidth:Float = 0;
	private var _scaledTileHeight:Float = 0;
	
	#if FLX_DEBUG
	private var _debugTileNotSolid:BitmapData;
	private var _debugTilePartial:BitmapData;
	private var _debugTileSolid:BitmapData;
	private var _debugRect:Rectangle;
	#end
	
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods. Used only in tile rendering mode
	 */
	private var _helperPoint:Point;
	
	/**
	 * Rendering helper, used for tile's frame transoformations (only in tile rendering mode).
	 */
	private var _matrix:FlxMatrix;
	
	/**
	 * Whether buffers need to be checked again next draw().
	 */
	private var _checkBufferChanges:Bool = false;
	
	public function new()
	{
		super();

		if (FlxG.renderTile)
		{
			_helperPoint = new Point();
			_matrix = new FlxMatrix();
		}
		
		scale = new FlxCallbackPoint(setScaleXCallback, setScaleYCallback, setScaleXYCallback);
		scale.set(1, 1);
		
		FlxG.signals.gameResized.add(onGameResized);
		FlxG.cameras.cameraAdded.add(onCameraChanged);
		FlxG.cameras.cameraRemoved.add(onCameraChanged);
		FlxG.cameras.cameraResized.add(onCameraChanged);
		
		#if FLX_DEBUG
		if (FlxG.renderBlit)
			FlxG.debugger.drawDebugChanged.add(onDrawDebugChanged);
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_flashPoint = null;
		_flashRect = null;
		
		_tileObjects = FlxDestroyUtil.destroyArray(_tileObjects);
		_buffers = FlxDestroyUtil.destroyArray(_buffers);
		
		if (FlxG.renderBlit)
		{
			#if FLX_DEBUG
			_debugRect = null;
			_debugTileNotSolid = null;
			_debugTilePartial = null;
			_debugTileSolid = null;
			#end
		}
		else
		{
			_helperPoint = null;
			_matrix = null;
		}
		
		frames = null;
		graphic = null;
		
		// need to destroy FlxCallbackPoints
		scale = FlxDestroyUtil.destroy(scale);
		offset = FlxDestroyUtil.put(offset);
		
		colorTransform = null;
		
		FlxG.signals.gameResized.remove(onGameResized);
		FlxG.cameras.cameraAdded.remove(onCameraChanged);
		FlxG.cameras.cameraRemoved.remove(onCameraChanged);
		FlxG.cameras.cameraResized.remove(onCameraChanged);
		
		#if FLX_DEBUG
		if (FlxG.renderBlit)
			FlxG.debugger.drawDebugChanged.remove(onDrawDebugChanged);
		#end
		
		shader = null;
		
		super.destroy();
	}
	
	private function set_frames(value:FlxFramesCollection):FlxFramesCollection
	{
		frames = value;
		
		if (value != null)
		{
			_tileWidth = Std.int(value.frames[0].sourceSize.x);
			_tileHeight = Std.int(value.frames[0].sourceSize.y);
			_flashRect.setTo(0, 0, _tileWidth, _tileHeight);
			graphic = value.parent;
			postGraphicLoad();
		}
		
		return value;
	}
	
	private function onGameResized(_, _):Void
	{
		_checkBufferChanges = true;
	}
	
	private function onCameraChanged(_):Void
	{
		_checkBufferChanges = true;
	}
	
	override private function cacheGraphics(TileWidth:Int, TileHeight:Int, TileGraphic:FlxTilemapGraphicAsset):Void 
	{
		if (Std.is(TileGraphic, FlxFramesCollection))
		{
			frames = cast TileGraphic;
			return;
		}
		
		var graph:FlxGraphic = FlxG.bitmap.add(cast TileGraphic);
		if (graph == null)
			return;

		// Figure out the size of the tiles
		_tileWidth = TileWidth;
		if (_tileWidth <= 0)
			_tileWidth = graph.height;
		
		_tileHeight = TileHeight;
		if (_tileHeight <= 0)
			_tileHeight = _tileWidth;
		
		frames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(_tileWidth, _tileHeight));
	}
	
	override private function initTileObjects():Void 
	{
		if (frames == null)
			return;
		
		_tileObjects = FlxDestroyUtil.destroyArray(_tileObjects);
		// Create some tile objects that we'll use for overlap checks (one for each tile)
		_tileObjects = new Array<FlxTile>();
		
		var length:Int = frames.numFrames;
		length += _startingIndex;
		
		for (i in 0...length)
			_tileObjects[i] = new FlxTile(this, i, _tileWidth, _tileHeight, (i >= _drawIndex), (i >= _collideIndex) ? allowCollisions : FlxObject.NONE);
		
		// Create debug tiles for rendering bounding boxes on demand
		#if FLX_DEBUG
		if (FlxG.renderBlit)
		{
			_debugTileNotSolid = makeDebugTile(FlxColor.BLUE);
			_debugTilePartial = makeDebugTile(FlxColor.PINK);
			_debugTileSolid = makeDebugTile(FlxColor.GREEN);
		}
		#end
	}
	
	override private function computeDimensions():Void 
	{
		_scaledTileWidth = _tileWidth * scale.x;
		_scaledTileHeight = _tileHeight * scale.y;
		
		// Then go through and create the actual map
		width = widthInTiles * _scaledTileWidth;
		height = heightInTiles * _scaledTileHeight;
	}
	
	override private function updateMap():Void 
	{
		#if FLX_DEBUG
		if (FlxG.renderBlit)
			_debugRect = new Rectangle(0, 0, _tileWidth, _tileHeight);
		#end
		
		var numTiles:Int = _tileObjects.length;
		for (i in 0...numTiles)
			updateTile(i);
	}
	
	#if FLX_DEBUG
	override public function drawDebugOnCamera(Camera:FlxCamera):Void
	{
		if (!FlxG.renderTile)
			return;
		
		var buffer:FlxTilemapBuffer = null;
		var l:Int = FlxG.cameras.list.length;
		
		for (i in 0...l)
		{
			if (FlxG.cameras.list[i] == Camera)
			{
				buffer = _buffers[i];
				break;
			}
		}
		
		if (buffer == null)
			return;
		
		// Copied from getScreenPosition()
		_helperPoint.x = x - Camera.scroll.x * scrollFactor.x;
		_helperPoint.y = y - Camera.scroll.y * scrollFactor.y;
		
		var debugColor:FlxColor;
		var drawX:Float;
		var drawY:Float;
		
		var rectWidth:Float = _scaledTileWidth;
		var rectHeight:Float = _scaledTileHeight;
		
		// Copy tile images into the tile buffer
		// Modified from getScreenPosition()
		_point.x = (Camera.scroll.x * scrollFactor.x) - x; 
		_point.y = (Camera.scroll.y * scrollFactor.y) - y;
		var screenXInTiles:Int = Math.floor(_point.x / _scaledTileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _scaledTileHeight);
		var screenRows:Int = buffer.rows;
		var screenColumns:Int = buffer.columns;
		
		// Bound the upper left corner
		screenXInTiles = Std.int(FlxMath.bound(screenXInTiles, 0, widthInTiles - screenColumns));
		screenYInTiles = Std.int(FlxMath.bound(screenYInTiles, 0, heightInTiles - screenRows));
		
		var rowIndex:Int = screenYInTiles * widthInTiles + screenXInTiles;
		var columnIndex:Int;
		var tile:FlxTile;
		
		for (row in 0...screenRows)
		{
			columnIndex = rowIndex;
			
			for (column in 0...screenColumns)
			{
				tile = _tileObjects[_data[columnIndex]];
				
				if (tile != null && tile.visible)
				{
					drawX = _helperPoint.x + (columnIndex % widthInTiles) * rectWidth;
					drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * rectHeight;
					
					if (tile.allowCollisions <= FlxObject.NONE)
					{
						debugColor = FlxColor.BLUE;
					}
					else if (tile.allowCollisions != FlxObject.ANY)
					{
						debugColor = FlxColor.PINK;
					}
					else
					{
						debugColor = FlxColor.GREEN;
					}
					
					// Copied from makeDebugTile
					var gfx:Graphics = Camera.debugLayer.graphics;
					gfx.lineStyle(1, debugColor, 0.5);
					gfx.drawRect(drawX, drawY, rectWidth, rectHeight);
				}
				
				columnIndex++;
			}
			
			rowIndex += widthInTiles;
		}
	}
	#end
	
	/**
	 * Draws the tilemap buffers to the cameras.
	 */
	override public function draw():Void
	{
		// don't try to render a tilemap that isn't loaded yet
		if (graphic == null)
			return;
		
		if (_checkBufferChanges)
		{
			refreshBuffers();
			_checkBufferChanges = false;
		}
		
		var camera:FlxCamera;
		var buffer:FlxTilemapBuffer;
		var l:Int = cameras.length;
		
		for (i in 0...l)
		{
			camera = cameras[i];
			
			if (!camera.visible || !camera.exists)
				continue;
			
			if (_buffers[i] == null)
				_buffers[i] = createBuffer(camera);
			
			buffer = _buffers[i];
			
			if (FlxG.renderBlit)
			{
				getScreenPosition(_point, camera).subtractPoint(offset).add(buffer.x, buffer.y);
				buffer.dirty = buffer.dirty || _point.x > 0 || (_point.y > 0) || (_point.x + buffer.width < camera.width) || (_point.y + buffer.height < camera.height);
				
				if (buffer.dirty)
					drawTilemap(buffer, camera);
				
				getScreenPosition(_point, camera).subtractPoint(offset).add(buffer.x, buffer.y).copyToFlash(_flashPoint);
				buffer.draw(camera, _flashPoint, scale.x, scale.y);
			}
			else
			{
				drawTilemap(buffer, camera);
			}
			
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
	
	private function refreshBuffers():Void
	{
		for (i in 0...cameras.length)
		{
			var camera = cameras[i];
			var buffer = _buffers[i];
			
			// Calculate the required number of columns and rows
			_helperBuffer.updateColumns(_tileWidth, widthInTiles, scale.x, camera);
			_helperBuffer.updateRows(_tileHeight, heightInTiles, scale.y, camera);
			
			// Create a new buffer if the number of columns and rows differs
			if (buffer == null || _helperBuffer.columns != buffer.columns || _helperBuffer.rows != buffer.rows)
			{
				if (buffer != null)
					buffer.destroy();
				
				_buffers[i] = createBuffer(camera);
			}
		}
	}
	
	/**
	 * Set the dirty flag on all the tilemap buffers.
	 * Basically forces a reset of the drawn tilemaps, even if it wasn'tile necessary.
	 * 
	 * @param	Dirty		Whether to flag the tilemap buffers as dirty or not.
	 */
	override public function setDirty(Dirty:Bool = true):Void
	{
		for (buffer in _buffers)
			buffer.dirty = true;
	}

	/**
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 * 
	 * @param	Object				The FlxObject you are checking for overlaps against.
	 * @param	Callback			An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a FlxTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param	FlipCallbackParams	Used to preserve A-B list ordering from FlxObject.separate() - returns the FlxTile object as the second parameter instead.
	 * @param	Position			Optional, specify a custom position for the tilemap (useful for overlapsAt()-type funcitonality).
	 * @return	Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	override public function overlapsWithCallback(Object:FlxObject, ?Callback:FlxObject->FlxObject->Bool, FlipCallbackParams:Bool = false, ?Position:FlxPoint):Bool
	{
		var results:Bool = false;
		
		var xPos:Float = x;
		var yPos:Float = y;
		
		if (Position != null)
		{
			xPos = Position.x;
			yPos = Position.y;
		}
		
		// Figure out what tiles we need to check against
		var selectionX:Int = Math.floor((Object.x - xPos) / _scaledTileWidth);
		var selectionY:Int = Math.floor((Object.y - yPos) / _scaledTileHeight);
		var selectionWidth:Int = selectionX + Math.ceil(Object.width / _scaledTileWidth) + 1;
		var selectionHeight:Int = selectionY + Math.ceil(Object.height / _scaledTileHeight) + 1;
		
		// Then bound these coordinates by the map edges
		selectionX = Std.int(FlxMath.bound(selectionX, 0, widthInTiles));
		selectionY = Std.int(FlxMath.bound(selectionY, 0, heightInTiles));
		selectionWidth = Std.int(FlxMath.bound(selectionWidth, 0, widthInTiles));
		selectionHeight = Std.int(FlxMath.bound(selectionHeight, 0, heightInTiles));
		
		// Then loop through this selection of tiles
		var rowStart:Int = selectionY * widthInTiles;
		var column:Int;
		var tile:FlxTile;
		var overlapFound:Bool;
		var deltaX:Float = xPos - last.x;
		var deltaY:Float = yPos - last.y;
		
		for (row in selectionY...selectionHeight)
		{
			column = selectionX;
			
			while (column < selectionWidth)
			{
				var index:Int = rowStart + column;
				if (index < 0 || index > _data.length - 1)
				{
					column++;
					continue;
				}
				
				var dataIndex:Int = _data[index];
				if (dataIndex < 0)
				{
					column++;
					continue;
				}
				
				tile = _tileObjects[dataIndex];
				tile.width = _scaledTileWidth;
				tile.height = _scaledTileHeight;
				tile.x = xPos + column * tile.width;
				tile.y = yPos + row * tile.height;
				tile.last.x = tile.x - deltaX;
				tile.last.y = tile.y - deltaY;
				
				overlapFound =
					((Object.x + Object.width) > tile.x)  && (Object.x < (tile.x + tile.width)) && 
					((Object.y + Object.height) > tile.y) && (Object.y < (tile.y + tile.height));
				
				if (tile.allowCollisions != FlxObject.NONE)
				{
					if (Callback != null)
					{
						if (FlipCallbackParams)
						{
							overlapFound = Callback(Object, tile);
						}
						else
						{
							overlapFound = Callback(tile, Object);
						}
					}
				}
				
				if (overlapFound)
				{
					if (tile.callbackFunction != null && (tile.filter == null || Std.is(Object, tile.filter)))
					{
						tile.mapIndex = rowStart + column;
						tile.callbackFunction(tile, Object);
					}
					
					if (tile.allowCollisions != FlxObject.NONE)
						results = true;
				}
				
				column++;
			}
			
			rowStart += widthInTiles;
		}
		
		return results;
	}

	override public function getTileIndexByCoords(Coord:FlxPoint):Int
	{
		var result = Std.int((Coord.y - y) / _scaledTileHeight) * widthInTiles + Std.int((Coord.x - x) / _scaledTileWidth);
		Coord.putWeak();
		return result;
	}
	
	override public function getTileCoordsByIndex(Index:Int, Midpoint:Bool = true):FlxPoint
	{
		var point = FlxPoint.get(x + (Index % widthInTiles) * _scaledTileWidth, y + Std.int(Index / widthInTiles) * _scaledTileHeight);
		if (Midpoint)
		{
			point.x += _scaledTileWidth * 0.5;
			point.y += _scaledTileHeight * 0.5;
		}
		return point;
	}
	
	/**
	 * Returns a new array full of every coordinate of the requested tile type.
	 * 
	 * @param	Index		The requested tile type.
	 * @param	Midpoint	Whether to return the coordinates of the tile midpoint, or upper left corner. Default is true, return midpoint.
	 * @return	An Array with a list of all the coordinates of that tile type.
	 */
	public function getTileCoords(Index:Int, Midpoint:Bool = true):Array<FlxPoint>
	{
		var array:Array<FlxPoint> = null;
		
		var point:FlxPoint;
		var l:Int = widthInTiles * heightInTiles;
		
		for (i in 0...l)
		{
			if (_data[i] == Index)
			{
				point = FlxPoint.get(x + (i % widthInTiles) * _scaledTileWidth, y + Std.int(i / widthInTiles) * _scaledTileHeight);
				
				if (Midpoint)
				{
					point.x += _scaledTileWidth * 0.5;
					point.y += _scaledTileHeight * 0.5;
				}
				
				if (array == null)
				{
					array = new Array<FlxPoint>();
				}
				array.push(point);
			}
		}
		
		return array;
	}
	
	/**
	 * Call this function to lock the automatic camera to the map's edges.
	 * 
	 * @param	Camera			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @param	Border			Adjusts the camera follow boundary by whatever number of tiles you specify here.  Handy for blocking off deadends that are offscreen, etc.  Use a negative number to add padding instead of hiding the edges.
	 * @param	UpdateWorld		Whether to update the collision system's world size, default value is true.
	 */
	public function follow(?Camera:FlxCamera, Border:Int = 0, UpdateWorld:Bool = true):Void
	{
		if (Camera == null)
			Camera = FlxG.camera;
		
		Camera.setScrollBoundsRect(x + Border * _scaledTileWidth, y + Border * _scaledTileHeight, width - Border * _scaledTileWidth * 2, height - Border * _scaledTileHeight * 2, UpdateWorld);
	}
	
	/**
	 * Shoots a ray from the start point to the end point.
	 * If/when it passes through a tile, it stores that point and returns false.
	 * 
	 * @param	Start		The world coordinates of the start of the ray.
	 * @param	End			The world coordinates of the end of the ray.
	 * @param	Result		An optional point containing the first wall impact if there was one. Null otherwise.
	 * @param	Resolution	Defaults to 1, meaning check every tile or so.  Higher means more checks!
	 * @return	Returns true if the ray made it from Start to End without hitting anything. Returns false and fills Result if a tile was hit.
	 */
	override public function ray(Start:FlxPoint, End:FlxPoint, ?Result:FlxPoint, Resolution:Float = 1):Bool
	{
		var step:Float = _scaledTileWidth;
		
		if (_scaledTileHeight < _scaledTileWidth)
			step = _scaledTileHeight;
		
		step /= Resolution;
		var deltaX:Float = End.x - Start.x;
		var deltaY:Float = End.y - Start.y;
		var distance:Float = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		var steps:Int = Math.ceil(distance / step);
		var stepX:Float = deltaX / steps;
		var stepY:Float = deltaY / steps;
		var curX:Float = Start.x - stepX - x;
		var curY:Float = Start.y - stepY - y;
		var tileX:Int;
		var tileY:Int;
		var i:Int = 0;
		
		Start.putWeak();
		End.putWeak();
		
		while (i < steps)
		{
			curX += stepX;
			curY += stepY;
			
			if ((curX < 0) || (curX > width) || (curY < 0) || (curY > height))
			{
				i++;
				continue;
			}
			
			tileX = Math.floor(curX / _scaledTileWidth);
			tileY = Math.floor(curY / _scaledTileHeight);
			
			if (_tileObjects[_data[tileY * widthInTiles + tileX]].allowCollisions != FlxObject.NONE)
			{
				// Some basic helper stuff
				tileX *= Std.int(_scaledTileWidth);
				tileY *= Std.int(_scaledTileHeight);
				var rx:Float = 0;
				var ry:Float = 0;
				var q:Float;
				var lx:Float = curX - stepX;
				var ly:Float = curY - stepY;
				
				// Figure out if it crosses the X boundary
				q = tileX;
				
				if (deltaX < 0)
				{
					q += _scaledTileWidth;
				}
				
				rx = q;
				ry = ly + stepY * ((q - lx) / stepX);
				
				if ((ry >= tileY) && (ry <= tileY + _scaledTileHeight))
				{
					if (Result == null)
					{
						Result = FlxPoint.get();
					}
					
					Result.set(rx, ry);
					return false;
				}
				
				// Else, figure out if it crosses the Y boundary
				q = tileY;
				
				if (deltaY < 0)
				{
					q += _scaledTileHeight;
				}
				
				rx = lx + stepX * ((q - ly) / stepY);
				ry = q;
				
				if ((rx >= tileX) && (rx <= tileX + _scaledTileWidth))
				{
					if (Result == null)
					{
						Result = FlxPoint.get();
					}
					
					Result.set(rx, ry);
					return false;
				}
				
				return true;
			}
			i++;
		}
		
		return true;
	}
	
	/**
	 * Change a particular tile to FlxSprite. Or just copy the graphic if you dont want any changes to mapdata itself.
	 * 
	 * @link http://forums.flixel.org/index.php/topic,5398.0.html
	 * @param	X				The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y				The Y coordinate of the tile (in tiles, not pixels).
	 * @param	NewTile			New tile to the mapdata. Use -1 if you dont want any changes. Default = 0 (empty)
	 * @param	SpriteFactory	Method for converting FlxTile to FlxSprite. If null then will be used defaultTileToSprite() method.
	 * @return	FlxSprite.
	 */
	public function tileToSprite(X:Int, Y:Int, NewTile:Int = 0, ?SpriteFactory:FlxTileProperties->FlxSprite):FlxSprite
	{
		if (SpriteFactory == null)
			SpriteFactory = defaultTileToSprite;
		
		var rowIndex:Int = X + (Y * widthInTiles);
		var tile:FlxTile = _tileObjects[_data[rowIndex]];
		var image:FlxImageFrame = null;
		
		if (tile != null && tile.visible)
			image = FlxImageFrame.fromFrame(tile.frame);
		else
			image = FlxImageFrame.fromEmptyFrame(graphic, FlxRect.get(0, 0, _tileWidth, _tileHeight));
		
		var tileX:Float = X * _tileWidth * scale.x + x;
		var tileY:Float = Y * _tileHeight * scale.y + y;
		var tileSprite:FlxSprite = SpriteFactory({graphic: image, x: tileX, y: tileY, scale: FlxPoint.get().copyFrom(scale), alpha: alpha, blend: blend});
		
		if (NewTile >= 0) 
			setTile(X, Y, NewTile);
		
		return tileSprite;
	}
	
	/**
	 * Use this method so the tilemap buffers are updated, e.g. when resizing your game
	 */
	public function updateBuffers():Void
	{
		FlxDestroyUtil.destroyArray(_buffers);
		_buffers = [];
	}
	
	/**
	 * Internal function that actually renders the tilemap to the tilemap buffer. Called by draw().
	 * 
	 * @param	Buffer		The FlxTilemapBuffer you are rendering to.
	 * @param	Camera		The related FlxCamera, mainly for scroll values.
	 */
	private function drawTilemap(Buffer:FlxTilemapBuffer, Camera:FlxCamera):Void
	{
		var isColored:Bool = (alpha != 1) || (color != 0xffffff);
		
		//only used for renderTile
		var drawX:Float = 0;
		var drawY:Float = 0;
		var scaledWidth:Float = 0;
		var scaledHeight:Float = 0;
		var drawItem = null;
		
		if (FlxG.renderBlit)
		{
			Buffer.fill();
		}
		else
		{
			getScreenPosition(_point, Camera).subtractPoint(offset).copyToFlash(_helperPoint);
			
			_helperPoint.x = isPixelPerfectRender(Camera) ? Math.floor(_helperPoint.x) : _helperPoint.x;
			_helperPoint.y = isPixelPerfectRender(Camera) ? Math.floor(_helperPoint.y) : _helperPoint.y;
			
			scaledWidth  = _scaledTileWidth;
			scaledHeight = _scaledTileHeight;
			
			var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());
			drawItem = Camera.startQuadBatch(graphic, isColored, hasColorOffsets, blend, antialiasing, shader);
		}
		
		// Copy tile images into the tile buffer
		_point.x = (Camera.scroll.x * scrollFactor.x) - x - offset.x; //modified from getScreenPosition()
		_point.y = (Camera.scroll.y * scrollFactor.y) - y - offset.y;
		
		var screenXInTiles:Int = Math.floor(_point.x / _scaledTileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _scaledTileHeight);
		var screenRows:Int = Buffer.rows;
		var screenColumns:Int = Buffer.columns;
		
		// Bound the upper left corner
		screenXInTiles = Std.int(FlxMath.bound(screenXInTiles, 0, widthInTiles - screenColumns));
		screenYInTiles =  Std.int(FlxMath.bound(screenYInTiles, 0, heightInTiles - screenRows));
		
		var rowIndex:Int = screenYInTiles * widthInTiles + screenXInTiles;
		_flashPoint.y = 0;
		var columnIndex:Int;
		var tile:FlxTile;
		var frame:FlxFrame;
		
		#if FLX_DEBUG
		var debugTile:BitmapData;
		#end 
		
		for (row in 0...screenRows)
		{
			columnIndex = rowIndex;
			_flashPoint.x = 0;
			
			for (column in 0...screenColumns)
			{
				tile = _tileObjects[_data[columnIndex]];
				
				if (tile != null && tile.visible && tile.frame.type != FlxFrameType.EMPTY)
				{
					frame = tile.frame;
					
					if (FlxG.renderBlit)
					{
						frame.paint(Buffer.pixels, _flashPoint, true);
						
						#if FLX_DEBUG
						if (FlxG.debugger.drawDebug && !ignoreDrawDebug) 
						{
							if (tile.allowCollisions <= FlxObject.NONE)
							{
								// Blue
								debugTile = _debugTileNotSolid; 
							}
							else if (tile.allowCollisions != FlxObject.ANY)
							{
								// Pink
								debugTile = _debugTilePartial; 
							}
							else
							{
								// Green
								debugTile = _debugTileSolid; 
							}
							
							offset.addToFlash(_flashPoint);
							Buffer.pixels.copyPixels(debugTile, _debugRect, _flashPoint, null, null, true);
							offset.subtractFromFlash(_flashPoint);
						}
						#end
					}
					else
					{
						drawX = _helperPoint.x + (columnIndex % widthInTiles) * scaledWidth;
						drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * scaledHeight;
						
						_matrix.identity();
						
						if (frame.angle != FlxFrameAngle.ANGLE_0)
						{
							frame.prepareMatrix(_matrix);
						}
						
						var scaleX:Float = scale.x;
						var scaleY:Float = scale.y;
						
						if (useScaleHack)
						{
							scaleX += 1 / (frame.sourceSize.x * Camera.totalScaleX);
							scaleY += 1 / (frame.sourceSize.y * Camera.totalScaleY);
						}
						
						_matrix.scale(scaleX, scaleY);
						_matrix.translate(drawX, drawY);
						
						drawItem.addQuad(frame, _matrix, colorTransform);
					}
				}
				
				if (FlxG.renderBlit)
					_flashPoint.x += _tileWidth;
				columnIndex++;
			}
			
			if (FlxG.renderBlit)
				_flashPoint.y += _tileHeight;
			rowIndex += widthInTiles;
		}
		
		Buffer.x = screenXInTiles * _scaledTileWidth;
		Buffer.y = screenYInTiles * _scaledTileHeight;
		
		if (FlxG.renderBlit)
		{
			if (isColored)
				Buffer.colorTransform(colorTransform);
			Buffer.blend = blend;
		}
		
		Buffer.dirty = false;
	}
	
	/**
	 * Internal function to clean up the map loading code.
	 * Just generates a wireframe box the size of a tile with the specified color.
	 */
	#if FLX_DEBUG
	private function makeDebugTile(Color:FlxColor):BitmapData
	{
		if (FlxG.renderTile)
			return null;

		var debugTile:BitmapData;
		debugTile = new BitmapData(_tileWidth, _tileHeight, true, 0);
		
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		gfx.clear();
		gfx.moveTo(0, 0);
		gfx.lineStyle(1, Color, 0.5);
		gfx.lineTo(_tileWidth - 1, 0);
		gfx.lineTo(_tileWidth - 1, _tileHeight - 1);
		gfx.lineTo(0, _tileHeight - 1);
		gfx.lineTo(0, 0);
		
		debugTile.draw(FlxSpriteUtil.flashGfxSprite);
		return debugTile;
	}
	#end

	/**
	 * Internal function used in setTileByIndex() and the constructor to update the map.
	 * 
	 * @param	Index		The index of the tile object in _tileObjects internal array you want to update.
	 */
	override private function updateTile(Index:Int):Void
	{
		var tile:FlxTile = _tileObjects[Index];
		if (tile == null || !tile.visible)
			return;

		tile.frame = frames.frames[Index - _startingIndex];
	}
	
	private inline function createBuffer(camera:FlxCamera):FlxTilemapBuffer
	{
		var buffer = new FlxTilemapBuffer(_tileWidth, _tileHeight, widthInTiles, heightInTiles, camera, scale.x, scale.y);
		buffer.pixelPerfectRender = pixelPerfectRender;
		buffer.antialiasing = antialiasing;
		return buffer;
	}
	
	#if FLX_DEBUG
	private function onDrawDebugChanged():Void
	{
		if (FlxG.renderTile)
			return;

		for (buffer in _buffers)
			if (buffer != null)
				buffer.dirty = true;
	}
	#end
	
	private function set_antialiasing(value:Bool):Bool
	{
		for (buffer in _buffers)
			buffer.antialiasing = value;
		return antialiasing = value;
	}
	
	/**
	 * Internal function for setting graphic property for this object. 
	 * It changes graphic' useCount also for better memory tracking.
	 */
	private function set_graphic(Value:FlxGraphic):FlxGraphic
	{
		//If graphics are changing
		if (graphic != Value)
		{
			//If new graphic is not null, increase its use count
			if (Value != null)
				Value.useCount++;

			//If old graphic is not null, decrease its use count
			if (graphic != null)
				graphic.useCount--;
		}
		
		return graphic = Value;
	}
	
	override private function set_pixelPerfectRender(Value:Bool):Bool 
	{
		if (_buffers != null)
			for (buffer in _buffers)
				buffer.pixelPerfectRender = Value;
		
		return pixelPerfectRender = Value;
	}
	
	private function set_alpha(Alpha:Float):Float
	{
		alpha = FlxMath.bound(Alpha, 0, 1);
		updateColorTransform();
		return alpha;
	}
	
	private function set_color(Color:FlxColor):Int
	{
		if (color == Color)
			return Color;

		color = Color;
		updateColorTransform();
		return color;
	}
	
	private function updateColorTransform():Void
	{
		if (colorTransform == null)
			colorTransform = new ColorTransform();
		
		if (alpha != 1 || color != 0xffffff)
			colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, alpha);
		else
			colorTransform.setMultipliers(1, 1, 1, 1);
		
		if (FlxG.renderBlit)
			setDirty();
	}
	
	private function set_blend(Value:BlendMode):BlendMode 
	{
		if (FlxG.renderBlit)
			setDirty();
		return blend = Value;
	}
	
	private function setScaleXYCallback(Scale:FlxPoint):Void
	{
		setScaleXCallback(Scale);
		setScaleYCallback(Scale);
	}
	
	private function setScaleXCallback(Scale:FlxPoint):Void
	{
		_scaledTileWidth = _tileWidth * scale.x;
		width = widthInTiles * _scaledTileWidth;
		
		if (cameras == null)
			return;

		for (i in 0...cameras.length)
			if (_buffers[i] != null)
				_buffers[i].updateColumns(_tileWidth, widthInTiles, scale.x, cameras[i]);
	}
	
	private function setScaleYCallback(Scale:FlxPoint):Void
	{
		_scaledTileHeight = _tileHeight * scale.y;
		height = heightInTiles * _scaledTileHeight;
		
		if (cameras == null)
			return;

		for (i in 0...cameras.length)
			if (_buffers[i] != null)
				_buffers[i].updateRows(_tileHeight, heightInTiles, scale.y, cameras[i]);
	}
	
	/**
	 * Default method for generating FlxSprite from FlxTile
	 * 
	 * @param	TileProperties	properties for new sprite
	 * @return	New FlxSprite with specified graphic
	 */
	private function defaultTileToSprite(TileProperties:FlxTileProperties):FlxSprite
	{
		var tileSprite = new FlxSprite(TileProperties.x, TileProperties.y);
		tileSprite.frames = TileProperties.graphic;
		tileSprite.scale.copyFrom(TileProperties.scale);
		TileProperties.scale = FlxDestroyUtil.put(TileProperties.scale);
		tileSprite.alpha = TileProperties.alpha;
		tileSprite.blend = TileProperties.blend;
		return tileSprite;
	}
	
	override function set_allowCollisions(Value:Int):Int 
	{
		for (tile in _tileObjects)
			if (tile.index >= _collideIndex)
				tile.allowCollisions = Value;

		return super.set_allowCollisions(Value);
	}
}

typedef FlxTileProperties =
{
	graphic:FlxImageFrame,
	x:Float,
	y:Float,
	scale:FlxPoint,
	alpha:Float,
	blend:BlendMode
}
