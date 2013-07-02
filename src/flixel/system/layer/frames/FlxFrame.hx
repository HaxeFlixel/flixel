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
	
	public var name:String = null;
	public var frame:Rectangle = null;
	
	public var rotated:Bool = false;
	public var trimmed:Bool = false;
	public var sourceSize:FlxPoint = null;
	public var offset:FlxPoint = null;
	
	public var tileID:Int = -1;
	
	public var additionalAngle:Float = 0;
	
	private var _bitmapData:BitmapData;
	
	private var _reversedBitmapData:BitmapData;
	
	private var _tileSheet:TileSheetData;
	
	public var center:FlxPoint = null;
	
	public function new(tileSheet:TileSheetData)
	{
		_tileSheet = tileSheet;
		additionalAngle = 0;
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
			temp.copyPixels(_tileSheet.tileSheet.nmeBitmap, frame, FlxFrame.POINT);
			
			MATRIX.identity();
			MATRIX.translate( -0.5 * frame.width, -0.5 * frame.height);
			MATRIX.rotate(-90.0 * FlxAngle.TO_RAD);
			MATRIX.translate(offset.x + 0.5 * frame.height, offset.y + 0.5 * frame.width);
			
			_bitmapData.draw(temp, MATRIX);
		}
		else
		{
			FlxFrame.POINT.x = offset.x;
			FlxFrame.POINT.y = offset.y;
			_bitmapData.copyPixels(_tileSheet.tileSheet.nmeBitmap, frame, FlxFrame.POINT);
		}
		
		return _bitmapData;
	}
	
	public function getReversedBitmap():BitmapData
	{
		if (_reversedBitmapData != null)
		{
			return _reversedBitmapData;
		}
		
		var normalFrame:BitmapData = getBitmap();
		MATRIX.identity();
		MATRIX.scale( -1, 1);
		MATRIX.translate(Std.int(sourceSize.x), 0);
		_reversedBitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		_reversedBitmapData.draw(normalFrame, MATRIX);
		
		return _reversedBitmapData;
	}
	
	public function destroyBitmapDatas():Void
	{
		if (_bitmapData != null)
		{
			_bitmapData.dispose();
			_bitmapData = null;
		}
		
		if (_reversedBitmapData != null)
		{
			_reversedBitmapData.dispose();
			_reversedBitmapData = null;
		}
	}
}