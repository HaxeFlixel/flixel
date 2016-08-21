package flixel.system.render.gl;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawStack;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Zaphod
 */
class FlxGlView extends FlxCameraView
{
	public var drawStack:FlxDrawStack;
	
	public var renderView:HardwareRenderer;
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		drawStack = new FlxDrawStack(this);
		renderView = new HardwareRenderer(camera.width, camera.height);
	}
	
	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		drawStack.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
	}
	
	override public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		drawStack.copyPixels(frame, pixels, sourceRect, destPoint, transform, blend, smoothing, shader);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		FlxDestroyUtil.destroy(renderView);
	}
	
	override private function render():Void
	{
		drawStack.render();
	}
	
	override public function lock(useBufferLocking:Bool):Void 
	{
		drawStack.clearDrawStack();
		renderView.clear();
	}
	
	override function get_display():DisplayObject 
	{
		return renderView;
	}
	
	public function drawItem(item:FlxDrawHardwareItem<Dynamic>):Void
	{
		renderView.drawItem(item);
	}
	
}