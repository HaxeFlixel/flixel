package flixel.system.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
using StringTools;

private enum UserDefines
{
	FLX_NO_MOUSE_ADVANCED;
	FLX_NO_GAMEPAD;
	FLX_NO_NATIVE_CURSOR;
	FLX_NO_MOUSE;
	FLX_NO_TOUCH;
	FLX_NO_KEYBOARD;
	FLX_NO_SOUND_SYSTEM;
	FLX_NO_SOUND_TRAY;
	FLX_NO_FOCUS_LOST_SCREEN;
	FLX_NO_DEBUG;
	FLX_RECORD;
	/**
	 * Mostly internal, makes sure that flixel can be built with pure haxe
	 * (as opposed to lime-tools). Needed for API doc generation and unit tests.
	 */
	FLX_HAXE_BUILD;
	/** only one of these two may be defined */
	FLX_RENDER_TILE;
	FLX_RENDER_BLIT;
	/* additional rendering define */
	FLX_RENDER_TRIANGLE;
}

/**
 * These are "typedef defines" - complex #if / #elseif conditions
 * are shortened into a single define to avoid the redundancy
 * that comes with using them frequently.
 */
private enum HelperDefines
{
	FLX_MOUSE_ADVANCED;
	FLX_NATIVE_CURSOR;
	FLX_SOUND_TRAY;
	FLX_POINTER_INPUT;
	FLX_POST_PROCESS;
	
	FLX_JOYSTICK_API;
	FLX_GAMEINPUT_API;
}

class FlxDefines
{
	public static function run()
	{
		#if (haxe_ver < "3.1.1")
		Context.fatalError('The minimum required Haxe version for HaxeFlixel is 3.1.1. '
			+ 'Please install a newer version.', FlxMacroUtil.here());
		#end
		
		checkDefines();
		defineRenderingDefine();
		defineHelperDefines();
		
		if (defined("flash"))
		{
			checkSwfVersion();
		}
	}
	
	private static function checkDefines()
	{
		if (defined(FLX_RENDER_BLIT) && defined(FLX_RENDER_TILE))
		{
			Context.fatalError('You cannot define both $FLX_RENDER_BLIT and $FLX_RENDER_TILE.', FlxMacroUtil.here());
		}
		
		for (define in HelperDefines.getConstructors())
		{
			abortIfDefined(define);
		}
		
		#if (haxe_ver >= "3.2")
		var userDefinable = UserDefines.getConstructors();
		for (define in Context.getDefines().keys())
		{
			if (define.startsWith("FLX_") && userDefinable.indexOf(define) == -1)
			{
				Context.warning('"$define" is not a valid flixel define.', FlxMacroUtil.here());
			}
		}
		#end
	}
	
	private static function abortIfDefined(define:String)
	{
		if (defined(define))
		{
			Context.fatalError('$define can only be defined by flixel.', FlxMacroUtil.here());
		}
	}
	
	private static function defineRenderingDefine()
	{
		if (!defined(FLX_RENDER_BLIT) && !defined(FLX_RENDER_TILE))
		{
			if (defined("flash") || defined("js"))
			{
				define(FLX_RENDER_BLIT);
			}
			else
			{
				define(FLX_RENDER_TILE);
			}
		}
	}
	
	private static function defineHelperDefines()
	{
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_MOUSE_ADVANCED) && (!defined("flash") || defined("flash11_2")))
		{
			define(FLX_MOUSE_ADVANCED);
		}
		
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_NATIVE_CURSOR) && defined("flash10_2"))
		{
			define(FLX_NATIVE_CURSOR);
		}
		
		if (defined("next") || defined("flash11_8"))
		{
			define(FLX_GAMEINPUT_API);
		}
		else if (!defined("next") && (defined("cpp") || defined("neko") || defined("bitfive")))
		{
			define(FLX_JOYSTICK_API);
		}
		
		if (!defined(FLX_NO_SOUND_SYSTEM) && !defined(FLX_NO_SOUND_TRAY))
		{
			define(FLX_SOUND_TRAY);
		}
		
		if (!defined(FLX_NO_TOUCH) || !defined(FLX_NO_MOUSE))
		{
			define(FLX_POINTER_INPUT);
		}
		
		if (!defined(FLX_NO_GAMEPAD) && defined("bitfive"))
		{
			define("bitfive_gamepads");
		}
		
		if (defined("cpp") || defined("neko"))
		{
			define(FLX_POST_PROCESS);
		}
	}
	
	private static function checkSwfVersion()
	{
		swfVersionError("Native mouse cursors are", "10.2", FLX_NO_NATIVE_CURSOR);
		swfVersionError("Middle and right mouse button events are", "11.2", FLX_NO_MOUSE_ADVANCED);
		swfVersionError("Gamepad input is", "11.8", FLX_NO_GAMEPAD);
	}
	
	private static function swfVersionError(feature:String, version:String, define:UserDefines)
	{
		var errorMessage = '[feature] only supported in Flash Player version [version] or higher. '
			+ 'Define [define] to disable this feature or add <set name="SWF_VERSION" value="$version" /> to your Project.xml.';
		
		if (!defined("flash" + version.replace(".", "_")) && !defined(define))
		{
			Context.fatalError(errorMessage
				.replace("[feature]", feature)
				.replace("[version]", version)
				.replace("[define]", define.getName()),
				FlxMacroUtil.here());
		}
	}
	
	private static inline function defined(define:Dynamic)
	{
		return Context.defined(Std.string(define));
	}
	
	private static inline function define(define:Dynamic)
	{
		Compiler.define(Std.string(define));
	}
}
#end