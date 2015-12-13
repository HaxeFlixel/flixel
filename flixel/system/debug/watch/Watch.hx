package flixel.system.debug.watch;

import flash.display.Sprite;
import flixel.FlxG;
import flixel.system.debug.FlxDebugger;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;

/**
 * A Visual Studio-style "watch" window, for use in the debugger overlay.
 * Track the values of any public variable in real-time, and/or edit their values on the fly.
 */
class Watch extends Window
{
	#if !FLX_NO_DEBUG
	private static inline var LINE_HEIGHT:Int = 15;
	
	private var _names:Sprite;
	private var _values:Sprite;
	private var _watchEntries:Array<WatchEntry> = [];
	private var _quickWatchList:Map<String, WatchEntry> = new Map<String, WatchEntry>();
	
	/**
	 * Creates a new watch window object.
	 */
	public function new(Closable:Bool = false)
	{
		super("Watch", new GraphicWatch(0, 0), 0, 0, true, null, Closable);
		
		_names = new Sprite();
		_names.x = 2;
		_names.y = 15;
		addChild(_names);
		
		_values = new Sprite();
		_values.x = 2;
		_values.y = 15;
		addChild(_values);
		
		removeAll();
		FlxG.signals.stateSwitched.add(removeAll);
	}
	
	override public function destroy():Void
	{
		_names = FlxDestroyUtil.removeChild(this, _names);
		_values = FlxDestroyUtil.removeChild(this, _values);
		_watchEntries = FlxDestroyUtil.destroyArray(_watchEntries);
		_quickWatchList = null;
		FlxG.signals.stateSwitched.remove(removeAll);
		
		super.destroy();
	}

	/**
	 * Add a new variable to the watch window. Prevents the same variable being watched twice.
	 * 
	 * @param 	AnyObject		The Object containing the variable you want to track, e.g. this or Player.velocity.
	 * @param 	VariableName	The String name of the variable you want to track, e.g. "width" or "x".
	 * @param 	DisplayName		Optional String that can be displayed in the watch window instead of the basic class-name information.
	 */
	public function add(AnyObject:Dynamic, VariableName:String, ?DisplayName:String):Void
	{
		if (DisplayName == null)
			DisplayName = VariableName;
		
		// Don't add repeats
		for (watchEntry in _watchEntries)
		{
			if ((watchEntry.object == AnyObject) && (watchEntry.field == VariableName))
			{
				return;
			}
		}
		
		// Good, no repeats, add away!
		addEntry(AnyObject, VariableName, DisplayName);
	}
	
	/**
	 * Add or update a quickWatch entry to the watch list in the debugger. Extremely useful when called in update() 
	 * functions when there doesn't exist a variable for a value you want to watch - so you won't have to create one.
	 * 
	 * @param	Name		The name of the quickWatch entry, for example "mousePressed".
	 * @param	NewValue	The new value for this entry, for example FlxG.mouse.pressed.
	 */
	public function updateQuickWatch(Name:String, NewValue:Dynamic):Void
	{
		// Does this quickWatch exist yet? If not, create one.
		if (_quickWatchList.get(Name) == null)
		{
			var quickWatch = addEntry(null, null, Name);
			_quickWatchList.set(Name, quickWatch);
		}
		
		//  Update the value
		var quickWatch:WatchEntry = _quickWatchList.get(Name);
		if (quickWatch != null) 
		{
			quickWatch.valueDisplay.text = Std.string(NewValue);
		}
	}
	
	private function addEntry(object:Dynamic, field:String, custom:String):WatchEntry
	{
		var entry = new WatchEntry(_watchEntries.length * LINE_HEIGHT, getNameWidth(), getValueWidth(), object, field, custom);
		_names.addChild(entry.nameDisplay);
		_values.addChild(entry.valueDisplay);
		_watchEntries.push(entry);
		return entry;
	}
	
	/**
	 * Remove a variable from the watch window.
	 * 
	 * @param 	AnyObject		The Object containing the variable you want to remove, e.g. this or Player.velocity.
	 * @param 	VariableName	The String name of the variable you want to remove, e.g. "width" or "x".  If left null, this will remove all variables of that object. 
	 * @param	QuickWatchName	In case you want to remove a quickWatch entry.
	 */
	public function remove(AnyObject:Dynamic, ?VariableName:String, ?QuickWatchName:String):Void
	{
		if (QuickWatchName != null) // Remove quickWatch entry
		{
			var quickWatch:WatchEntry = _quickWatchList.get(QuickWatchName);
			if (quickWatch != null)
			{
				removeEntry(quickWatch, _watchEntries.indexOf(quickWatch));
			}
			_quickWatchList.remove(QuickWatchName);
			
			return; // We're done here
		}
		
		for (i in 0..._watchEntries.length) // Remove regular entrys
		{
			var watchEntry:WatchEntry = _watchEntries[i];
			if (watchEntry != null && watchEntry.object == AnyObject && ((VariableName == null) || (watchEntry.field == VariableName)))
			{
				removeEntry(watchEntry, i);
			}
		}
	}
	
	/**
	 * Helper function to acutally remove an entry.
	 */
	private function removeEntry(Entry:WatchEntry, Index:Int):Void
	{
		FlxArrayUtil.fastSplice(_watchEntries, Entry);
		
		_names.removeChild(Entry.nameDisplay);
		_values.removeChild(Entry.valueDisplay);
		Entry.destroy();
		
		// Reset the display heights of the remaining objects
		for (i in 0..._watchEntries.length)
		{
			_watchEntries[i].setY(i * LINE_HEIGHT);
		}
	}
	
	/**
	 * Remove everything from the watch window.
	 */
	public function removeAll():Void
	{
		for (watchEntry in _watchEntries)
		{
			_names.removeChild(watchEntry.nameDisplay);
			_values.removeChild(watchEntry.valueDisplay);
			watchEntry.destroy();
		}
		
		_watchEntries = [];
		_quickWatchList = new Map<String, WatchEntry>();
	}

	/**
	 * Update all the entries in the watch window.
	 */
	override public function update():Void
	{
		for (watchEntry in _watchEntries)
			watchEntry.updateValue();
	}
	
	/**
	 * Update the Flash shapes to match the new size, and reposition the header, shadow, and handle accordingly.
	 * Also adjusts the width of the entries and stuff, and makes sure there is room for all the entries.
	 */
	override private function updateSize():Void
	{
		if (Std.int(_height) < _watchEntries.length * LINE_HEIGHT + 17)
		{
			_height = _watchEntries.length * LINE_HEIGHT + 17;
		}
		
		super.updateSize();
		
		var newNameWidth = getNameWidth();
		_values.x = newNameWidth + 2;
		
		for (watchEntry in _watchEntries)
		{
			watchEntry.updateWidth(newNameWidth, getValueWidth());
		}
	}
	
	private function getNameWidth():Float
	{
		return Math.min(100, _width / 2);
	}
	
	private function getValueWidth():Float
	{
		return _width - getNameWidth() - 10;
	}
	#end
}
