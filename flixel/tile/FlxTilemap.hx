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

using flixel.util.FlxColorTransformUtil;

#if html5
/**
 * BitmapData loaded via @:bitmap is loaded asynchronously, this allows us to apply frame
 * padding to the bitmap once it's loaded rather
 */
private interface IEmbeddedBitmapData
{
	var onLoad:()->Void;
}

@:keep @:bitmap("assets/images/tile/autotiles.png")
private class RawGraphicAuto extends BitmapData {}
class GraphicAuto extends RawGraphicAuto implements IEmbeddedBitmapData
{
	static inline var WIDTH = 128;
	static inline var HEIGHT = 8;

	public var onLoad:()->Void;
	public function new ()
	{
		super(WIDTH, HEIGHT, true, 0xFFffffff, (_)-> if (onLoad != null) onLoad());
		// Set properties because `@:bitmap` constructors ignore width/height
		this.width = WIDTH;
		this.height = HEIGHT;
	}
}

@:keep @:bitmap("assets/images/tile/autotiles_alt.png")
private class RawGraphicAutoAlt extends BitmapData {}
class GraphicAutoAlt extends RawGraphicAutoAlt implements IEmbeddedBitmapData
{
	static inline var WIDTH = 128;
	static inline var HEIGHT = 8;

	public var onLoad:()->Void;
	public function new ()
	{
		super(WIDTH, HEIGHT, true, 0xFFffffff, (_)-> if (onLoad != null) onLoad());
		// Set properties because `@:bitmap` constructors ignore width/height
		this.width = WIDTH;
		this.height = HEIGHT;
	}
}

@:keep @:bitmap("assets/images/tile/autotiles_full.png")
private class RawGraphicAutoFull extends BitmapData {}
class GraphicAutoFull extends RawGraphicAutoFull implements IEmbeddedBitmapData
{
	static inline var WIDTH = 256;
	static inline var HEIGHT = 48;

