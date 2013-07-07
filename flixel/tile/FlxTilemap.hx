package flixel.tile;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.system.layer.DrawStackItem;
import flixel.util.FlxArray;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;

/**
 * This is a traditional tilemap display and collision class.
 * It takes a string of comma-separated numbers and then associates
 * those values with tiles from the sheet you pass in.
 * It also includes some handy static parsers that can convert
 * arrays or images into strings that can be loaded.
 */
class FlxTilemap extends FlxObject
{
	/**
	 * A set of generic tiles you can use. Useful for protyping.
	 */
	inline static public var imgAuto:String = FlxAssets.imgAuto;
	/**
	 * An alternate set of generic tiles you can use. Useful for protyping.
	 */
	inline static public var imgAutoAlt:String = FlxAssets.imgAutoAlt;
	
	/**
	 * No auto-tiling.
	 */
	inline static public var OFF:Int = 0;
	/**
	 * Good for levels with thin walls that don'tile need interior corner art.
	 */
	inline static public var AUTO:Int = 1;
	/**
	 * Better for levels with thick walls that look better with interior corner art.
	 */
	inline static public var ALT:Int = 2;
	
	/**
	 * Set this flag to use one of the 16-tile binary auto-tile algorithms (OFF, AUTO, or ALT).
	 */
	public var auto:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var widthInTiles:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var heightInTiles:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var totalTiles:Int;
	/**
	 * Helper variable for non-flash targets. Adjust it's value if you'll see tilemap tearing (empty pixels between tiles). To something like 1.02 or 1.03
	 */
	public var tileScaleHack:Float = 1.01;
	
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashPoint:Point;
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods.
	 */
	private var _flashRect:Rectangle;
	/**
	 * Internal reference to the bitmap data object that stores the original tile graphics.
	 */
	private var _tiles:BitmapData;
	/**
	 * Internal list of buffers, one for each camera, used for drawing the tilemaps.
	 */
	private var _buffers:Array<FlxTilemapBuffer>;
	/**
	 * Internal representation of the actual tile data, as a large 1D array of integers.
	 */
	private var _data:Array<Int>;
	/**
	 * Internal representation of rectangles, one for each tile in the entire tilemap, used to speed up drawing.
	 */
	#if flash
	private var _rects:Array<Rectangle>;
	#end
	/**
	 * Internal, the width of a single tile.
	 */
	private var _tileWidth:Int;
	/**
	 * Internal, the height of a single tile.
	 */
	private var _tileHeight:Int;
	/**
	 * Internal collection of tile objects, one for each type of tile in the map (NOTE one for every single tile in the whole map).
	 */
	private var _tileObjects:Array<FlxTile>;
	
	#if !FLX_NO_DEBUG
	#if flash
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
	
	/**
	 * Internal flag for checking to see if we need to refresh
	 * the tilemap display to show or hide the bounding boxes.
	 */
	private var _lastVisualDebug:Bool;
	#end
	
	/**
	 * Internal, used to sort of insert blank tiles in front of the tiles in the provided graphic.
	 */
	private var _startingIndex:Int;
	
	#if !flash
	/**
	 * Rendering helper, minimize new object instantiation on repetitive methods. Used only in cpp
	 */
	private var _helperPoint:Point;
	/**
	 * Internal representation of rectangles (actually id of rectangle in tileSheet), one for each tile in the entire tilemap, used to speed up drawing.
	 */
	private var _rectIDs:Array<Int>;
	#end
	
	private var _repeatX:Int = 0;
	private var _repeatY:Int = 0;
	
	/**
	 * The tilemap constructor just initializes some basic variables.
	 */
	public function new()
	{
		super();
		
		auto = OFF;
		widthInTiles = 0;
		heightInTiles = 0;
		totalTiles = 0;
		_buffers = new Array<FlxTilemapBuffer>();
		_flashPoint = new Point();
		_flashRect = null;
		_data = null;
		_tileWidth = 0;
		_tileHeight = 0;
		
		#if flash
		_rects = null;
		#if !FLX_NO_DEBUG
		_debugRect = null;
		#end
		#else
		_rectIDs = null;
		#end
		_tiles = null;
		_tileObjects = null;
		immovable = true;
		moves = false;
		cameras = null;
		#if !FLX_NO_DEBUG
		#if flash
		_debugTileNotSolid = null;
		_debugTilePartial = null;
		_debugTileSolid = null;
		#end
		_lastVisualDebug = FlxG.debugger.visualDebug;
		#end
		
		_startingIndex = 0;
		
		#if !flash
		_helperPoint = new Point();
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_flashPoint = null;
		_flashRect = null;
		_tiles = null;
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
		
		_data = null;
		
		#if flash
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

		super.destroy();
	}
	
	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param	MapData      	A string of comma and line-return delineated indices indicating what order the tiles should go in, or an <code>Array of Int</code>. YOU MUST SET <code>widthInTiles</code> and <code>heightInTyles</code> manually BEFORE CALLING <code>loadMap</code> if you pass an Array!
	 * @param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param	TileWidth		The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param	TileHeight		The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param	AutoTile		Whether to load the map using an automatic tile placement algorithm.  Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param	StartingIndex	Used to sort of insert empty tiles in front of the provided graphic.  Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param	DrawIndex		Initializes all tile objects equal to and after this index as visible. Default value is 1.  Ignored if AutoTile is set.
	 * @param	CollideIndex	Initializes all tile objects equal to and after this index as allowCollisions = ANY.  Default value is 1.  Ignored if AutoTile is set.  Can override and customize per-tile-type collision behavior using <code>setTileProperties()</code>.	
	 * @param 	RepeatX						
	 * @param 	RepeatY
	 * @return	A pointer this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMap(MapData:Dynamic, TileGraphic:Dynamic, TileWidth:Int = 0, TileHeight:Int = 0, AutoTile:Int = 0, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1, RepeatX:Int = 1, RepeatY:Int = 1):FlxTilemap
	{
		auto = AutoTile;
		_startingIndex = (StartingIndex <= 0) ? 0 : StartingIndex;
		
		// Populate data if MapData is a CSV string
		if (Std.is(MapData, String))
		{
			// Figure out the map dimensions based on the data string
			_data = new Array<Int>();
			var columns:Array<String>;
			var rows:Array<String> = MapData.split("\n");
			heightInTiles = rows.length;
			widthInTiles = 0;
			var row:Int = 0;
			var column:Int;
			
			while (row < heightInTiles)
			{
				columns = rows[row++].split(",");
				
				if (columns.length <= 1)
				{
					heightInTiles = heightInTiles - 1;
					continue;
				}
				if (widthInTiles == 0)
				{
					widthInTiles = columns.length;
				}
				column = 0;
				
				while (column < widthInTiles)
				{
					_data.push(Std.parseInt(columns[column++]));
				}
			}
		}
		// Data is already set up as an Array<Int>
		// DON'T FORGET TO SET 'widthInTiles' and 'heightInTyles' manually BEFORE CALLING loadMap() if you pass an Array<Int>!
		else if (Std.is(MapData, Array))
		{
			_data = MapData;
		}
		else
		{
			throw "Unexpected MapData format '" + Type.typeof(MapData) + "' passed into loadMap. Map data must be CSV string or Array<Int>.";
		}
		
		// Pre-process the map data if it's auto-tiled
		var i:Int;
		totalTiles = _data.length;
		
		if (auto > OFF)
		{
			_startingIndex = 1;
			DrawIndex = 1;
			CollideIndex = 1;
			i = 0;
			
			while (i < totalTiles)
			{
				autoTile(i++);
			}
		}
		
		// Figure out the size of the tiles
		_tiles = FlxG.bitmap.add(TileGraphic);
		_tileWidth = TileWidth;
		
		if (_tileWidth <= 0)
		{
			_tileWidth = _tiles.height;
		}
		
		_tileHeight = TileHeight;
		
		if (_tileHeight <= 0)
		{
			_tileHeight = _tileWidth;
		}
		
		_repeatX = (RepeatX >= 0 ) ? RepeatX : 0;
		_repeatY = (RepeatY >= 0) ? RepeatY : 0;
		
		#if !flash
		_tiles = FlxG.bitmap.addTilemap(TileGraphic, false, false, null, _tileWidth, _tileHeight, _repeatX, _repeatY);
		_bitmapDataKey = FlxG.bitmap._lastBitmapDataKey;
		#end
		
		// Create some tile objects that we'll use for overlap checks (one for each tile)
		_tileObjects = new Array<FlxTile>();
		
		#if flash
		var length:Int = Std.int(_tiles.width / _tileWidth * _tiles.height / _tileHeight);
		#else
		var length:Int = Std.int(_tiles.width / (_tileWidth + (_repeatX + 1)) * _tiles.height / (_tileHeight + (_repeatY + 1)));
		#end
		
		length += _startingIndex;
		
		for (i in 0...length)
		{
			_tileObjects[i] = new FlxTile(this, i, _tileWidth, _tileHeight, (i >= DrawIndex), (i >= CollideIndex) ? allowCollisions : FlxObject.NONE);
		}
		
		updateAtlasInfo();
		
		// Create debug tiles for rendering bounding boxes on demand
		#if (flash && !FLX_NO_DEBUG)
		_debugTileNotSolid = makeDebugTile(FlxColor.BLUE);
		_debugTilePartial = makeDebugTile(FlxColor.PINK);
		_debugTileSolid = makeDebugTile(FlxColor.GREEN);
		#end
		
		// Then go through and create the actual map
		width = widthInTiles * _tileWidth;
		height = heightInTiles * _tileHeight;
		
		#if flash
		#if !FLX_NO_DEBUG
		_debugRect = new Rectangle(0, 0, _tileWidth, _tileHeight);
		#end
		
		_rects = new Array<Rectangle>();
		FlxArray.setLength(_rects, totalTiles);
		i = 0;
		
		while (i < totalTiles)
		{
			updateTile(i++);
		}
		#end
		
		return this;
	}
	
