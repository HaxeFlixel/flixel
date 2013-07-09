package flixel.system.debug;

import flash.display.Sprite;
import flash.geom.Rectangle;
import haxe.ds.StringMap;
import flixel.FlxG;
import flixel.system.FlxDebugger;
import flixel.util.FlxArray;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;

/**
 * A Visual Studio-style "watch" window, for use in the debugger overlay.
 * Track the values of any public variable in real-time, and/or edit their values on the fly.
 */
class Watch extends Window
{
	static private inline var MAX_LOG_LINES:Int = 1024;
	static private inline var LINE_HEIGHT:Int = 15;
	
	/**
	 * Whether a watch entry is currently being edited or not. 
	 */		
	public var editing:Bool;
	
	private var _names:Sprite;
	private var _values:Sprite;
	private var _watching:Array<WatchEntry>;
	private var _quickWatchList:Map<String, WatchEntry>;
	
	/**
	 * Creates a new window object.  This Flash-based class is mainly (only?) used by <code>FlxDebugger</code>.
	 * @param Title			The name of the window, displayed in the header bar.
	 * @param Width			The initial width of the window.
	 * @param Height		The initial height of the window.
	 * @param Resizable		Whether you can change the size of the window with a drag handle.
	 * @param Bounds		A rectangle indicating the valid screen area for the window.
	 * @param BGColor		What color the window background should be, default is gray and transparent.
	 * @param TopColor		What color the window header bar should be, default is black and transparent.
	 */
	public function new(Title:String, Width:Float, Height:Float, Resizable:Bool = true, Bounds:Rectangle = null, BGColor:Int = 0x7f7f7f7f, TopColor:Int = 0x7f000000)
	{
		super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
		
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
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_names != null)
		{
			removeChild(_names);
		}
		_names = null;
		if (_values != null)
		{
			removeChild(_values);
		}
		_values = null;
		if (_watching != null)
		{
			var i:Int = 0;
			var l:Int = _watching.length;
			while (i < l)
			{
				_watching[i++].destroy();
			}
			_watching = null;
		}
		_quickWatchList = null;
		
