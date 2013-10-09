package flixel.system.frontEnds;

import flixel.FlxBasic;
import flixel.FlxG;

class DebuggerFrontEnd
{
    /**
 	 * Whether the debugger is visible or not.
 	 * @default false
 	 */
    public var visible(default, set):Bool = false;

    inline private function set_visible(Visible:Bool):Bool
    {
        #if !FLX_NO_DEBUG
 		FlxG.game.debugger.visible = Visible;
        #end
        return visible = Visible;
    }

	#if !FLX_NO_DEBUG
	/**
	 * Whether to show visual debug displays or not. Doesn't exist in <code>FLX_NO_DEBUG</code> mode.
	 * @default false
	 */
    public var visualDebug:Bool = false;

	/**
	 * The amount of decimals FlxPoints are rounded to in log / watch.
	 * @default 3
	 */
	public var pointPrecision:Int = 3; 
	#end
	
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
	 * 
	 * @param	Layout	The layout codes can be found in <code>FlxDebugger</code>, for example <code>FlxDebugger.MICRO</code>
	 */
	inline public function setLayout(Layout:Int):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.setLayout(Layout);
		#end
	}
	
	/**
	 * Just resets the debugger windows to whatever the last selected layout was (<code>STANDARD</code> by default).
	 */
	inline public function resetLayout():Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.resetLayout();
		#end
	}
}