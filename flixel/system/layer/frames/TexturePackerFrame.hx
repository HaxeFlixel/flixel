package flixel.system.layer.frames;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
// TODO: TexturePackerTileSheetData doesn't seem to exist (anymore)?
//import flixel.plugin.texturepacker.TexturePackerTileSheetData;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

class TexturePackerFrame extends FlxFrame
{
	public static var MATRIX:Matrix = new Matrix();
	
	//public function new(tileSheet:TexturePackerTileSheetData)
	//{
		//super(tileSheet);
	//}
	
	override public function destroy():Void 
	{
		sourceSize = null;
		offset = null;
		
		super.destroy();
	}
	
	override public function getBitmap():BitmapData 
	{
		if (_bitmapData != null)
		{
			return _bitmapData;
		}
		
		_bitmapData = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		#if !doc
		if (rotated)
		{
			// TODO: fix this for non-square sprites
			MATRIX.identity();
			MATRIX.translate(-sourceSize.x * 0.5, -sourceSize.y * 0.5);
			MATRIX.rotate(-90.0 * FlxAngle.TO_RAD);
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
		#end
		return _bitmapData;
	}
	
	// TODO: implement this
	//override public function prepare():Void 
	//{
		//super.prepare();
	//}
}