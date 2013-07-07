package flixel.system.frontEnds;

import flixel.FlxG;

class CameraFXFrontEnd
{
	/**
	 * Just needed to create an instance.
	 */
	public function new() { }
	
	/**
	 * All screens are filled with this color and gradually return to normal.
	 * 
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	public function flash(Color:Int = 0xffffffff, Duration:Float = 1, OnComplete:Void->Void = null, Force:Bool = false):Void
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.list.length;
		while (i < l)
		{
			FlxG.cameras.list[i++].flash(Color, Duration, OnComplete, Force);
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
	public function fade(Color:Int = 0xff000000, Duration:Float = 1, FadeIn:Bool = false, OnComplete:Void->Void = null, Force:Bool = false):Void
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.list.length;
		while (i < l)
		{
			FlxG.cameras.list[i++].fade(Color, Duration, FadeIn, OnComplete, Force);
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
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, OnComplete:Void->Void = null, Force:Bool = true, Direction:Int = 0):Void
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.list.length;
		while (i < l)
		{
			FlxG.cameras.list[i++].shake(Intensity, Duration, OnComplete, Force, Direction);
		}
	}
}