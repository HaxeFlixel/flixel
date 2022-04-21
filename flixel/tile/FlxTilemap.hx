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
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

using flixel.util.FlxColorTransformUtil;

#if html5
@:keep @:bitmap("assets/images/tile/autotiles.png")
private class RawGraphicAuto extends BitmapData {}
class GraphicAuto extends RawGraphicAuto
{
	public function new (width = 128, height = 8, transparent = true, fillRGBA = 0xFFffffff, ?onLoad:Dynamic)
	{
		super(width, height, transparent, fillRGBA, onLoad);
		// Set properties because `@:bitmap` constructors ignore width/height
		this.width = width;
		this.height = height;
	}
}

@:keep @:bitmap("assets/images/tile/autotiles_alt.png")
private class RawGraphicAutoAlt extends BitmapData {}
class GraphicAutoAlt extends RawGraphicAutoAlt
{
	public function new (width = 128, height = 8, transparent = true, fillRGBA = 0xFFffffff, ?onLoad:Dynamic)
	{
		super(width, height, transparent, fillRGBA, onLoad);
		// Set again because `@:bitmap` constructors ignore width/height
		this.width = width;
		this.height = height;
	}
}

@:keep @:bitmap("assets/images/tile/autotiles_full.png")
private class RawGraphicAutoFull extends BitmapData {}
class GraphicAutoFull extends RawGraphicAutoFull
{
	public function new (width = 256, height = 48, transparent = true, fillRGBA = 0xFFffffff, ?onLoad:Dynamic)
	{
		super(width, height, transparent, fillRGBA, onLoad);
		// Set again because `@:bitmap` constructors ignore width/height
		this.width = width;
		this.height = height;
	}
}
#else
@:keep @:bitmap("assets/images/tile/autotiles.png")
class GraphicAuto extends BitmapData {}

@:keep @:bitmap("assets/images/tile/autotiles_alt.png")
class GraphicAutoAlt extends BitmapData {}

@:keep @:bitmap("assets/images/tile/autotiles_full.png")
class GraphicAutoFull extends BitmapData {}
#end

// TODO: try to solve "tile tearing problem" (1px gap between tile at certain conditions) on native targets

/**
 * This is a traditional tilemap display and collision class. It takes a string of comma-separated numbers and then associates
 * those values with tiles from the sheet you pass in. It also includes some handy static parsers that can convert
 * arrays or images into strings that can be loaded.
 */
class FlxTilemap extends FlxBaseTilemap<FlxTile>
{
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
	#if openfl_legacy
	@:noCompletion
	#end
	public var shader:FlxShader;

	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	var _flashPoint:Point = new Point();

	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	var _flashRect:Rectangle = new Rectangle();

	/**
	 * Internal list of buffers, one for each camera, used for drawing the tilemaps.
	 */
	var _buffers:Array<FlxTilemapBuffer> = [];

	/**
	 * Internal, the width of a single tile.
	 */
	var _tileWidth:Int = 0;

	/**
	 * Internal, the height of a single tile.
	 */
	var _tileHeight:Int = 0;

	var _scaledTileWidth:Float = 0;
	var _scaledTileHeight:Float = 0;

	#if FLX_DEBUG
	var _debugTileNotSolid:BitmapData;
	var _debugTilePartial:BitmapData;
	var _debugTileSolid:BitmapData;
	var _debugRect:Rectangle;
	#end

	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods. Used only in tile rendering mode
	 */
	var _helperPoint:Point;

	/**
	 * Rendering helper, used for tile's frame transformations (only in tile rendering mode).
	 */
	var _matrix:FlxMatrix;

	/**
	 * Whether buffers need to be checked again next draw().
	 */
	var _checkBufferChanges:Bool = false;

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
		debugBoundingBoxColorSolid = FlxColor.GREEN;
		debugBoundingBoxColorPartial = FlxColor.PINK;
		debugBoundingBoxColorNotSolid = FlxColor.TRANSPARENT;

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
			_debugTileNotSolid = FlxDestroyUtil.dispose(_debugTileNotSolid);
			_debugTilePartial = FlxDestroyUtil.dispose(_debugTilePartial);
			_debugTileSolid = FlxDestroyUtil.dispose(_debugTileSolid);
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

	function set_frames(value:FlxFramesCollection):FlxFramesCollection
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

	function onGameResized(_, _):Void
	{
		_checkBufferChanges = true;
	}

	function onCameraChanged(_):Void
	{
		_checkBufferChanges = true;
	}

