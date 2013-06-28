package flixel.system.layer;

import haxe.ds.ObjectMap;
import flash.display.BitmapData;
import openfl.display.Tilesheet;
import flash.geom.Point;
import flash.geom.Rectangle;

// TODO: check image caching for tilesheets and their disposing
class TileSheetExt extends Tilesheet
{
	private static var _tileSheetCache:ObjectMap<BitmapData, TileSheetExt> = new ObjectMap<BitmapData, TileSheetExt>();
	
	public static var _DRAWCALLS:Int = 0;
	
	/**
	 * Adds new tileSheet to manager and returns it
	 * If manager already contains tileSheet with the same bitmapData then it returns this tileSheetData object 
	 */
	public static function addTileSheet(bitmapData:BitmapData):TileSheetExt
	{
		if (containsTileSheet(bitmapData))
		{
			return getTileSheet(bitmapData);
		}
		
		var tempTileSheetData:TileSheetExt = new TileSheetExt(bitmapData);
		_tileSheetCache.set(bitmapData, tempTileSheetData);
		return tempTileSheetData;
	}
	
	public static function containsTileSheet(bitmapData:BitmapData):Bool
	{
		return _tileSheetCache.exists(bitmapData);
	}
	
	public static function getTileSheet(bitmapData:BitmapData):TileSheetExt
	{
		return _tileSheetCache.get(bitmapData);
	}
	
	public static function removeTileSheet(tileSheetObj:TileSheetExt):Void
	{
		var key:BitmapData = tileSheetObj.nmeBitmap;
		if (containsTileSheet(key))
		{
			var temp:TileSheetExt = _tileSheetCache.get(key);
			_tileSheetCache.remove(key);
			temp.destroy();
		}
	}
	
	public static function clear():Void
	{
		for (key in _tileSheetCache.keys())
		{
			if (key != null)
			{
				var temp:TileSheetExt = _tileSheetCache.get(key);
				_tileSheetCache.remove(key);
				temp.destroy();
			}
		}
		
		_tileSheetCache = new ObjectMap<BitmapData, TileSheetExt>();
	}
	
	private var _numTiles:Int;
	
	private var _tileIDs:Map<String, Int>;
	
	private function new(bitmap:BitmapData)
	{
		super(bitmap);
		
		_tileIDs = new Map<String, Int>();
		_numTiles = 0;
	}
	
	private function getKey(rect:Rectangle, point:Point = null):String
	{
		var key:String = rect.x + "_" + rect.y + "_" + rect.width + "_" + rect.height + "_";
		if (point != null)
		{
			key = key + point.x + "_" + point.y;
		}
		return key;
	}
	
	/**
	 * Adds new tileRect to tileSheet object
	 * @return id of added tileRect
	 */
	public function addTileRectID(rect:Rectangle, point:Point = null):Int
	{
		var key:String = getKey(rect, point);
		
		if (_tileIDs.exists(key))
		{
			return _tileIDs.get(key);
		}
		
		addTileRect(rect, point);
		var tileID:Int = _numTiles;
		_numTiles++;
		_tileIDs.set(key, tileID);
		return tileID;
	}
	
	public function destroy():Void
	{
		#if !(flash || js)
		__bitmap = null;
		#else
		nmeBitmap = null;
		#end
		_tileIDs = null;
	}
	
	#if !(flash || js)
	public var nmeBitmap(get_nmeBitmap, null):BitmapData;
	
	private function get_nmeBitmap():BitmapData
	{
		return __bitmap;
	}
	#end
}