		super.destroy();
	}

	/**
	 * Add a new variable to the watch window.
	 * Has some simple code in place to prevent
	 * accidentally watching the same variable twice.
	 * @param AnyObject		The <code>Object</code> containing the variable you want to track, e.g. this or Player.velocity.
	 * @param VariableName	The <code>String</code> name of the variable you want to track, e.g. "width" or "x".
	 * @param DisplayName	Optional <code>String</code> that can be displayed in the watch window instead of the basic class-name information.
	 */
	public function add(AnyObject:Dynamic, VariableName:String, DisplayName:String = null):Void
	{
		// Don't add repeats
		var watchEntry:WatchEntry;
		var i:Int = 0;
		var l:Int = _watching.length;
		while(i < l)
		{
			watchEntry = _watching[i++];
			if ((watchEntry.object == AnyObject) && (watchEntry.field == VariableName))
			{
				return;
			}
		}
		
		// Good, no repeats, add away!
		watchEntry = new WatchEntry(_watching.length * LINE_HEIGHT, _width / 2, _width / 2 - 10, AnyObject, VariableName, DisplayName);
		
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
	
	#if !FLX_NO_DEBUG
	/**
	 * Add or update a quickWatch entry to the watch list in the debugger.
	 * Extremely useful when called in <code>update()</code> functions when there 
	 * doesn't exist a variable for a value you want to watch - so you won't have to create one.
	 * @param	Name		The name of the quickWatch entry, for example "mousePressed".
	 * @param	NewValue	The new value for this entry, for example <code>FlxG.mouse.pressed()</code>.
	 */
	public function updateQuickWatch(Name:String, NewValue:Dynamic):Void
	{
		// Does this quickWatch exist yet? If not, create one.
		if (_quickWatchList.get(Name) == null)
		{
			var quickWatch:WatchEntry = new WatchEntry(_watching.length * LINE_HEIGHT, _width / 2, _width / 2 - 10, null, null, Name);
			_names.addChild(quickWatch.nameDisplay);
			_values.addChild(quickWatch.valueDisplay);
			_watching.push(quickWatch);
			_quickWatchList.set(Name, quickWatch);
		}
		// Otherwise just update its value
		else 
		{
			var quickWatch:WatchEntry = _quickWatchList.get(Name);
			
			if (quickWatch != null) 
			{
				var text:String = Std.string(NewValue);
				
				if (Std.is(NewValue, StringMap))
					text = FlxStringUtil.formatStringMap(NewValue);
				else if (Std.is(NewValue, FlxPoint))
					text = FlxStringUtil.formatFlxPoint(NewValue, FlxDebugger.pointPrecision);
				
				quickWatch.valueDisplay.text = text;
			}
		}
	}
	#end
	
	/**
	 * Remove a variable from the watch window.
	 * @param 	AnyObject		The <code>Object</code> containing the variable you want to remove, e.g. this or Player.velocity.
	 * @param 	VariableName	The <code>String</code> name of the variable you want to remove, e.g. "width" or "x".  If left null, this will remove all variables of that object. 
	 * @param	QuickWatchName	In case you want to remove a quickWatch entry.
	 */
	public function remove(AnyObject:Dynamic, VariableName:String = null, QuickWatchName:String = null):Void
	{
		// Remove quickWatch entry
		if (AnyObject == null && VariableName == null && QuickWatchName != null)
		{
			var quickWatch:WatchEntry = _quickWatchList.get(QuickWatchName);
			
			if (quickWatch != null)
				removeEntry(quickWatch, FlxArray.indexOf(_watching, quickWatch));
			_quickWatchList.remove(QuickWatchName);
			
			// We're done here
			return;
		}
			
		// Remove regular entrys
		var watchEntry:WatchEntry;
		
		var i:Int = _watching.length - 1;
		while(i >= 0)
		{
			watchEntry = _watching[i];
			
			if ((watchEntry.object == AnyObject) && ((VariableName == null) || (watchEntry.field == VariableName)))
			{
				removeEntry(watchEntry, i);
			}
			
			i--;
		}
		watchEntry = null;
	}
	
	/**
	 * Helper function to acutally remove an entry.
	 */
	private function removeEntry(Entry:WatchEntry, Index:Int):Void
	{
		// Fast array removal (only do on arrays where order doesn't matter)
		_watching[Index] = _watching[_watching.length - 1];
		_watching.pop();
		
		_names.removeChild(Entry.nameDisplay);
		_values.removeChild(Entry.valueDisplay);
		Entry.destroy();
		
		// Reset the display heights of the remaining objects
		var i:Int = 0;
		var l:Int = _watching.length;
		while(i < l)
		{
			_watching[i].setY(i * LINE_HEIGHT);
			i++;
		}
	}
	
	/**
	 * Remove everything from the watch window.
	 */
	public function removeAll():Void
	{
		var watchEntry:WatchEntry;
		var i:Int = 0;
		var l:Int = _watching.length;
		while(i < l)
		{
			watchEntry = _watching.pop();
			_names.removeChild(watchEntry.nameDisplay);
			_values.removeChild(watchEntry.valueDisplay);
			watchEntry.destroy();
			i++;
		}
		//_watching.length = 0;
		_watching = [];
	}

	/**
	 * Update all the entries in the watch window.
	 */
	public function update():Void
	{
		#if !FLX_NO_DEBUG
		editing = false;
		var i:Int = 0;
		var l:Int = _watching.length;
		while(i < l)
		{
			if (!_watching[i++].updateValue())
			{
				editing = true;
			}
		}
		#end
	}
	
	/**
	 * Force any watch entries currently being edited to submit their changes.
	 */
	public function submit():Void
	{
		var i:Int = 0;
		var l:Int = _watching.length;
		var watchEntry:WatchEntry;
		while(i < l)
		{
			watchEntry = _watching[i++];
			if (watchEntry.editing)
			{
				watchEntry.submit();
			}
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
			_height = _watching.length*LINE_HEIGHT + 17;
		}

		super.updateSize();

		_values.x = _width/2 + 2;

		var i:Int = 0;
		var l:Int = _watching.length;
		while (i < l)
		{
			_watching[i++].updateWidth(_width / 2, _width / 2 - 10);
		}
	}
}