	override function cacheGraphics(TileWidth:Int, TileHeight:Int, TileGraphic:FlxTilemapGraphicAsset):Void
	{
		if ((TileGraphic is FlxFramesCollection))
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

	override function initTileObjects():Void
	{
		if (frames == null)
			return;

		_tileObjects = FlxDestroyUtil.destroyArray(_tileObjects);
		// Create some tile objects that we'll use for overlap checks (one for each tile)
		_tileObjects = new Array<FlxTile>();

		var length:Int = frames.numFrames;
		length += _startingIndex;

		for (i in 0...length)
			_tileObjects[i] = new FlxTile(this, i, _tileWidth, _tileHeight, (i >= _drawIndex), (i >= _collideIndex) ? allowCollisions : NONE);

		// Create debug tiles for rendering bounding boxes on demand
		#if FLX_DEBUG
		updateDebugTileBoundingBoxSolid();
		updateDebugTileBoundingBoxNotSolid();
		updateDebugTileBoundingBoxPartial();
		#end
	}

	#if FLX_DEBUG
	function updateDebugTileBoundingBoxSolid():Void
	{
		_debugTileSolid = updateDebugTile(_debugTileSolid, debugBoundingBoxColorSolid);
	}

	function updateDebugTileBoundingBoxNotSolid():Void
	{
		_debugTileNotSolid = updateDebugTile(_debugTileNotSolid, debugBoundingBoxColorNotSolid);
	}

	function updateDebugTileBoundingBoxPartial():Void
	{
		_debugTilePartial = updateDebugTile(_debugTilePartial, debugBoundingBoxColorPartial);
	}

	function updateDebugTile(tileBitmap:BitmapData, color:FlxColor):BitmapData
	{
		if (FlxG.renderTile)
			return null;

		if (_tileWidth <= 0 || _tileHeight <= 0)
			return tileBitmap;

		if (tileBitmap != null && (tileBitmap.width != _tileWidth || tileBitmap.height != _tileHeight))
			tileBitmap = FlxDestroyUtil.dispose(tileBitmap);

		if (tileBitmap == null)
			tileBitmap = makeDebugTile(color);
		else
		{
			tileBitmap.fillRect(tileBitmap.rect, FlxColor.TRANSPARENT);
			drawDebugTile(tileBitmap, color);
		}

		setDirty();
		return tileBitmap;
	}
	#end

	override function computeDimensions():Void
	{
		_scaledTileWidth = _tileWidth * scale.x;
		_scaledTileHeight = _tileHeight * scale.y;

		// Then go through and create the actual map
		width = widthInTiles * _scaledTileWidth;
		height = heightInTiles * _scaledTileHeight;
	}

	override function updateMap():Void
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

		var rectWidth:Float = _scaledTileWidth;
		var rectHeight:Float = _scaledTileHeight;
		var rect = FlxRect.get(0, 0, rectWidth, rectHeight);

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
					rect.x = _helperPoint.x + (columnIndex % widthInTiles) * rectWidth;
					rect.y = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * rectHeight;
					drawDebugBoundingBox(Camera.debugLayer.graphics, rect, tile.allowCollisions, tile.allowCollisions != ANY);
				}

