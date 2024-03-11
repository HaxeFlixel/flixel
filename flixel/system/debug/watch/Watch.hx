package flixel.system.debug.watch;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.debug.FlxDebugger.GraphicWatch;
import openfl.display.Sprite;

using flixel.util.FlxStringUtil;
using flixel.util.FlxArrayUtil;

/**
 * A Visual Studio-style "watch" window, for use in the debugger overlay.
 * Track the values of any public variable in real-time, and/or edit their values on the fly.
 */
class Watch extends Window
{
	#if FLX_DEBUG
	static inline var LINE_HEIGHT:Int = 15;

	var entriesContainer:Sprite;
	var entriesContainerOffset:FlxPoint = FlxPoint.get(2, 15);
	var entries:Array<WatchEntry> = [];

	public function new(closable:Bool = false)
	{
		super("Watch", new GraphicWatch(0, 0), 0, 0, true, null, closable);

		entriesContainer = new Sprite();
		entriesContainer.x = entriesContainerOffset.x;
		entriesContainer.y = entriesContainerOffset.y;
		addChild(entriesContainer);

		FlxG.signals.preStateSwitch.add(removeAll);
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

	function getExistingEntry(displayName:String, data:WatchEntryData):WatchEntry
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

	function addEntry(displayName:String, data:WatchEntryData):Void
	{
		var entry = new WatchEntry(displayName, data, removeEntry);
		entries.push(entry);
		entriesContainer.addChild(entry);
		resetEntries();
	}

	public function remove(displayName:String, data:WatchEntryData):Void
	{
		var existing = getExistingEntry(displayName, data);
		if (existing != null)
			removeEntry(existing);
	}

	function removeEntry(entry:WatchEntry):Void
	{
		entries.fastSplice(entry);
		entriesContainer.removeChild(entry);
		entry.destroy();
		resetEntries();
	}

	public function removeAll():Void
	{
		for (i in 0...entries.length)
		{
			var entry = entries[i];
			entriesContainer.removeChild(entry);
			entry.destroy();
		}
		entries.splice(0, entries.length);
		resetEntries();
	}

	override public function update():Void
	{
		for (entry in entries)
			entry.updateValue();
	}

	override function updateSize():Void
	{
		minSize.setTo(getMaxMinWidth() + entriesContainerOffset.x, entriesContainer.height + entriesContainerOffset.y);
		super.updateSize();
		resetEntries();
	}

	function resetEntries():Void
	{
		for (i in 0...entries.length)
		{
			var entry = entries[i];
			entry.y = i * LINE_HEIGHT;
			entry.updateSize(getMaxNameWidth(), _width);
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
