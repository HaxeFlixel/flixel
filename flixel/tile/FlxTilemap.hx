package flixel.tile;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.layer.DrawStackItem;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.system.layer.Region;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import flixel.util.loaders.CachedGraphics;
import flixel.util.loaders.TextureRegion;

@:bitmap("assets/images/tile/autotiles.png")
class GraphicAuto extends BitmapData {}

@:bitmap("assets/images/tile/autotiles_alt.png")
class GraphicAutoAlt extends BitmapData {}

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
	public var tileScaleHack:Float = 1.01;
	
	/**
	 * Changes the size of this tilemap. Default is (1, 1). 
	 * Anything other than the default is very slow with blitting!
	 */
	public var scale(default, null):FlxPoint;
	
	/**
	 * Rendering variables.
	 */
	public var region(default, null):Region;
	public var framesData(default, null):FlxSpriteFrames;
	public var cachedGraphics(default, set):CachedGraphics;
	
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
	 * Internal representation of rectangles, one for each tile in the entire tilemap, used to speed up drawing.
	 */
	#if FLX_RENDER_BLIT
	private var _rects:Array<Rectangle>;
	#end
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
	/**
	 * Internal representation of rectangles (actually id of rectangle in tileSheet), one for each tile in the entire tilemap, used to speed up drawing.
	 */
	private var _rectIDs:Array<Int>;
	#end
	
	
	/**
	 * The tilemap constructor just initializes some basic variables.
	 */
	public function new()
	{
		super();
		
		_buffers = new Array<FlxTilemapBuffer>();
		_flashPoint = new Point();
		
		#if FLX_RENDER_TILE
		_helperPoint = new Point();
		#end
		
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
		
		if (_tileObjects != null)
		{
			l = _tileObjects.length;
			
			for (i in 0...l)
			{
				_tileObjects[i].destroy();
			}
			
			_tileObjects = null;
		}
		
		if (_buffers != null)
		{
			i = 0;
			l = _buffers.length;
			
			for (i in 0...l)
			{
				_buffers[i].destroy();
			}
			
			_buffers = null;
		}
		
		#if FLX_RENDER_BLIT
		_rects = null;
		#if !FLX_NO_DEBUG
		_debugRect = null;
		_debugTileNotSolid = null;
		_debugTilePartial = null;
		_debugTileSolid = null;
		#end
		#else
		_helperPoint = null;
		_rectIDs = null;
		#end
		
		framesData = null;
		cachedGraphics = null;
		region = null;
		
		// need to destroy FlxCallbackPoints
		scale = FlxDestroyUtil.destroy(scale);
		
		FlxG.signals.gameResized.remove(onGameResize);
		
		super.destroy();
	}
	
	override private function cacheGraphics(TileWidth:Int, TileHeight:Int, TileGraphic:Dynamic):Void 
	{
		// Figure out the size of the tiles
		cachedGraphics = FlxG.bitmap.add(TileGraphic);
		_tileWidth = TileWidth;
		
		if (_tileWidth <= 0)
		{
			_tileWidth = cachedGraphics.bitmap.height;
		}
		
		_tileHeight = TileHeight;
		
		if (_tileHeight <= 0)
		{
			_tileHeight = _tileWidth;
		}
		
		if (!Std.is(TileGraphic, TextureRegion))
		{
			region = new Region(0, 0, _tileWidth, _tileHeight);
			region.width = Std.int(cachedGraphics.bitmap.width / _tileWidth) * _tileWidth;
			region.height = Std.int(cachedGraphics.bitmap.height / _tileHeight) * _tileHeight;
		}
		else
		{
			var spriteRegion:TextureRegion = cast TileGraphic;
			region = spriteRegion.region.clone();
			if (region.tileWidth > 0)
			{
				_tileWidth = region.tileWidth;
			}
			else
			{
				region.tileWidth = _tileWidth;
			}
			
			if (region.tileHeight > 0)
			{
				_tileHeight = region.tileWidth;
			}
			else
			{
				region.tileHeight = _tileHeight;
			}
		}
	}
	
	override private function initTileObjects(DrawIndex:Int, CollideIndex:Int):Void 
	{
		// Create some tile objects that we'll use for overlap checks (one for each tile)
		_tileObjects = new Array<FlxTile>();
		
		var length:Int = region.numTiles;
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
		#if FLX_RENDER_BLIT
		#if !FLX_NO_DEBUG
		_debugRect = new Rectangle(0, 0, _tileWidth, _tileHeight);
		#end
		
		_rects = new Array<Rectangle>();
		FlxArrayUtil.setLength(_rects, totalTiles);
		var i:Int = 0;
		while (i < totalTiles)
		{
			updateTile(i++);
		}
		#else
		updateFrameData();
		#end
	}
	
	#if !FLX_NO_DEBUG
	override public function drawDebugOnCamera(Camera:FlxCamera):Void
	{
		#if FLX_RENDER_TILE
		var buffer:FlxTilemapBuffer = null;
		
		for (i in 0...FlxG.cameras.list.length)
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
		
		var tileID:Int;
		var debugColor:FlxColor;
		var drawX:Float;
		var drawY:Float;
	
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
		_flashPoint.y = 0;
		var row:Int = 0;
		var column:Int;
		var columnIndex:Int;
		var tile:FlxTile;
		var debugTile:BitmapData;
		
		while (row < screenRows)
		{
			columnIndex = rowIndex;
			column = 0;
			_flashPoint.x = 0;
			
			while (column < screenColumns)
			{
				tileID = _rectIDs[columnIndex];
				
				if (tileID != -1)
				{
					drawX = _helperPoint.x + (columnIndex % widthInTiles) * _scaledTileWidth;
					drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * _scaledTileHeight;
					
					tile = _tileObjects[_data[columnIndex]];
					
					if (tile != null)
					{
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
						gfx.drawRect(drawX, drawY, _scaledTileWidth, _scaledTileHeight);
					}
				}
				
				_flashPoint.x += _scaledTileWidth;
				column++;
				columnIndex++;
			}
			
			rowIndex += widthInTiles;
			_flashPoint.y += _scaledTileHeight;
			row++;
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
		if (cachedGraphics == null)
		{
			return;
		}
		
		var cameras = cameras;
		var camera:FlxCamera;
		var buffer:FlxTilemapBuffer;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		while (i < l)
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
			
			buffer = _buffers[i++];
				
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
		var row:Int = selectionY;
		var column:Int;
		var tile:FlxTile;
		var overlapFound:Bool;
		var deltaX:Float = X - last.x;
		var deltaY:Float = Y - last.y;
		
		while (row < selectionHeight)
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
			row++;
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
		var point = FlxPoint.get(x + Std.int(Index % widthInTiles) * _scaledTileWidth, y + Std.int(Index / widthInTiles) * _scaledTileHeight);
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
		var i:Int = 0;
		var l:Int = widthInTiles * heightInTiles;
		
		while (i < l)
		{
			if (_data[i] == Index)
			{
				point = FlxPoint.get(x + Std.int(i % widthInTiles) * _scaledTileWidth, y + Std.int(i / widthInTiles) * _scaledTileHeight);
				
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
			i++;
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
	public function updateFrameData():Void
	{
		if (cachedGraphics != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			framesData = cachedGraphics.tilesheet.getSpriteSheetFrames(region, new Point(0, 0));
			#if FLX_RENDER_TILE
			_rectIDs = new Array<Int>();
			FlxArrayUtil.setLength(_rectIDs, totalTiles);
			#end
			var i:Int = 0;
			
			while (i < totalTiles)
			{
				updateTile(i++);
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
		
		var rect:Rectangle = null;
		
		#if FLX_RENDER_BLIT
		rect = _rects[rowIndex];
		#else
		
		var tile:FlxTile = _tileObjects[_data[rowIndex]];
		
		if ((tile == null) || !tile.visible)
		{
			// Nothing to do here: rect object should stay null.
		}
		else
		{
			var rx:Int = (_data[rowIndex] - _startingIndex) * (_tileWidth + region.spacingX);
			var ry:Int = 0;
			
			if (rx >= region.width)
			{
				ry = Std.int(rx / region.width) * (_tileHeight + region.spacingY);
				rx %= region.width;
			}
			
			rect = new Rectangle(rx + region.startX, ry + region.startY, _tileWidth, _tileHeight);
		}
		#end
		
		// TODO: make it better for native targets
		var pt = new Point(0, 0);
		var tileSprite:FlxSprite = new FlxSprite();
		tileSprite.makeGraphic(_tileWidth, _tileHeight, FlxColor.TRANSPARENT, true);
		tileSprite.x = X * _tileWidth + x;
		tileSprite.y = Y * _tileHeight + y;
		tileSprite.scale.copyFrom(scale);
		
		if (rect != null) 
		{
			tileSprite.pixels.copyPixels(cachedGraphics.bitmap, rect, pt);
		}
		
		tileSprite.dirty = true;
		tileSprite.updateFrameData();

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
		var i:Int = 0;
		var l:Int;
		
		if (_buffers != null)
		{
			i = 0;
			l = _buffers.length;
			
			for (i in 0...l)
			{
				_buffers[i].destroy();
			}
			
			_buffers = null;
		}
		
		_buffers = new Array<FlxTilemapBuffer>();
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
		
		var tileID:Int;
		var drawX:Float;
		var drawY:Float;
		
		var hackScaleX:Float = tileScaleHack * scale.x;
		var hackScaleY:Float = tileScaleHack * scale.y;
	#end
		
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
		var row:Int = 0;
		var column:Int;
		var columnIndex:Int;
		var tile:FlxTile;
		
		#if !FLX_NO_DEBUG
		var debugTile:BitmapData;
		#end 
		
		while (row < screenRows)
		{
			columnIndex = rowIndex;
			column = 0;
			_flashPoint.x = 0;
			
			while (column < screenColumns)
			{
				#if FLX_RENDER_BLIT
				_flashRect = _rects[columnIndex];
				
				if (_flashRect != null)
				{
					Buffer.pixels.copyPixels(cachedGraphics.bitmap, _flashRect, _flashPoint, null, null, true);
					
					#if !FLX_NO_DEBUG
					if (FlxG.debugger.drawDebug && !ignoreDrawDebug) 
					{
						tile = _tileObjects[_data[columnIndex]];
						
						if (tile != null)
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
					}
					#end
				}
				#else
				tileID = _rectIDs[columnIndex];
				
				if (tileID != -1)
				{
					drawX = _helperPoint.x + (columnIndex % widthInTiles) * _scaledTileWidth;
					drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * _scaledTileHeight;
					
					_point.x = isPixelPerfectRender(Camera) ? Math.floor(drawX) : drawX;
					_point.y = isPixelPerfectRender(Camera) ? Math.floor(drawY) : drawY;
					
					var drawItem:DrawStackItem = Camera.getDrawStackItem(cachedGraphics, false, 0);
					drawItem.setDrawData(_point, tileID, hackScaleX, 0, 0, hackScaleY);
				}
				#end
				
				#if FLX_RENDER_BLIT
				_flashPoint.x += _tileWidth;
				#end
				column++;
				columnIndex++;
			}
			
			#if FLX_RENDER_BLIT
			_flashPoint.y += _tileHeight;
			#end
			rowIndex += widthInTiles;
			row++;
		}
		
		Buffer.x = screenXInTiles * _scaledTileWidth;
		Buffer.y = screenYInTiles * _scaledTileHeight;
		
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
			#if FLX_RENDER_BLIT
			_rects[Index] = null;
			#else
			_rectIDs[Index] = -1;
			#end
			
			return;
		}
		
		#if FLX_RENDER_BLIT
		var rx:Int = (_data[Index] - _startingIndex) * (_tileWidth + region.spacingX);
		var ry:Int = 0;
		
		if (rx >= region.width)
		{
			ry = Std.int(rx / region.width) * (_tileHeight + region.spacingY);
			rx %= region.width;
		}
		_rects[Index] = (new Rectangle(rx + region.startX, ry + region.startY, _tileWidth, _tileHeight));
		#else
		_rectIDs[Index] = framesData.frames[_data[Index] - _startingIndex].tileID;
		#end
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
	 * Internal function for setting cachedGraphics property for this object. 
	 * It changes cachedGraphics' useCount also for better memory tracking.
	 */
	private function set_cachedGraphics(Value:CachedGraphics):CachedGraphics
	{
		//If graphics are changing
		if (cachedGraphics != Value)
		{
			//If new graphic is not null, increase its use count
			if (Value != null)
			{
				Value.useCount++;
			}
			//If old graphic is not null, decrease its use count
			if (cachedGraphics != null)
			{
				cachedGraphics.useCount--;
			}
		}
		
		return cachedGraphics = Value;
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
