package flixel.system.frontEnds;

import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;

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
	
	/** @since 4.2.0 */
	public var cameraAdded(default, null):FlxTypedSignal<FlxCamera->Void> = new FlxTypedSignal<FlxCamera->Void>();
	
	/** @since 4.2.0 */
	public var cameraRemoved(default, null):FlxTypedSignal<FlxCamera->Void> = new FlxTypedSignal<FlxCamera->Void>();
	
	/** @since 4.2.0 */
	public var cameraResized(default, null):FlxTypedSignal<FlxCamera->Void> = new FlxTypedSignal<FlxCamera->Void>();
	
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
	public function add<T:FlxCamera>(NewCamera:T):T
	{
		FlxG.game.addChildAt(NewCamera.view.display, FlxG.game.getChildIndex(FlxG.game._inputContainer));
		FlxG.cameras.list.push(NewCamera);
		NewCamera.ID = FlxG.cameras.list.length - 1;
		cameraAdded.dispatch(NewCamera);
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
		if (Camera != null && index != -1)
		{
			FlxG.game.removeChild(Camera.view.display);
			list.splice(index, 1);
		}
		else
		{
			FlxG.log.warn("FlxG.cameras.remove(): The camera you attempted to remove is not a part of the game.");
			return;
		}
		
		if (FlxG.renderTile)
		{
			for (i in 0...list.length)
				list[i].ID = i;
		}
		
		if (Destroy)
			Camera.destroy();
		
		cameraRemoved.dispatch(Camera);
	}
		
	/**
	 * Dumps all the current cameras and resets to just one camera.
	 * Handy for doing split-screen especially.
	 * 
	 * @param	NewCamera	Optional; specify a specific camera object to be the new main camera.
	 */
	public function reset(?NewCamera:FlxCamera):Void
	{
		while (list.length > 0)
			remove(list[0]);

		if (NewCamera == null)
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		
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
	public function flash(Color:FlxColor = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		for (camera in list)
			camera.flash(Color, Duration, OnComplete, Force);
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
			camera.fade(Color, Duration, FadeIn, OnComplete, Force);
	}
	
	/**
	 * A simple screen-shake effect.
	 * 
	 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * @param	Duration	The length in seconds that the shaking effect should last.
	 * @param	OnComplete	A function you want to run when the shake effect finishes.
	 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
	 * @param	Axes		On what axes to shake. Default value is XY / both.
	 */
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, ?Axes:FlxAxes):Void
	{
		for (camera in list)
			camera.shake(Intensity, Duration, OnComplete, Force, Axes);
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		FlxCamera.defaultCameras = list;
	}
	
	/**
	 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
	 */
	@:allow(flixel.FlxGame)
	private inline function lock():Void
	{
		for (camera in list)
		{
			if (camera == null || !camera.exists || !camera.visible)
				continue;
			
			camera.lock(useBufferLocking);
		}
	}
	
	@:allow(flixel.FlxGame)
	private inline function render():Void
	{
		for (camera in list)
		{
			if ((camera != null) && camera.exists && camera.visible)
				camera.render();
		}
	}
	
	/**
	 * Called by the game object to draw the special FX and unlock all the camera buffers.
	 */
	@:allow(flixel.FlxGame)
	private inline function unlock():Void
	{
		for (camera in list)
		{
			if ((camera == null) || !camera.exists || !camera.visible)
				continue;
			
			camera.drawFX();
			camera.unlock(useBufferLocking);
		}
	}
	
	/**
	 * Called by the game object to update the cameras and their tracking/special effects logic.
	 */
	@:allow(flixel.FlxGame)
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
	@:allow(flixel.FlxGame)
	private function resize():Void
	{
		for (camera in list)
			camera.onResize();
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