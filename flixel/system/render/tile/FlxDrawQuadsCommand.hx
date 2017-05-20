package flixel.system.render.tile;

import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxMaterial;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.DrawCommand.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawBaseCommand;
import flash.geom.ColorTransform;

import openfl.display.Tilesheet;

class FlxDrawQuadsCommand extends FlxDrawBaseCommand<FlxDrawQuadsCommand>
{
	public var size(default, null):Int = 2000;
	
	public var drawData:Array<Float> = [];
	public var position:Int = 0;
	public var numQuads(get, never):Int;
	public var elementsPerQuad(get, null):Int;
	
	public var canAddQuad(get, null):Bool;
	
	private var graphic:FlxGraphic;
	
	public function new(textured:Bool = true, size:Int = 0) 
	{
		super();
		
		if (size <= 0)
			size = FlxCameraView.QUADS_PER_BATCH;
		
		this.size = size;
		type = FlxDrawItemType.QUADS;
	}
	
	override public function reset():Void
	{
		super.reset();
		position = 0;
		graphic = null;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		drawData = null;
		graphic = null;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, material:FlxMaterial):Void
	{
		graphic = frame.parent;
		
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
	
	override public function render(view:FlxCameraView):Void
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
		
		flags |= FlxDrawBaseCommand.blendToInt(material.blendMode);
		
		#if !(nme && flash)
		view.canvas.graphics.drawTiles(graphic.tilesheet, drawData,
			(view.smoothing || material.smoothing), flags,
			#if !openfl_legacy shader, #end
			position);
		#end
		
		FlxCameraView.drawCalls++;
	}
	
	private function get_canAddQuad():Bool
	{
		return ((numQuads + 1) <= size);
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