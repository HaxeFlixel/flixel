package flixel.system.debug.watch;

import openfl.display.DisplayObject;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.debug.FlxDebugger.GraphicWatch;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

using flixel.util.FlxStringUtil;
using flixel.util.FlxArrayUtil;

/**
 * A Visual Studio-style "watch" window, for use in the debugger overlay.
 * Track the values of any public variable in real-time, and/or edit their values on the fly.
 */
class Watch extends WatchBase<WatchEntry>
{
	#if FLX_DEBUG
	public function new(closable = false)
	{
		super(WatchEntry.new, "Watch", new GraphicWatch(0, 0), true, null, closable);
	}
	#end
}

class WatchBase<TEntry:WatchEntry> extends Window
{
	#if FLX_DEBUG
	static inline var LINE_HEIGHT:Int = 15;
	
	public var alwaysOnTop(get, set):Bool;
	inline function get_alwaysOnTop() return _alwaysOnTop;
	inline function set_alwaysOnTop(value:Bool) return _alwaysOnTop = value;
	
	final entriesContainer:ScrollSprite;
	final entries:Array<TEntry> = [];
	var create:(displayName:String, data:WatchEntryData)->TEntry;
	
	public function new(entryConstructor, title, ?icon, resizable = true, ?bounds, closable = false, alwaysOnTop = true)
	{
		create = entryConstructor;
		super(title, icon, 0, 0, resizable, bounds, closable, alwaysOnTop);
		
		entriesContainer = new ScrollSprite();
		entriesContainer.x = 2;
		entriesContainer.y = 15;
		addChild(entriesContainer);
		
		FlxG.signals.preStateSwitch.add(clear);
	}
	
	public function add(displayName:String, data:WatchEntryData):Void
	{
		if (isInvalid(displayName, data))
			return;
		
		var existing = getExistingEntry(displayName, data);
		if (existing != null)
		{
			switch (data)
			{
				case QUICK(_) | FUNCTION(_):
					existing.data = data;
				case _:
			}
			return;
		}

		addEntry(displayName, data);
	}

	function isInvalid(displayName:String, data:WatchEntryData):Bool
	{
		return switch (data)
		{
			case FIELD(object, field): object == null || field == null;
			case QUICK(value):
				displayName.isNullOrEmpty();
			case EXPRESSION(expression, _):
				expression.isNullOrEmpty();
			case FUNCTION(func):
				func == null;
		}
	}

	function getExistingEntry(displayName:String, data:WatchEntryData):TEntry
	{
		for (entry in entries)
		{
			if (data == null || data.match(QUICK(_) | FUNCTION(_)))
			{
				if (entry.displayName == displayName)
					return entry;
			}
			else if (entry.data.equals(data))
				return entry;
		}
		return null;
	}

	function addEntry(displayName:String, data:WatchEntryData, redraw = true)
	{
		final entry = create(displayName, data);
		entry.onRemove.addOnce(removeEntry.bind(entry));
		entries.push(entry);
		entriesContainer.addChild(entry);
		if (redraw)
			updateSize();
	}

	public function remove(displayName:String, data:WatchEntryData):Void
	{
		final existing = getExistingEntry(displayName, data);
		if (existing != null)
			removeEntry(existing);
	}

	function removeEntry(entry:TEntry)
	{
		entries.fastSplice(entry);
		entriesContainer.removeChild(entry);
		entry.destroy();
		updateSize();
	}

	/**
	 * internal method to remove all without calling updateSize
	 */
	function clear():Void
	{
		for (entry in entries)
		{
			entriesContainer.removeChild(entry);
			entry.destroy();
		}
		
		entries.resize(0);
	}

	public function removeAll():Void
	{
		clear();
	}

	override function update():Void
	{
		for (entry in entries)
		{
			if (entriesContainer.isChildVisible(entry))
				entry.updateValue();
		}
	}

	override function updateSize():Void
	{
		final oldMinSize = minSize.x;
		super.updateSize();
		minSize.x = oldMinSize;
		
		entriesContainer.setScrollSize(getMarginWidth(), getMarginHeight());
		resetEntries();
	}
	
	function getMarginWidth()
	{
		return _width - entriesContainer.x - (_resizable ? 5 : 3);
	}
	
	function getMarginHeight()
	{
		return _height - entriesContainer.y - 3;
	}
	
	function resetEntries():Void
	{
		final width = getMarginWidth();
		final sansNameWidth = Math.min(width * 0.8, getMaxMinWidth());
		final nameWidth = Math.min(getMaxNameWidth(), width - sansNameWidth);
		for (i in 0...entries.length)
		{
			final entry = entries[i];
			entry.y = i * LINE_HEIGHT;
			entry.updateSize(nameWidth, width);
		}
	}

	function getMaxNameWidth():Float
	{
		return getMax(function(entry) return entry.getNameWidth());
	}

	function getMaxMinWidth():Float
	{
		return getMax(function(entry) return entry.getMinWidth());
	}

	function getMax(getValue:WatchEntry->Float):Float
	{
		var max = 0.0;
		for (entry in entries)
		{
			var value = getValue(entry);
			if (value > max)
				max = value;
		}
		return max;
	}
	#end
}

class ScrollSprite extends Sprite
{
	var scroll = new Rectangle();
	
	public function new ()
	{
		super();
		
		addEventListener(Event.ADDED_TO_STAGE, function (e)
		{
			final stage = this.stage;
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll);
			addEventListener(Event.REMOVED_FROM_STAGE, (_)->stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll));
		});
	}
	
	function onMouseScroll(e:MouseEvent)
	{
		FlxG.watch.addQuick("mouseX", mouseX);
		FlxG.watch.addQuick("mouseY", mouseY);
		FlxG.watch.addQuick("scroll", scroll);
		if (mouseX > 0 && mouseX < scroll.width && mouseY - scroll.y > 0 && mouseY - scroll.y < scroll.height)
		{
			scroll.y -= e.delta;
			updateScroll();
		}
	}
	
	public function setScrollSize(width:Float, height:Float)
	{
		scroll.width = width;
		scroll.height = height;
		updateScroll();
	}
	
	function updateScroll()
	{
		scrollRect = null;
		
		if (scroll.bottom > this.height)
			scroll.y = height - scroll.height;
		
		if (scroll.y < 0)
			scroll.y = 0;
		
		scrollRect = scroll;
	}
	
	override function addChild(child)
	{
		super.addChild(child);
		updateScroll();
		return child;
	}
	
	public function isChildVisible(child:DisplayObject)
	{
		if (getChildIndex(child) == -1)
			throw "Invalid child, not a child of this container";
		
		return child.y < scroll.bottom && child.y + child.height > scroll.y;
	}
}