package org.flixel.system.layer.frames;

import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;

class TexturePackerFrame extends FlxFrame
{
	public static var MATRIX:Matrix = new Matrix();
	
	public var rotated:Bool = false;
	public var trimmed:Bool = false;
	public var sourceSize:FlxPoint = null;
	public var offset:FlxPoint = null;
	
	public function new()
	{
		super();
	}
	
	override public function destroy():Void 
	{
		sourceSize = null;
		offset = null;
		
		super.destroy();
	}
	
	// TODO: test this
	override public function getBitmap():BitmapData 
	{
		if (_bitmapData != null)
		{
			return _bitmapData;
		}
		
		_bitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxG.TRANSPARENT);
		
		if (rotated)
		{
			MATRIX.identity();
			MATRIX.translate(-source.width * 0.5, -source.height * 0.5);
			MATRIX.rotate(-90.0 * FlxG.RAD);
			MATRIX.translate(source.width * 0.5, source.height * 0.5);
			MATRIX.translate(offset.x, offset.y);
			
			var r:Rectangle = new Rectangle(frame.x, frame.y, frame.width + offset.x, frame.height + offset.y);
			_bitmapData.draw(_tileSheet.tileSheet.nmeBitmap, MATRIX, null, null, r, false);
		}
		else
		{
			POINT.x = offset.x;
			POINT.y = offset.y;
			_bitmapData.copyPixels(_tileSheet.tileSheet.nmeBitmap, frame, POINT);
		}
		
		return _bitmapData;
	}
	
	// TODO: implement this
	override public function prepare():Void 
	{
		super.prepare();
	}
}