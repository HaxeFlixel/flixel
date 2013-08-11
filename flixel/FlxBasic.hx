package flixel;

import flixel.util.FlxStringUtil;

/**
 *  This class is for <code>FlxTypedGroup</code> to work with interface instead of <code>FlxBasic</code>, which is needed
 *  so that <code>FlxSpriteGroup</code> could extend <code>FlxTypedGroup</code> and be typed with <code>IFlxSprite</code>
 **/
interface IFlxBasic {
    public var exists:Bool;
    public var alive:Bool;
}


/**
 * This is a useful "generic" Flixel object. Both <code>FlxObject</code> and 
 * <code>FlxGroup</code> extend this class. Has no size, position or graphical data.
 */
class FlxBasic implements IFlxBasic
{
	#if !FLX_NO_DEBUG
	static public var _ACTIVECOUNT:Int = 0;
	static public var _VISIBLECOUNT:Int = 0;
	#end
	
	/**
	 * IDs seem like they could be pretty useful, huh?
	 * They're not actually used for anything yet though.
	 */
	public var ID:Int = -1;
	/**
	 * Controls whether <code>update()</code> and <code>draw()</code> are automatically called by FlxState/FlxGroup.
	 */
	public var exists:Bool = true;
	/**
	 * Controls whether <code>update()</code> is automatically called by FlxState/FlxGroup.
	 */
	public var active:Bool = true;
	/**
	 * Controls whether <code>draw()</code> is automatically called by FlxState/FlxGroup.
	 */
	public var visible:Bool = true;
	/**
	 * Useful state for many game objects - "dead" (!alive) vs alive.
	 * <code>kill()</code> and <code>revive()</code> both flip this switch (along with exists, but you can override that).
	 */
	public var alive:Bool = true;
	/**
	 * An array of camera objects that this object will use during <code>draw()</code>. This value will initialize itself during the first draw to automatically
	 * point at the main camera list out in <code>FlxG</code> unless you already set it. You can also change it afterward too, very flexible!
	 */
	public var cameras:Array<FlxCamera>;
	
	#if !FLX_NO_DEBUG
	/**
	 * Setting this to true will prevent the object from appearing
	 * when the visual debug mode in the debugger overlay is toggled on.
	 */
	public var ignoreDrawDebug:Bool = false;
	#end
	
	public function new() { }

	/**
	 * WARNING: This will remove this object entirely. Use <code>kill()</code> if you want to disable it temporarily only and <code>reset()</code> it later to revive it.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	public function destroy():Void { }
	
	/**
	 * Override this function to update your class's position and appearance.
	 * This is where most of your game rules and behavioral code will go.
	 */
	public function update():Void 
	{ 
		#if !FLX_NO_DEBUG
		_ACTIVECOUNT++;
		#end
	}
	
	/**
	 * Override this function to control how the object is drawn.
	 * Overriding <code>draw()</code> is rarely necessary, but can be very useful.
	 */
	public function draw():Void
	{
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		while(i < l)
		{
			camera = cameras[i++];
			
			#if !FLX_NO_DEBUG
			_VISIBLECOUNT++;
			#end
		}
	}
	
	#if !FLX_NO_DEBUG
	public function drawDebug():Void
	{
		if (!ignoreDrawDebug)
		{
			var i:Int = 0;
			if (cameras == null)
			{
				cameras = FlxG.cameras.list;
			}
			var l:Int = cameras.length;
			while (i < l)
			{
				drawDebugOnCamera(cameras[i++]);
			}
		}
	}
	
	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	public function drawDebugOnCamera(?Camera:FlxCamera):Void { }
	#end
	
	/**
	 * Handy function for "killing" game objects. Use <code>reset()</code> to revive them. Default behavior is to flag them as nonexistent AND dead. However, if you want the 
	 * "corpse" to remain in the game, like to animate an effect or whatever, you should override this, setting only alive to false, and leaving exists true.
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
		return FlxStringUtil.getClassName(this, true);
	}
}