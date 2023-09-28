package flixel.util;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * BitmapData pool class.
 *
 * Notes on implementation:
 *     get() starts searching for a suitable BitmapData from the start of the pool list
 *     put() adds the BitmapData to the start of the pool list (removing the last one if the pool exceeds maxLength)
 *
 * @author azrafe7
 */
@:access(FlxBitmapDataPoolNode)
class FlxBitmapDataPool
{
	/**
	 * Maximum number of BitmapData to hold in the pool.
	 */
	public static var maxLength(default, set):Int = 8;

	/** 
	 * Current number of BitmapData present in the pool.
	 */
	public static var length(default, null):Int = 0;

	static var _head:FlxBitmapDataPoolNode = null;
	static var _tail:FlxBitmapDataPoolNode = null;

	static var _rect:Rectangle = new Rectangle();

	/** 
	 * Returns a BitmapData with the specified parameters.
	 * If a suitable BitmapData cannot be found in the pool a new one will be created.
	 * If fillColor is specified the returned BitmapData will also be cleared with it.
	 *
	 * @param exactSize	If false a BitmapData with size >= [w, h] may be returned.
	 */
	public static function get(w:Int, h:Int, transparent:Bool = true, ?fillColor:FlxColor, ?exactSize:Bool = false):BitmapData
	{
		var res:BitmapData = null;

		// search the pool
		var node = _head;
		while (node != null)
		{
			var bmd = node.bmd;
			if ((bmd.transparent == transparent && bmd.width >= w && bmd.height >= h)
				&& (!exactSize || (exactSize && bmd.width == w && bmd.height == h)))
			{
				res = bmd;

				// remove it from pool
				if (node.prev != null)
					node.prev.next = node.next;
				if (node.next != null)
					node.next.prev = node.prev;
				if (node == _head)
					_head = node.next;
				if (node == _tail)
					_tail = node.prev;
				node = null;
				length--;
				break;
			}
			node = node.next;
		}

		if (res != null) // suitable BitmapData found in the pool
		{
			if (fillColor != null)
			{
				_rect.x = 0;
				_rect.y = 0;
				_rect.width = w;
				_rect.height = h;
				res.fillRect(_rect, fillColor);
			}
		}
		else // not found: create a new one
		{
			res = new BitmapData(w, h, transparent, fillColor != null ? fillColor : FlxColor.WHITE);
		}

		return res;
	}

	/** 
	 * Adds bmd to the pool for future use.
	 */
	public static function put(bmd:BitmapData):Void
	{
		if (length >= maxLength)
		{
			var last = _tail;
			last.bmd.dispose();
			if (last.prev != null)
			{
				last.prev.next = null;
				_tail = last.prev;
			}
			last = null;
			length--;
		}

		var node = new FlxBitmapDataPoolNode(bmd);
		node.next = _head;
		if (_head == null)
		{
			_head = _tail = node;
		}
		else
		{
			_head = node;
			node.next.prev = node;
		}
		length++;
	}

	/**
	 * Disposes of all the BitmapData in the pool.
	 */
	public static function clear():Void
	{
		var node = _head;
		while (node != null)
		{
			var bmd = node.bmd;
			bmd.dispose();
			bmd = null;
			node = node.next;
		}
		length = 0;
		_head = _tail = null;
	}

	static function set_maxLength(value:Int):Int
	{
		if (maxLength != value)
		{
			var node = _tail;
			while ((node != null) && (length > value))
			{
				var bmd = node.bmd;
				bmd.dispose();
				bmd = null;
				node = node.prev;
				length--;
			}
		}
		return maxLength = value;
	}
}

private class FlxBitmapDataPoolNode
{
	public var bmd:BitmapData;
	public var prev:FlxBitmapDataPoolNode;
	public var next:FlxBitmapDataPoolNode;

	public function new(?bmd:BitmapData, ?prev:FlxBitmapDataPoolNode, ?next:FlxBitmapDataPoolNode):Void
	{
		this.bmd = bmd;
		this.prev = prev;
		this.next = next;
	}
}
