package flixel.system.render.common;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Zaphod
 */
class FlxCameraView implements IFlxDestroyable
{
	/**
	 * Tracks total number of drawTiles() calls made each frame.
	 */
	public static var _DRAWCALLS:Int = 0;
	
	public var display(get, null):DisplayObject;
	
	public var camera(default, null):FlxCamera;
	
	public var antialiasing(get, set):Bool;
	
	public var color(get, set):FlxColor;
	
	public var alpha(get, set):Float;
	
	public var visible(get, set):Bool;
	
	public var angle(get, set):Float;

	
	/**
	 * Internal, used for positioning camera's flashSprite on screen.
	 * Basically it represents position of camera's center point in game sprite.
	 * It's recalculated every time you resize game or camera.
	 * Its value dependes on camera's size (width and height), game's scale and camera's initial zoom factor.
	 * Do not modify it unless you know what are you doing.
	 */
	private var _flashOffset:FlxPoint = FlxPoint.get();
	
	/**
	 * Internal, the filters array to be applied to the camera.
	 */
	private var _filters:Array<BitmapFilter>;
	
	/**
	 * Helper rect for drawTriangles visibility checks
	 */
	@:allow(flixel.system.render)
	private var _bounds:FlxRect = FlxRect.get();
	
	public var bounds(get, null):FlxRect;
	
	public function new(camera:FlxCamera) 
	{
		this.camera = camera;
	}
	
	public function destroy():Void
	{
		display = null;
		_filters = null;
		_bounds = null;
		camera = null;
		_flashOffset = FlxDestroyUtil.put(_flashOffset);
	}
	
	public function updateOffset():Void
	{
		_flashOffset.x = camera.width * 0.5 * FlxG.scaleMode.scale.x * camera.initialZoom;
		_flashOffset.y = camera.height * 0.5 * FlxG.scaleMode.scale.y * camera.initialZoom;
	}
	
	public function updatePosition():Void { }
	
	public function updateScrollRect():Void { }
	
	public function updateInternals():Void { }
	
	public function updateFilters():Void { }
	
	public function updateScale():Void { }
	
	public function checkResize():Void { }
	
	public function fill(Color:FlxColor, BlendAlpha:Bool = true, Alpha:Float = 1.0):Void { }
	
	public function drawFX(FxColor:FlxColor, FxAlpha:Float = 1.0):Void { }
	
	public function lock(useBufferLocking:Bool):Void { }
	
	public function unlock(useBufferLocking:Bool):Void { }
	
	public function clear():Void { }
	
	public function offsetView(X:Float, Y:Float):Void { }
	
	public function setFilters(filters:Array<BitmapFilter>):Void 
	{ 
		_filters = filters;
	}
	
	@:allow(flixel.FlxCamera)
	private function render():Void { }
	
	public function beginDrawDebug():Graphics
	{
		return null;
	}
	
	public function endDrawDebug():Void { }
	
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
	
	private function get_color():FlxColor
	{
		return camera.color;
	}
	
	private function set_color(Color:FlxColor):FlxColor
	{
		return Color;
	}
	
	private function get_alpha():Float
	{
		return camera.alpha;
	}
	
	private function set_alpha(Alpha:Float):Float
	{
		return Alpha;
	}
	
	private function set_antialiasing(Antialiasing:Bool):Bool
	{
		return Antialiasing;
	}
	
	private function get_antialiasing():Bool
	{
		return camera.antialiasing;
	}
	
	private function get_visible():Bool
	{
		return camera.visible;
	}
	
	private function set_visible(visible:Bool):Bool
	{
		return visible;
	}
		
	private function get_angle():Float
	{
		return camera.angle;
	}
	
	private function set_angle(Angle:Float):Float
	{
		return Angle;
	}
	
	private function get_display():DisplayObject
	{
		return null;
	}
	
	private function get_bounds():FlxRect
	{
		_bounds.set(0, 0, camera.width, camera.height);
		return _bounds;
	}
	
}