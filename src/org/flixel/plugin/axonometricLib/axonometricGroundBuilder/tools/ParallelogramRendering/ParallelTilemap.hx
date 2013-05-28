package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.parallelogramRendering;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;		
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxCamera;
import org.flixel.FlxPath;
import org.flixel.FlxRect;
import org.flixel.FlxG;
import org.flixel.FlxU;


/**
 * this is a normal FlxTilemap object modified to render paralelograms
 *
 * 
 * @author	Adam Atomic(original) Miguel Ángel Piedras Carrillo(Modified), Jimmy Delas (Haxe port)
 */


class ParallelTilemap extends FlxObject
{
	
	/**
	 * No auto-tiling.
	 */
	static public inline var OFF:Int = 0;
	/**
	 * Good for levels with thin walls that don'tile need Interior corner art.
	 */
	static public inline var AUTO:Int = 1;
	/**
	 * Better for levels with thick walls that look better with Interior corner art.
	 */
	static public inline var ALT:Int = 2;

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
	public var _tiles:BitmapData;

	
	/**
	 * Internal reference to the bitmap data object that stores the skewed graphics.
	 */		
	public var myParallelogram:ParallelogramGenerator;
	
	/**
	 * Internal list of buffers, one for each camera, used for drawing the tilemaps.
	 */
	private var _buffers:Array<Dynamic>;
	/**
	 * Internal representation of the actual tile data, as a large 1D array of Integers.
	 */
	private var _data:Array<Int>;
	/**
	 * Internal representation of rectangles, one for each tile in the entire tilemap, used to speed up drawing.
	 */
	private var _rects:Array<Rectangle>;
	/**
	 * Internal, the width of a single tile.
	 */
	public var _tileWidth:Int;
	/**
	 * Internal, the height of a single tile.
	 */
	public var _tileHeight:Int;

	/**
	 * Internal, the location to draw tiles, differs if there is offset present
	 */
	public var _drawlocation:FlxPoint;
	
	private var _tileObjects:Array<ParallelTile>;
	
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
	/**
	 * Internal flag for checking to see if we need to refresh
	 * the tilemap display to show or hide the bounding boxes.
	 */
	private var _lastVisualDebug:Bool;
	/**
	 * X position of the center of the tilemap ( different from x)
	 */
	public var X:Float ;
	/**
	 * Y position of the center of the tilemap ( different from y)
	 */
	public var Y:Float ;
	 
