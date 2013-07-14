package flixel.util.loaders;

import flash.display.BitmapData;
import flixel.system.frontEnds.BitmapFrontEnd.CachedGraphicsObject;

class SpriteSheetRegion
{
	public var data:CachedGraphicsObject;
	public var region:Region;
	
	public function new(data:CachedGraphicsObject, startX:Int = 0, startY:Int = 0, tileWidth:Int = 0, tileHeight:Int = 0, spacingX:Int = 0, spacingY:Int = 0, width:Int = 0, height:Int = 0) 
	{ 
		this.data = data;
		region = new Region(startX, startY, tileWidth, tileHeight, spacingX, spacingY, width, height);
	}
	
	public function clone():SpriteSheetRegion 
	{
		return new SpriteSheetRegion(data, region.startX, region.startY, region.tileWidth, region.tileHeight, region.spacingX, region.spacingY, region.width, region.height);
	}
	
	public function destroy():Void
	{
		data = null;
		region = null;
	}
}