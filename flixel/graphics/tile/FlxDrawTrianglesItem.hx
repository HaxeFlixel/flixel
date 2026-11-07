package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.Graphics;
import openfl.display.ShaderParameter;
import openfl.display.TriangleCulling;
import openfl.geom.ColorTransform;

typedef DrawData<T> = openfl.Vector<T>;

inline final INDICES_PER_QUAD = 6;

/**
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{
	static inline final INDICES_PER_QUAD = 6;
	static var point:FlxPoint = FlxPoint.get();
	static var rect:FlxRect = FlxRect.get();
	
	public var shader:FlxShader;
		
	final colorMultipliers = new ColorMultVector();
	final colorOffsets = new ColorOffsetVector();
	final alphas = new AlphaVector();
	
	public var vertices:DrawData<Float> = new DrawData<Float>();
	public var indices:DrawData<Int> = new DrawData<Int>();
	public var uvtData:DrawData<Float> = new DrawData<Float>();
	@:deprecated("colors is deprecated, use colorMultipliers and colorOffsets")
	public var colors:DrawData<Int> = new DrawData<Int>();
	
	public var verticesPosition:Int = 0;
	public var indicesPosition:Int = 0;
	@:deprecated("colorsPosition is deprecated")
	public var colorsPosition:Int = 0;
	
	var bounds:FlxRect = FlxRect.get();
	
	public function new()
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
	}
	
	override public function render(camera:FlxCamera):Void
	{
		if (numTriangles <= 0)
			return;
		
		#if !flash
		var shader = shader != null ? shader : graphics.shader;
		shader.bitmap.input = graphics.bitmap;
		shader.bitmap.filter = (camera.antialiasing || antialiasing) ? LINEAR : NEAREST;
		shader.bitmap.wrap = REPEAT; // in order to prevent breaking tiling behaviour in classes that use drawTriangles
		shader.alpha.value = alphas.toShaderValue();
		
		if (colored || hasColorOffsets)
		{
			shader.colorMultiplier.value = colorMultipliers.toShaderValue();
			shader.colorOffset.value = colorOffsets.toShaderValue();
		}
		else
		{
			shader.colorMultiplier.value = null;
			shader.colorOffset.value = null;
		}
		
		setParameterValue(shader.hasTransform, true);
		setParameterValue(shader.hasColorTransform, colored || hasColorOffsets);
		
		camera.canvas.graphics.overrideBlendMode(blend);
		
		camera.canvas.graphics.beginShaderFill(shader);
		#else
		camera.canvas.graphics.beginBitmapFill(graphics.bitmap, null, true, (camera.antialiasing || antialiasing));
		#end
		
		camera.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE);
		camera.canvas.graphics.endFill();
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = camera.debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices, uvtData);
		}
		#end

		super.render(camera);
	}

	override public function reset():Void
	{
		super.reset();
		vertices.length = 0;
		indices.length = 0;
		uvtData.length = 0;

		verticesPosition = 0;
		indicesPosition = 0;
		alphas.clear();
		colorMultipliers.clear();
		colorOffsets.clear();
	}

	override public function dispose():Void
	{
		super.dispose();

		vertices = null;
		indices = null;
		uvtData = null;
		bounds = null;
		alphas.clear();
		colorMultipliers.clear();
		colorOffsets.clear();
	}

	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint,
			?cameraBounds:FlxRect, ?transform:ColorTransform):Void
	{
		if (position == null)
			position = point.zero();

		if (cameraBounds == null)
			cameraBounds = rect.set(0, 0, FlxG.width, FlxG.height);

		var verticesLength:Int = vertices.length;
		var prevVerticesLength:Int = this.vertices.length;
		var numberOfVertices:Int = Std.int(verticesLength / 2);
		var prevIndicesLength:Int = this.indices.length;
		var prevUVTDataLength:Int = this.uvtData.length;
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
				inflateBounds(bounds, tempX, tempY);
			}

			i += 2;
		}

		var indicesLength:Int = indices.length;
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

			for (i in 0...indicesLength)
			{
				this.indices[prevIndicesLength + i] = indices[i] + prevNumberOfVertices;
			}
			
			alphas.push(indicesLength, transform);
			
			if (colored || hasColorOffsets)
			{
				if (colorMultipliers.numIndices < indicesLength)
					colorMultipliers.padTo(indicesLength);
				
				if (colorOffsets.numIndices < indicesLength)
					colorOffsets.padTo(indicesLength);
				
				colorMultipliers.push(indicesLength, transform);
				colorOffsets.push(indicesLength, transform);
			}
			
			verticesPosition += verticesLength;
			indicesPosition += indicesLength;
		}

		position.putWeak();
		cameraBounds.putWeak();
	}

	inline function setParameterValue(parameter:ShaderParameter<Bool>, value:Bool):Void
	{
		if (parameter.value == null)
			parameter.value = [];
		parameter.value[0] = value;
	}

	public static inline function inflateBounds(bounds:FlxRect, x:Float, y:Float):FlxRect
	{
		if (x < bounds.x)
		{
			bounds.width += bounds.x - x;
			bounds.x = x;
		}

		if (y < bounds.y)
		{
			bounds.height += bounds.y - y;
			bounds.y = y;
		}

		if (x > bounds.x + bounds.width)
		{
			bounds.width = x - bounds.x;
		}

		if (y > bounds.y + bounds.height)
		{
			bounds.height = y - bounds.y;
		}

		return bounds;
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		final prevVerticesPos = verticesPosition;
		final prevNumberOfVertices = numVertices;
		
		final w = frame.frame.width;
		final h = frame.frame.height;
		vertices[prevVerticesPos + 0] = matrix.transformX(0, 0); // left
		vertices[prevVerticesPos + 1] = matrix.transformY(0, 0); // top
		vertices[prevVerticesPos + 2] = matrix.transformX(w, 0); // right
		vertices[prevVerticesPos + 3] = matrix.transformY(w, 0); // top
		vertices[prevVerticesPos + 4] = matrix.transformX(0, h); // left
		vertices[prevVerticesPos + 5] = matrix.transformY(0, h); // bottom
		vertices[prevVerticesPos + 6] = matrix.transformX(w, h); // right
		vertices[prevVerticesPos + 7] = matrix.transformY(w, h); // bottom
		
		uvtData[prevVerticesPos + 0] = frame.uv.left;
		uvtData[prevVerticesPos + 1] = frame.uv.top;
		uvtData[prevVerticesPos + 2] = frame.uv.right;
		uvtData[prevVerticesPos + 3] = frame.uv.top;
		uvtData[prevVerticesPos + 4] = frame.uv.left;
		uvtData[prevVerticesPos + 5] = frame.uv.bottom;
		uvtData[prevVerticesPos + 6] = frame.uv.right;
		uvtData[prevVerticesPos + 7] = frame.uv.bottom;
		
		final prevIndicesPos = indicesPosition;
		indices[prevIndicesPos + 0] = prevNumberOfVertices + 0; // TL
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1; // TR
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2; // BL
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 1; // TR
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 2; // BL
		indices[prevIndicesPos + 5] = prevNumberOfVertices + 3; // BR

		alphas.push(INDICES_PER_QUAD, transform);
			
		if (colored || hasColorOffsets)
		{
			if (colorMultipliers.numIndices < indicesPosition)
				colorMultipliers.padTo(indicesPosition);
			
			if (colorOffsets.numIndices < indicesPosition)
				colorOffsets.padTo(indicesPosition);
			
			colorMultipliers.push(INDICES_PER_QUAD, transform);
			colorOffsets.push(INDICES_PER_QUAD, transform);
		}

		verticesPosition += 8;
		indicesPosition += 6;
	}

	override function get_numVertices():Int
	{
		return Std.int(vertices.length / 2);
	}

	override function get_numTriangles():Int
	{
		return Std.int(indices.length / 3);
	}
}

@:forward
private abstract AlphaVector(Array<Float>)
{
	inline public function new ()
	{
		this = new Array<Float>();
	}
	
	inline public function clear()
	{
		this.resize(0);
	}
	
	overload public inline extern function push(numIndices:Int, alpha:Float)
	{
		for (i in 0...numIndices)
			this.push(alpha);
	}
	
	overload public inline extern function push(numIndices:Int, transform:Null<ColorTransform>)
	{
		push(numIndices, transform == null ? 1.0 : transform.alphaMultiplier);
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}

@:forward
private abstract ColorMultVector(Array<Float>)
{
	public var numIndices(get, never):Int;
	inline function get_numIndices() return Math.round(this.length / 4);
	
	inline public function new ()
	{
		this = new Array<Float>();
	}
	
	inline public function padTo(newLength:Int)
	{
		pushDefault(newLength - numIndices);
	}
	
	inline public function clear()
	{
		this.resize(0);
	}
	
	overload public inline extern function push(numIndices:Int, red:Float, green:Float, blue:Float)
	{
		for (i in 0...numIndices)
		{
			this.push(red);
			this.push(green);
			this.push(blue);
			this.push(1);
		}
	}
	
	inline public function pushDefault(numIndices:Int)
	{
		push(numIndices, 1, 1, 1);
	}
	
	overload public inline extern function push(numIndices:Int, transform:Null<ColorTransform>)
	{
		if (transform == null)
			pushDefault(numIndices);
		else
			push(numIndices, transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier);
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}

@:forward
private abstract ColorOffsetVector(Array<Float>)
{
	public var numIndices(get, never):Int;
	inline function get_numIndices() return Math.round(this.length / 4);
	
	inline public function new ()
	{
		this = new Array<Float>();
	}
	
	inline public function padTo(newLength:Int)
	{
		pushDefault(newLength - numIndices);
	}
	
	inline public function clear()
	{
		this.resize(0);
	}
	
	overload public inline extern function push(numIndices:Int, red:Float, green:Float, blue:Float, alpha:Float)
	{
		for (i in 0...numIndices)
		{
			this.push(red);
			this.push(green);
			this.push(blue);
			this.push(alpha);
		}
	}
	
	inline public function pushDefault(numIndices:Int)
	{
		push(numIndices, 0, 0, 0, 0);
	}
	
	overload public inline extern function push(numIndices:Int, transform:Null<ColorTransform>)
	{
		if (transform == null)
			pushDefault(numIndices);
		else
			push(numIndices, transform.redOffset, transform.greenOffset, transform.blueOffset, transform.alphaOffset);
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}
