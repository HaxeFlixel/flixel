package flixel.graphics.tile;
import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import openfl.display.BlendMode;
import openfl.display.Tilesheet;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawBaseItem<T>
{
	public static function blendToInt(blend:BlendMode):Int
	{
		if (blend == null)
			return Tilesheet.TILE_BLEND_NORMAL;
		
		return switch (blend)
		{
			case BlendMode.ADD:
				Tilesheet.TILE_BLEND_ADD;
			#if !flash
			case BlendMode.MULTIPLY:
				Tilesheet.TILE_BLEND_MULTIPLY;
			case BlendMode.SCREEN:
				Tilesheet.TILE_BLEND_SCREEN;
			case BlendMode.SUBTRACT:
				Tilesheet.TILE_BLEND_SUBTRACT;
			#end
			default:
				Tilesheet.TILE_BLEND_NORMAL;
		}
	}
	
	public var nextTyped:T;
	
	public var next:FlxDrawBaseItem<T>;
	
	public var graphics:FlxGraphic;
	public var antialiasing:Bool = false;
	public var colored:Bool = false;
	public var blending:Int = 0;
	
	public var type:FlxDrawItemType;
	
	public var numVertices(get, never):Int;
	
	public var numTriangles(get, never):Int;
	
	public function new() {  }
	
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
	
	public function render(camera:FlxCamera):Void {  }
	
	public function addQuad(frame:FlxFrame, matrix:FlxMatrix,
		red:Float = 1, green:Float = 1, blue:Float = 1, alpha:Float = 1):Void {  }
	
	private function get_numVertices():Int
	{
		return 0;
	}
	
	private function get_numTriangles():Int
	{
		return 0;
	}
}

enum FlxDrawItemType 
{
	TILES;
	TRIANGLES;
}