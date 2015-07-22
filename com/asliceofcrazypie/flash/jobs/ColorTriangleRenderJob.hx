package com.asliceofcrazypie.flash.jobs;

import com.asliceofcrazypie.flash.jobs.BaseRenderJob.RenderJobType;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.display.TriangleCulling;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Vector;

/**
 * ...
 * @author Zaphod
 */
#if flash11
class ColorTriangleRenderJob extends TriangleRenderJob
{
	public function new() 
	{
		super();
		type = RenderJobType.COLOR_TRIANGLE;
	}
	
	public function addAAQuad(rect:Rectangle, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		var prevVerticesNumber:Int = Std.int(vertexPos / dataPerVertice);
		
		vertices[vertexPos++] = rect.x; //top left x
		vertices[vertexPos++] = rect.y; //top left y
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		vertices[vertexPos++] = rect.right; //top right x
		vertices[vertexPos++] = rect.y; //top right y
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		vertices[vertexPos++] = rect.right; //bottom right x
		vertices[vertexPos++] = rect.bottom; //bottom right y
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		vertices[vertexPos++] = rect.x; //bottom left x
		vertices[vertexPos++] = rect.bottom; //bottom left y
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		numVertices += 4;
		numIndices += 6;
		
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 1;
		indices[indexPos++] = prevVerticesNumber + 0;
		indices[indexPos++] = prevVerticesNumber + 3;
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 0;
	}
	
	public function addQuad(rect:Rectangle, normalizedOrigin:Point, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		var prevVerticesNumber:Int = Std.int(vertexPos / dataPerVertice);
		
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
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		//top right
		px = imgWidth - centerX;
		py = -centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //top right x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //top right y
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		//bottom right
		px = imgWidth - centerX;
		py = imgHeight - centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //bottom right x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //bottom right y
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		//bottom left
		px = -centerX;
		py = imgHeight - centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //bottom left x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //bottom left y
		
		vertices[vertexPos++] = r;
		vertices[vertexPos++] = g;
		vertices[vertexPos++] = b;
		vertices[vertexPos++] = a;
		
		numVertices += 4;
		numIndices += 6;
		
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 1;
		indices[indexPos++] = prevVerticesNumber + 0;
		indices[indexPos++] = prevVerticesNumber + 3;
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 0;
	}
	
	public function addTriangles(vertices:Vector<Float>, indices:Vector<Int> = null, colors:Vector<Int> = null, position:Point = null):Void
	{
		var numIndices:Int = indices.length;
		var numVertices:Int = Std.int(vertices.length / 2);
		
		var prevVerticesNumber:Int = Std.int(vertexPos / dataPerVertice);
		
		var vertexIndex:Int = 0;
		var vColor:Int;
		
		var x:Float = 0;
		var y:Float = 0;
		
		if (position != null)
		{
			x = position.x;
			y = position.y;
		}
		
		for (i in 0...numVertices)
		{
			vertexIndex = 2 * i;
			
			this.vertices[vertexPos++] = vertices[vertexIndex] + x;
			this.vertices[vertexPos++] = vertices[vertexIndex + 1] + y;
			
			vColor = colors[i];
			this.vertices[vertexPos++] = ((vColor >> 16) & 0xff) / 255;
			this.vertices[vertexPos++] = ((vColor >> 8) & 0xff) / 255;
			this.vertices[vertexPos++] = (vColor & 0xff) / 255;
			this.vertices[vertexPos++] = ((vColor >> 24) & 0xff) / 255;
		}
		
		for (i in 0...numIndices)
		{
			this.indices[indexPos++] = prevVerticesNumber + indices[i];
		}
		
		this.numVertices += numVertices;
		this.numIndices += numIndices;
	}
	
	override public function render(context:ContextWrapper = null, colored:Bool = false):Void 
	{
		if (context != null)
		{
			//blend mode
			context.setBlendMode(blendMode, false);
			
			context.setTriangleNoImageProgram(colored); //assign appropriate shader
			
			// TODO: culling support...
			// context.context3D.setCulling();
			
			context.setTexture(null);
			
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
			indexbuffer.uploadFromVector(indices, 0, numIndices);
			
			// vertex position to attribute register 0
			context.context3D.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			// color to attribute register 1
			context.context3D.setVertexBufferAt(1, vertexbuffer, 2, Context3DVertexBufferFormat.FLOAT_4);
			context.context3D.setVertexBufferAt(2, null);
			
			context.context3D.drawTriangles(indexbuffer);
		}
	}
	
	public function set(blend:BlendMode, culling:TriangleCulling = null):Void
	{
		this.blendMode = blend;
		this.culling = culling;
		this.dataPerVertice = 6;
	}
}
#else
class ColorTriangleRenderJob extends TriangleRenderJob
{
	private var color:Int = 0xFFFFFF;
	private var alpha:Float = 1.0;
	
