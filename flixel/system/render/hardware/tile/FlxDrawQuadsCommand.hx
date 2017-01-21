package flixel.system.render.hardware.tile;

import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawBaseCommand;
import flixel.system.render.hardware.FlxHardwareView;
import flash.display.BlendMode;
import openfl.display.Tilesheet;
import flash.geom.ColorTransform;

class FlxDrawQuadsCommand extends FlxDrawBaseCommand<FlxDrawQuadsCommand>
{
	public var size(default, null):Int = 2000;
	
	public var drawData:Array<Float> = [];
	public var position:Int = 0;
	public var numQuads(get, never):Int;
	public var elementsPerQuad(get, null):Int;
	
	public var canAddQuad(get, null):Bool;
	
	public function new(size:Int = 2000, textured:Bool = true) 
	{
		super();
		
		this.size = size;
		type = FlxDrawItemType.QUADS;
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
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool):Void
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
		
		flags |= FlxDrawBaseCommand.blendToInt(blending);
		
		#if !(nme && flash)
		view.canvas.graphics.drawTiles(graphics.tilesheet, drawData,
			(view.smoothing || smoothing), flags,
			#if !openfl_legacy shader, #end
			position);
		#end
		
		FlxCameraView.drawCalls++;
	}
	
	private function get_canAddQuad():Bool
	{
		return ((numQuads + 1) <= FlxCameraView.QUADS_PER_BATCH);
	}
	
	private function get_numQuads():Int
	{
		return Std.int(position / elementsPerQuad);
	}
	
	private function get_elementsPerQuad():Int 
	{
		var elementsPerQuad:Int = 8; // x, y, id, trans (4 elements) and alpha
		if (colored)
			elementsPerQuad += 3; // r, g, b
		#if (!openfl_legacy && openfl >= "3.6.0")
		if (hasColorOffsets)
			elementsPerQuad += 4; // r, g, b, a
		#end
		
		return elementsPerQuad;
	}
	
	override private function get_numVertices():Int
	{
		return FlxCameraView.VERTICES_PER_QUAD * numQuads; 
	}
	
	override private function get_numTriangles():Int
	{
		return numQuads * FlxCameraView.TRIANGLES_PER_QUAD;
	}
}