package org.flixel;

import org.flixel.tweens.FlxTween;

/**
 * This is a useful "generic" Flixel object.
 * Both <code>FlxObject</code> and <code>FlxGroup</code> extend this class,
 * as do the plugins.  Has no size, position or graphical data.
 */
class FlxBasic
{
	
	static public var _ACTIVECOUNT:Int;
	static public var _VISIBLECOUNT:Int;
	
	/**
	 * IDs seem like they could be pretty useful, huh?
	 * They're not actually used for anything yet though.
	 */
	public var ID:Int;
	/**
	 * Controls whether <code>update()</code> and <code>draw()</code> are automatically called by FlxState/FlxGroup.
	 */
	public var exists:Bool;
	/**
	 * Controls whether <code>update()</code> is automatically called by FlxState/FlxGroup.
	 */
	public var active:Bool;
	/**
	 * Controls whether <code>draw()</code> is automatically called by FlxState/FlxGroup.
	 */
	public var visible:Bool;
	/**
	 * Useful state for many game objects - "dead" (!alive) vs alive.
	 * <code>kill()</code> and <code>revive()</code> both flip this switch (along with exists, but you can override that).
	 */
	public var alive:Bool;
	/**
	 * An array of camera objects that this object will use during <code>draw()</code>.
	 * This value will initialize itself during the first draw to automatically
	 * point at the main camera list out in <code>FlxG</code> unless you already set it.
	 * You can also change it afterward too, very flexible!
	 */
	public var cameras:Array<FlxCamera>;
	/**
	 * Setting this to true will prevent the object from appearing
	 * when the visual debug mode in the debugger overlay is toggled on.
	 */
	public var ignoreDrawDebug:Bool;
	
	/**
	 * If the Tweener should clear on removal. For Entities, this is when they are
	 * removed from a World, and for World this is when the active World is switched.
	 */
	public var autoClear:Bool;
	
	/**
	 * Instantiate the basic flixel object.
	 */
	public function new()
	{
		ID = -1;
		exists = true;
		active = true;
		visible = true;
		alive = true;
		ignoreDrawDebug = false;
		
		autoClear = true;
	}

	/**
	 * Override this function to null out variables or manually call
	 * <code>destroy()</code> on class members if necessary.
	 * Don't forget to call <code>super.destroy()</code>!
	 */
	public function destroy():Void 
	{
		if (autoClear && hasTween) 
		{
			clearTweens(true);
			_tween = null;
		}
	}
	
	/**
	 * Pre-update is called right before <code>update()</code> on each object in the game loop.
	 */
	public function preUpdate():Void
	{
		_ACTIVECOUNT++;
	}
	
	/**
	 * Override this function to update your class's position and appearance.
	 * This is where most of your game rules and behavioral code will go.
	 */
	public function update():Void { }
	
	/**
	 * Post-update is called right after <code>update()</code> on each object in the game loop.
	 */
	public function postUpdate():Void { }
	
	/**
	 * Override this function to control how the object is drawn.
	 * Overriding <code>draw()</code> is rarely necessary, but can be very useful.
	 */
	public function draw():Void
	{
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		while(i < l)
		{
			camera = cameras[i++];
			_VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		}
	}
	
	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	public function drawDebug(?Camera:FlxCamera = null):Void { }
	
	/**
	 * Handy function for "killing" game objects.
	 * Default behavior is to flag them as nonexistent AND dead.
	 * However, if you want the "corpse" to remain in the game,
	 * like to animate an effect or whatever, you should override this,
	 * setting only alive to false, and leaving exists true.
	 */
	public function kill():Void
	{
		alive = false;
		exists = false;
	}
	
	/**
	 * Handy function for bringing game objects "back to life". Just sets alive and exists back to true.
	 * In practice, this function is most often called by <code>FlxObject.reset()</code>.
	 */
	public function revive():Void
	{
		alive = true;
		exists = true;
	}
	
	/**
	 * Convert object to readable string name.  Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxU.getClassName(this, true);
	}
	
	public function addTween(t:FlxTween, ?start:Bool = false):FlxTween
	{
		var ft:FriendTween = t;
		if (ft._parent != null) 
		{
			throw "Cannot add a FlxTween object more than once.";
		}
		ft._parent = this;
		ft._next = _tween;
		var friendTween:FriendTween = _tween;
		if (_tween != null) 
		{
			friendTween._prev = t;
		}
		_tween = t;
		if (start) 
		{
			_tween.start();
		}
		return t;
	}

	public function removeTween(t:FlxTween, ?destroy:Bool = false):FlxTween
	{
		var ft:FriendTween = t;
		if (ft._parent != this) 
		{
			throw "Core object does not contain FlxTween.";
		}
		if (ft._next != null) 
		{
			ft._next._prev = ft._prev;
		}
		if (ft._prev != null)
		{
			ft._prev._next = ft._next;
		}
		else
		{
			if (ft._next != null)
			{
				_tween = cast(ft._next, FlxTween);
			}
		}
		ft._next = ft._prev = null;
		ft._parent = null;
		if (destroy) t.destroy();
		t.active = false;
		return t;
	}

	public function clearTweens(?destroy:Bool = false):Void
	{
		var t:FlxTween;
		var ft:FriendTween = _tween;
		var fn:FriendTween;
		while (ft != null)
		{
			fn = ft._next;
			removeTween(cast(ft, FlxTween), destroy);
			ft = fn;
		}
	}

	public function updateTweens():Void
	{
		var t:FlxTween;
		var	ft:FriendTween = _tween;
		while (ft != null)
		{
			t = cast(ft, FlxTween);
			if (t.active)
			{
				t.update();
				if (ft._finish) 
				{
					ft.finish();
				}
			}
			ft = ft._next;
		}
	}

	public var hasTween(getTween, never):Bool;
	
	private function getTween():Bool 
	{ 
		return (_tween != null); 
	}

	private var _tween:FlxTween;
}