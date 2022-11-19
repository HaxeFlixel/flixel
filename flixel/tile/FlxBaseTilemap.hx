package flixel.tile;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.path.FlxPathfinder;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxCollision;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxStringUtil;
import openfl.Assets;
import openfl.display.BitmapData;

using StringTools;

class FlxBaseTilemap<Tile:FlxObject> extends FlxObject
{
	/**
	 * Set this flag to use one of the 16-tile binary auto-tile algorithms (OFF, AUTO, or ALT).
	 */
	public var auto:FlxTilemapAutoTiling = OFF;

	static var offsetAutoTile:Array<Int> = [
		 0,   0, 0, 0,  2,   2, 0,   3, 0, 0, 0, 0,  0,   0, 0,   0,
		11,  11, 0, 0, 13,  13, 0,  14, 0, 0, 0, 0, 18,  18, 0,  19,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		51,  51, 0, 0, 53,  53, 0,  54, 0, 0, 0, 0,  0,   0, 0,   0,
		62,  62, 0, 0, 64,  64, 0,  65, 0, 0, 0, 0, 69,  69, 0,  70,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		86,  86, 0, 0, 88,  88, 0,  89, 0, 0, 0, 0, 93,  93, 0,  94,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		 0, 159, 0, 0,  0, 162, 0, 163, 0, 0, 0, 0,  0,   0, 0,   0,
		 0, 172, 0, 0,  0, 175, 0, 176, 0, 0, 0, 0,  0, 181, 0, 182,
		 0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
		 0, 199, 0, 0,  0, 202, 0, 203, 0, 0, 0, 0,  0, 208, 0, 209
	];
	
	static var diagonalPathfinder = new FlxDiagonalPathfinder();

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
	var _randomIndices:Array<Int>;

	var _randomChoices:Array<Array<Int>>;

	/**
	 * Setting this function allows you to control which choice will be selected for each element within _randomIndices array.
	 * Must return a 0-1 value that gets multiplied by _randomChoices[randIndex].length;
	 */
	var _randomLambda:Void->Float;

	/**
	 * Internal collection of tile objects, one for each type of tile in the map (NOT one for every single tile in the whole map).
	 */
	var _tileObjects:Array<Tile> = [];

	/**
	 * Internal, used to sort of insert blank tiles in front of the tiles in the provided graphic.
	 */
	var _startingIndex:Int = 0;

	/**
	 * Internal representation of the actual tile data, as a large 1D array of integers.
	 */
	var _data:Array<Int>;

	var _drawIndex:Int = 0;
	var _collideIndex:Int = 0;

	/**
	 * Virtual methods, must be implemented in each renderers
	 */
	function updateTile(index:Int):Void
	{
		throw "updateTile must be implemented";
	}

	function cacheGraphics(tileWidth:Int, tileHeight:Int, tileGraphic:FlxTilemapGraphicAsset):Void
	{
		throw "cacheGraphics must be implemented";
	}

	function initTileObjects():Void
	{
		throw "initTileObjects must be implemented";
	}

	function updateMap():Void
	{
		throw "updateMap must be implemented";
	}

	function computeDimensions():Void
	{
		throw "computeDimensions must be implemented";
	}

	public function getTileIndexByCoords(coord:FlxPoint):Int
	{
		throw "getTileIndexByCoords must be implemented";
		return 0;
	}

