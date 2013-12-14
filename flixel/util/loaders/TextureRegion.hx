package flixel.util.loaders;

import flash.display.BitmapData;
import flixel.system.layer.Region;

class TextureRegion
{
	public var data:CachedGraphics;
	public var region:Region;
	
	public function new(data:CachedGraphics, startX:Int = 0, startY:Int = 0, tileWidth:Int = 0, tileHeight:Int = 0, spacingX:Int = 0, spacingY:Int = 0, width:Int = 0, height:Int = 0) 
	{ 
		this.data = data;
		
		if (width <= 0)		width = data.bitmap.width;
		if (height <= 0)	height = data.bitmap.height;
		
		region = new Region(startX, startY, tileWidth, tileHeight, spacingX, spacingY, width, height);
	}
	
	public function clone():TextureRegion 
	{
		return new TextureRegion(data, region.startX, region.startY, region.tileWidth, region.tileHeight, region.spacingX, region.spacingY, region.width, region.height);
	}
	
	public function destroy():Void
	{
		data = null;
		region = null;
	}
}