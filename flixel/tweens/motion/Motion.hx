package flixel.tweens.motion;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.util.Ease;

typedef Movable = {
	public var immovable:Bool;
	public function move(x:Float, y:Float):Void;
}

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
	
	private var _object:Movable;
	
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
	
	public function setObject(object:Movable):Void
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
			_object.move(x, y); 
		}
	}
}