package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import openfl.geom.ColorTransform;

class FlxDrawTilesItem extends FlxDrawBaseItem<FlxDrawTilesItem>
{
	public var drawData:Array<Float> = [];
	public var position:Int = 0;
	public var numTiles(get, never):Int;
	public var shader:FlxShader;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TILES;
	}
	
	override public function reset():Void
	{
		super.reset();
		position = 0;
		shader = null;
	}
	
	override public function dispose():Void
	{
		super.dispose();
		drawData = null;
		shader = null;
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
	
	override public function render(camera:FlxCamera):Void
	{
		if (!FlxG.renderTile || position <= 0)
			return;
		
		var flags:Int = FlxTilesheet.TILE_TRANS_2x2 | FlxTilesheet.TILE_RECT | FlxTilesheet.TILE_ALPHA;
		
		if (colored)
			flags |= FlxTilesheet.TILE_RGB;
		
		#if (!openfl_legacy && openfl >= "3.6.0")
		if (hasColorOffsets)
			flags |= FlxTilesheet.TILE_TRANS_COLOR;
		#end

		flags |= blending;

		#if !(nme && flash)
		graphics.tilesheet.draw(camera.canvas, drawData,
			(camera.antialiasing || antialiasing), flags,
			#if !openfl_legacy shader, #end
			position);
		#end

		FlxTilesheet._DRAWCALLS++;
	}
	
	private function get_numTiles():Int
	{
		var elementsPerTile:Int = 8; // x, y, id, trans (4 elements) and alpha
		if (colored)
			elementsPerTile += 3; // r, g, b
		#if (!openfl_legacy && openfl >= "3.6.0")
		if (hasColorOffsets)
			elementsPerTile += 4; // r, g, b, a
		#end

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