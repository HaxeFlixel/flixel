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

private inline final INDICES_PER_QUAD = 6;

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
		shader.colorMultiplier.value = colored ? colorMultipliers.toShaderValue() : null;
		shader.colorOffset.value = hasColorOffsets ? colorOffsets.toShaderValue() : null;
		
		setParameterValue(shader.hasColorMults, colored);
		setParameterValue(shader.hasColorOffsets, hasColorOffsets);
		
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
			
			alphas.pushMany(indicesLength, transform);
			
			if (colored)
			{
				if (colorMultipliers.numIndices < indicesPosition)
					colorMultipliers.padTo(indicesPosition);
				
				if (colors != null && colors.length < indicesLength && colors.length > 0)
					FlxG.log.warn('Expected a color for each indice pair ($indicesLength), got ${colors.length}');
				
				if (colors != null && colors.length == indicesLength)
					colorMultipliers.pushColors(colors, transform);
				else
					colorMultipliers.pushMany(indicesLength, transform);
			}
			
			if (hasColorOffsets)
			{
				if (colorOffsets.numIndices < indicesPosition)
					colorOffsets.padTo(indicesPosition);
				
				colorOffsets.pushMany(indicesLength, transform);
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

		alphas.pushMany(INDICES_PER_QUAD, transform);
		
		if (colored)
		{
			if (colorMultipliers.numIndices < indicesPosition)
				colorMultipliers.padTo(indicesPosition);
			
			colorMultipliers.pushMany(INDICES_PER_QUAD, transform);
		}
		
		if (hasColorOffsets)
		{
			if (colorOffsets.numIndices < indicesPosition)
				colorOffsets.padTo(indicesPosition);
			
			colorOffsets.pushMany(INDICES_PER_QUAD, transform);
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
	
	/** Removes all items */
	inline public function clear()
	{
		this.resize(0);
	}
	
	
	/**
	 * Adds the alpha for the given number of indices
	 */
	overload public inline extern function pushMany(numIndices:Int, alpha:Float)
	{
		for (i in 0...numIndices)
			this.push(alpha);
	}
	
	
	/**
	 * Adds the alpha for the given number of indices
	 */
	overload public inline extern function pushMany(numIndices:Int, transform:Null<ColorTransform>)
	{
		pushMany(numIndices, transform == null ? 1.0 : transform.alphaMultiplier);
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}

@:forward
private abstract ColorMultVector(Array<Float>)
{
	/**
	 * The number of indice color multipliers in this list
	 */
	public var numIndices(get, never):Int;
	inline function get_numIndices() return Math.round(this.length / 4);
	
	inline public function new ()
	{
		this = new Array<Float>();
	}
	
	/**
	 * Adds colors to this list until it has the desired length
	 */
	inline public function padTo(newLength:Int)
	{
		pushDefaults(newLength - numIndices);
	}
	
	/** Removes all items */
	inline public function clear()
	{
		this.resize(0);
	}
	
	/**
	 * Adds the color multiplier
	 */
	public inline function push(red:Float, green:Float, blue:Float, alpha = 1.0)
	{
		this.push(red);
		this.push(green);
		this.push(blue);
		this.push(alpha);
	}
	
	/**
	 * Adds the color multiplier for the given number of indices
	 */
	overload public inline extern function pushMany(numIndices:Int, red:Float, green:Float, blue:Float, alpha = 1.0)
	{
		for (i in 0...numIndices)
			push(red, green, blue, alpha);
	}
	
	/**
	 * Adds the default color multiplier for the given number of indices
	 */
	inline public function pushDefaults(numIndices:Int)
	{
		pushMany(numIndices, 1, 1, 1);
	}
	
	/**
	 * Adds the color multiplier for the given number of indices
	 */
	overload public inline extern function pushMany(numIndices:Int, transform:Null<ColorTransform>)
	{
		if (transform == null)
			pushDefaults(numIndices);
		else
			pushMany(numIndices, transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier);
	}
	
	/**
	 * Adds the given list of color multipliers and applies the transform's multipliers, if not null
	 */
	public inline function pushColors(colors:DrawData<Int>, transform:Null<ColorTransform>)
	{
		if (transform == null)
		{
			for (c in colors)
			{
				final color:FlxColor = c;
				push(color.redFloat, color.greenFloat, color.blueFloat);
			}
		}
		else
		{
			for (c in colors)
			{
				final color:FlxColor = c;
				push(transform.redMultiplier * color.redFloat, transform.greenMultiplier * color.greenFloat, transform.blueMultiplier * color.blueFloat);
			}
		}
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}

@:forward
private abstract ColorOffsetVector(Array<Float>)
{
	/**
	 * The number of indice color offsets in this list
	 */
	public var numIndices(get, never):Int;
	inline function get_numIndices() return Math.round(this.length / 4);
	
	inline public function new ()
	{
		this = new Array<Float>();
	}
	
	/**
	 * Adds colors to this list until it has the desired length
	 */
	inline public function padTo(newLength:Int)
	{
		pushDefaults(newLength - numIndices);
	}
	
	/** Removes all items */
	inline public function clear()
	{
		this.resize(0);
	}
	
	/**
	 * Adds the color offset
	 */
	public inline function push(red:Float, green:Float, blue:Float, alpha = 1.0)
	{
		this.push(red);
		this.push(green);
		this.push(blue);
		this.push(alpha);
	}
	
	/**
	 * Adds the color offset for the given number of indices
	 */
	overload public inline extern function pushMany(numIndices:Int, red:Float, green:Float, blue:Float, alpha:Float)
	{
		for (i in 0...numIndices)
			push(red, green, blue, alpha);
	}
	
	/**
	 * Adds the default color offset for the given number of indices
	 */
	inline public function pushDefaults(numIndices:Int)
	{
		pushMany(numIndices, 0, 0, 0, 0);
	}
	
	/**
	 * Adds the color offset for the given number of indices
	 */
	overload public inline extern function pushMany(numIndices:Int, transform:Null<ColorTransform>)
	{
		if (transform == null)
			pushDefaults(numIndices);
		else
			pushMany(numIndices, transform.redOffset, transform.greenOffset, transform.blueOffset, transform.alphaOffset);
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}