	public function new() 
	{
		super();
		type = RenderJobType.COLOR_TRIANGLE;
	}
	
	public function addAAQuad(rect:Rectangle, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		var prevVerticesNumber:Int = Std.int(vertexPos / dataPerVertice);
		
		vertices[vertexPos++] = rect.x; //top left x
		vertices[vertexPos++] = rect.y; //top left y
		
		vertices[vertexPos++] = rect.right; //top right x
		vertices[vertexPos++] = rect.y; //top right y
		
		vertices[vertexPos++] = rect.right; //bottom right x
		vertices[vertexPos++] = rect.bottom; //bottom right y
		
		vertices[vertexPos++] = rect.x; //bottom left x
		vertices[vertexPos++] = rect.bottom; //bottom left y
		
		numVertices += 4;
		numIndices += 6;
		
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 1;
		indices[indexPos++] = prevVerticesNumber + 0;
		indices[indexPos++] = prevVerticesNumber + 3;
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 0;
		
		#if flash
		color = ((Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255));
		alpha = a;
		#else
		var color = ((Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255));
		colors[colorPos++] = color;
		colors[colorPos++] = color;
		colors[colorPos++] = color;
		colors[colorPos++] = color;
		#end
	}
	
	public function addQuad(rect:Rectangle, normalizedOrigin:Point, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		var prevVerticesNumber:Int = Std.int(vertexPos / dataPerVertice);
		
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
		
		//top right
		px = imgWidth - centerX;
		py = -centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //top right x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //top right y
		
		//bottom right
		px = imgWidth - centerX;
		py = imgHeight - centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //bottom right x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //bottom right y
		
		//bottom left
		px = -centerX;
		py = imgHeight - centerY;
		
		vertices[vertexPos++] = px * matrix.a + py * matrix.c + matrix.tx; //bottom left x
		vertices[vertexPos++] = px * matrix.b + py * matrix.d + matrix.ty; //bottom left y
		
		numVertices += 4;
		numIndices += 6;
		
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 1;
		indices[indexPos++] = prevVerticesNumber + 0;
		indices[indexPos++] = prevVerticesNumber + 3;
		indices[indexPos++] = prevVerticesNumber + 2;
		indices[indexPos++] = prevVerticesNumber + 0;
		
		#if flash
		color = ((Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255));
		alpha = a;
		#else
		var color = ((Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255));
		colors[colorPos++] = color;
		colors[colorPos++] = color;
		colors[colorPos++] = color;
		colors[colorPos++] = color;
		#end
	}
	
	public function addTriangles(vertices:Vector<Float>, indices:Vector<Int> = null, colors:Vector<Int> = null, position:Point = null):Void
	{
		var numIndices:Int = indices.length;
		var numVertices:Int = Std.int(vertices.length / 2);
		
		var prevVerticesNumber:Int = Std.int(vertexPos / dataPerVertice);
		
		var vertexIndex:Int = 0;
		
		var x:Float = 0;
		var y:Float = 0;
		
		if (position != null)
		{
			x = position.x;
			y = position.y;
		}
		
		for (i in 0...numVertices)
		{
			vertexIndex = 2 * i;
			
			this.vertices[vertexPos++] = vertices[vertexIndex] + x;
			this.vertices[vertexPos++] = vertices[vertexIndex + 1] + y;
			
			#if !flash
			this.colors[colorPos++] = colors[i];
			#end
		}
		
		for (i in 0...numIndices)
		{
			this.indices[indexPos++] = prevVerticesNumber + indices[i];
		}
		
		this.numVertices += numVertices;
		this.numIndices += numIndices;
	}
	
	override public function render(context:Sprite = null, colored:Bool = false):Void 
	{
		#if flash
		context.graphics.beginFill(color, alpha);
		context.graphics.drawTriangles(vertices, indices);
		#else
		context.graphics.beginBitmapFill(Batcher.colorsheet.bitmap);
		var blendInt:Int = 0;
		
		if (blendMode == BlendMode.ADD)
		{
			blendInt = Tilesheet.TILE_BLEND_ADD;
		}
		else if (blendMode == BlendMode.MULTIPLY)
		{
			blendInt = Tilesheet.TILE_BLEND_MULTIPLY;
		}
		else if (blendMode == BlendMode.SCREEN)
		{
			blendInt = Tilesheet.TILE_BLEND_SCREEN;
		}
		
		culling = (culling == null) ? TriangleCulling.NONE : culling;
		
		context.graphics.drawTriangles(vertices, indices, null, culling, colors, blendInt);
		#end
		context.graphics.endFill();
	}
	
	public function set(blend:BlendMode, culling:TriangleCulling = null):Void
	{
		this.blendMode = blend;
		this.culling = culling;
		this.dataPerVertice = 2;
	}
}
#end