package flixel.system.layer.frames;

<<<<<<< HEAD:src/org/flixel/system/layer/frames/FlxFrame.hx
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.system.layer.TileSheetData;
import org.flixel.system.layer.TileSheetExt;
=======
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.system.layer.TileSheetData;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
>>>>>>> origin/dev:flixel/system/layer/frames/FlxFrame.hx

class FlxFrame
{
	public static var POINT:Point = new Point();
	
	public var name:String = null;
	public var frame:Rectangle = null;
	public var tileID:Int = -1;
	
<<<<<<< HEAD:src/org/flixel/system/layer/frames/FlxFrame.hx
=======
	public var additionalAngle:Float = 0;
	
>>>>>>> origin/dev:flixel/system/layer/frames/FlxFrame.hx
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
<<<<<<< HEAD:src/org/flixel/system/layer/frames/FlxFrame.hx
			_bitmapData.dispose();
			_bitmapData = null;
=======
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
>>>>>>> origin/dev:flixel/system/layer/frames/FlxFrame.hx
		}
	}
	
	public function prepare():Void
	{
<<<<<<< HEAD:src/org/flixel/system/layer/frames/FlxFrame.hx
		// TODO: implement this
=======
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
>>>>>>> origin/dev:flixel/system/layer/frames/FlxFrame.hx
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