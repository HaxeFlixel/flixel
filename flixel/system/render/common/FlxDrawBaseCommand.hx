package flixel.system.render.common;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.hardware.FlxHardwareView;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;

#if (openfl < "4.0.0")
import openfl.display.Tilesheet;
#end

/**
 * ...
 * @author Zaphod
 */
class FlxDrawBaseCommand<T> implements IFlxDestroyable
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
	
	public var next:FlxDrawBaseCommand<T>;
	
	public var graphics:FlxGraphic;
	public var smoothing:Bool = false;
	public var colored:Bool = false;
	public var hasColorOffsets:Bool = false;
	public var blending:BlendMode = null;
	public var shader:FlxShader;
	public var repeat:Bool = true;
	
	public var type:FlxDrawItemType;
	
	public var numVertices(get, never):Int;
	
	public var numTriangles(get, never):Int;
	
	public var elementsPerVertex(get, null):Int;
	
	public var textured(get, null):Bool;
	
	public function new() {}
	
	public function reset():Void
	{
		graphics = null;
		smoothing = false;
		hasColorOffsets = false;
		colored = false;
		repeat = true;
		blending = null;
		shader = null;
		nextTyped = null;
		next = null;
	}
	
	public function destroy():Void
	{
		graphics = null;
		blending = null;
		shader = null;
		next = null;
		nextTyped = null;
		type = null;
	}
	
	public function render(view:FlxHardwareView):Void {}
	
	public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool):Void {}
	
	public function addUVQuad(texture:FlxGraphic, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool):Void {}
	
	public function equals(type:FlxDrawItemType, graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, repeat:Bool = true, ?shader:FlxShader):Bool
	{
		if (hasColorOffsets)	return false;
		
		return (this.type == type 
			&& this.graphics == graphic 
			&& this.colored == colored
			&& this.hasColorOffsets == hasColorOffsets
			&& this.blending == blend
			&& this.smoothing == smooth
			&& this.repeat == repeat
			&& this.shader == shader);
	}
	
	public /*inline*/ function set(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, repeat:Bool = true, ?shader:FlxShader):Void
	{
		this.graphics = graphic;
		this.colored = colored;
		this.hasColorOffsets = hasColorOffsets;
		this.blending = blend;
		this.smoothing = smooth;
		this.repeat = repeat;
		this.shader = shader;
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
	
	private inline function get_textured():Bool
	{
		return (graphics != null);
	}
}
