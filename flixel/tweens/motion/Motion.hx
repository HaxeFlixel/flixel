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
	
	override private function update():Void 
	{
		super.update();
		postUpdate();
	}
	
	private function postUpdate():Void
	{
		if (_object != null)
		{
			_object.setPosition(x, y);
		}
	}
}
