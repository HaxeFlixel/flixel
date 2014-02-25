package flixel.system.frontEnds;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.system.debug.Tracker;
import flixel.system.debug.FlxDebugger.ButtonAlignment;
import flixel.system.debug.FlxDebugger.DebuggerLayout;
import flixel.system.debug.Window;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxStringUtil;

class DebuggerFrontEnd
{	
	/**
	 * Whether to draw the hitboxes of FlxObjects.
	 */
	public var drawDebug:Bool = false;
	
	/**
	 * The amount of decimals FlxPoints / FlxRects are rounded to in log / watch / trace.
	 */
	public var precision:Int = 3; 
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to toggle the debugger (see FlxG.keys for the keys available).
	 * Default keys: ` and \. Set to null to deactivate.
	 * @default ["GRAVEACCENT", "BACKSLASH"]
	 */
	public var toggleKeys:Array<String>;
	#end
	
	public var visible(default, set):Bool = false;
	
	/**
	 * Change the way the debugger's windows are laid out.
	 * 
	 * @param	Layout	The layout codes can be found in FlxDebugger, for example FlxDebugger.MICRO
	 */
	public inline function setLayout(Layout:DebuggerLayout):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.setLayout(Layout);
		#end
	}
	
	/**
	 * Just resets the debugger windows to whatever the last selected layout was (STANDARD by default).
	 */
	public inline function resetLayout():Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.resetLayout();
		#end
	}
	
	/**
	 * Create and add a new debugger button.
	 * 
	 * @param   Position       Either LEFT, MIDDLE or RIGHT.
	 * @param   Icon           The icon to use for the button
	 * @param   UpHandler      The function to be called when the button is pressed.
	 * @param   ToggleMode     Whether this is a toggle button or not.
	 * @param   UpdateLayout   Whether to update the button layout.
	 * @return  The added button.
	 */
	public function addButton(Alignment:ButtonAlignment, Icon:BitmapData, UpHandler:Void->Void, ToggleMode:Bool = false, UpdateLayout:Bool = true):FlxSystemButton
	{
		#if !FLX_NO_DEBUG
		return FlxG.game.debugger.addButton(Alignment, Icon, UpHandler, ToggleMode, UpdateLayout);
		#else
		return null;
		#end
	}
	
	/**
	 * Creates a new tracker window, if there exists a tracking profile for the class of the object.
	 * By default, flixel classes like FlxBasics, FlxRect and FlxPoint are supported.
	 * 
	 * @param	Object	The object to track
	 * @param	WindowTitle	Title for the tracker window, uses the Object's class name by default
	 */
	public function track(Object:Dynamic, ?WindowTitle:String):Window
	{
		#if !FLX_NO_DEBUG
		if (Lambda.indexOf(Tracker.objectsBeingTracked, Object) == -1)
		{
			var profile = Tracker.findProfile(Object);
			if (profile == null)
			{
				FlxG.log.error("FlxG.debugger.track(): Could not find a tracking profile for this object of class '" + FlxStringUtil.getClassName(Object, true) + "'."); 
				return null;
			}
			else 
			{
				return FlxG.game.debugger.addWindow(new Tracker(profile, Object, WindowTitle));
			}
		}
		else 
		{
			return null;
		}
		#else 
		return null;
		#end
	}
	
	/**
	 * Adds a new TrackerProfile for track(). This also overrides existing profiles.
	 * 
	 * @param	Profile	The TrackerProfile
	 */
	public inline function addTrackerProfile(Profile:TrackerProfile):Void
	{
		#if !FLX_NO_DEBUG
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
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.removeButton(Button, UpdateLayout);
		#end
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		#if !FLX_NO_KEYBOARD
		toggleKeys = ["GRAVEACCENT", "BACKSLASH"];
		#end
	}
	
	private inline function set_visible(Visible:Bool):Bool
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.visible = Visible;
		#end
		
		return visible = Visible;
	}
}
