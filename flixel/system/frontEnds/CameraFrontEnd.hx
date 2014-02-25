package flixel.system.frontEnds;

import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;

@:allow(flixel.FlxGame)
class CameraFrontEnd
{
	/**
	 * An array listing FlxCamera objects that are used to draw stuff.
	 * By default flixel creates one camera the size of the screen.
	 */
	public var list(default, null):Array<FlxCamera>;
	
	/**
	 * The current (global, applies to all cameras) bgColor.
	 */
	public var bgColor(get, set):Int;
	
	/**
	 * Allows you to possibly slightly optimize the rendering process IF
	 * you are not doing any pre-processing in your game state's draw() call.
	 * @default false
	 */
	public var useBufferLocking:Bool = false;
	/**
	 * Internal helper variable for clearing the cameras each frame.
	 */
	private var _cameraRect:Rectangle;
	
	/**
	 * Add a new camera object to the game.
	 * Handy for PiP, split-screen, etc.
	 * 
	 * @param	NewCamera	The camera you want to add.
	 * @return	This FlxCamera instance.
	 */
	@:generic public inline function add<T:FlxCamera>(NewCamera:T):T
	{
		FlxG.game.addChildAt(NewCamera.flashSprite, FlxG.game.getChildIndex(FlxG.game._inputContainer));
		FlxG.cameras.list.push(NewCamera);
		NewCamera.ID = FlxG.cameras.list.length - 1;
		return NewCamera;
	}
	
	/**
	 * Remove a camera from the game.
	 * 
	 * @param   Camera    The camera you want to remove.
	 * @param   Destroy   Whether to call destroy() on the camera, default value is true.
	 */
	public function remove(Camera:FlxCamera, Destroy:Bool = true):Void
	{
		if ((Camera != null) && FlxG.game.contains(Camera.flashSprite))
		{
			FlxG.game.removeChild(Camera.flashSprite);
			var index = FlxArrayUtil.indexOf(FlxG.cameras.list, Camera);
			
			if (index >= 0)
			{
				FlxG.cameras.list.splice(index, 1);
			}
		}
		else
		{
			FlxG.log.warn("FlxG.cameras.remove(): The camera you attemped to remove is not a part of the game.");
		}
		
		#if !flash
		for (i in 0...list.length)
		{
			list[i].ID = i;
		}
		#end
		
		if (Destroy)
		{
			Camera.destroy();
		}
	}
		
	/**
	 * Dumps all the current cameras and resets to just one camera.
	 * Handy for doing split-screen especially.
	 * 
	 * @param	NewCamera	Optional; specify a specific camera object to be the new main camera.
	 */
	public function reset(?NewCamera:FlxCamera):Void
	{
		for (camera in list)
		{
			FlxG.game.removeChild(camera.flashSprite);
			camera.destroy();
		}
		
		list.splice(0, list.length);
		
		if (NewCamera == null)	
		{
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		}
		
		FlxG.camera = add(NewCamera);
		NewCamera.ID = 0;
	}
	
	/**
	 * All screens are filled with this color and gradually return to normal.
	 * 
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function flash(Color:Int = 0xffffffff, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		for (camera in list)
		{
			camera.flash(Color, Duration, OnComplete, Force);
		}
	}
	
	/**
	 * The screen is gradually filled with this color.
	 * 
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the fade to finish.
	 * @param 	FadeIn 		True fades from a color, false fades to it.
	 * @param	OnComplete	A function you want to run when the fade finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function fade(Color:Int = 0xff000000, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		for (camera in list)
		{
			camera.fade(Color, Duration, FadeIn, OnComplete, Force);
		}
	}
	
	/**
	 * A simple screen-shake effect.
	 * 
	 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * @param	Duration	The length in seconds that the shaking effect should last.
	 * @param	OnComplete	A function you want to run when the shake effect finishes.
	 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
	 * @param	Direction	Whether to shake on both axes, just up and down, or just side to side (use class constants SHAKE_BOTH_AXES, SHAKE_VERTICAL_ONLY, or SHAKE_HORIZONTAL_ONLY).  Default value is SHAKE_BOTH_AXES (0).
	 */
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, Direction:Int = 0):Void
	{
		for (camera in list)
		{
			camera.shake(Intensity, Duration, OnComplete, Force, Direction);
		}
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		_cameraRect = new Rectangle();
		list = new Array<FlxCamera>();
		FlxCamera.defaultCameras = list;
	}
	
	/**
	 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
	 */
	private inline function lock():Void
	{
		for (camera in list)
		{
			if (camera == null || !camera.exists || !camera.visible)
			{
				continue;
			}
			
			#if flash
			camera.checkResize();
			
			if (useBufferLocking)
			{
				camera.buffer.lock();
			}
			#end
			
		#if !flash
			camera.clearDrawStack();
			camera.canvas.graphics.clear();
			// Clearing camera's debug sprite
			#if !FLX_NO_DEBUG
			camera.debugLayer.graphics.clear();
			#end
		#end
			
			#if flash
			camera.fill(camera.bgColor, camera.useBgAlphaBlending);
			camera.screen.dirty = true;
			#else
			camera.fill((camera.bgColor & 0x00ffffff), camera.useBgAlphaBlending, ((camera.bgColor >> 24) & 255) / 255);
			#end
		}
	}
	
	#if !flash
	private inline function render():Void
	{
		for (camera in list)
		{
			if ((camera != null) && camera.exists && camera.visible)
			{
				camera.render();
			}
		}
	}
	#end
	
	/**
	 * Called by the game object to draw the special FX and unlock all the camera buffers.
	 */
	private inline function unlock():Void
	{
		for (camera in list)
		{
			if ((camera == null) || !camera.exists || !camera.visible)
			{
				continue;
			}
			
			camera.drawFX();
			
			#if flash
			if (useBufferLocking)
			{
				camera.buffer.unlock();
			}
			
			camera.screen.resetFrameBitmapDatas();
			#end
		}
	}
	
	/**
	 * Called by the game object to update the cameras and their tracking/special effects logic.
	 */
	private inline function update():Void
	{
		for (camera in list)
		{
			if ((camera != null) && camera.exists)
			{
				if (camera.active)
				{
					camera.update();
				}
				
				if (camera.target == null) 
				{
					camera.flashSprite.x = camera.x + camera._flashOffset.x;
					camera.flashSprite.y = camera.y + camera._flashOffset.y;
				}
				
				camera.flashSprite.visible = camera.visible;
			}
		}
	}
	
	private function get_bgColor():Int
	{
		return (FlxG.camera == null) ? FlxColor.BLACK : FlxG.camera.bgColor;
	} 
	
	private function set_bgColor(Color:Int):Int
	{
		for (camera in list)
		{
			camera.bgColor = Color;
		}
		
		return Color;
	}
}