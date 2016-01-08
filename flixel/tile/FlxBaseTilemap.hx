package flixel.tile;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.util.FlxArrayUtil;
import openfl.Assets;
using StringTools;

class FlxBaseTilemap<Tile:FlxObject> extends FlxObject
{
	/**
	 * Set this flag to use one of the 16-tile binary auto-tile algorithms (OFF, AUTO, or ALT).
	 */
	public var auto:FlxTilemapAutoTiling = OFF;
	
	public var widthInTiles(default, null):Int = 0;
	
	public var heightInTiles(default, null):Int = 0;
	
	public var totalTiles(default, null):Int = 0;
	
	/**
	 * Set this to create your own image index remapper, so you can create your own tile layouts.
	 * Mostly useful in combination with the auto-tilers.
	 * 
	 * Normally, each tile's value in _data corresponds to the index of a 
	 * tile frame in the tilesheet. With this active, each value in _data
	 * is a lookup value to that index in customTileRemap.
	 * 
	 * Example:
	 *  customTileRemap = [10,9,8,7,6]
	 *  means: 0=10, 1=9, 2=8, 3=7, 4=6
	 */
	public var customTileRemap:Array<Int>;

	/**
	 * If these next two arrays are not null, you're telling FlxTilemap to 
	 * draw random tiles in certain places. 
	 * 
	 * _randomIndices is a list of tilemap values that should be replaced
	 * by a randomly selected value. The available values are chosen from
	 * the corresponding array in randomize_choices
	 * 
	 * So if you have:
	 *   randomIndices = [12,14]
	 *   randomChoices = [[0,1,2],[3,4,5,6,7]]
	 * 
	 * Everywhere the tilemap has a value of 12 it will be replaced by 0, 1, or, 2
	 * Everywhere the tilemap has a value of 14 it will be replaced by 3, 4, 5, 6, 7
	 */
	private var _randomIndices:Array<Int>;
	private var _randomChoices:Array<Array<Int>>;
	/**
	 * Setting this function allows you to control which choice will be selected for each element within _randomIndices array.
	 * Must return a 0-1 value that gets multiplied by _randomChoices[randIndex].length;
	 */
	private var _randomLambda:Void->Float;
	/**
	 * Internal collection of tile objects, one for each type of tile in the map (NOT one for every single tile in the whole map).
	 */
	private var _tileObjects:Array<Tile> = [];

	/**
	 * Internal, used to sort of insert blank tiles in front of the tiles in the provided graphic.
	 */
	private var _startingIndex:Int = 0;
	/**
	 * Internal representation of the actual tile data, as a large 1D array of integers.
	 */
	private var _data:Array<Int>;
	
	private var _drawIndex:Int = 0;
	private var _collideIndex:Int = 0;
	
	/**
	 * Virtual methods, must be implemented in each renderers
	 */
	private function updateTile(Index:Int):Void 
	{
		throw "updateTile must be implemented";
	}
	
	private function cacheGraphics(TileWidth:Int, TileHeight:Int, TileGraphic:FlxTilemapGraphicAsset):Void
	{
		throw "cacheGraphics must be implemented";
	}
	
	private function initTileObjects():Void 
	{
		throw "initTileObjects must be implemented";
	}
	
	private function updateMap():Void
	{
		throw "updateMap must be implemented";
	}
	
	private function computeDimensions():Void
	{
		throw "computeDimensions must be implemented";
	}
	
	public function getTileIndexByCoords(Coord:FlxPoint):Int
	{
		throw "getTileIndexByCoords must be implemented";
		return 0;
	}
	
	public function getTileCoordsByIndex(Index:Int, Midpoint:Bool = true):FlxPoint
	{ 
		throw "getTileCoordsByIndex must be implemented";
		return null;
	}
	
	public function ray(Start:FlxPoint, End:FlxPoint, ?Result:FlxPoint, Resolution:Float = 1):Bool
	{ 
		throw "ray must be implemented";
		return false;
	}
	
	public function overlapsWithCallback(Object:FlxObject, ?Callback:FlxObject->FlxObject->Bool, FlipCallbackParams:Bool = false, ?Position:FlxPoint):Bool
	{ 
		throw "overlapsWithCallback must be implemented";
		return false;
	}
	
	public function setDirty(Dirty:Bool = true):Void
	{
		throw "setDirty must be implemented";
	}