	/**
	 * Internal function to clean up the map loading code.
	 * Just generates a wireframe box the size of a tile with the specified color.
	 */
	#if (flash && !FLX_NO_DEBUG)
	private function makeDebugTile(Color:UInt):BitmapData
	{
		var debugTile:BitmapData;
		debugTile = new BitmapData(_tileWidth, _tileHeight, true, 0);

		var gfx:Graphics = FlxG.flashGfx;
		gfx.clear();
		gfx.moveTo(0, 0);
		gfx.lineStyle(1, Color, 0.5);
		gfx.lineTo(_tileWidth - 1, 0);
		gfx.lineTo(_tileWidth - 1, _tileHeight - 1);
		gfx.lineTo(0, _tileHeight - 1);
		gfx.lineTo(0, 0);
		
		debugTile.draw(FlxG.flashGfxSprite);
		
		return debugTile;
	}
	#end
	
	#if !FLX_NO_DEBUG
	/**
	 * Main logic loop for tilemap is pretty simple,
	 * just checks to see if visual debug got turned on.
	 * If it did, the tilemap is flagged as dirty so it
	 * will be redrawn with debug info on the next draw call.
	 */
	override public function update():Void
	{
		if (_lastVisualDebug != FlxG.debugger.visualDebug)
		{
			_lastVisualDebug = FlxG.debugger.visualDebug;
			setDirty();
		}
		
		super.update();
	}
	#end

	/**
	 * Internal function that actually renders the tilemap to the tilemap buffer.  Called by draw().
	 * @param	Buffer		The <code>FlxTilemapBuffer</code> you are rendering to.
	 * @param	Camera		The related <code>FlxCamera</code>, mainly for scroll values.
	 */
	private function drawTilemap(Buffer:FlxTilemapBuffer, Camera:FlxCamera):Void
	{
		#if flash
		Buffer.fill();
		#else
		_helperPoint.x = x - Camera.scroll.x * scrollFactor.x; //copied from getScreenXY()
		_helperPoint.y = y - Camera.scroll.y * scrollFactor.y;
		
		var tileID:Int;
		var drawX:Float;
		var drawY:Float;
		
		// TODO: maybe optimize this a liitle bit (get last drawStack item's colored value for example)
		#if !js
		var drawItem:DrawStackItem = Camera.getDrawStackItem(_atlas, false, 0);
		#else
		var drawItem:DrawStackItem = Camera.getDrawStackItem(_atlas, false);
		#end
		var currDrawData:Array<Float> = drawItem.drawData;
		var currIndex:Int = drawItem.position;
		#end
		
		// Copy tile images into the tile buffer
		_point.x = (Camera.scroll.x * scrollFactor.x) - x; //modified from getScreenXY()
		_point.y = (Camera.scroll.y * scrollFactor.y) - y;
		var screenXInTiles:Int = Math.floor(_point.x / _tileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _tileHeight);
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
				#if flash
				_flashRect = _rects[columnIndex];
				
				if (_flashRect != null)
				{
					Buffer.pixels.copyPixels(_tiles, _flashRect, _flashPoint, null, null, true);
					
					#if !FLX_NO_DEBUG
					if (FlxG.debugger.visualDebug && !ignoreDrawDebug) 
					{
						tile = _tileObjects[_data[columnIndex]];
						
						if(tile != null)
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
					drawX = _helperPoint.x + (columnIndex % widthInTiles) * _tileWidth;
					drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * _tileHeight;
					
					#if !js
					currDrawData[currIndex++] = drawX;
					currDrawData[currIndex++] = drawY;
					#else
					currDrawData[currIndex++] = Math.floor(drawX);
					currDrawData[currIndex++] = Math.floor(drawY);
					#end
					currDrawData[currIndex++] = tileID;
					
					// Tilemap tearing hack
					currDrawData[currIndex++] = tileScaleHack; 
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					// Tilemap tearing hack
					currDrawData[currIndex++] = tileScaleHack; 
					
					#if !js
					// Alpha
					currDrawData[currIndex++] = 1.0; 
					#end
				}
				#end
				
				_flashPoint.x += _tileWidth;
				column++;
				columnIndex++;
			}
			
			rowIndex += widthInTiles;
			_flashPoint.y += _tileHeight;
			row++;
		}
		
