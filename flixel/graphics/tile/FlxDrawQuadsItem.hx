package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.system.FlxAssets;
import flixel.system.FlxBuffer;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import openfl.geom.ColorTransform;
import openfl.display.ShaderParameter;
import openfl.Vector;

typedef QuadRectRaw = { x:Float, y:Float, width:Float, height:Float };
@:forward
abstract QuadRect(QuadRectRaw) from QuadRectRaw to QuadRectRaw
{
	@:from
	public static inline function fromFlxRect(rect:FlxRect):QuadRect
	{
		return { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
	}
	
	@:from
	public static inline function fromRect(rect:openfl.geom.Rectangle):QuadRect
	{
		return { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
	}
	
	public inline function toFlxRect(rect:FlxRect):FlxRect
	{
		return rect.set(this.x, this.y, this.width, this.height);
	}
}

typedef QuadTransformRaw = { a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float };
@:forward
abstract QuadTransform(QuadTransformRaw) from QuadTransformRaw to QuadTransformRaw
{
	@:from
	public static inline function fromMatrix(matrix:FlxMatrix):QuadTransform
	{
		return { a: matrix.a, b: matrix.b, c: matrix.c, d: matrix.d, tx: matrix.tx, ty: matrix.ty };
	}
	
	public inline function toMatrix(matrix:FlxMatrix):FlxMatrix
	{
		matrix.setTo(this.a, this.b, this.c, this.d, this.tx, this.ty);
		return matrix;
	}
}

typedef QuadColorMult = { r:Float, g:Float, b:Float, a:Float };
typedef QuadColorOffset = { r:Float, g:Float, b:Float, a:Float };

class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{
	static inline var VERTICES_PER_QUAD = #if (openfl >= "8.5.0") 4 #else 6 #end;

	public var shader:FlxShader;

	var rects:FlxBuffer<QuadRect>;
	var transforms:FlxBuffer<QuadTransform>;
	var alphas:Array<Float>;
	var colorMultipliers:FlxBufferArray<QuadColorMult>;
	var colorOffsets:FlxBufferArray<QuadColorOffset>;

	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
		rects = new FlxBuffer<QuadRect>();
		transforms = new FlxBuffer<QuadTransform>();
		alphas = [];
	}

	override public function reset():Void
	{
		super.reset();
		rects.resize(0);
		transforms.resize(0);
		alphas.resize(0);
		if (colorMultipliers != null)
			colorMultipliers.resize(0);
		if (colorOffsets != null)
			colorOffsets.resize(0);
	}

	override public function dispose():Void
	{
		super.dispose();
		rects = null;
		transforms = null;
		alphas = null;
		colorMultipliers = null;
		colorOffsets = null;
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		rects.push(frame.frame);
		transforms.push(matrix);

		var alphaMultiplier = transform != null ? transform.alphaMultiplier : 1.0;
		for (i in 0...VERTICES_PER_QUAD)
			alphas.push(alphaMultiplier);

		if (colored || hasColorOffsets)
		{
			if (colorMultipliers == null)
				colorMultipliers = [];

			if (colorOffsets == null)
				colorOffsets = [];

			for (i in 0...VERTICES_PER_QUAD)
			{
				if (transform != null)
				{
					colorMultipliers.push(transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier, 1);
					colorOffsets.push(transform.redOffset, transform.greenOffset, transform.blueOffset, transform.alphaOffset);
				}
				else
				{
					colorMultipliers.push(1, 1, 1, 1);
					colorOffsets.push(0, 0, 0, 0);
				}
			}
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
		shader.alpha.value = alphas;

		if (colored || hasColorOffsets)
		{
			shader.colorMultiplier.value = colorMultipliers;
			shader.colorOffset.value = colorOffsets;
		}

		setParameterValue(shader.hasTransform, true);
		setParameterValue(shader.hasColorTransform, colored || hasColorOffsets);

		#if (openfl > "8.7.0")
		camera.canvas.graphics.overrideBlendMode(blend);
		#end
		camera.canvas.graphics.beginShaderFill(shader);
		camera.canvas.graphics.drawQuads(rects, null, transforms);
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