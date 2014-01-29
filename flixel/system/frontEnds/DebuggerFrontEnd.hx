package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.FlxDebugger.ButtonAlignment;
import flixel.system.debug.FlxDebugger.DebuggerLayout;
import flixel.system.ui.FlxSystemButton;

class DebuggerFrontEnd
{	
	/**
	 * Whether to show visual debug displays or not. Doesn't exist in <code>FLX_NO_DEBUG</code> mode.
	 * @default false
	 */
	public var drawDebug:Bool = false;
	
	/**
	 * The amount of decimals FlxPoints / FlxRects are rounded to in log / watch / trace.
	 * @default 3
	 */
	public var precision:Int = 3; 
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to toggle the debugger (see <code>FlxG.keys</code> for the keys available).
	 * Default keys: ` and \. Set to <code>null</code> to deactivate.
	 * @default ["GRAVEACCENT", "BACKSLASH"]
	 */
	public var toggleKeys:Array<String>;
	#end
	
	/**
	 * Used to instantiate this class and assign a value to <code>toggleKeys</code>
	 */
	public function new() 
	{
		#if !FLX_NO_KEYBOARD
		toggleKeys = ["GRAVEACCENT", "BACKSLASH"];
		#end
	}
	
	/**
	 * Change the way the debugger's windows are laid out.
	 * @param	Layout	The layout codes can be found in <code>FlxDebugger</code>, for example <code>FlxDebugger.MICRO</code>
	 */
	public inline function setLayout(Layout:DebuggerLayout):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.setLayout(Layout);
		#end
	}
	
	/**
	 * Just resets the debugger windows to whatever the last selected layout was (<code>STANDARD</code> by default).
	 */
	public inline function resetLayout():Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.resetLayout();
		#end
	}
	
	/**
	 * Whether the debugger is visible or not.
	 * @default false
	 */
	public var visible(default, set):Bool = false;
	
	private inline function set_visible(Visible:Bool):Bool
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.visible = Visible;
		#end
		
		return visible = Visible;
	}
	
	/**
	 * Create and add a new debugger button.
	 * @param	Position	Either LEFT,  MIDDLE or RIGHT.
	 * @param	IconPath	The path to the image to use as the icon for the button.
	 * @param	DownHandler	The function to be called when the button is pressed.
	 * @param	ToggleMode	Whether this is a toggle button or not.
	 * @param	UpdateLayout	Whether to update the button layout.
	 */
	public function addButton(Alignment:ButtonAlignment, IconPath:String, DownHandler:Void->Void, ToggleMode:Bool = false, UpdateLayout:Bool = true):FlxSystemButton
	{
		#if !FLX_NO_DEBUG
		return FlxG.game.debugger.addButton(Alignment, IconPath, DownHandler, ToggleMode, UpdateLayout);
		#else
		return null;
		#end
	}
	
	/**
	 * Removes and destroys a button from the debugger.
	 * @param	Button			The FlxSystemButton instance to remove.
	 * @param	UpdateLayout	Whether to update the button layout.
	 */
	public function removeButton(Button:FlxSystemButton, UpdateLayout:Bool = true):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.removeButton(Button, UpdateLayout);
		#end
	}
}
