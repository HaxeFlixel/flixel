package com.asliceofcrazypie.flash.jobs;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

#if flash11
import com.asliceofcrazypie.flash.TilesheetStage3D;
import com.asliceofcrazypie.flash.jobs.BaseRenderJob;

import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import flash.display3D.IndexBuffer3D;
import flash.display3D.textures.Texture;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.display3D.Context3DTriangleFace;
import flash.display.TriangleCulling;
import flash.Vector;
import flash.errors.Error;
import flash.utils.ByteArray;
import flash.utils.Endian;
import haxe.ds.StringMap;

/**
 * ...
 * @author Paul M Pepper
 */
class RenderJob extends BaseRenderJob
{
	private function new(useBytes:Bool)
	{
		super(useBytes);
	}
	
	public function addQuad(rect:FlxRect, normalizedOrigin:FlxPoint, uv:FlxRect, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		var imgWidth:Int = Std.int(rect.width);
		var imgHeight:Int = Std.int(rect.height);
		
		var centerX:Float = normalizedOrigin.x * imgWidth;
		var centerY:Float = normalizedOrigin.y * imgHeight;
		
		var px:Float;
		var py:Float;
		
		//top left
		px = -centerX;
		py = -centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //top left x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //top left y
		
		vertices[vertexPos++] = uv.x; //top left u
		vertices[vertexPos++] = uv.y; //top left v
		
		if (isRGB)
		{
			vertices[vertexPos++] = r;
			vertices[vertexPos++] = g;
			vertices[vertexPos++] = b;
		}
		
		if (isAlpha)
		{
			vertices[vertexPos++] = a;
		}
		
		//top right
		px = imgWidth - centerX;
		py = -centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //top right x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //top right y
		
		vertices[vertexPos++] = uv.width; //top right u
		vertices[vertexPos++] = uv.y; //top right v
		
		if (isRGB)
		{
			vertices[vertexPos++] = r;
			vertices[vertexPos++] = g;
			vertices[vertexPos++] = b;
		}
		
		if (isAlpha)
		{
			vertices[vertexPos++] = a;
		}
		
		//bottom right
		px = imgWidth - centerX;
		py = imgHeight - centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //bottom right x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //bottom right y
		
		vertices[vertexPos++] = uv.width; //bottom right u
		vertices[vertexPos++] = uv.height; //bottom right v
		
		if (isRGB)
		{
			vertices[vertexPos++] = r;
			vertices[vertexPos++] = g;
			vertices[vertexPos++] = b;
		}
		
		if (isAlpha)
		{
			vertices[vertexPos++] = a;
		}
		
		//bottom left
		px = -centerX;
		py = imgHeight - centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //bottom left x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //bottom left y
		
		vertices[vertexPos++] = uv.x; //bottom left u
		vertices[vertexPos++] = uv.height; //bottom left v
		
		if (isRGB)
		{
			vertices[vertexPos++] = r;
			vertices[vertexPos++] = g;
			vertices[vertexPos++] = b;
		}
		
		if (isAlpha)
		{
			vertices[vertexPos++] = a;
		}
		
		numVertices += 4;
		numIndices += 6;
		
		/*
		indices.position = 12 * quadPos; // 12 = 6 * 2 (6 indices per quad and 2 bytes per index)
		var startIndex:Int = quadPos * 4;
		indices.writeShort(startIndex + 2);
		indices.writeShort(startIndex + 1);
		indices.writeShort(startIndex + 0);
		indices.writeShort(startIndex + 3);
		indices.writeShort(startIndex + 2);
		indices.writeShort(startIndex + 0);
		*/
	}
	
	override public function render(context:ContextWrapper = null, colored:Bool = false):Void
	{
		if (context != null && context.context3D.driverInfo != 'Disposed')
		{
			//blend mode
			context.setBlendMode(blendMode, tilesheet.premultipliedAlpha);
			
			context.setImageProgram(isRGB, isAlpha, isSmooth, tilesheet.mipmap, colored); //assign appropriate shader
			
			// TODO: culling support...
			// context.context3D.setCulling();
			
			context.setTexture(tilesheet.texture);
			
			//actually create the buffers
			var vertexbuffer:VertexBuffer3D = null;
			var indexbuffer:IndexBuffer3D = null;
			
			// Create VertexBuffer3D. numVertices vertices, of dataPerVertice Numbers each
			vertexbuffer = context.context3D.createVertexBuffer(numVertices, dataPerVertice);
			
			// Upload VertexBuffer3D to GPU. Offset 0, numVertices vertices
			vertexbuffer.uploadFromVector(vertices, 0, numVertices);
			
			// Create IndexBuffer3D.
			indexbuffer = context.context3D.createIndexBuffer(numIndices);
			
			// Upload IndexBuffer3D to GPU.
			if (indicesBytes != null)
			{
				indexbuffer.uploadFromByteArray(indicesBytes, 0, 0, numIndices);
			}
			else
			{
				indexbuffer.uploadFromVector(indicesVector, 0, numIndices);
			}
			
			// vertex position to attribute register 0
			context.context3D.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			// UV to attribute register 1
			context.context3D.setVertexBufferAt(1, vertexbuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			
			if (isRGB && isAlpha)
			{
				context.context3D.setVertexBufferAt(2, vertexbuffer, 4, Context3DVertexBufferFormat.FLOAT_4); //rgba data
			}
			else if (isRGB)
			{
				context.context3D.setVertexBufferAt(2, vertexbuffer, 4, Context3DVertexBufferFormat.FLOAT_3); //rgb data
			}
			else if (isAlpha)
			{
				context.context3D.setVertexBufferAt(2, vertexbuffer, 4, Context3DVertexBufferFormat.FLOAT_1); //a data
			}
			else
			{
				context.context3D.setVertexBufferAt(2, null, 4);
			}
			
			context.context3D.drawTriangles(indexbuffer);
		}
	}
}
#end