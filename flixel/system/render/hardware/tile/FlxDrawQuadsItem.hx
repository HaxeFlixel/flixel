package flixel.system.render.hardware.tile;

import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawBaseItem;
import flixel.system.render.hardware.FlxHardwareView;
import openfl.display.Tilesheet;
import openfl.geom.ColorTransform;

class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
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
	
	override public function destroy():Void
	{
		super.destroy();
		drawData = null;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		setNext(matrix.tx);
		setNext(matrix.ty);
		
		var rect:FlxRect = frame.frame;
		
		setNext(rect.x);
		setNext(rect.y);
		setNext(rect.width);
		setNext(rect.height);

		setNext(matrix.a);
		setNext(matrix.b);
		setNext(matrix.c);
		setNext(matrix.d);

		if (colored && transform != null)
		{
			setNext(transform.redMultiplier);
			setNext(transform.greenMultiplier);
			setNext(transform.blueMultiplier);
		}

		setNext(transform != null ? transform.alphaMultiplier : 1.0);

		#if (!openfl_legacy && openfl >= "3.6.0")
		if (hasColorOffsets && transform != null)
		{
			setNext(transform.redOffset);
			setNext(transform.greenOffset);
			setNext(transform.blueOffset);
			setNext(transform.alphaOffset);
		}
		#end
	}
	
	private inline function setNext(f:Float):Void
	{
		drawData[position++] = f;
	}
	
	override public function render(view:FlxHardwareView):Void
	{
		if (!FlxG.renderTile || position <= 0)
			return;
		
		var flags:Int = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RECT | Tilesheet.TILE_ALPHA;
		
		if (colored)
			flags |= Tilesheet.TILE_RGB;
		
		#if (!openfl_legacy && openfl >= "3.6.0")
		if (hasColorOffsets)
			flags |= Tilesheet.TILE_TRANS_COLOR;
		#end
		
		flags |= FlxDrawBaseItem.blendToInt(blending);
		
		view.canvas.graphics.drawTiles(graphics.tilesheet, drawData,
			(view.antialiasing || antialiasing), flags,
			#if (!openfl_legacy && openfl >= "3.3.9") shader, #end
			position);
		
		FlxCameraView._DRAWCALLS++;
	}
	
	private function get_numTiles():Int
	{
		return Std.int(position / elementsPerTile);
	}
	
	override function get_elementsPerTile():Int 
	{
		var elementsPerTile:Int = 8; // x, y, id, trans (4 elements) and alpha
		if (colored)
			elementsPerTile += 3; // r, g, b
		#if (!openfl_legacy && openfl >= "3.6.0")
		if (hasColorOffsets)
			elementsPerTile += 4; // r, g, b, a
		#end
		
		return elementsPerTile;
	}
	
	override private function get_numVertices():Int
	{
		return FlxCameraView.VERTICES_PER_TILE * numTiles; 
	}
	
	override private function get_numTriangles():Int
	{
		return 2 * numTiles;
	}
}