	private function new()
	{
		super();
		
		flixelType = TILEMAP;
		immovable = true;
		moves = false;
	}
	
	override public function destroy():Void 
	{
		_data = null;
		super.destroy();
	}

	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param   MapData         A csv-formatted string indicating what order the tiles should go in (or the path to that file)
	 * @param   TileGraphic     All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param   TileWidth       The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param   TileHeight      The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param   AutoTile        Whether to load the map using an automatic tile placement algorithm (requires 16 tiles!).
	 *                          Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param   StartingIndex   Used to sort of insert empty tiles in front of the provided graphic.
	 *                          Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param   DrawIndex       Initializes all tile objects equal to and after this index as visible.
	 *                          Default value is 1. Ignored if AutoTile is set.
	 * @param   CollideIndex    Initializes all tile objects equal to and after this index as allowCollisions = ANY.
	 *                          Default value is 1.  Ignored if AutoTile is set.  
	 *                          Can override and customize per-tile-type collision behavior using setTileProperties().
	 * @return  A reference to this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMapFromCSV(MapData:String, TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0, 
		?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1)
	{
		// path to map data file?
		if (Assets.exists(MapData))
		{
			MapData = Assets.getText(MapData);
		}
		
		// Figure out the map dimensions based on the data string
		_data = new Array<Int>();
		var columns:Array<String>;
		
		var regex:EReg = new EReg("[ \t]*((\r\n)|\r|\n)[ \t]*", "g");
		var lines:Array<String> = regex.split(MapData);
		var rows:Array<String> = lines.filter(function(line) return line != "");
		
		heightInTiles = rows.length;
		widthInTiles = 0;
		
		var row:Int = 0;
		while (row < heightInTiles)
		{
			var rowString = rows[row];
			if (rowString.endsWith(","))
				rowString = rowString.substr(0, rowString.length - 1);
			columns = rowString.split(",");
			
			if (columns.length == 0)
			{
				heightInTiles--;
				continue;
			}
			if (widthInTiles == 0)
			{
				widthInTiles = columns.length;
			}
			
			var column = 0;
			while (column < widthInTiles)
			{
				//the current tile to be added:
				var columnString = columns[column];
				var curTile = Std.parseInt(columnString);
				
				if (curTile == null)
					throw 'String in row $row, column $column is not a valid integer: "$columnString"';
				
				// anything < 0 should be treated as 0 for compatibility with certain map formats (ogmo)
				if (curTile < 0)
					curTile = 0;
				
				_data.push(curTile);
				column++;
			}
			
			row++;
		}
		
		loadMapHelper(TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
		return this;
	}
	
	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param   MapData         An array containing the tile indices
	 * @param   WidthInTiles    The width of the tilemap in tiles
	 * @param   HeightInTiles   The height of the tilemap in tiles
	 * @param   TileGraphic     All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param   TileWidth       The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param   TileHeight      The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param   AutoTile        Whether to load the map using an automatic tile placement algorithm (requires 16 tiles!).
	 *                          Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param   StartingIndex   Used to sort of insert empty tiles in front of the provided graphic.
	 *                          Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param   DrawIndex       Initializes all tile objects equal to and after this index as visible.
	 *                          Default value is 1. Ignored if AutoTile is set.
	 * @param   CollideIndex    Initializes all tile objects equal to and after this index as allowCollisions = ANY.
	 *                          Default value is 1.  Ignored if AutoTile is set.  
	 *                          Can override and customize per-tile-type collision behavior using setTileProperties().
	 * @return  A reference to this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMapFromArray(MapData:Array<Int>, WidthInTiles:Int, HeightInTiles:Int, TileGraphic:FlxTilemapGraphicAsset,
		TileWidth:Int = 0, TileHeight:Int = 0, ?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1)
	{
		widthInTiles = WidthInTiles;
		heightInTiles = HeightInTiles;
		_data = MapData.copy(); // make a copy to make sure we don't mess with the original array, which might be used for something!
		
		loadMapHelper(TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
		return this;
	}
	
	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param   MapData         A 2D array containing the tile indices. The length of the inner arrays should be consistent.
	 * @param   TileGraphic     All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param   TileWidth       The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param   TileHeight      The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param   AutoTile        Whether to load the map using an automatic tile placement algorithm (requires 16 tiles!).
	 *                          Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param   StartingIndex   Used to sort of insert empty tiles in front of the provided graphic.
	 *                          Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param   DrawIndex       Initializes all tile objects equal to and after this index as visible.
	 *                          Default value is 1. Ignored if AutoTile is set.
	 * @param   CollideIndex    Initializes all tile objects equal to and after this index as allowCollisions = ANY.
	 *                          Default value is 1.  Ignored if AutoTile is set.  
	 *                          Can override and customize per-tile-type collision behavior using setTileProperties().
	 * @return  A reference to this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMapFrom2DArray(MapData:Array<Array<Int>>, TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0,
		?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1)
	{
		widthInTiles = MapData[0].length;
		heightInTiles = MapData.length;
		_data = FlxArrayUtil.flatten2DArray(MapData);
		
		loadMapHelper(TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
		return this;
	}
	
	private function loadMapHelper(TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0, ?AutoTile:FlxTilemapAutoTiling,
		StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1)
	{
		totalTiles = _data.length;
		auto = (AutoTile == null) ? OFF : AutoTile;
		_startingIndex = (StartingIndex <= 0) ? 0 : StartingIndex;

		if (auto != OFF)
		{
			_startingIndex = 1;
			DrawIndex = 1;
			CollideIndex = 1;
		}
		
		_drawIndex = DrawIndex;
		_collideIndex = CollideIndex;
		
		applyAutoTile();
		applyCustomRemap();
		randomizeIndices();
		cacheGraphics(TileWidth, TileHeight, TileGraphic);
		postGraphicLoad();
	}

	private function postGraphicLoad()
	{
		initTileObjects();
		computeDimensions();
		updateMap();
	}
	
	private function applyAutoTile():Void	
	{
		// Pre-process the map data if it's auto-tiled
		if (auto != OFF)
		{
			var i:Int = 0;
			while (i < totalTiles)
			{
				autoTile(i++);
			}
		}
	}
	
	private function applyCustomRemap():Void
	{
		var i:Int = 0;

		if (customTileRemap != null) 
		{
			while (i < totalTiles) 
			{
				var oldIndex = _data[i];
				var newIndex = oldIndex;
				if (oldIndex < customTileRemap.length)
				{
					newIndex = customTileRemap[oldIndex];
				}
				_data[i] = newIndex;
				i++;
			}
		}
	}
	
	private function randomizeIndices():Void
	{
		var i:Int = 0;

		if (_randomIndices != null)
		{
			var randLambda:Void->Float = _randomLambda != null ? _randomLambda : function() {
				return FlxG.random.float();
			};
			
			while (i < totalTiles)
			{
				var oldIndex = _data[i];
				var j = 0;
				var newIndex = oldIndex;
				for (rand in _randomIndices) 
				{
					if (oldIndex == rand) 
					{
						var k:Int = Std.int(randLambda() * _randomChoices[j].length);
						newIndex = _randomChoices[j][k];
					}
					j++;
				}
				_data[i] = newIndex;
				i++;
			}
		}
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
			if ((Index % widthInTiles > 0) && (Std.int(Index+widthInTiles) < totalTiles) && (_data[Index+widthInTiles-1] <= 0))
			{
				_data[Index] = 1;
			}
			// TOP LEFT OPEN
			if ((Index % widthInTiles > 0) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles-1] <= 0))
			{
				_data[Index] = 2;
			}
			// TOP RIGHT OPEN
			if ((Index % widthInTiles < widthInTiles-1) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0))
			{
				_data[Index] = 4;
			}
			// BOTTOM RIGHT OPEN
			if ((Index % widthInTiles < widthInTiles - 1) && (Std.int(Index + widthInTiles) < totalTiles) && (_data[Index + widthInTiles + 1] <= 0))
			{
				_data[Index] = 8;
			}
		}
		