				columnIndex++;
			}

			rowIndex += widthInTiles;
		}

		rect.put();
	}
	#end

	/**
	 * Check and see if this object is currently on screen. Differs from `FlxObject`'s implementation
	 * in that it takes the actual graphic into account, not just the hitbox or bounding box or whatever.
	 *
	 * @param   Camera  Specify which game camera you want. If `null`, it will just grab the first global camera.
	 * @return  Whether the object is on screen or not.
	 */
	override public function isOnScreen(?Camera:FlxCamera):Bool
	{
		if (Camera == null)
			Camera = FlxG.camera;

		var minX:Float = x - offset.x - Camera.scroll.x * scrollFactor.x;
		var minY:Float = y - offset.y - Camera.scroll.y * scrollFactor.y;

		_point.set(minX, minY);
		return Camera.containsPoint(_point, _scaledTileWidth * widthInTiles, _scaledTileHeight * heightInTiles);
	}

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

			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			if (_buffers[i] == null)
				_buffers[i] = createBuffer(camera);

			buffer = _buffers[i];

			if (FlxG.renderBlit)
			{
				if (buffer.isDirty(this, camera))
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

	function refreshBuffers():Void
	{
		for (i in 0...cameras.length)
		{
			var camera = cameras[i];
			var buffer = _buffers[i];

			// Create a new buffer if the number of columns and rows differs
			if (buffer == null)
				_buffers[i] = createBuffer(camera);
			else
				buffer.resize(_tileWidth, _tileHeight, widthInTiles, heightInTiles, camera, scale.x, scale.y);
		}
	}

	/**
	 * Set the dirty flag on all the tilemap buffers.
	 * Basically forces a reset of the drawn tilemaps, even if it wasn't necessary.
	 *
	 * @param	Dirty		Whether to flag the tilemap buffers as dirty or not.
	 */
	override public function setDirty(Dirty:Bool = true):Void
	{
		if (FlxG.renderTile)
			return;

		for (buffer in _buffers)
			if (buffer != null)
				buffer.dirty = Dirty;
	}

	/**
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 *
	 * @param	Object				The FlxObject you are checking for overlaps against.
	 * @param	Callback			An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a FlxTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param	FlipCallbackParams	Used to preserve A-B list ordering from FlxObject.separate() - returns the FlxTile object as the second parameter instead.
	 * @param	Position			Optional, specify a custom position for the tilemap (useful for overlapsAt()-type functionality).
	 * @return	Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	override public function overlapsWithCallback(Object:FlxObject, ?Callback:FlxObject->FlxObject->Bool, FlipCallbackParams:Bool = false,
			?Position:FlxPoint):Bool
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

				overlapFound = ((Object.x + Object.width) > tile.x)
					&& (Object.x < (tile.x + tile.width))
					&& ((Object.y + Object.height) > tile.y)
					&& (Object.y < (tile.y + tile.height));

				if (tile.allowCollisions != NONE)
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
					if (tile.callbackFunction != null && (tile.filter == null || isOfType(Object, tile.filter)))
					{
						tile.mapIndex = rowStart + column;
						tile.callbackFunction(tile, Object);
					}

					if (tile.allowCollisions != NONE)
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
		var localX = Coord.x - x;
		var localY = Coord.y - y;
		Coord.putWeak();

		if ((localX < 0) || (localY < 0) || (localX >= width) || (localY >= height))
			return -1;

		return Std.int(localY / _scaledTileHeight) * widthInTiles + Std.int(localX / _scaledTileWidth);
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

		Camera.setScrollBoundsRect(x
			+ Border * _scaledTileWidth, y
			+ Border * _scaledTileHeight, width
			- Border * _scaledTileWidth * 2,
			height
			- Border * _scaledTileHeight * 2, UpdateWorld);
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

			if (_tileObjects[_data[tileY * widthInTiles + tileX]].allowCollisions != NONE)
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
	 * Change a particular tile to FlxSprite. Or just copy the graphic if you dont want any changes to map data itself.
	 *
	 * @param	X				The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y				The Y coordinate of the tile (in tiles, not pixels).
	 * @param	NewTile			New tile for the map data. Use -1 if you dont want any changes. Default = 0 (empty)
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
		var tileSprite:FlxSprite = SpriteFactory({
			graphic: image,
			x: tileX,
			y: tileY,
			scale: FlxPoint.get().copyFrom(scale),
			alpha: alpha,
			blend: blend
		});

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
	@:access(flixel.FlxCamera)
	function drawTilemap(Buffer:FlxTilemapBuffer, Camera:FlxCamera):Void
	{
		var isColored:Bool = (alpha != 1) || (color != 0xffffff);

		// only used for renderTile
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

			scaledWidth = _scaledTileWidth;
			scaledHeight = _scaledTileHeight;

			var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());
			drawItem = Camera.startQuadBatch(graphic, isColored, hasColorOffsets, blend, antialiasing, shader);
		}

		// Copy tile images into the tile buffer
		_point.x = (Camera.scroll.x * scrollFactor.x) - x - offset.x + Camera.viewOffsetX; // modified from getScreenPosition()
		_point.y = (Camera.scroll.y * scrollFactor.y) - y - offset.y + Camera.viewOffsetY;

		var screenXInTiles:Int = Math.floor(_point.x / _scaledTileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _scaledTileHeight);
		var screenRows:Int = Buffer.rows;
		var screenColumns:Int = Buffer.columns;

		// Bound the upper left corner
		screenXInTiles = Std.int(FlxMath.bound(screenXInTiles, 0, widthInTiles - screenColumns));
		screenYInTiles = Std.int(FlxMath.bound(screenYInTiles, 0, heightInTiles - screenRows));

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
							if (tile.allowCollisions <= NONE)
							{
								debugTile = _debugTileNotSolid;
							}
							else if (tile.allowCollisions != ANY)
							{
								debugTile = _debugTilePartial;
							}
							else
							{
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
	function makeDebugTile(color:FlxColor):BitmapData
	{
		if (FlxG.renderTile)
			return null;

		var debugTile = new BitmapData(_tileWidth, _tileHeight, true, 0);
		drawDebugTile(debugTile, color);
		return debugTile;
	}

	function drawDebugTile(debugTile:BitmapData, color:FlxColor):Void
	{
		if (color != FlxColor.TRANSPARENT)
		{
			var gfx:Graphics = FlxSpriteUtil.flashGfx;
			gfx.clear();
			gfx.moveTo(0, 0);
			gfx.lineStyle(1, color, 0.5);
			gfx.lineTo(_tileWidth - 1, 0);
			gfx.lineTo(_tileWidth - 1, _tileHeight - 1);
			gfx.lineTo(0, _tileHeight - 1);
			gfx.lineTo(0, 0);

			debugTile.draw(FlxSpriteUtil.flashGfxSprite);
		}
	}

	function onDrawDebugChanged():Void
	{
		setDirty();
	}
	#end

	/**
	 * Internal function used in setTileByIndex() and the constructor to update the map.
	 *
	 * @param	Index		The index of the tile object in _tileObjects internal array you want to update.
	 */
	override function updateTile(Index:Int):Void
	{
		var tile:FlxTile = _tileObjects[Index];
		if (tile == null || !tile.visible)
			return;

		tile.frame = frames.frames[Index - _startingIndex];
	}

	inline function createBuffer(camera:FlxCamera):FlxTilemapBuffer
	{
		var buffer = new FlxTilemapBuffer(_tileWidth, _tileHeight, widthInTiles, heightInTiles, camera, scale.x, scale.y);
		buffer.pixelPerfectRender = pixelPerfectRender;
		buffer.antialiasing = antialiasing;
		return buffer;
	}

	function set_antialiasing(value:Bool):Bool
	{
		for (buffer in _buffers)
			buffer.antialiasing = value;
		return antialiasing = value;
	}

	/**
	 * Internal function for setting graphic property for this object.
	 * It changes graphic' useCount also for better memory tracking.
	 */
	function set_graphic(Value:FlxGraphic):FlxGraphic
	{
		// If graphics are changing
		if (graphic != Value)
		{
			// If new graphic is not null, increase its use count
			if (Value != null)
				Value.useCount++;

			// If old graphic is not null, decrease its use count
			if (graphic != null)
				graphic.useCount--;
		}

		return graphic = Value;
	}

	override function set_pixelPerfectRender(Value:Bool):Bool
	{
		if (_buffers != null)
			for (buffer in _buffers)
				buffer.pixelPerfectRender = Value;

		return pixelPerfectRender = Value;
	}

	function set_alpha(Alpha:Float):Float
	{
		alpha = FlxMath.bound(Alpha, 0, 1);
		updateColorTransform();
		return alpha;
	}

	function set_color(Color:FlxColor):Int
	{
		if (color == Color)
			return Color;

		color = Color;
		updateColorTransform();
		return color;
	}

	function updateColorTransform():Void
	{
		if (colorTransform == null)
			colorTransform = new ColorTransform();

		if (alpha != 1 || color != 0xffffff)
			colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, alpha);
		else
			colorTransform.setMultipliers(1, 1, 1, 1);

		setDirty();
	}

	function set_blend(Value:BlendMode):BlendMode
	{
		setDirty();
		return blend = Value;
	}

	function setScaleXYCallback(Scale:FlxPoint):Void
	{
		setScaleXCallback(Scale);
		setScaleYCallback(Scale);
	}

	function setScaleXCallback(Scale:FlxPoint):Void
	{
		_scaledTileWidth = _tileWidth * scale.x;
		width = widthInTiles * _scaledTileWidth;

		if (cameras == null)
			return;

		for (i in 0...cameras.length)
			if (_buffers[i] != null)
				_buffers[i].updateColumns(_tileWidth, widthInTiles, scale.x, cameras[i]);
	}

	function setScaleYCallback(Scale:FlxPoint):Void
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
	function defaultTileToSprite(TileProperties:FlxTileProperties):FlxSprite
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

	#if FLX_DEBUG
	override function set_debugBoundingBoxColorSolid(color:FlxColor)
	{
		super.set_debugBoundingBoxColorSolid(color);
		updateDebugTileBoundingBoxSolid();
		return color;
	}

	override function set_debugBoundingBoxColorNotSolid(color:FlxColor)
	{
		super.set_debugBoundingBoxColorNotSolid(color);
		updateDebugTileBoundingBoxNotSolid();
		return color;
	}

	override function set_debugBoundingBoxColorPartial(color:FlxColor)
	{
		super.set_debugBoundingBoxColorPartial(color);
		updateDebugTileBoundingBoxPartial();
		return color;
	}
	#end
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