	public function getTileCoordsByIndex(index:Int, midpoint = true):FlxPoint
	{
		throw "getTileCoordsByIndex must be implemented";
		return null;
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
	public function ray(start:FlxPoint, end:FlxPoint, ?result:FlxPoint):Bool
	{
		throw "ray must be implemented";
		return false;
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
	 *                      Only returned if the line enters the rect.
	 * @param   resolution  Defaults to 1, meaning check every tile or so.  Higher means more checks!
	 * @return  Returns true if the ray made it from Start to End without hitting anything.
	 *          Returns false and fills Result if a tile was hit.
	 */
	public function rayStep(start:FlxPoint, end:FlxPoint, ?result:FlxPoint, resolution:Float = 1):Bool
	{
		throw "rayStep must be implemented?";
		return false;
	}

	/**
	 * Calculates at which point where the given line, from start to end, first enters the tilemap.
	 * If the line starts inside the tilemap, a copy of start is returned.
	 * If the line never enters the tilemap, null is returned.
	 *
	 * Note: If a result vector is supplied and the line is outside the tilemap, null is returned
	 * and the supplied result is unchanged
	 * @since 5.0.0
	 *
	 * @param start   The start of the line
	 * @param end     The end of the line
	 * @param result  Optional result vector, to avoid creating a new instance to be returned.
	 *                Only returned if the line enters the tilemap.
	 * @return The point of entry of the line into the tilemap, if possible.
	 */
	public function calcRayEntry(start, end, ?result)
	{
		var bounds = getBounds();
		// subtract 1 from size otherwise `getTileIndexByCoords` will have weird edge cases (literally)
		bounds.width--;
		bounds.height--;

		return FlxCollision.calcRectEntry(bounds, start, end, result);
	}

	/**
	 * Calculates at which point where the given line, from start to end, was last inside the tilemap.
	 * If the line ends inside the tilemap, a copy of end is returned.
	 * If the line is never inside the tilemap, null is returned.
	 *
	 * Note: If a result vector is supplied and the line is outside the tilemap, null is returned
	 * and the supplied result is unchanged
	 * @since 5.0.0
	 *
	 * @param start   The start of the line
	 * @param end     The end of the line
	 * @param result  Optional result vector, to avoid creating a new instance to be returned.
	 *                Only returned if the line enters the tilemap.
	 * @return The point of exit of the line from the tilemap, if possible.
	 */
	public inline function calcRayExit(start, end, ?result)
	{
		return calcRayEntry(end, start, result);
	}

	public function overlapsWithCallback(object:FlxObject, ?callback:FlxObject->FlxObject->Bool, flipCallbackParams = false, ?position:FlxPoint):Bool
	{
		throw "overlapsWithCallback must be implemented";
		return false;
	}

	public function setDirty(dirty:Bool = true):Void
	{
		throw "setDirty must be implemented";
	}

	function new()
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
	 * @param   mapData         A csv-formatted string indicating what order the tiles should go in (or the path to that file)
	 * @param   tileGraphic     All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param   tileWidth       The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param   tileHeight      The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param   autoTile        Whether to load the map using an automatic tile placement algorithm (requires 16 tiles!).
	 *                          Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param   startingIndex   Used to sort of insert empty tiles in front of the provided graphic.
	 *                          Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param   drawIndex       Initializes all tile objects equal to and after this index as visible.
	 *                          Default value is 1. Ignored if AutoTile is set.
	 * @param   collideIndex    Initializes all tile objects equal to and after this index as allowCollisions = ANY.
	 *                          Default value is 1.  Ignored if AutoTile is set.
	 *                          Can override and customize per-tile-type collision behavior using setTileProperties().
	 * @return  A reference to this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMapFromCSV(mapData:String, tileGraphic:FlxTilemapGraphicAsset, tileWidth = 0, tileHeight = 0, ?autoTile:FlxTilemapAutoTiling,
			startingIndex = 0, drawIndex = 1, collideIndex = 1)
	{
		// path to map data file?
		if (Assets.exists(mapData))
		{
			mapData = Assets.getText(mapData);
		}

		// Figure out the map dimensions based on the data string
		_data = new Array<Int>();
		var columns:Array<String>;

		var regex:EReg = new EReg("[ \t]*((\r\n)|\r|\n)[ \t]*", "g");
		var lines:Array<String> = regex.split(mapData);
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
				// the current tile to be added:
				var columnString = columns[column];
				var curTile = Std.parseInt(columnString);

				if (curTile == null)
					throw 'String in row $row, column $column is not a valid integer: "$columnString"';

				_data.push(curTile);
				column++;
			}

			row++;
		}

		loadMapHelper(tileGraphic, tileWidth, tileHeight, autoTile, startingIndex, drawIndex, collideIndex);
		return this;
	}