	public var onLoad:()->Void;
	public function new ()
	{
		super(WIDTH, HEIGHT, true, 0xFFffffff, (_)-> if (onLoad != null) onLoad());
		// Set properties because `@:bitmap` constructors ignore width/height
		this.width = WIDTH;
		this.height = HEIGHT;
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

/**
 * This is a traditional tilemap display and collision class. It takes a string of comma-separated
 * numbers and then associates those values with tiles from the sheet you pass in. It also includes
 * some handy static parsers that can convert arrays or images into strings that can be loaded.
 */
class FlxTilemap extends FlxBaseTilemap<FlxTile>
{
	/**
	 * Eliminates tearing on tilemaps by extruding each tile frame's edge out by the specified
	 * number of pixels. Ignored if <= 0
	 */
	public static var defaultFramePadding = 2;

	/**
	 * DISABLED, the static var `defaultFramePadding` fixes the tearing issue in a more performant
	 * and visually appealing way.
	 */
	@:deprecated("useScaleHaxe is no longer needed")
	@:noCompletion
	public var useScaleHack:Bool = false;

	/**
	 * Changes the size of this tilemap. Default is (1, 1).
	 * Anything other than the default is very slow with blitting!
	 */
	public var scale(default, null):FlxPoint;

	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 * @since 4.1.0
	 * 
	 * @see FlxSprite.defaultAntialiasing
	 */
	public var antialiasing(default, set):Bool = FlxSprite.defaultAntialiasing;

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
	 * The unscaled width of a single tile.
	 */
	public var tileWidth(default, null):Int = 0;

	/**
	 * The unscaled height of a single tile.
	 */
	public var tileHeight(default, null):Int = 0;

	/**
	 * The scaled width of a single tile.
	 */
	public var scaledTileWidth(default, null):Float = 0;

	/**
	 * The scaled height of a single tile.
	 */
	public var scaledTileHeight(default, null):Float = 0;
	
	/**
	 * The scaled width of the entire map.
	 */
	public var scaledWidth(get, never):Float;

	/**
	 * The scaled height of the entire map.
	 */
	public var scaledHeight(get, never):Float;

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
			tileWidth = Std.int(value.frames[0].sourceSize.x);
			tileHeight = Std.int(value.frames[0].sourceSize.y);
			_flashRect.setTo(0, 0, tileWidth, tileHeight);
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

	override function cacheGraphics(tileWidth:Int, tileHeight:Int, tileGraphic:FlxTilemapGraphicAsset):Void
	{
		if ((tileGraphic is FlxFramesCollection))
		{
			frames = cast tileGraphic;
			return;
		}

		var graph:FlxGraphic = FlxG.bitmap.add(cast tileGraphic);
		if (graph == null)
			return;

		// Figure out the size of the tiles
		if (tileWidth <= 0)
			tileWidth = graph.height;

		if (tileHeight <= 0)
			tileHeight = tileWidth;

		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		if (defaultFramePadding > 0 && graph.isLoaded)
			frames = padTileFrames(tileWidth, tileHeight, graph, defaultFramePadding);
		else
		{
			#if html5
			/* if Using tile graphics like GraphicAuto or others defined above, they will not
			 * load immediately. Track their loading and apply frame padding after.
			**/
			if (!graph.isLoaded && Std.isOfType(graph.bitmap, IEmbeddedBitmapData))
			{
				var futureBitmap:IEmbeddedBitmapData = cast graph.bitmap;
				futureBitmap.onLoad = function()
				{
					frames = padTileFrames(tileWidth, tileHeight, graph, defaultFramePadding);
				}
			}
			else if (defaultFramePadding > 0 && !graph.isLoaded)
			{
				FlxG.log.warn('defaultFramePadding not applied to "${graph.key}" because it is loading asynchronously.'
					+ "using `@:bitmap` assets on html5 is not recommended");
			}
			#end
			frames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(tileWidth, tileHeight));
		}
	}

	function padTileFrames(tileWidth:Int, tileHeight:Int, graphic:FlxGraphic, padding:Int)
	{
		return FlxTileFrames.fromBitmapAddSpacesAndBorders(
			graphic,
			FlxPoint.get(tileWidth, tileHeight),
			null,
			FlxPoint.get(padding, padding)
		);
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
			_tileObjects[i] = new FlxTile(this, i, tileWidth, tileHeight, (i >= _drawIndex), (i >= _collideIndex) ? allowCollisions : NONE);

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

		if (tileWidth <= 0 || tileHeight <= 0)
			return tileBitmap;

		if (tileBitmap != null && (tileBitmap.width != tileWidth || tileBitmap.height != tileHeight))
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
		scaledTileWidth = tileWidth * scale.x;
		scaledTileHeight = tileHeight * scale.y;

		width = scaledWidth;
		height = scaledHeight;
	}

	override function updateMap():Void
	{
		#if FLX_DEBUG
		if (FlxG.renderBlit)
			_debugRect = new Rectangle(0, 0, tileWidth, tileHeight);
		#end

		var numTiles:Int = _tileObjects.length;
		for (i in 0...numTiles)
			updateTile(i);
	}

	#if FLX_DEBUG
	override public function drawDebugOnCamera(camera:FlxCamera):Void
	{
		if (!FlxG.renderTile)
			return;

		var buffer:FlxTilemapBuffer = null;
		var l:Int = FlxG.cameras.list.length;

		for (i in 0...l)
		{
			if (FlxG.cameras.list[i] == camera)
			{
				buffer = _buffers[i];
				break;
			}
		}

		if (buffer == null)
			return;

		// Copied from getScreenPosition()
		_helperPoint.x = x - camera.scroll.x * scrollFactor.x;
		_helperPoint.y = y - camera.scroll.y * scrollFactor.y;

		var rectWidth:Float = scaledTileWidth;
		var rectHeight:Float = scaledTileHeight;
		var rect = FlxRect.get(0, 0, rectWidth, rectHeight);

		// Copy tile images into the tile buffer
		// Modified from getScreenPosition()
		_point.x = (camera.scroll.x * scrollFactor.x) - x;
		_point.y = (camera.scroll.y * scrollFactor.y) - y;
		var screenXInTiles:Int = Math.floor(_point.x / scaledTileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / scaledTileHeight);
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
					drawDebugBoundingBox(camera.debugLayer.graphics, rect, tile.allowCollisions, tile.allowCollisions != ANY);
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
	 * @param   camera  Specify which game camera you want. If `null`, it will just grab the first global camera.
	 * @return  Whether the object is on screen or not.
	 */
	override public function isOnScreen(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = FlxG.camera;

		var minX:Float = x - offset.x - camera.scroll.x * scrollFactor.x;
		var minY:Float = y - offset.y - camera.scroll.y * scrollFactor.y;

		_point.set(minX, minY);
		return camera.containsPoint(_point, scaledTileWidth * widthInTiles, scaledTileHeight * heightInTiles);
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
				buffer.resize(tileWidth, tileHeight, widthInTiles, heightInTiles, camera, scale.x, scale.y);
		}
	}

	/**
	 * Set the dirty flag on all the tilemap buffers.
	 * Basically forces a reset of the drawn tilemaps, even if it wasn't necessary.
	 *
	 * @param   dirty  Whether to flag the tilemap buffers as dirty or not.
	 */
	override public function setDirty(dirty:Bool = true):Void
	{
		if (FlxG.renderTile)
			return;

		for (buffer in _buffers)
			if (buffer != null)
				buffer.dirty = dirty;
	}

	/**
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 *
	 * @param   object              The FlxObject you are checking for overlaps against.
	 * @param   callback            An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a FlxTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param   flipCallbackParams  Used to preserve A-B list ordering from FlxObject.separate() - returns the FlxTile object as the second parameter instead.
	 * @param   position            Optional, specify a custom position for the tilemap (useful for overlapsAt()-type functionality).
	 * @return  Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	override public function overlapsWithCallback(object:FlxObject, ?callback:FlxObject->FlxObject->Bool, flipCallbackParams:Bool = false,
			?position:FlxPoint):Bool
	{
		var results:Bool = false;

		var xPos:Float = x;
		var yPos:Float = y;

		if (position != null)
		{
			xPos = position.x;
			yPos = position.y;
			position.putWeak();
		}

		// Figure out what tiles we need to check against
		var selectionX:Int = Math.floor((object.x - xPos) / scaledTileWidth);
		var selectionY:Int = Math.floor((object.y - yPos) / scaledTileHeight);
		var selectionWidth:Int = selectionX + Math.ceil(object.width / scaledTileWidth) + 1;
		var selectionHeight:Int = selectionY + Math.ceil(object.height / scaledTileHeight) + 1;

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
				tile.width = scaledTileWidth;
				tile.height = scaledTileHeight;
				tile.x = xPos + column * tile.width;
				tile.y = yPos + row * tile.height;
				tile.last.x = tile.x - deltaX;
				tile.last.y = tile.y - deltaY;

				overlapFound = ((object.x + object.width) > tile.x)
					&& (object.x < (tile.x + tile.width))
					&& ((object.y + object.height) > tile.y)
					&& (object.y < (tile.y + tile.height));

				if (tile.allowCollisions != NONE)
				{
					if (callback != null)
					{
						if (flipCallbackParams)
						{
							overlapFound = callback(object, tile);
						}
						else
						{
							overlapFound = callback(tile, object);
						}
					}
				}

				if (overlapFound)
				{
					if (tile.callbackFunction != null && (tile.filter == null || Std.isOfType(object, tile.filter)))
					{
						tile.mapIndex = rowStart + column;
						tile.callbackFunction(tile, object);
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

	override public function getTileIndexByCoords(coord:FlxPoint):Int
	{
		var localX = coord.x - x;
		var localY = coord.y - y;
		coord.putWeak();

		if ((localX < 0) || (localY < 0) || (localX >= scaledWidth) || (localY >= scaledHeight))
			return -1;

		return Std.int(localY / scaledTileHeight) * widthInTiles + Std.int(localX / scaledTileWidth);
	}

	override public function getTileCoordsByIndex(index:Int, midpoint = true):FlxPoint
	{
		var point = FlxPoint.get(x + (index % widthInTiles) * scaledTileWidth, y + Std.int(index / widthInTiles) * scaledTileHeight);
		if (midpoint)
		{
			point.x += scaledTileWidth * 0.5;
			point.y += scaledTileHeight * 0.5;
		}
		return point;
	}

	/**
	 * Returns a new array full of every coordinate of the requested tile type.
	 *
	 * @param   index     The requested tile type.
	 * @param   midpoint  Whether to return the coordinates of the tile midpoint, or upper left corner. Default is true, return midpoint.
	 * @return  An Array with a list of all the coordinates of that tile type.
	 */
	public function getTileCoords(index:Int, midpoint = true):Array<FlxPoint>
	{
		var array:Array<FlxPoint> = null;

		var point:FlxPoint;
		var l:Int = widthInTiles * heightInTiles;

		for (i in 0...l)
		{
			if (_data[i] == index)
			{
				point = FlxPoint.get(x + (i % widthInTiles) * scaledTileWidth, y + Std.int(i / widthInTiles) * scaledTileHeight);

				if (midpoint)
				{
					point.x += scaledTileWidth * 0.5;
					point.y += scaledTileHeight * 0.5;
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
	 * @param   camera       Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @param   border       Adjusts the camera follow boundary by whatever number of tiles you specify here.  Handy for blocking off deadends that are offscreen, etc.  Use a negative number to add padding instead of hiding the edges.
	 * @param   updateWorld  Whether to update the collision system's world size, default value is true.
	 */
	public function follow(?camera:FlxCamera, border = 0, updateWorld = true):Void
	{
		if (camera == null)
			camera = FlxG.camera;

		camera.setScrollBoundsRect(
			x + border * scaledTileWidth,
			y + border * scaledTileHeight,
			scaledWidth - border * scaledTileWidth * 2,
			scaledHeight - border * scaledTileHeight * 2,
			updateWorld
		);
	}

	/**
	 * Shoots a ray from the start point to the end point.
	 * If/when it passes through a tile, it stores that point and returns false.
	 * Note: In flixel 5.0.0, this was redone, the old method is now `rayStep`
	 *
	 * @param   start   The world coordinates of the start of the ray.
	 * @param   end     The world coordinates of the end of the ray.
	 * @param   result  Optional result vector, to avoid creating a new instance to be returned.
	 *                  Only returned if the line enters the rect.
	 * @return  Returns true if the ray made it from Start to End without hitting anything.
	 *          Returns false and fills Result if a tile was hit.
	 */
	override function ray(start:FlxPoint, end:FlxPoint, ?result:FlxPoint):Bool
	{
		// trim the line to the parts inside the map
		final trimmedStart = calcRayEntry(start, end);
		final trimmedEnd = calcRayExit(start, end);

		start.putWeak();
		end.putWeak();

		if (trimmedStart == null || trimmedEnd == null)
		{
			FlxDestroyUtil.put(trimmedStart);
			FlxDestroyUtil.put(trimmedEnd);
			return true;
		}

		start = trimmedStart;
		end = trimmedEnd;

		inline function clearRefs()
		{
			trimmedStart.put();
			trimmedEnd.put();
		}

		final startIndex = getTileIndexByCoords(start);
		final endIndex = getTileIndexByCoords(end);

		// If the starting tile is solid, return the starting position
		if (getTileCollisions(getTileByIndex(startIndex)) != NONE)
		{
			if (result != null)
				result.copyFrom(start);
			
			clearRefs();
			return false;
		}

		final startTileX = startIndex % widthInTiles;
		final startTileY = Std.int(startIndex / widthInTiles);
		final endTileX = endIndex % widthInTiles;
		final endTileY = Std.int(endIndex / widthInTiles);
		var hitIndex = -1;

		if (start.x == end.x)
		{
			hitIndex = checkColumn(startTileX, startTileY, endTileY);
			if (hitIndex != -1 && result != null)
			{
				// check the bottom
				result.copyFrom(getTileCoordsByIndex(hitIndex, false));
				result.x = start.x;
				if (start.y > end.y)
					result.y += scaledTileHeight;
			}
		}
		else
		{
			// Use y = mx + b formula
			final m = (start.y - end.y) / (start.x - end.x);
			// y - mx = b
			final b = start.y - m * start.x;

			final movesRight = start.x < end.x;
			final inc = movesRight ? 1 : -1;
			final offset = movesRight ? 1 : 0;
			var tileX = startTileX;
			var tileY = 0;
			var xPos = 0.0;
			var yPos = 0.0;
			var lastTileY = startTileY;

			while (tileX != endTileX)
			{
				xPos = x + (tileX + offset) * scaledTileWidth;
				yPos = m * xPos + b;
				tileY = Math.floor((yPos - y) / scaledTileHeight);
				hitIndex = checkColumn(tileX, lastTileY, tileY);
				if (hitIndex != -1)
					break;
				lastTileY = tileY;
				tileX += inc;
			}

			if (hitIndex == -1)
				hitIndex = checkColumn(endTileX, lastTileY, endTileY);

			if (hitIndex != -1 && result != null)
			{
				result.copyFrom(getTileCoordsByIndex(hitIndex, false));
				if (Std.int(hitIndex / widthInTiles) == lastTileY)
				{
					if (start.x > end.x)
						result.x += scaledTileWidth;

					// set result to left side
					result.y = m * result.x + b;//mx + b
				}
				else
				{
					// if ascending
					if (start.y > end.y)
					{
						// change result to bottom
						result.y += scaledTileHeight;
					}
					// otherwise result is top

					// x = (y - b)/m
					result.x = (result.y - b) / m;
				}
			}
		}

		clearRefs();
		return hitIndex == -1;
	}

	function checkColumn(x:Int, startY:Int, endY:Int):Int
	{
		if (startY < 0)
			startY = 0;
		
		if (endY < 0)
			endY = 0;
		
		if (startY > heightInTiles - 1)
			startY = heightInTiles - 1;
		
		if (endY > heightInTiles - 1)
			endY = heightInTiles - 1;
		
		var y = startY;
		final step = startY <= endY ? 1 : -1;
		while (true)
		{
			var index = y * widthInTiles + x;
			if (getTileCollisions(getTileByIndex(index)) != NONE)
				return index;
			
			if (y == endY)
				break;
			
			y += step;
		}
		
		return -1;
	}

	/**
	 * Shoots a ray from the start point to the end point.
	 * If/when it passes through a tile, it stores that point and returns false.
	 * This method checks at steps and can miss, for better results use `ray()`
	 * @since 5.0.0
	 *
	 * @param   start       The world coordinates of the start of the ray.
	 * @param   end         The world coordinates of the end of the ray.
	 * @param   result      Optional result vector, to avoid creating a new instance to be returned.
	 * @param   resolution  Defaults to 1, meaning check every tile or so.  Higher means more checks!
	 *                      Only returned if the line enters the rect.
	 * @return  Returns true if the ray made it from Start to End without hitting anything.
	 *          Returns false and fills Result if a tile was hit.
	 */
	override function rayStep(start:FlxPoint, end:FlxPoint, ?result:FlxPoint, resolution:Float = 1):Bool
	{
		var step:Float = scaledTileWidth;

		if (scaledTileHeight < scaledTileWidth)
			step = scaledTileHeight;

		step /= resolution;
		var deltaX:Float = end.x - start.x;
		var deltaY:Float = end.y - start.y;
		var distance:Float = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		var steps:Int = Math.ceil(distance / step);
		var stepX:Float = deltaX / steps;
		var stepY:Float = deltaY / steps;
		var curX:Float = start.x - stepX - x;
		var curY:Float = start.y - stepY - y;
		var tileX:Int;
		var tileY:Int;
		var i:Int = 0;

		start.putWeak();
		end.putWeak();

		while (i < steps)
		{
			curX += stepX;
			curY += stepY;

			if ((curX < 0) || (curX > scaledWidth) || (curY < 0) || (curY > scaledHeight))
			{
				i++;
				continue;
			}

			tileX = Math.floor(curX / scaledTileWidth);
			tileY = Math.floor(curY / scaledTileHeight);

			if (_tileObjects[_data[tileY * widthInTiles + tileX]].allowCollisions != NONE)
			{
				// Some basic helper stuff
				tileX *= Std.int(scaledTileWidth);
				tileY *= Std.int(scaledTileHeight);
				var rx:Float = 0;
				var ry:Float = 0;
				var q:Float;
				var lx:Float = curX - stepX;
				var ly:Float = curY - stepY;

				// Figure out if it crosses the X boundary
				q = tileX;

				if (deltaX < 0)
				{
					q += scaledTileWidth;
				}

				rx = q;
				ry = ly + stepY * ((q - lx) / stepX);

				if ((ry >= tileY) && (ry <= tileY + scaledTileHeight))
				{
					if (result == null)
					{
						result = FlxPoint.get();
					}

					result.set(rx + x, ry + y);
					return false;
				}

				// Else, figure out if it crosses the Y boundary
				q = tileY;

				if (deltaY < 0)
				{
					q += scaledTileHeight;
				}

				rx = lx + stepX * ((q - ly) / stepY);
				ry = q;

				if ((rx >= tileX) && (rx <= tileX + scaledTileWidth))
				{
					if (result == null)
					{
						result = FlxPoint.get();
					}

					result.set(rx + x, ry + y);
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
	 * @param   x              The X coordinate of the tile (in tiles, not pixels).
	 * @param   y              The Y coordinate of the tile (in tiles, not pixels).
	 * @param   newTile        New tile for the map data. Use -1 if you dont want any changes. Default = 0 (empty)
	 * @param   spriteFactory  Method for converting FlxTile to FlxSprite. If null then will be used defaultTileToSprite() method.
	 * @return FlxSprite.
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
			image = FlxImageFrame.fromEmptyFrame(graphic, FlxRect.get(0, 0, tileWidth, tileHeight));

		var tileX:Float = X * tileWidth * scale.x + x;
		var tileY:Float = Y * tileHeight * scale.y + y;
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
	 * @param   buffer  The FlxTilemapBuffer you are rendering to.
	 * @param   camera  The related FlxCamera, mainly for scroll values.
	 */
	@:access(flixel.FlxCamera)
	function drawTilemap(buffer:FlxTilemapBuffer, camera:FlxCamera):Void
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
			buffer.fill();
		}
		else
		{
			getScreenPosition(_point, camera).subtractPoint(offset).copyToFlash(_helperPoint);

			_helperPoint.x = isPixelPerfectRender(camera) ? Math.floor(_helperPoint.x) : _helperPoint.x;
			_helperPoint.y = isPixelPerfectRender(camera) ? Math.floor(_helperPoint.y) : _helperPoint.y;

			scaledWidth = scaledTileWidth;
			scaledHeight = scaledTileHeight;

			var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());
			drawItem = camera.startQuadBatch(graphic, isColored, hasColorOffsets, blend, antialiasing, shader);
		}

		// Copy tile images into the tile buffer
		_point.x = (camera.scroll.x * scrollFactor.x) - x - offset.x + camera.viewMarginX; // modified from getScreenPosition()
		_point.y = (camera.scroll.y * scrollFactor.y) - y - offset.y + camera.viewMarginY;

		var screenXInTiles:Int = Math.floor(_point.x / scaledTileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / scaledTileHeight);
		var screenRows:Int = buffer.rows;
		var screenColumns:Int = buffer.columns;

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
						frame.paint(buffer.pixels, _flashPoint, true);

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
							buffer.pixels.copyPixels(debugTile, _debugRect, _flashPoint, null, null, true);
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

						_matrix.scale(scaleX, scaleY);
						_matrix.translate(drawX, drawY);

						drawItem.addQuad(frame, _matrix, colorTransform);
					}
				}

				if (FlxG.renderBlit)
					_flashPoint.x += tileWidth;

				columnIndex++;
			}

			if (FlxG.renderBlit)
				_flashPoint.y += tileHeight;
			rowIndex += widthInTiles;
		}

		buffer.x = screenXInTiles * scaledTileWidth;
		buffer.y = screenYInTiles * scaledTileHeight;

		if (FlxG.renderBlit)
		{
			if (isColored)
				buffer.colorTransform(colorTransform);
			buffer.blend = blend;
		}

		buffer.dirty = false;
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

		var debugTile = new BitmapData(tileWidth, tileHeight, true, 0);
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
			gfx.lineTo(tileWidth - 1, 0);
			gfx.lineTo(tileWidth - 1, tileHeight - 1);
			gfx.lineTo(0, tileHeight - 1);
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
	 * @param   index  The index of the tile object in _tileObjects internal array you want to update.
	 */
	override function updateTile(index:Int):Void
	{
		var tile:FlxTile = _tileObjects[index];
		if (tile == null || !tile.visible)
			return;

		tile.frame = frames.frames[index - _startingIndex];
	}

	inline function createBuffer(camera:FlxCamera):FlxTilemapBuffer
	{
		var buffer = new FlxTilemapBuffer(tileWidth, tileHeight, widthInTiles, heightInTiles, camera, scale.x, scale.y);
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
	function set_graphic(value:FlxGraphic):FlxGraphic
	{
		// If graphics are changing
		if (graphic != value)
		{
			// If new graphic is not null, increase its use count
			if (value != null)
				value.useCount++;

			// If old graphic is not null, decrease its use count
			if (graphic != null)
				graphic.useCount--;
		}

		return graphic = value;
	}

	override function set_pixelPerfectRender(value:Bool):Bool
	{
		if (_buffers != null)
			for (buffer in _buffers)
				buffer.pixelPerfectRender = value;

		return pixelPerfectRender = value;
	}

	function set_alpha(value:Float):Float
	{
		alpha = FlxMath.bound(value, 0, 1);
		updateColorTransform();
		return alpha;
	}

	function set_color(value:FlxColor):Int
	{
		if (color == value)
			return value;

		color = value;
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

	function set_blend(value:BlendMode):BlendMode
	{
		setDirty();
		return blend = value;
	}

	function setScaleXYCallback(scale:FlxPoint):Void
	{
		setScaleXCallback(scale);
		setScaleYCallback(scale);
	}

	function setScaleXCallback(scale:FlxPoint):Void
	{
		scaledTileWidth = tileWidth * scale.x;
		width = scaledWidth;

		if (cameras == null)
			return;

		for (i in 0...cameras.length)
			if (_buffers[i] != null)
				_buffers[i].updateColumns(tileWidth, widthInTiles, scale.x, cameras[i]);
	}

	function setScaleYCallback(scale:FlxPoint):Void
	{
		scaledTileHeight = tileHeight * scale.y;
		height = scaledHeight;

		if (cameras == null)
			return;

		for (i in 0...cameras.length)
			if (_buffers[i] != null)
				_buffers[i].updateRows(tileHeight, heightInTiles, scale.y, cameras[i]);
	}

	/**
	 * Default method for generating FlxSprite from FlxTile
	 *
	 * @param   tileProperties  properties for new sprite
	 * @return  New FlxSprite with specified graphic
	 */
	function defaultTileToSprite(tileProperties:FlxTileProperties):FlxSprite
	{
		var tileSprite = new FlxSprite(tileProperties.x, tileProperties.y);
		tileSprite.frames = tileProperties.graphic;
		tileSprite.scale.copyFrom(tileProperties.scale);
		tileProperties.scale = FlxDestroyUtil.put(tileProperties.scale);
		tileSprite.alpha = tileProperties.alpha;
		tileSprite.blend = tileProperties.blend;
		return tileSprite;
	}

	override function set_allowCollisions(value:Int):Int
	{
		for (tile in _tileObjects)
			if (tile.index >= _collideIndex)
				tile.allowCollisions = value;

		return super.set_allowCollisions(value);
	}

	inline function get_scaledWidth():Float
	{
		return widthInTiles * scaledTileWidth;
	}

	inline function get_scaledHeight():Float
	{
		return heightInTiles * scaledTileHeight;
	}

	/**
	 * Get the world coordinates and size of the entire tilemap as a FlxRect.
	 *
	 * @param   bounds  Optional, pass in a pre-existing FlxRect to prevent instantiation of a new object.
	 * @return  A FlxRect containing the world coordinates and size of the entire tilemap.
	 */
	override function getBounds(?bounds:FlxRect):FlxRect
	{
		if (bounds == null)
			bounds = FlxRect.get();

		return bounds.set(x, y, scaledWidth, scaledHeight);
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
