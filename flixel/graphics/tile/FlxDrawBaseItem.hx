package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawBaseItem<T>
{
	public static function blendToInt(blend:BlendMode):Int
	{
		if (blend == null)
			return FlxTilesheet.TILE_BLEND_NORMAL;
		
		return switch (blend)
		{
			case BlendMode.ADD:
				FlxTilesheet.TILE_BLEND_ADD;
			#if !flash
			case BlendMode.MULTIPLY:
				FlxTilesheet.TILE_BLEND_MULTIPLY;
			case BlendMode.SCREEN:
				FlxTilesheet.TILE_BLEND_SCREEN;
			case BlendMode.SUBTRACT:
				FlxTilesheet.TILE_BLEND_SUBTRACT;
			#if !lime_legacy
			case BlendMode.DARKEN:
				FlxTilesheet.TILE_BLEND_DARKEN;
			case BlendMode.LIGHTEN:
				FlxTilesheet.TILE_BLEND_LIGHTEN;
			case BlendMode.OVERLAY:
				FlxTilesheet.TILE_BLEND_OVERLAY;
			case BlendMode.HARDLIGHT:
				FlxTilesheet.TILE_BLEND_HARDLIGHT;
			case BlendMode.DIFFERENCE:
				FlxTilesheet.TILE_BLEND_DIFFERENCE;
			case BlendMode.INVERT:
				FlxTilesheet.TILE_BLEND_INVERT;
			#end
			#end
			default:
				FlxTilesheet.TILE_BLEND_NORMAL;
		}
	}
	
	public var nextTyped:T;
	
	public var next:FlxDrawBaseItem<T>;
	
	public var graphics:FlxGraphic;
	public var antialiasing:Bool = false;
	public var colored:Bool = false;
	public var hasColorOffsets:Bool = false;
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
	
	public function render(camera:FlxCamera):Void {}
	
	public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void {}
	
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
