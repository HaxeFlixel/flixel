package flixel.system.frontEnds;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.system.debug.Tracker;
import flixel.system.debug.Window;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxSignal;
import flixel.util.FlxStringUtil;
import flixel.system.debug.FlxDebugger;

class DebuggerFrontEnd
{	
	/**
	 * The amount of decimals FlxPoints / FlxRects are rounded to in log / watch / trace.
	 */
	public var precision:Int = 3; 
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to toggle the debugger (see FlxG.keys for the keys available).
	 * Default keys: ` and \. Set to null to deactivate.
	 */
	public var toggleKeys:Array<FlxKey> = [GRAVEACCENT, BACKSLASH];
	#end
	
	/**
	 * Whether to draw the hitboxes of FlxObjects.
	 */
	public var drawDebug(default, set):Bool = false;
	/**
	 * Dispatched when drawDebug is changed.
	 */
	public var drawDebugChanged(default, null):FlxSignal = new FlxSignal();
	
	public var visible(default, set):Bool = false;
	
	/**
	 * Change the way the debugger's windows are laid out.
	 * 
	 * @param	Layout	The layout codes can be found in FlxDebugger, for example FlxDebugger.MICRO
	 */
	public inline function setLayout(Layout:FlxDebuggerLayout):Void
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
	public function addButton(Alignment:FlxButtonAlignment, Icon:BitmapData, UpHandler:Void->Void, ToggleMode:Bool = false, UpdateLayout:Bool = true):FlxSystemButton
	{
		#if !FLX_NO_DEBUG
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
		#if !FLX_NO_DEBUG
		if (Tracker.objectsBeingTracked.indexOf(ObjectOrClass) == -1)
		{
			var profile = Tracker.findProfile(ObjectOrClass);
			if (profile == null)
			{
				FlxG.log.error("Could not find a tracking profile for object of class '" +
					FlxStringUtil.getClassName(ObjectOrClass, true) + "'."); 
				return null;
			}
			else 
			{
				return FlxG.game.debugger.addWindow(new Tracker(profile, ObjectOrClass, WindowTitle));
			}
		}
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
	private function new() {}
	
	private inline function set_drawDebug(Value:Bool):Bool
	{
		#if !FLX_NO_DEBUG
		if (Value != drawDebug)
			drawDebugChanged.dispatch();
		#end
		
		return drawDebug = Value;
	}
	
	private inline function set_visible(Value:Bool):Bool
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.visible = Value;
		#end
		
		return visible = Value;
	}
}
