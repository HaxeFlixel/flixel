package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import openfl.display.TriangleCulling;
import openfl.geom.ColorTransform;

typedef DrawData<T> = openfl.Vector<T>;

/**
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{
	static inline final INDICES_PER_QUAD = 6;
	static final point = FlxPoint.get();
	static final rect = FlxRect.get();
	static final bounds = FlxRect.get();
	
	public var shader:FlxShader;
	var alphas:Array<Float> = [];
	var colorMultipliers:Array<Float> = [];
	var colorOffsets:Array<Float> = [];
	
	public var vertices:DrawData<Float> = new DrawData<Float>();
	public var indices:DrawData<Int> = new DrawData<Int>();
	public var uvtData:DrawData<Float> = new DrawData<Float>();
	@:deprecated("colors is deprecated")
	public var colors:DrawData<Int> = new DrawData<Int>();
	
	@:deprecated("verticesPosition is deprecated, use vertices.length, instead")
	public var verticesPosition(get, never):Int;
	@:deprecated("indicesPosition is deprecated, use indices.length, instead")
	public var indicesPosition(get, never):Int;
	@:deprecated("colorsPosition is deprecated")
	public var colorsPosition(get, never):Int;
	
	public function new()
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
	}
	
	#if !flash
	override public function render(camera:FlxCamera):Void
	{
		if (numTriangles == 0)
			return;
		
		// TODO: catch this error when the dev actually messes up, not in the draw phase
		if (shader == null && graphics.isDestroyed)
			throw 'Attempted to render an invalid FlxDrawItem, did you destroy a cached sprite?';
		
		final shader = shader != null ? shader : graphics.shader;
		shader.bitmap.input = graphics.bitmap;
		shader.bitmap.filter = (camera.antialiasing || antialiasing) ? LINEAR : NEAREST;
		shader.bitmap.wrap = REPEAT; // in order to prevent breaking tiling behaviour in classes that use drawTriangles
		shader.alpha.value = alphas;
		
		if (colored || hasColorOffsets)
		{
			shader.colorMultiplier.value = colorMultipliers;
			shader.colorOffset.value = colorOffsets;
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
		camera.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE);
		camera.canvas.graphics.endFill();
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			final gfx = camera.debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices, uvtData);
		}
		#end
		
		super.render(camera);
	}
	
	inline function setParameterValue(parameter:ShaderParameter<Bool>, value:Bool):Void
	{
		if (parameter.value == null)
			parameter.value = [];
		parameter.value[0] = value;
	}
	#end
	
	@:haxe.warning("-WDeprecated")
	override public function reset():Void
	{
		super.reset();
		vertices.length = 0;
		indices.length = 0;
		uvtData.length = 0;
		colors.length = 0;
		alphas.resize(0);
		colorMultipliers.resize(0);
		colorOffsets.resize(0);
	}
	
	@:haxe.warning("-WDeprecated")
	override public function dispose():Void
	{
		super.dispose();
		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;
		alphas = null;
		colorMultipliers = null;
		colorOffsets = null;
	}
	
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint,
			?cameraBounds:FlxRect, ?transform:ColorTransform):Void
	{
		if (position == null)
			position = point.set();
		
		if (cameraBounds == null)
			cameraBounds = rect.set(0, 0, FlxG.width, FlxG.height);
		
		#if FLX_DEBUG
		if (colors != null && colors.length != 0)
			FlxG.log.warn('FlxDrawTrianglesItem.addTriangles: "colors" is deprecated and will be ignored');
		#end
		
		// reset bounds outside camera view
		bounds.set(Math.NaN, Math.NaN, Math.NaN, Math.NaN);
		
		final prevNumberOfVertices = numVertices;
		final verticesLength = vertices.length;
		var i = 0;
		
		while (i < verticesLength)
		{
			final tempX = position.x + vertices[i];
			final tempY = position.y + vertices[i + 1];
			
			this.vertices.push(tempX);
			this.vertices.push(tempY);
			
			if (i == 0)
				bounds.set(tempX, tempY, 0, 0);
			else
				inflateBounds(bounds, tempX, tempY);
			
			i += 2;
		}
		
		final inBounds = cameraBounds.overlaps(bounds);
		
		position.putWeak();
		cameraBounds.putWeak();
		
		if (!inBounds)
		{
			this.vertices.length -= verticesLength;
			return;
		}
		
		for (uvt in uvtData)
			this.uvtData.push(uvt);
		
		for (index in indices)
			this.indices.push(prevNumberOfVertices + index);
		
		final indicesLength = indices.length;
		final alphaMultiplier = transform != null ? transform.alphaMultiplier : 1.0;
		for (_ in 0...indicesLength)
			alphas.push(alphaMultiplier);
		
		if (colored || hasColorOffsets)
		{
			var redMultiplier = 1.0;
			var greenMultiplier = 1.0;
			var blueMultiplier = 1.0;
			
			var redOffset = 1.0;
			var greenOffset = 1.0;
			var blueOffset = 1.0;
			var alphaOffset = 1.0;
			
			if (transform != null)
			{
				redMultiplier = transform.redMultiplier;
				greenMultiplier = transform.greenMultiplier;
				blueMultiplier = transform.blueMultiplier;
				
				redOffset = transform.redOffset;
				greenOffset = transform.greenOffset;
				blueOffset = transform.blueOffset;
				alphaOffset = transform.alphaOffset;
			}
			
			for (_ in 0...indicesLength)
			{
				colorMultipliers.push(redMultiplier);
				colorMultipliers.push(greenMultiplier);
				colorMultipliers.push(blueMultiplier);
				colorMultipliers.push(1);
				
				colorOffsets.push(redOffset);
				colorOffsets.push(greenOffset);
				colorOffsets.push(blueOffset);
				colorOffsets.push(alphaOffset);
			}
		}
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
		
		if (x > bounds.right)
			bounds.width = x - bounds.x;
		
		if (y > bounds.bottom)
			bounds.height = y - bounds.y;
		
		return bounds;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		final prevNumberOfVertices = numVertices;
		
		inline function addVertex(x:Float, y:Float)
		{
			point.set(x, y).transform(matrix);
			vertices.push(point.x);
			vertices.push(point.y);
		}
		
		addVertex(0, 0);
		addVertex(frame.frame.width, 0);
		addVertex(frame.frame.width, frame.frame.height);
		addVertex(0, frame.frame.height);
		
		uvtData.push(frame.uv.left);
		uvtData.push(frame.uv.top);
		uvtData.push(frame.uv.right);
		uvtData.push(frame.uv.top);
		uvtData.push(frame.uv.right);
		uvtData.push(frame.uv.bottom);
		uvtData.push(frame.uv.left);
		uvtData.push(frame.uv.bottom);
		
		indices.push(prevNumberOfVertices);
		indices.push(prevNumberOfVertices + 1);
		indices.push(prevNumberOfVertices + 2);
		indices.push(prevNumberOfVertices + 2);
		indices.push(prevNumberOfVertices + 3);
		indices.push(prevNumberOfVertices);
		
		final alphaMultiplier = transform != null ? transform.alphaMultiplier : 1.0;
		for (_ in 0...INDICES_PER_QUAD)
			alphas.push(alphaMultiplier);
		
		if (colored || hasColorOffsets)
		{
			var redMultiplier = 1.0;
			var greenMultiplier = 1.0;
			var blueMultiplier = 1.0;
			
			var redOffset = 1.0;
			var greenOffset = 1.0;
			var blueOffset = 1.0;
			var alphaOffset = 1.0;
			
			if (transform != null)
			{
				redMultiplier = transform.redMultiplier;
				greenMultiplier = transform.greenMultiplier;
				blueMultiplier = transform.blueMultiplier;
				
				redOffset = transform.redOffset;
				greenOffset = transform.greenOffset;
				blueOffset = transform.blueOffset;
				alphaOffset = transform.alphaOffset;
			}
			
			for (_ in 0...INDICES_PER_QUAD)
			{
				colorMultipliers.push(redMultiplier);
				colorMultipliers.push(greenMultiplier);
				colorMultipliers.push(blueMultiplier);
				colorMultipliers.push(1);
				
				colorOffsets.push(redOffset);
				colorOffsets.push(greenOffset);
				colorOffsets.push(blueOffset);
				colorOffsets.push(alphaOffset);
			}
		}
	}
	
	override function get_numVertices():Int
	{
		return Std.int(vertices.length / 2);
	}
	
	override function get_numTriangles():Int
	{
		return Std.int(indices.length / 3);
	}
	
	@:noCompletion
	inline function get_verticesPosition():Int
	{
		return vertices.length;
	}
	
	@:noCompletion
	inline function get_indicesPosition():Int
	{
		return indices.length;
	}
	
	@:noCompletion
	inline function get_colorsPosition():Int
	{
		return 0;
	}
}