	/**
	 * Load the tilemap with string data and a tile graphic.
	 *
	 * @param   mapData         An array containing the (non-negative) tile indices.
	 * @param   widthInTiles    The width of the tilemap in tiles
	 * @param   heightInTiles   The height of the tilemap in tiles
	 * @param   tileGraphic     All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param   tileWidth       The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param   tileHeight      The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param   autoTile        Whether to load the map using an automatic tile placement algorithm (requires 16 tiles!).
	 *                          Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param   startingIndex   Used to sort of insert empty tiles in front of the provided graphic.
	 *                          Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param   drawIndex       Initializes all tile objects equal to and after this index as visible.
	 *                          Default value is 1. Ignored if AutoTile is set.
	 * @param   collideIndex    Initializes all tile objects equal to and after this index as allowCollisions = ANY.
	 *                          Default value is 1.  Ignored if AutoTile is set.
	 *                          Can override and customize per-tile-type collision behavior using setTileProperties().
	 * @return  A reference to this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMapFromArray(mapData:Array<Int>, widthInTiles:Int, heightInTiles:Int, tileGraphic:FlxTilemapGraphicAsset, tileWidth = 0, tileHeight = 0,
			?autoTile:FlxTilemapAutoTiling, startingIndex = 0, drawIndex = 1, collideIndex = 1)
	{
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		_data = mapData.copy(); // make a copy to make sure we don't mess with the original array, which might be used for something!

		loadMapHelper(tileGraphic, tileWidth, tileHeight, autoTile, startingIndex, drawIndex, collideIndex);
		return this;
	}

	/**
	 * Load the tilemap with string data and a tile graphic.
	 *
	 * @param   mapData         A 2D array containing the (non-negative) tile indices. The length of the inner arrays should be consistent.
	 * @param   tileGraphic     All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param   tileWidth       The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param   tileHeight      The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param   autoTile        Whether to load the map using an automatic tile placement algorithm (requires 16 tiles!).
	 *                          Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param   startingIndex   Used to sort of insert empty tiles in front of the provided graphic.
	 *                          Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param   drawIndex       Initializes all tile objects equal to and after this index as visible.
	 *                          Default value is 1. Ignored if AutoTile is set.
	 * @param   collideIndex    Initializes all tile objects equal to and after this index as allowCollisions = ANY.
	 *                          Default value is 1.  Ignored if AutoTile is set.
	 *                          Can override and customize per-tile-type collision behavior using setTileProperties().
	 * @return  A reference to this instance of FlxTilemap, for chaining as usual :)
	 */
	public function loadMapFrom2DArray(mapData:Array<Array<Int>>, tileGraphic:FlxTilemapGraphicAsset, tileWidth = 0, tileHeight = 0,
			?autoTile:FlxTilemapAutoTiling, startingIndex = 0, drawIndex = 1, collideIndex = 1)
	{
		widthInTiles = mapData[0].length;
		heightInTiles = mapData.length;
		_data = FlxArrayUtil.flatten2DArray(mapData);

		loadMapHelper(tileGraphic, tileWidth, tileHeight, autoTile, startingIndex, drawIndex, collideIndex);
		return this;
	}

