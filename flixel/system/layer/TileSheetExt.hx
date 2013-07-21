package flixel.system.layer;

<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetExt.hx
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;
=======
=======
>>>>>>> experimental
import haxe.ds.ObjectMap;
import flash.display.BitmapData;
import openfl.display.Tilesheet;
import flash.geom.Point;
import flash.geom.Rectangle;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/layer/TileSheetExt.hx

class TileSheetExt extends Tilesheet
{
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetExt.hx
	private static var _tileSheetCache:Map<BitmapData, TileSheetExt> = new Map<BitmapData, TileSheetExt>();
=======
	private static var _tileSheetCache:ObjectMap<BitmapData, TileSheetExt> = new ObjectMap<BitmapData, TileSheetExt>();
>>>>>>> origin/dev:flixel/system/layer/TileSheetExt.hx
	
=======

class TileSheetExt extends Tilesheet
{
>>>>>>> experimental
	public static var _DRAWCALLS:Int = 0;
	
	public var numTiles:Int;
	
	public var tileIDs:Map<String, RectPointTileID>;
	public var tileOrder:Array<String>;
	
	public function new(bitmap:BitmapData)
	{
		super(bitmap);
		
		tileIDs = new Map<String, RectPointTileID>();
		tileOrder = new Array<String>();
		numTiles = 0;
	}
	
	public function rebuildFromOld(old:TileSheetExt):Void
	{
		var num:Int = old.tileOrder.length;
		for (i in 0...num)
		{
			var tileName:String = old.tileOrder[i];
			var tileObj:RectPointTileID = old.tileIDs.get(tileName);
			addTileRect(tileObj.rect, tileObj.point);
		}
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetExt.hx
=======
		
		_tileSheetCache = new ObjectMap<BitmapData, TileSheetExt>();
>>>>>>> origin/dev:flixel/system/layer/TileSheetExt.hx
	}
	
	private var _numTiles:Int;
	
	private var _tileIDs:Map<String, Int>;
	
	private function new(bitmap:BitmapData)
	{
		super(bitmap);
=======
		
		tileIDs = old.tileIDs;
		tileOrder = old.tileOrder;
		numTiles = old.numTiles;
>>>>>>> experimental
		
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
		__handle = null;
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