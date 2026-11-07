package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import openfl.Vector;
import openfl.display.ShaderParameter;
import openfl.geom.ColorTransform;

inline var VERTICES_PER_QUAD = 4;

#if !flash @:nullSafety(Strict) #end
class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{
	static inline var VERTICES_PER_QUAD = 4;
	
	public var shader:Null<FlxShader> = null;
	
	final rects = new RectVector();
	final transforms = new MatrixVector();
	final colorMultipliers = new ColorMultVector();
	final colorOffsets = new ColorOffsetVector();
	final alphas = new AlphaVector();
	
	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
	}
	
	override public function reset():Void
	{
		super.reset();
		rects.clear();
		transforms.clear();
		alphas.clear();
		colorMultipliers.clear();
		colorOffsets.clear();
	}
	
	override public function dispose():Void
	{
		super.dispose();
		rects.clear();
		transforms.clear();
		alphas.clear();
		colorMultipliers.clear();
		colorOffsets.clear();
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		final prevQuads = Math.round(rects.length / VERTICES_PER_QUAD);
		
		rects.push(frame.frame);
		transforms.push(matrix);
		alphas.push(transform);
		
		if (colored || hasColorOffsets)
		{
			if (colorMultipliers.numQuads < prevQuads)
				colorMultipliers.padTo(prevQuads);
			
			if (colorOffsets.numQuads < prevQuads)
				colorOffsets.padTo(prevQuads);
			
			colorMultipliers.push(transform);
			colorOffsets.push(transform);
		}
	}

	#if !flash
	override public function render(camera:FlxCamera):Void
	{
		if (rects.length == 0)
			return;
		
		// TODO: catch this error when the dev actually messes up, not in the draw phase
		if (shader == null && graphics.isDestroyed)
			throw 'Attempted to render an invalid FlxDrawItem, did you destroy a cached sprite?';
		
		final shader = shader != null ? shader : graphics.shader;
		shader.bitmap.input = graphics.bitmap;
		shader.bitmap.filter = (camera.antialiasing || antialiasing) ? LINEAR : NEAREST;
		shader.alpha.value = alphas.toShaderValue();
		
		if (colored || hasColorOffsets)
		{
			shader.colorMultiplier.value = colorMultipliers.toShaderValue();
			shader.colorOffset.value = colorOffsets.toShaderValue();
		}
		
		setParameterValue(shader.hasTransform, true);
		setParameterValue(shader.hasColorTransform, colored || hasColorOffsets);
		
		camera.canvas.graphics.overrideBlendMode(blend);
		camera.canvas.graphics.beginShaderFill(shader);
		camera.canvas.graphics.drawQuads(rects.toShaderValue(), null, transforms.toShaderValue());
		camera.canvas.graphics.endFill();
		super.render(camera);
	}

	inline function setParameterValue(parameter:ShaderParameter<Bool>, value:Bool):Void
	{
		if (parameter.value == null)
			parameter.value = [];
		
		parameter.value[0] = value;
	}
	#end
}

@:forward
private abstract RectVector(Vector<Float>)
{
	inline public function new () this = new Vector<Float>();
	
	inline public function clear()
	{
		this.splice(0, this.length);
	}
	
	overload public inline extern function push(x:Float, y:Float, width:Float, height:Float)
	{
		this.push(x);
		this.push(y);
		this.push(width);
		this.push(height);
	}
	
	overload public inline extern function push(rect:FlxRect)
	{
		push(rect.x, rect.y, rect.width, rect.height);
	}
	
	inline public function toShaderValue():Vector<Float>
	{
		return this;
	}
}

@:forward
private abstract MatrixVector(Vector<Float>)
{
	inline public function new () this = new Vector<Float>();
	
	inline public function clear()
	{
		this.splice(0, this.length);
	}
	
	overload public inline extern function push(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float)
	{
		this.push(a);
		this.push(b);
		this.push(c);
		this.push(d);
		this.push(tx);
		this.push(ty);
	}
	
	overload public inline extern function push(matrix:FlxMatrix)
	{
		push(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
	}
	
	inline public function toShaderValue():Vector<Float>
	{
		return this;
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
	
	overload public inline extern function push(alpha:Float)
	{
		for (i in 0...VERTICES_PER_QUAD)
			this.push(alpha);
	}
	
	overload public inline extern function push(transform:Null<ColorTransform>)
	{
		push(transform == null ? 1.0 : transform.alphaMultiplier);
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}

@:forward
private abstract ColorVector(Array<Float>)
{
	public var numQuads(get, never):Int;
	inline function get_numQuads() return Math.round(this.length / VERTICES_PER_QUAD / 4);
	
	inline public function new ()
	{
		this = new Array<Float>();
	}
	
	inline public function clear()
	{
		this.resize(0);
	}
	
	overload public inline extern function push(red:Float, green:Float, blue:Float, alpha:Float)
	{
		for (i in 0...VERTICES_PER_QUAD)
		{
			this.push(red);
			this.push(green);
			this.push(blue);
			this.push(alpha);
		}
	}
	
	inline public function toShaderValue():Array<Float>
	{
		return this;
	}
}

@:forward
private abstract ColorMultVector(ColorVector)
{
	inline public function new () this = new ColorVector();
	
	inline public function padTo(newLength:Int)
	{
		final length = this.numQuads;
		while (newLength-- > length)
			pushDefault();
	}
	
	inline public function pushDefault()
	{
		this.push(1, 1, 1, 1);
	}
	
	overload public inline extern function push(transform:Null<ColorTransform>)
	{
		if (transform == null)
			pushDefault();
		else
			this.push(transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier, 1);
	}
}

@:forward
private abstract ColorOffsetVector(ColorVector)
{
	inline public function new () this = new ColorVector();
	
	inline public function padTo(newLength:Int)
	{
		final length = this.numQuads;
		while (newLength-- > length)
			pushDefault();
	}
	
	inline public function pushDefault()
	{
		this.push(0, 0, 0, 0);
	}
	
	overload public inline extern function push(transform:Null<ColorTransform>)
	{
		if (transform == null)
			pushDefault();
		else
			this.push(transform.redOffset, transform.greenOffset, transform.blueOffset, transform.alphaOffset);
	}
}