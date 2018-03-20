package flixel.graphics.tile;

import flixel.system.FlxAssets;
import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import openfl.Vector;

class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{
	public var shader:FlxShader;

	var rects:Vector<Float>;
	var transforms:Vector<Float>;
	var alpha:Array<Float>;
	var colorMultipliers:Array<Float>;
	var colorOffsets:Array<Float>;

	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
		rects = new Vector<Float>();
		transforms = new Vector<Float>();
		alpha = [];
	}
	
	override public function reset():Void
	{
		super.reset();
		rects.splice(0, rects.length);
		transforms.splice(0, transforms.length);
		alpha.splice(0, alpha.length);
		if (colorMultipliers != null)
			colorMultipliers.splice(0, colorMultipliers.length);
		if (colorOffsets != null)
			colorOffsets.splice(0, colorOffsets.length);
	}
	
	override public function dispose():Void
	{
		super.dispose();
		rects = null;
		transforms = null;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var rect = frame.frame;
		rects.push(rect.x);
		rects.push(rect.y);
		rects.push(rect.width);
		rects.push(rect.height);

		transforms.push(matrix.a);
		transforms.push(matrix.b);
		transforms.push(matrix.c);
		transforms.push(matrix.d);
		transforms.push(matrix.tx);
		transforms.push(matrix.ty);

		for (i in 0...6)
			alpha.push(transform != null ? transform.alphaMultiplier : 1.0);

		if (colored)
		{
			if (colorMultipliers == null)
				colorMultipliers = [];

			for (i in 0...6)
			{
				if (transform != null)
				{
					colorMultipliers.push(transform.redMultiplier);
					colorMultipliers.push(transform.greenMultiplier);
					colorMultipliers.push(transform.blueMultiplier);
				}
				else
				{
					colorMultipliers.push(1);
					colorMultipliers.push(1);
					colorMultipliers.push(1);
				}

				colorMultipliers.push(1);
			}
		}

		if (hasColorOffsets)
		{
			if (colorOffsets == null)
				colorOffsets = [];

			for (i in 0...6)
			{
				if (transform != null)
				{
					colorOffsets.push(transform.redOffset);
					colorOffsets.push(transform.greenOffset);
					colorOffsets.push(transform.blueOffset);
					colorOffsets.push(transform.alphaOffset);
				}
				else
				{
					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
				}
			}
		}
	}
	
	override public function render(camera:FlxCamera):Void
	{
		if (rects.length == 0)
			return;

		var shader = shader != null ? shader : graphics.shader;
		shader.data.texture0.input = graphics.bitmap;
		shader.data.texture0.smoothing = camera.antialiasing || antialiasing;
		shader.data.alpha.value = alpha;
		shader.data.colorMultipliers.value = colorMultipliers;
		shader.data.colorOffsets.value = colorOffsets;

		camera.canvas.graphics.beginShaderFill(shader);
		camera.canvas.graphics.drawQuads(rects, null, transforms);
		super.render(camera);
	}
}
