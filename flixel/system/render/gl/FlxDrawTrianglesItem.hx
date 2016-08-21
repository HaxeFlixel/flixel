package flixel.system.render.gl;

import flixel.util.FlxColor;
import openfl.geom.ColorTransform;
import flixel.math.FlxMatrix;

import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.system.render.common.FlxDrawBaseItem;

import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;

// TODO: add culling support???
// gl.enable(gl.CULL_FACE);
// gl.cullFace(gl.FRONT);

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawHardwareItem<FlxDrawTrianglesItem>
{

	public function new() 
	{
		super();
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		ensureElement(HardwareRenderer.ELEMENTS_PER_TILE, HardwareRenderer.INDICES_PER_TILE);
		var prevVerticesNumber:Int = Std.int(vertexPos / HardwareRenderer.ELEMENTS_PER_VERTEX);
		
		var rect:FlxRect = frame.frame;
		var uv:FlxRect = frame.uv;
		
		var data:Float32Array = buffer;
		
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
		data[vertexPos++] = x;
		data[vertexPos++] = y;
		data[vertexPos++] = uvx;
		data[vertexPos++] = uvy;
		fillTint(r, g, b, a);
		// Triangle 1, top-right
		data[vertexPos++] = x2;
		data[vertexPos++] = y2;
		data[vertexPos++] = uvx2;
		data[vertexPos++] = uvy;
		fillTint(r, g, b, a);
		// Triangle 1, bottom-left
		data[vertexPos++] = x3;
		data[vertexPos++] = y3;
		data[vertexPos++] = uvx;
		data[vertexPos++] = uvy2;
		fillTint(r, g, b, a);
		// Triangle 2, bottom-right
		data[vertexPos++] = x4;
		data[vertexPos++] = y4;
		data[vertexPos++] = uvx2;
		data[vertexPos++] = uvy2;
		fillTint(r, g, b, a);
		
		indexes[indexPos++] = prevVerticesNumber + 0;
		indexes[indexPos++] = prevVerticesNumber + 1;
		indexes[indexPos++] = prevVerticesNumber + 2;
		indexes[indexPos++] = prevVerticesNumber + 2;
		indexes[indexPos++] = prevVerticesNumber + 1;
		indexes[indexPos++] = prevVerticesNumber + 3;
		
		vertexBufferDirty = true;
		indexBufferDirty = true;
	}
	
	// TODO: replace position argument with matrix?
	// TODO: check this method...
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var numVerticesToAdd:Int = Std.int(vertices.length / 2);
		var numIndexesToAdd:Int = indices.length;
		var prevVerticesNumber:Int = Std.int(vertexPos / HardwareRenderer.ELEMENTS_PER_VERTEX);
		
		ensureElement(numVerticesToAdd * HardwareRenderer.ELEMENTS_PER_VERTEX, numIndexesToAdd);
		
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
		
		var data:Float32Array = buffer;
		
		var numUVCoordsPerVertex:Int = (Std.int(uvData.length / 3) == Std.int(vertices.length / 2)) ? 3 : 2;
		
		var x:Float, y:Float;
		for (i in 0...numVerticesToAdd)
		{
			x = vertices[i * 2];
			y = vertices[i * 2 + 1];
			
			data[vertexPos++] = matrix.__transformX(x, y);
			data[vertexPos++] = matrix.__transformY(x, y);
			data[vertexPos++] = uvData[i * numUVCoordsPerVertex];
			data[vertexPos++] = uvData[i * numUVCoordsPerVertex + 1];
			fillTint(r, g, b, a);
		}
		
		for (i in 0...numIndexesToAdd)
		{
			indexes[indexPos++] = prevVerticesNumber + indices[i];
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
			indexes = new UInt32Array(newIndexesLength);
		}
		else
		{
			var oldBubberLength:Int = buffer.length;
			if (newBufferLength >= oldBubberLength)
			{
				var oldBuffer:Float32Array = buffer;
				buffer = new Float32Array(newBufferLength);
				
				for (i in 0...oldBubberLength)
				{
					buffer[i] = oldBuffer[i];
				}
			}
			
			var oldIndexesLength:Int = indexes.length;
			if (newIndexesLength >= oldIndexesLength)
			{
				var oldIndexes:UInt32Array = indexes;
				indexes = new UInt32Array(newIndexesLength);
				
				for (i in 0...oldIndexesLength)
				{
					indexes[i] = oldIndexes[i];
				}
			}
			
		}
	}
	
	// TODO: add check if it's possible to add new quad to this item...
	// TODO: add check if it's possible to add new triangles to this item...
}