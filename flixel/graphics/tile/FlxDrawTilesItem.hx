package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import openfl.display.Tilesheet;
import openfl.geom.ColorTransform;

class FlxDrawTilesItem extends FlxDrawBaseItem<FlxDrawTilesItem>
{
	public var drawData:Array<Float> = [];
	public var position:Int = 0;
	public var numTiles(get, never):Int;
	
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
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		drawData[position++] = matrix.tx;
		drawData[position++] = matrix.ty;
		
		var rect:FlxRect = frame.frame;
		
		drawData[position++] = rect.x;
		drawData[position++] = rect.y;
		drawData[position++] = rect.width;
		drawData[position++] = rect.height;
		
		drawData[position++] = matrix.a;
		drawData[position++] = matrix.b;
		drawData[position++] = matrix.c;
		drawData[position++] = matrix.d;
		
		if (colored && transform != null)
		{
			drawData[position++] = transform.redMultiplier; 
			drawData[position++] = transform.greenMultiplier;
			drawData[position++] = transform.blueMultiplier;
		}
		
		drawData[position++] = transform != null ? transform.alphaMultiplier : 1.0;
		
		#if (!openfl_legacy && openfl >= "3.6.0")
		if (hasColorOffsets && transform != null)
		{
			drawData[position++] = transform.redOffset;
			drawData[position++] = transform.greenOffset;
			drawData[position++] = transform.blueOffset;
			drawData[position++] = transform.alphaOffset;
		}
		#end
	}
	
	override public function render(camera:FlxCamera):Void
	{
		if (!FlxG.renderTile)
			return;
		
		if (position > 0)
		{
			var tempFlags:Int = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RECT | Tilesheet.TILE_ALPHA;
			
			if (colored)
			{
				tempFlags |= Tilesheet.TILE_RGB;
			}
			
			#if (!openfl_legacy && openfl >= "3.6.0")
			if (hasColorOffsets)
			{
				tempFlags |= Tilesheet.TILE_TRANS_COLOR;
			}
			#end
			
			tempFlags |= blending;
			graphics.tilesheet.drawTiles(camera.canvas.graphics, drawData, (camera.antialiasing || antialiasing), tempFlags, position);
			FlxTilesheet._DRAWCALLS++;
		}
	}
	
	private function get_numTiles():Int
	{
		var elementsPerTile:Int = 8; // x, y, id, trans (4 elements) and alpha
		if (colored)
		{
			elementsPerTile += 3;	// r, g, b
		}
		
		return Std.int(position / elementsPerTile);
	}
	
	override private function get_numVertices():Int
	{
		return 4 * numTiles;
	}
	
	override private function get_numTriangles():Int
	{
		return 2 * numTiles;
	}
}