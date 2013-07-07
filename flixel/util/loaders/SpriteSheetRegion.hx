package flixel.util.loaders;

import flash.display.BitmapData;

class SpriteSheetRegion
{
	public var bitmap:BitmapData;
	
	public var startX:Int;
	public var startY:Int;
	
	public var width:Int;
	public var height:Int;
	
	public var tileWidth:Int;
	public var tileHeight:Int;
	
	public var spacingX:Int;
	public var spacingY:Int;
	
	public function new(bitmap:BitmapData, startX:Int = 0, startY:Int = 0, tileWidth:Int = 0, tileHeight:Int = 0, spacingX:Int = 0, spacingY:Int = 0, width:Int = 0, height:Int = 0) 
	{ 
		this.bitmap = bitmap;
		
		this.startX = startX;
		this.startY = startY;
		
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		
		this.spacingX = spacingX;
		this.spacingY = spacingY;
		
		this.width = (width == 0) ? bitmap.width : width;
		this.height = (height == 0) ? bitmap.height : height;
	}
	
	public function destroy():Void
	{
		bitmap = null;
	}
}