	/**
	 * Load the tilemap with image data and a tile graphic.
	 * Black pixels are flagged as 'solid' by default, non-black pixels are set as non-colliding. Black pixels must be PURE BLACK.
	 * @param   mapGraphic      The image you want to use as a source of map data, where each pixel is a tile (or more than one tile if you change Scale's default value). Preferably black and white.
	 * @param   invert          Load white pixels as solid instead.
	 * @param   scale           Default is 1. Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @param   colorMap        An array of color values (alpha values are ignored) in the order they're intended to be assigned as indices
	 * @param   tileGraphic     All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param   tileWidth       The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param   tileHeight      The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param   autoTile        Whether to load the map using an automatic tile placement algorithm (requires 16 tiles!).
	 *                          Setting this to either AUTO or ALT will override any values you put for StartingIndex, DrawIndex, or CollideIndex.
	 * @param   startingIndex   Used to sort of insert empty tiles in front of the provided graphic.
	 *                          Default is 0, usually safest ot leave it at that.  Ignored if AutoTile is set.
	 * @param   drawIndex       Initializes all tile objects equal to and after this index as visible.
	 *                          Default value is 1. Ignored if AutoTile is set.
	 * @param   collideIndex    Initializes all tile objects equal to and after this index as allowCollisions = ANY.
	 *                          Default value is 1.  Ignored if AutoTile is set.
	 *                          Can override and customize per-tile-type collision behavior using setTileProperties().
	 * @return  A reference to this instance of FlxTilemap, for chaining as usual :)
	 * @since   4.1.0
	 */
	public function loadMapFromGraphic(mapGraphic:FlxGraphicSource, invert = false, scale = 1, ?colorMap:Array<FlxColor>,
			tileGraphic:FlxTilemapGraphicAsset, tileWidth = 0, tileHeight = 0, ?autoTile:FlxTilemapAutoTiling,
			startingIndex = 0, drawIndex = 1, collideIndex = 1)
	{
		var mapBitmap:BitmapData = FlxAssets.resolveBitmapData(mapGraphic);
		var mapData:String = FlxStringUtil.bitmapToCSV(mapBitmap, invert, scale, colorMap);
		return loadMapFromCSV(mapData, tileGraphic, tileWidth, tileHeight, autoTile, startingIndex, drawIndex, collideIndex);
	}

	function loadMapHelper(tileGraphic:FlxTilemapGraphicAsset, tileWidth = 0, tileHeight = 0, ?autoTile:FlxTilemapAutoTiling,
			startingIndex = 0, drawIndex = 1, collideIndex = 1)
	{
		// anything < 0 should be treated as 0 for compatibility with certain map formats (ogmo)
		for (i in 0..._data.length)
		{
			if (_data[i] < 0)
				_data[i] = 0;
		}

		totalTiles = _data.length;
		auto = (autoTile == null) ? OFF : autoTile;
		_startingIndex = (startingIndex <= 0) ? 0 : startingIndex;

		if (auto != OFF)
		{
			_startingIndex = 1;
			drawIndex = 1;
			collideIndex = 1;
		}

		_drawIndex = drawIndex;
		_collideIndex = collideIndex;

		applyAutoTile();
		applyCustomRemap();
		randomizeIndices();
		cacheGraphics(tileWidth, tileHeight, tileGraphic);
		postGraphicLoad();
	}

	function postGraphicLoad()
	{
		initTileObjects();
		computeDimensions();
		updateMap();
	}

	function applyAutoTile():Void
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

	function applyCustomRemap():Void
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

