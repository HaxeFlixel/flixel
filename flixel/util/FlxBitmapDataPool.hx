package flixel.util;

import flash.display.BitmapData;
import flash.geom.Rectangle;

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
	private static var _head:FlxBitmapDataPoolNode = null;
	private static var _tail:FlxBitmapDataPoolNode = null;
	
	private static var _rect:Rectangle = new Rectangle();
	
	private static var _length:Int = 0;
	private static var _maxLength:Int = 8;
	
	/** Maximum number of BitmapData to hold in the pool. */
	public static var maxLength(get, set):Int;
	
	static inline function get_maxLength():Int 
	{
		return _maxLength;
	}
	
	static function set_maxLength(value:Int):Int 
	{
		if (_maxLength != value) 
		{
			var node = _tail;
			while (node != null && _length > value) 
			{
				var bmd = node.bmd;
				bmd.dispose();
				bmd = null;
				node = node.prev;
				_length--;
			}
		}
		return _maxLength = value;
	}
	
	/** Current number of BitmapData present in the pool. */
	public static var length(get, null):Int;
	
	static function get_length():Int 
	{
		return _length;
	}
	
	/** 
	 * Returns a BitmapData with the specified parameters. 
	 * If a suitable BitmapData cannot be found in the pool a new one will be created.
	 * If fillColor is specified the returned BitmapData will also be cleared with it.
	 * 
	 * @param ?exactSize	If false a BitmapData with size >= [w, h] may be returned.
	 */
	public static function get(w:Int, h:Int, transparent:Bool = true, ?fillColor:Int, ?exactSize:Bool = false):BitmapData 
	{
		var res:BitmapData = null;
		
		// search the pool
		var node = _head;
		while (node != null) 
		{
			var bmd = node.bmd;
			if ((bmd.transparent == transparent && bmd.width >= w && bmd.height >= h) && 
				(!exactSize || (exactSize && bmd.width == w && bmd.height == h)))
			{
				res = bmd;
				
				// remove it from pool
				if (node.prev != null) node.prev.next = node.next;
				if (node.next != null) node.next.prev = node.prev;
				if (node == _head) _head = node.next;
				if (node == _tail) _tail = node.prev;
				node = null;
				_length--;
				break;
			}
			node = node.next;
		}
		
		if (res != null) 	// suitable BitmapData found in the pool
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
		else 	// not found: create a new one
		{
			res = new BitmapData(w, h, transparent, fillColor != null ? fillColor : 0xFFFFFFFF);
		}
		
		return res;
	}
	
	/** Adds bmd to the pool for future use. */
	public static function put(bmd:BitmapData):Void 
	{
		if (_length >= maxLength) 
		{
			var last = _tail;
			last.bmd.dispose();
			if (last.prev != null) 
			{
				last.prev.next = null;
				_tail = last.prev;
			}
			last = null;
			_length--;
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
		_length++;
	}
	
	/** Disposes of all the BitmapData in the pool. */
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
		_length = 0;
		_head = _tail = null;
	}
}

@:publicFields
private class FlxBitmapDataPoolNode {
	var bmd:BitmapData = null;
	var prev:FlxBitmapDataPoolNode = null;
	var next:FlxBitmapDataPoolNode = null;
	
	function new(bmd:BitmapData = null, prev:FlxBitmapDataPoolNode = null, next:FlxBitmapDataPoolNode = null):Void 
	{
		this.bmd = bmd;
		this.prev = prev;
		this.next = next;
	}
}