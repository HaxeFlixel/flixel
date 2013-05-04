package org.flixel.system.layer.frames;

import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.system.layer.DrawStackItem;
import org.flixel.system.layer.TileSheetData;
import org.flixel.system.layer.TileSheetExt;
import org.flixel.tweens.misc.NumTween;

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
	
	public var additionalAngle:Float;
	
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
	
	public function getBitmap():BitmapData
	{
		if (_bitmapData != null)
		{
			return _bitmapData;
		}
		
		_bitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxG.TRANSPARENT);
		
		if (rotated)
		{
			// TODO: fix this for non-square sprites
			MATRIX.identity();
			MATRIX.translate(-sourceSize.x * 0.5, -sourceSize.y * 0.5);
			MATRIX.rotate(-90.0 * FlxG.RAD);
			MATRIX.translate(sourceSize.x * 0.5, sourceSize.y * 0.5);
			MATRIX.translate(offset.x, offset.y);
			
			var r:Rectangle = new Rectangle(frame.x, frame.y, frame.width + offset.x, frame.height + offset.y);
			_bitmapData.draw(_tileSheet.tileSheet.nmeBitmap, MATRIX, null, null, r, false);
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
		// TODO: implement this
		return null;
	}
	
	public function pixelsOverlapPoint():Bool
	{
		// TODO: implement this
		return false;
	}
}