	function randomizeIndices():Void
	{
		var i:Int = 0;

		if (_randomIndices != null)
		{
			var randLambda:Void->Float = _randomLambda != null ? _randomLambda : function()
			{
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
	 * An internal function used by the binary auto-tilers. (16 tiles)
	 *
	 * @param   index  The index of the tile you want to analyze.
	 */
	function autoTile(index:Int):Void
	{
		if (_data[index] == 0)
		{
			return;
		}

		if (auto == FULL)
		{
			autoTileFull(index);
			return;
		}

		_data[index] = 0;

		// UP
		if ((index - widthInTiles < 0) || (_data[index - widthInTiles] > 0))
		{
			_data[index] += 1;
		}
		// RIGHT
		if ((index % widthInTiles >= widthInTiles - 1) || (_data[index + 1] > 0))
		{
			_data[index] += 2;
		}
		// DOWN
		if ((Std.int(index + widthInTiles) >= totalTiles) || (_data[index + widthInTiles] > 0))
		{
			_data[index] += 4;
		}
		// LEFT
		if ((index % widthInTiles <= 0) || (_data[index - 1] > 0))
		{
			_data[index] += 8;
		}

		// The alternate algo checks for interior corners
		if ((auto == ALT) && (_data[index] == 15))
		{
			// BOTTOM LEFT OPEN
			if ((index % widthInTiles > 0) && (Std.int(index + widthInTiles) < totalTiles) && (_data[index + widthInTiles - 1] <= 0))
			{
				_data[index] = 1;
			}
			// TOP LEFT OPEN
			if ((index % widthInTiles > 0) && (index - widthInTiles >= 0) && (_data[index - widthInTiles - 1] <= 0))
			{
				_data[index] = 2;
			}
			// TOP RIGHT OPEN
			if ((index % widthInTiles < widthInTiles - 1) && (index - widthInTiles >= 0) && (_data[index - widthInTiles + 1] <= 0))
			{
				_data[index] = 4;
			}
			// BOTTOM RIGHT OPEN
			if ((index % widthInTiles < widthInTiles - 1)
				&& (Std.int(index + widthInTiles) < totalTiles)
				&& (_data[index + widthInTiles + 1] <= 0))
			{
				_data[index] = 8;
			}
		}

		_data[index] += 1;
	}

	/**
	 * An internal function used by the binary auto-tilers. (47 tiles)
	 *
	 * @param   index  The index of the tile you want to analyze.
	 */
	function autoTileFull(index:Int):Void
	{
		_data[index] = 0;

		var wallUp:Bool = index - widthInTiles < 0;
		var wallRight:Bool = index % widthInTiles >= widthInTiles - 1;
		var wallDown:Bool = Std.int(index + widthInTiles) >= totalTiles;
		var wallLeft:Bool = index % widthInTiles <= 0;

		var up = wallUp || _data[index - widthInTiles] > 0;
		var upRight = wallUp || wallRight || _data[index - widthInTiles + 1] > 0;
		var right = wallRight || _data[index + 1] > 0;
		var rightDown = wallRight || wallDown || _data[index + widthInTiles + 1] > 0;
		var down = wallDown || _data[index + widthInTiles] > 0;
		var downLeft = wallDown || wallLeft || _data[index + widthInTiles - 1] > 0;
		var left = wallLeft || _data[index - 1] > 0;
		var leftUp = wallLeft || wallUp || _data[index - widthInTiles - 1] > 0;

		if (up)
			_data[index] += 1;
		if (upRight && up && right)
			_data[index] += 2;
		if (right)
			_data[index] += 4;
		if (rightDown && right && down)
			_data[index] += 8;
		if (down)
			_data[index] += 16;
		if (downLeft && down && left)
			_data[index] += 32;
		if (left)
			_data[index] += 64;
		if (leftUp && left && up)
			_data[index] += 128;

		_data[index] -= offsetAutoTile[_data[index]] - 1;
	}

	/**
	 * Set custom tile mapping and/or randomization rules prior to loading. This MUST be called BEFORE loadMap().
	 * WARNING: Using this will cause your maps to take longer to load. Be careful using this in very large tilemaps.
	 *
	 * @param   mappings       Array of ints for remapping tiles. Ex: [7,4,12] means "0-->7, 1-->4, 2-->12"
	 * @param   randomIndices  Array of ints indicating which tile indices should be randomized. Ex: [7,4,12] means "replace tile index of 7, 4, or 12 with a randomized value"
	 * @param   randomChoices  A list of int-arrays that serve as the corresponding choices to randomly choose from. Ex: indices = [7,4], choices = [[1,2],[3,4,5]], 7 will be replaced by either 1 or 2, 4 will be replaced by 3, 4, or 5.
	 * @param   randomLambda   A custom randomizer function, should return value between 0.0 and 1.0. Initialize your random seed before passing this in! If not defined, will default to unseeded Math.random() calls.
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
			throw "You must provide valid 'randomChoices' if you wish to randomize tilemap indices, please read documentation of 'setCustomTileMappings' function.";
		}
	}

	/**
	 * Check the value of a particular tile.
	 *
	 * @param   x  The X coordinate of the tile (in tiles, not pixels).
	 * @param   y  The Y coordinate of the tile (in tiles, not pixels).
	 * @return  An integer containing the value of the tile at this spot in the array.
	 */
	public function getTile(x:Int, y:Int):Int
	{
		return _data[y * widthInTiles + x];
	}

	/**
	 * Get the value of a tile in the tilemap by index.
	 *
	 * @param   index  The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * @return  An integer containing the value of the tile at this spot in the array.
	 */
	public function getTileByIndex(index:Int):Int
	{
		return _data[index];
	}

	/**
	 * Gets the collision flags of tile by index.
	 *
	 * @param   index  Tile index returned by getTile or getTileByIndex
	 * @return  The internal collision flag for the requested tile.
	 */
	public function getTileCollisions(index:Int):FlxDirectionFlags
	{
		return _tileObjects[index].allowCollisions;
	}

	/**
	 * Returns a new array full of every map index of the requested tile type.
	 *
	 * @param   index  The requested tile type.
	 * @return  An Array with a list of all map indices of that tile type.
	 */
	public function getTileInstances(index:Int):Array<Int>
	{
		var array:Array<Int> = null;
		var i:Int = 0;
		var l:Int = widthInTiles * heightInTiles;

		while (i < l)
		{
			if (_data[i] == index)
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
	 * @param   x               The X coordinate of the tile (in tiles, not pixels).
	 * @param   y               The Y coordinate of the tile (in tiles, not pixels).
	 * @param   tile            The new integer data you wish to inject.
	 * @param   updateGraphics  Whether the graphical representation of this tile should change.
	 * @return  Whether or not the tile was actually changed.
	 */
	public function setTile(x:Int, y:Int, tile:Int, updateGraphics = true):Bool
	{
		if ((x >= widthInTiles) || (y >= heightInTiles))
		{
			return false;
		}

		return setTileByIndex(y * widthInTiles + x, tile, updateGraphics);
	}

	/**
	 * Change the data and graphic of a tile in the tilemap.
	 *
	 * @param   index           The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * @param   tile            The new integer data you wish to inject.
	 * @param   updateGraphics  Whether the graphical representation of this tile should change.
	 * @return  Whether or not the tile was actually changed.
	 */
	public function setTileByIndex(index:Int, tile:Int, updateGraphics = true):Bool
	{
		if (index >= _data.length)
		{
			return false;
		}

		var ok:Bool = true;
		_data[index] = tile;

		if (!updateGraphics)
		{
			return ok;
		}

		setDirty();

		if (auto == OFF)
		{
			updateTile(_data[index]);
			return ok;
		}

		// If this map is auto-tiled and it changes, locally update the arrangement
		var i:Int;
		var row:Int = Std.int(index / widthInTiles) - 1;
		var rowLength:Int = row + 3;
		var column:Int = index % widthInTiles - 1;
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
	 * @param   tile             The tile or tiles you want to adjust.
	 * @param   allowCollisions  Modify the tile or tiles to only allow collisions from certain directions, use FlxObject constants NONE, ANY, LEFT, RIGHT, etc. Default is "ANY".
	 * @param   callback         The function to trigger, e.g. lavaCallback(Tile:FlxObject, Object:FlxObject).
	 * @param   callbackFilter   If you only want the callback to go off for certain classes or objects based on a certain class, set that class here.
	 * @param   range            If you want this callback to work for a bunch of different tiles, input the range here. Default value is 1.
	 */
	public function setTileProperties(tile:Int, allowCollisions = ANY, ?callback:FlxObject->FlxObject->Void, ?callbackFilter:Class<FlxObject>, range = 1):Void
	{
		if (range <= 0)
		{
			range = 1;
		}

		var end = tile + range;

		var maxIndex = _tileObjects.length;
		if (end > maxIndex)
		{
			throw 'Index $end exceeds the maximum tile index of $maxIndex. Please verify the Tile ($tile) and Range ($range) parameters.';
		}

		for (i in tile...end)
		{
			var tileData = _tileObjects[i];
			tileData.allowCollisions = allowCollisions;
			(cast tileData).callbackFunction = callback;
			(cast tileData).filter = callbackFilter;
		}
	}

	/**
	 * Fetches the tilemap data array.
	 *
	 * @param   simple   If true, returns the data as copy, as a series of 1s and 0s (useful for auto-tiling stuff).
	 *                   Default value is false, meaning it will return the actual data array (NOT a copy).
	 * @return  An array the size of the tilemap full of integers indicating tile placement.
	 */
	public function getData(simple:Bool = false):Array<Int>
	{
		if (!simple)
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
	 * @param   start           The start point in world coordinates.
	 * @param   end             The end point in world coordinates.
	 * @param   simplify        Whether to run a basic simplification algorithm over the path data, removing
	 *                          extra points that are on the same line.  Default value is true.
	 * @param   raySimplify     Whether to run an extra raycasting simplification algorithm over the remaining
	 *                          path data.  This can result in some close corners being cut, and should be
	 *                          used with care if at all (yet).  Default value is false.
	 * @param   diagonalPolicy  How to treat diagonal movement. (Default is WIDE, count +1 tile for diagonal movement)
	 * @return  An Array of FlxPoints, containing all waypoints from the start to the end.  If no path could be found,
	 *          then a null reference is returned.
	 */
	public inline function findPath(start:FlxPoint, end:FlxPoint, simplify:FlxPathSimplifier = LINE,
			diagonalPolicy:FlxTilemapDiagonalPolicy = WIDE):Array<FlxPoint>
	{
		return getDiagonalPathfinder(diagonalPolicy).findPath(cast this, start, end, simplify);
	}

	/**
	 * Find a path through the tilemap.  Any tile with any collision flags set is treated as impassable.
	 * If no path is discovered then a null reference is returned.
	 * @since 5.0.0
	 *
	 * @param   pathfinder   Decides how to move and evaluate the paths for comparison.
	 * @param   start        The start point in world coordinates.
	 * @param   end          The end point in world coordinates.
	 * @param   simplify     Whether to run a basic simplification algorithm over the path data, removing
	 *                       extra points that are on the same line.  Default value is true.
	 * @param   raySimplify  Whether to run an extra raycasting simplification algorithm over the remaining
	 *                       path data.  This can result in some close corners being cut, and should be
	 *                       used with care if at all (yet).  Default value is false.
	 * @return  An Array of FlxPoints, containing all waypoints from the start to the end.  If no path could be found,
	 *          then a null reference is returned.
	 */
	public inline function findPathCustom(pathfinder:FlxPathfinder, start:FlxPoint, end:FlxPoint,
		simplify:FlxPathSimplifier = LINE):Array<FlxPoint>
	{
		return pathfinder.findPath(cast this, start, end, simplify);
	}

	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic! It's pretty brute.
	 *
	 * @param   startIndex      The starting tile's map index.
	 * @param   endIndex        The ending tile's map index.
	 * @param   diagonalPolicy  How to treat diagonal movement.
	 * @param   stopOnEnd       Whether to stop at the end or not (default true)
	 * @return  An array of FlxPoint nodes. If the end tile could not be found, then a null Array is returned instead.
	 */
	public function computePathDistance(startIndex:Int, endIndex:Int, diagonalPolicy:FlxTilemapDiagonalPolicy = WIDE, stopOnEnd:Bool = true):Array<Int>
	{
		var data = computePathData(startIndex, endIndex, diagonalPolicy, stopOnEnd);
		if (data != null)
			return data.distances;
		
		return null;
	}

	
	/**
	 * Pathfinding helper function, floods a grid with distance information until it finds the end point.
	 * NOTE: Currently this process does NOT use any kind of fancy heuristic! It's pretty brute.
	 * @since 5.0.0
	 *
	 * @param   startIndex  The starting tile's map index.
	 * @param   endIndex    The ending tile's map index.
	 * @param   policy      Decides how to move and evaluate the paths for comparison.
	 * @param   stopOnEnd   Whether to stop at the end or not (default true)
	 * @return  An array of FlxPoint nodes. If the end tile could not be found, then a null Array is returned instead.
	 */
	public function computePathData(startIndex:Int, endIndex:Int, diagonalPolicy:FlxTilemapDiagonalPolicy = WIDE, stopOnEnd:Bool = true):FlxPathfinderData
	{
		return getDiagonalPathfinder(diagonalPolicy).computePathData(cast this, startIndex, endIndex, stopOnEnd);
	}

	inline function getDiagonalPathfinder(diagonalPolicy:FlxTilemapDiagonalPolicy):FlxPathfinder
	{
		diagonalPathfinder.diagonalPolicy = diagonalPolicy;
		return diagonalPathfinder;
	}

	/**
	 * Checks to see if some FlxObject overlaps this FlxObject object in world space.
	 * If the group has a LOT of things in it, it might be faster to use FlxG.overlaps().
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   object         The object being tested.
	 * @param   inScreenSpace  Whether to take scroll factors into account when checking for overlap.
	 * @param   camera         Specify which game camera you want. If null, getScreenPosition() will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	override public function overlaps(objectOrGroup:FlxBasic, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(tilemapOverlapsCallback, group, 0, 0, inScreenSpace, camera);
		}
		else if (tilemapOverlapsCallback(objectOrGroup))
		{
			return true;
		}
		return false;
	}

	inline function tilemapOverlapsCallback(objectOrGroup:FlxBasic, x = 0.0, y = 0.0, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
		if (objectOrGroup.flixelType == OBJECT || objectOrGroup.flixelType == TILEMAP)
		{
			return overlapsWithCallback(cast objectOrGroup);
		}
		else
		{
			return overlaps(objectOrGroup, inScreenSpace, camera);
		}
	}

	/**
	 * Checks to see if this FlxObject were located at the given position, would it overlap the FlxObject or FlxGroup?
	 * This is distinct from overlapsPoint(), which just checks that point, rather than taking the object's size into account.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   x              The X position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param   y              The Y position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param   objectOrGroup  The object or group being tested.
	 * @param   inScreenSpace  Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param   camera         Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	override public function overlapsAt(x:Float, y:Float, objectOrGroup:FlxBasic, inScreenSpace:Bool = false, ?camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(tilemapOverlapsAtCallback, group, x, y, inScreenSpace, camera);
		}
		else if (tilemapOverlapsAtCallback(objectOrGroup, x, y, inScreenSpace, camera))
		{
			return true;
		}

		return false;
	}

	inline function tilemapOverlapsAtCallback(objectOrGroup:FlxBasic, x:Float, y:Float, inScreenSpace:Bool, camera:FlxCamera):Bool
	{
		if (objectOrGroup.flixelType == OBJECT || objectOrGroup.flixelType == TILEMAP)
		{
			return overlapsWithCallback(cast objectOrGroup, null, false, _point.set(x, y));
		}
		else
		{
			return overlapsAt(x, y, objectOrGroup, inScreenSpace, camera);
		}
	}

	/**
	 * Checks to see if a point in 2D world space overlaps this FlxObject object.
	 *
	 * @param   worldPoint     The point in world space you want to check.
	 * @param   inScreenSpace  Whether to take scroll factors into account when checking for overlap.
	 * @param   camera         Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return  Whether or not the point overlaps this object.
	 */
	override public function overlapsPoint(worldPoint:FlxPoint, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
		if (inScreenSpace)
		{
			if (camera == null)
				camera = FlxG.camera;

			worldPoint.subtractPoint(camera.scroll);
			worldPoint.putWeak();
		}

		return tileAtPointAllowsCollisions(worldPoint);
	}

	function tileAtPointAllowsCollisions(point:FlxPoint):Bool
	{
		var tileIndex = getTileIndexByCoords(point);
		if (tileIndex < 0 || tileIndex >= _data.length)
			return false;
		return _tileObjects[_data[tileIndex]].allowCollisions > 0;
	}

	/**
	 * Get the world coordinates and size of the entire tilemap as a FlxRect.
	 *
	 * @param   bounds  Optional, pass in a pre-existing FlxRect to prevent instantiation of a new object.
	 * @return  A FlxRect containing the world coordinates and size of the entire tilemap.
	 */
	public function getBounds(?bounds:FlxRect):FlxRect
	{
		if (bounds == null)
			bounds = FlxRect.get();

		return bounds.set(x, y, width, height);
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

	/**
	 * Better for all, but need 47 tiles.
	 * @since 4.6.0
	 */
	FULL;
}
