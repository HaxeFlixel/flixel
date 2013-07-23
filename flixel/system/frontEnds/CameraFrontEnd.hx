package flixel.system.frontEnds;

import flash.display.StageDisplayState;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;

class CameraFrontEnd
{
	/**
	 * An array listing <code>FlxCamera</code> objects that are used to draw stuff.
	 * By default flixel creates one camera the size of the screen.
	 */
	public var list(default, null):Array<FlxCamera>;
	/**
	 * Allows you to possibly slightly optimize the rendering process IF
	 * you are not doing any pre-processing in your game state's <code>draw()</code> call.
	 * @default false
	 */
	public var useBufferLocking:Bool;
	/**
	 * Internal helper variable for clearing the cameras each frame.
	 */
	private var _cameraRect:Rectangle;
	
	public function new() 
	{
		_cameraRect = new Rectangle();
		list = new Array<FlxCamera>();
		useBufferLocking = false;
	}
	
	/**
	 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
	 */
	inline public function lock():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = list;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++];
			if ((cam == null) || !cam.exists || !cam.visible)
			{
				continue;
			}
			
			#if flash
			if (useBufferLocking)
			{
				cam.buffer.lock();
			}
			#end
			
			#if !flash
			cam.clearDrawStack();
			cam._canvas.graphics.clear();
			// clearing camera's debug sprite
			cam._debugLayer.graphics.clear();
			#end
			
			#if flash
			cam.fill(cam.bgColor, cam.useBgAlphaBlending);
			cam.screen.dirty = true;
			#else
			cam.fill((cam.bgColor & 0x00ffffff), cam.useBgAlphaBlending, ((cam.bgColor >> 24) & 255) / 255);
			#end
		}
	}
	
	#if !flash
	inline public function render():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = FlxG.cameras.list;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++];
			if ((cam == null) || !cam.exists || !cam.visible)
			{
				continue;
			}
			
			cam.render();
		}
	}
	#end
	
	/**
	 * Called by the game object to draw the special FX and unlock all the camera buffers.
	 */
	inline public function unlock():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = list;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++];
			if ((cam == null) || !cam.exists || !cam.visible)
			{
				continue;
			}
			cam.drawFX();
			
			#if flash
			if (useBufferLocking)
			{
				cam.buffer.unlock();
			}
			
			cam.screen.resetFrameBitmapDatas();
			#end
		}
	}
	
	/**
	 * Called by the game object to update the cameras and their tracking/special effects logic.
	 */
	inline public function update():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = list;
		var i:Int = 0;
		var l:Int = cams.length;
		while (i < l)
		{
			cam = cams[i++];
			if ((cam != null) && cam.exists)
			{
				if (cam.active)
				{
					cam.update();
				}

				if (cam.target == null) 
				{
					cam._flashSprite.x = cam.x + cam._flashOffsetX;
					cam._flashSprite.y = cam.y + cam._flashOffsetY;
				}
				
				cam._flashSprite.visible = cam.visible;
			}
		}
	}
	
	/**
	 * Add a new camera object to the game.
	 * Handy for PiP, split-screen, etc.
	 * 
	 * @param	NewCamera	The camera you want to add.
	 * @return	This <code>FlxCamera</code> instance.
	 */
	public function add(NewCamera:FlxCamera):FlxCamera
	{
		FlxG.game.addChildAt(NewCamera._flashSprite, FlxG.game.getChildIndex(FlxG.game.inputContainer));
		FlxG.cameras.list.push(NewCamera);
		NewCamera.ID = FlxG.cameras.list.length - 1;
		return NewCamera;
	}
	
	/**
	 * Remove a camera from the game.
	 * 
	 * @param	Camera	The camera you want to remove.
	 * @param	Destroy	Whether to call destroy() on the camera, default value is true.
	 */
	public function remove(Camera:FlxCamera, Destroy:Bool = true):Void
	{
		if (Camera != null && FlxG.game.contains(Camera._flashSprite))
		{
			FlxG.game.removeChild(Camera._flashSprite);
			var index = FlxArrayUtil.indexOf(FlxG.cameras.list, Camera);
			if(index >= 0)
				FlxG.cameras.list.splice(index, 1);
		}
		else
		{
			FlxG.log.error("Removing camera, not part of game.");
		}
		
		#if !flash
		for (i in 0...(FlxG.cameras.list.length))
		{
			FlxG.cameras.list[i].ID = i;
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
	public function reset(NewCamera:FlxCamera = null):Void
	{
		var cam:FlxCamera;
		var i:Int = 0;
		var l:Int = list.length;
		while(i < l)
		{
			cam = list[i++];
			FlxG.game.removeChild(cam._flashSprite);
			cam.destroy();
		}
		list.splice(0, FlxG.cameras.list.length);
		
		if (NewCamera == null)	
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		
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
	
	#if flash
	/**
	 * Switch to full-screen display.
	 */
	public function fullscreen():Void
	{
		FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
		
		var fsw:Int = Std.int(FlxG.width * FlxG.camera.zoom);
		var fsh:Int = Std.int(FlxG.height * FlxG.camera.zoom);
		
		FlxG.camera.x = (FlxG.stage.fullScreenWidth - fsw) / 2;
		FlxG.camera.y = (FlxG.stage.fullScreenHeight - fsh) / 2;
	}
	#end
	
	public var bgColor(get, set):Int;

	/**
	 * Get and set the background color of the game.
	 * Get functionality is equivalent to FlxG.camera.bgColor.
	 * Set functionality sets the background color of all the current cameras.
	 */
	private function get_bgColor():Int
	{
		if (FlxG.camera == null)
		{
			return FlxColor.BLACK;
		}
		else
		{
			return FlxG.camera.bgColor;
		}
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