		#if !flash
		drawItem.position = currIndex;
		#end
		
		Buffer.x = screenXInTiles * _tileWidth;
		Buffer.y = screenYInTiles * _tileHeight;
	}
	
#if !FLX_NO_DEBUG
	#if flash
	override public function drawDebug():Void {  }
	#else
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
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
		
		if (buffer == null)	return;
		
		#if !js
		// Copied from getScreenXY()
		_helperPoint.x = Math.floor((x - Math.floor(Camera.scroll.x) * scrollFactor.x) * 5) / 5 + 0.1;
		_helperPoint.y = Math.floor((y - Math.floor(Camera.scroll.y) * scrollFactor.y) * 5) / 5 + 0.1;
		#else
		// Copied from getScreenXY()
		_helperPoint.x = x - Camera.scroll.x * scrollFactor.x; 
		_helperPoint.y = y - Camera.scroll.y * scrollFactor.y;
		#end
		
		var tileID:Int;
		var debugColor:Int;
		var drawX:Float;
		var drawY:Float;
	
		// Copy tile images into the tile buffer
		// Modified from getScreenXY()
		_point.x = (Camera.scroll.x * scrollFactor.x) - x; 
		_point.y = (Camera.scroll.y * scrollFactor.y) - y;
		var screenXInTiles:Int = Math.floor(_point.x / _tileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _tileHeight);
		var screenRows:Int = buffer.rows;
		var screenColumns:Int = buffer.columns;
		
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
					drawX = _helperPoint.x + (columnIndex % widthInTiles) * _tileWidth;
					drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * _tileHeight;
					
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
						var gfx:Graphics = Camera._debugLayer.graphics;
						gfx.lineStyle(1, debugColor, 0.5);
						gfx.drawRect(drawX, drawY, _tileWidth, _tileHeight);
					}
				}
				
				_flashPoint.x += _tileWidth;
				column++;
				columnIndex++;
			}
			
			rowIndex += widthInTiles;
			_flashPoint.y += _tileHeight;
			row++;
		}
	}
	#end
