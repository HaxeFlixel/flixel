package flixel.system.frontEnds;

#if FLX_RENDER_TILE
import com.asliceofcrazypie.flash.Batcher;
#end

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
	public var list(default, null):Array<FlxCamera> = [];
	
	/**
	 * The current (global, applies to all cameras) bgColor.
	 */
	public var bgColor(get, set):FlxColor;
	
	/**
	 * Allows you to possibly slightly optimize the rendering process IF
	 * you are not doing any pre-processing in your game state's draw() call.
	 */
	public var useBufferLocking:Bool = false;
	/**
	 * Internal helper variable for clearing the cameras each frame.
	 */
	private var _cameraRect:Rectangle = new Rectangle();
	
	/**
	 * Add a new camera object to the game.
	 * Handy for PiP, split-screen, etc.
	 * 
	 * @param	NewCamera	The camera you want to add.
	 * @return	This FlxCamera instance.
	 */
	@:generic
	public inline function add<T:FlxCamera>(NewCamera:T):T
	{
		#if !js
		FlxG.game.addChildAt(NewCamera.flashSprite, FlxG.game.getChildIndex(FlxG.game._inputContainer));
		#end
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
		var index:Int = list.indexOf(Camera);
		if ((Camera != null) && index != -1)
		{
			#if !js
			FlxG.game.removeChild(Camera.flashSprite);
			#end
			
			list.splice(index, 1);
		}
		else
		{
			FlxG.log.warn("FlxG.cameras.remove(): The camera you attemped to remove is not a part of the game.");
		}
		
		#if FLX_RENDER_TILE
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
		#if !js
		for (camera in list)
		{
			FlxG.game.removeChild(camera.flashSprite);
			camera.destroy();
		}
		#end
		
		list.splice(0, list.length);
		
		if (NewCamera == null)	
		{
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		}
		
		FlxG.camera = add(NewCamera);
		NewCamera.ID = 0;
		
		FlxCamera.defaultCameras = list;
	}
	
	/**
	 * All screens are filled with this color and gradually return to normal.
	 * 
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function flash(Color:FlxColor = 0xffffffff, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
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
	public function fade(Color:FlxColor = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void
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
	 * @param	Direction	Whether to shake on both axes, just up and down, or just side to side. Default value is BOTH_AXES.
	 */
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, ?Direction:FlxCameraShakeDirection):Void
	{
		for (camera in list)
		{
			camera.shake(Intensity, Duration, OnComplete, Force, Direction);
		}
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		FlxCamera.defaultCameras = list;
	}
	
	/**
	 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
	 */
	private inline function lock():Void
	{
		#if FLX_RENDER_TILE
		Batcher.clear();
		#end
		
		for (camera in list)
		{
			if (camera == null || !camera.exists || !camera.visible)
			{
				continue;
			}
			
		#if FLX_RENDER_BLIT
			camera.checkResize();
			
			if (useBufferLocking)
			{
				camera.buffer.lock();
			}
		#end
			
		#if FLX_RENDER_TILE
			// Clearing camera's debug sprite
			#if !FLX_NO_DEBUG
			camera.debugLayer.graphics.clear();
			#end
		#end
			
			#if FLX_RENDER_BLIT
			camera.fill(camera.bgColor, camera.useBgAlphaBlending);
			camera.screen.dirty = true;
			#else
			camera.viewport.bgColor = camera.bgColor;
			camera.viewport.useBgColor = true;
			#end
		}	
	}
	
	#if FLX_RENDER_TILE
	private inline function render():Void
	{
		#if !flash11
		Batcher.render();
		#end
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
			
			#if FLX_RENDER_BLIT
			if (useBufferLocking)
			{
				camera.buffer.unlock();
			}
			
			camera.screen.dirty = true;
			#end
		}
	}
	
	/**
	 * Called by the game object to update the cameras and their tracking/special effects logic.
	 */
	private inline function update(elapsed:Float):Void
	{
		for (camera in list)
		{
			if (camera != null && camera.exists && camera.active)
			{
				camera.update(elapsed);
			}
		}
	}
	
	/**
	 * Resizes and moves cameras when the game resizes (onResize signal).
	 */
	private function resize():Void
	{
		for (camera in list)
		{
			camera.onResize();
		}
	}
	
	private function get_bgColor():FlxColor
	{
		return (FlxG.camera == null) ? FlxColor.BLACK : FlxG.camera.bgColor;
	} 
	
	private function set_bgColor(Color:FlxColor):FlxColor
	{
		for (camera in list)
		{
			camera.bgColor = Color;
		}
		
		return Color;
	}
}