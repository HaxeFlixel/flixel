package org.flixel.system;

import haxe.FastList;
import org.flixel.FlxObject;

/**
 * A miniature linked list class.
 * Useful for optimizing time-critical or highly repetitive tasks!
 * See <code>FlxQuadTree</code> for how to use it, IF YOU DARE.
 */
class FlxList
{
	static private var _listCache:FastList<FlxList> = new FastList<FlxList>();
	
	/**
	 * Stores a reference to a <code>FlxObject</code>.
	 */
	public var object:FlxObject;
	/**
	 * Stores a reference to the next link in the list.
	 */
	public var next:FlxList;
	
	public var exists:Bool;
	
	/**
	 * Creates a new link, and sets <code>object</code> and <code>next</code> to <code>null</code>.
	 */
	private function new()
	{
		object = null;
		next = null;
		exists = true;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		// ensure we haven't been destroyed already
		if (!exists)
			return;
		
		object = null;
		if (next != null)
		{
			next.destroy();
		}
		next = null;
		exists = false;
		 _listCache.add(this);
	}
	
	public static function recycle():FlxList
	{
		if (!_listCache.isEmpty())
		{
			var listElement:FlxList = _listCache.pop();
			listElement.exists = true;
			return listElement;
		}
		else
			return new FlxList();
	}
}