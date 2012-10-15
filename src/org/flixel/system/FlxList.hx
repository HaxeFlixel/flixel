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
	/**
	 * Pooling mechanism, when FlxLists are destroyed, they get added to this collection, and when they get recycled they get removed.
	 */
	static public var  _NUM_CACHED_FLX_LIST:Int = 0;
	static private var _cachedListsHead:FlxList;
	
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
	 * Private, use recycle instead.
	 */
	private function new()
	{
		object = null;
		next = null;
		exists = true;
	}
	
	/**
	 * Recycle a cached Linked List, or creates a new one if needed.
	 */
	public static function recycle():FlxList
	{
		if (_cachedListsHead != null)
		{
			var cachedList:FlxList = _cachedListsHead;
			_cachedListsHead = _cachedListsHead.next;
			_NUM_CACHED_FLX_LIST--;
			
			cachedList.exists = true;
			cachedList.next = null;
			return cachedList;
		}
		else
			return new FlxList();
	}
	
	/**
	 * Clear cached List nodes. You might want to do this when loading new levels (probably not though, no need to clear cache unless you run into memory problems).
	 */
	public static function clearCache():Void 
	{
		// null out next pointers to help out garbage collector
		while (_cachedListsHead != null)
		{
			var node = _cachedListsHead;
			_cachedListsHead = _cachedListsHead.next;
			node.object = null;
			node.next = null;
		}
		_NUM_CACHED_FLX_LIST = 0;
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
		exists = false;
		
		// Deposit this list into the linked list for reusal.
		next = _cachedListsHead;
		_cachedListsHead = this;
		_NUM_CACHED_FLX_LIST++;
	}
}