	public function new()
	{
		super();
		auto = OFF;
		widthInTiles = 0;
		heightInTiles = 0;
		totalTiles = 0;
		_buffers = new Array();
		_flashPoint = new Point();
		_flashRect = null;
		_data = null;
		_tileWidth = 0;
		_tileHeight = 0;
		_rects = null;
		_tiles = null;
		_tileObjects = null;
		myParallelogram = null;
		immovable = true;
		cameras = null;
		_debugTileNotSolid = null;
		_debugTilePartial = null;
		_debugTileSolid = null;
		_debugRect = null;
		_lastVisualDebug = FlxG.visualDebug;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_flashPoint = null;
		_flashRect = null;
		_tiles = null;
		myParallelogram.destroy();
		var i:Int = 0;
		var l:Int = _tileObjects.length;
		while(i < l)
			if (Std.is(_tileObjects[i++], ParallelTile))
				cast(_tileObjects[i - 1], ParallelTile).destroy();
		_tileObjects = null;
		i = 0;
		l = _buffers.length;
		while (i < l)
			if (Std.is(_buffers[i++], ParallelTilemapBuffer))
				cast(_buffers[i - 1], ParallelTilemapBuffer).destroy();
		_buffers = null;
		_data = null;
		_rects = null;
		_debugTileNotSolid = null;
		_debugTilePartial = null;
		_debugTileSolid = null;
		_debugRect = null;

		super.destroy();
	}
	
	
	/**
	 * Pone la localización del mapa en una posición específica
	 * 
	 * @param	x		la coordenada x del mapa
	 * @param	y		la coordenada x del mapa
	 * 
	*/
	public function setLocation(x:Float, y:Float):Void 
	{									
		this.x = x + myParallelogram.BigUpperLeft.x;			
		this.y = y + myParallelogram.BigUpperLeft.y;
		this.X = x;
		this.Y = y;
	}
	
	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param	MapData			A string of comma and line-return delineated indices indicating what order the tiles should go in.
	 * @param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param	TileWidth		The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param	TileHeight		The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param	AutoTile		Whether to load the map using an automatic tile placement algorithm.  Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param	StartingIndex	Used to sort of insert empty tiles in front of the provided graphic.  Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param	DrawIndex		Initializes all tile objects equal to and after this index as visible. Default value is 1.  Ignored if AutoTile is set.
	 * @param	CollideIndex	Initializes all tile objects equal to and after this index as allowCollisions = ANY.  Default value is 1.  Ignored if AutoTile is set.  Can override and customize per-tile-type collision behavior using <code>setTileProperties()</code>.	
	 * @param	tileoffset   	point containing isometric skewed and diamond tile info and offset, Default value is null.	
	 * 
	 * @return	A pointer this instance of ParallelTilemap, for chaining as usual :)
	 */
	public function loadMap(MapData:String, TileGraphic:Dynamic,positiveAngle:Bool=false,rotatetile:Bool= false,inverttile:Bool = false, TileWidth:Int=0, TileHeight:Int=0, AutoTile:Int=OFF, StartingIndex:Int=0, DrawIndex:Int=1, CollideIndex:Int=1,alpha:Float=0,beta:Float=0,tilemapdebug:Bool= false, showboundingboxes:Bool= false, hideTile:Bool= false,showmytiles:Bool=false):ParallelTilemap
	{
		
		auto = AutoTile;			

		//Figure out the map dimensions based on the data string
		var columns:Array<String>;
		var rows:Array<String> = MapData.split("\n");
		heightInTiles = rows.length;
		_data = new Array();
		var row:Int = 0;
		var column:Int;
		while(row < heightInTiles)
		{
			columns = rows[row++].split(",");
			if(widthInTiles == 0)
				widthInTiles = columns.length;
			column = 0;
			while(column < widthInTiles)
				_data.push(Std.parseInt(columns[column++]));					
		}
		
		if (rotatetile || inverttile || positiveAngle) {
			ModifyMapData(rotatetile, inverttile, positiveAngle);
		}

		//Pre-process the map data if it's auto-tiled
		var i:Int;
		totalTiles = widthInTiles*heightInTiles;
		
		//Figure out the size of the tiles
		_tiles = FlxG.addBitmap(TileGraphic);
		_tileWidth = TileWidth;
		if(_tileWidth == 0)
			_tileWidth = _tiles.height;
		_tileHeight = TileHeight;
		if(_tileHeight == 0)
			_tileHeight = _tileWidth;
		
		
			
		myParallelogram = new ParallelogramGenerator(tilemapdebug, showboundingboxes, hideTile,showmytiles);
		myParallelogram.SetParalelogram(alpha, _tileWidth, beta,_tileHeight , _tiles,positiveAngle,rotatetile,inverttile);

			
		
		//create some tile objects that we'll use for overlap checks (one for each tile)
		i = 0;
		var l:Int = Math.floor((_tiles.width/_tileWidth) * (_tiles.height/_tileHeight));
		if(auto > OFF)
			l++;
			
		_tileObjects = new Array<ParallelTile>();
		var ac:Int;
		while(i < l)
		{
			_tileObjects[i] = new ParallelTile(this,i,myParallelogram.Rectanglewidth,myParallelogram.Rectangleheight,(i >= DrawIndex),(i >= CollideIndex)?allowCollisions:FlxObject.NONE);
			i++;
		}			
		
		//create debug tiles for rendering bounding boxes on demand
		
		_debugTileNotSolid = makeDebugTile(FlxG.BLUE );
		_debugTilePartial  = makeDebugTile(FlxG.PINK );
		_debugTileSolid    = makeDebugTile(FlxG.GREEN);
		_debugRect = new Rectangle(0,0,_tileWidth,_tileHeight);
		
		//Then go through and create the actual map
		
		myParallelogram.setBigParalelogram(widthInTiles, heightInTiles);
		
		_drawlocation = new FlxPoint(
			-myParallelogram.BigUpperLeft.x+myParallelogram.UpperLeft.x
			,
			-myParallelogram.BigUpperLeft.y+myParallelogram.UpperLeft.y			
			);

		
		width  = myParallelogram.BigRectanglewidth;
					
		height = myParallelogram.BigRectangleheight;

		_rects = new Array<Rectangle>();
		i = 0;
		while(i < totalTiles)
			updateTile(i++);

		return this;
	}
	

	public function ModifyMapData(rotatetile:Bool, inverttile:Bool,positiveAngle:Bool):Void {
		var temp_data:Array<Int>;
		var tempval:Int;
		var row:Int = 0;
		var column:Int = 0;
		
		if(positiveAngle){
			temp_data = new Array<Int>();
			while (row < heightInTiles) {
				while (column < widthInTiles) {
					temp_data.push( 
						_data[ 
							row*widthInTiles +
							(widthInTiles- column- 1)
						]
					);
					column++;
				}
				column = 0;
				row++;
			}
			_data = null;
			_data = temp_data;
		}

		row = 0;
		column = 0;
		
		if (rotatetile){
			temp_data = new Array();
			while (column < widthInTiles) {
				while (row < heightInTiles) {
					temp_data.push( 
						_data[ 
							(heightInTiles - row - 1) * widthInTiles +
							column							
						]
					);
					row++;
				}
				row = 0;
				column++;
			}
			_data = null;
			_data = temp_data;				
			tempval = widthInTiles;
			widthInTiles = heightInTiles;
			heightInTiles = tempval;
			
			tempval = _tileWidth;
			_tileWidth = _tileHeight;
			_tileHeight = tempval;
		}			
	
		row = 0;
		column = 0;
		
		if (inverttile) {
			temp_data = new Array();
			while (row < heightInTiles) {
				while (column < widthInTiles) {
					temp_data.push( 
						_data[ 
							(heightInTiles - row - 1) * widthInTiles +
							column							
						]
					);
					column++;
				}
				column = 0;
				row++;
			}
			_data = null;
			_data = temp_data;				
		}
	
		row = 0;
		column = 0;

	}
	
	
	/**
	 * Internal function to clean up the map loading code.
	 * Just generates a wireframe box the size of a tile with the specified color.
	 */
	private function makeDebugTile(Color:Int):BitmapData
	{
		var debugTile:BitmapData;
		debugTile = new BitmapData(myParallelogram.Rectanglewidth,myParallelogram.Rectangleheight,true,0);

		var gfx:Graphics = FlxG.flashGfx;
		gfx.clear();
		gfx.moveTo(0,0);
		gfx.lineStyle(1,Color,0.5);
		gfx.lineTo(myParallelogram.Rectanglewidth-1 , 0);
		gfx.lineTo(myParallelogram.Rectanglewidth-1 , myParallelogram.Rectangleheight-1);
		gfx.lineTo(0                                , myParallelogram.Rectangleheight-1);
		gfx.lineTo(0,0);			
		debugTile.draw(FlxG.flashGfxSprite);
		return debugTile;
	}
	
	/**
	 * Main logic loop for tilemap is pretty simple,
	 * just checks to see if visual debug got turned on.
	 * If it did, the tilemap is flagged as dirty so it
	 * will be redrawn with debug info on the next draw call.
	 */
	override public function update():Void
	{
		if(_lastVisualDebug != FlxG.visualDebug)
		{
			_lastVisualDebug = FlxG.visualDebug;
			setDirty();
		}
	}
	


	
	/**
	 * Internal function that actually renders the tilemap to the tilemap buffer.  Called by draw().
	 * 
	 * @param	Buffer		The <code>ParallelTilemapBuffer</code> you are rendering to.
	 * @param	Camera		The related <code>FlxCamera</code>, mainly for scroll values.
	 */
	private function drawTilemap(Buffer:ParallelTilemapBuffer,Camera:FlxCamera):Void
	{
		Buffer.fill();
		
		//Copy tile images Into the tile buffer
		_point.x = Math.floor(Camera.scroll.x*scrollFactor.x) - _drawlocation.x; //modified from getScreenXY()
		_point.y = Math.floor(Camera.scroll.y*scrollFactor.y) - _drawlocation.y;
		var screenXInTiles:Int = Math.floor((_point.x + ((_point.x > 0)?0.0000001:-0.0000001))/myParallelogram.Rectanglewidth);
		var screenYInTiles:Int = Math.floor((_point.y + ((_point.y > 0)?0.0000001:-0.0000001))/myParallelogram.Rectangleheight);
		var screenRows:Int    = Buffer.rows;
		var screenColumns:Int = Buffer.columns;
		
		
		//Bound the upper left corner
		if(screenXInTiles < 0)
			screenXInTiles = 0;
		if(screenXInTiles > widthInTiles-screenColumns)
			screenXInTiles = widthInTiles-screenColumns;
		if(screenYInTiles < 0)
			screenYInTiles = 0;
		if(screenYInTiles > heightInTiles-screenRows)
			screenYInTiles = heightInTiles - screenRows;
		

			
			
		
		var rowIndex:Int = screenYInTiles*widthInTiles+screenXInTiles;
		_flashPoint.y = 0;
		var row:Int = 0;
		var column:Int;
		var columnIndex:Int;
		var tile:ParallelTile;
		
		
		var debugTile:BitmapData;

		Buffer.pixels.lock();

		
		myParallelogram.DrawBigSiluette(Buffer.pixels);

		
		while(row < screenRows)
		{
			
			columnIndex = rowIndex;
			column = 0;
							
			while (column < screenColumns)
			{					
				
				
				_flashPoint.x =  _drawlocation.x+ 
								 Math.floor(column*myParallelogram.AxisA.x   +  row*myParallelogram.AxisB.x);
				
				_flashPoint.y =   _drawlocation.y+
								 Math.floor(column*myParallelogram.AxisA.y   +  row*myParallelogram.AxisB.y);
				
				_flashRect = null;
				if (Std.is(_rects[columnIndex], Rectangle))
					_flashRect = cast(_rects[columnIndex], Rectangle);
				if(_flashRect != null )
				{
					
					Buffer.pixels.copyPixels(myParallelogram.ParalelogramTiles, _flashRect, _flashPoint, null, null, true);

					if(FlxG.visualDebug && !ignoreDrawDebug)
					{
						tile = _tileObjects[_data[columnIndex]];
						if(tile != null)
						{
							if(tile.allowCollisions <= FlxObject.NONE)
								debugTile = _debugTileNotSolid; //blue
							else if(tile.allowCollisions != FlxObject.ANY)
								debugTile = _debugTilePartial; //pink
							else
								debugTile = _debugTileSolid; //green
							//if(false)									//CLEAN
								Buffer.pixels.copyPixels(debugTile,_debugRect,_flashPoint,null,null,true);
						}
					}
				}
				
				

				columnIndex++;
				column++;
			}
			rowIndex += widthInTiles;								
			row++;

		}

		Buffer.pixels.unlock();

		
		Buffer.x = screenXInTiles*_tileWidth  -(_drawlocation.x - x);
		Buffer.y = screenYInTiles*_tileHeight -(_drawlocation.y - y);
	}
	
	/**
	 * Draws the tilemap buffers to the cameras and handles flickering.
	 */
	override public function draw():Void
	{
		if(_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if(_flicker)
				return;
		}			
		if(cameras == null)
			cameras = FlxG.cameras;
		var camera:FlxCamera;
		var buffer:ParallelTilemapBuffer;
		var i:Int = 0;
		var l:Int = cameras.length;
		while(i < l)
		{
			camera = cameras[i];
			if(_buffers[i] == null)
				_buffers[i] = new ParallelTilemapBuffer(myParallelogram.Rectanglewidth, myParallelogram.Rectangleheight, widthInTiles, heightInTiles, camera, myParallelogram.BigRectanglewidth, myParallelogram.BigRectangleheight);
			buffer = cast(_buffers[i++], ParallelTilemapBuffer); //unsafe cast ?
			if(!buffer.dirty)
			{
				_point.x = _drawlocation.x  - Math.floor(camera.scroll.x*scrollFactor.x) + buffer.x; //copied from getScreenXY()
				_point.y = _drawlocation.y  - Math.floor(camera.scroll.y*scrollFactor.y) + buffer.y;
				_point.x += (_point.x > 0)?0.0000001:-0.0000001;
				_point.y += (_point.y > 0)?0.0000001:-0.0000001;
				buffer.dirty = (_point.x > 0) || (_point.y > 0) || (_point.x + buffer.width < camera.width) || (_point.y + buffer.height < camera.height);
			}
			if(buffer.dirty)
			{
				drawTilemap(buffer,camera);
				buffer.dirty = false;
			}
			_flashPoint.x = _drawlocation.x - Math.floor(camera.scroll.x*scrollFactor.x) + buffer.x; //copied from getScreenXY()
			_flashPoint.y = _drawlocation.y - Math.floor(camera.scroll.y*scrollFactor.y) + buffer.y;
			_flashPoint.x += (_flashPoint.x > 0)?0.0000001:-0.0000001;
			_flashPoint.y += (_flashPoint.y > 0)?0.0000001:-0.0000001;
			buffer.draw(camera, _flashPoint);
			//increasevisiblecount();
		}
	}
	
	/**
	 * Fetches the tilemap data array.
	 * 
	 * @param	Simple		If true, returns the data as copy, as a series of 1s and 0s (useful for auto-tiling stuff). Default value is false, meaning it will return the actual data array (NOT a copy).
	 * 
	 * @return	An array the size of the tilemap full of Integers indicating tile placement.
	 */
	public function getData(Simple:Bool=false):Array<Int>
	{
		if(!Simple)
			return _data;
		
		var i:Int = 0;
		var l:Int = _data.length;
		var data:Array<Int> = new Array<Int>();
		while(i < l)
		{
			data[i] = (cast(_tileObjects[_data[i]], ParallelTile).allowCollisions > 0)?1:0;
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
	public function setDirty(Dirty:Bool=true):Void
	{
		var i:Int = 0;
		var l:Int = _buffers.length;
		while(i < l)
			cast(_buffers[i++], ParallelTilemapBuffer).dirty = Dirty;
	}
	
	/**
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 * 
	 * @param	Start		The start point in world coordinates.
	 * @param	End			The end point in world coordinates.
	 * @param	Simplify	Whether to run a basic simplification algorithm over the path data, removing extra points that are on the same line.  Default value is true.
	 * @param	RaySimplify	Whether to run an extra raycasting simplification algorithm over the remaining path data.  This can result in some close corners being cut, and should be used with care if at all (yet).  Default value is false.
	 * 
	 * @return	A <code>FlxPath</code> from the start to the end.  If no path could be found, then a null reference is returned.
	 */
	public function findPath(Start:FlxPoint,End:FlxPoint,Simplify:Bool=true,RaySimplify:Bool=false):FlxPath
	{
		//figure out what tile we are starting and ending on.
		var startIndex:Int = Math.floor((Start.y-y)/_tileHeight) * widthInTiles + Math.floor((Start.x-x)/_tileWidth);
		var endIndex:Int = Math.floor((End.y-y)/_tileHeight) * widthInTiles + Math.floor((End.x-x)/_tileWidth);

		//check that the start and end are clear.
		if( (cast(_tileObjects[_data[startIndex]], ParallelTile).allowCollisions > 0) ||
			(cast(_tileObjects[_data[endIndex]], ParallelTile).allowCollisions > 0) )
			return null;
		
		//figure out how far each of the tiles is from the starting tile
		var distances:Array<Int> = computePathDistance(startIndex,endIndex);
		if(distances == null)
			return null;

		//then count backward to find the shortest path.
		var points:Array<FlxPoint> = new Array<FlxPoint>();
		walkPath(distances,endIndex,points);
		
		//reset the start and end points to be exact
		var node:FlxPoint;
		node = cast(points[points.length-1], FlxPoint);
		node.x = Start.x;
		node.y = Start.y;
		node = cast(points[0], FlxPoint);
		node.x = End.x;
		node.y = End.y;

		//some simple path cleanup options
		if(Simplify)
			simplifyPath(points);
		if(RaySimplify)
			raySimplifyPath(points);
		
		//finally load the remaining points Into a new path object and return it
		var path:FlxPath = new FlxPath();
		var i:Int = points.length - 1;
		while(i >= 0)
		{
			node = cast(points[i--], FlxPoint);
			if(node != null)
				path.addPoint(node,true);
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
		var l:Int = Points.length-1;
		while(i < l)
		{
			node = Points[i];
			deltaPrevious = (node.x - last.x)/(node.y - last.y);
			deltaNext = (node.x - Points[i+1].x)/(node.y - Points[i+1].y);
			if((last.x == Points[i+1].x) || (last.y == Points[i+1].y) || (deltaPrevious == deltaNext))
				Points[i] = null;
			else
				last = node;
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
			if(node == null)
				continue;
			if(ray(source,node,_point))	
			{
				if(lastIndex >= 0)
					Points[lastIndex] = null;
			}
			else
				source = Points[lastIndex];
			lastIndex = i-1;
		}
	}
	
	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic!  It's pretty brute.
	 * 
	 * @param	StartIndex	The starting tile's map index.
	 * @param	EndIndex	The ending tile's map index.
	 * 
	 * @return	A Flash <code>Array</code> of <code>FlxPoint</code> nodes.  If the end tile could not be found, then a null <code>Array</code> is returned instead.
	 */
	private function computePathDistance(StartIndex:Int, EndIndex:Int):Array<Int>
	{
		//Create a distance-based representation of the tilemap.
		//All walls are flagged as -2, all open areas as -1.
		var mapSize:Int = widthInTiles*heightInTiles;
		var distances:Array<Int> = new Array<Int>();
		var i:Int = 0;
		while(i < mapSize)
		{
			if (cast(_tileObjects[_data[i]], ParallelTile).allowCollisions != FlxObject.NONE )
				distances[i] = -2;
			else
				distances[i] = -1;
			i++;
		}
		var distance:Int = 0;
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
				if(currentIndex == EndIndex)
				{
					foundEnd = true;
					neighbors = new Array<Int>();
//					neighbors.length = 0;
					break;
				}
				
				//basic map bounds
				left = currentIndex%widthInTiles > 0;
				right = currentIndex%widthInTiles < widthInTiles-1;
				up = currentIndex/widthInTiles > 0;
				down = currentIndex/widthInTiles < heightInTiles-1;
				
				var index:Int;
				if(up)
				{
					index = currentIndex - widthInTiles;
					if(distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if(right)
				{
					index = currentIndex + 1;
					if(distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if(down)
				{
					index = currentIndex + widthInTiles;
					if(distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if(left)
				{
					index = currentIndex - 1;
					if(distances[index] == -1)
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if(up && right)
				{
					index = currentIndex - widthInTiles + 1;
					if((distances[index] == -1) && (distances[currentIndex-widthInTiles] >= -1) && (distances[currentIndex+1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if(right && down)
				{
					index = currentIndex + widthInTiles + 1;
					if((distances[index] == -1) && (distances[currentIndex+widthInTiles] >= -1) && (distances[currentIndex+1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if(left && down)
				{
					index = currentIndex + widthInTiles - 1;
					if((distances[index] == -1) && (distances[currentIndex+widthInTiles] >= -1) && (distances[currentIndex-1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
				if(up && left)
				{
					index = currentIndex - widthInTiles - 1;
					if((distances[index] == -1) && (distances[currentIndex-widthInTiles] >= -1) && (distances[currentIndex-1] >= -1))
					{
						distances[index] = distance;
						neighbors.push(index);
					}
				}
			}
			distance++;
		}
		if(!foundEnd)
			distances = null;
		return distances;
	}
	
	/**
	 * Pathfinding helper function, recursively walks the grid and finds a shortest path back to the start.
	 * 
	 * @param	Data	A Flash <code>Array</code> of distance information.
	 * @param	Start	The tile we're on in our walk backward.
	 * @param	Points	A Flash <code>Array</code> of <code>FlxPoint</code> nodes composing the path from the start to the end, compiled in reverse order.
	 */
	private function walkPath(Data:Array<Int>,Start:Int,Points:Array<FlxPoint>):Void
	{
		Points.push(new FlxPoint(x + Start%widthInTiles*_tileWidth + _tileWidth*0.5, y + Math.floor(Start/widthInTiles)*_tileHeight + _tileHeight*0.5));
		if(Data[Start] == 0)
			return;
		
		//basic map bounds
		var left:Bool = Start%widthInTiles > 0;
		var right:Bool = Start%widthInTiles < widthInTiles-1;
		var up:Bool = Start/widthInTiles > 0;
		var down:Bool = Start/widthInTiles < heightInTiles-1;
		
		var current:Int = Data[Start];
		var i:Int;
		if(up)
		{
			i = Start - widthInTiles;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		if(right)
		{
			i = Start + 1;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		if(down)
		{
			i = Start + widthInTiles;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		if(left)
		{
			i = Start - 1;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		if(up && right)
		{
			i = Start - widthInTiles + 1;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		if(right && down)
		{
			i = Start + widthInTiles + 1;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		if(left && down)
		{
			i = Start + widthInTiles - 1;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		if(up && left)
		{
			i = Start - widthInTiles - 1;
			if((Data[i] >= 0) && (Data[i] < current))
				return walkPath(Data,i,Points);
		}
		return ;
	}
	
	/**
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 * 
	 * @param	Object				The <code>FlxObject</code> you are checking for overlaps against.
	 * @param	Callback			An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a ParallelTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param	FlipCallbackParams	Used to preserve A-B list ordering from FlxObject.separate() - returns the ParallelTile object as the second parameter instead.
	 * 
	 * @return	Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	public function overlapsWithCallback(Object:FlxObject,Callback:FlxObject->FlxObject->Bool = null,FlipCallbackParams:Bool=false):Bool
	{
		var results:Bool = false;
		
		
		var refPoint:FlxPoint = new FlxPoint(
											Object.x - _drawlocation.x
											,
											Object.y - _drawlocation.y
											);
		
		
		//Figure out what tiles we need to check against
		var selectionY:Int =  FlxU.floor(
											(			
											refPoint.y
											) / (_tileHeight)
										);
		var selectionHeight:Int = selectionY + FlxU.ceil ( Object.height/_tileHeight) + 1;

		var selectionX:Int =  FlxU.floor(
											(			
											refPoint.x
											) / (_tileWidth)
										);
		var selectionWidth:Int = selectionX  +  FlxU.ceil(  Object.width/(_tileWidth)) + 1;
		
		//Then bound these coordinates by the map edges
		if(selectionX < 0)
			selectionX = 0;
		if(selectionY < 0)
			selectionY = 0;
		if(selectionWidth > widthInTiles)
			selectionWidth = widthInTiles;
		if(selectionHeight > heightInTiles)
			selectionHeight = heightInTiles;
		
		//Then loop through this selection of tiles and call FlxObject.separate() accordingly
		var rowStart:Int = selectionY*widthInTiles;
		var row:Int = selectionY;
		var column:Int;
		var tile:ParallelTile;
		var overlapFound:Bool;
		var deltaX:Float = x - last.x;  
		var deltaY:Float = y - last.y;
		while(row < selectionHeight)
		{				
			column = selectionX;
			while(column < selectionWidth)
			{
				overlapFound = false;
				tile = cast(_tileObjects[_data[rowStart+column]], ParallelTile);
				if(tile.allowCollisions != FlxObject.NONE)
				{
					tile.x = _drawlocation.x +column*(_tileWidth );
					tile.y = _drawlocation.y +row   *(_tileHeight);
					tile.last.x = tile.x - deltaX;
					tile.last.y = tile.y - deltaY;
					if(Callback != null)
					{
						if(FlipCallbackParams)
							overlapFound = Callback(Object,tile);
						else
							overlapFound = Callback(tile,Object);
					}
					else
						overlapFound = 
						(Object.x + Object.width > tile.x) && 
						(Object.x < tile.x + tile.width) && 
						(Object.y + Object.height > tile.y) && 
						(Object.y < tile.y + tile.height);
					if(overlapFound)
					{
						if((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
						{
							tile.mapIndex = rowStart+column;
							tile.callbackFunction(tile,Object);
						}
						results = true;
					}
				}
				else if((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
				{
					tile.mapIndex = rowStart+column;
					tile.callbackFunction(tile,Object);
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
	 * @param	Point			The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors Into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * 
	 * @return	Whether or not the point overlaps this object.
	 */
	override public function overlapsPoint(Point:FlxPoint,InScreenSpace:Bool=false,Camera:FlxCamera=null):Bool
	{
		if(!InScreenSpace)
			return cast(_tileObjects[_data[Math.floor(Math.floor((Point.y-y)/_tileHeight)*widthInTiles + (Point.x-x)/_tileWidth)]], ParallelTile).allowCollisions > 0;
		
		if(Camera == null)
			Camera = FlxG.camera;
		Point.x = Point.x - Camera.scroll.x;
		Point.y = Point.y - Camera.scroll.y;
		getScreenXY(_point,Camera);
		return cast(_tileObjects[_data[Math.floor(Math.floor((Point.y-_point.y)/_tileHeight)*widthInTiles + (Point.x-_point.x)/_tileWidth)]], ParallelTile).allowCollisions > 0;
	}
	
	/**
	 * Check the value of a particular tile.
	 * 
	 * @param	X		The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y		The Y coordinate of the tile (in tiles, not pixels).
	 * 
	 * @return	A Int containing the value of the tile at this spot in the array.
	 */
	public function getTile(X:Int,Y:Int):Int
	{
		return cast(_data[Y * widthInTiles + X], Int);
	}
	
	/**
	 * Get the value of a tile in the tilemap by index.
	 * 
	 * @param	Index	The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * 
	 * @return	A Int containing the value of the tile at this spot in the array.
	 */
	public function getTileByIndex(Index:Int):Int
	{
		return cast(_data[Index], Int);
	}
	
	/**
	 * Returns a new Flash <code>Array</code> full of every map index of the requested tile type.
	 *
	 * @param	Index	The requested tile type.
	 * 
	 * @return	An <code>Array</code> with a list of all map indices of that tile type.
	 */
	public function getTileInstances(Index:Int):Array<Int>
	{
		var array:Array<Int> = null;
		var i:Int = 0;
		var l:Int = widthInTiles * heightInTiles;
		while(i < l)
		{
			if(_data[i] == Index)
			{
				if(array == null)
					array = new Array<Int>();
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
	 * 
	 * @return	An <code>Array</code> with a list of all the coordinates of that tile type.
	 */
	public function getTileCoords(Index:Int,Midpoint:Bool=true):Array<FlxPoint>
	{
		var array:Array<FlxPoint> = null;
		
		var point:FlxPoint;
		var i:Int = 0;
		var l:Int = widthInTiles * heightInTiles;
		while(i < l)
		{
			if(_data[i] == Index)
			{
				point = new FlxPoint(i%widthInTiles*_tileWidth,Math.floor(i/widthInTiles)*_tileHeight);
				if(Midpoint)
				{
					point.x += _tileWidth*0.5;
					point.y += _tileHeight*0.5;
				}
				if(array == null)
					array = new Array<FlxPoint>();
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
	 * @param	Tile			The new Integer data you wish to inject.
	 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
	 * 
	 * @return	Whether or not the tile was actually changed.
	 */ 
	public function setTile(X:Int,Y:Int,Tile:Int,UpdateGraphics:Bool=true):Bool
	{
		if((X >= widthInTiles) || (Y >= heightInTiles))
			return false;
		return setTileByIndex(Y * widthInTiles + X,Tile,UpdateGraphics);
	}
	
	/**
	 * Change the data and graphic of a tile in the tilemap.
	 * 
	 * @param	Index			The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * @param	Tile			The new Integer data you wish to inject.
	 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
	 * 
	 * @return	Whether or not the tile was actually changed.
	 */
	public function setTileByIndex(Index:Int,Tile:Int,UpdateGraphics:Bool=true):Bool
	{
		if(Index >= _data.length)
			return false;
		
		var ok:Bool = true;
		_data[Index] = Tile;
		
		if(!UpdateGraphics)
			return ok;
		
		setDirty();
		
		if(auto == OFF)
		{
			updateTile(Index);
			return ok;
		}
		
		//If this map is autotiled and it changes, locally update the arrangement
		var i:Int;
		var row:Int = Math.floor(Index/widthInTiles) - 1;
		var rowLength:Int = row + 3;
		var column:Int = Index%widthInTiles - 1;
		var columnHeight:Int = column + 3;
		while(row < rowLength)
		{
			column = columnHeight - 3;
			while(column < columnHeight)
			{
				if((row >= 0) && (row < heightInTiles) && (column >= 0) && (column < widthInTiles))
				{
					i = row*widthInTiles+column;
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
	 * @param	Tile			The tile or tiles you want to adjust.
	 * @param	AllowCollisions	Modify the tile or tiles to only allow collisions from certain directions, use FlxObject constants NONE, ANY, LEFT, RIGHT, etc.  Default is "ANY".
	 * @param	Callback		The function to trigger, e.g. <code>lavaCallback(Tile:ParallelTile, Object:FlxObject)</code>.
	 * @param	CallbackFilter	If you only want the callback to go off for certain classes or objects based on a certain class, set that class here.
	 * @param	Range			If you want this callback to work for a bunch of different tiles, input the range here.  Default value is 1.
	 */
	public function setTileProperties(Tile:Int,AllowCollisions:Int=0x1111, Callback:FlxObject->FlxObject->Void = null,CallbackFilter:Class<Dynamic>=null,Range:Int=1):Void
	{
		if(Range <= 0)
			Range = 1;
		var tile:ParallelTile;
		var i:Int = Tile;
		var l:Int = Tile+Range;
		while(i < l)
		{
			tile = cast(_tileObjects[i++], ParallelTile);
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
	public function follow(Camera:FlxCamera=null,Border:Int=0,UpdateWorld:Bool=true):Void
	{
		if(Camera == null)
			Camera = FlxG.camera;
		Camera.setBounds(x+Border*_tileWidth,y+Border*_tileHeight,width-Border*_tileWidth*2,height-Border*_tileHeight*2,UpdateWorld);
	}
	
	/**
	 * Get the world coordinates and size of the entire tilemap as a <code>FlxRect</code>.
	 * 
	 * @param	Bounds		Optional, pass in a pre-existing <code>FlxRect</code> to prevent instantiation of a new object.
	 * 
	 * @return	A <code>FlxRect</code> containing the world coordinates and size of the entire tilemap.
	 */
	public function getBounds(Bounds:FlxRect=null):FlxRect
	{
		if(Bounds == null)
			Bounds = new FlxRect();
		return Bounds.make(x,y,width,height);
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
	public function ray(Start:FlxPoint, End:FlxPoint, Result:FlxPoint=null, Resolution:Float=1):Bool
	{
		var step:Float = _tileWidth;
		if(_tileHeight < _tileWidth)
			step = _tileHeight;
		step /= Resolution;
		var deltaX:Float = End.x - Start.x;
		var deltaY:Float = End.y - Start.y;
		var distance:Float = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
		var steps:Int = Math.ceil(distance/step);
		var stepX:Float = deltaX/steps;
		var stepY:Float = deltaY/steps;
		var curX:Float = Start.x - stepX - _drawlocation.x;
		var curY:Float = Start.y - stepY - _drawlocation.y;
		var tileX:Int;
		var tileY:Int;
		var i:Int = 0;
		while(i < steps)
		{
			curX += stepX;
			curY += stepY;
			
			if((curX < 0) || (curX > width) || (curY < 0) || (curY > height))
			{
				i++;
				continue;
			}
			
			tileX = Math.floor(curX/_tileWidth);
			tileY = Math.floor(curY/_tileHeight);
			if(cast(_tileObjects[_data[tileY*widthInTiles+tileX]], ParallelTile).allowCollisions != FlxObject.NONE)
			{
				//Some basic helper stuff
				tileX *= _tileWidth;
				tileY *= _tileHeight;
				var rx:Float = 0;
				var ry:Float = 0;
				var q:Float;
				var lx:Float = curX-stepX;
				var ly:Float = curY-stepY;
				
				//Figure out if it crosses the X boundary
				q = tileX;
				if(deltaX < 0)
					q += _tileWidth;
				rx = q;
				ry = ly + stepY*((q-lx)/stepX);
				if((ry > tileY) && (ry < tileY + _tileHeight))
				{
					if(Result == null)
						Result = new FlxPoint();
					Result.x = rx;
					Result.y = ry;
					return false;
				}
				
				//Else, figure out if it crosses the Y boundary
				q = tileY;
				if(deltaY < 0)
					q += _tileHeight;
				rx = lx + stepX*((q-ly)/stepY);
				ry = q;
				if((rx > tileX) && (rx < tileX + _tileWidth))
				{
					if(Result == null)
						Result = new FlxPoint();
					Result.x = rx;
					Result.y = ry;
					return false;
				}
				return true;
			}
			i++;
		}
		return true;
	}
	
	/**
	 * Converts a one-dimensional array of tile data to a comma-separated string.
	 * 
	 * @param	Data		An array full of Integer tile references.
	 * @param	Width		The number of tiles in each row.
	 * @param	Invert		Recommended only for 1-bit arrays - changes 0s to 1s and vice versa.
	 * 
	 * @return	A comma-separated string containing the level data in a <code>ParallelTilemap</code>-friendly format.
	 */
	static public function arrayToCSV(Data:Array<Int>,Width:Int,Invert:Bool=false):String
	{
		var row:Int = 0;
		var column:Int;
		var csv:String = "";
		var Height:Int = cast(Data.length / Width, Int);
		var index:Int;
		while(row < Height)
		{
			column = 0;
			while(column < Width)
			{
				index = Data[row*Width+column];
				if(Invert)
				{
					if(index == 0)
						index = 1;
					else if(index == 1)
						index = 0;
				}
				
				if(column == 0)
				{
					if(row == 0)
						csv += index;
					else
						csv += "\n"+index;
				}
				else
					csv += ", "+index;
				column++;
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
	 * @param	bitmapData	A Flash <code>BitmapData</code> object, preferably black and white.
	 * @param	Invert		Load white pixels as solid instead.
	 * @param	Scale		Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * 
	 * @return	A comma-separated string containing the level data in a <code>ParallelTilemap</code>-friendly format.
	 */
	static public function bitmapToCSV(bitmapData:BitmapData,Invert:Bool=false,Scale:Int=1):String
	{
		//Import and scale image if necessary
		if(Scale > 1)
		{
			var bd:BitmapData = bitmapData;
			bitmapData = new BitmapData(bitmapData.width*Scale,bitmapData.height*Scale);
			var mtx:Matrix = new Matrix();
			mtx.scale(Scale,Scale);
			bitmapData.draw(bd,mtx);
		}
		
		//Walk image and export pixel values
		var row:Int = 0;
		var column:Int;
		var pixel:Int;
		var csv:String = "";
		var bitmapWidth:Int = bitmapData.width;
		var bitmapHeight:Int = bitmapData.height;
		while(row < bitmapHeight)
		{
			column = 0;
			while(column < bitmapWidth)
			{
				//Decide if this pixel/tile is solid (1) or not (0)
				pixel = bitmapData.getPixel(column,row);
				if((Invert && (pixel > 0)) || (!Invert && (pixel == 0)))
					pixel = 1;
				else
					pixel = 0;
				
				//Write the result to the string
				if(column == 0)
				{
					if(row == 0)
						csv += pixel;
					else
						csv += "\n"+pixel;
				}
				else
					csv += ", "+pixel;
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
	 * 
	 * @return	A comma-separated string containing the level data in a <code>ParallelTilemap</code>-friendly format.
	 */
	//static public function imageToCSV(ImageFile:Class<Dynamic>,Invert:Bool=false,Scale:Int=1):String
	//{
		//return bitmapToCSV((new ImageFile()).bitmapData,Invert,Scale);
	//}
	
	/**
	 * An Internal function used by the binary auto-tilers.
	 * 
	 * @param	Index		The index of the tile you want to analyze.
	 */
	private function autoTile(Index:Int):Void
	{
		if(_data[Index] == 0)
			return;
		
		_data[Index] = 0;
		if((Index-widthInTiles < 0) || (_data[Index-widthInTiles] > 0)) 		//UP
			_data[Index] += 1;
		if((Index%widthInTiles >= widthInTiles-1) || (_data[Index+1] > 0)) 		//RIGHT
			_data[Index] += 2;
		if((cast(Index+widthInTiles, Int) >= totalTiles) || (_data[cast(Index+widthInTiles, Int)] > 0)) //DOWN
			_data[Index] += 4;
		if((Index%widthInTiles <= 0) || (_data[Index-1] > 0)) 					//LEFT
			_data[Index] += 8;
		if((auto == ALT) && (_data[Index] == 15))	//The alternate algo checks for Interior corners
		{
			if((Index%widthInTiles > 0) && (cast(Index+widthInTiles, Int) < totalTiles) && (_data[Index+widthInTiles-1] <= 0))
				_data[Index] = 1;		//BOTTOM LEFT OPEN
			if((Index%widthInTiles > 0) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles-1] <= 0))
				_data[Index] = 2;		//TOP LEFT OPEN
			if((Index%widthInTiles < widthInTiles-1) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0))
				_data[Index] = 4;		//TOP RIGHT OPEN
			if((Index%widthInTiles < widthInTiles-1) && (cast(Index+widthInTiles, Int) < totalTiles) && (_data[Index+widthInTiles+1] <= 0))
				_data[Index] = 8; 		//BOTTOM RIGHT OPEN
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
		/*									
			_data.push(Int(columns[column++]));
			_tileObjects   ----->Brush
		*/
		
		var tile:ParallelTile = null;
		if (Std.is(_tileObjects[_data[Index]], ParallelTile))
			tile = cast(_tileObjects[_data[Index]], ParallelTile);
		if((tile == null) || !tile.visible)
		{
			_rects[Index] = null;
			return;
		}
		var rx:Int = (_data[Index]) * myParallelogram.Rectanglewidth;
		var ry:Int = 0;
		if(rx >= myParallelogram.ParalelogramTiles.width)
		{
			ry = cast(rx/myParallelogram.ParalelogramTiles.width, Int)*myParallelogram.Rectangleheight;
			rx %= myParallelogram.Rectanglewidth;
		}
		_rects[Index] = (new Rectangle(rx,ry,myParallelogram.Rectanglewidth-1,myParallelogram.Rectangleheight-1));
	}
}
