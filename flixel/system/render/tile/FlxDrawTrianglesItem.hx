package flixel.system.render.tile;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.DrawItem.FlxDrawItemType;
import flixel.system.render.DrawItem.DrawData;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.FlxCameraView;
import flixel.system.render.tile.FlxTilesheetView;
import flixel.util.FlxColor;
import flixel.util.FlxGeom;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.display.TriangleCulling;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{
	private static var point:FlxPoint = FlxPoint.get();
	private static var rect:FlxRect = FlxRect.get();
	
	public var vertices:DrawData<Float> = new DrawData<Float>();
	public var indices:DrawData<Int> = new DrawData<Int>();
	public var uvtData:DrawData<Float> = new DrawData<Float>();
	public var colors:DrawData<Int> = new DrawData<Int>();
	
	public var verticesPosition:Int = 0;
	public var indicesPosition:Int = 0;
	public var colorsPosition:Int = 0;
	
	private var bounds:FlxRect = FlxRect.get();
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
	}
	
	override public function render(view:FlxTilesheetView):Void 
	{
		if (!FlxG.renderTile)
			return;
		
		if (numTriangles <= 0)
			return;
		
		view.canvas.graphics.beginBitmapFill(graphics.bitmap, null, true, (view.antialiasing || antialiasing));
		#if !openfl_legacy
		view.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE);
		#else
		view.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE, (colored) ? colors : null, FlxDrawBaseItem.blendToInt(blending));
		#end
		view.canvas.graphics.endFill();
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = view.debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices);
		}
		#end
		
		FlxCameraView._DRAWCALLS++;
	}
	
	override public function reset():Void 
	{
		super.reset();
		vertices.splice(0, vertices.length);
		indices.splice(0, indices.length);
		uvtData.splice(0, uvtData.length);
		colors.splice(0, colors.length);
		
		verticesPosition = 0;
		indicesPosition = 0;
		colorsPosition = 0;
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		
		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;
		bounds = null;
	}
	
	override public function equals(type:FlxDrawItemType, graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader):Bool
	{
		return (this.type == type 
			&& this.graphics == graphic 
			&& this.colored == colored
			&& this.blending == blend
			&& this.antialiasing == smooth);
	}
	
	override public function set(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader):Void
	{
		// TODO: implement and use it...
	}
	
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint, ?cameraBounds:FlxRect):Void
	{
		if (position == null)
			position = point.set();
		
		if (cameraBounds == null)
			cameraBounds = rect.set(0, 0, FlxG.width, FlxG.height);
		
		var verticesLength:Int = vertices.length;
		var prevVerticesLength:Int = this.vertices.length;
		var numberOfVertices:Int = Std.int(verticesLength / 2);
		var prevIndicesLength:Int = this.indices.length;
		var prevUVTDataLength:Int = this.uvtData.length;
		var prevColorsLength:Int = this.colors.length;
		var prevNumberOfVertices:Int = this.numVertices;
		
		var tempX:Float, tempY:Float;
		var i:Int = 0;
		var currentVertexPosition:Int = prevVerticesLength;
		
		while (i < verticesLength)
		{
			tempX = position.x + vertices[i]; 
			tempY = position.y + vertices[i + 1];
			
			this.vertices[currentVertexPosition++] = tempX;
			this.vertices[currentVertexPosition++] = tempY;
			
			if (i == 0)
			{
				bounds.set(tempX, tempY, 0, 0);
			}
			else
			{
				FlxGeom.inflateBounds(bounds, tempX, tempY);
			}
			
			i += 2;
		}
		
		if (!cameraBounds.overlaps(bounds))
		{
			this.vertices.splice(this.vertices.length - verticesLength, verticesLength);
		}
		else
		{
			var uvtDataLength:Int = uvtData.length;
			for (i in 0...uvtDataLength)
			{
				this.uvtData[prevUVTDataLength + i] = uvtData[i];
			}
			
			var indicesLength:Int = indices.length;
			for (i in 0...indicesLength)
			{
				this.indices[prevIndicesLength + i] = indices[i] + prevNumberOfVertices;
			}
			
			if (colored)
			{
				for (i in 0...numberOfVertices)
				{
					this.colors[prevColorsLength + i] = colors[i];
				}
				
				colorsPosition += numberOfVertices;
			}
			
			verticesPosition += verticesLength;
			indicesPosition += indicesLength;
		}
		
		position.putWeak();
		cameraBounds.putWeak();
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var prevVerticesPos:Int = verticesPosition;
		var prevIndicesPos:Int = indicesPosition;
		var prevColorsPos:Int = colorsPosition;
		var prevNumberOfVertices:Int = numVertices;
		
		var point = FlxPoint.get();
		point.transform(matrix);
		
		vertices[prevVerticesPos] = point.x;
		vertices[prevVerticesPos + 1] = point.y;
		
		uvtData[prevVerticesPos] = frame.uv.x;
		uvtData[prevVerticesPos + 1] = frame.uv.y;
		
		point.set(frame.frame.width, 0);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 2] = point.x;
		vertices[prevVerticesPos + 3] = point.y;
		
		uvtData[prevVerticesPos + 2] = frame.uv.width;
		uvtData[prevVerticesPos + 3] = frame.uv.y;
		
		point.set(frame.frame.width, frame.frame.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 4] = point.x;
		vertices[prevVerticesPos + 5] = point.y;
		
		uvtData[prevVerticesPos + 4] = frame.uv.width;
		uvtData[prevVerticesPos + 5] = frame.uv.height;
		
		point.set(0, frame.frame.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 6] = point.x;
		vertices[prevVerticesPos + 7] = point.y;
		
		point.put();
		
		uvtData[prevVerticesPos + 6] = frame.uv.x;
		uvtData[prevVerticesPos + 7] = frame.uv.height;
		
		indices[prevIndicesPos] = prevNumberOfVertices;
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1;
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 3;
		indices[prevIndicesPos + 5] = prevNumberOfVertices;
		
		if (colored)
		{
			var red = 1.0;
			var green = 1.0;
			var blue = 1.0;
			var alpha = 1.0;
			
			if (transform != null)
			{
				red  = transform.redMultiplier;
				green = transform.greenMultiplier;
				blue = transform.blueMultiplier;
				
				#if !neko
				alpha = transform.alphaMultiplier;
				#end
			}
			
			var color = FlxColor.fromRGBFloat(red, green, blue, alpha);
			
			colors[prevColorsPos] = color;
			colors[prevColorsPos + 1] = color;
			colors[prevColorsPos + 2] = color;
			colors[prevColorsPos + 3] = color;
			
			colorsPosition += 4;
		}
		
		verticesPosition += 8;
		indicesPosition += 6;
	}
	
	override private function get_numVertices():Int
	{
		return Std.int(vertices.length / 2);
	}
	
	override private function get_numTriangles():Int
	{
		return Std.int(indices.length / 3);
	}
}
