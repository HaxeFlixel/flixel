package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.system.debug.FlxDebugger;
import flixel.system.debug.Window;
import flixel.system.debug.interaction.Interaction;
import flixel.system.debug.interaction.tools.Tool;
import flixel.system.debug.watch.Tracker;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxHorizontalAlign;
import flixel.util.FlxSignal;
import openfl.display.BitmapData;

using flixel.util.FlxArrayUtil;
using flixel.util.FlxStringUtil;

/**
 * Accessed via `FlxG.debugger`.
 */
class DebuggerFrontEnd
{
	/**
	 * The amount of decimals Floats are rounded to in the debugger.
	 */
	public var precision:Int = 3;

	#if FLX_KEYBOARD
	/**
	 * The key codes used to toggle the debugger (see FlxG.keys for the keys available).
	 * Default keys: F2, ` and \. Set to null to deactivate.
	 */
	public var toggleKeys:Array<FlxKey> = [F2, GRAVEACCENT, BACKSLASH];
	#end

	/**
	 * Whether to draw the hitboxes of FlxObjects.
	 */
	public var drawDebug(default, set):Bool = false;

	/**
	 * Dispatched when `drawDebug` is changed.
	 */
	public var drawDebugChanged(default, null):FlxSignal = new FlxSignal();

	/**
	 * Dispatched when `visible` is changed.
	 * @since 4.1.0
	 */
	public var visibilityChanged(default, null):FlxSignal = new FlxSignal();

	public var visible(default, set):Bool = false;
	
	#if FLX_DEBUG
	/** Helper for adding and removing debug tools */
	public var tools:DebugToolsFrontEnd;
	
	/** Helper for adding and removing debug windows */
	public var windows:DebugWindowsFrontEnd;
	#end
	
	@:allow(flixel.FlxG)
	function new()
	{
		#if FLX_DEBUG
		tools = new DebugToolsFrontEnd();
		windows = new DebugWindowsFrontEnd();
		#end
	}
	
	/**
	 * Change the way the debugger's windows are laid out.
	 *
	 * @param	Layout	The layout codes can be found in FlxDebugger, for example FlxDebugger.MICRO
	 */
	public inline function setLayout(Layout:FlxDebuggerLayout):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.setLayout(Layout);
		#end
	}

	/**
	 * Just resets the debugger windows to whatever the last selected layout was (STANDARD by default).
	 */
	public inline function resetLayout():Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.resetLayout();
		#end
	}

	/**
	 * Create and add a new debugger button.
	 *
	 * @param   Position       Either LEFT, CENTER or RIGHT.
	 * @param   Icon           The icon to use for the button
	 * @param   UpHandler      The function to be called when the button is pressed.
	 * @param   ToggleMode     Whether this is a toggle button or not.
	 * @param   UpdateLayout   Whether to update the button layout.
	 * @return  The added button.
	 */
	public function addButton(Alignment:FlxHorizontalAlign, Icon:BitmapData, UpHandler:Void->Void, ToggleMode:Bool = false,
			UpdateLayout:Bool = true):FlxSystemButton
	{
		#if FLX_DEBUG
		return FlxG.game.debugger.addButton(Alignment, Icon, UpHandler, ToggleMode, UpdateLayout);
		#else
		return null;
		#end
	}

	/**
	 * Creates a new tracker window if there exists a tracking profile for the class / class of the object.
	 * By default, flixel classes like FlxBasic, FlxRect and FlxPoint are supported.
	 *
	 * @param	ObjectOrClass	The object or class to track
	 * @param	WindowTitle	Title of the tracker window, uses the class name by default
	 */
	public function track(ObjectOrClass:Dynamic, ?WindowTitle:String):Window
	{
		#if FLX_DEBUG
		if (Tracker.objectsBeingTracked.contains(ObjectOrClass))
			return null;

		var profile = Tracker.findProfile(ObjectOrClass);
		if (profile == null)
		{
			FlxG.log.error("Could not find a tracking profile for object of class '" + ObjectOrClass.getClassName(true) + "'.");
			return null;
		}
		else
			return FlxG.game.debugger.addWindow(new Tracker(profile, ObjectOrClass, WindowTitle));
		#end
		return null;
	}

	/**
	 * Adds a new TrackerProfile for track(). This also overrides existing profiles.
	 *
	 * @param	Profile	The TrackerProfile
	 */
	public inline function addTrackerProfile(Profile:TrackerProfile):Void
	{
		#if FLX_DEBUG
		Tracker.addProfile(Profile);
		#end
	}

	/**
	 * Removes and destroys a button from the debugger.
	 *
	 * @param	Button			The FlxSystemButton instance to remove.
	 * @param	UpdateLayout	Whether to update the button layout.
	 */
	public function removeButton(Button:FlxSystemButton, UpdateLayout:Bool = true):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.removeButton(Button, UpdateLayout);
		#end
	}
	
	function set_drawDebug(Value:Bool):Bool
	{
		if (drawDebug == Value)
			return drawDebug;

		drawDebug = Value;
		#if FLX_DEBUG
		drawDebugChanged.dispatch();
		#end
		return drawDebug;
	}

	function set_visible(value:Bool):Bool
	{
		if (visible == value)
			return visible;

		visible = value;

		#if FLX_DEBUG
		FlxG.game.debugger.visible = value;
		FlxG.game.debugger.tabChildren = value;

		visibilityChanged.dispatch();
		#end

		return visible;
	}
}

#if FLX_DEBUG
@:allow(flixel.system.frontEnds.DebuggerFrontEnd)
class DebugToolsFrontEnd
{
	public var activeTool(get, never):Tool;
	inline function get_activeTool() return interaction.activeTool;
	
	var interaction(get, never):Interaction;
	inline function get_interaction() return FlxG.game.debugger.interaction;
	
	function new() {}
	
	public function add(tool)
	{
		interaction.addTool(tool);
	}
	
	public function remove(tool)
	{
		interaction.removeTool(tool);
	}
}

@:allow(flixel.system.frontEnds.DebuggerFrontEnd)
class DebugWindowsFrontEnd
{
	var debugger(get, never):FlxDebugger;
	inline function get_debugger() return FlxG.game.debugger;
	
	function new() {}
	
	public function add(window, ?button)
	{
		debugger.addWindow(window);
		debugger.addWindowToggleButton(window, button);
	}
	
	public function remove(window)
	{
		debugger.removeWindow(window);
		if (window.toggleButton != null)
			debugger.removeButton(window.toggleButton);
	}
}
#end