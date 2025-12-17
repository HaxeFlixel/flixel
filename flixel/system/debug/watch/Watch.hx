package flixel.system.debug.watch;

import flixel.FlxG;
import flixel.system.debug.FlxDebugger;
import flixel.system.debug.ScrollSprite;

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
		super(WatchEntry.new, "Watch", Icon.watch, true, null, closable);
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
	final scrollbar:ScrollBar;
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
		
		scrollbar = entriesContainer.createScrollBar();
		scrollbar.y = entriesContainer.y;
		addChild(scrollbar);
		
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
		
		scrollbar.x = _width - scrollbar.width - 2;
		scrollbar.resize(getMarginHeight() - 10);
		
		entriesContainer.setScrollSize(getMarginWidth(), getMarginHeight());
		resetEntries();
	}
	
	function getMarginWidth()
	{
		return _width - entriesContainer.x - (_resizable ? 5 : 3) - scrollbar.width - 4;
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