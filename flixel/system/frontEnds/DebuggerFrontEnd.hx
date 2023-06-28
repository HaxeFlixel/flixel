package flixel.system.frontEnds;

import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.system.debug.FlxDebugger.FlxDebuggerLayout;
import flixel.system.debug.Window;
import flixel.system.debug.watch.Tracker;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxHorizontalAlign;
import flixel.util.FlxSignal;

using flixel.util.FlxStringUtil;
using flixel.util.FlxArrayUtil;

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

	@:allow(flixel.FlxG)
	function new() {}

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

	@:access(flixel.FlxGame.onFocus)
	function set_visible(Value:Bool):Bool
	{
		if (visible == Value)
			return visible;

		visible = Value;

		#if FLX_DEBUG
		FlxG.game.debugger.visible = Value;
		FlxG.game.debugger.tabChildren = Value;

		// if the debugger is non-visible, then we need to focus on game sprite,
		// so the game still will be able to capture key presses
		if (!Value)
		{
			FlxG.stage.focus = null;
			// setting focus to null will trigger a focus lost event, let's undo that
			FlxG.game.onFocus(null);

			#if FLX_MOUSE
			FlxG.mouse.enabled = true;
			#end
		}
		else
		{
			#if FLX_MOUSE
			// Debugger is visible, allow mouse input in the game only if the
			// interaction tool is not in use.
			FlxG.mouse.enabled = !FlxG.game.debugger.interaction.isInUse();
			#end
		}

		visibilityChanged.dispatch();
		#end

		return visible;
	}
}
