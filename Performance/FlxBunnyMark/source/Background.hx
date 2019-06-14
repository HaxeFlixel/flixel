package;

import flixel.FlxStrip;
import flixel.FlxG;
import openfl.Lib;

class Background extends FlxStrip
{
	public var cols:Int;
	public var rows:Int;

	public function new()
	{
		super(-50, -50, "assets/grass.png");

		width = FlxG.width + 100;
		height = FlxG.height + 100;

		cols = Std.int(width / frame.sourceSize.x);
		rows = Std.int(height / frame.sourceSize.y);

		build();
	}

	function build():Void
	{
		var sw:Float = width;
		var sh:Float = height;
		var uw:Float = sw / frame.sourceSize.x;
		var uh:Float = sh / frame.sourceSize.y;
		var kx:Float, ky:Float;
		var ci:Int, ci2:Int, ri:Int;

		vertices.splice(0, vertices.length);
		uvtData.splice(0, uvtData.length);
		indices.splice(0, indices.length);

		for (j in 0...rows + 1)
		{
			ri = j * (cols + 1) * 2;
			ky = j / rows;
			for (i in 0...cols + 1)
			{
				ci = ri + i * 2;
				kx = i / cols;
				vertices[ci] = sw * kx;
				vertices[ci + 1] = sh * ky;
				uvtData[ci] = uw * kx;
				uvtData[ci + 1] = uh * ky;
			}
		}

		for (j in 0...rows)
		{
			ri = j * (cols + 1);
			for (i in 0...cols)
			{
				ci = i + ri;
				ci2 = ci + cols + 1;
				indices.push(ci);
				indices.push(ci + 1);
				indices.push(ci2);
				indices.push(ci + 1);
				indices.push(ci2 + 1);
				indices.push(ci2);
			}
		}
	}

	override public function update(elapsed:Float):Void
	{
		var t:Float = Lib.getTimer() / 1000.0;
		var sw:Float = width;
		var sh:Float = height;
		var kx:Float, ky:Float;
		var ci:Int, ri:Int;

		for (j in 0...rows + 1)
		{
			ri = j * (cols + 1) * 2;
			for (i in 0...cols + 1)
			{
				ci = ri + i * 2;
				kx = i / cols + Math.cos(t + i) * 0.02;
				ky = j / rows + Math.sin(t + j + i) * 0.02;
				vertices[ci] = sw * kx;
				vertices[ci + 1] = sh * ky;
			}
		}

		super.update(elapsed);
	}
}
