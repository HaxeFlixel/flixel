package flixel.system.layer;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxDestroyUtil;
import openfl.display.Tilesheet;

class TileSheetExt extends Tilesheet implements IFlxDestroyable
{
	public static var _DRAWCALLS:Int = 0;
	
	public var numTiles:Int = 0;
	
	public var tileIDs:Map<String, RectPointTileID>;
	public var tileOrder:Array<String>;
	
	public function new(bitmap:BitmapData)
	{
		super(bitmap);
		
		tileIDs = new Map<String, RectPointTileID>();
		tileOrder = new Array<String>();
	}
	
	public function rebuildFromOld(old:TileSheetExt):Void
	{
		for (i in 0...(old.tileOrder.length))
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
		FlxDestroyUtil.destroy(old);
	}
	
	/**
	 * Hashing Functionality (TODO: use numbers as Map keys):
	 * 
	 * http://stackoverflow.com/questions/892618/create-a-hashcode-of-two-numbers
	 * http://stackoverflow.com/questions/299304/why-does-javas-hashcode-in-string-use-31-as-a-multiplier
	*/
	private function getKey(rect:Rectangle, ?point:Point):String
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
	public function addTileRectID(rect:Rectangle, ?point:Point):Int
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
		tileOrder = null;
		if (tileIDs != null)
		{
			for (tileObj in tileIDs)
			{
				FlxDestroyUtil.destroy(tileObj);
			}
		}
		tileIDs = null;
	}
}

private class RectPointTileID implements IFlxDestroyable
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
