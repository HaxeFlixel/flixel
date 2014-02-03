package flixel.system.layer.frames;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.system.layer.TileSheetData;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

class FlxFrame
{
	public static var POINT:Point = new Point();
	public static var MATRIX:Matrix = new Matrix();
	
	public var name:String;
	public var frame:Rectangle;
	
	public var rotated:Bool = false;
	public var trimmed:Bool = false;
	
	public var tileID:Int = -1;
	public var additionalAngle:Float = 0;
	
	public var sourceSize(default, null):FlxPoint;
	public var offset(default, null):FlxPoint;
	public var center(default, null):FlxPoint;
	
	private var _bitmapData:BitmapData;
	private var _hReversedBitmapData:BitmapData;
	private var _vReversedBitmapData:BitmapData;
	private var _hvReversedBitmapData:BitmapData;
	private var _tileSheet:TileSheetData;
	
	public function new(tileSheet:TileSheetData)
	{
		_tileSheet = tileSheet;
		additionalAngle = 0;
		
		sourceSize = new FlxPoint();
		offset = new FlxPoint();
		center = new FlxPoint();
	}
	
	public function getBitmap():BitmapData
	{
		if (_bitmapData != null)
		{
			return _bitmapData;
		}
		
		_bitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		
		if (rotated)
		{
			var temp:BitmapData = new BitmapData(Std.int(frame.width), Std.int(frame.height), true, FlxColor.TRANSPARENT);
			FlxFrame.POINT.x = FlxFrame.POINT.y = 0;
			temp.copyPixels(_tileSheet.bitmap, frame, FlxFrame.POINT);
			
			MATRIX.identity();
			MATRIX.translate( -0.5 * frame.width, -0.5 * frame.height);
			MATRIX.rotate(-90.0 * FlxAngle.TO_RAD);
			MATRIX.translate(offset.x + 0.5 * frame.height, offset.y + 0.5 * frame.width);
			
			_bitmapData.draw(temp, MATRIX);
			temp.dispose();
		}
		else
		{
			FlxFrame.POINT.x = offset.x;
			FlxFrame.POINT.y = offset.y;
			_bitmapData.copyPixels(_tileSheet.bitmap, frame, FlxFrame.POINT);
		}
		
		return _bitmapData;
	}
	
	public function getHReversedBitmap():BitmapData
	{
		if (_hReversedBitmapData != null)
		{
			return _hReversedBitmapData;
		}
		
		var normalFrame:BitmapData = getBitmap();
		MATRIX.identity();
		MATRIX.scale( -1, 1);
		MATRIX.translate(Std.int(sourceSize.x), 0);
		_hReversedBitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		_hReversedBitmapData.draw(normalFrame, MATRIX);
		
		return _hReversedBitmapData;
	}
	
	public function getVReversedBitmap():BitmapData
	{
		if (_vReversedBitmapData != null)
		{
			return _vReversedBitmapData;
		}
		
		var normalFrame:BitmapData = getBitmap();
		MATRIX.identity();
		MATRIX.scale(1, -1);
		MATRIX.translate(0, Std.int(sourceSize.y));
		_vReversedBitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		_vReversedBitmapData.draw(normalFrame, MATRIX);
		
		return _vReversedBitmapData;
	}
	
	public function getHVReversedBitmap():BitmapData
	{
		if (_hvReversedBitmapData != null)
		{
			return _hvReversedBitmapData;
		}
		
		var normalFrame:BitmapData = getBitmap();
		MATRIX.identity();
		MATRIX.scale( -1, -1);
		MATRIX.translate(Std.int(sourceSize.x), Std.int(sourceSize.y));
		_hvReversedBitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		_hvReversedBitmapData.draw(normalFrame, MATRIX);
		
		return _hvReversedBitmapData;
	}
	
	public function destroy():Void
	{
		name = null;
		frame = null;
		
		sourceSize = null;
		offset = null;
		center = null;
		
		_tileSheet = null;
		
		destroyBitmapDatas();
	}
	
	public function destroyBitmapDatas():Void
	{
		if (_bitmapData != null)
		{
			_bitmapData.dispose();
			_bitmapData = null;
		}
		
		if (_hReversedBitmapData != null)
		{
			_hReversedBitmapData.dispose();
			_hReversedBitmapData = null;
		}
		
		if (_vReversedBitmapData != null)
		{
			_vReversedBitmapData.dispose();
			_vReversedBitmapData = null;
		}
		
		if (_hvReversedBitmapData != null)
		{
			_hvReversedBitmapData.dispose();
			_hvReversedBitmapData = null;
		}
	}
}