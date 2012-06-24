package org.flixel.tweens.motion;

import org.flixel.Tween;
import org.flixel.tweens.util.Ease;

/**
 * Base class for motion Tweens.
 */
class Motion extends Tween
{
	/**
	 * Current x position of the Tween.
	 */
	public var x:Float;
	
	/**
	 * Current y position of the Tween.
	 */
	public var y:Float;
	
	/**
	 * Constructor.
	 * @param	duration	Duration of the Tween.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	ease		Optional easer function.
	 */
	public function new(duration:Float, ?complete:CompleteCallback, ?type:TweenType, ?ease:EaseFunction = null) 
	{
		x = y = 0;
		super(duration, type, complete, ease);
	}
	
	override public function update():Void
	{
		super.update();
	}
}