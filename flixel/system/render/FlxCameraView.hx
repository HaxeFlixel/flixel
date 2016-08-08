package flixel.system.render;
import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Zaphod
 */
class FlxCameraView
{
	public var display(get, null):DisplayObject;
	
	public var camera(default, null):FlxCamera;
	
	// TODO: try to avoid using this variable.
	// need to move functionality related to this var into FlxStrip
	/**
	 * Internal variable, used for visibility checks to minimize drawTriangles() calls.
	 */
	private static var drawVertices:Vector<Float> = new Vector<Float>();
	
	public function new(camera:FlxCamera) 
	{
		this.camera = camera;
	}
	
	public function init():Void
	{
		
	}
	
	public function destroy():Void
	{
		
	}
	
	public function updatePosition():Void
	{
		
	}
	
	public function updateScrollRect():Void
	{
		
	}
	
	public function updateInternals():Void
	{
		
	}
	
	public function fill():Void
	{
		
	}
	
	public function setFilters():Void
	{
		
	}
	
	public function render():Void
	{
		
	}
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		
	}
	
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>,
		uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint, ?blend:BlendMode,
		repeat:Bool = false, smoothing:Bool = false):Void
	{
		
	}
	
	public function setColor(Color:FlxColor):FlxColor
	{
		return Color;
	}
	
	private function get_display():DisplayObject
	{
		return null;
	}
	
}