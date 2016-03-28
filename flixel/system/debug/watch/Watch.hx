package flixel.system.debug.watch;

import flixel.FlxG;
import flixel.system.debug.FlxDebugger.GraphicWatch;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import openfl.display.Sprite;
using flixel.util.FlxStringUtil;

/**
 * A Visual Studio-style "watch" window, for use in the debugger overlay.
 * Track the values of any public variable in real-time, and/or edit their values on the fly.
 */
class Watch extends Window
{
	#if FLX_DEBUG
	private static inline var LINE_HEIGHT:Int = 15;
	
	private var names:Sprite;
	private var values:Sprite;
	private var entries:Array<WatchEntry> = [];

	public function new(closable:Bool = false)
	{
		super("Watch", new GraphicWatch(0, 0), 0, 0, true, null, closable);
		
		names = createSprite();
		values = createSprite();
		
		FlxG.signals.stateSwitched.add(removeAll);
	}
	
	private function createSprite():Sprite
	{
		var sprite = new Sprite();
		sprite.x = 2;
		sprite.y = 15;
		addChild(sprite);
		return sprite;
	}
	
	override public function destroy():Void
	{
		names = FlxDestroyUtil.removeChild(this, names);
		values = FlxDestroyUtil.removeChild(this, values);
		entries = FlxDestroyUtil.destroyArray(entries);
		FlxG.signals.stateSwitched.remove(removeAll);
		
		super.destroy();
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
				case QUICK(value):
					existing.data = data;
				case _:
			}
			return;
		}
		
		addEntry(displayName, data);
	}
	
	private function isInvalid(displayName:String, data:WatchEntryData):Bool
	{
		return switch (data)
		{
			case FIELD(object, field):
				object == null || field == null;
			case QUICK(value):
				displayName.isNullOrEmpty();
			case EXPRESSION(expression):
				expression.isNullOrEmpty();
		}
	}
	
	private function getExistingEntry(displayName:String, data:WatchEntryData):WatchEntry
	{
		for (entry in entries)
		{
			if (data.match(QUICK(_)))
			{
				if (entry.displayName == displayName)
					return entry;
			}
			else if (entry.data.equals(data))
				return entry;
		}
		return null;
	}
	
	private function addEntry(displayName:String, data:WatchEntryData):Void
	{
		var entry = new WatchEntry(displayName, data);
		names.addChild(entry.nameText);
		values.addChild(entry.valueText);
		entry.setY(entries.length * LINE_HEIGHT);
		entries.push(entry);
	}
	
	public function remove(displayName:String, data:WatchEntryData):Void
	{
		var existing = getExistingEntry(displayName, data);
		if (existing != null)
			removeEntry(existing);
	}
	
	private function removeEntry(entry:WatchEntry):Void
	{
		FlxArrayUtil.fastSplice(entries, entry);
		
		names.removeChild(entry.nameText);
		values.removeChild(entry.valueText);
		entry.destroy();
		
		// Reset the display heights of the remaining objects
		for (i in 0...entries.length)
			entries[i].setY(i * LINE_HEIGHT);
	}
	
	/**
	 * Remove everything from the watch window.
	 */
	public function removeAll():Void
	{
		for (entry in entries)
			removeEntry(entry);
		
		entries = [];
	}

	override public function update():Void
	{
		for (entry in entries)
			entry.updateValue();
	}
	
	/**
	 * Update the shapes to match the new size, and reposition the header, shadow, and handle accordingly.
	 * Also adjusts the width of the entries and stuff, and makes sure there is room for all the entries.
	 */
	override private function updateSize():Void
	{
		var maxHeight = entries.length * LINE_HEIGHT + 17;
		if (Std.int(_height) < maxHeight)
			_height = maxHeight;
		
		super.updateSize();
		
		var newNameWidth = getNameWidth();
		values.x = newNameWidth + 2;
		
		for (entry in entries)
			entry.updateWidth(newNameWidth, getValueWidth());
	}
	
	private function getNameWidth():Float
	{
		return Math.min(120, _width / 2);
	}
	
	private function getValueWidth():Float
	{
		return _width - getNameWidth() - 10;
	}
	#end
}