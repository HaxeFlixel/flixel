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
	
	public var numTiles:Int;
	
	public var tileIDs:Map<String, RectPointTileID>;
	public var tileOrder:Array<String>;
	
	private function new(bitmap:BitmapData)
	{
		super(bitmap);
		
		tileIDs = new Map<String, RectPointTileID>();
		tileOrder = new Array<String>();
		numTiles = 0;
	}
	
	// TODO: Check this
	public function buildAfterContextLoss(old:TileSheetExt):Void
	{
		var num:Int = old.tileOrder.length;
		for (i in 0...num)
		{
			var tileName:String = old.tileOrder[i];
			var tileObj:RectPointTileID = old.tileIDs.get(tileName);
			addTileRect(tileObj.rect, tileObj.point);
		}
		
		tileIDs = old.tileIDs;
		tileOrder = old.tileOrder;
		numTiles = old.numTiles;
		
		old.tileIDs = null;
		old.tileOrder = null;
		old.destroy();
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
		
		if (tileIDs.exists(key))
		{
			return tileIDs.get(key).id;
		}
		
		addTileRect(rect, point);
		var tileID:Int = numTiles;
		numTiles++;
		tileOrder[tileID] = key;
		tileIDs.set(key, new RectPointTileID(tileID, rect, point));
		return tileID;
	}
	
	public function destroy():Void
	{
		#if !(flash || js)
		__bitmap = null;
		#else
		nmeBitmap = null;
		#end
		
		tileOrder = null;
		if (tileIDs != null)
		{
			for (tileObj in tileIDs)
			{
				tileObj.destroy();
			}
		}
		tileIDs = null;
	}
	
	#if !(flash || js)
	public var nmeBitmap(get_nmeBitmap, null):BitmapData;
	
	private function get_nmeBitmap():BitmapData
	{
		return __bitmap;
	}
	#end
}

class RectPointTileID
{
	public var rect:Rectangle;
	public var point:Point;
	public var id:Int;
	
	public function new(id, rect, point)
	{
		this.id = id;
		this.rect = rect;
		this.point = point;
	}
	
	public function destroy():Void
	{
		rect = null;
		point = null;
	}
}