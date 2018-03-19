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
	static inline var ITEMS_PER_RECT = 4;
	static inline var ITEMS_PER_TRANSFORM = 6;

	public var shader:FlxShader;

	var rects:Vector<Float>;
	var transforms:Vector<Float>;

	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
		rects = new Vector<Float>();
		transforms = new Vector<Float>();
	}
	
	override public function reset():Void
	{
		super.reset();
		rects.splice(0, rects.length);
		transforms.splice(0, transforms.length);
	}
	
	override public function dispose():Void
	{
		super.dispose();
		rects = null;
		transforms = null;
		shader = null;
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
	}
	
	override public function render(camera:FlxCamera):Void
	{
		if (shader == null)
			shader = new FlxShader();
		shader.data.texture0.input = graphics.bitmap;

		camera.canvas.graphics.beginShaderFill(shader);
		camera.canvas.graphics.drawQuads(rects, null, transforms);
		FlxDrawBaseItem.drawCalls++;
	}
	
	private function get_numTiles():Int
	{
		return 0;
	}
	
	override private function get_numVertices():Int
	{
		return 0;
	}
	
	override private function get_numTriangles():Int
	{
		return 0;
	}
}