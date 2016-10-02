package flixel.system.render.hardware.gl;

import openfl.geom.ColorTransform;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.util.FlxColor;

import lime.utils.Float32Array;
import lime.utils.Int16Array;

// TODO: add culling support???
// gl.enable(gl.CULL_FACE);
// gl.cullFace(gl.FRONT);

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawHardwareItem<FlxDrawTrianglesItem>
{
	public var numTiles:Int = 0;
	
	public function new()
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
	}
	
	#if !flash
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		addUVQuad(frame.frame, frame.uv, matrix, transform);
	}
	
	override public function addUVQuad(rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		ensureElement(FlxCameraView.ELEMENTS_PER_TEXTURED_TILE, FlxCameraView.INDICES_PER_TILE);
		var prevVerticesNumber:Int = numVertices;
		
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
		
		indexes[indexPos++] = prevVerticesNumber + 0;
		indexes[indexPos++] = prevVerticesNumber + 1;
		indexes[indexPos++] = prevVerticesNumber + 2;
		indexes[indexPos++] = prevVerticesNumber + 2;
		indexes[indexPos++] = prevVerticesNumber + 1;
		indexes[indexPos++] = prevVerticesNumber + 3;
		
		vertexBufferDirty = true;
		indexBufferDirty = true;
	}
	
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var numVerticesToAdd:Int = Std.int(vertices.length / 2);
		
		var numIndexesToAdd:Int = numVerticesToAdd;
		var indexed:Bool = false;
		
		if (indices != null)
		{
			numIndexesToAdd = indices.length;
			indexed = true;
		}
		
		var prevVerticesNumber:Int = numVertices;
		
		ensureElement(numVerticesToAdd * FlxCameraView.ELEMENTS_PER_TEXTURED_VERTEX, numIndexesToAdd);
		
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
		
		var numUVCoordsPerVertex:Int = (Std.int(uvData.length / 3) == Std.int(vertices.length / 2)) ? 3 : 2;
		
		var x:Float, y:Float;
		for (i in 0...numVerticesToAdd)
		{
			x = vertices[i * 2];
			y = vertices[i * 2 + 1];
			
			addTexturedVertexData(	matrix.__transformX(x, y), matrix.__transformY(x, y),
									uvData[i * numUVCoordsPerVertex], uvData[i * numUVCoordsPerVertex + 1],
									r, g, b, a);
		}
		
		if (indexed)
		{
			for (i in 0...numIndexesToAdd)
			{
				indexes[indexPos++] = prevVerticesNumber + indices[i];
			}
		}
		else
		{
			for (i in 0...numIndexesToAdd)
			{
				indexes[indexPos++] = prevVerticesNumber + i;
			}
		}
		
		vertexBufferDirty = true;
		indexBufferDirty = true;
	}
	
	private function ensureElement(vertexPosToAdd:Int, indexPosToAdd:Int):Void
	{
		var newBufferLength:Int = vertexPos + vertexPosToAdd;
		var newIndexesLength:Int = indexPos + indexPosToAdd;
		
		if (buffer == null)
		{
			buffer = new Float32Array(newBufferLength);
			indexes = new Int16Array(newIndexesLength);
		}
		else
		{
			var oldBuffer:Float32Array = buffer;
			var oldBubberLength:Int = oldBuffer.length;
			if (newBufferLength >= oldBubberLength)
			{
				buffer = new Float32Array(newBufferLength);
				buffer.set(oldBuffer);
			}
			
			var oldIndexes:Int16Array = indexes;
			var oldIndexesLength:Int = oldIndexes.length;
			if (newIndexesLength >= oldIndexesLength)
			{
				indexes = new Int16Array(newIndexesLength);
				indexes.set(oldIndexes);
			}
		}
	}
	
	#else
	
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform):Void {}
	
	#end
}