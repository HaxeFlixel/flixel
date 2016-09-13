package flixel.system.render.hardware.glArrays;

import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.hardware.gl.FlxDrawHardwareItem;
import flixel.util.FlxColor;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawHardwareItem<FlxDrawTrianglesItem>
{
	public var numTiles:Int = 0;
	
	#if !flash
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		addUVQuad(frame.frame, frame.uv, matrix, transform);
	}
	
	override public function addUVQuad(rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		ensureElement(FlxCameraView.ELEMENTS_PER_TEXTURED_TILE * FlxCameraView.MINIMUM_TILE_COUNT_PER_BUFFER);
		var prevVerticesNumber:Int = numVertices;
		
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
		addTexturedVertexData(x, y, uv.x, uv.y, r, g, b, a);
		// Triangle 1, top-right
		addTexturedVertexData(x2, y2, uv.width, uv.y, r, g, b, a);
		// Triangle 1, bottom-left
		addTexturedVertexData(x3, y3, uv.x, uv.height, r, g, b, a);
		// Triangle 2, bottom-left
		addTexturedVertexData(x3, y3, uv.x, uv.height, r, g, b, a);
		// Triangle 2, top-right
		addTexturedVertexData(x2, y2, uv.width, uv.y, r, g, b, a);
		// Triangle 2, bottom-right
		addTexturedVertexData(x4, y4, uv.width, uv.height, r, g, b, a);
		
		vertexBufferDirty = true;
	}
	
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		/*
		var numVerticesToAdd:Int = Std.int(vertices.length / 2);
		var numIndexesToAdd:Int = indices.length;
		var prevVerticesNumber:Int = numVertices;
		
		ensureElement(numVerticesToAdd * FlxCameraView.ELEMENTS_PER_TEXTURED_TILE, numIndexesToAdd);
		
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
		
		vertexBufferDirty = true;
	*/
	}
	
	// TODO: addNonIndexedTriangles()???
	
	private function ensureElement(vertexPosToAdd:Int):Void
	{
		var newBufferLength:Int = vertexPos + vertexPosToAdd;
		
		if (buffer == null)
		{
			buffer = new Float32Array(newBufferLength);
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
		}
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		if (graphics != null)
			return;
			
		ensureElement(FlxCameraView.ELEMENTS_PER_NONTEXTURED_TILE * FlxCameraView.MINIMUM_TILE_COUNT_PER_BUFFER);
		
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
		// Triangle 2, bottom-left
		addNonTexturedVertexData(x3, y3, r, g, b, a);
		// Triangle 2, top-right
		addNonTexturedVertexData(x2, y2, r, g, b, a);
		// Triangle 2, bottom-right
		addNonTexturedVertexData(x4, y4, r, g, b, a);
		
		vertexBufferDirty = true;
	}
	
	#else
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		
	}
	#end
	
}