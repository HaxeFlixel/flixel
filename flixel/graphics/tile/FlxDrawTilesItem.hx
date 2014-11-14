package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.Tilesheet;
import openfl.geom.Matrix;

class FlxDrawTilesItem extends FlxDrawBaseItem<FlxDrawTilesItem>
{
	public var drawData:Array<Float> = [];
	public var position:Int = 0;
	
	public var colored:Bool = false;
	public var blending:Int = 0;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TILES;
	}
	
	override public function reset():Void
	{
		super.reset();
		position = 0;
	}
	
	override public function dispose():Void
	{
		super.dispose();
		drawData = null;
	}
	
	public inline function setDrawData(coordinate:FlxPoint, ID:Float, matrix:Matrix,
		isColored:Bool = false, color:FlxColor = FlxColor.WHITE, alpha:Float = 1):Void
	{
		drawData[position++] = coordinate.x;
		drawData[position++] = coordinate.y;
		
		drawData[position++] = ID;
		
		drawData[position++] = matrix.a;
		drawData[position++] = matrix.b;
		drawData[position++] = matrix.c;
		drawData[position++] = matrix.d;
		
		if (isColored)
		{
			drawData[position++] = color.redFloat; 
			drawData[position++] = color.greenFloat;
			drawData[position++] = color.blueFloat;
		}
		
		drawData[position++] = alpha;
		
		coordinate.putWeak();
	}
	
	override public function render(camera:FlxCamera):Void
	{
		var dataLen:Int = drawData.length;
		
		if (position > 0)
		{
			var tempFlags:Int = Tilesheet.TILE_TRANS_2x2;
			tempFlags |= Tilesheet.TILE_ALPHA;
			
			if (colored)
			{
				tempFlags |= Tilesheet.TILE_RGB;
			}
			
			tempFlags |= blending;
			graphics.tilesheet.drawTiles(camera.canvas.graphics, drawData, (camera.antialiasing || antialiasing), tempFlags, position);
			FlxTilesheet._DRAWCALLS++;
		}
	}
}