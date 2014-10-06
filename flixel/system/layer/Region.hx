package flixel.system.layer;

import flash.display.BitmapData;

class Region
{
	public var startX:Int;
	public var startY:Int;
	
	public var width:Int;
	public var height:Int;
	
	public var tileWidth:Int;
	public var tileHeight:Int;
	
	public var spacingX:Int;
	public var spacingY:Int;
	
	public function new(startX:Int = 0, startY:Int = 0, tileWidth:Int = 0, tileHeight:Int = 0, spacingX:Int = 0, spacingY:Int = 0, width:Int = 0, height:Int = 0) 
	{ 
		this.startX = startX;
		this.startY = startY;
		
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		
		this.spacingX = spacingX;
		this.spacingY = spacingY;
		
		this.width = width;
		this.height = height;
	}
	
	public var numTiles(get, null):Int;
	
	private function get_numTiles():Int
	{
		return numRows * numCols;
	}
	
	public var numRows(get, null):Int;
	
	private function get_numRows():Int
	{
		var num:Int = 1;
		
		if (tileHeight != 0)
		{
			num = Std.int((height + spacingY) / (tileHeight + spacingY));
		}
		
		return num;
	}
	
	public var numCols(get, null):Int;
	
	private function get_numCols():Int
	{
		var num:Int = 1;
		
		if (tileWidth != 0)
		{
			num = Std.int((width + spacingX) / (tileWidth + spacingX));
		}
		
		return num;
	}
	
	public function clone():Region 
	{
		return new Region(startX, startY, tileWidth, tileHeight, spacingX, spacingY, width, height);
	}
}