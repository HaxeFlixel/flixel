package flixel.system.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
using StringTools;

class FlxConditionals
{
	/**
	 * Rendering conditionals - only one may be defined. Can be defined by the user.
	 */
	static inline var FLX_RENDER_TILE = "FLX_RENDER_TILE";
	static inline var FLX_RENDER_BLIT = "FLX_RENDER_BLIT";
	
	/**
	 * Flixel-defined helper conditionals
	 */
	static inline var FLX_MOUSE_ADVANCED = "FLX_MOUSE_ADVANCED";
	static inline var FLX_NATIVE_CURSOR = "FLX_NATIVE_CURSOR";
	static inline var FLX_OPENFL_JOYSTICK_API = "FLX_OPENFL_JOYSTICK_API";
	static inline var FLX_SOUND_TRAY = "FLX_SOUND_TRAY";
	static inline var FLX_POINTER_INPUT = "FLX_POINTER_INPUT";
	static inline var FLX_POST_PROCESS = "FLX_POST_PROCESS";
	
	/**
	 * User-defined conditionals
	 */
	static inline var FLX_NO_MOUSE_ADVANCED = "FLX_NO_MOUSE_ADVANCED";
	static inline var FLX_NO_GAMEPAD = "FLX_NO_GAMEPAD";
	static inline var FLX_NO_NATIVE_CURSOR = "FLX_NO_NATIVE_CURSOR";
	static inline var FLX_NO_MOUSE = "FLX_NO_MOUSE";
	static inline var FLX_NO_TOUCH = "FLX_NO_TOUCH";
	static inline var FLX_NO_SOUND_SYSTEM = "FLX_NO_SOUND_SYSTEM";
	static inline var FLX_NO_SOUND_TRAY = "FLX_NO_SOUND_TRAY";
	static inline var FLX_NO_FOCUS_LOST_SCREEN = "FLX_NO_FOCUS_LOST_SCREEN";
	static inline var FLX_NO_DEBUG = "FLX_NO_DEBUG";
	static inline var FLX_RECORD = "FLX_RECORD";
	
	static var USER_DEFINABLE:Array<String> = [
		FLX_RENDER_BLIT,
		FLX_RENDER_TILE,
		FLX_NO_MOUSE,
		FLX_NO_MOUSE_ADVANCED,
		FLX_NO_NATIVE_CURSOR,
		FLX_NO_SOUND_SYSTEM,
		FLX_NO_TOUCH,
		FLX_NO_SOUND_SYSTEM,
		FLX_NO_SOUND_TRAY,
		FLX_NO_FOCUS_LOST_SCREEN,
		FLX_NO_DEBUG,
		FLX_RECORD];
	
	public static function run()
	{
		checkConditionals();
		defineConditionals();
		
		if (defined("flash"))
		{
			checkSwfVersion();
		}
	}
	
	private static function checkConditionals()
	{
		if (defined(FLX_RENDER_BLIT) && defined(FLX_RENDER_TILE))
		{
			Context.fatalError('Cannot define both $FLX_RENDER_BLIT and $FLX_RENDER_TILE.', Context.currentPos());
		}
		
		abortIfDefined(FLX_MOUSE_ADVANCED);
		abortIfDefined(FLX_NATIVE_CURSOR);
		abortIfDefined(FLX_OPENFL_JOYSTICK_API);
		abortIfDefined(FLX_SOUND_TRAY);
		abortIfDefined(FLX_POINTER_INPUT);
		abortIfDefined(FLX_POST_PROCESS);
		
		#if (haxe_ver >= "3.2")
			var defines = Context.getDefines();
			for (define in defines.keys())
			{
				if (define.startsWith("FLX_") && USER_DEFINABLE.indexOf(define) == -1)
				{
					Context.warning('"$define" is not a valid flixel-conditional.', Context.currentPos());
				}
			}
		#end
		
	}
	
	private static function abortIfDefined(conditional:String)
	{
		if (defined(conditional))
		{
			Context.fatalError('$conditional can only be defined by flixel.', Context.currentPos());
		}
	}
	
	/**
	 * Acts as a "typedef for conditionals" - complex "#if"s that are made up of
	 * several conditionals / negations and used commonly are shortened into a
	 * single conditional to avoid redundancy.
	 * 
	 * Also handles rendering conditionals.
	 */
	private static function defineConditionals()
	{
		// no rendering conditonal defined yet?
		if (!defined(FLX_RENDER_BLIT) && !defined(FLX_RENDER_TILE))
		{
			if (defined("flash") || defined("js"))
			{
				Compiler.define(FLX_RENDER_BLIT);
			}
			else
			{
				Compiler.define(FLX_RENDER_TILE);
			}
		}
		
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_MOUSE_ADVANCED) && (!defined("flash") || defined("flash11_2")))
		{
			Compiler.define(FLX_MOUSE_ADVANCED);
		}
		
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_NATIVE_CURSOR) && defined("flash10_2"))
		{
			Compiler.define(FLX_NATIVE_CURSOR);
		}
		
		if (defined("cpp") || defined("neko") || defined("bitfive"))
		{
			Compiler.define(FLX_OPENFL_JOYSTICK_API);
		}
		
		if (!defined(FLX_NO_SOUND_SYSTEM) && !defined(FLX_NO_SOUND_TRAY))
		{
			Compiler.define(FLX_SOUND_TRAY);
		}
		
		if (!defined(FLX_NO_TOUCH) || !defined(FLX_NO_MOUSE))
		{
			Compiler.define(FLX_POINTER_INPUT);
		}
		
		if (!defined(FLX_NO_GAMEPAD) && defined("bitfive"))
		{
			Compiler.define("bitfive_gamepads");
		}
		
		if (defined("cpp") || defined("neko"))
		{
			Compiler.define(FLX_POST_PROCESS);
		}
	}
	
	private static function checkSwfVersion()
	{
		swfVersionError("Native mouse cursors are", "10.2", FLX_NO_NATIVE_CURSOR);
		swfVersionError("Middle and right mouse button events are", "11.2", FLX_NO_MOUSE_ADVANCED);
		swfVersionError("Gamepad input is", "11.8", FLX_NO_GAMEPAD);
	}
	
	private static function swfVersionError(feature:String, version:String, conditional:String)
	{
		var errorMessage = '[feature] only supported in Flash Player version [version] or higher. '
			+ 'Define [conditional] to disable this feature or add <set name="SWF_VERSION" value="$version" /> to your Project.xml.';
		
		if (!defined("flash" + version.replace(".", "_")) && !defined(conditional))
		{
			Context.fatalError(errorMessage
				.replace("[feature]", feature)
				.replace("[version]", version)
				.replace("[conditional]", conditional),
				Context.currentPos());
		}
	}
	
	private static inline function defined(conditional:String)
	{
		return Context.defined(conditional);
	}
}
#end