		_data[Index] += 1;
	}

	/**
	 * Set custom tile mapping and/or randomization rules prior to loading. This MUST be called BEFORE loadMap().
	 * WARNING: Using this will cause your maps to take longer to load. Be careful using this in very large tilemaps.
	 * 
	 * @param	mappings		Array of ints for remapping tiles. Ex: [7,4,12] means "0-->7, 1-->4, 2-->12"
	 * @param	randomIndices	Array of ints indicating which tile indices should be randmoized. Ex: [7,4,12] means "replace tile index of 7, 4, or 12 with a randomized value"
	 * @param	randomChoices	A list of int-arrays that serve as the corresponding choices to randomly choose from. Ex: indices = [7,4], choices = [[1,2],[3,4,5]], 7 will be replaced by either 1 or 2, 4 will be replaced by 3, 4, or 5.
	 * @param	randomLambda	A custom randomizer function, should return value between 0.0 and 1.0. Initialize your random seed before passing this in! If not defined, will default to unseeded Math.random() calls.
	 */
	public function setCustomTileMappings(mappings:Array<Int>, ?randomIndices:Array<Int>, ?randomChoices:Array<Array<Int>>, ?randomLambda:Void->Float):Void
	{
		customTileRemap = mappings;
		_randomIndices = randomIndices;
		_randomChoices = randomChoices;
		_randomLambda = randomLambda;
		
		// make sure users provide all that data required if they wish to randomize tile mappings.
		if (_randomIndices != null && (_randomChoices == null || _randomChoices.length == 0))
		{
			throw "You must provide valid 'randomChoices' if you wish to randomize tilemap indicies, please read documentation of 'setCustomTileMappings' function.";
		}
	}
	
	/**
	 * Check the value of a particular tile.
	 * 
	 * @param	X		The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y		The Y coordinate of the tile (in tiles, not pixels).
	 * @return	An integer containing the value of the tile at this spot in the array.
	 */
	public function getTile(X:Int, Y:Int):Int
	{
		return _data[Y * widthInTiles + X];
	}

	/**
	 * Get the value of a tile in the tilemap by index.
	 * 
	 * @param	Index	The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * @return	An integer containing the value of the tile at this spot in the array.
	 */
	public function getTileByIndex(Index:Int):Int
	{
		return _data[Index];
	}

	/**
	 * Gets the collision flags of tile by index.
	 * 
	 * @param	Index	Tile index returned by getTile or getTileByIndex
	 * @return	The internal collision flag for the requested tile.
	 */
	public function getTileCollisions(Index:Int):Int
	{
		return _tileObjects[Index].allowCollisions;
	}

	/**
	 * Returns a new array full of every map index of the requested tile type.
	 * 
	 * @param	Index	The requested tile type.
	 * @return	An Array with a list of all map indices of that tile type.
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
			updateTile(_data[Index]);
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
					updateTile(_data[i]);
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
	 * @param	AllowCollisions		Modify the tile or tiles to only allow collisions from certain directions, use FlxObject constants NONE, ANY, LEFT, RIGHT, etc. Default is "ANY".
	 * @param	Callback			The function to trigger, e.g. lavaCallback(Tile:FlxObject, Object:FlxObject).
	 * @param	CallbackFilter		If you only want the callback to go off for certain classes or objects based on a certain class, set that class here.
	 * @param	Range				If you want this callback to work for a bunch of different tiles, input the range here. Default value is 1.
	 */
	public function setTileProperties(Tile:Int, AllowCollisions:Int = FlxObject.ANY, ?Callback:FlxObject->FlxObject->Void, ?CallbackFilter:Class<FlxObject>, Range:Int = 1):Void
	{
		if (Range <= 0)
		{
			Range = 1;
		}
		
		var tile:Tile;
		var i:Int = Tile;
		var l:Int = Tile + Range;
		
		var maxIndex = _tileObjects.length;
		if (l > maxIndex) 
		{
			throw 'Index $l exceeds the maximum tile index of $maxIndex. Please verfiy the Tile ($Tile) and Range ($Range) parameters.';
		}
		
		while (i < l)
		{
			tile = _tileObjects[i++];
			tile.allowCollisions = AllowCollisions;
			(cast tile).callbackFunction = Callback;
			(cast tile).filter = CallbackFilter;
		}
	}

	/**
	 * Fetches the tilemap data array.
	 * 
	 * @param   Simple   If true, returns the data as copy, as a series of 1s and 0s (useful for auto-tiling stuff).
	 *                   Default value is false, meaning it will return the actual data array (NOT a copy).
	 * @return  An array the size of the tilemap full of integers indicating tile placement.
	 */
	public function getData(Simple:Bool = false):Array<Int>
	{
		if (!Simple)
		{
			return _data;
		}
		
		var i:Int = 0;
		var l:Int = _data.length;
		var data:Array<Int> = new Array();
		FlxArrayUtil.setLength(data, l);
		
		while (i < l)
		{
			data[i] = (_tileObjects[_data[i]].allowCollisions > 0) ? 1 : 0;
			i++;
		}
		
		return data;
	}

	/**
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 * 
	 * @param	Start		The start point in world coordinates.
	 * @param	End			The end point in world coordinates.
	 * @param	Simplify	Whether to run a basic simplification algorithm over the path data, removing extra points that are on the same line.  Default value is true.
	 * @param	RaySimplify	Whether to run an extra raycasting simplification algorithm over the remaining path data.  This can result in some close corners being cut, and should be used with care if at all (yet).  Default value is false.
	 * @param	DiagonalPolicy	How to treat diagonal movement. (Default is WIDE, count +1 tile for diagonal movement)
	 * @return	An Array of FlxPoints, containing all waypoints from the start to the end.  If no path could be found, then a null reference is returned.
	 */
	public function findPath(Start:FlxPoint, End:FlxPoint, Simplify:Bool = true, RaySimplify:Bool = false, DiagonalPolicy:FlxTilemapDiagonalPolicy = WIDE):Array<FlxPoint>
	{
		// Figure out what tile we are starting and ending on.
		var startIndex:Int = getTileIndexByCoords(Start);
		var endIndex:Int = getTileIndexByCoords(End);

		// Check that the start and end are clear.
		if ((_tileObjects[_data[startIndex]].allowCollisions > 0) || (_tileObjects[_data[endIndex]].allowCollisions > 0))
		{
			return null;
		}
		
		// Figure out how far each of the tiles is from the starting tile
		var distances:Array<Int> = computePathDistance(startIndex, endIndex, DiagonalPolicy);
		
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
		node.copyFrom(Start);
		node = points[0];
		node.copyFrom(End);

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
		var path:Array<FlxPoint> = [];
		var i:Int = points.length - 1;
		
		while (i >= 0)
		{
			node = points[i--];
			
			if (node != null)
			{
				path.push(node);
			}
		}
		
		return path;
	}
	
	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic! It's pretty brute.
	 * 
	 * @param	StartIndex		The starting tile's map index.
	 * @param	EndIndex		The ending tile's map index.
	 * @param	DiagonalPolicy	How to treat diagonal movement.
	 * @param	StopOnEnd		Whether to stop at the end or not (default true)
	 * @return	A Flash Array of FlxPoint nodes.  If the end tile could not be found, then a null Array is returned instead.
	 */
	public function computePathDistance(StartIndex:Int, EndIndex:Int, DiagonalPolicy:FlxTilemapDiagonalPolicy, StopOnEnd:Bool = true):Array<Int>
	{
		// Create a distance-based representation of the tilemap.
		// All walls are flagged as -2, all open areas as -1.
		var mapSize:Int = widthInTiles * heightInTiles;
		var distances:Array<Int> = new Array<Int>(/*mapSize*/);
		FlxArrayUtil.setLength(distances, mapSize);
		var i:Int = 0;
		
		while (i < mapSize)
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
		
		while (neighbors.length > 0)
		{
			current = neighbors;
			neighbors = new Array<Int>();
			
			i = 0;
			currentLength = current.length;
			while (i < currentLength)
			{
				currentIndex = current[i++];
				
				if (currentIndex == Std.int(EndIndex))
				{
					foundEnd = true;
					if (StopOnEnd)
					{
						neighbors = [];
						break;
					}
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
				
				if (DiagonalPolicy != NONE)
				{
					var WideDiagonal = DiagonalPolicy == WIDE;
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
	 * @param	Data	A Flash Array of distance information.
	 * @param	Start	The tile we're on in our walk backward.
	 * @param	Points	A Flash Array of FlxPoint nodes composing the path from the start to the end, compiled in reverse order.
	 */
	private function walkPath(Data:Array<Int>, Start:Int, Points:Array<FlxPoint>):Void
	{
		Points.push(getTileCoordsByIndex(Start));
		
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
	 * Pathfinding helper function, strips out extra points on the same line.
	 * 
	 * @param	Points		An array of FlxPoint nodes.
	 */
	private function simplifyPath(Points:Array<FlxPoint>):Void
	{
		var deltaPrevious:Float;
		var deltaNext:Float;
		var last:FlxPoint = Points[0];
		var node:FlxPoint;
		var i:Int = 1;
		var l:Int = Points.length - 1;
		
		while (i < l)
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
	 * @param	Points		An array of FlxPoint nodes.
	 */
	private function raySimplifyPath(Points:Array<FlxPoint>):Void
	{
		var source:FlxPoint = Points[0];
		var lastIndex:Int = -1;
		var node:FlxPoint;
		var i:Int = 1;
		var l:Int = Points.length;
		
		while (i < l)
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
	 * Checks to see if some FlxObject overlaps this FlxObject object in world space.
	 * If the group has a LOT of things in it, it might be faster to use FlxG.overlaps().
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * 
	 * @param	Object			The object being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	override public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(tilemapOverlapsCallback, group, 0, 0, InScreenSpace, Camera);
		}
		else if (tilemapOverlapsCallback(ObjectOrGroup))
		{
			return true;
		}
		return false;
	}
	
	private inline function tilemapOverlapsCallback(ObjectOrGroup:FlxBasic, X:Float = 0, Y:Float = 0, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (ObjectOrGroup.flixelType == OBJECT || ObjectOrGroup.flixelType == TILEMAP)
		{
			return overlapsWithCallback(cast ObjectOrGroup);
		}
		else 
		{
			return overlaps(ObjectOrGroup, InScreenSpace, Camera);
		}
	}

	/**
	 * Checks to see if this FlxObject were located at the given position, would it overlap the FlxObject or FlxGroup?
	 * This is distinct from overlapsPoint(), which just checks that point, rather than taking the object's size into account.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks! 
	 * 
	 * @param	X				The X position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	Y				The Y position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	override public function overlapsAt(X:Float, Y:Float, ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(tilemapOverlapsAtCallback, group, X, Y, InScreenSpace, Camera);
		}
		else if (tilemapOverlapsAtCallback(ObjectOrGroup, X, Y, InScreenSpace, Camera))
		{
			return true;
		}

		return false;
	}
	
	private inline function tilemapOverlapsAtCallback(ObjectOrGroup:FlxBasic, X:Float, Y:Float, InScreenSpace:Bool, Camera:FlxCamera):Bool
	{
		if (ObjectOrGroup.flixelType == OBJECT || 
		    ObjectOrGroup.flixelType == TILEMAP)
		{
			return overlapsWithCallback(cast ObjectOrGroup, null, false, _point.set(X, Y));
		}
		else 
		{
			return overlapsAt(X, Y, ObjectOrGroup, InScreenSpace, Camera);
		}
	}

	/**
	 * Checks to see if a point in 2D world space overlaps this FlxObject object.
	 * 
	 * @param	WorldPoint		The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	override public function overlapsPoint(WorldPoint:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (!InScreenSpace)
		{
			return _tileObjects[_data[getTileIndexByCoords(WorldPoint)]].allowCollisions > 0;
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		WorldPoint.subtractPoint(Camera.scroll);
		
		var result:Bool =  _tileObjects[_data[getTileIndexByCoords(WorldPoint)]].allowCollisions > 0;
		WorldPoint.putWeak();
		return result;
	}

	/**
	 * Get the world coordinates and size of the entire tilemap as a FlxRect.
	 * 
	 * @param	Bounds		Optional, pass in a pre-existing FlxRect to prevent instantiation of a new object.
	 * @return	A FlxRect containing the world coordinates and size of the entire tilemap.
	 */
	public function getBounds(?Bounds:FlxRect):FlxRect
	{
		if (Bounds == null)
		{
			Bounds = FlxRect.get();
		}
		
		return Bounds.set(x, y, width, height);
	}
}

enum FlxTilemapAutoTiling
{
	OFF;
	/**
	 * Good for levels with thin walls that don't need interior corner art.
	 */
	AUTO;
	/**
	 * Better for levels with thick walls that look better with interior corner art.
	 */
	ALT;
}

@:enum
abstract FlxTilemapDiagonalPolicy(Int)
{
	/**
	 * No diagonal movement allowed when calculating the path
	 */
	var NONE = 0;
	/**
	 * Diagonal movement costs the same as orthogonal movement
	 */
	var NORMAL = 1;
	/**
	 * Diagonal movement costs one more than orthogonal movement
	 */
	var WIDE = 2;
}