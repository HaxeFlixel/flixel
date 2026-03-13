package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.system.render.FlxRenderer;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;

/**
 * @author Zaphod
 */
class FlxDrawBaseItem<T>
{
	/**
	 * Tracks the total number of draw calls made each frame.
	 */
	@:deprecated("drawCalls is deprecated, use FlxG.renderer.totalDrawCalls instead")
	public static var drawCalls(get, set):Int;

	static function set_drawCalls(value:Int):Int
	{
		return FlxG.renderer.totalDrawCalls = value;
	}

	static function get_drawCalls():Int
	{
		return FlxG.renderer.totalDrawCalls;
	}

	@:noCompletion
	@:deprecated("blendToInt() is deprecated, remove all references to it")
	public static function blendToInt(blend:BlendMode):Int
	{
		return 0; // no blend mode support in drawQuads()
	}

	public var nextTyped:T;

	public var next:FlxDrawBaseItem<T>;

	public var graphics:FlxGraphic;
	public var antialiasing:Bool = false;
	public var colored:Bool = false;
	public var hasColorOffsets:Bool = false;
	public var blend:BlendMode;

	@:noCompletion
	@:deprecated("blending is deprecated, remove all references to it")
	public var blending:Int = 0;

	public var type:FlxDrawItemType;

	public var numVertices(get, never):Int;

	public var numTriangles(get, never):Int;

	public function new() {}

	public function reset():Void
	{
		graphics = null;
		antialiasing = false;
		nextTyped = null;
		next = null;
	}

	public function dispose():Void
	{
		graphics = null;
		next = null;
		type = null;
		nextTyped = null;
	}

	public function render(camera:FlxCamera):Void
	{
		FlxG.renderer.totalDrawCalls++;
	}

	public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void {}

	function get_numVertices():Int
	{
		return 0;
	}

	function get_numTriangles():Int
	{
		return 0;
	}
}

enum FlxDrawItemType
{
	TILES;
	TRIANGLES;
}
