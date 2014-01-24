package flixel.tweens.motion;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Base class for motion Tweens.
 */
class Motion extends FlxTween
{
	/**
	 * Current x position of the Tween.
	 */
	public var x:Float = 0;
	/**
	 * Current y position of the Tween.
	 */
	public var y:Float = 0;
	
	private var _object:FlxObject;
	
	/**
	 * Constructor.
	 * @param	duration	Duration of the Tween.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	ease		Optional easer function.
	 */
	public function new(duration:Float, ?complete:CompleteCallback, type:Int = 0, ?ease:EaseFunction) 
	{
		super(duration, type, complete, ease);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
	}
	
	public function setObject(object:FlxObject):Motion
	{
		_object = object;
		_object.immovable = true;
		return this;
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
			_object.setPosition(x, y); 
		}
	}
}
