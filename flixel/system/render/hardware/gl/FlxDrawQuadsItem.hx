package flixel.system.render.hardware.gl;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.FlxDrawBaseItem;

import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawQuadsItem extends FlxDrawHardwareItem<FlxDrawQuadsItem>
{
	#if !flash
	/** Current amount of filled data in tiles. */
	public var numTiles(get, null):Int;
	/** Overall buffer size */
	public var currentTilesCapacity(get, null):Int;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TILES;
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		if (graphics != null)
			return;
			
		ensureElement();
		
		// Position
		var x :Float = matrix.__transformX(0, 0); // Top-left
		var y :Float = matrix.__transformY(0, 0);
		var x2:Float = matrix.__transformX(rect.width, 0); // Top-right
		var y2:Float = matrix.__transformY(rect.width, 0);
		var x3:Float = matrix.__transformX(0, rect.height); // Bottom-left
		var y3:Float = matrix.__transformY(0, rect.height);
		var x4:Float = matrix.__transformX(rect.width, rect.height); // Bottom-right
		var y4:Float = matrix.__transformY(rect.width, rect.height);
		
		var r:Float = color.redFloat;
		var g:Float = color.greenFloat;
		var b:Float = color.blueFloat;
		var a:Float = alpha;
		
		// Triangle 1, top-left
		addNonTexturedVertexData(x, y, r, g, b, a);
		// Triangle 1, top-right
		addNonTexturedVertexData(x2, y2, r, g, b, a);
		// Triangle 1, bottom-left
		addNonTexturedVertexData(x3, y3, r, g, b, a);
		// Triangle 2, bottom-right
		addNonTexturedVertexData(x4, y4, r, g, b, a);
		
		indexPos += HardwareRenderer.INDICES_PER_TILE;
		vertexBufferDirty = true;
	}
	
	// TODO: implement this methods for other renderers...
	
	public function addUVQuad(rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		ensureElement();
		
		// UV
		var uvx:Float = uv.x;
		var uvy:Float = uv.y;
		var uvx2:Float = uv.width;
		var uvy2:Float = uv.height;
		
		// Position
		var x :Float = matrix.__transformX(0, 0); // Top-left
		var y :Float = matrix.__transformY(0, 0);
		var x2:Float = matrix.__transformX(rect.width, 0); // Top-right
		var y2:Float = matrix.__transformY(rect.width, 0);
		var x3:Float = matrix.__transformX(0, rect.height); // Bottom-left
		var y3:Float = matrix.__transformY(0, rect.height);
		var x4:Float = matrix.__transformX(rect.width, rect.height); // Bottom-right
		var y4:Float = matrix.__transformY(rect.width, rect.height);
		
		var r:Float = 1.0;
		var g:Float = 1.0;
		var b:Float = 1.0;
		var a:Float = 1.0;
		
		if (transform != null)
		{
			if (colored)
			{
				r = transform.redMultiplier;
				g = transform.greenMultiplier;
				b = transform.blueMultiplier;
			}
			
			a = transform.alphaMultiplier;
		}
		
		// Triangle 1, top-left
		addTexturedVertexData(x, y, uvx, uvy, r, g, b, a);
		// Triangle 1, top-right
		addTexturedVertexData(x2, y2, uvx2, uvy, r, g, b, a);
		// Triangle 1, bottom-left
		addTexturedVertexData(x3, y3, uvx, uvy2, r, g, b, a);
		// Triangle 2, bottom-right
		addTexturedVertexData(x4, y4, uvx2, uvy2, r, g, b, a);
		
		indexPos += HardwareRenderer.INDICES_PER_TILE;
		vertexBufferDirty = true;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		addUVQuad(frame.frame, frame.uv, matrix, transform);
	}
	
	private function ensureElement():Void
	{
		if (buffer == null)
		{
			buffer = new Float32Array(HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER * elementsPerTile);
			
			fillIndexBuffer();
		}
		else if (vertexPos >= buffer.length)
		{
			var oldBuffer:Float32Array = buffer;
			var newNumberOfTiles = currentTilesCapacity + HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER;
			
			buffer = new Float32Array(newNumberOfTiles * elementsPerTile);
			buffer.set(oldBuffer);
			
			fillIndexBuffer();
		}
	}
	
	private inline function fillIndexBuffer():Void
	{
		var oldIndexes:UInt32Array = indexes;
		var oldLength:Int = (oldIndexes != null) ? oldIndexes.length : 0;
		
		indexes = new UInt32Array(currentTilesCapacity * HardwareRenderer.INDICES_PER_TILE);
		
		if (oldLength > 0)
		{
			indexes.set(oldIndexes);
		}
		
		var i:Int = oldLength;
		var vertexOffset:Int = Std.int(HardwareRenderer.VERTICES_PER_TILE * oldLength / HardwareRenderer.INDICES_PER_TILE);
		
	//	var i:Int = 0;
	//	var vertexOffset:Int = 0;
	
		while (i < indexes.length)
		{
			indexes[i    ] = vertexOffset;//0;
			indexes[i + 1] = vertexOffset + 1;
			indexes[i + 2] = vertexOffset + 2;
			indexes[i + 3] = vertexOffset + 2;
			indexes[i + 4] = vertexOffset + 1;
			indexes[i + 5] = vertexOffset + 3;
			vertexOffset += HardwareRenderer.VERTICES_PER_TILE;
			i += HardwareRenderer.INDICES_PER_TILE;
		}
		
		indexBufferDirty = true;
	}
	
	// TODO: add methods for adding non-textured quads and triangles...
	
	private function get_numTiles():Int
	{
		return Std.int(vertexPos / elementsPerTile);
	}
	
	private function get_currentTilesCapacity():Int
	{
		return (buffer != null) ? Std.int(buffer.length / elementsPerTile) : 0;
	}
	
	override public function canAddQuad():Bool
	{
		return ((this.numTiles + 1) <= HardwareRenderer.TILES_PER_BATCH);
	}
	
	// TODO: add check if it's possible to add new quad to this item...
	
	#end
}