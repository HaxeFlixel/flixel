package flixel.system.debug;

import flash.display.Sprite;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.system.debug.ConsoleUtil.PathToVariable;
import flixel.system.debug.FlxDebugger;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import haxe.ds.StringMap;

/**
 * A Visual Studio-style "watch" window, for use in the debugger overlay.
 * Track the values of any public variable in real-time, and/or edit their values on the fly.
 */
class Watch extends Window
{
	#if !FLX_NO_DEBUG
	private static inline var MAX_LOG_LINES:Int = 1024;
	private static inline var LINE_HEIGHT:Int = 15;
	
	/**
	 * Whether a watch entry is currently being edited or not. 
	 */		
	public var editing:Bool;
	
	private var _names:Sprite;
	private var _values:Sprite;
	private var _watching:Array<WatchEntry>;
	private var _quickWatchList:Map<String, WatchEntry>;
	
	/**
	 * Creates a new watch window object.
	 */
	public function new(Closable:Bool = false)
	{
		super("watch", new GraphicWatch(0, 0), 0, 0, true, null, Closable);
		
		_names = new Sprite();
		_names.x = 2;
		_names.y = 15;
		addChild(_names);
		
		_values = new Sprite();
		_values.x = 2;
		_values.y = 15;
		addChild(_values);
		
		_watching = new Array<WatchEntry>();
		_quickWatchList = new Map<String, WatchEntry>();
		
		editing = false;
		
		removeAll();
		FlxG.signals.stateSwitched.add(removeAll);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_names != null)
		{
			removeChild(_names);
			_names = null;
		}
		if (_values != null)
		{
			removeChild(_values);
			_values = null;
		}
		if (_watching != null)
		{
			for (watchEntry in _watching)
			{
				watchEntry = FlxDestroyUtil.destroy(watchEntry);
			}
			_watching = null;
		}
		_quickWatchList = null;
		FlxG.signals.stateSwitched.remove(removeAll);
		
		super.destroy();
	}

	/**
	 * Add a new variable to the watch window. Has some simple code in place to prevent
	 * accidentally watching the same variable twice.
	 * 
	 * @param 	AnyObject		The Object containing the variable you want to track, e.g. this or Player.velocity.
	 * @param 	VariableName	The String name of the variable you want to track, e.g. "width" or "x".
	 * @param 	DisplayName		Optional String that can be displayed in the watch window instead of the basic class-name information.
	 */
	public function add(AnyObject:Dynamic, VariableName:String, ?DisplayName:String):Void
	{
		// Attempt to resolve variable paths, like FlxG.state.members.length
		var varData:PathToVariable = ConsoleUtil.resolveObjectAndVariable(VariableName, AnyObject);
		AnyObject = varData.object;
		VariableName = varData.variableName;
		
		// Don't add repeats
		for (watchEntry in _watching)
		{
			if ((watchEntry.object == AnyObject) && (watchEntry.field == VariableName))
			{
				return;
			}
		}
		
		// Good, no repeats, add away!
		var watchEntry = new WatchEntry((_watching.length * LINE_HEIGHT), (_width / 2), (_width / 2 - 10), AnyObject, VariableName, DisplayName);
		
		if (watchEntry.field == null)
		{
			watchEntry.destroy();
			watchEntry = null;
			return;
		}
		
		_names.addChild(watchEntry.nameDisplay);
		_values.addChild(watchEntry.valueDisplay);
		_watching.push(watchEntry);
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
			var quickWatch = new WatchEntry(_watching.length * LINE_HEIGHT, _width / 2, _width / 2 - 10, null, null, Name);
			_names.addChild(quickWatch.nameDisplay);
			_values.addChild(quickWatch.valueDisplay);
			_watching.push(quickWatch);
			_quickWatchList.set(Name, quickWatch);
		}
		
		//  Update the value
		var quickWatch:WatchEntry = _quickWatchList.get(Name);
		
		if (quickWatch != null) 
		{
			quickWatch.valueDisplay.text = Std.string(NewValue);
		}
	}
	
	/**
	 * Remove a variable from the watch window.
	 * 
	 * @param 	AnyObject		The Object containing the variable you want to remove, e.g. this or Player.velocity.
	 * @param 	VariableName	The String name of the variable you want to remove, e.g. "width" or "x".  If left null, this will remove all variables of that object. 
	 * @param	QuickWatchName	In case you want to remove a quickWatch entry.
	 */
	public function remove(AnyObject:Dynamic, VariableName:String = null, ?QuickWatchName:String):Void
	{
		// Remove quickWatch entry
		if (AnyObject == null && VariableName == null && QuickWatchName != null)
		{
			var quickWatch:WatchEntry = _quickWatchList.get(QuickWatchName);
			
			if (quickWatch != null)
			{
				removeEntry(quickWatch, _watching.indexOf(quickWatch));
			}
			_quickWatchList.remove(QuickWatchName);
			
			// We're done here
			return;
		}
		
		// Remove regular entrys
		for (i in 0..._watching.length)
		{
			var watchEntry:WatchEntry = _watching[i];
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
		FlxArrayUtil.fastSplice(_watching, Entry);
		
		_names.removeChild(Entry.nameDisplay);
		_values.removeChild(Entry.valueDisplay);
		Entry.destroy();
		
		// Reset the display heights of the remaining objects
		for (i in 0..._watching.length)
		{
			_watching[i].setY(i * LINE_HEIGHT);
		}
	}
	
	/**
	 * Remove everything from the watch window.
	 */
	public function removeAll():Void
	{
		for (watchEntry in _watching)
		{
			_names.removeChild(watchEntry.nameDisplay);
			_values.removeChild(watchEntry.valueDisplay);
			watchEntry.destroy();
		}
		
		_watching = [];
		_quickWatchList = new Map<String, WatchEntry>();
	}

	/**
	 * Update all the entries in the watch window.
	 */
	override public function update():Void
	{
		editing = false;
		
		for (watchEntry in _watching)
		{
			if (!watchEntry.updateValue())
				editing = true;
		}
	}
	
	/**
	 * Force any watch entries currently being edited to submit their changes.
	 */
	public function submit():Void
	{
		for (watchEntry in _watching)
		{
			if (watchEntry.editing)
				watchEntry.submit();
		}
		
		editing = false;
	}
	
	/**
	 * Update the Flash shapes to match the new size, and reposition the header, shadow, and handle accordingly.
	 * Also adjusts the width of the entries and stuff, and makes sure there is room for all the entries.
	 */
	override private function updateSize():Void
	{
		if (Std.int(_height) < _watching.length * LINE_HEIGHT + 17)
		{
			_height = _watching.length * LINE_HEIGHT + 17;
		}
		
		super.updateSize();
		
		_values.x = _width/2 + 2;
		
		for (watchEntry in _watching)
		{
			watchEntry.updateWidth(_width / 2, _width / 2 - 10);
		}
	}
	#end
}