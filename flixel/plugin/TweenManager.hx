package flixel.plugin;

import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;

/**
 * A manager for <code>FlxTween</code>s.
 */
class TweenManager extends FlxPlugin
{
	/**
	 * A list of all <code>FlxTween</code> objects.
	 */
	public var list(default, null):Array<FlxTween>;
	
	public function new():Void
	{
		super();
		
		list = new Array<FlxTween>();
	}
	
	override public function update():Void
	{
		super.update();
	
		// process finished tweens after iterating through main list, since finish() can manipulate FlxTween.list
		var finishedTweens:Array<FlxTween> = null;
	
		for (tween in list)
		{
			if (tween.active)
			{
				tween.update();
				if(tween.finished)
				{
					if(finishedTweens == null)
						finishedTweens = new Array<FlxTween>();
					finishedTweens.push(tween);
				}
			}
		}
	
		if(finishedTweens != null)
		{
			while(finishedTweens.length > 0)
			{
				finishedTweens.shift().finish();
			}
		}
	}
	
	/**
	 * Add a <code>FlxTween</code>.
	 * @param	Tween	The <code>FlxTween</code> to add.
	 * @param	Start	Whether you want it to start right away.
	 * @return	The added <code>FlxTween</code> object.
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
	 * Remove a <code>FlxTween</code>.
	 * @param	Tween		The <code>FlxTween</code> to remove.
	 * @param	Destroy		Whether you want to destroy the <code>FlxTween</code>.
	 * @return	The added <code>FlxTween</code> object.
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
		
		// Fast array removal (only do on arrays where order doesn't matter)
		list[FlxArrayUtil.indexOf(list, Tween)] = list[list.length - 1];
		list.pop();
		
		return Tween;
	}

	/**
	 * Removes all <code>FlxTween</code>s.
	 * @param	Destroy		Whether you want to destroy the <code>FlxTween</code>s.
	 */
	public function clear(Destroy:Bool = false):Void
	{
		for (tween in list)
		{
			remove(tween, Destroy);
		}
		list = new Array<FlxTween>();
	}
	
	override inline public function onStateSwitch():Void
	{
		clear(true);
	}
}
