package flixel.plugin;

import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;

/**
 * A manager for FlxTweens.
 */
class TweenManager extends FlxPlugin
{
	/**
	 * A list of all FlxTween objects.
	 */
	private var _tweens(default, null):Array<FlxTween> = [];
	
	public function new():Void
	{
		super();
		visible = false; // No draw-calls needed 
	}
	
	override public function update():Void
	{
		// process finished tweens after iterating through main list, since finish() can manipulate FlxTween.list
		var finishedTweens:Array<FlxTween> = null;
		
		for (tween in _tweens)
		{
			if (tween.active)
			{
				tween.update();
				if (tween.finished)
				{
					if (finishedTweens == null)
					{
						finishedTweens = new Array<FlxTween>();
					} 
					finishedTweens.push(tween);
				}
			}
		}
		
		if (finishedTweens != null)
		{
			while (finishedTweens.length > 0)
			{
				finishedTweens.shift().finish();
			}
		}
	}
	
	/**
	 * Add a FlxTween.
	 * 
	 * @param	Tween	The FlxTween to add.
	 * @param	Start	Whether you want it to start right away.
	 * @return	The added FlxTween object.
	 */
	@:generic
	@:allow(flixel.tweens.FlxTween)
	private function add<T:FlxTween>(Tween:T, Start:Bool = false):T
	{
		// Don't add a null object
		if (Tween == null)
		{
			return null;
		}
		
		_tweens.push(Tween);
		
		if (Start) 
		{
			Tween.start();
		}
		return Tween;
	}

	/**
	 * Remove a FlxTween.
	 * 
	 * @param	Tween		The FlxTween to remove.
	 * @param	Destroy		Whether you want to destroy the FlxTween.
	 * @return	The added FlxTween object.
	 */
	@:allow(flixel.tweens.FlxTween)
	private function remove(Tween:FlxTween):FlxTween
	{
		if (Tween == null)
		{
			return null;
		}
		
		Tween.active = false;
		Tween.destroy();
		
		FlxArrayUtil.fastSplice(_tweens, Tween);
		
		return Tween;
	}

	/**
	 * Removes all FlxTweens.
	 */
	public function clear():Void
	{
		while (_tweens.length > 0)
		{
			remove(_tweens[0]);
		}
	}
	
	override public inline function onStateSwitch():Void
	{
		clear();
	}
}
