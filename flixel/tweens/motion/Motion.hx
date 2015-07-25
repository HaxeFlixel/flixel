package flixel.tweens.motion;

import flixel.FlxObject;
import flixel.tweens.FlxTween;

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
	private var _wasObjectImmovable:Bool;
	
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
	}
	
	public function setObject(object:FlxObject):Motion
	{
		_object = object;
		_wasObjectImmovable = _object.immovable;
		_object.immovable = true;
		return this;
	}
	
	override private function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		postUpdate();
	}
	
	override private function onEnd():Void
	{
		_object.immovable = _wasObjectImmovable;
		super.onEnd();
	}
	
	private function postUpdate():Void
	{
		if (_object != null)
		{
			_object.setPosition(x, y);
		}
	}
}
