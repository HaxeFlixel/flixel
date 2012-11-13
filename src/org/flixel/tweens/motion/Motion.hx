package org.flixel.tweens.motion;

import org.flixel.FlxObject;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

/**
 * Base class for motion Tweens.
 */
class Motion extends FlxTween
{
	/**
	 * Current x position of the Tween.
	 */
	public var x:Float;
	
	/**
	 * Current y position of the Tween.
	 */
	public var y:Float;
	
	private var _object:FlxObject;
	
	/**
	 * Constructor.
	 * @param	duration	Duration of the Tween.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	ease		Optional easer function.
	 */
	public function new(duration:Float, complete:CompleteCallback = null, type:Int = 0, ease:EaseFunction = null) 
	{
		super(duration, type, complete, ease);
		x = y = 0;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
	}
	
	public function setObject(object:FlxObject):Void
	{
		_object = object;
		_object.immovable = true;
	}
	
	override public function update():Void 
	{
		super.update();
		postUpdate();
	}
	
	public function postUpdate():Void
	{
		if (_object != null)
		{
			_object.x = x;
			_object.y = y;
		}
	}
}