package flixel.system;

import flixel.FlxObject;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A miniature linked list class.
 * Useful for optimizing time-critical or highly repetitive tasks!
 * See `FlxQuadTree` for how to use it, IF YOU DARE.
 */
class FlxLinkedList implements IFlxDestroyable
{
	/**
	 * The current size of the `FlxLinkedList` pool.
	 */
	public static var _NUM_CACHED_FLX_LIST:Int = 0;

	/**
	 * Pooling mechanism. When `FlxLinkedList`s are destroyed, they get added
	 * to this collection, and, when they get recycled, they get removed.
	 */
	static var _cachedListsHead:FlxLinkedList;

	/**
	 * Recycles a cached linked list, or creates a new one if needed.
	 */
	public static function recycle():FlxLinkedList
	{
		if (_cachedListsHead != null)
		{
			var cachedList:FlxLinkedList = _cachedListsHead;
			_cachedListsHead = _cachedListsHead.next;
			_NUM_CACHED_FLX_LIST--;

			cachedList.exists = true;
			cachedList.next = null;
			return cachedList;
		}
		else
			return new FlxLinkedList();
	}

	/**
	 * Clears cached list nodes. You might want to do this when loading new levels
	 * (probably not though; no need to clear cache unless you run into memory problems).
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
	 * Stores a reference to a `FlxObject`.
	 */
	public var object:FlxObject;

	/**
	 * Stores a reference to the next link in the list.
	 */
	public var next:FlxLinkedList;

	public var exists:Bool = true;

	/**
	 * Private. Use `recycle()` instead.
	 */
	function new() {}

	/**
	 * Cleans up memory.
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

		// Deposit this list into the linked list for reuse.
		next = _cachedListsHead;
		_cachedListsHead = this;
		_NUM_CACHED_FLX_LIST++;
	}
}
