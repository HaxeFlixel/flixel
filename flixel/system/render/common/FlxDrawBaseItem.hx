package flixel.system.render.common;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.hardware.FlxHardwareView;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;

#if (openfl < "4.0.0")
import openfl.display.Tilesheet;
#end

/**
 * ...
 * @author Zaphod
 */
class FlxDrawBaseItem<T>
{
	#if (openfl < "4.0.0")
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
			#if (!lime_legacy && openfl > "3.3.1")
			case BlendMode.DARKEN:
				Tilesheet.TILE_BLEND_DARKEN;
			case BlendMode.LIGHTEN:
				Tilesheet.TILE_BLEND_LIGHTEN;
			case BlendMode.OVERLAY:
				Tilesheet.TILE_BLEND_OVERLAY;
			case BlendMode.HARDLIGHT:
				Tilesheet.TILE_BLEND_HARDLIGHT;
			case BlendMode.DIFFERENCE:
				Tilesheet.TILE_BLEND_DIFFERENCE;
			case BlendMode.INVERT:
				Tilesheet.TILE_BLEND_INVERT;
			#end
			#end
			default:
				Tilesheet.TILE_BLEND_NORMAL;
		}
	}
	#end
	
	public var nextTyped:T;
	
	public var next:FlxDrawBaseItem<T>;
	
	public var graphics:FlxGraphic;
	public var antialiasing:Bool = false;
	public var colored:Bool = false;
	public var hasColorOffsets:Bool = false;
	public var blending:BlendMode = null;
	public var shader:FlxShader;
	
	public var type:FlxDrawItemType;
	
	public var numVertices(get, never):Int;
	
	public var numTriangles(get, never):Int;
	
	public var elementsPerVertex(get, null):Int;
	
	public var elementsPerQuad(get, null):Int;
	
	public function new() {}
	
	public function reset():Void
	{
		graphics = null;
		antialiasing = false;
		hasColorOffsets = false;
		colored = false;
		blending = null;
		shader = null;
		nextTyped = null;
		next = null;
	}
	
	public function dispose():Void
	{
		graphics = null;
		blending = null;
		shader = null;
		next = null;
		type = null;
		nextTyped = null;
	}
	
	public function render(view:FlxHardwareView):Void {}
	
	public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void {}
	
	public function equals(type:FlxDrawItemType, graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader):Bool
	{
		return (this.type == type 
			&& this.graphics == graphic 
			&& this.colored == colored
			&& this.hasColorOffsets == hasColorOffsets
			&& this.blending == blend
			&& this.antialiasing == smooth
			&& this.shader == shader);
	}
	
	public inline function set(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader):Void
	{
		this.graphics = graphic;
		this.colored = colored;
		this.hasColorOffsets = hasColorOffsets;
		this.blending = blend;
		this.antialiasing = smooth;
		this.shader = shader;
	}
	
	public function canAddQuad():Bool
	{
		return true;
	}
	
	public function canAddTriangles(numVertices:Int, numIndices:Int):Bool
	{
		return true;
	}
	
	private function get_numVertices():Int
	{
		return 0;
	}
	
	private function get_numTriangles():Int
	{
		return 0;
	}
	
	private function get_elementsPerVertex():Int
	{
		return 0;
	}
	
	private function get_elementsPerQuad():Int
	{
		return 0;
	}
}
