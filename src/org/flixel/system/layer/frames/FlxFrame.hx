package org.flixel.system.layer.frames;

import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.system.layer.TileSheetData;
import org.flixel.system.layer.TileSheetExt;

class FlxFrame
{
	public static var POINT:Point = new Point();
	
	public var name:String = null;
	public var frame:Rectangle = null;
	public var tileID:Int = -1;
	
	private var _bitmapData:BitmapData;
	private var _tileSheet:TileSheetData;
	
	public function new(tileSheet:TileSheetData)
	{
		_tileSheet = tileSheet;
	}
	
	public function destroy():Void
	{
		name = null;
		frame = null;
		_tileSheet = null;
		
		if (_bitmapData != null)
		{
			_bitmapData.dispose();
			_bitmapData = null;
		}
	}
	
	public function prepare():Void
	{
		// TODO: implement this
	}
	
	public function getBitmap():BitmapData
	{
		if (_bitmapData != null)
		{
			return _bitmapData;
		}
		
		_bitmapData = new BitmapData(Std.int(frame.width), Std.int(frame.height), true, FlxG.TRANSPARENT);
		POINT.x = POINT.y = 0;
		_bitmapData.copyPixels(_tileSheet.tileSheet.nmeBitmap, frame, POINT);
		return _bitmapData;
	}
}