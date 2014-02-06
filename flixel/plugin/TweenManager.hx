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
	public var list(default, null):Array<FlxTween>;
	
	public function new():Void
	{
		super();
		list = new Array<FlxTween>();
		visible = false; // No draw-calls needed 
	}
	
	override public function update():Void
	{
		// process finished tweens after iterating through main list, since finish() can manipulate FlxTween.list
		var finishedTweens:Array<FlxTween> = null;
		
		for (tween in list)
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
			while(finishedTweens.length > 0)
			{
				finishedTweens.shift().finish();
			}
		}
	}
	
	/**
	 * Add a FlxTween.
	 * @param	Tween	The FlxTween to add.
	 * @param	Start	Whether you want it to start right away.
	 * @return	The added FlxTween object.
	 */
	public function add(Tween:FlxTween, Start:Bool = false):FlxTween
	{
		// Don't add a null object
		if (Tween == null)
		{
			return null;
		}
		
		// Don't add the same tween twice
		if (FlxArrayUtil.indexOf(list, Tween) > 0)
		{
			return Tween;
		}
		
		list.push(Tween);
		
		if (Start) 
		{
			Tween.start();
		}
		return Tween;
	}

	/**
	 * Remove a FlxTween.
	 * @param	Tween		The FlxTween to remove.
	 * @param	Destroy		Whether you want to destroy the FlxTween.
	 * @return	The added FlxTween object.
	 */
	public function remove(Tween:FlxTween, Destroy:Bool = false):FlxTween
	{
		if (Tween == null)
		{
			return null;
		}
		
		if (Destroy) 
		{
			Tween.destroy();
		}
		
		Tween.active = false;
		
		FlxArrayUtil.fastSplice(list, Tween);
		
		return Tween;
	}

	/**
	 * Removes all FlxTweens.
	 * @param	Destroy		Whether you want to destroy the FlxTweens.
	 */
	public function clear(Destroy:Bool = false):Void
	{
		for (tween in list)
		{
			remove(tween, Destroy);
		}
		list = new Array<FlxTween>();
	}
	
	override public inline function onStateSwitch():Void
	{
		clear(true);
	}
}
