package flixel.tile;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxImageFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.graphics.tile.FlxDrawStackItem;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTilemapAsset;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import openfl.display.Tilesheet;
import openfl.geom.ColorTransform;

@:bitmap("assets/images/tile/autotiles.png")
class GraphicAuto extends BitmapData {}

@:bitmap("assets/images/tile/autotiles_alt.png")
class GraphicAutoAlt extends BitmapData { }

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
	
	/**
	 * Helper variable for non-flash targets. Adjust it's value if you'll see tilemap tearing (empty pixels between tiles). To something like 1.02 or 1.03
	 */
	public var tileScaleHack:Float = 1.00;
	
	/**
	 * Changes the size of this tilemap. Default is (1, 1). 
	 * Anything other than the default is very slow with blitting!
	 */
	public var scale(default, null):FlxPoint;
	
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
	
	public var colorTransform(default, null):ColorTransform;
	
	/**
	 * Blending modes, just like Photoshop or whatever, e.g. "multiply", "screen", etc.
	 */
	public var blend(default, set):BlendMode = null;
	
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashPoint:Point;
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashRect:Rectangle;
	/**
	 * Internal list of buffers, one for each camera, used for drawing the tilemaps.
	 */
	private var _buffers:Array<FlxTilemapBuffer>;
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
	
	private var _drawIndex:Int = 0;
	private var _collideIndex:Int = 0;
	
	#if (FLX_RENDER_BLIT && !FLX_NO_DEBUG)
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugTileNotSolid:BitmapData;
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugTilePartial:BitmapData;
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugTileSolid:BitmapData;
	/**
	 * Internal, used for rendering the debug bounding box display.
	 */
	private var _debugRect:Rectangle;
	#end
	
	#if FLX_RENDER_TILE
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods. Used only in cpp
	 */
	private var _helperPoint:Point;
	
	private var _blendInt:Int = 0;
	
	private var _matrix:FlxMatrix;
	#end
	
	/**
	 * The tilemap constructor just initializes some basic variables.
	 */
	public function new()
	{
		super();
		
		_buffers = new Array<FlxTilemapBuffer>();
		_flashPoint = new Point();
		_flashRect = new Rectangle();
		
		#if FLX_RENDER_TILE
		_helperPoint = new Point();
		_matrix = new FlxMatrix();
		#end
		
		colorTransform = new ColorTransform();
		
		scale = new FlxCallbackPoint(setScaleXCallback, setScaleYCallback, setScaleXYCallback);
		scale.set(1, 1);
		
		FlxG.signals.gameResized.add(onGameResize);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_flashPoint = null;
		_flashRect = null;
		var i:Int = 0;
		var l:Int;
		
		_tileObjects = FlxDestroyUtil.destroyArray(_tileObjects);
		_buffers = FlxDestroyUtil.destroyArray(_buffers);
		
		#if FLX_RENDER_BLIT
		#if !FLX_NO_DEBUG
		_debugRect = null;
		_debugTileNotSolid = null;
		_debugTilePartial = null;
		_debugTileSolid = null;
		#end
		#else
		_helperPoint = null;
		_matrix = null;
		#end
		
		frames = null;
		graphic = null;
		
		// need to destroy FlxCallbackPoints
		scale = FlxDestroyUtil.destroy(scale);
		
		colorTransform = null;
		
		FlxG.signals.gameResized.remove(onGameResize);
		
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
			initTileObjects(_drawIndex, _collideIndex);
			computeDimensions();
			updateMap();
		}
		
		return value;
	}
	
	override public function loadMap(MapData:FlxTilemapAsset, TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0, 
		?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1):FlxTilemap
	{
		auto = (AutoTile == null) ? OFF : AutoTile;
		_startingIndex = (StartingIndex <= 0) ? 0 : StartingIndex;

		if (auto != OFF)
		{
			_startingIndex = 1;
			DrawIndex = 1;
			CollideIndex = 1;
		}
		
		loadMapData(MapData);
		applyAutoTile(DrawIndex, CollideIndex);
		applyCustomRemap();
		randomizeIndices();
		cacheGraphics(TileWidth, TileHeight, TileGraphic);
		
		return this;
	}
	
	override private function cacheGraphics(TileWidth:Int, TileHeight:Int, TileGraphic:FlxTilemapGraphicAsset):Void 
	{
		if (Std.is(TileGraphic, FlxTileFrames))
		{
			frames = cast(TileGraphic, FlxTileFrames);
			return;
		}
		
		var graph:FlxGraphic = FlxG.bitmap.add(cast TileGraphic);
		// Figure out the size of the tiles
		_tileWidth = TileWidth;
		
		if (_tileWidth <= 0)
		{
			_tileWidth = graph.height;
		}
		
		_tileHeight = TileHeight;
		
		if (_tileHeight <= 0)
		{
			_tileHeight = _tileWidth;
		}
		
		frames = FlxTileFrames.fromGraphic(graph, new FlxPoint(_tileWidth, _tileHeight));
	}
	
	override private function initTileObjects(DrawIndex:Int, CollideIndex:Int):Void 
	{
		_tileObjects = FlxDestroyUtil.destroyArray(_tileObjects);
		// Create some tile objects that we'll use for overlap checks (one for each tile)
		_tileObjects = new Array<FlxTile>();
		
		var length:Int = frames.numFrames;
		length += _startingIndex;
		
		for (i in 0...length)
		{
			_tileObjects[i] = new FlxTile(this, i, _tileWidth, _tileHeight, (i >= DrawIndex), (i >= CollideIndex) ? allowCollisions : FlxObject.NONE);
		}
		
		// Create debug tiles for rendering bounding boxes on demand
		#if (FLX_RENDER_BLIT && !FLX_NO_DEBUG)
		_debugTileNotSolid = makeDebugTile(FlxColor.BLUE);
		_debugTilePartial = makeDebugTile(FlxColor.PINK);
		_debugTileSolid = makeDebugTile(FlxColor.GREEN);
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
		#if (!FLX_NO_DEBUG && FLX_RENDER_BLIT)
		_debugRect = new Rectangle(0, 0, _tileWidth, _tileHeight);
		#end
		
		for (i in 0...totalTiles)
		{
			updateTile(i);
		}
	}
	
	#if !FLX_NO_DEBUG
	override public function drawDebugOnCamera(Camera:FlxCamera):Void
	{
		#if FLX_RENDER_TILE
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
		{
			return;
		}
		
		// Copied from getScreenXY()
		_helperPoint.x = Math.floor((x - Math.floor(Camera.scroll.x) * scrollFactor.x) * 5) / 5 + 0.1;
		_helperPoint.y = Math.floor((y - Math.floor(Camera.scroll.y) * scrollFactor.y) * 5) / 5 + 0.1;
		
		_helperPoint.x *= Camera.totalScaleX;
		_helperPoint.y *= Camera.totalScaleY;
		
		var debugColor:FlxColor;
		var drawX:Float;
		var drawY:Float;
		
		var rectWidth:Float = _scaledTileWidth * Camera.totalScaleX;
		var rectHeight:Float = _scaledTileHeight * Camera.totalScaleY;
	
		// Copy tile images into the tile buffer
		// Modified from getScreenXY()
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
		var debugTile:BitmapData;
		
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
		#end
	}
	#end
	
	/**
	 * Draws the tilemap buffers to the cameras.
	 */
	override public function draw():Void
	{
		// don't try to render a tilemap that isn't loaded yet
		if (graphic == null)
		{
			return;
		}
		
		var camera:FlxCamera;
		var buffer:FlxTilemapBuffer;
		var l:Int = cameras.length;
		
		for (i in 0...l)
		{
			camera = cameras[i];
			
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			if (_buffers[i] == null)
			{
				_buffers[i] = createBuffer(camera);
			}
			
			buffer = _buffers[i];
			
			#if FLX_RENDER_BLIT
			getScreenPosition(_point, camera).add(buffer.x, buffer.y);
			buffer.dirty = buffer.dirty || _point.x > 0 || (_point.y > 0) || (_point.x + buffer.width < camera.width) || (_point.y + buffer.height < camera.height);
			
			if (buffer.dirty)
			{
				drawTilemap(buffer, camera);
			}
			
			getScreenPosition(_point, camera).add(buffer.x, buffer.y).copyToFlash(_flashPoint);
			buffer.draw(camera, _flashPoint, scale.x, scale.y);
			#else			
			drawTilemap(buffer, camera);
			#end
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
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
		{
			buffer.dirty = true;
		}
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
		
		var X:Float = x;
		var Y:Float = y;
		
		if (Position != null)
		{
			X = Position.x;
			Y = Position.y;
		}
		
		// Figure out what tiles we need to check against
		var selectionX:Int = Math.floor((Object.x - X) / _scaledTileWidth);
		var selectionY:Int = Math.floor((Object.y - Y) / _scaledTileHeight);
		var selectionWidth:Int = selectionX + Math.ceil(Object.width / _scaledTileWidth) + 1;
		var selectionHeight:Int = selectionY + Math.ceil(Object.height / _scaledTileHeight) + 1;
		
		// Then bound these coordinates by the map edges
		selectionWidth = Std.int(FlxMath.bound(selectionWidth, 0, widthInTiles));
		selectionHeight = Std.int(FlxMath.bound(selectionHeight, 0, heightInTiles));
		
		// Then loop through this selection of tiles
		var rowStart:Int = selectionY * widthInTiles;
		var column:Int;
		var tile:FlxTile;
		var overlapFound:Bool;
		var deltaX:Float = X - last.x;
		var deltaY:Float = Y - last.y;
		
		for (row in selectionY...selectionHeight)
		{
			column = selectionX;
			
			while (column < selectionWidth)
			{
				var index:Int = rowStart + column;
				if ((index < 0) || (index > _data.length - 1))
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
				tile.x = X + column * tile.width;
				tile.y = Y + row * tile.height;
				tile.last.x = tile.x - deltaX;
				tile.last.y = tile.y - deltaY;
				
				overlapFound = ((Object.x + Object.width) > tile.x)  && (Object.x < (tile.x + tile.width)) && 
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
					if ((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
					{
						tile.mapIndex = rowStart + column;
						tile.callbackFunction(tile, Object);
					}
					
					if (tile.allowCollisions != FlxObject.NONE)
					{
						results = true;
					}
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
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @param	Border			Adjusts the camera follow boundary by whatever number of tiles you specify here.  Handy for blocking off deadends that are offscreen, etc.  Use a negative number to add padding instead of hiding the edges.
	 * @param	UpdateWorld		Whether to update the collision system's world size, default value is true.
	 */
	public function follow(?Camera:FlxCamera, Border:Int = 0, UpdateWorld:Bool = true):Void
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
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
		{
			step = _scaledTileHeight;
		}
		
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
				
				if ((ry > tileY) && (ry < tileY + _scaledTileHeight))
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
				
				if ((rx > tileX) && (rx < tileX + _scaledTileWidth))
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
	 * Use this method for creating tileSheet for FlxTilemap. Must be called after loadMap() method.
	 * If you forget to call it then you will not see this FlxTilemap on c++ target
	 */
	public function updateTiles():Void
	{
		if (graphic != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			for (i in 0...totalTiles)
			{
				updateTile(i);
			}
		}
	}
	
	/**
	 * Change a particular tile to FlxSprite. Or just copy the graphic if you dont want any changes to mapdata itself.
	 * 
	 * @link http://forums.flixel.org/index.php/topic,5398.0.html
	 * @param	X		The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y		The Y coordinate of the tile (in tiles, not pixels).
	 * @param	NewTile	New tile to the mapdata. Use -1 if you dont want any changes. Default = 0 (empty)
	 * @return	FlxSprite.
	 */
	public function tileToFlxSprite(X:Int, Y:Int, NewTile:Int = 0):FlxSprite
	{
		var rowIndex:Int = X + (Y * widthInTiles);
		
		var tile:FlxTile = _tileObjects[_data[rowIndex]];
		var tileSprite:FlxSprite = new FlxSprite();
		tileSprite.x = X * _tileWidth + x;
		tileSprite.y = Y * _tileHeight + y;
		
		if (tile != null && tile.visible)
		{
			var image:FlxImageFrame = FlxImageFrame.fromFrame(tile.frame);
			tileSprite.frames = image;
		}
		else
		{
			tileSprite.makeGraphic(_tileWidth, _tileHeight, FlxColor.TRANSPARENT, true);
		}
		
		tileSprite.scale.copyFrom(scale);
		tileSprite.dirty = true;

		if (NewTile >= 0) 
		{
			setTile(X, Y, NewTile);
		}
		
		return tileSprite;
	}
	
	/**
	 * Use this method so the tilemap buffers are updated, eg when resizing your game
	 */
	public function updateBuffers():Void
	{
		_buffers = FlxDestroyUtil.destroyArray(_buffers);
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
	#if FLX_RENDER_BLIT
		Buffer.fill();
	#else
		getScreenPosition(_point, Camera).copyToFlash(_helperPoint);
		
		_helperPoint.x *= Camera.totalScaleX;
		_helperPoint.y *= Camera.totalScaleY;
		
		_helperPoint.x = isPixelPerfectRender(Camera) ? Math.floor(_helperPoint.x) : _helperPoint.x;
		_helperPoint.y = isPixelPerfectRender(Camera) ? Math.floor(_helperPoint.y) : _helperPoint.y;
		
		var drawX:Float;
		var drawY:Float;
		
		var scaledWidth:Float = _scaledTileWidth * Camera.totalScaleX;
		var scaledHeight:Float = _scaledTileHeight * Camera.totalScaleY;
		
		var scaleX:Float = scale.x * Camera.totalScaleX;
		var scaleY:Float = scale.y * Camera.totalScaleY;
		
		var hackScaleX:Float = tileScaleHack * scaleX;
		var hackScaleY:Float = tileScaleHack * scaleY;
		
		var drawItem:FlxDrawStackItem;
	#end
	
		var isColored:Bool = ((alpha != 1) || (color != 0xffffff));
		
		// Copy tile images into the tile buffer
		_point.x = (Camera.scroll.x * scrollFactor.x) - x; //modified from getScreenXY()
		_point.y = (Camera.scroll.y * scrollFactor.y) - y;
		
		var screenXInTiles:Int = Math.floor(_point.x / _scaledTileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _scaledTileHeight);
		var screenRows:Int = Buffer.rows;
		var screenColumns:Int = Buffer.columns;
		
		// Bound the upper left corner
		if (screenXInTiles < 0)
		{
			screenXInTiles = 0;
		}
		if (screenXInTiles > widthInTiles - screenColumns)
		{
			screenXInTiles = widthInTiles - screenColumns;
		}
		if (screenYInTiles < 0)
		{
			screenYInTiles = 0;
		}
		if (screenYInTiles > heightInTiles - screenRows)
		{
			screenYInTiles = heightInTiles - screenRows;
		}
		
		var rowIndex:Int = screenYInTiles * widthInTiles + screenXInTiles;
		_flashPoint.y = 0;
		var columnIndex:Int;
		var tile:FlxTile;
		var frame:FlxFrame;
		
		#if !FLX_NO_DEBUG
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
					
				#if FLX_RENDER_BLIT
					Buffer.pixels.copyPixels(frame.getBitmap(), _flashRect, _flashPoint, null, null, true);
					
					#if !FLX_NO_DEBUG
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
						
						Buffer.pixels.copyPixels(debugTile, _debugRect, _flashPoint, null, null, true);
					}
					#end
				#else
					drawX = _helperPoint.x + (columnIndex % widthInTiles) * scaledWidth + frame.center.x * scaleX;
					drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * scaledHeight + frame.center.y * scaleY;
					
					_point.set(drawX, drawY);
					
					_matrix.identity();
					
					if (frame.angle != FlxFrameAngle.ANGLE_0)
					{
						frame.prepareFrameMatrix(_matrix);
					}
					
					_matrix.scale(hackScaleX, hackScaleY);
					
					drawItem = Camera.getDrawStackItem(graphic, isColored, _blendInt);
					drawItem.setDrawData(_point, frame.tileID, _matrix, isColored, color, alpha);
				#end
				}
				
				#if FLX_RENDER_BLIT
				_flashPoint.x += _tileWidth;
				#end
				columnIndex++;
			}
			
			#if FLX_RENDER_BLIT
			_flashPoint.y += _tileHeight;
			#end
			rowIndex += widthInTiles;
		}
		
		Buffer.x = screenXInTiles * _scaledTileWidth;
		Buffer.y = screenYInTiles * _scaledTileHeight;
		
		#if FLX_RENDER_BLIT
		if (isColored)
		{
			Buffer.colorTransform(colorTransform);
		}
		Buffer.blend = blend;
		#end
		
		Buffer.dirty = false;
	}
	
	/**
	 * Internal function to clean up the map loading code.
	 * Just generates a wireframe box the size of a tile with the specified color.
	 */
	#if (FLX_RENDER_BLIT && !FLX_NO_DEBUG)
	private function makeDebugTile(Color:FlxColor):BitmapData
	{
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
	 * @param	Index		The index of the tile you want to update.
	 */
	override private function updateTile(Index:Int):Void
	{
		var tile:FlxTile = _tileObjects[_data[Index]];
		
		if ((tile == null) || !tile.visible)
		{
			return;
		}
		
		tile.frame = frames.frames[_data[Index] - _startingIndex];
	}
	
	private inline function createBuffer(camera:FlxCamera):FlxTilemapBuffer
	{
		var buffer = new FlxTilemapBuffer(_tileWidth, _tileHeight, widthInTiles, heightInTiles, camera, scale.x, scale.y);
		buffer.pixelPerfectRender = pixelPerfectRender;
		return buffer;
	}
	
	/**
	 * Signal listener for gameResize 
	 */
	private function onGameResize(_,_):Void
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
			{
				Value.useCount++;
			}
			//If old graphic is not null, decrease its use count
			if (graphic != null)
			{
				graphic.useCount--;
			}
		}
		
		return graphic = Value;
	}
	
	override private function set_pixelPerfectRender(Value:Bool):Bool 
	{
		if (_buffers != null)
		{
			for (buffer in _buffers)
			{
				buffer.pixelPerfectRender = Value;
			}
		}
		
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
		{
			return Color;
		}
		color = Color;
		updateColorTransform();
		
		return color;
	}
	
	private function updateColorTransform():Void
	{
		if ((alpha != 1) || (color != 0xffffff))
		{
			colorTransform.redMultiplier = color.redFloat;
			colorTransform.greenMultiplier = color.greenFloat;
			colorTransform.blueMultiplier = color.blueFloat;
			colorTransform.alphaMultiplier = alpha;
		}
		else
		{
			colorTransform.redMultiplier = 1;
			colorTransform.greenMultiplier = 1;
			colorTransform.blueMultiplier = 1;
			colorTransform.alphaMultiplier = 1;
		}
		
		#if FLX_RENDER_BLIT
		setDirty();
		#end
	}
	
	private function set_blend(Value:BlendMode):BlendMode 
	{
		#if FLX_RENDER_TILE
		if (Value != null)
		{
			switch (Value)
			{
				case BlendMode.ADD:
					_blendInt = Tilesheet.TILE_BLEND_ADD;
				#if !flash
				case BlendMode.MULTIPLY:
					_blendInt = Tilesheet.TILE_BLEND_MULTIPLY;
				case BlendMode.SCREEN:
					_blendInt = Tilesheet.TILE_BLEND_SCREEN;
				#end
				default:
					_blendInt = Tilesheet.TILE_BLEND_NORMAL;
			}
		}
		else
		{
			_blendInt = 0;
		}
		#else
		setDirty();
		#end	
		
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
		
		if (cameras != null)
		{
			for (i in 0...cameras.length)
			{
				if (_buffers[i] != null)
				{
					_buffers[i].updateColumns(_tileWidth, widthInTiles, scale.x, cameras[i]);
				}
			}
		}
	}
	
	private function setScaleYCallback(Scale:FlxPoint):Void
	{
		_scaledTileHeight = _tileHeight * scale.y;
		height = heightInTiles * _scaledTileHeight;
		
		if (cameras != null)
		{
			for (i in 0...cameras.length)
			{
				if (_buffers[i] != null)
				{
					_buffers[i].updateRows(_tileHeight, heightInTiles, scale.y, cameras[i]);
				}
			}
		}
	}
}