#end
	
	/**
	 * Draws the tilemap buffers to the cameras and handles flickering.
	 */
	override public function draw():Void
	{
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			
			if (_flicker)
			{
				return;
			}
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		
		var camera:FlxCamera;
		var buffer:FlxTilemapBuffer;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		while(i < l)
		{
			camera = cameras[i];
			
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			if (_buffers[i] == null)
			{
				_buffers[i] = new FlxTilemapBuffer(_tileWidth, _tileHeight, widthInTiles, heightInTiles, camera);
				_buffers[i].forceComplexRender = forceComplexRender;
			}
			
			buffer = _buffers[i++];
			
			#if flash
			if (!buffer.dirty)
			{
				// Copied from getScreenXY()
				_point.x = x - (camera.scroll.x * scrollFactor.x) + buffer.x; 
				_point.y = y - (camera.scroll.y * scrollFactor.y) + buffer.y;
				buffer.dirty = (_point.x > 0) || (_point.y > 0) || (_point.x + buffer.width < camera.width) || (_point.y + buffer.height < camera.height);
			}
			
			if (buffer.dirty)
			{
				drawTilemap(buffer, camera);
				buffer.dirty = false;
			}
			
			// Copied from getScreenXY()
			_flashPoint.x = x - (camera.scroll.x * scrollFactor.x) + buffer.x; 
			_flashPoint.y = y - (camera.scroll.y * scrollFactor.y) + buffer.y;
			buffer.draw(camera, _flashPoint);
			
			#else
			drawTilemap(buffer, camera);
			#end
			
			FlxBasic._VISIBLECOUNT++;
		}
	}
	
	/**
	 * Fetches the tilemap data array.
	 * 
	 * @param	Simple		If true, returns the data as copy, as a series of 1s and 0s (useful for auto-tiling stuff). Default value is false, meaning it will return the actual data array (NOT a copy).
	 * @return	An array the size of the tilemap full of integers indicating tile placement.
	 */
	public function getData(Simple:Bool = false):Array<Int>
	{
		if (!Simple)
		{
			return _data;
		}
		
		var i:Int = 0;
		var l:Int = _data.length;
		var data:Array<Int> = new Array(/*l*/);
		FlxArray.setLength(data, l);
		
		while(i < l)
		{
			data[i] = (_tileObjects[_data[i]].allowCollisions > 0) ? 1 : 0;
			i++;
		}
		
		return data;
	}
	
	/**
	 * Set the dirty flag on all the tilemap buffers.
	 * Basically forces a reset of the drawn tilemaps, even if it wasn'tile necessary.
	 * 
	 * @param	Dirty		Whether to flag the tilemap buffers as dirty or not.
	 */
	public function setDirty(Dirty:Bool = true):Void
	{
		var i:Int = 0;
		var l:Int = _buffers.length;
		
		while (i < l)
		{
			_buffers[i++].dirty = Dirty;
		}
	}
	
	/**
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 * 
	 * @param	Start		The start point in world coordinates.
	 * @param	End			The end point in world coordinates.
	 * @param	Simplify	Whether to run a basic simplification algorithm over the path data, removing extra points that are on the same line.  Default value is true.
	 * @param	RaySimplify	Whether to run an extra raycasting simplification algorithm over the remaining path data.  This can result in some close corners being cut, and should be used with care if at all (yet).  Default value is false.
	 * @param   WideDiagonal   Whether to require an additional tile to make diagonal movement. Default value is true;
	 * @return	A <code>FlxPath</code> from the start to the end.  If no path could be found, then a null reference is returned.
	 */
	public function findPath(Start:FlxPoint, End:FlxPoint, Simplify:Bool = true, RaySimplify:Bool = false, WideDiagonal:Bool = true):FlxPath
	{
		// Figure out what tile we are starting and ending on.
		var startIndex:Int = Std.int((Start.y - y) / _tileHeight) * widthInTiles + Std.int((Start.x - x) / _tileWidth);
		var endIndex:Int = Std.int((End.y - y) / _tileHeight) * widthInTiles + Std.int((End.x - x) / _tileWidth);

		// Check that the start and end are clear.
		if ((_tileObjects[_data[startIndex]].allowCollisions > 0) || (_tileObjects[_data[endIndex]].allowCollisions > 0))
		{
			return null;
		}
		
		// Figure out how far each of the tiles is from the starting tile
		var distances:Array<Int> = computePathDistance(startIndex, endIndex, WideDiagonal);
		
		if (distances == null)
		{
			return null;
		}

		// Then count backward to find the shortest path.
		var points:Array<FlxPoint> = new Array<FlxPoint>();
		walkPath(distances, endIndex, points);
		
		// Reset the start and end points to be exact
		var node:FlxPoint;
		node = points[points.length-1];
		node.x = Start.x;
		node.y = Start.y;
		node = points[0];
		node.x = End.x;
		node.y = End.y;

		// Some simple path cleanup options
		if (Simplify)
		{
			simplifyPath(points);
		}
		if (RaySimplify)
		{
			raySimplifyPath(points);
		}
		
		// Finally load the remaining points into a new path object and return it
		var path:FlxPath = new FlxPath();
		var i:Int = points.length - 1;
		
		while(i >= 0)
		{
			node = points[i--];
			
			if (node != null)
			{
				path.addPoint(node,true);
			}
		}
		
		return path;
	}
	
	/**
	 * Pathfinding helper function, strips out extra points on the same line.
	 * 
	 * @param	Points		An array of <code>FlxPoint</code> nodes.
	 */
	private function simplifyPath(Points:Array<FlxPoint>):Void
	{
		var deltaPrevious:Float;
		var deltaNext:Float;
		var last:FlxPoint = Points[0];
		var node:FlxPoint;
		var i:Int = 1;
		var l:Int = Points.length - 1;
		
		while(i < l)
		{
			node = Points[i];
			deltaPrevious = (node.x - last.x)/(node.y - last.y);
			deltaNext = (node.x - Points[i + 1].x) / (node.y - Points[i + 1].y);
			
			if ((last.x == Points[i + 1].x) || (last.y == Points[i + 1].y) || (deltaPrevious == deltaNext))
			{
				Points[i] = null;
			}
			else
			{
				last = node;
			}
			
			i++;
		}
	}
	
	/**
	 * Pathfinding helper function, strips out even more points by raycasting from one point to the next and dropping unnecessary points.
	 * 
	 * @param	Points		An array of <code>FlxPoint</code> nodes.
	 */
	private function raySimplifyPath(Points:Array<FlxPoint>):Void
	{
		var source:FlxPoint = Points[0];
		var lastIndex:Int = -1;
		var node:FlxPoint;
		var i:Int = 1;
		var l:Int = Points.length;
		
		while(i < l)
		{
			node = Points[i++];
			
			if (node == null)
			{
				continue;
			}
			
			if (ray(source,node,_point))	
			{
				if (lastIndex >= 0)
				{
					Points[lastIndex] = null;
				}
			}
			else
			{
				source = Points[lastIndex];
			}
			
			lastIndex = i - 1;
		}
	}
	
	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic! It's pretty brute.
	 * 
	 * @param	StartIndex	The starting tile's map index.
	 * @param	EndIndex	The ending tile's map index.
	 * @param   WideDiagonal Whether to require an additional tile to make diagonal movement. Default value is true.
	 * @return	A Flash <code>Array</code> of <code>FlxPoint</code> nodes.  If the end tile could not be found, then a null <code>Array</code> is returned instead.
	 */
	private function computePathDistance(StartIndex:Int, EndIndex:Int, WideDiagonal:Bool):Array<Int>
	{
		// Create a distance-based representation of the tilemap.
		// All walls are flagged as -2, all open areas as -1.
		var mapSize:Int = widthInTiles * heightInTiles;
		var distances:Array<Int> = new Array<Int>(/*mapSize*/);
		FlxArray.setLength(distances, mapSize);
		var i:Int = 0;
		
		while(i < mapSize)
		{
			if (_tileObjects[_data[i]].allowCollisions != FlxObject.NONE)
			{
				distances[i] = -2;
			}
			else
			{
				distances[i] = -1;
			}
			i++;
		}
		
		distances[StartIndex] = 0;
		var distance:Int = 1;
		var neighbors:Array<Int> = [StartIndex];
		var current:Array<Int>;
		var currentIndex:Int;
		var left:Bool;
		var right:Bool;
		var up:Bool;
		var down:Bool;
		var currentLength:Int;
		var foundEnd:Bool = false;
		
		while(neighbors.length > 0)
		{
			current = neighbors;
			neighbors = new Array<Int>();
			
			i = 0;
			currentLength = current.length;
			while(i < currentLength)
			{
				currentIndex = current[i++];
				
				if(currentIndex == Std.int(EndIndex))
				{
					foundEnd = true;
					// Neighbors.length = 0;
					neighbors = [];
					break;
				}
				
				// Basic map bounds
				left = currentIndex % widthInTiles > 0;
				right = currentIndex % widthInTiles < widthInTiles - 1;
				up = currentIndex / widthInTiles > 0;
				down = currentIndex / widthInTiles < heightInTiles - 1;
				
				var index:Int;
				
				if (up)
				{
					index = currentIndex - widthInTiles;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (right)
				{
					index = currentIndex + 1;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (down)
				{
					index = currentIndex + widthInTiles;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (left)
				{
					index = currentIndex - 1;
					
					if (distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (up && right)
				{
					index = currentIndex - widthInTiles + 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex-widthInTiles] >= -1) && (distances[currentIndex+1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (right && down)
				{
					index = currentIndex + widthInTiles + 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex+widthInTiles] >= -1) && (distances[currentIndex+1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (left && down)
				{
					index = currentIndex + widthInTiles - 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex+widthInTiles] >= -1) && (distances[currentIndex-1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if (up && left)
				{
					index = currentIndex - widthInTiles - 1;
					
					if (WideDiagonal && (distances[index] == -1) && (distances[currentIndex-widthInTiles] >= -1) && (distances[currentIndex-1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
					else if (!WideDiagonal && (distances[index] == -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
			}
			
			distance++;
		}
		if (!foundEnd)
		{
			distances = null;
		}
		
		return distances;
	}
	
	/**
	 * Pathfinding helper function, recursively walks the grid and finds a shortest path back to the start.
	 * 
	 * @param	Data	A Flash <code>Array</code> of distance information.
	 * @param	Start	The tile we're on in our walk backward.
	 * @param	Points	A Flash <code>Array</code> of <code>FlxPoint</code> nodes composing the path from the start to the end, compiled in reverse order.
	 */
	private function walkPath(Data:Array<Int>, Start:Int, Points:Array<FlxPoint>):Void
	{
		Points.push(new FlxPoint(x + Math.floor(Start % widthInTiles) * _tileWidth + _tileWidth * 0.5, y + Math.floor(Start / widthInTiles) * _tileHeight + _tileHeight * 0.5));
		
		if (Data[Start] == 0)
		{
			return;
		}
		
		// Basic map bounds
		var left:Bool = (Start % widthInTiles) > 0;
		var right:Bool = (Start % widthInTiles) < (widthInTiles - 1);
		var up:Bool = (Start / widthInTiles) > 0;
		var down:Bool = (Start / widthInTiles) < (heightInTiles - 1);
		
		var current:Int = Data[Start];
		var i:Int;
		
		if (up)
		{
			i = Start - widthInTiles;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (right)
		{
			i = Start + 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (down)
		{
			i = Start + widthInTiles;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (left)
		{
			i = Start - 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (up && right)
		{
			i = Start - widthInTiles + 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (right && down)
		{
			i = Start + widthInTiles + 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (left && down)
		{
			i = Start + widthInTiles - 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		if (up && left)
		{
			i = Start - widthInTiles - 1;
			
			if (i >= 0 && (Data[i] >= 0) && (Data[i] < current))
			{
				return walkPath(Data, i, Points);
			}
		}
		
		return;
	}
	
	/**
	 * Checks to see if some <code>FlxObject</code> overlaps this <code>FlxObject</code> object in world space.
	 * If the group has a LOT of things in it, it might be faster to use <code>FlxG.overlaps()</code>.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * 
	 * @param	Object			The object being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	override public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (Std.is(ObjectOrGroup, FlxTypedGroup))
		{
			var results:Bool = false;
			var basic:FlxBasic;
			var i:Int = 0;
			var grp:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = grp.members;
			
			while(i < grp.length)
			{
				basic = members[i++];
				
				if ((basic != null) && basic.exists)
				{
					if (Std.is(basic, FlxObject))
					{
						if (overlapsWithCallback(cast(basic, FlxObject)))
						{
							results = true;
						}
					}
					else
					{
						if (overlaps(basic, InScreenSpace, Camera))
						{
							results = true;
						}
					}
				}
			}
			
			return results;
		}
		else if (Std.is(ObjectOrGroup, FlxObject))
		{
			return overlapsWithCallback(cast(ObjectOrGroup, FlxObject));
		}
		
		return false;
	}
	
	/**
	 * Checks to see if this <code>FlxObject</code> were located at the given position, would it overlap the <code>FlxObject</code> or <code>FlxGroup</code>?
	 * This is distinct from overlapsPoint(), which just checks that point, rather than taking the object's size into account.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks! 
	 * 
	 * @param	X				The X position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	Y				The Y position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	override public function overlapsAt(X:Float, Y:Float, ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (Std.is(ObjectOrGroup, FlxTypedGroup))
		{
			var results:Bool = false;
			var basic:FlxBasic;
			var i:Int = 0;
			var grp:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = grp.members;
			
			while(i < grp.length)
			{
				basic = members[i++];
				
				if ((basic != null) && basic.exists)
				{
					if (Std.is(basic, FlxObject))
					{
						_point.x = X;
						_point.y = Y;
						
						if (overlapsWithCallback(cast(basic, FlxObject), null, false, _point))
						{
							results = true;
						}
					}
					else
					{
						if (overlapsAt(X, Y, basic, InScreenSpace, Camera))
						{
							results = true;
						}
					}
				}
			}
			
			return results;
		}
		else if(Std.is(ObjectOrGroup, FlxObject))
		{
			_point.x = X;
			_point.y = Y;
			
			return overlapsWithCallback(cast(ObjectOrGroup, FlxObject), null, false, _point);
		}
		
		return false;
	}
	
	/**
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 * 
	 * @param	Object				The <code>FlxObject</code> you are checking for overlaps against.
	 * @param	Callback			An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a FlxTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param	FlipCallbackParams	Used to preserve A-B list ordering from FlxObject.separate() - returns the FlxTile object as the second parameter instead.
	 * @param	Position			Optional, specify a custom position for the tilemap (useful for overlapsAt()-type funcitonality).
	 * @return	Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	public function overlapsWithCallback(Object:FlxObject, ?Callback:FlxObject->FlxObject->Bool, FlipCallbackParams:Bool = false, ?Position:FlxPoint):Bool
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
		var selectionX:Int = Math.floor((Object.x - X) / _tileWidth);
		var selectionY:Int = Math.floor((Object.y - Y) / _tileHeight);
		var selectionWidth:Int = selectionX + (Math.ceil(Object.width / _tileWidth)) + 1;
		var selectionHeight:Int = selectionY + Math.ceil(Object.height / _tileHeight) + 1;
		
		// Then bound these coordinates by the map edges
		if (selectionX < 0)
		{
			selectionX = 0;
		}
		if (selectionY < 0)
		{
			selectionY = 0;
		}
		if (selectionWidth > widthInTiles)
		{
			selectionWidth = widthInTiles;
		}
		if (selectionHeight > heightInTiles)
		{
			selectionHeight = heightInTiles;
		}
		
		// Then loop through this selection of tiles and call FlxObject.separate() accordingly
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
				overlapFound = false;
				var dataIndex:Int = _data[rowStart + column];
				
				if (dataIndex < 0)
				{
					column++;
					continue;
				}
				
				tile = _tileObjects[dataIndex];
				
				if (tile.allowCollisions != FlxObject.NONE)
				{
					tile.x = X + column * _tileWidth;
					tile.y = Y + row * _tileHeight;
					tile.last.x = tile.x - deltaX;
					tile.last.y = tile.y - deltaY;
					
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
					else
					{
						overlapFound = (Object.x + Object.width > tile.x) && (Object.x < tile.x + tile.width) && (Object.y + Object.height > tile.y) && (Object.y < tile.y + tile.height);
					}
					if (overlapFound)
					{
						if ((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
						{
							tile.mapIndex = rowStart + column;
							tile.callbackFunction(tile, Object);
						}
						
						results = true;
					}
				}
				else if ((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
				{
					tile.mapIndex = rowStart + column;
					tile.callbackFunction(tile, Object);
				}
				
				column++;
			}
			
			rowStart += widthInTiles;
			row++;
		}
		
		return results;
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this <code>FlxObject</code> object.
	 * 
	 * @param	WorldPoint		The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	override public function overlapsPoint(WorldPoint:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (!InScreenSpace)
		{
			return _tileObjects[_data[Math.floor(Math.floor((WorldPoint.y - y) / _tileHeight) * widthInTiles + (WorldPoint.x - x) / _tileWidth)]].allowCollisions > 0;
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		WorldPoint.x = WorldPoint.x - Camera.scroll.x;
		WorldPoint.y = WorldPoint.y - Camera.scroll.y;
		getScreenXY(_point, Camera);
		
		return _tileObjects[_data[Std.int(Std.int((WorldPoint.y - WorldPoint.y) / _tileHeight) * widthInTiles + (WorldPoint.x - WorldPoint.x) / _tileWidth)]].allowCollisions > 0;
	}
	
	/**
	 * Check the value of a particular tile.
	 * 
	 * @param	X		The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y		The Y coordinate of the tile (in tiles, not pixels).
	 * @return	A uint containing the value of the tile at this spot in the array.
	 */
	public function getTile(X:Int, Y:Int):Int
	{
		return _data[Y * widthInTiles + X];
	}
	
	/**
	 * Get the value of a tile in the tilemap by index.
	 * 
	 * @param	Index	The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * @return	A uint containing the value of the tile at this spot in the array.
	 */
	public function getTileByIndex(Index:Int):Int
	{
		return _data[Index];
	}
	
	/**
	 * Returns a new Flash <code>Array</code> full of every map index of the requested tile type.
	 * 
	 * @param	Index	The requested tile type.
	 * @return	An <code>Array</code> with a list of all map indices of that tile type.
	 */
	public function getTileInstances(Index:Int):Array<Int>
	{
		var array:Array<Int> = null;
		var i:Int = 0;
		var l:Int = widthInTiles * heightInTiles;
		
		while (i < l)
		{
			if (_data[i] == Index)
			{
				if (array == null)
				{
					array = [];
				}
				array.push(i);
			}
			
			i++;
		}
		
		return array;
	}
	
	/**
	 * Returns a new Flash <code>Array</code> full of every coordinate of the requested tile type.
	 * 
	 * @param	Index		The requested tile type.
	 * @param	Midpoint	Whether to return the coordinates of the tile midpoint, or upper left corner. Default is true, return midpoint.
	 * @return	An <code>Array</code> with a list of all the coordinates of that tile type.
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
				point = new FlxPoint(x + Std.int(i % widthInTiles) * _tileWidth, y + Std.int(i / widthInTiles) * _tileHeight);
				
				if (Midpoint)
				{
					point.x += _tileWidth * 0.5;
					point.y += _tileHeight * 0.5;
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
	 * Change the data and graphic of a tile in the tilemap.
	 * 
	 * @param	X				The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y				The Y coordinate of the tile (in tiles, not pixels).
	 * @param	Tile			The new integer data you wish to inject.
	 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
	 * @return	Whether or not the tile was actually changed.
	 */ 
	public function setTile(X:Int, Y:Int, Tile:Int, UpdateGraphics:Bool = true):Bool
	{
		if ((X >= widthInTiles) || (Y >= heightInTiles))
		{
			return false;
		}
		
		return setTileByIndex(Y * widthInTiles + X, Tile, UpdateGraphics);
	}
	
	/**
	 * Change the data and graphic of a tile in the tilemap.
	 * 
	 * @param	Index			The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * @param	Tile			The new integer data you wish to inject.
	 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
	 * @return	Whether or not the tile was actually changed.
	 */
	public function setTileByIndex(Index:Int, Tile:Int, UpdateGraphics:Bool = true):Bool
	{
		if (Index >= _data.length)
		{
			return false;
		}
		
		var ok:Bool = true;
		_data[Index] = Tile;
		
		if (!UpdateGraphics)
		{
			return ok;
		}
		
		setDirty();
		
		if (auto == OFF)
		{
			updateTile(Index);
			return ok;
		}
		
		// If this map is autotiled and it changes, locally update the arrangement
		var i:Int;
		var row:Int = Std.int(Index / widthInTiles) - 1;
		var rowLength:Int = row + 3;
		var column:Int = Index % widthInTiles - 1;
		var columnHeight:Int = column + 3;
		
		while (row < rowLength)
		{
			column = columnHeight - 3;
			
			while (column < columnHeight)
			{
				if ((row >= 0) && (row < heightInTiles) && (column >= 0) && (column < widthInTiles))
				{
					i = row * widthInTiles + column;
					autoTile(i);
					updateTile(i);
				}
				column++;
			}
			
			row++;
		}
		
		return ok;
	}
	
	/**
	 * Adjust collision settings and/or bind a callback function to a range of tiles.
	 * This callback function, if present, is triggered by calls to overlap() or overlapsWithCallback().
	 * 
	 * @param	Tile				The tile or tiles you want to adjust.
	 * @param	AllowCollisions		Modify the tile or tiles to only allow collisions from certain directions, use FlxObject constants NONE, ANY, LEFT, RIGHT, etc.  Default is "ANY".
	 * @param	Callback			The function to trigger, e.g. <code>lavaCallback(Tile:FlxTile, Object:FlxObject)</code>.
	 * @param	CallbackFilter		If you only want the callback to go off for certain classes or objects based on a certain class, set that class here.
	 * @param	Range				If you want this callback to work for a bunch of different tiles, input the range here.  Default value is 1.
	 */
	public function setTileProperties(Tile:Int, AllowCollisions:Int = 0x1111, ?Callback:FlxObject->FlxObject->Void, ?CallbackFilter:Class<Dynamic>, Range:Int = 1):Void
	{
		if (Range <= 0)
		{
			Range = 1;
		}
		
		var tile:FlxTile;
		var i:Int = Tile;
		var l:Int = Tile + Range;
		
		while (i < l)
		{
			tile = _tileObjects[i++];
			tile.allowCollisions = AllowCollisions;
			tile.callbackFunction = Callback;
			tile.filter = CallbackFilter;
		}
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
		
		Camera.setBounds(x + Border * _tileWidth, y + Border * _tileHeight, width - Border * _tileWidth * 2, height - Border * _tileHeight * 2, UpdateWorld);
	}
	
	/**
	 * Get the world coordinates and size of the entire tilemap as a <code>FlxRect</code>.
	 * 
	 * @param	Bounds		Optional, pass in a pre-existing <code>FlxRect</code> to prevent instantiation of a new object.
	 * @return	A <code>FlxRect</code> containing the world coordinates and size of the entire tilemap.
	 */
	public function getBounds(?Bounds:FlxRect):FlxRect
	{
		if (Bounds == null)
		{
			Bounds = new FlxRect();
		}
		
		return Bounds.make(x, y, width, height);
	}
	
	/**
	 * Shoots a ray from the start point to the end point.
	 * If/when it passes through a tile, it stores that point and returns false.
	 * 
	 * @param	Start		The world coordinates of the start of the ray.
	 * @param	End			The world coordinates of the end of the ray.
	 * @param	Result		A <code>Point</code> object containing the first wall impact.
	 * @param	Resolution	Defaults to 1, meaning check every tile or so.  Higher means more checks!
	 * @return	Returns true if the ray made it from Start to End without hitting anything.  Returns false and fills Result if a tile was hit.
	 */
	public function ray(Start:FlxPoint, End:FlxPoint, ?Result:FlxPoint, Resolution:Float = 1):Bool
	{
		var step:Float = _tileWidth;
		
		if (_tileHeight < _tileWidth)
		{
			step = _tileHeight;
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
		
		while (i < steps)
		{
			curX += stepX;
			curY += stepY;
			
			if ((curX < 0) || (curX > width) || (curY < 0) || (curY > height))
			{
				i++;
				continue;
			}
			
			tileX = Math.floor(curX / _tileWidth);
			tileY = Math.floor(curY / _tileHeight);
			
			if (_tileObjects[_data[tileY * widthInTiles + tileX]].allowCollisions != FlxObject.NONE)
			{
				// Some basic helper stuff
				tileX *= _tileWidth;
				tileY *= _tileHeight;
				var rx:Float = 0;
				var ry:Float = 0;
				var q:Float;
				var lx:Float = curX - stepX;
				var ly:Float = curY - stepY;
				
				// Figure out if it crosses the X boundary
				q = tileX;
				
				if (deltaX < 0)
				{
					q += _tileWidth;
				}
				
				rx = q;
				ry = ly + stepY * ((q - lx) / stepX);
				
				if ((ry > tileY) && (ry < tileY + _tileHeight))
				{
					if (Result != null)
					{
						Result.x = rx;
						Result.y = ry;
					}
					
					return false;
				}
				
				// Else, figure out if it crosses the Y boundary
				q = tileY;
				
				if (deltaY < 0)
				{
					q += _tileHeight;
				}
				
				rx = lx + stepX * ((q - ly) / stepY);
				ry = q;
				
				if ((rx > tileX) && (rx < tileX + _tileWidth))
				{
					if (Result != null)
					{
						Result.x = rx;
						Result.y = ry;
					}
					
					return false;
				}
				
				return true;
			}
			
			i++;
		}
		
		return true;
	}
	
	/**
	* Works exactly like ray() except it explicitly returns the hit result.
	* Shoots a ray from the start point to the end point.
	* If/when it passes through a tile, it returns that point.
	* If it does not, it returns null.
	* Usage:
	* var hit:FlxPoint = tilemap.rayHit(startPoint, endPoint);
	* if (hit != null) //code ;
	*
	* @param 	Start		The world coordinates of the start of the ray.
	* @param 	End 		The world coordinates of the end of the ray.
	* @param 	Resolution 	Defaults to 1, meaning check every tile or so. Higher means more checks!
	* @return Returns null if the ray made it from Start to End without hitting anything. Returns FlxPoint if a tile was hit.
	*/
	public function rayHit(Start:FlxPoint, End:FlxPoint, Resolution:Float = 1):FlxPoint
	{
		var Result:FlxPoint = null;
		var step:Float = _tileWidth;
		
		if (_tileHeight < _tileWidth)
		{
			step = _tileHeight;
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
		
		while (i < steps)
		{
			curX += stepX;
			curY += stepY;

			if ((curX < 0) || (curX > width) || (curY < 0) || (curY > height))
			{
				i++;
				continue;
			}

			tileX = Math.floor(curX / _tileWidth);
			tileY = Math.floor(curY / _tileHeight);
			
			if (_tileObjects[_data[tileY * widthInTiles + tileX]].allowCollisions != 0)
			{
				// Some basic helper stuff
				tileX *= _tileWidth;
				tileY *= _tileHeight;
				var rx:Float = 0;
				var ry:Float = 0;
				var q:Float;
				var lx:Float = curX - stepX;
				var ly:Float = curY - stepY;

				// Figure out if it crosses the X boundary
				q = tileX;
				
				if (deltaX < 0)
				{
					q += _tileWidth;
				}
				
				rx = q;
				ry = ly + stepY * ((q - lx) / stepX);
				
				if ((ry > tileY) && (ry < tileY + _tileHeight))
				{
					if (Result == null)
					{
						Result = new FlxPoint();
					}
					
					Result.x = rx;
					Result.y = ry;
					return Result;
				}

				// Else, figure out if it crosses the Y boundary
				q = tileY;
				
				if (deltaY < 0)
				{
					q += _tileHeight;
				}
				
				rx = lx + stepX * ((q - ly) / stepY);
				ry = q;
				
				if ((rx > tileX) && (rx < tileX + _tileWidth))
				{
					if (Result == null)
					{
						Result = new FlxPoint();
					}
					
					Result.x = rx;
					Result.y = ry;
					return Result;
				}
				
				return null;
			}
			
			i++;
		}
		
		return null;
	}
	
	/**
	 * Converts a one-dimensional array of tile data to a comma-separated string.
	 * 
	 * @param	Data		An array full of integer tile references.
	 * @param	Width		The number of tiles in each row.
	 * @param	Invert		Recommended only for 1-bit arrays - changes 0s to 1s and vice versa.
	 * @return	A comma-separated string containing the level data in a <code>FlxTilemap</code>-friendly format.
	 */
	static public function arrayToCSV(Data:Array<Int>, Width:Int, Invert:Bool = false):String
	{
		var row:Int = 0;
		var column:Int;
		var csv:String = "";
		var Height:Int = Std.int(Data.length / Width);
		var index:Int;
		var offset:Int = 0;
		
		while (row < Height)
		{
			column = 0;
			
			while (column < Width)
			{
				index = Data[offset];
				
				if (Invert)
				{
					if (index == 0)
					{
						index = 1;
					}
					else if (index == 1)
					{
						index = 0;
					}
				}
				
				if (column == 0)
				{
					if (row == 0)
					{
						csv += index;
					}
					else
					{
						csv += "\n" + index;
					}
				}
				else
				{
					csv += ", "+index;
				}
				
				column++;
				offset++;
			}
			
			row++;
		}
		
		return csv;
	}
	
	/**
	 * Converts a <code>BitmapData</code> object to a comma-separated string.
	 * Black pixels are flagged as 'solid' by default,
	 * non-black pixels are set as non-colliding.
	 * Black pixels must be PURE BLACK.
	 * 
	 * @param	Bitmap		A Flash <code>BitmapData</code> object, preferably black and white.
	 * @param	Invert		Load white pixels as solid instead.
	 * @param	Scale		Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @param  	ColorMap  	An array of color values (uint 0xAARRGGBB) in the order they're intended to be assigned as indices
	 * @return	A comma-separated string containing the level data in a <code>FlxTilemap</code>-friendly format.
	 */
	static public function bitmapToCSV(Bitmap:BitmapData, Invert:Bool = false, Scale:Int = 1, ?ColorMap:Array<Int>):String
	{
		if (Scale < 1) 
		{
			Scale = 1;
		}
		
		// Import and scale image if necessary
		if (Scale > 1)
		{
			var bd:BitmapData = Bitmap;
			Bitmap = new BitmapData(Bitmap.width * Scale, Bitmap.height * Scale);
			
			#if js
			var bdW:Int = bd.width;
			var bdH:Int = bd.height;
			var pCol:Int = 0;
			
			for (i in 0...bdW)
			{
				for (j in 0...bdH)
				{
					pCol = bd.getPixel(i, j);
					
					for (k in 0...Scale)
					{
						for (m in 0...Scale)
						{
							Bitmap.setPixel(i * Scale + k, j * Scale + m, pCol);
						}
					}
				}
			}
			#else
			var mtx:Matrix = new Matrix();
			mtx.scale(Scale, Scale);
			Bitmap.draw(bd, mtx);
			#end
		}
		
		// Walk image and export pixel values
		var row:Int = 0;
		var column:Int;
		var pixel:Int;
		var csv:String = "";
		var bitmapWidth:Int = Bitmap.width;
		var bitmapHeight:Int = Bitmap.height;
		
		while (row < bitmapHeight)
		{
			column = 0;
			
			while(column < bitmapWidth)
			{
				// Decide if this pixel/tile is solid (1) or not (0)
				pixel = Bitmap.getPixel(column, row);
				
				if (ColorMap != null)
				{
					pixel = FlxArray.indexOf(ColorMap, pixel);
				}
				else if ((Invert && (pixel > 0)) || (!Invert && (pixel == 0)))
				{
					pixel = 1;
				}
				else
				{
					pixel = 0;
				}
				
				// Write the result to the string
				if (column == 0)
				{
					if (row == 0)
					{
						csv += pixel;
					}
					else
					{
						csv += "\n" + pixel;
					}
				}
				else
				{
					csv += ", " + pixel;
				}
				
				column++;
			}
			
			row++;
		}
		
		return csv;
	}
	
	/**
	 * Converts a resource image file to a comma-separated string.
	 * Black pixels are flagged as 'solid' by default,
	 * non-black pixels are set as non-colliding.
	 * Black pixels must be PURE BLACK.
	 * 
	 * @param	ImageFile	An embedded graphic, preferably black and white.
	 * @param	Invert		Load white pixels as solid instead.
	 * @param	Scale		Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @return	A comma-separated string containing the level data in a <code>FlxTilemap</code>-friendly format.
	 */
	static public function imageToCSV(ImageFile:Dynamic, Invert:Bool = false, Scale:Int = 1):String
	{
		var tempBitmapData:BitmapData;
		
		if (Std.is(ImageFile, String))
		{
			tempBitmapData = FlxAssets.getBitmapData(ImageFile);
		}
		else
		{
			tempBitmapData = (Type.createInstance(ImageFile, [])).bitmapData;
		}
		
		return bitmapToCSV(tempBitmapData, Invert, Scale);
	}
	
	/**
	 * An internal function used by the binary auto-tilers.
	 * 
	 * @param	Index		The index of the tile you want to analyze.
	 */
	private function autoTile(Index:Int):Void
	{
		if (_data[Index] == 0)
		{
			return;
		}
		
		_data[Index] = 0;
		
		// UP
		if ((Index-widthInTiles < 0) || (_data[Index-widthInTiles] > 0)) 		
		{
			_data[Index] += 1;
		}
		// RIGHT
		if ((Index%widthInTiles >= widthInTiles-1) || (_data[Index+1] > 0)) 		
		{
			_data[Index] += 2;
		}
		// DOWN
		if ((Std.int(Index+widthInTiles) >= totalTiles) || (_data[Index+widthInTiles] > 0)) 
		{
			_data[Index] += 4;
		}
		// LEFT
		if ((Index%widthInTiles <= 0) || (_data[Index-1] > 0)) 					
		{
			_data[Index] += 8;
		}
		
		// The alternate algo checks for interior corners
		if ((auto == ALT) && (_data[Index] == 15))	
		{
			// BOTTOM LEFT OPEN
			if ((Index%widthInTiles > 0) && (Std.int(Index+widthInTiles) < totalTiles) && (_data[Index+widthInTiles-1] <= 0))
			{
				_data[Index] = 1;		
			}
			// TOP LEFT OPEN
			if ((Index%widthInTiles > 0) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles-1] <= 0))
			{
				_data[Index] = 2;		
			}
			// TOP RIGHT OPEN
			if ((Index%widthInTiles < widthInTiles-1) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0))
			{
				_data[Index] = 4;		
			}
			// BOTTOM RIGHT OPEN
			if ((Index%widthInTiles < widthInTiles-1) && (Std.int(Index+widthInTiles) < totalTiles) && (_data[Index+widthInTiles+1] <= 0))
			{
				_data[Index] = 8; 		
			}
		}
		
		_data[Index] += 1;
	}
	
	/**
	 * Internal function used in setTileByIndex() and the constructor to update the map.
	 * 
	 * @param	Index		The index of the tile you want to update.
	 */
	private function updateTile(Index:Int):Void
	{
		var tile:FlxTile = _tileObjects[_data[Index]];
		
		if ((tile == null) || !tile.visible)
		{
			#if flash
			_rects[Index] = null;
			#else
			_rectIDs[Index] = -1;
			#end
			
			return;
		}
		
		#if flash
		var rx:Int = (_data[Index] - _startingIndex) * _tileWidth;
		var ry:Int = 0;
		
		if (Std.int(rx) >= _tiles.width)
		{
			ry = Std.int(rx / _tiles.width) * _tileHeight;
			rx %= _tiles.width;
		}
		_rects[Index] = (new Rectangle(rx, ry, _tileWidth, _tileHeight));
		#else
		_rectIDs[Index] = _framesData.frames[_data[Index] - _startingIndex].tileID;
		#end
	}
	
	/**
	 * Use this method for creating tileSheet for FlxTilemap. Must be called after loadMap() method.
	 * If you forget to call it then you will not see this FlxTilemap on c++ target
	 */
	override public function updateFrameData():Void
	{
		#if !flash
		if (_node != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			_framesData = _node.getSpriteSheetFrames(_tileWidth, _tileHeight, new Point(0, 0), 0, 0, 0, 0, _repeatX + 1, _repeatY + 1);
			
			_rectIDs = new Array<Int>();
			FlxArray.setLength(_rectIDs, totalTiles);
			var i:Int = 0;
			
			while (i < totalTiles)
			{
				updateTile(i++);
			}
		}
		#end
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
		
		#if flash
		rect = _rects[rowIndex];
		#else
		
		var tile:FlxTile = _tileObjects[_data[rowIndex]];
		
		if ((tile == null) || !tile.visible)
		{
			// Nothing to do here: rect object should stay null.
		}
		else
		{
			var rx:Int = (_data[rowIndex] - _startingIndex) * (_tileWidth + _repeatX + 1);
			var ry:Int = 0;
			
			if(Std.int(rx) >= _tiles.width)
			{
				ry = Std.int(rx / _tiles.width) * (_tileHeight + _repeatY + 1);
				rx %= _tiles.width;
			}
			
			rect = new Rectangle(rx, ry, _tileWidth, _tileHeight);
		}
		#end
		
		var pt:Point = new Point(0, 0);
		var tileSprite:FlxSprite = new FlxSprite();
		tileSprite.makeGraphic(_tileWidth, _tileHeight, FlxColor.TRANSPARENT, true);
		tileSprite.x = X * _tileWidth + x;
		tileSprite.y = Y * _tileHeight + y;
		
		if (rect != null) 
		{
			tileSprite.pixels.copyPixels(_tiles, rect, pt);
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
	
	override private function set_forceComplexRender(Value:Bool):Bool 
	{
		var i:Int = 0;
        var l:Int;
		
        if (_buffers != null)
        {
            i = 0;
            l = _buffers.length;
			
            for (i in 0...l)
            {
                _buffers[i].forceComplexRender = Value;
            }
        }
		
		return super.set_forceComplexRender(Value);
	}
}