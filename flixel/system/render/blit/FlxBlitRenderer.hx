package flixel.system.render.blit;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.render.FlxRenderer;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:access(flixel.FlxCamera)
@:access(flixel.system.render.blit)
class FlxBlitRenderer extends FlxTypedRenderer<FlxBlitView>
{
	/**
	 * Whether the camera's buffer should be locked and unlocked during render calls.
	 * 
	 * Allows you to possibly slightly optimize the rendering process IF
	 * you are not doing any pre-processing in your game state's draw() call.
	 * 
	 * This property only has effects when targeting Flash.
	 */
	public var useBufferLocking:Bool = false;
	
	public function new()
	{
		super();
		method = BLITTING;
	}
	
	override function initGlobals()
	{
		super.initGlobals();
		
		FlxObject.defaultPixelPerfectPosition = true;
	}
	
	public function createCameraView(camera:FlxCamera)
	{
		return new FlxBlitView(camera);
	}
}
