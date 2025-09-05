package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.system.FlxAssets.FlxShader;
import openfl.Vector;
import openfl.display.ShaderParameter;
import openfl.geom.ColorTransform;

class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{
	static inline final VERTICES_PER_QUAD = 4;
	
	public var shader:FlxShader;
	
	var rects:Vector<Float> = new Vector<Float>();
	var transforms:Vector<Float> = new Vector<Float>();
	var alphas:Array<Float> = [];
	var colorMultipliers:Array<Float> = [];
	var colorOffsets:Array<Float> = [];
	
	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
	}
	
	override public function reset():Void
	{
		super.reset();
		rects.length = 0;
		transforms.length = 0;
		alphas.resize(0);
		colorMultipliers.resize(0);
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
		rects.push(frame.frame.x);
		rects.push(frame.frame.y);
		rects.push(frame.frame.width);
		rects.push(frame.frame.height);
		
		transforms.push(matrix.a);
		transforms.push(matrix.b);
		transforms.push(matrix.c);
		transforms.push(matrix.d);
		transforms.push(matrix.tx);
		transforms.push(matrix.ty);
		
		final alphaMultiplier = transform != null ? transform.alphaMultiplier : 1.0;
		for (_ in 0...VERTICES_PER_QUAD)
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
			
			for (_ in 0...VERTICES_PER_QUAD)
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
		else
		{
			shader.colorMultiplier.value = null;
			shader.colorOffset.value = null;
		}
		
		setParameterValue(shader.hasTransform, true);
		setParameterValue(shader.hasColorTransform, colored || hasColorOffsets);
		
		camera.canvas.graphics.overrideBlendMode(blend);
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